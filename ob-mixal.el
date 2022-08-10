;;; ob-mixal.el --- org-babel support for MIXAL evaluation

;; Copyright (C) 2022 Lukasz Wiechec

;; Author: Lukasz Wiechec <lukasz@wiechec.eu>
;; URL: https://github.com/lwiechec/ob-mixal
;; Keywords: lisp
;; Version: 0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Org-Babel support for evaluating MIXAL programs.

;;; Requirements:

;; mixal | https://github.com/darius/mixal

;;; Code:

(require 'ob)
(require 'ob-eval)

(defvar org-babel-default-header-args:mixal
  '((:results . "value verbatim"))
  "Default arguments for evaluatiing a mix source block.")

(defcustom ob-mixal-cli-path nil
  "Path to mixal executable."
  :group 'org-babel
  :type 'string)

(defun org-babel-execute:mixal (body params)
  (let* ((temp-file (org-babel-temp-file "mixal-"))
         (mixal (or ob-mixal-cli-path
                    (executable-find "mixal")
                    (error "`ob-mixal-cli-path' is not set and mixal is not in `exec-path'")))
         (cmd (concat (shell-quote-argument (expand-file-name mixal))
                      " " (org-babel-process-file-name temp-file))))
    (unless (file-executable-p mixal)
      (error "Cannot find or execute %s, please check `ob-mixal-cli-path'" mmdc))
    (with-temp-file temp-file (insert body))
    (message "%s" cmd)
    (org-babel-reassemble-table
     (org-babel-eval cmd "")
     (org-babel-pick-name
      (cdr (assq :colname-names params)) (cdr (assq :colnames params)))
     (org-babel-pick-name
      (cdr (assq :rowname-names params)) (cdr (assq :rownames params))))
    ))

(provide 'ob-mixal)

;;; ob-mixal.el ends here
