# frozen_string_literal: true

class Views::Base < Components::Base
  extend Phlex::Rails::HelperMacros
  register_value_helper :current_user
  register_value_helper :page_heading

  include Phlex::Rails::Helpers::FormWith
  include Phlex::Rails::Helpers::LinkTo
  include Phlex::Rails::Helpers::ButtonTo
  include Phlex::Rails::Helpers::L
  include Phlex::Rails::Helpers::Pluralize
  include Phlex::Rails::Helpers::T
  include Phlex::Rails::Helpers::URLFor
  include Phlex::Rails::Helpers::ContentFor
  include ApplicationHelper

  def cache_store = Rails.cache

  def apply_stored_theme
    script do
      raw safe(<<~JS)
        (() => {
          const stored = localStorage.theme;
          const theme = stored === "light" || stored === "dark" ? stored : "dark";
          document.documentElement.classList.toggle("dark", theme === "dark");
          document.documentElement.classList.toggle("light", theme === "light");
        })();
      JS
    end
  end
end
