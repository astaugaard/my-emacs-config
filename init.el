(require 'package)

(setq package-archives '(("melpa" . "https://stable.melpa.org/packages/")
			 ("elpa" . "https://elpa.gnu.org/packages/")))

(setq package-archive-priorities '(("elpa" . 20)
			    ("melpa" . 10)))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-integration t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))
(define-key evil-normal-state-map (kbd "SPC") nil)
(define-key evil-visual-state-map (kbd "SPC") nil)
(define-key evil-motion-state-map (kbd "SPC") nil)
(defun aa/kbdl (key)
   "turns a input into a keybinding for using with the space leader key 
 eg. ab -> SPC a b then runs it threw the kbd function"
   (setq key-sequence "SPC")
   (if (stringp key)
       (dotimes (i (length key))
	 (setq key-sequence (format "%s %c" key-sequence (elt key i))))
     (setq key-sequence (format "%s %c" key-sequence key)))
   (kbd key-sequence))

;; from evil-collection github 
(defvar my-intercept-mode-map (make-sparse-keymap)
  "High precedence keymap.")

(define-minor-mode my-intercept-mode
  "Global minor mode for higher precedence evil keybindings."
  :global t)

(my-intercept-mode)

(dolist (state '(normal visual insert))
  (evil-make-intercept-map
   ;; NOTE: This requires an evil version from 2018-03-20 or later
   (evil-get-auxiliary-keymap my-intercept-mode-map state t t)
   state))

(define-key global-map (kbd "C-SPC") nil)

(use-package evil-collection
  :after evil
  :config
  (defun my-no-space-rotation (_mode mode-keymaps &rest _rest)
    (evil-collection-translate-key 'normal mode-keymaps
      (kbd "C-SPC") (kbd "SPC")
      "[" nil
      "]" nil
      "[[" "["
      "]]" "]"))
  (add-hook 'evil-collection-setup-hook #'my-no-space-rotation)
  (evil-collection-init)) ;; vim keybindings for different modes and common packages

(use-package hydra) ;; another way to make keybindings

(use-package doom-themes)

(setq inhibit-startup-message t)
(setq visible-bell t)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(set-fringe-mode 10)
(set-face-attribute 'default nil :font "Droid Sans Mono Slashed for Powerline 12")
(load-theme 'doom-dracula t)
(blink-cursor-mode -1)
(column-number-mode)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

(use-package which-key
  :init
  (setq which-key-idle-delay 0.3)
  :config
  (which-key-mode)
  (which-key-add-key-based-replacements
    "SPC g" "goto+more"
    "SPC e" "execute"
    "SPC o" "open"
    "SPC w" "windows"
    "SPC f" "files"
    "SPC m" "make"
    "SPC q" "quick toggle"
    "SPC c" "current-mode")
  :diminish which-key-mode) ;; shows keybindings

(use-package avy
  :init
  (setq avy-keys (list 97 111 101 117 104 116 110 115))) ;; movement

;;     (ido-mode t)
;;
;;     (defun aa/ido-extended-command()
;;       "taken from https://emacs.stackexchange.com/questions/45107/ido-mode-autocomplete-in-interactively-mode
;;     mimics execute-extended-command but with ido"
;;       (interactive)
;;       (call-interactively
;;	(intern
;;	 (ido-completing-read "command: " (all-completions "" obarray 'commandp)))))
;;     (setq ido-enable-flex-matching t)
;;     (setq ido-everywhere nil)
;;
;;
;;     ;; for ido emulation in the minibuffer
;;     (fido-mode)
;;
;;     (defun my-icomplete-styles ()
;;       (setq-local completion-styles '(substring initials partial-completion flex)))
;;     (add-hook 'icomplete-minibuffer-setup-hook 'my-icomplete-styles)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
	 :map ivy-minibuffer-map
	 ("RET" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-d" . ivy-immediate-done)
	 ("C-t" . ivy-next-line)
	 ("C-n" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-n" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-n" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (setq ivy-initial-inputs-alist nil)
  (setq ivy-re-builders-alist '((t . ivy--regex-ignore-order)))
  (ivy-mode 1))

(use-package counsel
  :bind (:map minibuffer-local-map
	("C-r" . 'counsel-minibuffer-history)))

(use-package ace-window)
(setq aw-keys '(?a ?o ?u ?e ?h ?t ?n ?s))

(setq display-buffer-base-action
      '((display-buffer-reuse-window
	 display-buffer-reuse-mode-window
	 display-buffer-in-previous-window
	 display-buffer-same-window)
	. ((mode . (help-mode org-mode)))))

(setq indent-tabs-mode nil)
(setq make-backup-files nil)

(defun aa/lsp-mode-setup () 
      (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
      (lsp-headerline-breadcrumb-mode)
      (message "lsp mode setup")
      (add-hook 'before-save-hook 'lsp-format-buffer)
      (add-hook 'before-save-hook (lambda () (message "formating"))))

(use-package lsp-mode
     :commands (lsp lsp-deferred)
     :init
     (setq lsp-keymap-prefix "C-c l")
     :hook (c++-mode . lsp-deferred)
     :hook (c++-mode . lsp-deferred)
     :hook (lsp-mode . aa/lsp-mode-setup)
     :config
    (lsp-enable-which-key-integration t))

(use-package lsp-ui)



(use-package yasnippet
  :diminish yas-minor-mode
  :config
  (yas-global-mode 1))
;;  (add-hook 'yas-minor-mode-hook (lambda ()
;;				   (yas-activate-extra-mode 'fundemental-mode)))
(add-hook 'company-mode-hook (lambda ()
                                     (evil-define-key '(insert) company-active-map (kbd "SPC") yas-expand)))

;; convert to upper
(defun aa/ifn-format (str)
  (concat (upcase (replace-regexp-in-string " " "_" str)) (upcase (replace-regexp-in-string "-" "_" (replace-regexp-in-string "\\." "_" (file-name-nondirectory (buffer-file-name)))))))
;;(defun aa/yas-after-exit ()
;;  (let ((pos 0))
;;    (setq aa/helper (lambda ()
;;		      (flush-lines "^\\input")
;;		      (setq pos (search-backward "@@" nil t -1))
;;		      (delete-char (length "@@"))))
;;    (replace-region-contents yas-snippet-beg yas-snippet-end aa/helper)
;;    (goto-char (+ (point) pos))))
;;;;  (flush-lines "^\\input" yas-snippet-beg yas-snippet-end)
;;;;  (search-backwards "@@" yas-snippet-end)
;;
;;(add-hook 'yas-after-exit-snippet-hook 'aa/yas-after-exit)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
	      ("C-t" . company-select-next)
	      ("<tab>" . company-complete-selection)
	      ("C-n" . company-select-previous))
  (:map lsp-mode-map
	("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package org)

(setq org-ellipsis "???")
(defun org-my-setup()
    ""
    (set-face-underline 'org-ellipsis nil))
(add-hook 'org-mode-hook 'org-my-setup)

(font-lock-add-keywords 'org-mode
			'(("^ *\\([-]\\) "
			   (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "??"))))))

(font-lock-add-keywords 'org-mode
		      '(("^[ \\t]*\\(- \\[[ -]\\]\\)" . (1 'message-mml))
			("^[ \\t]*\\(- \\[X\\]\\)" . (1 'epa-mark))))

(font-lock-add-keywords 'org-mode
			  '(("^\\(\\**\\)\\* " (1 'org-hide))
			  ("^\\**\\(\\*\\) " (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "	???"))))))

(font-lock-add-keywords 'org-mode
			  '(("^ *\\([0-9]*\\.\\)" . (1 'message-mml))))

(setq org-agenda-start-with-log-mode t)
(setq org-log-done 'time)
(setq org-agenda-files
      '("~/org/todo.org"))

(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")))

(setq org-tag-alist
      '((:startgroup)
	;; i don't know why this is here
	(:endgroup)
	("idea" . ?i))) ;; add tags here to add sorting functionality

(setq org-agenda-custom-commands
      '(("n" "Next Tasks"
	 ((todo "NEXT"
		((org-agenda-overriding-header "Next Tasks")))))
	("i" "Ideas" tags-todo "idea")
	("e" "low effort" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
	 ((org-agenda-overriding-header "Low Effort Tasks")
	  (org-agenda-max-todos 20)
	  (org-agenda-files org-agenda-files)))
	("d" "Dasboard"
	 ((agenda "" ((org-deadlines-warning-days 14)))
	  (todo "NEXT"
		((org-agenda-overriding-header "Next Tasks")))))))  ;; can also use tags don't know how to set tags

(setq org-capture-templates
      '(("t" "Todo")
	("tg" "general Todo" entry (file+olp "~/org/todo.org" "Misc Todos")
	 "* TODO %?\n %U\n %a" :empty-lines 1))) ;; capture template ie away that when you execute org-capture lets you log that thing it a org file and a location

(org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
	(python . t)))

;;     (push '("conf-unix" . conf-unix) org-src-lang-modes)

(defun aa/org-babel-tangle-config()
       (when (string-equal (buffer-file-name)
	     (expand-file-name "~/.emacs.d/init.org"))
             (message "attempting to tangle")
	  (let ((org-confirm-babel-evaluate nil))
	     (org-babel-tangle))))
   (add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'aa/org-babel-tangle-config)))

(require 'org-habit)
(add-to-list 'org-modules 'org-habit)
(setq org-habbit-graph-column 60)

(setq org-refile-targets
      '(("Archive.org" :maxlevel . 1)
	("todo.org" :maxlevel . 1)))

(advice-add 'org-refile :after 'org-save-all-org-buffers)

(evil-define-key '(normal motion) org-mode-map (aa/kbdl "cl") 'org-insert-link
  (aa/kbdl "co") 'org-open-link
  (aa/kbdl "ct") 'org-todo
  (aa/kbdl "cc") 'org-toggle-checkbox
  (aa/kbdl "cs") 'org-schedule
  (aa/kbdl "cd") 'org-deadline
  (aa/kbdl "cS") 'org-time-stamp)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)))

(require 'org-tempo)
(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

(use-package magit)

(evil-define-key '(normal motion) Info-mode-map (aa/kbdl "co") 'Info-follow-nearest-node)

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :custom ((dired-listing-switches "-AFGghot"))) ;; this uses ls to get the directory information

(add-hook 'dired-mode-hook
	  (lambda ()
	     (dired-hide-details-mode)))

(evil-collection-define-key 'normal 'dired-mode-map
   "h" 'dired-up-directory
   "l" 'dired-find-file)

(evil-define-key '(normal motion) apropos-mode-map
  (aa/kbdl "cf") 'apropose-follow)

(evil-define-key '(normal motion) log-edit-mode-map
  (aa/kbdl "cd") 'log-edit-done)

(defun aa/term ()
  "starts a zsh terminal"
  (interactive)
  (term "/usr/local/bin/fish"))

(defun aa/open-agenda-new-window ()
  "opens org-agenda in a new window"
  (interactive)
  (split-window-right)
  (evil-window-right 1)
  (evil-window-move-far-right)
  (org-agenda))

(defun aa/new-shell-window()
  (interactive)
  (split-window-right)
  (evil-window-right 1)
  (aa/window-bottom)
  (aa/term))

(defun aa/window-bottom()
  (interactive)
  (evil-window-move-very-bottom)
  (evil-window-set-height 15))

(defun aa/window-top()
  (interactive)
  (evil-window-move-very-top)
  (evil-window-set-height 15))

(defhydra hydra-less (:color red)
  "scroll"
  ("t" scroll-up)
  ("s" swiper)
  ("n" scroll-down))

(defhydra hydra-window-movement (:color red :hint nil)
  "
^Size^           ^Move^               ^Split^      ^Open^         ^Delete^      ^Snap^
^^^^^^^^^^^^---------------------------------------------------------------------------------
_m_: - width     _s_: swap window     _S_: Right   _T_: terminal  _d_: window   _a_: left
_v_: + height    _t_: to window       _V_: Down    _H_: Help      _f_: other w  _o_: down
_w_: - height         ^^       ^^                  _F_: file      ^^            _e_: up
_z_: + width              ^^             ^^        _A_: agenda    ^^            _u_: right
_j_: - textS    ^^^^                               _b_: buffer
_k_: + textS
\" \": exit
"
  ("m" shrink-window-horizontally)
  ("w" shrink-window)
  ("v" enlarge-window)
  ("z" enlarge-window-horizontally)
  ("j" text-scale-decrease)
  ("k" text-scale-increase)

  ("b" switch-to-buffer :color blue)

  ("t" ace-select-window)
  ("s" ace-swap-window)

  ("S" split-window-below)
  ("V" split-window-right)

  ("H" help-for-help :color blue)
  ("T" aa/new-shell-window :color blue)
  ("F" find-file :color blue)
  ("A" aa/open-agenda-new-window :color blue)

  ("f" delete-other-windows :color blue)
  ("d" ace-delete-window)
  (" " nil :color blue)

  ("a" evil-window-move-far-left)
  ("o" aa/window-bottom)
  ("e" aa/window-top)
  ("u" evil-window-move-far-right))

(evil-define-key '(normal motion) my-intercept-mode-map
  (aa/kbdl "b") 'switch-to-buffer
  (aa/kbdl "of") 'counsel-find-file
  (aa/kbdl "ot") 'aa/term
  (aa/kbdl "oe") 'ielm
  (aa/kbdl "od") 'dired
  (aa/kbdl "os") 'yas-new-snippet
  (aa/kbdl "oa") 'org-agenda
  (aa/kbdl "oc") 'org-capture
  (aa/kbdl "ov") 'vc-next-action

(aa/kbdl "t") 'ace-window
(aa/kbdl "s") 'ace-swap-window
(aa/kbdl "d") 'ace-delete-window

;; makeing and deleting windows
(aa/kbdl "w") 'hydra-window-movement/body

;; execute commands
(aa/kbdl "ec") 'counsel-M-x
(aa/kbdl "eb") 'load-buffer
(aa/kbdl "el") 'eval-last-sexp
(aa/kbdl "ee") 'eval-expression
(aa/kbdl "et") 'shell-command
(aa/kbdl "er") 'eval-region

(aa/kbdl "gs") 'swiper
(aa/kbdl "gl") 'avy-goto-line
(aa/kbdl "gf") 'imenu

(aa/kbdl "ga") 'avy-goto-char-2
(aa/kbdl "gy") 'avy-kill-ring-save-whole-line
(aa/kbdl "gd") 'avy-kill-whole-line
(aa/kbdl "gY") 'avy-kill-ring-save-region
(aa/kbdl "gD") 'avy-kill-region
(aa/kbdl "gm") 'avy-move-line
(aa/kbdl "gM") 'avy-move-region
(aa/kbdl "gc") 'avy-copy-line
(aa/kbdl "gC") 'avy-copy-region

(kbd "s") 'avy-goto-word-1
(kbd "j") 'evil-next-visual-line
(kbd "k") 'evil-previous-visual-line

(aa/kbdl "mr") 'recompile
(aa/kbdl "mc") 'compile
(aa/kbdl "mn") 'next-error

(aa/kbdl "qw") 'whitespace-mode

(aa/kbdl "fa") 'rename-file
(aa/kbdl "fs") 'save-buffer
(aa/kbdl "fr") 'undo-redo
(aa/kbdl "ff") 'ff-find-other-file
(aa/kbdl "fc") 'kill-buffer
(aa/kbdl "fo") 'dired-jump
(aa/kbdl "l") 'hydra-less/body)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(magit yasnippet which-key use-package lsp-ui hydra evil-collection doom-themes counsel company ace-window)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
