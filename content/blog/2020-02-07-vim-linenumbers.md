---
layout: post
title: 'Line Numbers In Vim'
author: '@codehakase'
hakase:
  featureimage:
    url: 'https://res.cloudinary.com/hakase-labs/image/upload/v1581043107/hybrid_numbers_tfx83y.gif'
description: 'Vim’s absolute, relative and hybrid line numbers'
modified: 2020-02-07
tags: [workflow, vim, development]
share: true
comments: true
category: [workflow, vim, development]
---

Vim doesn't show line numbers by default, they can be turned on in your vim configuration. Vim has an absolute, relative and hybrid line numbering mode.
![](https://res.cloudinary.com/hakase-labs/image/upload/v1581043109/bare_setup_mzb8rd.gif)

## Absolute Line Numbers

Addding the `number` option to your vim config, Vim sets up absolute line numbers to show the line number for each line in the current buffer.
![](https://res.cloudinary.com/hakase-labs/image/upload/v1581043108/absolute_numbers_q1z6ku.gif)

```vim
" set absolute numbers
set number " or
set nu
```

## Relative Line Numbers

With the `relativenumber` option, each line in your file is numbered relative to the cursor’s current position.
![](https://res.cloudinary.com/hakase-labs/image/upload/v1581043108/relative_numbers_prnvbk.gif)

```vim
" set relative numbers
set relativenumber " or
set rnu

" turn relative numbers off
:set norelativenumber
:set nornu
```

## Hybrid Line Numbers

Setting `number` and `relativenumber` at the same time produces activates the hybrid line number mode. All lines will show their relative number, except for current line, which will show its absolute line number.
![](https://res.cloudinary.com/hakase-labs/image/upload/v1581043107/hybrid_numbers_tfx83y.gif)

```vim
" turn hybrid numbers on
set relativenumber
set number " or
set rnu
set nu
" toggle hybrid line numbers
:set number! relativenumber!
:set nu! rnu!
```

That's it. That's the post. Got any questions, corrections? Leave a comment below!
