;;; ivy-pass.el --- ivy interface to pass command

;; Copyright (C) 2020 Lee Jia Hong

;; Author   : Lee Jia Hong <jiahong@zacque.tk>
;; Maintainer: Lee Jia Hong
;; URL: https://github.com/JiaHong-Lee/ivy-pass
;; Created  : 10th April 2020
;; Version  : 0.0.1
;; Keywords : ivy pass
;; Package-Requires: ((ivy "") (password-store ""))

;; This file is NOT part of GNU Emacs.

;; This file is a free software (MIT License).

;;; Commentary:
;; Ivy interface to pass command.

;;; Code:

(require 'ivy)
(require 'password-store)

(defun ivy-pass--copy-or-create (entry)
  "Copy password if the entry exists. Otherwise, create a new entry."
  (if (member entry (password-store-list))
      (password-store-copy entry)
    (message "%s not found. Creating new entry." entry)
    (ivy-pass--create-new entry)))

(defun ivy-pass--create-new (entry)
  (let* ((password (read-passwd "Password: " t))
         (command (format "echo %s | %s insert -m -f %s"
                          (shell-quote-argument password)
                          password-store-executable
                          (shell-quote-argument entry)))
         (ret (process-file-shell-command command)))
    (if (zerop ret)
        (progn
          (message "Successfully inserted entry for %s" entry)
          (ivy-pass--open-entry-file entry))
      (message "Cannot insert entry for %s" entry))
    nil))

(defun ivy-pass--copy-field (entry)
  (let ((field (password-store-read-field entry)))
    (password-store-copy-field entry field)))

(defun ivy-pass--rename (entry)
  (let ((new-name (read-string "Rename entry to: " entry)))
    (password-store-rename entry new-name)))

(defun ivy-pass--delete (entry)
  (when (yes-or-no-p (format "Do you really want to remove the entry %s? " entry))
    (password-store-remove entry)))

(defun ivy-pass--open-entry-file (entry)
  (password-store--run-edit entry))

;;;###autoload
(defun ivy-pass ()
  "Using ivy-completion to filter and select a password entry to
1. copy password to the kill ring
2. copy field to the kill ring
3. rename the entry
4. delete the entry
5. open the entry file. User can enter an unmatched input to create a new password entry."
  (interactive)
  (ivy-read "Password-store entry: "
            (password-store-list)
            :action '(1
                      ("o" ivy-pass--open-entry-file "open entry file")
                      ("c" ivy-pass--copy-or-create "copy password")
                      ("f" ivy-pass--copy-field "copy field")
                      ("r" ivy-pass--rename "rename entry")
                      ("d" ivy-pass--delete "delete entry"))))

(provide 'ivy-pass)

;;; ivy-pass.el ends here
