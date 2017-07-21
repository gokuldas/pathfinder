# Pathfinder
Pathfinder is a bunch of scripts to simplify management of $PATH variable. It can
be used from Bash or Zsh shells to:
- Initialize the PATH variable with a default set when the shell is initialized
- Add or remove paths one by one, or in groups
- Backup and restore PATH variable

The indiviual paths are stored in a TOML files. Each path is also associated with
one or more aspects (or tags). These aspects are used in pathfinder commands to
add or remove paths in `$PATH` variable, one by one, or in group.

## Installation
### Prerequisites
1. Bash or Zsh shell
2. Python 3 (Available in package repositories of most OS)
3. [TOML python library](https://github.com/uiri/toml)
4. Git (Optional: You could download source from GitHub instead of cloning repo)

Once you have installed python 3, check the OS package repository for the python
TOML package. If it is not available, you can install it from
[PyPI Repository](https://pypi.python.org/pypi/toml) using the command:
```bash
pip install toml
```
Or if you want to install just for you user account:
```bash
pip install --user toml
```
### Installing Pathfinder
Clone this git repository into some directory, preferably `~/scripts/pathfinder`.
And move the pathfinder.toml file into `$XDG_CONFIG_HOME/pathfinder/`. XDG
configuration path is usually `~/.config` as specified by
[freedesktop](https://specifications.freedesktop.org/basedir-spec/basedir-spec-0.6.html#variables).
Do an `echo $XDG_CONFIG_HOME` to ensure that it is not empty. If it is empty,
replace `$XDG_CONFIG_HOME` with `~/.config` path in the commands below.
```bash
mkdir -p ~/scripts
cd ~/scripts
git clone https://github.com/gokuldas/pathfinder pathfinder
mkdir -p $XDG_CONFIG_HOME/pathfinder
cp ~/scripts/pathfinder/src/pathfinder.toml $XDG_CONFIG_HOME/pathfinder
````

Add the following lines at the end of `.bashrc` or `.zshrc`:
```bash
alias pathfind="source ~/scripts/pathfinder/src/pathfinder.sh"
source ~/scripts/pathfinder/src/pathfinder.sh boot
```

Modify the configuration file as described below, and confirm that all the 
necessary dependencies are satisfied before logging off or rebooting.

### Creating configuration file
The file `$XDG_CONFIG_HOME/pathfinder/pathfinder.toml` contains some sample
path configurations as example. You may want to rewrite the entire file following
the format given in the sample. In general, a single path entry consists of the
lines:
```toml
[[Paths]]
path = "root_of_whereever_the_binaries_are/bin"
aspects = ["aspect1", "aspect2", "so_on..."]
```

For example:
```toml
[[Paths]]
path = "$HOME/.cargo/bin"
aspects = ["rust", "user", "default"]
```

#### Rules for creating configuration
1. Only the paths mentioned in the configuration can be managed by
pathfinder. So, if there are paths in the `$PATH` variable that are not mentioned
in `pathfinder.toml`, they will not be removed by pathfinder for the sake of
safety.

2. The paths are added to the `$PATH` variable in the order it is specified in
`pathfinder.toml`. However, the order of paths already in the `$PATH` variable
is not disturbed (unless ofcourse you are removing those paths).

3. Every path should be associated with one or more 'aspect strings'.

4. Atleast one aspect (usually the first one) for each path should be unique to
that path. This is so that the path can be managed independantly by
pathfinder when needed.

5. You can give same aspect to several paths. This is to manage a group of
paths together. For example, you may need to load `$PATH` with many paths to make
the Android SDK accessible. You could attach `"android"` aspect to all those paths.

6. `"default"` is a special aspect. The `boot` line added to `.bashrc` will cause
all paths having default aspect to be added to `$PATH`. So add `default` aspect to
all paths you want when opening a shell.

7. All paths are attached with an `"all"` aspect by default. You should not add
this aspect to any path yourself. You can use this aspect to manage all paths
at once.

8. It is a convention to add `"system"` aspect to all paths that belong to the
OS system directories. `"user"` aspect is added to all paths inside the user's
home directory. These are not implict - the user has to add these aspects manually.

9. Pathfinder supports usage of environment variables in `pathfinder.toml`. You
can use environment variables like `$HOME` inside `pathfinder.toml`. It is also
advisable to create environment variables for paths you use often inside
`pathfinder.toml`. Be careful to add such environment variables to `.bashrc` or
`.zshrc` before the lines added for pathfinder.

10. Resolution of `~` for home directory is not supported (yet). Use `$HOME`
variable instead.

11. You could consider removing the paths added to `$PATH` variable inside
`.bashrc` or `.zshrc` after adding them to `pathfinder.toml`. Please test the
setup using commands described below, before doing this.

## Usage
There are 3 workflows in using pathfinder commands:

### Shell boot
This is used to initialize the shell when one is started. The lines added to
`.bashrc` or `.zshrc` will ensure that all the paths with `default` aspect is
automatically added to `$PATH` variable.

### Simple workflow
The simple workflow can be used to manage `$PATH` variable of the currently open
shell using single command.

**Adding Paths:** You can add path/s to the $PATH variable with a single
pathfinder command:
```bash
pathfind up aspect_name
```

**Removing Paths:** You can remove path/s to the $PATH variable with a single
pathfinder command:
```bash
pathfind down aspect_name
```

### Staged workflow
Staged workflow is used when multiple operations are needed to change the `$PATH`
variable. All the modifications are done on a 'scratch variable' `$PFSCRATCH`
until you are ready to 'commit' the changes to the `$PATH` variable. The original
contents of the `$PATH` variable is backed up on another variable `$PFBACKUP` so
that the modifications may be aborted and rolled back anytime. This workflow is
inspired by git. This workflow is useful when the $PATH modification is
complicated - like when you want to remove all paths with a particular aspect,
except just one path.

**Show current values:** This command shows you the contents of `$PATH`, `$PFSCRATCH`
and `$PFBACKUP` variables at any instant. It is useful for viewing the results
of each intermediate operation. If any of the variables show as `Absent`, it means
that the variable is unset.
```bash
pathfind show
```

**Initiate scratch by copying $PATH:** You must initiate the scratch variable before
any further modification in this workflow. This command initiates the scratch with
value copied from `$PATH` variable.
```bash
pathfind init-copy
```

**Initiate scratch empty:** This is the second method of initiating the scratch
variable. This command initiates the scratch with an empty value.
```bash
pathfind init-empty
```

**Abort:** This command aborts the modifications and leaves the `$PATH` variables
untouched. It will work only if this workflow has been already initiated. It unsets
scratch variable to indicate that the workflow is completed. If you need to start
this workflow again, you should initialize.
```bash
pathfind abort
```

**Add paths:** This command can be used to add paths with specified aspects to the
scrath variable. Multiple add and remove commands can be used in this workflow
in any order. Unlike `up` and `down` commands, all these changes are made to only
the scratch variable, until you commit it.
```bash
pathfind add aspect_name
```

**Remove paths:** This command can be used to remove paths with specified aspects
from the scratch variabl. Just like add command, remove command also doesn't touch
the `$PATH` variable.
```bash
pathfind remove aspect_name
```

**Commit changes:** This command commits the changes you made on the scratch
variable to the `$PATH` variable. It also completes this workflow by unsetting the
scratch variable.
```bash
pathfind commit
```

### Restoring backup
At any time, all changes made by pathfinder can be rolled back using this command
```bash
pathfind restore
```

## License
The Pathfinder scripts and the rest of the contents of this repository is
distributed under the terms of MIT license. Refer 'LICENSE' file at the root
of this repository for details.

Copyright (c) 2017 Gokul Das B
