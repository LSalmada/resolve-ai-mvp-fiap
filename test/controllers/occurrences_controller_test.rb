# frozen_string_literal: true

require "test_helper"

class OccurrencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @requester = create_user(role: :requester, name: "Lucas Souza")
    @other = create_user(role: :requester, name: "Camila")
    @manager = create_user(role: :manager, name: "Síndica")
    @mine = create_occurrence(reporter: @requester, title: "Lâmpada queimada")
    @theirs = create_occurrence(reporter: @other, title: "Portão aberto")
  end

  test "requester sees only own occurrences and can open the new form" do
    sign_in @requester

    get occurrences_path
    assert_response :success
    assert_select "a", text: "Lâmpada queimada"
    assert_select "a", text: "Portão aberto", count: 0
    assert_select "a", text: "Nova ocorrência"
    assert_select "a", text: "Dashboard", count: 0

    get new_occurrence_path
    assert_response :success
  end

  test "requester creates an occurrence with photo" do
    sign_in @requester

    assert_difference -> { Occurrence.count }, 1 do
      post occurrences_path, params: {
        occurrence: {
          title: "Vazamento no hall",
          description: "Poça perto do elevador.",
          location: "Bloco A, térreo",
          category: "leakage",
          photo: fixture_file_upload(file_fixture("photo.png"), "image/png")
        }
      }
    end

    occurrence = Occurrence.order(:id).last
    assert_redirected_to occurrence_path(occurrence)
    assert occurrence.photo.attached?
    assert_equal @requester, occurrence.reporter
    assert occurrence.open?
  end

  test "requester cannot view someone else's occurrence" do
    sign_in @requester

    get occurrence_path(@theirs)
    assert_response :not_found
  end

  test "manager inbox lists every occurrence and can filter" do
    sign_in @manager
    @theirs.update!(priority: :urgent)

    get occurrences_path
    assert_response :success
    assert_select "a", text: "Lâmpada queimada"
    assert_select "a", text: "Portão aberto"
    assert_select "a", text: "Dashboard"

    get occurrences_path, params: { priority: "urgent" }
    assert_response :success
    assert_select "a", text: "Portão aberto"
    assert_select "a", text: "Lâmpada queimada", count: 0
  end

  test "manager conducts priority, assignee and status with a note" do
    sign_in @manager

    patch prioritize_occurrence_path(@mine), params: { priority: "high" }
    assert_redirected_to occurrence_path(@mine)
    assert @mine.reload.high?

    patch assign_occurrence_path(@mine), params: { assignee_id: @manager.id }
    assert_redirected_to occurrence_path(@mine)
    assert_equal @manager, @mine.reload.assignee

    patch transition_occurrence_path(@mine), params: { to_status: "in_analysis" }
    follow_redirect!
    assert_response :success
    assert @mine.reload.open?

    patch transition_occurrence_path(@mine), params: {
      to_status: "in_analysis",
      note: "Vistoria agendada."
    }
    assert_redirected_to occurrence_path(@mine)
    assert @mine.reload.in_analysis?
    assert_equal 3, @mine.occurrence_events.count
  end

  test "owner comments and rates a resolved occurrence" do
    sign_in @manager
    patch transition_occurrence_path(@mine), params: { to_status: "in_analysis", note: "Analisando" }
    patch transition_occurrence_path(@mine), params: { to_status: "in_progress", note: "Equipe no local" }
    patch transition_occurrence_path(@mine), params: {
      to_status: "resolved",
      note: "Concluído",
      resolution_notes: "Lâmpada substituída."
    }

    sign_in @requester
    post occurrence_comments_path(@mine), params: { comment: { body: "Obrigado pelo retorno." } }
    assert_redirected_to occurrence_path(@mine)

    post occurrence_rating_path(@mine), params: { occurrence: { rating: 5, rating_comment: "Rápido." } }
    assert_redirected_to occurrence_path(@mine)
    @mine.reload
    assert_equal 5, @mine.rating
    assert_equal "Rápido.", @mine.rating_comment
    assert_equal 1, @mine.comments.count
  end
end
