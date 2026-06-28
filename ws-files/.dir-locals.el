;;; Directory Local Variables            -*- no-byte-compile: t -*-
;;; For more information see (info "(emacs) Directory Variables")

((nil . ((vterm-source-venv . "~/.pve-cloud-dev-venv/bin/activate")
         (lsp-additional-ignore-directories . ("ansible_collections"))
         (eval . (setq lsp-pyright-venv-path "~/.pve-cloud-dev-venv"))
         (eval . (setq magit-repository-directories
                       (list (cons (locate-dominating-file default-directory ".dir-locals.el") 1)
                             (cons (expand-file-name "ansible_collections/pxc/cloud/" (locate-dominating-file default-directory ".dir-locals.el")) 0)))))))
