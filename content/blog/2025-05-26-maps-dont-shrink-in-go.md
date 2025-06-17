---
layout: post
title: "Maps Don't Shrink in Go"
author: "@codehakase"
description: "A note on how Go maps handle memory allocation and why they don't shrink automatically."
modified: 2025-05-27
tags: [go, maps]
share: true
category: "go"
---

Maps in Go are built-in data structures that provide a way to store key-value pairs. They are similar to dictionaries or hash tables in other programming languages. Maps are unordered collections, meaning that the order of elements is not guaranteed.

```go
func main() {
    m := make(map[string]string)
    m["name"] = "Didi"
    m["city"] = "Lagos"

    fmt.Println(m) 
    // Output: map[city:Lagos name:Didi]
}
```

Go maps are designed to **grow** as the data they hold increases, but they generally **do not shrink** back down if elements are removed. When you add key-value pairs, they are stored in structures called **buckets**. If a map starts to fill up, it will eventually trigger a **growth operation**. This typically happens under one of two conditions:

1.  There are **too many overflow buckets** (an indicator that many main buckets are very full and chaining heavily).
2.  The **load factor** exceeds a predefined threshold.

### The Growth Process

When a map needs to grow, Go performs these main steps:
1.  A **new, larger array of main buckets** is allocated. This new array is often twice the size of the current one.
2.  All **existing key-value pairs are rehashed** (their positions recalculated) and copied from the old buckets to the new, larger array of buckets.
3.  The **old array of buckets is discarded** (becoming eligible for garbage collection), and the new array becomes the active one for the map.

Sometimes, multiple keys will hash to the same main bucket. Each main bucket has a fixed number of slots (e.g 8). If a main bucket fills up, Go doesn't immediately resize the entire map. Instead, it creates an **overflow bucket** and links it to that specific full main bucket. New key-value pairs that belong to this full main bucket are then stored in its overflow bucket. This allows the map to handle more entries that map to the same initial bucket without triggering an immediate, full rehash of all entries in the entire map. 


### Load Factor

Go keeps track of how full a map is using a *load factor*. This is essentially the average number of items per bucket. It can be represented as: \(\lambda = \frac{n}{m}\)

Where:
- \(n\) = number of items in the map.
- \(m\) = number of main buckets in the map.

Go's map implementation aims to keep this load factor below a certain threshold. Currently, this threshold is around **6.5** (meaning, on average, about 6.5 items per main bucket). If the load factor exceeds this value, the map will typically grow.


Consider the following example:

```go
package main

import (
	"fmt"
	"runtime"
)

func main() {
	m := make(map[int]int)

	for i := 0; i < 100_000; i++ {
		m[i] = i
	}

	fmt.Printf("Memory after insert: %d bytes\n", memStats())

	for i := 0; i < 99_900; i++ {
		delete(m, i)
	}

	runtime.GC()
	fmt.Printf("Memory after delete: %d bytes\n", memStats())
	fmt.Printf("Map length: %d\n", len(m))
}

func memStats() uint64 {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return m.Alloc
}

```

When you run this code, you will see that the memory usage remains high even after deleting nearly all elements. This is because the internal bucket structure, once allocated, is retained.

```shell
⋊> ~/D/p/codehakase.com on main ⨯ go run maps.go
Memory after insert: 7876888 bytes
Memory after delete: 5122288 bytes
Map length: 100
```

### Reclaiming Memory
We can partially reclaim memory by using pointers to the map, and GC will clean up the unused buckets. However, the internal structure of the map will remain intact.

```go

package main

import (
    "fmt"
    "runtime"
)

func main() {
    m := make(map[int]int)

    for i := 0; i < 100_000; i++ {
        m[i] = i
    }

    fmt.Printf("Memory after insert: %d bytes\n", memStats())

    for i := 0; i < 99_900; i++ {
        delete(m, i)
    }

    runtime.GC()
    fmt.Printf("Memory after delete: %d bytes\n", memStats())
    fmt.Printf("Map length: %d\n", len(m))

    // Option 1: Reclaim memory by using a pointer to the map
    m = nil
    // OR
    // Option 2: Create a new map with just the elements you need
    // newMap := make(map[int]int)
    // for k, v := range m {
    //     newMap[k] = v
    // }
    // m = newMap
    runtime.GC()
    fmt.Printf("Memory after setting map to nil: %d bytes\n", memStats())
}
```
When you run this code, you will see that the memory usage decreases significantly after allowing the garbage collector to reclaim the memory used:

```shell
⋊> ~/D/p/codehakase.com on main ⨯ go run maps.go
Memory after insert: 7851736 bytes
Memory after delete: 5117296 bytes
Map length: 100
Memory after setting map to nil: 102704 bytes
```

It's important to note and distinguish between the memory used by the map and the memory used by the internal structure of the map.
* If a map stores pointers to values, when you delete an entry, the pointer is removed from the map. If there are no other references to the value, it will be garbage collected.
* The slot in the map itself remains allocated, but marked as empty.

Go's map implementation prioritizes the performance of its core operations and anticipates that map sizes might fluctuate. The design choice to not automatically shrink maps avoids the performance penalties associated with frequent reallocations and rehashing.
