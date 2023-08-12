((nil . ((indent-tabs-mode . nil)
         (delete-trailing-lines . t)
         (require-final-newline . t)
         (before-save-hook . ((lambda ()
                                (save-excursion
                                  (add-file-local-variable 'coding 'utf-8-unix)))
                              delete-trailing-whitespace
                              t))))
 (org-mode . ((eval . (keymap-local-set "<f9>"
                                        "\N{ZERO WIDTH SPACE}"))
              ;; 链接🔗 保持原样渲染.
              (org-link-descriptive . nil)

              (mode . electric-quote-local)

              (eval . (electric-indent-local-mode -1)))))

;; Local Variables:
;; coding: utf-8-unix
;; End:
