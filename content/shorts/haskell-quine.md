---
layout: shorts
title: 'A Quine in Haskell'
author: "@codehakase"
description: "Writing a correct quine in Haskell"
modified: 2026-06-18
tags: [haskell]
share: true
category: haskell
---
A [Quine](https://wikipedia.org/wiki/Quine_(computing)) in [Haskell](https://www.haskell.org/):

```haskell
main = putStr (c ++ [toEnum 34] ++ c ++ [toEnum 34]) where c = "main = putStr (c ++ [toEnum 34] ++ c ++ [toEnum 34]) where c = "
```
