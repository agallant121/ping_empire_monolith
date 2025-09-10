# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", integrity: "sha384-RrYZu0SIUSWw6KnQ9e4NU0mfuqJa4y/zsRQiX/eApHrP3kVWg3X3dvaWfR+oF0id" # @5.3.8
pin "@popperjs/core", to: "@popperjs--core.js", integrity: "sha384-bfekMOfeUlr1dHZfNaAFiuuOeD7r+Qh45AQ2HHJY7EAAI4QGJ6qx1Qq9gsbvS+60" # @2.11.8
pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.3.3/dist/js/bootstrap.esm.js"
pin "bootstrap.min.css", to: "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
