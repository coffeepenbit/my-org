;;; test-my-org.el --- tests for my-org.el

;; Copyright (C) 2021  kga

;; Author: kga(require 'ert) <kga@Thinkpad-OpenSUSE>
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(require 'ert)
(require 'my-ert)
(require 'org)

(ert-delete-all-tests)

(my-ert-reload-feature 'my-org)

;;;; my-org-agenda--swap-deadline-and-schedule
;; (ert-deftest test-my-org-agenda--swap-deadline-and-schedule nil
;;   ;; Schedule to deadline
;;   (should (equal "* TODO foo
;; DEADLINE: <2021-03-05 Fri>"
;;                  (my-ert-org-buffer
;;                   "* TODO foo
;; SCHEDULED: <2021-03-05 Fri>"
;;                   (lambda nil
;;                     (my-org-swap-deadline-and-schedule 'from-schedule)
;;                     (buffer-string)))))
;;   ;; Deadline to schedule
;;   (should (equal "* TODO foo
;; SCHEDULED: <2021-03-05 Fri>"
;;                  (my-ert-org-buffer
;;                   "* TODO foo
;; DEADLINE: <2021-03-05 Fri>"
;;                   (lambda nil
;;                     (my-org-swap-deadline-and-schedule 'from-deadline)
;;                     (buffer-string)))))
;;   )


;; (ert-deftest test-my-org-schedule-to-deadline nil
;;   ;; Schedule to deadline
;;   (let ((function-under-test (lambda nil
;;                                (my-org-schedule-to-deadline)
;;                                (buffer-string))))
;;     (should (equal "* TODO foo
;; DEADLINE: <2021-03-05 Fri>"
;;                    (my-ert-org-buffer
;;                     "* TODO foo
;; SCHEDULED: <2021-03-05 Fri>"
;;                     function-under-test)))
;;     ;; Already has deadline)
;;     (should (equal "* TODO foo
;; DEADLINE: <2021-03-05 Fri> SCHEDULED: <2021-03-05 Fri>"
;;                    (my-ert-org-buffer
;;                     "* TODO foo
;; DEADLINE: <2021-03-05 Fri> SCHEDULED: <2021-03-05 Fri>"
;;                     function-under-test)))
;;     ;; No schedule
;;     (should (equal "* TODO foo
;; DEADLINE: <2021-03-05 Fri>"
;;                    (my-ert-org-buffer
;;                     "* TODO foo
;; DEADLINE: <2021-03-05 Fri>"
;;                     function-under-test)))
;;     ))



;; (ert-deftest test-my-org-deadline-to-schedule nil
;;   ;; Deadline to schedule
;;   (let ((function-under-test (lambda nil
;;                                (my-org-deadline-to-schedule)
;;                                (buffer-string))))
;;     (should (equal "* TODO foo
;; SCHEDULED: <2021-03-05 Fri>"
;;                    (my-ert-org-buffer
;;                     "* TODO foo
;; DEADLINE: <2021-03-05 Fri>"
;;                     function-under-test)))
;;     ;; Already has schedule
;;     (should (equal "* TODO foo
;; DEADLINE: <2021-03-05 Fri> SCHEDULED: <2021-03-05 Fri>"
;;                    (my-ert-org-buffer
;;                     "* TODO foo
;; DEADLINE: <2021-03-05 Fri> SCHEDULED: <2021-03-05 Fri>"
;;                     function-under-test)))
;;     ;; No deadline
;;     (should (equal "* TODO foo
;; SCHEDULE: <2021-03-05 Fri>"
;;                    (my-ert-org-buffer
;;                     "* TODO foo
;; SCHEDULE: <2021-03-05 Fri>"
;;                     function-under-test)))
;;     ))

;;;


;;;; my-org-get-blank-lines-surrounding-entry
(ert-deftest test-my-org-get-blank-lines-surrounding-entry/empty nil
  :tags '(my-org-get-blank-lines-surrounding-entry)
  (should (equal '(nil nil) (my-ert-org-buffer
                             ""
                             'my-org-get-blank-lines-surrounding-entry))))


(ert-deftest test-my-org-get-blank-lines-surrounding-entry/headline-first-line nil
  :tags '(my-org-get-blank-lines-surrounding-entry)
  (should (equal '(0 0) (my-ert-org-buffer
                         "* first headline"
                         'my-org-get-blank-lines-surrounding-entry))))


(ert-deftest test-my-org-get-blank-lines-surrounding-entry/headline-second-line nil
  :tags '(my-org-get-blank-lines-surrounding-entry)
  (should (equal '(0 1) (my-ert-org-buffer
                         "* first headline
"
                         (lambda nil
                           (my-org-get-blank-lines-surrounding-entry))))))


(ert-deftest test-my-org-get-blank-lines-surrounding-entry/headline-third-line nil
  :tags '(my-org-get-blank-lines-surrounding-entry)
  (should (equal '(0 2) (my-ert-org-buffer
                         "* first headline

"
                         (lambda nil
                           (forward-line 3)
                           (my-org-get-blank-lines-surrounding-entry))))))


(ert-deftest test-my-org-get-blank-lines-surrounding-entry/two-headlines-no-blank nil
  :tags '(my-org-get-blank-lines-surrounding-entry)
  (should (equal '(0 0) (my-ert-org-buffer
                         "

* first headline
* headline two"
                         (lambda nil
                           (forward-line 3)
                           (my-org-get-blank-lines-surrounding-entry))))))


(ert-deftest test-my-org-get-blank-lines-surrounding-entry/two-headlines-blanks nil
  :tags '(my-org-get-blank-lines-surrounding-entry)
  (should (equal '(2 3) (my-ert-org-buffer
                         "

* first headline ; Point here



* headline two"
                         (lambda nil
                           (forward-line 2)
                           (my-org-get-blank-lines-surrounding-entry))))))


(ert-deftest test-my-org-get-blank-lines-surrounding-entry/first-headline nil
  :tags '(my-org-get-blank-lines-surrounding-entry)
  (should (equal '(3 2) (my-ert-org-buffer
                         "

* first headline



* headline two ; Point here

"
                         (lambda nil
                           (forward-line 6)
                           (my-org-get-blank-lines-surrounding-entry))))))


;;;; my-org-get-blank-lines-above-entry
(ert-deftest test-my-org-get-blank-lines-above-entry/empty nil
  :tags '(my-org-get-blank-lines-above-entry)
  (should (equal nil (my-ert-org-buffer
                      ""
                      'my-org-get-blank-lines-above-entry))))


(ert-deftest test-my-org-get-blank-lines-above-entry/headline-first-line nil
  :tags '(my-org-get-blank-lines-above-entry)
  (should (equal 0 (my-ert-org-buffer
                    "* first headline"
                    'my-org-get-blank-lines-above-entry))))


(ert-deftest test-my-org-get-blank-lines-above-entry/headline-second-line nil
  :tags '(my-org-get-blank-lines-above-entry)
  (should (equal 1 (my-ert-org-buffer
                    "
* first headline"
                    (lambda nil
                      (forward-line)
                      (my-org-get-blank-lines-above-entry))))))


(ert-deftest test-my-org-get-blank-lines-above-entry/headline-third-line nil
  :tags '(my-org-get-blank-lines-above-entry)
  (should (equal 0 (my-ert-org-buffer
                    "* first headline

"
                    (lambda nil
                      (my-org-get-blank-lines-above-entry))))))


(ert-deftest test-my-org-get-blank-lines-above-entry/two-headlines-no-blank nil
  :tags '(my-org-get-blank-lines-above-entry)
  (should (equal 0 (my-ert-org-buffer
                    "

* first headline
* headline two" ; Point at here
                    (lambda nil
                      (forward-line 4)
                      (my-org-get-blank-lines-above-entry))))))


(ert-deftest test-my-org-get-blank-lines-above-entry/two-headlines-blanks nil
  :tags '(my-org-get-blank-lines-above-entry)
  (should (equal 3 (my-ert-org-buffer
                    "

* first headline



* headline two" ; Point at here
                    (lambda nil
                      (forward-line 6)
                      (my-org-get-blank-lines-above-entry))))))


(ert-deftest test-my-org-get-blank-lines-above-entry/first-headline nil
  :tags '(my-org-get-blank-lines-above-entry)
  (should (equal 2 (my-ert-org-buffer
                    "

* first headline ; Point here



* headline two"
                    (lambda nil
                      (forward-line 2)
                      (my-org-get-blank-lines-above-entry))))))


;;;; my-org-get-blank-lines-below-entry
(ert-deftest test-my-org-get-blank-lines-below-entry/empty nil
  :tags '(my-org-get-blank-lines-below-entry)
  (should (equal nil (my-ert-org-buffer
                      ""
                      'my-org-get-blank-lines-below-entry))))


(ert-deftest test-my-org-get-blank-lines-below-entry/headline-first-line nil
  :tags '(my-org-get-blank-lines-below-entry)
  (should (equal 0 (my-ert-org-buffer
                    "* first headline"
                    'my-org-get-blank-lines-below-entry))))


(ert-deftest test-my-org-get-blank-lines-below-entry/headline-second-line nil
  :tags '(my-org-get-blank-lines-below-entry)
  (should (equal 1 (my-ert-org-buffer
                    "* first headline
"
                    (lambda nil
                      (my-org-get-blank-lines-below-entry))))))


(ert-deftest test-my-org-get-blank-lines-below-entry/headline-third-line nil
  :tags '(my-org-get-blank-lines-below-entry)
  (should (equal 2 (my-ert-org-buffer
                    "* first headline

"
                    (lambda nil
                      (my-org-get-blank-lines-below-entry))))))


(ert-deftest test-my-org-get-blank-lines-below-entry/two-headlines-no-blank nil
  :tags '(my-org-get-blank-lines-below-entry)
  (should (equal 0 (my-ert-org-buffer
                    "

* first headline
* headline two" ; Point at here
                    (lambda nil
                      (forward-line 2)
                      (my-org-get-blank-lines-below-entry))))))


(ert-deftest test-my-org-get-blank-lines-below-entry/two-headlines-blanks nil
  :tags '(my-org-get-blank-lines-below-entry)
  (should (equal 3 (my-ert-org-buffer
                    "

* first headline ; Point here



* headline two"
                    (lambda nil
                      (forward-line 2)
                      (my-org-get-blank-lines-below-entry))))))


(ert-deftest test-my-org-get-blank-lines-below-entry/two-headline-blanks-second nil
  :tags '(my-org-get-blank-lines-below-entry)
  (should (equal 2 (my-ert-org-buffer
                    "

* first headline



* headline two ; Point here

"
                    (lambda nil
                      (forward-line 6)
                      (my-org-get-blank-lines-below-entry))))))


(ert-deftest test-my-org-get-blank-lines-below-entry/properties-drawer nil
  :tags '(my-org-get-blank-lines-below-entry)
  (should (equal 3 (my-ert-org-buffer
                    "* first headline
:PROPERTIES:
:SOMETHING: nil
:END:


"
                    (lambda nil
                      (my-org-get-blank-lines-below-entry))))))


;;;; my-org-remove-tags-on-done
(defmacro my-org-remove-tags-on-done-fixture (&rest body)
  `(cl-letf (((symbol-function 'org-add-log-setup) #'my-ert-nil-func)
             ((symbol-function 'org-align-tags) #'my-ert-nil-func))
     (let ((org-inhibit-logging t)
           (org-log-done nil)
		   (org-log-repeat nil)
		   (org-todo-log-states nil)
           (function-to-test (lambda nil
                               (make-local-variable 'org-after-todo-state-change-hook)
                               (add-hook 'org-after-todo-state-change-hook
                                         (lambda nil
                                           (my-org-remove-tags '("foo"))))
                               (goto-char (point-max))
                               (org-todo 'done)
                               (buffer-string))))
       (progn ,@body))))


(ert-deftest test-my-org-remove-tags-on-done/no-tags nil
  :tags '(my-org-remove-tags-on-done)
  (should (equal "* DONE headline"
                 (my-org-remove-tags-on-done-fixture
                  (my-ert-org-buffer
                   "* TODO headline"
                   (lambda nil
                     (make-local-variable 'org-after-todo-state-change-hook)
                     (add-hook 'org-after-todo-state-change-hook
                               (lambda nil
                                 (my-org-remove-tags '("foo"))))
                     (goto-char (point-max))
                     (org-todo 'done)
                     (buffer-string)))))))


(ert-deftest test-my-org-remove-tags-on-done/remove-none-of-one-tags nil
  :tags '(my-org-remove-tags-on-done)
  (should (equal "* DONE headline :bar:"
                 (my-org-remove-tags-on-done-fixture
                  (my-ert-org-buffer
                   "* TODO headline :bar:"
                   function-to-test)))))


(ert-deftest test-my-org-remove-tags-on-done/remove-one-of-one-tags nil
  :tags '(my-org-remove-tags-on-done)
  (should (equal "* DONE headline"
                 (my-org-remove-tags-on-done-fixture
                  (my-ert-org-buffer
                   "* TODO headline :foo:"
                   function-to-test)))))


(ert-deftest test-my-org-remove-tags-on-done/remove-one-of-two-tags nil
  :tags '(my-org-remove-tags-on-done)
  (should (equal "* DONE headline :bar:"
                 (my-org-remove-tags-on-done-fixture
                  (my-ert-org-buffer
                   "* TODO headline :foo:bar:"
                   function-to-test)))))


;;;; my-org-remove-tags
(ert-deftest test-my-org-remove-tags/empty nil
  :tags '(org-remove-tags)
  (should (equal ""
                 (my-ert-org-buffer
                  ""
                  (lambda nil
                    (my-org-remove-tags nil)
                    (buffer-string))))))


(ert-deftest test-my-org-remove-tags/headline-no-tag nil
  :tags '(org-remove-tags)
  (should (equal "* headline"
                 (my-ert-org-buffer
                  "* headline"
                  (lambda nil
                    (my-org-remove-tags nil)
                    (buffer-string))))))


(ert-deftest test-my-org-remove-tags/remove-one-of-one-tags nil
  :tags '(org-remove-tags)
  (should (equal nil
                 (my-ert-org-buffer
                  "* headline :foo:"
                  (lambda nil
                    (my-org-remove-tags '("foo"))
                    (org-get-tags))))))


(ert-deftest test-my-org-remove-tags/remove-one-of-two-tags nil
  :tags '(org-remove-tags)
  (should (equal '("bar")
                 (my-ert-org-buffer
                  "* headline :foo:bar:"
                  (lambda nil
                    (my-org-remove-tags '("foo"))
                    (org-get-tags))))))
;;;; End of tests
(ert t)

(provide 'test-my-org)
;;; test-my-org.el ends here
;; Local Variables:
;; flycheck-disabled-checkers: 'emacs-lisp-checkdoc
;; End:
