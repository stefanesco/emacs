;; -*- no-byte-compile: t; lexical-binding: nil -*-
(define-package "clj-refactor" "20260716.1545"
  "A collection of commands for refactoring Clojure code."
  '((emacs        "28.1")
    (yasnippet    "0.6.1")
    (paredit      "24")
    (clojure-mode "5.18.0")
    (cider        "2.0.0")
    (parseedn     "1.2.0")
    (transient    "0.4.1")
    (spinner      "1.7"))
  :url "https://github.com/clojure-emacs/clj-refactor.el"
  :commit "2805bd5f505fdb199a8c5a25fca398ec9c161e5b"
  :revdesc "2805bd5f505f"
  :keywords '("convenience" "clojure" "cider")
  :authors '(("Magnar Sveen" . "magnars@gmail.com")
             ("Lars Andersen" . "expez@expez.com")
             ("Benedek Fazekas" . "benedek.fazekas@gmail.com")
             ("Bozhidar Batsov" . "bozhidar@batsov.dev"))
  :maintainers '(("Magnar Sveen" . "magnars@gmail.com")
                 ("Lars Andersen" . "expez@expez.com")
                 ("Benedek Fazekas" . "benedek.fazekas@gmail.com")
                 ("Bozhidar Batsov" . "bozhidar@batsov.dev")))
