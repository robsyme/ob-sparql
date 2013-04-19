;;; ob-sparql.el --- org-babel functions for SPARQL evaluation

;; Copyright (C) Robert Syme

;; Author: Rob Syme
;; Keywords: literate programming, reproducible research, semantic web
;; Homepage: http://orgmode.org
;; Version: 0.01

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Allows the user to evalute SPARQL queries from org source blocks.

;;; Requirements:

;; - sparql-mode :: Will be available from ELPA soon, but see
;;   http://github.com/ljos/sparql-mode in the meantime.

;;; Code:
(require 'ob)
(require 'ob-ref)
(require 'ob-comint)
(require 'ob-eval)
(require 'sparql-mode)

;; Define file extension for queries
(add-to-list 'org-babel-tangle-lang-exts  '("sparql" . "sparql"))

;; Default header arguments for queries
(defvar org-babel-default-header-args:sparql '())

(defun org-babel-execute:sparql (body params)
  "Execute a SPARQL query with org-babel. This function is called
by `org-babel-execute-src-block'"
  (message "executing SPARQL query...")
  (let* ((processed-params (org-babel-process-params params))
         ;; variables assigned for use in the block
         (url (or (cdr (assoc :query-url params))
                  (sparql-get-base-url)))
         (results-format (or (cdr (assoc :results-format params))
                             (sparql-get-format)))
         (url-request-method "POST")
         (url-request-extra-headers
          `(("Content-Type" . "application/x-www-form-urlencoded")
            ("Accept" . ,results-format)))
         (url-request-data (format "query=%s" (http-url-encode body))))
    (with-current-buffer (url-retrieve-synchronously url)
      ;; Only return the body, ignore the response header
      ;; TODO Check for response code and insert something sensible if
      ;; query fails.
      (goto-char (point-min))
      (buffer-substring (+ 1 (re-search-forward "^$")) (point-max))
      )))

(provide 'ob-sparql)
