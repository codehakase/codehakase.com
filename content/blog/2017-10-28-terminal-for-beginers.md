---
layout: post
title: "Terminal for Beginners!"
author: "@codehakase"
description: "A simple guide to getting started with the Terminal"
modified: 2017-10-28
tags: [unix, terminal]
share: true
comments: true
category: workflow/tools
---
Getting into Software Development seem overwhelming (actually it is) these days. One has to go through the hassle of getting familiar with different languages, to organizing codebases, to libraries, frameworks, the list goes on. Every Job description (at least the sane ones), requires additional skills to get the job. Example of such, Version Control (Git or Mecurial), tasks runners, build tools, package managers, etc.

Most of these extra tools are being accessed/used from a command line interface. The black hacker environment thingy stuff seem frightening kind of, but this article should get you familiar with the terminal interface. For those of us already familiar, after reading this article, you'd wished you've read it before you opened a terminal for the first time.

> Note, this article is directed towards unix based terminal environments


### What is a terminal?
A terminal is an interface where you can type and execute text based commands. Every operating system comes with a factory command line interface (CLI). On Linux the default terminal is named "Terminal", same for MacOS. On Windows, you'd find the **command prompt** which is totally different from Linux and macOS since those are built on Unix, so to get the features (which we'll discuss later), you can Install a [linux enviroment](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide).


![terminal window](http://res.cloudinary.com/hakase-labs/image/upload/c_scale,w_1230/v1509199976/terminal-1.png "An opened Terminal window on Linux")


### Basic commands
**Changing directories:** You can change into any directory from a terminal with the `cd` command. What it requires is a valid path to a directory. So using the command:
```shell
$ cd Downloads
```
**Listing files and directories:** To list the contents of a directory, you can use the `ls` command.
```shell
$ cd Downloads
Downloads$ ls
golang-1.9 file.txt ...
```
> You can also pass arguments to `ls` command to change its behaviour.
```shell
Downloads$ ls -a -l
total 12
drwxr-xr-x  3 codehakase codehakase 4096 Oct 11 20:25 .
drwxr-xr-x 37 codehakase codehakase 4096 Oct 28 15:22 ..
drwxr-xr-x  2 codehakase codehakase 4096 Oct 22 17:04 talks
```
The `-a` and `-l` flags, shows all files (`-a` including hidden ones), and list them one file per line (`-l`).

#### Essential commands for file and directory management
```shell
ls     # List files
cat    # Show file content
mkdir  # Make directory
rm     # Remove file (or dir)
pwd    # Output the current directory
cd     # Change directory
mv     # Move or rename a file (or dir)
cp     # Copy file (or dir)
```
#### Finding your way around commands when stuck
Most commands (if not all) comes with a `--help` argument, which displays a list of available options for that commands, and what each option do.
So executing `ls --help` from the terminal would display:
```shell
Usage: ls [OPTION]... [FILE]...
List information about the FILEs (the current directory by default).
Sort entries alphabetically if none of -cftuvSUX nor --sort is specified.

Mandatory arguments to long options are mandatory for short options too.
  -a, --all                  do not ignore entries starting with .
  -A, --almost-all           do not list implied . and ..
      --author               with -l, print the author of each file
  -b, --escape               print C-style escapes for nongraphic characters
      --block-size=SIZE      scale sizes by SIZE before printing them; e.g.,
                               '--block-size=M' prints sizes in units of
                               1,048,576 bytes; see SIZE format below
  -B, --ignore-backups       do not list implied entries ending with ~
  -c                         with -lt: sort by, and show, ctime (time of last
                               modification of file status information);
                               with -l: show ctime and sort by name;
                               otherwise: sort by ctime, newest first
...
```
> For most commands, if you want to learn more about them without googling you can run `man commandName`. The `man` command displays a manual for any command.

### Setting up with Package Managers
Package managers are tools used to install software, or dependencies for projects. Some examples:
- yarn
- npm
- Homebrew
- apt-get

Linux distributions come pre-installed with package managers like **apt-get** or **yum**. MacOS preferred package manager is *Homebrew* available at [brew.sh](https://brew.sh).

### Dotfiles
Dotfiles are used to customize your system. The name is derived from the configuration files in Unix-like systems (eg .zshrc, .gitconfig, etc). Dotfiles automate things. If you get a new machine, you'll have to setup your development environment to the taste of yours, that takes a while, and yeah you'd probably forgotten the download pages for those awesome little plugins/packages that did the job. And apart from remembering download pages, we haven't mentioned the plethora of configurations and system preference to redo (I don't think you can memorize all...). I'm not going to go too deep into dotfiles, there'll be a dedicated article for it here on my blog.

Some example dotfiles
- .bashrc
- .zshrc
- .env
- .prompt


![Dotfiles](http://res.cloudinary.com/hakase-labs/image/upload/c_scale,w_1230/v1509222152/dotfiles_gyp7ku.png "Dotfiles linux")



### Git
You've probably heard of Git before, well no assumptions here. Git is a program used for version control. It allows you keep track of changes made to a project (repository), and allow multiple collaboration on a single project.
> Git is a life saver!!!

Installing Git is easy, we can use either Homebrew (macOS), apt-get (Linux distros) and on windows, Git bash or Chocolatey.
#### Linux
```shell
sudo apt-get install git
```
#### macOS
```shell
brew install git
```
#### windows
```shell
# chocolatey
choco install git
```

![Git](http://res.cloudinary.com/hakase-labs/image/upload/c_scale,w_1230/v1509221564/git-shell_f7q4nc.png "git prompt")


### Aliases
While using the terminal more often, you'd probably note some commands you repeat. You can use an alias to abbreviate more complex commands. While I work, I normally have to commit, push, or clone stuff using git, I have some commands abbreviated:
```shell
alias gc="git commit -m"

# The above is used, gc "initial commit"
```
Note, if you define aliases, it will only be available on the terminal's session. If you close your terminal, everything resets. If you want a permanent alias, you'd edit your terminal's profile (`.bashrc`, `.zshrc`, `.profile`). I use [ZSH and oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) for my terminal environment, so I'd edit my `.zshrc` file to add my alias same as before.


### Conclusion
Its been walking with you this far. If you're new to the terminal bla bla bla, I hope you feel comfortable now to use the terminal.

I'm no expert with the Terminal, still finding my way around it too, so I may have missed something. If I have, feel free to let me know in the comment below, or send me a tweet [@codehakase](https://twitter.com/codehakase). Thanks.

### Worth Checking out
[The Art of Command Line](https://github.com/jlevy/the-art-of-command-line#the-art-of-command-line)
