# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "react" # @19.3.0
pin "react-dom" # @19.3.0
pin "react-dom/client", to: "https://ga.jspm.io/npm:react-dom@19.3.0/client.js"
pin "scheduler", to: "https://ga.jspm.io/npm:scheduler@0.28.0/index.js"
