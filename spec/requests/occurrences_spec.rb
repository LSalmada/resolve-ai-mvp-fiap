# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Occurrences HTML", type: :request do
  let(:requester) { create(:user, :requester, name: "Lucas Souza") }
  let(:other) { create(:user, :requester, name: "Camila") }
  let(:manager) { create(:user, :manager, name: "Síndica") }
  let!(:mine) { create(:occurrence, reporter: requester, title: "Lâmpada queimada") }
  let!(:theirs) { create(:occurrence, reporter: other, title: "Portão aberto", category: :security) }

  describe "inbox scope" do
    it "shows a requester only their own occurrences" do
      sign_in requester

      get occurrences_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Lâmpada queimada")
      expect(response.body).not_to include("Portão aberto")
      expect(response.body).to include("Nova ocorrência")
      expect(response.body).not_to include("Dashboard")
    end

    it "does not let a requester open someone else's occurrence" do
      sign_in requester

      get occurrence_path(theirs)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "create with photo" do
    it "lets a requester register an occurrence with an image" do
      sign_in requester

      expect do
        post occurrences_path, params: {
          occurrence: {
            title: "Vazamento no hall",
            description: "Poça perto do elevador.",
            location: "Bloco A, térreo",
            category: "leakage",
            photo: Rack::Test::UploadedFile.new(Rails.root.join("spec/fixtures/files/photo.png"), "image/png")
          }
        }
      end.to change(Occurrence, :count).by(1)

      occurrence = Occurrence.order(:id).last
      expect(response).to redirect_to(occurrence_path(occurrence))
      expect(occurrence.photo).to be_attached
      expect(occurrence.reporter).to eq(requester)
      expect(occurrence).to be_open
    end
  end

  describe "manager filters" do
    before do
      sign_in manager
      theirs.update!(priority: :urgent)
    end

    it "lists the global inbox" do
      get occurrences_path

      expect(response).to have_http_status(:success)
      expect(response.body).to include("Lâmpada queimada")
      expect(response.body).to include("Portão aberto")
      expect(response.body).to include("Dashboard")
    end

    it "filters by priority" do
      get occurrences_path, params: { priority: "urgent" }

      expect(response.body).to include("Portão aberto")
      expect(response.body).not_to include("Lâmpada queimada")
    end

    it "filters by category" do
      get occurrences_path, params: { category: "security" }

      expect(response.body).to include("Portão aberto")
      expect(response.body).not_to include("Lâmpada queimada")
    end

    it "filters by status" do
      advance_status!(mine, actor: manager, to_status: "in_analysis", note: "Analisando")

      get occurrences_path, params: { status: "in_analysis" }

      expect(response.body).to include("Lâmpada queimada")
      expect(response.body).not_to include("Portão aberto")
    end
  end

  describe "manager actions" do
    it "sets priority, assignee and status only when a note is present" do
      sign_in manager

      patch prioritize_occurrence_path(mine), params: { priority: "high" }
      expect(response).to redirect_to(occurrence_path(mine))
      expect(mine.reload).to be_high

      patch assign_occurrence_path(mine), params: { assignee_id: manager.id }
      expect(response).to redirect_to(occurrence_path(mine))
      expect(mine.reload.assignee).to eq(manager)

      patch transition_occurrence_path(mine), params: { to_status: "in_analysis" }
      follow_redirect!
      expect(response).to have_http_status(:success)
      expect(mine.reload).to be_open

      patch transition_occurrence_path(mine), params: {
        to_status: "in_analysis",
        note: "Vistoria agendada."
      }
      expect(response).to redirect_to(occurrence_path(mine))
      expect(mine.reload).to be_in_analysis
      expect(mine.occurrence_events.count).to eq(3)
    end
  end

  describe "comments and rating" do
    it "lets the owner comment and rate a resolved occurrence" do
      sign_in manager
      resolve_occurrence!(mine, actor: manager)

      sign_in requester
      post occurrence_comments_path(mine), params: { comment: { body: "Obrigado pelo retorno." } }
      expect(response).to redirect_to(occurrence_path(mine))

      post occurrence_rating_path(mine), params: { occurrence: { rating: 5, rating_comment: "Rápido." } }
      expect(response).to redirect_to(occurrence_path(mine))
      mine.reload
      expect(mine.rating).to eq(5)
      expect(mine.rating_comment).to eq("Rápido.")
      expect(mine.comments.count).to eq(1)
    end

    it "blocks rating until the occurrence is resolved" do
      sign_in requester

      post occurrence_rating_path(mine), params: { occurrence: { rating: 5, rating_comment: "Cedo." } }

      expect(response).to redirect_to(occurrences_path)
      expect(mine.reload.rating).to be_nil
    end
  end
end
