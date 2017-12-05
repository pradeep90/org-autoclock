;;; -*- lexical-binding: t; -*-
;;; org-autoclock.el -- Automatically clock in for certain files.

(require 'org)

(defvar org-autoclock-logfile "~/.org-autoclock-log.org"
  "Log file where the session durations are stored.")

(defvar org-autoclock-timer-delay 5
  "Delay in seconds before timer automatically clocks in or out.")

(defvar org-autoclock-timer nil "Timer for `org-autoclock`.")

(defun org-autoclock (&optional arg)
  "Automatically clock in and out in Org when editing certain files.
The clock used will be the last one in Org.
If none exists, signal the user."
  (interactive "P")
  (cond ((org-autoclock-doing-taskp)
	 (when (equal (org-clock-in-last) "No last clock")
	   (user-error "Please clock in to an Org task before using org-autoclock.")))
	(t (org-clock-out nil t))))

(defun org-autoclock-doing-taskp (&optional arg)
  "Return true if we are doing the specified task. (For now, C code.)"
  (interactive "P")
  (and (buffer-file-name) (string-match-p "\\.[cSh]$" (buffer-file-name))))

(defun org-autoclock-start (&optional arg)
  "Start automatically clocking into a desired task."
  (interactive "P")
  (with-current-buffer (find-file-noselect org-autoclock-logfile)
    (goto-char (point-max))
    (insert "\n* XINU task")
    (org-clock-in)
    (org-clock-out)
    (save-buffer))
  (setq org-autoclock-timer (run-with-timer 1 org-autoclock-timer-delay 'org-autoclock)))

(defun org-autoclock-stop (&optional arg)
  "Cancel automatic clocking. Clock out of any running clock."
  (interactive "P")
  (cancel-timer org-autoclock-timer)
  (org-clock-out nil t))

(ert-deftest org-autoclock--no-running-clock ()
  (with-temp-buffer
    (org-clock-out nil t)
    ;; Should not fail when there's no running clock.
    (should (or (org-autoclock) t))))

(provide 'org-autoclock)
