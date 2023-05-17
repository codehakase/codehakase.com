---
layout: post
title: "Enum Stringer Interface optimisation in Go"
author: "@codehakase"
description: "A tip on how to optimise enum stringer interface"
modified: 2021-04-08
tags: [golang, go]
share: true
category: [golang]
---
The most idiomatic way of describing an enum type in Go is to use constants, often in conjunction with [iota](https://golang.org/ref/spec#Iota).

A pattern I've used to implement the `Stringer` interface for an enum type is to
lookup the string representation in a slice. Consider this snippet from a
project I'm working on:
```go
// Status ...
type Status uint32

// List of possible status values
const (
  // The operation is known, but hasn't been decided yet
	Processing Status = iota
  // The operation will never be accepted
	Rejected
  // The operation was accepted
	Accepted
  ...
)

func (s Status) String() string {
  return []string{"processing", "rejected", "accepted"}[s]
}
```

The snippet above works correct but has a few glitches -- passing
`Status(-2)` or `Status(300)`  will cause the `String()` method to panic, and
when appending to the slice, the order of the enum constants has to be taken
into consideration.

A way to optimise this is to use a map which provides `O(1)` access time rather
than the linear `O(n)` time in the string slice version.

```go
...
// Map of Status values back to their constant names for pretty printing.
var txStatuses = map[Status]string{
	Processing: "processing",
	Rejected:   "rejected",
	Accepted:   "accepted",
}

// String returns the ErrorCode as a human-readable name.
func (s Status) String() string {
	if s := txStatuses[s]; s != "" {
		return s
	}
	return fmt.Sprintf("Unknown Status (%d)", uint32(s))
}
```
