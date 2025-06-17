---
layout: post
title: "Building Small Containers for Kubernetes"
author: "@codehakase"
hakase:
  featureimage: 
    url: "https://res.cloudinary.com/hakase-labs/image/upload/v1543635780/Screen_Shot_2018-12-01_at_4.36.33_AM_n2pane.png"
description: "This article will show you how you can build small containers to make your Kubernetes deployments faster and more secure."
modified: 2018-12-01
tags: [go,docker,kubernetes]
share: true
comments: true
category: [go,docker,kubernetes]
---

The first step to deploying any app to [Kubernetes](https://kubernetes.io), is to bundle the app in a
container. There are several official, and community-backed container images for
various languages and distros, and most of these containers can be really large,
or sometimes contain overheads your app may never need/use.

Thanks to [Docker](https://docker.io), you can easily create container images in
a few steps; specify a base image, add your app-specific changes, and build your
container.

```dockerfile
FROM golang:alpine

WORKDIR /app

ADD . /app

EXPOSE 8080

ENTRYPOINT ["/app/run"]
```

We specified a base image (Linux alpine in this case), set the working directory
to be used in the container, exposed a network port, and an entry point, which
will start the app in the container. With the Dockerfile set, we can build the
container.

```shell
$ docker build myapp .
```

While the above process is pretty straight forward, there are some issues
to put into consideration. Using the default images can lead to large container
images, security vulnerabilities, and memory overheads.

#### Let's flesh out a sample app
We'll write a simple app in Go, that exposes a single HTTP route that returns a
string when hit. We will build a Docker image from it.

```go
package main

import (
	"fmt"
	"log"
	"net/http"
	"time"
)

func main() {
	r := http.NewServeMux()
	r.HandleFunc("/api/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello From Go!")
	})
	s := &http.Server{
		Addr:        ":8080",
		Handler:     r,
		ReadTimeout: 10 * time.Second,
	}
	fmt.Println("Starting server on port 8080")
	log.Fatal(s.ListenAndServe())
}
```
Let's build the Docker image with our app. First, we need to create a Dockerfile.

```docker
FROM golang:latest

RUN mkdir /app
ADD . /app/
WORKDIR /app
RUN go build -o myapp .

CMD ["/app/myapp"]
```
Build the image.

> PS: Replace tag with anything of choice: <user>/appname

```shell
$ docker build -t codehakase/goapp .
```

That's it! We just Dockerized a simple Go app. Let's take a look at the image we
just built.
![docker images list](https://res.cloudinary.com/hakase-labs/image/upload/v1543632543/Screen_Shot_2018-12-01_at_3.47.19_AM_wgpi3m.png)

For a simple Go app, the image is over 700 megabytes. The Go binary itself is
probably a few megabytes in size, and the additional overhead is wasted space,
and can also be a hiding place for bugs and security vulnerabilities.

What is taking up so much space? In this scenario, the container needs Go
installed, along with all the dependencies Go relies on, and all of this sits on
top of a Debian or Linux distro.

There are two ways to reduce container image sizes, actually three of which the
third is more often used in the Go community:

1. Using Small Base Images
2. The Builder Pattern
3. Using Empty Images

Using small base images are the easiest way to reduce container image size. The
stack/language in use probably provides an official image that's much smaller
than the default image.

Let's update the Dockerfile to use a small base image. We're going to use
`golang:alpine` in this case.

```docker
FROM golang:alpine

RUN mkdir /app
ADD . /app/
WORKDIR /app
RUN go build -o myapp .

CMD ["/app/myapp"]
```

Rebuild image.

```shell
$ docker build -t codehakase/goapp .
```

With the update to the Dockerfile, our image is now smaller compared to the
previous image.
![using small base images](https://res.cloudinary.com/hakase-labs/image/upload/v1543633738/Screen_Shot_2018-12-01_at_4.07.28_AM_wm920i.png)

This image size if still quite large, and we can even go smaller using the
Builder Pattern. Since we're using a compiled language (Go) in this example, in
the builder pattern, we should note that compiled languages often requires tools
that are not necessarily needed to run the code. These tools are mostly for
building and compiling to a binary. With the builder pattern, we can remove
these tools in the final container.

To use the Builder pattern in our existing example, we'll compile our code in a
container, and then use the compiled code to package the final container, without
all the required tools.

```docker
FROM golang:alpine AS main-env
RUN mkdir /app
ADD . /app/
WORKDIR /app
RUN cd /app && go build -o myapp

FROM alpine
WORKDIR /app
COPY --from=main-env /app/myapp /app
EXPOSE 8080

ENTRYPOINT ./myapp
```

We updated the Dockerfile to use the builder pattern. First, it builds and
compiles the app in the `alpine` container and name the step `main-env`, and
then copies the binary from the previous step to the new container.

Rebuild the multistage Dockerfile.

```shell
$ docker build -t codehakase/goapp .
```

The result of the build is a new container which is just a little over 10
megabytes.
![builder pattern](https://res.cloudinary.com/hakase-labs/image/upload/v1543634782/Screen_Shot_2018-12-01_at_4.24.48_AM_c6fnis.png)

Remember the first image we built that was over 700 megabytes? We've been able
to cut that down to 10.7 megabytes using the builder pattern.

We can still reduce this number a bit, by making use of scratch (empty)
images. What's a scratch image? It's a special docker image that's empty. To use
this, we need to first build our app outside the docker environment and add the
compiled binary to the container.

```shell
$ go build -o myapp .
```

We'll update the Dockerfile to add the binary to a scratch image.

```docker
FROM scratch
ADD myapp /
CMD ["/myapp"]
```

Let's build this image and see how large it turns out.
![scratch image](https://res.cloudinary.com/hakase-labs/image/upload/v1543635780/Screen_Shot_2018-12-01_at_4.36.33_AM_n2pane.png)

We got it down to 6.5 megabytes, cool! Let's try running our container to test
our app.

```shell
$ docker run -it codehakase/goapp
```

You may get an error like this:
![](https://res.cloudinary.com/hakase-labs/image/upload/v1543635780/Screen_Shot_2018-12-01_at_4.40.08_AM_pvjj3k.png)

Reason for this error, is the Go binary is looking for libraries on the OS its
running on, since the scratch image is empty, there are no libraries to look in.
We need to modify the build command to statically compile our Go app:

```shell
$ GO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o myapp .
```

Rebuild with `docker build -t codehakase/goapp`, and run the our container
again, forwarding the port on the container to our machine:

```shell
$ docker run -it -p 8080:8080 codehakase/goapp
  Starting server on port 8080
```

Navigate to `http://localhost:8080/api` to test the response from the app.

### Conclusion
The goal of this article was to explain how to reduce container sizes
specifically for Go apps. With smaller containers, you have more performance, as
building your containers say in a CI environment is going to be faster, pushing
your built images to a container registry will take less amount of time, and
most importantly pulling these containers to your distributed kubernetes
clusters will be faster, as smaller containers are less likely to delay a
deployment for a new cluster.

If you have any suggestions or comments, leave a comment below or ping
[@codehakase](https://twitter.com/codehakase)
