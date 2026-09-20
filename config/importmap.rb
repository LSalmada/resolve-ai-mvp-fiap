# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
# Vendored because `bin/importmap pin` fails with json 3.x (`quirks_mode`).
pin "@floating-ui/dom", to: "floating-ui--dom.js"
pin_all_from "app/javascript/controllers", under: "controllers"
