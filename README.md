---
title: org-autoclock
date: 2017-11-28
label: autoclock
---

# org-autoclock

Automatically clock in to Org mode when you work on a project.

Currently, this clocks in when you work on C files and clocks out when you work on anything else.

# Installation

Put `org-autoclock.el` somewhere in your load-path and add this to your `.emacs`:

```elisp
(require 'org-autoclock)
```

# Start automatic clocking

	M-x org-autoclock-start

This will clock into and out of your current Org task (which is by default a task created in `~/.org-autoclock-log.org`).

You can clock in to any other task and `org-autoclock` will work for that instead.

# Stop automatic clocking

	M-x org-autoclock-stop
