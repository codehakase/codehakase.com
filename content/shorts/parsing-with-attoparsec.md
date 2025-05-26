---
title: "Composable Parsers with Attoparsec"
modified: 2025-05-06
layout: shorts
tags: [haskell, parsers]
description: "Using Attoparsec in Haskell to create efficient and composable parsers for structured text data."
---

I've been diving into Haskell's [attoparsec](https://hackage.haskell.org/package/attoparsec) and I'm impressed by how it simplifies building complex parsers. Here's a quick example for a DSL snippet like `"name=Some Name;age=42;"`, using `Data.Attoparsec.Text`:

```haskell
import Control.Applicative ((<*), (*>))
import Data.Attoparsec.Text
import Data.Text (Text)
import GHC.Generics (Generic)

data Person = Person { name :: Text, age  :: Int }
  deriving (Show, Eq, Generic)

personParser :: Parser Person
personParser = Person
    <$> (string "name=" *> takeTill (== ';') <* char ';')
    <*> (string "age="  *> decimal        <* char ';')
```

This parser defines a `Person` and then, using applicative style, consumes `"name="`, takes characters until a semicolon (discarding the semicolon), then consumes `"age="`, parses a decimal (discarding its trailing semicolon), and populates the `Person` fields.
