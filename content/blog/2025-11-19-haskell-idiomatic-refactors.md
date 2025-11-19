---
layout: post
title: "Idiomatic Haskell Refactors"
author: "@codehakase"
description: "A note on some interesting idiomatic Haskell patterns I've learned and enjoy using."
modified: 2025-10-19
tags: [haskell]
share: true
category: "haskell"
---

I was reviewing my notes for previous idiomatic Haskell refactoring patterns I've recorded, and I can see some entries that are interesting to share. Some were confusing at first, but looking at them from first principles, weighing the gains in terms of brevity and/or performance, they've become clearer and essential to how I write Haskell code.

Here are some of the patterns that made the biggest difference:
### Bind to Lambda Case: 
Enabled via the `LambdaCase` language extension, we can rewrite pattern matching blocks to omit identifiers that are only used in the pattern match, like in the example below where we have a `userM` variable only used in the pattern match.

```haskell
processUserRequest :: UserId -> RequestId -> RequestData -> App (Response ())
processUserRequest userId reqId requestData = do
  userM <- getUserById userId
  case userM of
    Nothing -> showNotFoundError
    Just user -> handleValidRequest user.id reqId requestData
```

We can refactor the above to:

```haskell
processUserRequest :: UserId -> RequestId -> RequestData -> App (Response ())
processUserRequest userId reqId requestData = do
  getUserById userId >>= \case
    Nothing -> showNotFoundError
    Just user -> handleValidRequest user.id reqId requestData

```
The above can still be rewritten to be more idiomatic, by utilising the `maybe` function:
```haskell
processUserRequest :: UserId -> RequestId -> RequestData -> App (Response ())
processUserRequest userId reqId requestData = do
  getUserById userId >>= maybe showNotFoundError (\user -> handleValidRequest user.id reqId requestData)
```

### Alternative + Applicative 

A majority of verbose code can be rewritten to be clearer if one has a good command of some operators from the applicative/alternative typeclass. The following are the ones I've used on multiple occasions:
- `<|>` - Alternative Choice, First success/none-empty alternative 
-  `<*` - Sequence actions, return first result
- `*>` - Sequence actions, return second result

Consider a verbose function that can be refactored using some the operators listed above:
```haskell
updateResourceFilters filters userId resourceM =
  case resourceM of
    Nothing -> filters
    Just r -> 
      case filters.category of
        Nothing -> (filters :: Resource.FilterConfig){Resource.category = Just r.category}
        Just existing -> (filters :: Resource.FilterConfig){Resource.category = Just existing}
```
Refactored to:
```haskell
updateResourceFilters filters userId resourceM =
  maybe
    filters
    ( \r -> do
        let cat = Just r.category <* guard (isNothing filters.category) <|> filters.category
         in (filters :: Resource.FilterConfig){Resource.category = cat}
    )
    resourceM
```
The refactored version is more concise, and expressive. Using `<|>` to provide a reasonable fallback and `maybe` to handle the optional value.

### Functor Composition
The `<$>`  and `<&>`  operators enable chaining transformations without nested let/do blocks or intermediate variables. Using these functions removes conditional logic boilerplate, and makes data transformations explicit and composable. The left-to-right flow with `<&>` mirrors how we think about chaining operations on data.

For example, extracting and transforming nested record fields:
```haskell
isProjectAdmin :: Session -> Bool
isProjectAdmin session =
  case session.user of
    Nothing -> False
    Just user -> user.userType >= User.UTAdmin
```

Refactored with `<&>`:
```haskell
isProjectAdmin :: Session -> Bool
isProjectAdmin session =
  maybeToMonoid (session.user <&> (.userType)) >= User.UTAdmin
```

Or transforming optional dates in forms:

```haskell
let dueDate = case form.dueDate of
      Nothing -> Nothing
      Just d -> Just (dayToUTC d)
```

With `<$>`:
```haskell
let dueDate = dayToUTC <$> form.dueDate
```

### traverse & forM_
When you need to iterate over a collection and perform monadic actions (like effects or computations), the idiomatic approach is using `traverse` or `forM_` instead of manual recursion or explicit loops.

Consider a scenario where you need to process multiple employees and send invitations:
```haskell
inviteEmployees :: [Employee] -> Company -> App ()
inviteEmployees employees company = do
  let go [] = pure ()
      go (e:es) = do
        sendInvite e.email company.name
        go es
  go employees
```

Rewriting the above Using `forM_`:
```haskell
inviteEmployees :: [Employee] -> Company -> App ()
inviteEmployees employees company = 
  forM_ employees \employee -> 
    sendInvite employee.email company.name
```

Or for cases where you need to collect results, use traverse:
```haskell
inviteAndLogEmployees :: [Employee] -> Company -> App [InviteResult]
inviteAndLogEmployees employees company = 
  traverse (\e -> sendInvite e.email company.name) employees
```
