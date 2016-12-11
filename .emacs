;; Update load path for custom
(add-to-list 'load-path "~/.emacs.d/custom/")


;; Package repos
(when (>= emacs-major-version 24)
  (require 'package)
  (package-initialize)
  (add-to-list 'package-archives '("elpa" . "http://elpa.gnu.org/packages/") t)
  (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
  (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
  )


;; Set color theme
(require 'color-theme)
(color-theme-initialize)
(color-theme-calm-forest)
;;(load-theme 'fogus t)
     ;;(color-theme-robin-hood)
     ;;(color-theme-lethe)
     ;;(color-theme-hober)
     ;;(color-theme-clarity-and-beauty)
     ;;(color-theme-high-contrast)
     ;;(color-theme-midnight)
     ;;(color-theme-standard-emacs-20)


;; Configure transparency
;; Default
;;(set-frame-parameter (selected-frame) 'alpha '(<active> [<inactive>]))
(set-frame-parameter (selected-frame) 'alpha '(80 50))
(add-to-list 'default-frame-alist '(alpha 80 50))
;; Interactive
(defun djcb-opacity-modify (&optional dec)
  "modify the transparency of the emacs frame; if DEC is t,
    decrease the transparency, otherwise increase it in 10%-steps"
  (let* ((alpha-or-nil (frame-parameter nil 'alpha)) ; nil before setting
          (oldalpha (if alpha-or-nil alpha-or-nil 100))
          (newalpha (if dec (- oldalpha 10) (+ oldalpha 10))))
    (when (and (>= newalpha frame-alpha-lower-limit) (<= newalpha 100))
      (modify-frame-parameters nil (list (cons 'alpha newalpha))))))
 ;; C-8 will increase opacity (== decrease transparency)
 ;; C-9 will decrease opacity (== increase transparency
 ;; C-0 will returns the state to normal
(global-set-key (kbd "C-8") '(lambda()(interactive)(djcb-opacity-modify)))
(global-set-key (kbd "C-9") '(lambda()(interactive)(djcb-opacity-modify t)))
(global-set-key (kbd "C-0") '(lambda()(interactive)
                               (modify-frame-parameters nil `((alpha . 100)))))

;; No tabs and use 4 spaces by default
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq indent-line-function 'insert-tab)

;; Display trailing whitespaces by default
(setq-default show-trailing-whitespace t)

(add-to-list 'load-path "/Applications/Dash.app")
(autoload 'dash-at-point "dash-at-point"
  "Search the word at point with Dash." t nil)
(global-set-key "\C-cd" 'dash-at-point)

;; Hide ugly toolbar
;; Point EDTS to Erlang man
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(edts-man-root "~/.emacs.d/edts/doc/17.5")
 '(tool-bar-mode nil))

;; I don't need your Welcome!
(setq inhibit-startup-message t)

;; Show line numbers (there <-) and cursor position
(global-linum-mode 1)
(column-number-mode 1)

;; Zoom In/Out
(global-set-key [C-mouse-wheel-up-event] 'text-scale-increase)
(global-set-key [C-mouse-wheel-down-even] 'text-scale-decrease)

;; Erlang

;; The path to OTP
(setq load-path (cons "/usr/local/lib/erlang/lib/tools-2.7.1/emacs"
		      load-path))
(setq erlang-root-dir "/usr/local/lib/erlang")
(setq exec-path (cons "/usr/local/lib/erlang/bin" exec-path))
(setq erlang-man-root-dir "/usr/local/lib/erlang/man")
(require 'erlang-start)
(add-to-list 'auto-mode-alist '("\\.erl?$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.hrl?$" . erlang-mode))

(defun my-erlang-mode-hook ()
  ;; add Erlang functions to an imenu menu
  (imenu-add-to-menubar "imenu")
  ;; no tabs
  (function (lambda ()
                (setq indent-tabs-mode nil)))
  ;; customize keys
;;  (local-set-key [return] 'newline-and-indent)
  )

;; Some Erlang customizations
(add-hook 'erlang-mode-hook 'my-erlang-mode-hook)

;; when starting an Erlang shell in Emacs, default in the node name
(setq inferior-erlang-machine-options '("-sname" "emacs"))

;; Distel
;; (add-to-list 'load-path "/usr/local/share/distel/elisp")
;; (require 'distel)
;; (distel-setup)
;; ;; tell distel to default to that node
;; (setq erl-nodename-cache
;;       (make-symbol
;;        (concat
;;         "emacs@"
;;         ;; Mac OS X uses "name.local" instead of "name", this should work
;;         ;; pretty much anywhere without having to muck with NetInfo
;;         ;; ... but I only tested it on Mac OS X.
;;         (car (split-string (shell-command-to-string "hostname"))))))

;; EDTS
(add-hook 'after-init-hook 'erl-edts-after-init-hook)
(defun erl-edts-after-init-hook ()
  (require 'edts-start))


;; Python

(require 'python-mode)
(require 'ipython)

(autoload 'pylint "pylint")
(add-hook 'python-mode-hook 'pylint-add-menu-items)
(add-hook 'python-mode-hook 'pylint-add-key-bindings)

(defvar local-packages '(projectile auto-complete epc jedi))

(defun uninstalled-packages (packages)
  (delq nil
	(mapcar (lambda (p) (if (package-installed-p p nil) nil p)) packages)))

;; This delightful bit adapted from:
;; http://batsov.com/articles/2012/02/19/package-management-in-emacs-the-good-the-bad-and-the-ugly/

(let ((need-to-install (uninstalled-packages local-packages)))
  (when need-to-install
    (progn
      (package-refresh-contents)
      (dolist (p need-to-install)
	(package-install p)))))

;; Global Jedi config vars

(defvar jedi-config:use-system-python nil
  "Will use system python and active environment for Jedi server.
May be necessary for some GUI environments (e.g., Mac OS X)")

(defvar jedi-config:with-virtualenv nil
  "Set to non-nil to point to a particular virtualenv.")

(defvar jedi-config:vcs-root-sentinel ".git")

(defvar jedi-config:python-module-sentinel "__init__.py")

;; Helper functions

;; Small helper to scrape text from shell output
(defun get-shell-output (cmd)
  (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string cmd)))

;; Ensure that PATH is taken from shell
;; Necessary on some environments without virtualenv
;; Taken from: http://stackoverflow.com/questions/8606954/path-and-exec-path-set-but-emacs-does-not-find-executable

(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell."
  (interactive)
  (let ((path-from-shell (get-shell-output "$SHELL --login -i -c 'echo $PATH'")))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

;; Package specific initialization
(add-hook
 'after-init-hook
 '(lambda ()

    ;; Looks like you need Emacs 24 for projectile
    (unless (< emacs-major-version 24)
      (require 'projectile)
      (projectile-global-mode))

    ;; Auto-complete
    (require 'auto-complete-config)
    (ac-config-default)

    ;; Uncomment next line if you like the menu right away
    ;; (setq ac-show-menu-immediately-on-auto-complete t)

    ;; Can also express in terms of ac-delay var, e.g.:
       (setq ac-auto-show-menu (* ac-delay 2))

    ;; Jedi
    (require 'jedi)

    ;; (Many) config helpers follow

    ;; Alternative methods of finding the current project root
    ;; Method 1: basic
    (defun get-project-root (buf repo-file &optional init-file)
      "Just uses the vc-find-root function to figure out the project root.
       Won't always work for some directory layouts."
      (let* ((buf-dir (expand-file-name (file-name-directory (buffer-file-name buf))))
	     (project-root (vc-find-root buf-dir repo-file)))
	(if project-root
	    (expand-file-name project-root)
	  nil)))

    ;; Method 2: slightly more robust
    (defun get-project-root-with-file (buf repo-file &optional init-file)
      "Guesses that the python root is the less 'deep' of either:
         -- the root directory of the repository, or
         -- the directory before the first directory after the root
            having the init-file file (e.g., '__init__.py'."

      ;; make list of directories from root, removing empty
      (defun make-dir-list (path)
        (delq nil (mapcar (lambda (x) (and (not (string= x "")) x))
                          (split-string path "/"))))
      ;; convert a list of directories to a path starting at "/"
      (defun dir-list-to-path (dirs)
        (mapconcat 'identity (cons "" dirs) "/"))
      ;; a little something to try to find the "best" root directory
      (defun try-find-best-root (base-dir buffer-dir current)
        (cond
         (base-dir ;; traverse until we reach the base
          (try-find-best-root (cdr base-dir) (cdr buffer-dir)
                              (append current (list (car buffer-dir)))))

         (buffer-dir ;; try until we hit the current directory
          (let* ((next-dir (append current (list (car buffer-dir))))
                 (file-file (concat (dir-list-to-path next-dir) "/" init-file)))
            (if (file-exists-p file-file)
                (dir-list-to-path current)
              (try-find-best-root nil (cdr buffer-dir) next-dir))))

         (t nil)))

      (let* ((buffer-dir (expand-file-name (file-name-directory (buffer-file-name buf))))
             (vc-root-dir (vc-find-root buffer-dir repo-file)))
        (if (and init-file vc-root-dir)
            (try-find-best-root
             (make-dir-list (expand-file-name vc-root-dir))
             (make-dir-list buffer-dir)
             '())
          vc-root-dir))) ;; default to vc root if init file not given

    ;; Set this variable to find project root
    (defvar jedi-config:find-root-function 'get-project-root-with-file)

    (defun current-buffer-project-root ()
      (funcall jedi-config:find-root-function
               (current-buffer)
               jedi-config:vcs-root-sentinel
               jedi-config:python-module-sentinel))

    (defun jedi-config:setup-server-args ()
      ;; little helper macro for building the arglist
      (defmacro add-args (arg-list arg-name arg-value)
        `(setq ,arg-list (append ,arg-list (list ,arg-name ,arg-value))))
      ;; and now define the args
      (let ((project-root (current-buffer-project-root)))

        (make-local-variable 'jedi:server-args)

        (when project-root
          (message (format "Adding system path: %s" project-root))
          (add-args jedi:server-args "--sys-path" project-root))

        (when jedi-config:with-virtualenv
          (message (format "Adding virtualenv: %s" jedi-config:with-virtualenv))
          (add-args jedi:server-args "--virtual-env" jedi-config:with-virtualenv))))

    ;; Use system python
    (defun jedi-config:set-python-executable ()
      (set-exec-path-from-shell-PATH)
      (make-local-variable 'jedi:server-command)
      (set 'jedi:server-command
           (list (executable-find "python") ;; may need help if running from GUI
                 (cadr default-jedi-server-command))))

    ;; Now hook everything up
    ;; Hook up to autocomplete
    (add-to-list 'ac-sources 'ac-source-jedi-direct)

    ;; Enable Jedi setup on mode start
    (add-hook 'python-mode-hook 'jedi:setup)

    ;; Buffer-specific server options
    (add-hook 'python-mode-hook
              'jedi-config:setup-server-args)
    (when jedi-config:use-system-python
      (add-hook 'python-mode-hook
                'jedi-config:set-python-executable))

    ;; And custom keybindings
    (defun jedi-config:setup-keys ()
      (local-set-key (kbd "M-.") 'jedi:goto-definition)
      (local-set-key (kbd "M-,") 'jedi:goto-definition-pop-marker)
      (local-set-key (kbd "M-?") 'jedi:show-doc)
      (local-set-key (kbd "M-/") 'jedi:get-in-function-call))

    ;; Don't let tooltip show up automatically
    (setq jedi:get-in-function-call-delay 10000000)
    ;; Start completion at method dot
    (setq jedi:complete-on-dot t)
    ;; Use custom keybinds
    (add-hook 'python-mode-hook 'jedi-config:setup-keys)

    ))


;; Scala
;; Configure ENSIME
(require 'ensime)
(add-hook 'scala-mode-hook 'ensime-scala-mode-hook)

;; Thrift
(require 'thrift-mode)
(add-to-list 'auto-mode-alist '("\\.thrift$" . thrift-mode))

;; YAML
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.sls" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\docker-compose.sh" . yaml-mode))

;; Groovy
(require 'groovy-mode)
(add-to-list 'auto-mode-alist '("\\Jenkinsfile$" . groovy-mode))

;; Docker
(require 'dockerfile-mode)
(add-to-list 'auto-mode-alist '("\\Dockerfile.sh$" . dockerfile-mode))

;; Plantuml
;;flycheck
(with-eval-after-load 'flycheck
  (require 'flycheck-plantuml)
  (flycheck-plantuml-setup))
(add-to-list 'auto-mode-alist '("\\.wsd$" . plantuml-mode))

;; Set default window position and size
(setq initial-frame-alist
      '((top . 0)
	(left . 0)))

(toggle-frame-maximized)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
