---
layout: shorts
title: "TTYs"
modified: 2025-05-13
tags: [terminal, tty]
category: terminal
description: "Learn about the `tty` command, which returns the current user's terminal name."
---

Today I learned about the `tty` command. It returns the current user's terminal name.

```man
TTY(1)                      General Commands Manual                     TTY(1)

NAME
     tty – return user's terminal name

SYNOPSIS
     tty [-s]

DESCRIPTION
     The tty utility writes the name of the terminal attached to standard
     input to standard output.  The name that is written is the string
     returned by ttyname(3).  If the standard input is not a terminal, the
     message “not a tty” is written.  The options are as follows:

     -s      Do not write the terminal name; only the exit status is affected
             when this option is specified.  The -s option is deprecated in
             favor of the “test -t 0” command.

EXIT STATUS
     The tty utility exits 0 if the standard input is a terminal, 1 if the
     standard input is not a terminal, and >1 if an error occurs.
```

One cool thing I found was if you get the tty of a terminal tab, you can push text to it. For instance, running `echo "some text" > /dev/tty-{num}` will push the text `some text` to the terminal with the tty.
![TTY sample](/images/shorts/tty/tty.gif)
