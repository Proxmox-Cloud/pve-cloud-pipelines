;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((python-venv-project . "~/.pve-cloud-dev-venv") ;; this autosources in vterm and sets pylsp jedi env
         ;; (lsp-additional-ignore-direct
         (lsp-additional-ignore-directories . ("ansible_collections"
                                               "/target\\'"
                                               "/\\.terraform\\'"
                                               "/\\.pytest_cache\\'"
                                               "/dist\\'"))
         )))
