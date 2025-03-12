# Clean Hugo Theme

A clean, minimalist theme for personal websites and blogs.

## Features

- Responsive design
- Clean and minimal layout
- Tailwind CSS for styling
- Pagination for blog posts
- Archive page with posts grouped by year
- Tag support with dedicated tag pages

## Installation

1. Clone this repository to your Hugo site's themes directory:

```bash
git clone https://github.com/yourusername/hugo-clean-theme.git themes/clean
```

2. Add the following line to your Hugo site's configuration file (`config.toml`):

```toml
theme = "clean"
```

## Configuration

Example configuration in `config.toml`:

```toml
baseURL = "https://example.com/"
languageCode = "en-us"
title = "Your Name"
theme = "clean"

# Main sections
[params]
  mainSections = ["post"]
  description = "Your personal website description"
  twitter = "@yourtwitterhandle"

# Menu items
[menu]
  [[menu.main]]
    name = "About"
    url = "/about/"
    weight = 1
  [[menu.main]]
    name = "Blog"
    url = "/blog/"
    weight = 2
  [[menu.main]]
    name = "Archive"
    url = "/archive/"
    weight = 3
  [[menu.main]]
    name = "Tags"
    url = "/tags/"
    weight = 4
```

## Content Structure

The theme expects the following content structure:

```
content/
├── _index.md
├── about.md
├── archive.md
├── post/
│   ├── post-1.md
│   ├── post-2.md
│   └── ...
```

## License

This theme is released under the MIT License. 