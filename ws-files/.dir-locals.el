;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((python-venv-project . "~/.pve-cloud-dev-venv") ;; this autosources in vterm and sets pylsp jedi env
         ;; todo: custom shit attempts to fix lsp, maybe solved by just dumping pyright
         ;; (lsp-additional-ignore-directories . ("/dist\\'"))
         (eval . (setq magit-repository-directories
                       (list (cons (locate-dominating-file default-directory ".dir-locals.el") 1)
                             (cons (expand-file-name "ansible_collections/pxc/cloud/" (locate-dominating-file default-directory ".dir-locals.el")) 0)))))))
