# frozen_string_literal: true

module Occurrences
  Result = Struct.new(:success, :error, keyword_init: true) do
    def success?
      success
    end
  end
end
