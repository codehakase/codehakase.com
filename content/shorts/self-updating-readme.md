---
title: "Scripting a self-updating Github Readme"
date: 2025-05-01
layout: shorts
tags: [github, automation, go]
description: "Automating the update of my Github profile README using Go and Github Actions to fetch blog posts and render a template."
---

I recently updated the README [^1] on my [Github profile](https://github.com/codehakase/codehakase) to add a new blog post entry, which made me realise this manual process was a good candidate for automation.

![Github profile for codehakase](/images/shorts/self-updating-readme/github-readme.png)

I took inspiration from [Simon Willison's blog](https://simonwillison.net/2020/Jul/10/self-updating-profile-readme/) to utilise Github Actions for this. The [Github Action](https://github.com/codehakase/codehakase/blob/master/.github/workflows/push.yml) calls a [script](https://github.com/codehakase/codehakase/tree/master/up) that:

* Fetch and unmarshall rss feed items from this blog
* Render README template using feed data
* Updates the current `README.md` if there's a diff

The core Go script orchestrates fetching the data and rendering the template. Here's a snippet:
```go
func main() {
	ctx := context.Background()
	var readmeInfo ReadmeInfo

	errGroup, ctx := errgroup.WithContext(ctx)
	errGroup.SetLimit(5)

	errGroup.Go(func() error {
		var err error
		readmeInfo.Posts, err = fetchRSSFeed(ctx, rssSource)
		return err
	})

	if err := errGroup.Wait(); err != nil {
		log.Fatalf("failed to fetch feed data: %+v\n", err)
	}

	if err := renderTemplate(&readmeInfo); err != nil {
		log.Fatalf("failed to render readme, errr: %+v", err)
	}
}
```

This is currently configured to run every push to the repo, and on schedule for every 6 hours.

What I like about the structure of this script is how I can extend it to pull multiple feed entries. It only pulls my latest posts, and with this new [Shorts](/shorts) category I've added for TILs and short-form content, I can extend the `ReadmeInfo` to include a `Shorts` slice, and add another routine to concurrently fetch the rss info for shorts.

[^1]: GitHub profile READMEs allow users to create a special repository with their username. This enables personalized introductions with information like bio, skills, and projects.

