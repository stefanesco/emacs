;;; early-init.el --- Runs before package/UI init -*- lexical-binding: t; -*-
;; Keep this minimal and fast; it executes before the frame is drawn.

;; Raise the GC ceiling during startup so we don't pause to collect while
;; loading packages.  init.el restores a sane runtime value afterwards.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Disable window chrome here (not in init.el) so it never flickers into view.
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq frame-inhibit-implied-resize t
      inhibit-startup-screen t)

;; Faster package activation.  Run M-x package-quickstart-refresh after you
;; add or remove packages to regenerate the cache.
(setq package-quickstart t)

;; Don't let native-compilation warnings pop a buffer in your face.
(setq native-comp-async-report-warnings-errors 'silent)
;;; early-init.el ends here
