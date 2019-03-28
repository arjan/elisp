(require 'eieio)

(require 'eieio-base)

(require 'cl)

(require 'edit-server)
(edit-server-start)

(load "dired-x")

;; https://www.emacswiki.org/emacs/WinnerMode
(winner-mode 1)

;; Do not create those .#blah files as they interfere with 'watch'-based tooling
(setq create-lockfiles nil)

(setq split-width-threshold 120)

(global-set-key
 "\M-x"
 (lambda ()
   (interactive)
   (call-interactively
    (intern
     (ido-completing-read
      "M-x "
      (all-completions "" obarray 'commandp))))))

(add-to-list 'auto-mode-alist '("\\.ino$" . c-mode))

(add-to-list 'auto-mode-alist '("\\.config$" . erlang-mode))
;;(add-to-list 'auto-mode-alist '("\\.json$" . json-mode))

(server-start)

(require 'projectile)
(projectile-global-mode)

;; Disable scroll bar
(scroll-bar-mode -1)

;; Create shorter aliases
(defalias 'ack 'ack-and-a-half)
(defalias 'ack-same 'ack-and-a-half-same)
(defalias 'ack-find-file 'ack-and-a-half-find-file)
(defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)

;; colorize compilation buffer
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(setenv "PATH"
  (concat
   "/home/arjan/devel/config/bin" ":"
  (getenv "PATH"))
)

(autoload 'po-mode "po-mode"
  "Major mode for translators to edit PO files" t)
(setq auto-mode-alist (cons '("\\.po\\'\\|\\.po\\." . po-mode)
                            auto-mode-alist))
(autoload 'po-find-file-coding-system "po-compat")
(modify-coding-system-alist 'file "\\.po\\'\\|\\.po\\."
                            'po-find-file-coding-system)


(setq ido-create-new-buffer 'always)

(defun ido-ignore-non-user-except-magit (name)
  "Ignore all non-user (a.k.a. *starred*) buffers except *magit:"
  (and (string-match "^\*" name)
       (not (string-match "^\*magit:" name))))

(setq ido-ignore-buffers '("\\` " ido-ignore-non-user-except-magit))


;; remove trailing whitespace on save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(require 'string-inflection)
(global-set-key (kbd "C-c C-i") 'string-inflection-cycle)




(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize) ;; You might already have this line

(require 'editorconfig)
(editorconfig-mode 1)

(defun smart-open-line-above ()
  "Insert an empty line above the current line.
Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key [(control shift return)] 'smart-open-line-above)
(global-set-key [(control shift o)] 'smart-open-line-above)
