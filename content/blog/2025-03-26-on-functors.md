---
layout: post
title: "Functors: Identity, Composition, and fmap"
author: "@codehakase"
description: "An introduction to Functors in Haskell, exploring how fmap allows function application within wrapped contexts like Maybe and lists."
modified: 2025-03-26
tags: [haskell]
share: true
category: haskell
---

In writing software, we often encounter scenarios where a value resides within a context, a container of sorts. Standard function application, so straightforward with simple values, presents a challenge in these situations. Consider the `Maybe` data type in Haskell, which encapsulates the possibility of a value's absence. Applying functions to values wrapped in `Maybe` requires a different approach, as direct function application results in a type error.

For example, applying the function `(+4)` to the integer `2` is trivial:

```haskell
ghci> (+4) 2
6
```

However, attempting to apply the same function directly to a `Maybe` wrapped value results in a type error:

```haskell
ghci> x = Just 2
ghci> (+4) x

<interactive>:25:1: error: [GHC-39999]
    • No instance for ‘Num (Maybe Integer)’ arising from a use of ‘it’
    • In the first argument of ‘print’, namely ‘it’
      In a stmt of an interactive GHCi command: print it
```

This is where [fmap](https://hackage.haskell.org/package/base-4.21.0.0/docs/Data-Functor.html) comes in. `fmap` provides a way to apply a function to a value within a wrapped context. In the case of `Maybe`, `fmap` allows us to apply `(+4)` to the integer inside a `Just` context:

```haskell
ghci> fmap (+4) (Just 2)
Just 6
```

This leads us to the concept of Functors. The `Functor` typeclass[^1] in Haskell represents any type that can be mapped over. Lists, for example, are instances of the `Functor` typeclass. The definition of the `Functor` typeclass is as follows:

```haskell
class Functor f where
    fmap :: (a -> b) -> f a -> f b
```

This typeclass defines only one function, `fmap`. This polymorphic function, works for any type constructor `f` that is an instance of the `Functor` typeclass. It takes :
1. A function of type `a -> b`, which transforms a value of type `a` into a value of type `b`.
2. A value of type `f a`, which represents a value of type `a` within a functorial context `f`. It then returns a value of type `f b`, which is a value of type `b` within the same functorial context `f`. Essentially, `fmap` applies the function to the value(s) inside the functorial context.

As demonstrated earlier, we can use `fmap (+4) (Just 2)` because `Maybe` is a functor. `fmap` applies the function to the values inside the `Maybe` context. The `Maybe` type itself is defined as:

```haskell
data Maybe a = Nothing | Just a

instance Functor Maybe where
    fmap f (Just x) = Just (f x)
    fmap f Nothing = Nothing
```

This implementation reveals that if we have a value of `Nothing`, `fmap` will return `Nothing`. If we have a value wrapped in `Just`, `fmap` applies the function to the contents of the `Just` context.

In languages like Go, which lacks an explicit `Maybe` type, we often use error handling or other mechanisms to achieve similar results.

For instance, consider this Go code:

```go
metadata, err := user.GetMetadata()
if err != nil {
    return err
}

if metadata == nil {
    return nil
}
return metadata.ProjectedValue
```

The Haskell equivalent:

```haskell
getProjectedValue <$> (User.getMetadata "uuid")
```

Here, `<$>` is the infix version of `fmap`. If `User.getMetadata` returns `Just Metadata`, we can extract the projected value from it. If it returns `Nothing`, we'll return `Nothing`.

## Functor Laws

For a type to be considered a proper Functor, it must adhere to certain laws:

### Identity Law

*Applying `fmap id` should not change the functor's value.*

This law ensures that Functors don't introduce any unexpected changes or side effects when traversing their structure with a function that shouldn't modify anything.

As we can see from the `Maybe` implementation of `fmap`, this law holds.

```haskell
instance Functor Maybe where
    fmap f (Just x) = Just (f x)
    fmap f Nothing = Nothing
```

**Application of the identity law**:

**Maybe:**

```haskell
ghci> fmap id (Just "change")
Just "change"

ghci> id (Just "change")
Just "change"

ghci> fmap id Nothing
Nothing

ghci> id Nothing
Nothing
```

**List:**
```haskell
ghci> fmap id [1, 2, 3, 4]
[1, 2, 3, 4]

ghci> id [1, 2, 3, 4]
[1, 2, 3, 4]
```

**IO:**
```haskell
ghci> fmap id (return "test")
"test"
ghci> id (return "test")
"test"
```

Even in the `IO` Functor, `fmap id` leaves the action unchanged.

### Composition Law

*Applying `fmap` to a composed function should be the same as applying `fmap` separately in sequence.*

This ensures that Functors behave consistently when dealing with function composition. This is crucial for maintaining predictability and allowing for easier reasoning about code that uses Functors.

```haskell
fmap (f . g) == fmap f . fmap g
```

**Application of the composition law**:

**Maybe:**
```haskell
ghci> let f = (*3)
ghci> let g = (+5)
ghci> let c = f . g

ghci> fmap c (Just 10)
Just 45

ghci> fmap f (fmap g (Just 10))
Just 45
```

**List:**
```haskell
ghci> let f = (*3)
ghci> let g = (+5)
ghci> let c = f . g

ghci> fmap c [1, 2, 3]
[18,21,24]

ghci> fmap f (fmap g [1, 2, 3])
[18,21,24]
```


## Conclusion

Functors in Haskell provide a powerful abstraction for applying functions to values wrapped in a context, such as `Maybe`, lists, or `IO`. By following the **identity** and **composition laws**, they ensure predictable behavior and maintain structure while enabling clean, concise, and expressive code. By leveraging `fmap`, we can seamlessly work with values inside different contexts, making functional programming more flexible and easier to reason about. 

[^1]: A **typeclass** in Haskell defines a shared interface for different types, enabling polymorphism through type-specific implementations

