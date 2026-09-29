# frozen_string_literal: true

require "rails_helper"

RSpec.describe Occurrences::SubmitRating do
  let(:owner) { create(:user, :requester) }
  let(:other) { create(:user, :requester) }
  let(:manager) { create(:user, :manager) }
  let(:occurrence) { create(:occurrence, reporter: owner) }

  it "rejects rating while the occurrence is not resolved" do
    result = described_class.call(
      occurrence: occurrence,
      actor: owner,
      rating: 5,
      rating_comment: "Cedo demais"
    )

    expect(result).not_to be_success
    expect(result.error).to eq("A ocorrência ainda não foi resolvida.")
    expect(occurrence.reload.rating).to be_nil
  end

  it "rejects rating from anyone other than the owner" do
    resolve_occurrence!(occurrence, actor: manager)

    result = described_class.call(
      occurrence: occurrence,
      actor: other,
      rating: 3,
      rating_comment: "Não é minha"
    )

    expect(result).not_to be_success
    expect(result.error).to eq("Somente o solicitante pode avaliar.")
  end

  it "rejects a second rating" do
    resolve_occurrence!(occurrence, actor: manager)
    described_class.call(occurrence: occurrence, actor: owner, rating: 5, rating_comment: "Ótimo")

    result = described_class.call(occurrence: occurrence.reload, actor: owner, rating: 1, rating_comment: "Mudou")

    expect(result).not_to be_success
    expect(result.error).to eq("Esta ocorrência já foi avaliada.")
    expect(occurrence.reload.rating).to eq(5)
  end

  it "stores the rating when the owner rates a resolved occurrence" do
    resolve_occurrence!(occurrence, actor: manager)

    result = described_class.call(
      occurrence: occurrence,
      actor: owner,
      rating: 4,
      rating_comment: "Resolvido."
    )

    expect(result).to be_success
    occurrence.reload
    expect(occurrence.rating).to eq(4)
    expect(occurrence.rating_comment).to eq("Resolvido.")
  end
end
