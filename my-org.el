;;; my-org.el --- my org                    -*- lexical-binding: t; -*-
;; Copyright (C) 2020  coffeepenbit

;; Author: coffeepenbit <coffeepenbit@gmail.com>
;; Keywords: lisp, outlines

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/olicenses/>.

;;;; Commentary:

;; My org

;;;; Code:
(defun my-org-add-ids-to-headlines-in-buffer ()
  "Add ID property to headlines in the current buffer which do not have one."
  (interactive)
  (if (eq major-mode 'org-mode)
      (if (my-org-not-archive-p)
          (progn (message "Adding IDs to headlines in buffer")
                 (org-map-entries 'org-id-get-create))
        (message "Skipping add IDs to archive file"))
    (message "Skipping add IDs to non-org mode file")))

(defcustom my-org-auto-format-directories nil
  "Directories where auto-format should be run."
  :type 'list
  :group 'my-org)

(defun my-org-auto-format nil
  "Tidy up org file."
  (interactive)
  (if (and (eq major-mode 'org-mode)
           (member (file-name-directory (buffer-file-name))
                   (mapcar 'expand-file-name
                           my-org-auto-format-directories)))
      (if (my-org-not-archive-p)
          (progn
            (message "Formatting org file")

            ;; Realign tags
            (org-set-tags-command '(4))

            ;; Ensure at least 1 blank line before and after entries and
            ;; drawers. This last part about drawers is incredibly useful.
            (unpackaged/org-fix-blank-lines t)
            (org-unindent-buffer))
        (message "Skipping auto-format of archive file"))
    (message "Skipping auto-format of non-org mode file")))

(defun my-org-not-archive-p ()
  "Check if buffer name is an `org' archive."
  (and (not (string-match-p ".*\\.org_archive"
                            (buffer-name)))))

(defvar org-created-property-name
  "CREATED"
  "The name of the 'org-mode' property storing the creation date of entry.")

(defun my-org-set-created-property-all-entries ()
  "Apply my-org-set-create-property to all entries in buffer."
  (org-map-entries 'my-org-set-created-property nil nil))

(defun my-org-set-created-property (&optional active NAME)
  "Set a property on the entry giving the creation time.

By default the property is called CREATED.  If given the 'NAME'
argument will be used instead.  If the property already exists, it
will NOT be modified.

If ACTIVE, active timestamp format will be used."
  (interactive)
  (let* ((created (or NAME org-created-property-name))
         (fmt (if active "<%s>" "[%s]"))
         (now  (format fmt (format-time-string "%Y-%m-%d %a %H:%M"))))
    (unless (org-entry-get (point) created nil)
      (org-set-property created now))))

(defun my-org-collect-duplicate-headings ()
  "Check for duplicate org mode headlines."
  ;; Needs to be ran in eval, not interactive (i.e. M-x)."
  (let (dups
        (hls (org-element-map (org-element-parse-buffer) 'headline
               (lambda (hl)
                 (cons (org-element-property :raw-value hl)
                       (org-element-property :begin hl))))))
    (dolist (hl hls)
      (when (> (cl-count (car hl) (mapcar #'car hls)
                         :test 'equal)
               1)
	    (push hl dups)))
    (nreverse dups)))

(defun my-org-diary-last-day-of-month (date)
  "Return t if DATE is the last day of the month."
  (let* ((day (calendar-extract-day date))
         (month (calendar-extract-month date))
         (year (calendar-extract-year date))
         (last-day-of-month
          (calendar-last-day-of-month month year)))
    (= day last-day-of-month)))

(defun my-org-open-calendar ()
  "Opens cfw calendar buffer at maximum frame size."
  (interactive)
  (select-frame (make-frame))
  (sleep-for 1) ; allow frame to setup to resize calendar
  (cfw:open-calendar-buffer
   :contents-sources
   (list
    (cfw:org-create-source "Green")  ; orgmode source
    ;; (cfw:howm-create-source "Blue")  ; howm source
    ;; (cfw:cal-create-source "Orange") ; diary source
    ;; (cfw:ical-create-source "Moon" "~/moon.ics" "Gray")  ; ICS source1
    ;; (cfw:ical-create-source "gcal"
    ;;   "https://..../basic.ics" "IndianRed") ; google calendar ICS
    )))

(defun my-org-create-child-subtree (HEADLINE-NAME)
  "Create child subtree with HEADLINE-NAME, one level lower than current."
  (interactive)
  (my-org-create-subtree HEADLINE-NAME)
  (org-demote))

(defun my-org-create-subtree (HEADLINE-NAME)
  "Create subtree with HEADLINE-NAME at current level."
  (interactive)
  (end-of-line)
  (org-insert-heading)
  (org-edit-headline HEADLINE-NAME))

;; (defun my-org-get-time-stamp-string ()
;;   "Get time stamp string from `org-insert-time-stamp'."
;;   (interactive)
;;   ;; `let' is necessary to prevent two time stamps being generated.
;;   (let ((junk
;;          (org-insert-time-stamp (current-time) t)))))

(defun my-org-set-property-if-unset-all-entries (property &optional value)
  "Set PROPERTY on multiple entries.

Properties Will be set to nil if VALUE is not set."
  (org-map-entries (lambda nil
                     (my-org-set-property-if-unset property value) nil nil)))

(defun my-org-set-property-if-unset (property &optional value)
  "Set org headline PROPERTY if not yet set.

Properties Will be set to nil if VALUE is not set."
  (unless (org-entry-get nil property nil)
    (if value
        (org-entry-put nil property value)
      (org-entry-put nil property "nil"))))

;; (defun my-org-list-apply ()
;;   (interactive)
;;   (save-excursion
;;     (let* ((item-struct (org-element-property :structure
;;                                               (org-element-at-point)))
;;            (item-markers (my-org-list-get-item-markers item-struct)))
;;       (my-org-list-toggle-headings item-markers))))

;; (defun my-org-list-get-item-markers (struct &optional predicate)
;;   (let ((markers ()))
;;     (dolist (item struct)
;;       (cond ((null predicate)
;;              (push (nth 0 item) markers)))
;;       (when (string= (nth 4 item) "[ ]")
;;         (push (nth 0 item) markers)))
;;     markers))

;; (defun my-org-list-toggle-headings (item-markers)
;;   (dolist (marker item-markers)
;;     (goto-char marker)
;;     (org-toggle-heading)
;;     (org-id-get-create)
;;     (org-store-link nil nil)))

(defun my-org-headline-level-string (&optional diff)
  "Create headline stars equal to current org level.

DIFF to add or subtract from the number of stars."
  (let ((diff (or diff 0)))
    (make-string (+ (org-current-level) diff) ?*)))

(defun my-org-goto (&optional arg)
  "Use `org-goto' with specified max depth of ARG and outline interface."
  (interactive "P")
  (let ((org-goto-interface 'outline))
    (my-org-goto--function arg)))

(defun my-org-goto-outline (&optional arg)
  "Use `org-goto' with specified max depth of ARG and full-path interface."
  (interactive "P")
  (let ((org-goto-interface 'outline-path-completion))
    (my-org-goto--function arg)))

(defun my-org-goto--function (&optional arg)
  "Use `org-goto' with specified max depth of ARG."
  (if (and (not (null arg))
           (not (listp arg)))
      (let ((org-goto-max-level arg))
        (org-goto))
    (org-goto arg)))

(defun my-org-headline-exists (headline)
  "Check if HEADLINE exists in current buffer."
  (interactive)
  (cl-some 'identity
           (org-map-entries (lambda () (my-org-search-headline headline)) nil 'file)))

(defun my-org-search-headline (string)
  "Search current headline for STRING."
  (when (org-at-heading-p)
    (string= (downcase string) (downcase (org-get-heading
                                          'no-tags
                                          'no-todo
                                          'no-priority
                                          'no-comment)))))

;; (with-eval-after-load 'helm-org
(defun my-org-todo-buffer (&optional arg)
  "Create an inderect buffer showing all todo items in the current subtree.

\\[universal-argument] - select for a parent heading "
  (interactive "P")
  (save-excursion
    (let ((ind-buffer-name "org TODO buffer"))
      (when (equal arg '(4))
        (call-interactively 'helm-org-parent-headings nil (vector 4)))
      (when (get-buffer ind-buffer-name)
        (kill-buffer ind-buffer-name))
      (clone-indirect-buffer-other-window ind-buffer-name t))
    (call-interactively 'org-narrow-to-subtree)
    (org-show-todo-tree nil)))

;;;;; Tags
(defun my-org-rename-tag (old new)
  "Replace all instances of OLD tags with NEW tags in agenda files."
  (interactive "scurrent tag: \nsnew name: ")
  (org-map-entries
   (lambda () (change-tag old new))
   (format "+%s" old)
   'agenda))

(defun my-org-change-tag (old new)
  "Replace OLD tag with NEW tag for headline, if found."
  (when (member old (org-get-tags))
    (org-toggle-tag new 'on)
    (org-toggle-tag old 'off)))

(defun my-org-remove-tags (&optional tags)
  "Remove TAGS from entry.

If TAGS is nil, remove all tags."
  (dolist (tag tags)
    (when (member tag (org-get-tags))
      (org-toggle-tag tag 'off))))

;;;;; Deadlines and schedule
(defun my-org-swap-deadline-and-schedule (swap-from)
  "SWAP-FROM deadline/schedule to schedule/deadline."
  (cond ((eq swap-from 'from-deadline) (my-org-deadline-to-schedule))
        ((eq swap-from 'from-schedule) (my-org-schedule-to-deadline))))

(defun my-org-schedule-to-deadline nil
  "Convert schedule timestamp to deadline timestamp."
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (let ((schedule-time (org-get-scheduled-time (point)))
          (deadline-time (org-get-deadline-time (point))))
      (if (and schedule-time (null deadline-time))
          (progn
            (org-deadline nil (org-get-scheduled-time (point)))
            (my-org-remove-schedule))
        (progn
          (when (null schedule-time)
            (display-warning :error "Headline does not have a schedule time."))
          (when deadline-time
            (display-warning :error "Headline already has a deadline time"))
          )))))

(defun my-org-deadline-to-schedule nil
  "Convert deadline timestamp to schedule timestamp."
  (interactive)
  (save-excursion
    (org-back-to-heading)
    (let ((schedule-time (org-get-scheduled-time (point)))
          (deadline-time (org-get-deadline-time (point))))
      (when (and deadline-time (null schedule-time))
        (progn
          (org-schedule nil (org-get-deadline-time (point)))
          (my-org-remove-deadline))
        ;; (progn
        ;;   (when (null deadline-time)
        ;;     (display-warning :error "Headline does not have a deadline time."))
        ;;   (when schedule-time
        ;;     (display-warning :error "Headline already has a schedule time"))
        ;;   )
        ))))

(defun my-org-remove-deadline nil
  "Remove org entry headline."
  (org-deadline '(4)))

(defun my-org-remove-schedule nil
  "Remove org entry schedule."
  (org-schedule '(4)))

;;;;; Links
(defun my-org-open-next-link nil
  "Go to next link and open it."
  (interactive)
  (org-next-link)
  (org-open-at-point))

;;;;; Outline
;;;;;; Fold
(defun my-org-fold-to-content-level (&optional content-level)
  "Fold outline to prefix-argument CONTENT-LEVEL.

CONTENT-LEVEL nil will fold to current level."
  (interactive "P")
  (cond ((null content-level)
         ;; Fold to current level
         (org-content (org-current-level)))
        ((eq content-level 1)
         (org-global-cycle 'OVERVIEW))
        (t
         ;; Fold to content-level
         (org-content content-level))))

;;;;;; Sort
(defun my-org--sort-todo-func (&rest arg)
  "Sort todo items with non-todo items coming first."
  (when (looking-at org-complex-heading-regexp)
    (save-match-data
      (let* ((todo-keyword (save-match-data (match-string 2)))
             (title (save-match-data (match-string 4)))
             ;; Last value should not use `save-match-data'.
             ;; Because I don't know if the other part of `org-sort' is expecting a
             ;; cloberred search string.
             (tags (match-string 5)))
        (cond (todo-keyword ; nil todo-keyword means no todo keyword found
               (progn ; Sort heading with todo keyword
                 (let ((s (if (member todo-keyword org-done-keywords) '- '+)))
                   (- 99 (funcall s (length (member todo-keyword
                                                    org-todo-keywords-1)))))))
              ((and tags
                    ;; TODO: abstract :ARCHIVE: to defcustom
                    (save-match-data (string-match-p (regexp-quote ":ARCHIVE:") tags)))
               1000) ; Make ARCHIVE tag lowest priority
              (t
               1)) ; Make non-todo items highest PRIORITY
        ))))

(defun my-org-sort-entries (&rest arg)
  "Sort org entries using my own function(s)."
  (interactive)
  (org-sort-entries nil ?f 'my-org--sort-todo-func))

;;;;;; Narrow
(defun my-org-toggle-narrow-to-subtree (&optional arg)
  "Narrow to the subtree at point or widen a narrowed buffer.

With ARG \\[universal-argument] narrow to parent subtree."
  (interactive "P")
  (save-excursion
    (if (and (equal arg '(4)))
        (call-interactively 'my-org-narrow-to-parent-subtree)
      (call-interactively 'org-toggle-narrow-to-subtree))))

(defun my-org-narrow-to-parent-subtree nil
  "Narrow to parent heading."
  (interactive)
  (save-excursion
    (when (called-interactively-p 'any)
      (message "Narrowing to parent subtree"))
    ;; Widen before running otherwise highest outline will be the
    ;; narrowed buffers highest outline
    (when (buffer-narrowed-p) (widen))
    (if (>= (org-current-level) 2)
        (progn (outline-up-heading 1)
               (org-narrow-to-subtree))
      (widen))))
;;;;; Capture
(defun my-org-capture-prevent-headline-gobble ()
  "Prevent `org-capture' from gobbling next headline."
  ;; Go to end poistion - 1 as other hooks will run from this position. If its
  ;; at the end postion instead of end - 1 then it will run on the next
  ;; org-mode headline.
  (goto-char (- (point-max) 1))
  ;; Add newline if capture does not end with newline already
  (unless (looking-at "
")
    (goto-char (point-max))
    (insert "\n\n")))

;; (defun my-org-capture-at-point ()
;;   "Insert an org capture template at point."
;;   (interactive)
;;   (org-capture 0))

(defun my-org-capture-add-entry-id ()
  "This is a fix for org-roam capture."
  (unless (org-before-first-heading-p)
    (org-id-get-create)))

;; (defun my/org-capture-template-k ()
;;   (when (string= (org-capture-get :key t) "k")
;;     (message "Only run when the template with key \"k\" is selected")))

;;;;; Refile
;; See:
;; - https://emacs.stackexchange.com/questions/24976/org-mode-can-you-set-up-context-dependent-refile-targets
;; - https://emacs.stackexchange.com/a/8049/5385
;; WARNING: Not ready, don't implement yet
;; (defun my-org-refile-contexts nil)
;; (require 'dash)

;; (defvar org-refile-contexts "Contexts for `org-capture'.

;; Takes the same values as `org-capture-templates-contexts' except
;; that the first value of each entry should be a valid setting for
;; `org-refile-targets'.")

;; (defun org-refile--get-context-targets ()
;;   "Get the refile targets for the current headline.

;; Returns the first set of targets in `org-refile-contexts' that
;; the current headline satisfies, or `org-refile-targets' if there
;; are no such."
;;   (or (car (-first (lambda (x)
;;                      (org-contextualize-validate-key
;;                       (car x)
;;                       org-refile-contexts))
;;                    org-refile-contexts
;;                    ))
;;       org-refile-targets)
;;   )

;; (defun org-refile-with-context (&optional arg default-buffer rfloc msg)
;;   "Refile the headline to a location based on `org-refile-targets'.

;; Changes the set of available refile targets based on `org-refile-contexts', but is otherwise identical to `org-refile'"
;;   (interactive "P")
;;   (let ((org-refile-targets (org-refile--get-context-targets)))
;;     (org-refile arg default-buffer rfloc msg)
;;     )
;;   )

;; (defun my-org-refile-here (&optional arg &rest other-args)
;;   "Refile with context."
;;   (interactive "P")

;;   (org-refile-cache-clear)
;;   (let ((org-refile-targets '((nil :maxlevel . 9))))
;;     (org-refile arg other-args)))

;;;;;; Refile with link
(defun my-org-refile-with-link nil
  "Refile subheading and leave a link behind."
  ;; TODO make work with region
  ;;
  ;; 0. Go to entry heading
  ;; 1. Store link
  ;; 2. Refile
  ;; 3. Go back to original position
  ;; 4. Insert link at original position
  ;; 5. Ensure spaces above and below are the same as initial

  (interactive)
  (save-excursion
    (org-back-to-heading)
    ;; (beginning-of-line)
    (let ((stored-link (org-id-store-link))
          (heading (org-get-heading 'no-tags 'no-todo 'no-priority))
          ;; (start (point-marker))
          ;; TODO  maintain number of blank lines surrounding entry
          (initial-nblank-lines-above (my-org-get-blank-lines-above-entry))
          (initial-nblank-lines-below (my-org-get-blank-lines-below-entry))
          )
      (save-excursion
        (call-interactively 'org-refile)
        (open-line 1) ; This is to provent gobbling next headline
        (org-insert-link nil stored-link heading)
        ;; BUG too many blank lines above
        (save-excursion
          (let ((nblank-lines-above-diff (max 0
                                              (- initial-nblank-lines-above
                                                 (my-package-get-blank-lines-above)))))
            (when (> nblank-lines-above-diff 0)
              (my-package-insert-lines-above nblank-lines-above-diff))))
        (save-excursion
          (let ((nblank-lines-below-diff (max 0
                                              (- initial-nblank-lines-below
                                                 (my-package-get-blank-lines-below)))))
            (when (> nblank-lines-below-diff 0)
              (my-package-insert-lines-below nblank-lines-below-diff)))))
      )))

;;;;;;; Number of blank lines surrounding heading
(defun my-org-get-blank-lines-surrounding-entry nil
  "Get number of blank lines surrounding entry."
  `(,(my-org-get-blank-lines-above-entry) ,(my-org-get-blank-lines-below-entry)))

(defun my-org-get-blank-lines-above-entry nil
  "Get number of blank lines above entry."
  (unless (org-before-first-heading-p)
    (save-excursion
      (org-back-to-heading)
      (my-package-get-blank-lines-above))))

(defun my-org-get-blank-lines-below-entry nil
  "Get number of blank lines below entry."
  (unless (org-before-first-heading-p)
    (save-excursion
      (org-back-to-heading)
      ;; Counts blank lines by going end of entry and working its way up
      ;;
      ;; Places point at next heading or end of entry if it is last heading
      (goto-char (org-element-property :end (org-element-at-point)))
      ;; Moves to last line within entry if we were moved to next heading
      (when (org-at-heading-p)
        (forward-line -1))
      (if (my-package-at-blank-line-p)
          (let ((nblank-lines 1))
            (while (and (eq (forward-line -1) 0)
                        (my-package-at-blank-line-p))
              (setq nblank-lines (1+ nblank-lines)))
            nblank-lines)
        0))))

;;;;; Agenda
(defun my-org-agenda--function (func &rest args)
  "Run FUNC from within `org-agenda'.

ARGS are passed to FUNC."
  ;; See https://stackoverflow.com/questions/41263359/how-to-bulk-copy-in-org-agenda
  (interactive)
  (or (eq major-mode 'org-agenda-mode) (error "Not in org-agenda mode"))
  (let* ((headline-marker (or (org-get-at-bol 'org-marker)
		                      (org-agenda-error)))
	     (headline-buffer (marker-buffer headline-marker))
	     (headline-pos (marker-position headline-marker)))
    (with-current-buffer headline-buffer
      (widen)
      (goto-char headline-pos)
      (apply func args))))

;;;;;; 

;;;;;; Swap schedule and agenda
(defun my-org-agenda-schedule-to-deadline nil
  (interactive)
  (my-org-agenda--function 'my-org-swap-deadline-and-schedule 'from-schedule))

(defun my-org-agenda-deadline-to-schedule nil
  (interactive)
  (my-org-agenda--function 'my-org-swap-deadline-and-schedule 'from-deadline))

;;;;;; Agenda skip
;; (defun my-org-agenda-skip-entire-entry-if-done (&rest r)
;;   (let ((result (org-agenda-skip-entry-if 'todo 'done)))
;;     (if (not (null result))
;;         (org-element-property :end (org-element-at-point))
;;       nil)))


;;;;;; Agenda context
(defun my-org-agenda-contextual (files)
  "Dispatch `org-agenda' with specified FILES."
  (require 'org)
  (require 'init-org-agenda)
  (org-store-new-agenda-file-list files)
  (progn (org-store-new-agenda-file-list files)
         (call-interactively #'org-agenda)))

;;;;; Archive
(defun my-org-batch-archive nil
  "Archives multiple subtrees if they're done."
  ;; BUG should not start scope at start of file
  ;; TODO
  ;; - Add confirmation before archiving
  ;; - Select scope
  (interactive)
  (let* ((starting-level (org-current-level))
         (archive-mode-input (read-char-exclusive
                              "[s]ibling [d]efault location"))
         (archive-mode-choice (cond ((= archive-mode-input ?s)
                                     'org-archive-to-archive-sibling)
                                    ((= archive-mode-input ?d)
                                     'org-archive-subtree-default)
                                    (t (error "Unexpected user input")))))
    (org-map-entries archive-mode-choice
                     nil
                     nil
                     'archive
                     (lambda nil ; My skip function
                       (let ((skip-reason nil))
                         (cond ((not (org-entry-is-done-p))
                                (setq skip-reason "entry not marked as done"))
                               ((not (equal (org-current-level)
                                            starting-level))
                                (setq skip-reason "entry not on starting level")))
                         (when skip-reason
                           (message "skipping %s: %s" skip-reason (org-get-heading))
                           ;; Provide position for point to jump to
                           (org-element-property :end (org-element-at-point))
                           ))))))

;;;; Provide
(provide 'my-org)
;;; my-org.el ends here
