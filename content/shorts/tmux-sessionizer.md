---
title: "Tmux sessionizer"
modified: 2025-05-05
layout: shorts
tags: [tmux, productivity]
description: "Using tmux-sessionizer to manage tmux sessions efficiently, with custom modifications for a streamlined development workflow."
---


I came across [tmux-sessionizer](https://github.com/ThePrimeagen/tmux-sessionizer) today, and this has become handy in how I'm managing tmux sesisons. 

For my workflow, I added an alias that'll launch `tmux-sessionizer`. 
![tmux-sessionizer](https://blob.codehakase.com/static/images/shorts/tmux-sessionizer/tmux-sessionizer.png)

I've made some slight modifications to fit my dev setup. 

```bash
#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(find ~/Dev ~/Dev/personal ~/Dev/work ~/Dev/personal/projects ~/Dev/personal/opensource ~/Dev/personal/learning -mindepth 1 -maxdepth 1 -type d | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s $selected_name -c $selected
    exit 0
fi

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected
fi

if [[ -n $TMUX ]]; then
  tmux switch-client -t $selected_name
else 
  tmux attach-session -t $selected_name
fi
```

