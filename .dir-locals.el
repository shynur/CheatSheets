((nil . ((indent-tabs-mode . nil)
         (delete-trailing-lines . t)
         (require-final-newline . t)
         (eval . (add-hook 'before-save-hook
                           (lambda ()
                             (save-excursion
                               (add-file-local-variable 'coding 'utf-8-unix)))
                           0 "buffer-local"))
         (eval . (add-hook 'before-save-hook
                           #'delete-trailing-whitespace
                           0 "buffer-local")))))

;; Local Variables:
;; coding: utf-8-unix
;; End:
