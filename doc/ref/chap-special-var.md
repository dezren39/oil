---
title: Special Variables (Oils Reference)
all_docs_url: ..
body_css_class: width40
default_highlighter: oils-sh
preserve_anchor_case: yes
---

<div class="doc-ref-header">

[Oils Reference](index.html) &mdash;
Chapter **Special Variables**

</div>

This chapter describes special variables for OSH and YSH.

<span class="in-progress">(in progress)</span>

<div id="dense-toc">
</div>

## YSH Vars

### ARGV

Replacement for `"$@"`

### ENV

TODO

### _this_dir

The directory the current script resides in.  This knows about 3 situations:

- The location of `oshrc` in an interactive shell
- The location of the main script, e.g. in `osh myscript.sh`
- The location of script loaded with the `source` builtin

It's useful for "relative imports".

## YSH Status

### `_status`

An `Int` that's set by the `try` builtin.

    try {
      ls /bad  # exits with status 2
    }
    if (_status !== 0) {  # _status is 2
      echo 'failed'
    }

### `_error`

A `Dict` that's set by the `try` builtin when catching certain errors.

Such errors include JSON/J8 encoding/decoding errors, and user errors from the
`error` builtin.

    try {
      echo $[toJson( /d+/ )]  # invalid Eggex type
    }
    echo "failed: $[_error.message]"  # => failed: Can't serialize ...

### `_pipeline_status`

After a pipeline of processes is executed, this array contains the exit code of
each process.

Each exit code is an [Int](chap-type-method.html#Int).  Compare with
[`PIPESTATUS`](#PIPESTATUS).

### `_process_sub_status`

The exit status of all the process subs in the last command.

## YSH Tracing

### SHX_indent

### SHX_punct

### SHX_pid_str

## YSH Read

### _reply

YSH `read` sets this variable:

    read --all < myfile
    echo $_reply

## Oils VM

### `OILS_VERSION`

The version of Oils that's being run, e.g. `0.9.0`.

<!-- TODO: specify comparison algorithm. -->

### `OILS_GC_THRESHOLD`

At a GC point, if there are more than this number of live objects, collect
garbage.

### `OILS_GC_ON_EXIT`

Set `OILS_GC_ON_EXIT=1` to explicitly collect and `free()` before the process
exits.  By default, we let the OS clean up.

Useful for ASAN testing.

### `OILS_GC_STATS`

When the shell process exists, print GC stats to stderr.

### `OILS_GC_STATS_FD`

When the shell process exists, print GC stats to this file descriptor.

## Shell Vars

### IFS

Used for word splitting.  And the builtin `shSplit()` function.

### LANG

TODO: bash compat

### GLOBIGNORE

TODO: bash compat

## Shell Options

### SHELLOPTS

bash compat: serialized options for the `set` builtin.

### BASHOPTS

bash compat: serialized options for the `shopt` builtin.

## Other Env

### HOME

$HOME is used for:

1. ~ expansion 
2. ~ abbreviation in the UI (the dirs builtin, \W in $PS1).

Note: The shell doesn't set $HOME.  According to POSIX, the program that
invokes the login shell sets it based on /etc/passwd.

### PATH

A colon-separated string that's used to find executables to run.


## POSIX Special

## Other Special

### BASH_REMATCH

Result of regex evaluation `[[ $x =~ $pat ]]`.

### PIPESTATUS

After a pipeline of processes is executed, this array contains the exit code of
each process.

Each exit code is a [Str](chap-type-method.html#Str).  Compare with
[`_pipeline_status`](#_pipeline_status).

## Platform

### HOSTNAME

The name of the "host" or machine that Oils is running on, determined by
`gethostname()`.

### OSTYPE

The operating system that Oils is running on, determined by `uname()`.

Examples: `linux darwin ...`

## Call Stack

### BASH_SOURCE

### FUNCNAME

### BASH_LINENO

## Tracing

### LINENO

## Process State

### BASHPID

TODO

### PPID

TODO

### UID

### EUID

## Process Stack

## Shell State

## Completion

### COMP_WORDS

An array of words, split by : and = for compatibility with bash.  New
completion scripts should use COMP_ARGV instead.

### COMP_CWORD

Discouraged; for compatibility with bash.

### COMP_LINE

Discouraged; for compatibility with bash.

### COMP_POINT

Discouraged; for compatibility with bash.

### COMP_WORDBREAKS

Discouraged; for compatibility with bash.

### COMPREPLY

User-defined completion functions should Fill this array with candidates.  It
is cleared on every completion request.

### COMP_ARGV

An array of partial command arguments to complete.  Preferred over COMP_WORDS.
The compadjust builtin uses this variable.

(An OSH extension to bash.)

## History

### HISTFILE

Override the default OSH history location.

### YSH_HISTFILE

Override the default YSH history location.

## cd

### PWD

### OLDPWD

### CDPATH

## getopts

### OPTIND

### OPTARG

### OPTERR

## read

### REPLY

OSH read sets this:

    read < myfile

## Functions

### RANDOM

bash compat

### SECONDS

bash compat

