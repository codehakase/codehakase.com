---
layout: post
title: "Here's What's New  In Go 1.10"
author: "@codehakase"
imagefeature: "http://www.confusedcoders.com/wp-content/uploads/2016/10/golang-1.jpg"
description: "The latest Go release, v1.10 arrived six months after V1.9. This release was stated in the change-logs and the Go blog. I'm gonna share some interesting changes I've found in Go 1.10 with you."
modified: 2018-03-06
tags: [changelog, go]
share: true
comments: true
category: [go]
---
> Go 1.8 is one year old (Happy belated Birthday 🎊 🎉)
> Go 1.9 is already 6 months old!
> Go 1.10 is out ✌

The latest Go release, **v1.10** arrived six months after V1.9. This release was stated in the change-logs and the Go blog. I'm gonna share some interesting changes I've found in Go 1.10 with you.

## New Features

### The Language
Go 1.10 offers compiler tool chain and performance improvements, but no significant changes was made to the language's specification.

### Ports
In this release, there are no new supported operating systesm or processor architectures. Main focus has been on strengthening the support of existing ports, introducing  [new instructions in the assembler](https://golang.org/doc/go1.10#asm]), and improvements to the code generated by the compilers.

#### Notes On Existing Ports
Go 1.10 now requires FreeBSD 10.3 or later. Support for FreeBSD 9.3 has been removed.

Go now runs on NetBSD again, but requires NetBSD 8 (unreleased) - Only *GOARCH amd64* and *386* have been fixed, *arm* port is still broken.

Go 1.10 is the last release that will run on OpenBSD 6.0. Go 1.11 will require OpenBSD 6.2.

On 32-bit MIPS systems, the new environment variable settings `GOMIPS=hardfloat` (the default) and `GOMIPS=softfloat` select whether to use hardware instructions or software emulation for floating-point computations.

Go 1.10 is the last release that will run on OS X 10.8 Mountain Lion or OS X 10.9 Mavericks. Go 1.11 will require OS X 10.10 Yosemite or later.

Go 1.10 is the last release that will run on Windows XP or Windows Vista. Go 1.11 will require Windows 7 or later.

### Tooling

#### Default GOROOT & GOTMPDIR
In Go 1.10, if the environment variable `$GOROOT` is not set, the go tool uses the default `GOROOT` during compilation, by deducing `GOROOT` from its own executable path. This change was made, to allow binary distributions to be unpacked anywhere in the file system and then be used without setting `GOROOT` explicitly. A new variable `$GOTMPDIR` was added to control where temporary files are created.

#### Go Build & Go Install
In previous versions, running `go build `, detects changes of packages based on the time it was modified. The `go build` command now detects out-of-date packages purely based on th content of source files, specified build flags, and metadata stored in the compiled packages.

The `go build -asmflags, -gcflags, -gccgoflags,` and `ldflags` options are applied by default only to packages listed directly on the command line. For example, `go build -gcflags=-m mypackage` passes the compiler the `-m` flag when building `mypackage` but not its dependencies. `go build -asmflags=pattern=flags ...` applies the flags only to the packages matching the pattern. For example `go install -ldflags=cmd/gofmt=-X=main.version=1.2.3 cmd/ ...` installs all the commands matching `cmd/...` but only applies the `-X` option to the linker flags for `cmd/gofmt`.

#### Testing
The `go test ..` command now caches test result if the test executable and command line matches a previous run, and the files and environment variables consulted by the run have not changed. `go test` will print the previous test output,  replacing the elapsed time with the string **"cached"**.  The `go test` command now runs `go vet` on the testing package to identify significant problems before running the test(s). `go vet` can be disabled by passing the `-vet=off` flag to the `go test` command - `go test -vet=off`

The `go test -coverpkg` flag now interprets its argument as a comma-separated list of patterns to match against the dependencies of each test. For example, `go test -coverpkg=all` is now a more meaningful way to run a test with coverage enabled for the test package and all its dependencies.

Passing the `-failfast` flag to `go test` disables running additional tests after any test fails.

There's a new flag `-json` when used with `go test`, converts the test output to JSON format - `go test -json`

#### GoDoc
The `go doc` tool now adds functions returning slices of `T` or `*T` to the display of `type T`.  For example:
```shell
$ go doc mail.Address
package mail // import "net/mail"

type Address struct {
	Name    string
	Address string
}
    Address represents a single mail address.

func ParseAddress(address string) (*Address, error)
func ParseAddressList(list string) ([]*Address, error) // Pointer is included
func (a *Address) String() string
```
In Go 1.9 `go doc mail.Address` outputs:
```shell
package mail // import "net/mail"

type Address struct {
 Name    string
 Address string
}
    Address represents a single mail address. An address such as "Barry Gibbs
    <[bg@example.com](mailto:bg@example.com)>" is represented as Address{Name: "Barry Gibbs", Address:
    "[bg@example.com](mailto:bg@example.com)"}.

func ParseAddress(address string) (*Address, error)
func (a *Address) String() string
```
Difference between both is the display of `ParseAddressList` which was only shown  the package overview - `go doc mail`.

#### Go Vet
The `go vet` command now always have access to complete, up-to-date type information when checking packages, even for packages using `cgo` or vendored imports.

#### Diagnostics
Go 1.10 includes a new [overview of available Go program diagnostic tools](https://golang.org/doc/diagnostics.html)

#### Gofmt
Go 1.10 changed two minor details of the default formatting of Go source code. For instance, a certain complex three-index slice expression formatted like `x[i+1 : j:k` is now formatted with more consistent spacing: `x[i+1 : j : k`. Inline interface with single methods is now supported:
```go
type CarService interface { Check() }
```

Running `go fmt` in Go 1.9 formats the above to:
```go
type CarService interface {
  Check()
 }
  ```

#### Go Fix
The `go fix`  tool now replaces imports of `golang.org/x/net/context` with `"context"`

### Runtime
The behavior of nested calls to [`LockOSThread`](https://golang.org/pkg/runtime/#LockOSThread) and [`UnlockOSThread`](https://golang.org/pkg/runtime/#UnlockOSThread) has changed. These functions control whether a goroutine is locked to a specific operating system thread, so that the goroutine only runs on that thread, and the thread only runs that goroutine. Previously, calling `LockOSThread` more than once in a row was equivalent to calling it once, and a single `UnlockOSThread` always unlocked the thread. Now, the calls nest: if `LockOSThread` is called multiple times, `UnlockOSThread` must be called the same number of times in order to unlock the thread. Existing code that was careful not to nest these calls will remain correct. Existing code that incorrectly assumed the calls nested will become correct. Most uses of these functions in public Go source code falls into the second category.

In Go 1.10, there's a change. if `LockOSThread` is called multiple times, `UnlockOSThread` must be called the same number of times in order to unlock the thread. Detail the changes you can follow links:
[https://github.com/golang/go/issues/20458](https://github.com/golang/go/issues/20458)
[https://go-review.googlesource.com/c/go/+/45752](https://go-review.googlesource.com/c/go/+/45752)

There is no longer a limit on the `[GOMAXPROCS](https://tip.golang.org/pkg/runtime/#GOMAXPROCS)` setting.

### Performance
As always, the changes are so general and varied that precise statements about performance are difficult to make. Most programs should run a bit faster, due to speedups in the garbage collector, better generated code, and optimizations in the core library.

### Changes to Standard Library
Here I'll list some changes to the Go standard library as of Go 1.10, full details on this can be found on the [official release doc](https://golang.org/doc/go1.10)

#### Lib: net/url
The `ResolveReference` method now preserves multiple leading slashes n the target URL. Previously, it rewrote multiple leading slashes to a single slash, which resulted in the `http.Client` following certain redirects incorrectly. Consider following code:
```go
base, _ := url.Parse("http://host//path//to/page1")
target, _ := url.Parse("page2")
fmt.Println(base.ResolveReference(target))
```
In Go 1.9, the output of the above is `http://host/path//to/page2`
In Go 1.10, the resolved URL is `http://host//path//to/page2`

Note the doubled slashes around `path`. In Go 1.9 and earlier, the resolved URL was `http://host/path//to/page2`: the doubled slash before `path` was incorrectly rewritten to a single slash, while the doubled slash after `path` was correctly preserved. Go 1.10 preserves both doubled slashes, resolving to `http://host//path//to/page2` as required by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-5.2).

This change may break existing buggy programs that unintentionally construct a base URL with a leading doubled slash in the path and inadvertently depend on `ResolveReference` to correct that mistake. For example, this can happen if code adds a host prefix like `http://host/` to a path like `/my/api`, resulting in a URL with a doubled slash: `http://host//my/api`.

#### Lib: os
[`File`](https://golang.org/pkg/os/#File) adds new methods [`SetDeadline`](https://golang.org/pkg/os/#File.SetDeadline), [`SetReadDeadline`](https://golang.org/pkg/os/#File.SetReadDeadline), and [`SetWriteDeadline`](https://golang.org/pkg/os/#File.SetWriteDeadline) that allow setting I/O deadlines when the underlying file descriptor supports non-blocking I/O operations. The definition of these methods matches those in [`net.Conn`](https://golang.org/pkg/net/#Conn). If an I/O method fails due to missing a deadline, it will return a timeout error; the new [`IsTimeout`](https://golang.org/pkg/os/#IsTimeout) function reports whether an error represents a timeout.

Also matching `net.Conn`, `File`'s [`Close`](https://golang.org/pkg/os/#File.Close) method now guarantee that when `Close` returns, the underlying file descriptor has been closed. (In earlier releases, if the `Close` stopped pending I/O in other goroutines, the closing of the file descriptor could happen in one of those goroutines shortly after `Close` returned.)

On BSD, macOS, and Solaris systems, [`Chtimes`](https://golang.org/pkg/os/#Chtimes) now supports setting file times with nanosecond precision (assuming the underlying file system can represent them).

#### Lib: strconv
[`ParseUint`](https://golang.org/pkg/strconv/#ParseUint) now returns the maximum magnitude integer of the appropriate size with any `ErrRange` error, as it was already documented to do. Previously it returned 0 with `ErrRange` errors.

## Conclusion
This article was made to point out some changes made to the Go programming language. Having been using Go since v1.8 some of the changes to v1.10 brings optimization and faster runtime to developing Go programs. Have you upgraded your existing Go codebases to V1.10? Share your experience in the comment section below 😄.

#### References
[https://golang.org.doc/go1.10](https://golang.org.doc/go1.10)

