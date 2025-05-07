---
title: "GADTs for Type-Level Domain Logic"
modified: 2025-05-07
layout: shorts
tags: [haskell]
---

I've been leveraging Generalized Algebraic Data Types (GADTs) in Haskell and found them exceptionally powerful for encoding domain-specific rules and state transitions directly into the type system. This is particularly useful for defining operations that are based on explicitly tagged types or state, and behave differently.

Consider a scenario with distinct processing steps, each associated with specific data:

```haskell
{-# LANGUAGE GADTs #-}

module StepProcessor where

data AuthData = AuthData 
    { userId :: String
    , token :: String 
    } 
    deriving (Show)

data ReviewData = ReviewData 
    { documentId :: Int
    , comments :: String
    }
    deriving (Show)

data Step a where
  AuthStep   :: AuthData   -> Step AuthData
  ReviewStep :: ReviewData -> Step ReviewData

validateAuth :: AuthData -> IO ()
validateAuth ad = putStrLn $ "Validating auth for user: " ++ userId ad

runReview :: ReviewData -> IO ()
runReview rd = putStrLn $ "Running review for doc: " ++ show (documentId rd) ++ " with comments: " ++ comments rd

processStep :: Step a -> IO ()
processStep (AuthStep   payload) = validateAuth payload
processStep (ReviewStep payload) = runReview    payload

-- Example Usage:
-- let authAction = AuthStep (AuthData "user123" "secret_token")
-- let reviewAction = ReviewStep (ReviewData 456 "Looks good!")
--
-- processStep authAction 
-- processStep reviewAction
--
-- The following would be a compile-time error:
-- processStep (AuthStep (ReviewData 789 "Wrong data!")) -- Type mismatch!
```
