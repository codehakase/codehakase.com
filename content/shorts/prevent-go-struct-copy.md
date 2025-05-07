---
title: "Implementing Non-Copyable Embedded Structs"
modified: 2025-05-06
layout: shorts
tags: [go]
---

While working with embedded structs, I learned that even implicitly promoted fields can be silently copied if the parent struct is passed by value. This becomes dangerous when the embedded struct holds resources like mutexes, buffers, or channels.

To guard against this, I now utilise a `noCopy` marker in the embedded struct itself, making any value-based use of the parent type inherently unsafe and detectable with vet or the race detector.

```go
type noCopy struct{}
func (*noCopy) Lock()   {}
func (*noCopy) Unlock() {}

type Core struct {
    _     noCopy
    id string
    statuses chan string
}

type Tokenizer struct {
    Core
    vbs string
    vob map[string]int
}

func NewTokenizer(id string) *Tokenizer {
    return &Tokenizer{
        Core: Core{id: id, statuses make(chan string})},
        ...
    }
}
```

Now, if the `Tokenizer` struct is copied by value (e.g. passed to a goroutine or stored in a slice), the race detector will catch incorrect usage of the shared `statuses` channel or other internal state.

The win here is that Go's runtime and tooling will help enforce this and you don’t have to trust future readers of your code to do the right thing.
