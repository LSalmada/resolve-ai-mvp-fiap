# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API v1 occurrences", type: :request do
  let(:requester) { create(:user, :requester, name: "Lucas Souza") }
  let(:other) { create(:user, :requester, name: "Camila") }
  let(:manager) { create(:user, :manager, name: "Síndica") }
  let!(:mine) { create(:occurrence, reporter: requester, title: "Lâmpada queimada") }
  let!(:theirs) { create(:occurrence, reporter: other, title: "Portão aberto", category: :security) }

  def api_sign_in(user, password: "password123")
    post api_v1_sessions_path, params: { email: user.email, password: password }, as: :json
    expect(response).to have_http_status(:created)
  end

  def json_body
    JSON.parse(response.body)
  end

  it "rejects anonymous requests" do
    get api_v1_occurrences_path

    expect(response).to have_http_status(:unauthorized)
    expect(json_body["error"]).to eq("Você precisa estar autenticado.")
  end

  it "lists only the requester's occurrences" do
    api_sign_in requester

    get api_v1_occurrences_path, as: :json

    titles = json_body["occurrences"].map { |item| item["title"] }
    expect(titles).to include("Lâmpada queimada")
    expect(titles).not_to include("Portão aberto")
  end

  it "lets a requester create an occurrence with a photo" do
    api_sign_in requester

    expect do
      post api_v1_occurrences_path, params: {
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
    expect(response).to have_http_status(:created)
    expect(json_body.dig("occurrence", "title")).to eq("Vazamento no hall")
    expect(occurrence.photo).to be_attached
    expect(json_body.dig("occurrence", "photo_url")).to match(%r{/rails/active_storage/blobs/})
  end

  it "does not let a requester view someone else's occurrence" do
    api_sign_in requester

    get api_v1_occurrence_path(theirs), as: :json

    expect(response).to have_http_status(:not_found)
  end

  it "lets a manager filter the inbox" do
    api_sign_in manager
    theirs.update!(priority: :urgent)

    get api_v1_occurrences_path, params: { priority: "urgent" }, as: :json
    expect(json_body["occurrences"].map { |item| item["title"] }).to eq([ "Portão aberto" ])

    get api_v1_occurrences_path, params: { category: "security" }, as: :json
    expect(json_body["occurrences"].map { |item| item["title"] }).to eq([ "Portão aberto" ])

    advance_status!(mine, actor: manager, to_status: "in_analysis", note: "Analisando")
    get api_v1_occurrences_path, params: { status: "in_analysis" }, as: :json
    expect(json_body["occurrences"].map { |item| item["title"] }).to eq([ "Lâmpada queimada" ])
  end

  it "rejects invalid credentials" do
    post api_v1_sessions_path, params: { email: requester.email, password: "wrong" }, as: :json

    expect(response).to have_http_status(:unauthorized)
    expect(json_body["error"]).to eq("E-mail ou senha inválidos.")
  end

  it "includes comments and events on show" do
    api_sign_in manager

    get api_v1_occurrence_path(mine), as: :json

    expect(response).to have_http_status(:success)
    expect(json_body.dig("occurrence", "comments")).to eq([])
    expect(json_body.dig("occurrence", "events")).to eq([])
  end

  it "updates priority, assignee and status through patch" do
    api_sign_in manager

    patch api_v1_occurrence_path(mine), params: { occurrence: { priority: "high" } }, as: :json
    expect(response).to have_http_status(:success)
    expect(json_body.dig("occurrence", "priority")).to eq("high")
    expect(mine.reload).to be_high

    patch api_v1_occurrence_path(mine), params: { occurrence: { assignee_id: manager.id } }, as: :json
    expect(response).to have_http_status(:success)
    expect(json_body.dig("occurrence", "assignee", "id")).to eq(manager.id)

    patch api_v1_occurrence_path(mine), params: {
      occurrence: { status: "in_analysis", note: "Vistoria agendada." }
    }, as: :json
    expect(response).to have_http_status(:success)
    expect(json_body.dig("occurrence", "status")).to eq("in_analysis")
    expect(mine.reload.occurrence_events.count).to eq(3)
  end

  it "requires a note to change status" do
    api_sign_in manager

    patch api_v1_occurrence_path(mine), params: { occurrence: { status: "in_analysis" } }, as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(json_body["error"]).to eq("A observação é obrigatória para avançar o status.")
    expect(mine.reload).to be_open
  end

  it "does not let a requester patch occurrence fields" do
    api_sign_in requester

    patch api_v1_occurrence_path(mine), params: { occurrence: { priority: "urgent" } }, as: :json

    expect(response).to have_http_status(:forbidden)
    expect(mine.reload).to be_medium
  end

  it "rejects an invalid status skip" do
    api_sign_in manager

    patch api_v1_occurrence_path(mine), params: {
      occurrence: { status: "resolved", note: "Pulando", resolution_notes: "Não." }
    }, as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(json_body["error"]).to eq("Status não pode mudar de Aberta para Resolvida")
    expect(mine.reload).to be_open
  end

  it "requires resolution notes when resolving, with a pt-BR message" do
    advance_status!(mine, actor: manager, to_status: "in_analysis")
    advance_status!(mine, actor: manager, to_status: "in_progress")
    api_sign_in manager

    patch api_v1_occurrence_path(mine), params: {
      occurrence: { status: "resolved", note: "Concluído" }
    }, as: :json

    expect(response).to have_http_status(:unprocessable_entity)
    expect(json_body["error"]).to eq("Solução aplicada é obrigatória ao marcar como resolvida")
    expect(mine.reload).to be_in_progress
  end

  it "rejects rating before the occurrence is resolved" do
    api_sign_in requester

    post api_v1_occurrence_rating_path(mine), params: { rating: 5, rating_comment: "Cedo." }, as: :json

    expect(response).to have_http_status(:forbidden)
    expect(mine.reload.rating).to be_nil
  end

  it "lets the owner rate after resolution and keeps the requester off the dashboard" do
    api_sign_in manager
    patch api_v1_occurrence_path(mine), params: {
      occurrence: { status: "in_analysis", note: "Analisando" }
    }, as: :json
    patch api_v1_occurrence_path(mine), params: {
      occurrence: { status: "in_progress", note: "Equipe no local" }
    }, as: :json
    patch api_v1_occurrence_path(mine), params: {
      occurrence: { status: "resolved", note: "Concluído", resolution_notes: "Lâmpada substituída." }
    }, as: :json
    expect(response).to have_http_status(:success)

    api_sign_in requester
    post api_v1_occurrence_comments_path(mine), params: { comment: { body: "Obrigado pelo retorno." } }, as: :json
    expect(response).to have_http_status(:created)
    expect(json_body.dig("comment", "body")).to eq("Obrigado pelo retorno.")

    post api_v1_occurrence_rating_path(mine), params: { rating: 5, rating_comment: "Rápido." }, as: :json
    expect(response).to have_http_status(:success)
    expect(json_body.dig("occurrence", "rating")).to eq(5)

    get api_v1_dashboard_path, as: :json
    expect(response).to have_http_status(:forbidden)
  end

  it "returns aggregated dashboard metrics for a manager" do
    api_sign_in manager

    get api_v1_dashboard_path, as: :json

    expect(response).to have_http_status(:success)
    expect(json_body["total"]).to eq(2)
    expect(json_body["open_count"]).to eq(2)
    expect(json_body["resolved_count"]).to eq(0)
    expect(json_body.dig("status_counts", "open")).to eq(2)
  end

  it "destroys the session" do
    api_sign_in requester

    delete api_v1_sessions_path, as: :json
    expect(response).to have_http_status(:no_content)

    get api_v1_occurrences_path, as: :json
    expect(response).to have_http_status(:unauthorized)
  end
end
