((nil . ((eval . (when (buffer-file-name)
                   (add-hook 'before-save-hook (lambda ()
                                                 (save-excursion
                                                   (add-file-local-variable 'coding 'utf-8-unix)))
                             nil "buffer local"))))))

;; Local Variables:
;; coding: utf-8-unix
;; End:
