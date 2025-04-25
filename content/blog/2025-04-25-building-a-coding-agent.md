---
layout: post
title: "Notes on building a coding agent"
author: "@codehakase"
description: "My personal reflections on Thorsten's Ampcode article, which reveals how building AI coding agents can be more about leveraging powerful models than complex, custom code."
modified: 2025-04-25
tags: [go, amp, ai]
share: true
category: ai
---

I just finished reading Thorsten Ball's article on Ampcode, [How to build an agent](https://ampcode.com/how-to-build-an-agent?ref=codehakase.com), and wanted to note my thoughts. Going into it, I kind of expected a deep dive into complex engineering, maybe some heavy AI theory behind coding agents. But the main thrust of the piece was surprisingly different. It argues that building these agents doesn't necessarily involve arcane secrets. Thorsten makes a strong case that with the right model (like Anthropic's Claude) and a good SDK, a lot of the work boils down to setting up relatively standard boilerplate code.

### Key takeways
What really stood out was how the Anthropic Go SDK handles the heavy lifting. It abstracts away the direct API interactions, making it much simpler to work with the model's features. The core agent loop presented felt quite manageable:
* Initialize the client.
* Track the conversation history (the SDK uses `anthropic.MessageParam` for this).
* Get input from the user.

Then you loop: call the API with the model details, conversation history, and token limits.

```go
// This core inference call felt straightforward with the SDK
func (a *Agent) runInference(ctx context.Context, conversation []anthropic.MessageParam) (*anthropic.Message, error) {
    message, err := a.client.Messages.New(ctx, anthropic.MessageNewParams{
        Model:     anthropic.ModelClaude3_7SonnetLatest,
        MaxTokens: int64(1024),
        Messages:  conversation,
    })
    return message, err
}
```

I also found the approach to integrating tools particularly interesting. It wasn't about complex modifications, but more about clearly defining the tool's metadata (name, description, input schema) and passing that information along in the API call.

```go
// Passing tool info seemed like the main change for tool integration
func (a *Agent) runInference(ctx context.Context, conversation []anthropic.MessageParam) (*anthropic.Message, error) {
    anthropicTools := []anthropic.ToolUnionParam{}
    for _, tool := range a.tools { 
        anthropicTools = append(anthropicTools, anthropic.ToolUnionParam{
            OfTool: &anthropic.ToolParam{
                Name:        tool.Name,
                Description: anthropic.String(tool.Description),
                InputSchema: tool.InputSchema,
            },
        })
    }

    message, err := a.client.Messages.New(ctx, anthropic.MessageNewParams{
        Model:     anthropic.ModelClaude3_7SonnetLatest,
        MaxTokens: int64(1024),
        Messages:  conversation,
        Tools:     anthropicTools,
    })
    return message, err
}
```

The emphasis was clearly on describing the tool well so the model can figure out when to use it. The example for an edit_file tool made this concrete:

```go
var EditFileDefinition = ToolDefinition{
    Name: "edit_file",
    Description: `Make edits to a text file. ...`, 
    InputSchema: EditFileInputSchema,
    Function:    EditFile,
}

type EditFileInput struct {
    Path   string `json:"path" jsonschema_description:"..."`
    OldStr string `json:"old_str" jsonschema_description:"..."`
    NewStr string `json:"new_str" jsonschema_description:"..."`
}
```

I was initially bracing for discussions on fine-tuning or complex inference logic. Finding out that the foundation model itself, accessed via the SDK, handles so much of the core intelligence was a bit of a revelation. It really underscores how powerful these models are becoming and how accessible building agentic workflows can be, often relying more on structuring interactions and defining tools than on deep AI wizardry.

Reading this also helped demystify some of the terminal-based AI tools I've used. While I know production systems have more layers, seeing this fundamental structure makes their inner workings feel less like a black box.

My favourite text from the article is:

> If you’re anything like all the engineers I’ve talked to in the past few months, chances are that, while reading this, you have been waiting for the rabbit to be pulled out of the hat, for me to say “well, in reality it’s much, much harder than this.” But it’s not.

This has definitely sparked some ideas. I think my next step will be to actually play around with the agent structure outlined in the article. I'm curious to try building a similar agent but perhaps swapping out the model – maybe using Google's Gemini – to see how the process and the results compare.
