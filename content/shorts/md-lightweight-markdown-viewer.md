---
title: "Parsing, Not Guessing"
modified: 2025-06-14
layout: shorts
tags: [go, markdown]
description: "Using ASTs over regex to build a predictable, lightweight, theme-aware Markdown renderer in Go."
---

Markdown rendering in the terminal is usually done with string replacements or regex. This doesn’t scale. 

Goldmark exposes a proper AST. Each node has type, position, and content. Rendering becomes walking the tree:
```go
// render renders the AST node to the writer
func (tr *terminalRenderer) render(w io.Writer, source []byte, node ast.Node) error {
	return ast.Walk(node, func(node ast.Node, entering bool) (ast.WalkStatus, error) {
		err := tr.renderNode(w, source, node, entering)
		if err != nil {
			return ast.WalkStop, err
		}
		return ast.WalkContinue, nil
	})
}
```

This is better. You don’t need to guess whether a * means emphasis or a list. You know.

Syntax highlighting is handled by Chroma. It doesn’t support aliases like jsonc, tsx, zsh. I added a switch. Not ideal, but works:

```go
// getLexerByAlias handles language aliases that might not be directly supported
func (ch *ChromaHelper) getLexerByAlias(language string) chroma.Lexer {
	switch strings.ToLower(language) {
	case "jsonc", "json5":
		return lexers.Get("json")
	case "tsx":
		return lexers.Get("typescript")
	case "jsx":
		return lexers.Get("javascript")
	case "sh", "shell", "zsh", "fish":
		return lexers.Get("bash")
    ...
	default:
		return nil
	}
}
```

Terminal themes: there is no portable API. Some terminals expose `COLORFGBG`. Others don’t. Parse it when it exists:
```go
func DetectTerminalBackground() BackgroundType {
	if theme := os.Getenv("COLORFGBG"); theme != "" {
		// COLORFGBG format is typically "foreground;background"
		// Lower numbers (0-7) typically indicate darker colors
		// Higher numbers (8-15) typically indicate lighter colors
		parts := strings.Split(theme, ";")
		if len(parts) >= 2 {
			bg := parts[len(parts)-1]
			// Simple heuristic: if background is 0-7, it's likely dark
			if bg >= "0" && bg <= "7" {
				return BackgroundDark
			} else if bg >= "8" && bg <= "15" {
				return BackgroundLight
			}
		}
	}
    
    //...
}
```

Pager integration uses less:
```go
// Display shows the content using less with vim-style navigation options
func (p *Pager) Display(content string) error {
	if p.lessPath == "" {
		return fmt.Errorf("less command not available")
	}

	args := []string{
		"-R", // Raw control characters (for ANSI colors)
		"-S", // Chop long lines (don't wrap)
		"-X", // Don't clear screen on exit
		"-F", // Quit if entire file fits on screen
		"-K", // Exit on Ctrl-C
		"+g", // Start at beginning (gg equivalent)
	}

	env := append(os.Environ(),
		"LESS_TERMCAP_md=\033[1;36m",    // Bold cyan for headings
		"LESS_TERMCAP_us=\033[1;32m",    // Bold green for underline
		"LESS_TERMCAP_so=\033[1;44;33m", // Bold yellow on blue for standout
		"LESS_TERMCAP_se=\033[0m",       // End standout
		"LESS_TERMCAP_ue=\033[0m",       // End underline
		"LESS_TERMCAP_me=\033[0m",       // End bold/italic
	)

	cmd := exec.Command(p.lessPath, args...)
	cmd.Env = env
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

    // ...

	return nil
}
```

These are some of my notes from a recent tool I worked on called [md](https://github.com/codehakase/md). It renders Markdown in the terminal with syntax highlighting and theme support. Not the point. The point is: *parse, don’t guess*.
