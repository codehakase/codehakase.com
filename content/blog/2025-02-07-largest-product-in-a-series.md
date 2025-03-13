---
layout: post
title: "Largest product in a series"
author: "@codehakase"
description: "A short note on my haskell solution to Project Euler's problem 8"
modified: 2025-02-07
tags: [haskell]
share: true
category: haskell
toc: true
---

## Introduction

First post on this blog after a long hiatus -- hopefully, this will stick. I was cleaning up my browser tabs, and found a Project Euler window open and decided to attempt some problems in Haskell. I've been writing Haskell for a couple of months now, and it was a great way to test myself. 
I picked one of the problems I attempted, a simple one -- [Problem 8: Largest product in a series](https://projecteuler.net/problem=8).

```text
The four adjacent digits in the 1000-digit number that have the greatest product are 9 × 9 × 8 × 9 = 5832.

73167176531330624919225119674426574742355349194934
96983520312774506326239578318016984801869478851843
...

Find the thirteen adjacent digits in the 1000-digit number that have the greatest product. What is the value of this product?
```

## Approach

Initially, I approached this with an imperative mindset -- splitting the string, iterating over possible windows, using index-based iterations, etc. However, I stuck to a functional way:

## Implementation

First, I did a little trick to retrieve just the string digits. I opened the browser terminal and ran the following:
```js 
'...'.trim().replace(/\s+/g, '')
```

Then, in Haskell, I initialised a variable to hold a list of digits:
```haskell
import Data.Char (digitToInt)
import Data.List (tails)

let digitsM = map digitToInt "7316717653133062491922511967442657474235534919493496983520312774506326239578318016984801869478851843858615607891129494954595017379583319528532088055111254069874715852386305071569329096329522744304355766896648950445244523161731856403098711121722383113622298934233803081353362766142828064444866452387493035890729629049156044077239071381051585930796086670172427121883998797908792274921901699720888093776657273330010533678812202354218097512545405947522435258490771167055601360483958644670632441572215539753697817977846174064955149290862569321978468622482839722413756570560574902614079729686524145351004748216637048440319989000889524345065854122758866688116427171479924442928230863465674813919123162824586178664583591245665294765456828489128831426076900422421902267105562632111110937054421750694165896040807198403850962455444362981230987879927244284909188845801561660979191338754992005240636899125607176060588611646710940507754100225698315520005593572972571636269561882670428252483600823257530420752963450"
-- [7,3,1,6,7,1,7,6,5,3,1,3,3,0,6,2,4,9,1,9...]
```

Next step is to compute the greatest product by generating all contiguous substrings matching the expected length (13), and tracking the maxium from all computed products.
```haskell
maximum $ map product [take 13 xs | xs <- tails digitsM, length xs >= 13]
-- => 23514624000
```

For a more idiomatic solution, we could also write it as:
```haskell
-- Define a function to solve the problem
largestProductInSeries :: Int -> String -> Int
largestProductInSeries n digits = 
    maximum $ map (product . take n) $ filter (\xs -> length xs >= n) $ tails $ map digitToInt digits

-- Then call it with our parameters
largestProductInSeries 13 "73167176531330624919225119674426574742355349194934..."
-- => 23514624000
```

## Conclusion

I plan to keep tackling more Project Euler problems and writing about Haskell and functional programming here. Let's see if I can keep up the habit—should be fun.
