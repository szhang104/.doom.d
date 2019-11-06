;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
(let* ((time-s (decode-time (current-time)))
        (hour (nth 2 time-s))
        (minute (nth 1 time-s)))
  (if (and (< hour 18) (> hour 6))
      (load-theme 'tango t)
    (load-theme 'doom-gruvbox t)))

;; (load-theme 'doom-gruvbox t)
(load! "lisp/asciinote-mode")
(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 90))
(global-visual-line-mode 1)
(set-frame-font "Pragmata Pro Ligature-11")
(setq-default line-spacing 0.3) ; number of pixels added below each line

;; author has added auto-fill to text-mode-hook in favor of hard line breaks, but
;; I don't like it
(when (member #'auto-fill-mode text-mode-hook)
  (remove-hook 'text-mode-hook #'auto-fill-mode))



(map! :map TeX-mode-map
      (:localleader
        "b" #'TeX-command-run-all))

(defun ospl ()
  "One sentence per line"
  (interactive)
  (let ((end-of-paragraph (make-marker)))
    (save-excursion
      (forward-paragraph)
      (backward-sentence)
      (forward-sentence)
      (set-marker end-of-paragraph (point)))
    (forward-sentence)
    (save-excursion
      (beginning-of-line)
      (evil-forward-sentence-begin)
      (while (< (point) end-of-paragraph)
        (just-one-space)
        (delete-char -1)
        (newline-and-indent)
        (forward-sentence))
      (set-marker end-of-paragraph nil))))

(defun copy-abstract ()
  "Copy the contents between \begin{abstract} and \end{abstract}. Remove the line breaks and put it into the system clipboard"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((regbeg (re-search-forward "\\\\begin{abstract}"))
          (regend (re-search-forward "\\\\end{abstract}")))
      (if regbeg
          (progn
            (forward-sentence)
            (backward-sentence)
            (match-string 0))
        (message "Cannot find an abstract environment.")))))

(let ((tomatch "3710+27+88 (1)"))
  (when (string-match "\\([0-9]+\\)" tomatch)
    (string-to-number (match-string 1 tomatch))))


(defun latex-word-count ()
  (interactive)
  (let* ((this-file (buffer-file-name))
         (beg (point-min))
         (end (point-max))
         (word-count
          (with-output-to-string
            (call-process-region beg end
                                 "texcount"
                                 nil standard-output nil "-brief" "-"))))
    (when (string-match "\\([0-9]+\\)" word-count)
      (string-to-number (match-string 1 word-count)))))


(defun str50-wc ()
  "own version of word counting"
  (cond
   ((derived-mode-p 'tex-mode) (latex-word-count))
   (t (count-words (point-min) (point-max)))))

(defun start-session ()
  "start the timer and counting the words"
  (interactive)
  (setq-local str50-tic (current-time))
  (setq-local str50-tic-wc (str50-wc))
  (message "session started"))

(defun report-session ()
  (interactive)
  (setq-local words-count (- (str50-wc) str50-tic-wc))
  (setq-local time-count (float-time (time-subtract (current-time) str50-tic)))
  (message (format-message
            "%d words in %f seconds at %f WPM"
            words-count time-count (* (/ words-count time-count) 60))))

(defun end-session ()
  (interactive)
  (report-session)
  (kill-local-variable 'str50-tic)
  (kill-local-variable 'str50-tic-wc)
  (message "session ended"))

(defun start-or-report-session ()
  (interactive)
  (if (boundp 'str50-tic-wc)
      (report-session)
    (start-session)))

(map! :map global-map
      ([f8] #'start-or-report-session))
(map! :map global-map
      ([S-f8] #'end-session))

;; my own asciinote-map
(map! :map asciinote-mode-map
      (:localleader
        "v" #'an-preview-browser))
