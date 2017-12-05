;;; -*- lexical-binding: t; -*-
;;; org-autoclock.el -- Automatically clock in for certain files.

(require 'org)

(defvar org-autoclock-logfile "~/.org-autoclock-log.org"
  "Log file where the session durations are stored.")

(defvar org-autoclock-default-task-name "XINU"
  "Default name for the clocked task.")

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
    (insert (format "\n* %s" org-autoclock-default-task-name))
    (org-clock-in)
    (org-clock-out)
    (save-buffer))
  (setq org-autoclock-timer (run-with-timer 1 org-autoclock-timer-delay 'org-autoclock)))

(defun org-autoclock-stop (&optional arg)
  "Cancel automatic clocking. Clock out of any running clock."
  (interactive "P")
  (when org-autoclock-timer
    (cancel-timer org-autoclock-timer))
  (org-clock-out nil t)
  (with-current-buffer (find-file-noselect org-autoclock-logfile t)
    (save-buffer)))

;;; HACK: Have to use this giant workaround because Emacs 24 doesn't have
;;; inhibit-message.
(defadvice message (around suppress-messages)
  "Make `message' a no-op."
  (ignore))

(defadvice org-clock-in-last (around org-clock-in-last-suppress-messages)
  "Suppress messages within this function.
Adapted from https://superuser.com/questions/669701/emacs-disable-some-minibuffer-messages."
  (ad-enable-advice 'message 'around 'suppress-messages)
  (ad-activate 'message)
  (unwind-protect
      ad-do-it
    (ad-disable-advice 'message 'around 'suppress-messages)
    (ad-activate 'message)))

(defadvice org-clock-out (around org-clock-out-suppress-messages)
  "Suppress messages within this function.
Adapted from https://superuser.com/questions/669701/emacs-disable-some-minibuffer-messages."
  (ad-enable-advice 'message 'around 'suppress-messages)
  (ad-activate 'message)
  (unwind-protect
      ad-do-it
    (ad-disable-advice 'message 'around 'suppress-messages)
    (ad-activate 'message)))

(ad-activate 'org-clock-in-last)
(ad-activate 'org-clock-out)

(ert-deftest org-autoclock--no-running-clock ()
  (with-temp-buffer
    (org-clock-out nil t)
    ;; Should not fail when there's no running clock.
    (should (or (org-autoclock) t))))

;; Manual test:
 ;; Kill Emacs without clocking out -> org-autoclock should automatically clock
;; out and *save* the log file. No dangling clocks.

(add-hook 'kill-emacs-hook (lambda () (org-autoclock-stop)))

(provide 'org-autoclock)
