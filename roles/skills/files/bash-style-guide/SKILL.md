---
name: bash-style-guide
description: >
  Guide for writing bash scripts following the ysap.sh Bash Style Guide.
  Use when asked to write, review, generate, or fix bash scripts.
---

# Bash Style Guide

Based on the [Bash Style Guide](https://style.ysap.sh/) by Dave Eddy (YSAP). This guide favors bash builtins over external commands, and safe/predictable patterns over "vibes".

---

## Aesthetics

### Tabs / Spaces

Two spaces for indentation, no tabs.

### Columns

Not to exceed 120.

### Semicolons

Avoid semicolons unless required in control statements (`if`, `while`).

```bash
# wrong
name='edvin';
echo "hello $name";

# right
name='edvin'
echo "hello $name"
```

### Functions

Don't use the `function` keyword. All variables created in a function should be `local`.

```bash
# wrong
function foo {
    i=foo # this is now global, wrong depending on intent
}

# right
foo() {
    local i=foo # this is local, preferred
}
```

### Block Statements

`then` goes on the same line as `if`; `do` goes on the same line as `while`.

```bash
# wrong
if true
then
    ...
fi

# right
if true; then
    ...
fi
```

### Spacing

No more than 2 consecutive newlines (i.e. no more than 1 blank line in a row).

### Comments

No explicit style for comments. Don't change someone's comments for aesthetic reasons unless rewriting or updating them.

---

## Bashisms

Prefer bash builtins/keywords over external commands or `sh(1)` syntax.

### `test(1)`

Use `[[ ... ]]`, not `[ ... ]` or `test ...`.

```bash
# wrong
test -d /etc
[ -d /etc ]

# right
[[ -d /etc ]]
```

### Sequences

Use bash builtins for generating sequences instead of `seq`.

```bash
n=10

# wrong
for f in $(seq 1 5); do ...; done
for f in $(seq 1 "$n"); do ...; done

# right
for f in {1..5}; do ...; done
for ((i = 0; i < n; i++)); do ...; done
```

### Command Substitution

Use `$(...)`, not backticks.

```bash
foo=`date`  # wrong
foo=$(date) # right
```

### Math / Integer Manipulation

Use `((...))` and `$((...))`. Do **not** use `let`.

```bash
a=5
b=4

# wrong
if [[ $a -gt $b ]]; then ...; fi

# right
if ((a > b)); then ...; fi
```

### Parameter Expansion

Prefer parameter expansion over external commands like `echo`, `sed`, `awk`.

```bash
name='lidholm17'

# wrong
prog=$(basename "$0")
nonumbers=$(echo "$name" | sed -e 's/[0-9]//g')

# right
prog=${0##*/}
nonumbers=${name//[0-9]/}
```

### Listing Files

Never [parse `ls(1)`](http://mywiki.wooledge.org/ParsingLs) - use builtin globbing to loop over files.

```bash
# very wrong, potentially unsafe
for f in $(ls); do ...; done

# right
for f in *; do ...; done
```

### Determining path of the executable (`__dirname`)

You can't reliably know this in bash. If you need the full path of the running script, rethink the design. See [BashFAQ028](http://mywiki.wooledge.org/BashFAQ/028).

### Arrays and Lists

Use bash arrays instead of space/newline-separated strings.

```bash
# wrong
modules='json httpserver jshint'
for module in $modules; do
    npm install -g "$module"
done

# right
modules=(json httpserver jshint)
for module in "${modules[@]}"; do
    npm install -g "$module"
done

# even better, if the command supports multiple args
npm install -g "${modules[@]}"
```

### `read` builtin

Use bash's `read` builtin instead of forking external commands.

```bash
fqdn='computer1.edvinlidholm.com'

IFS=. read -r hostname domain tld <<< "$fqdn"
echo "$hostname is in $domain.$tld"
# => "computer1 is in edvinlidholm.com"
```

---

## External Commands

### GNU userland tools

Avoid GNU-specific options for `awk`, `sed`, `grep`, etc. to stay portable across non-Linux/non-GNU systems. Bash builtins can usually replace the need for forking external commands for simple string manipulation.

### Useless Use of Cat Award

Don't use `cat(1)` when you don't need it, use redirection or let the program read the file directly.

```bash
# wrong
cat file | grep foo

# right
grep foo < file

# also right
grep foo file
```

---

## Style

### Quoting

Double quotes for strings requiring variable expansion or command substitution; single quotes for everything else.

```bash
# right
foo='Hello World'
bar="You are $USER"

# wrong
foo="hello world"

# possibly wrong, depending on intent
bar='You are $USER'
```

All variables that undergo word-splitting *must* be quoted. If no splitting will happen (e.g. inside `[[ ... ]]`, or on assignment), quotes aren't required but are still safe to add.

```bash
foo='hello world'

if [[ -n $foo ]]; then   # no quotes needed here
    echo "$foo"          # quotes needed here
fi

bar=$foo  # no quotes needed - assignment doesn't word-split
```

Exception: variables whose lifetime and content are fully controlled by the script (not user/command input) don't strictly need quoting. Special parameters like `$$`, `$?`, `$#` never need quotes since they can't contain spaces/tabs/newlines. When in doubt, [quote all expansions](http://mywiki.wooledge.org/Quotes).

### Variable Declaration

Avoid uppercase names unless they're constants or exported. Don't use `let` or `readonly` to create variables. `declare` should *only* be used for associative arrays. `local` should *always* be used in functions.

```bash
# wrong
declare -i foo=5
let foo++
readonly bar='something'
FOOBAR=baz

# right
i=5
((i++))
bar='something'
export FOOBAR=baz
```

### Shebang

Bash isn't always at `/bin/bash`, so prefer:

```bash
#!/usr/bin/env bash
```

Unless intentionally targeting a specific environment (e.g. `/bin/bash` on Linux servers with restricted `PATH`).

### Error Checking

Commands like `cd` can fail - always check and exit/break accordingly.

```bash
# wrong
cd /some/path # this could fail
rm file       # if cd fails where am I? what am I deleting?

# right
cd /some/path || exit
rm file
```

### Using `set -e`

Don't set `errexit`. Sometimes a failing command is expected and shouldn't exit the whole script. See [The Problem with Bash "strict mode"](https://www.youtube.com/watch?v=4Jo3Ml53kvc) and [BashFAQ105](http://mywiki.wooledge.org/BashFAQ/105).

### Using `eval`

Never. It opens code to injection and makes static analysis impossible. Use arrays, indirect expansion, or proper quoting instead.

---

## Common Mistakes

### Using `${f}` instead of quotes

`${f}` still undergoes word-splitting if unquoted, it is *not* a substitute for quoting.

```bash
for f in '1 space' '2  spaces' '3   spaces'; do
    echo ${f}   # wrong: loses extra spaces due to word-splitting
done

for f in '1 space' '2  spaces' '3   spaces'; do
    echo "$f"   # right: preserves spacing
done
```

Curly braces (`${VAR}`) should only be used to disambiguate the variable name, e.g. `"${USER}s home directory"` vs `"$USERs home directory"`.

### Abusing for-loops when while would work better

`for` loops are for iterating over arguments or arrays. Use `while read -r ...` for newline-separated data (e.g. file contents), since it streams instead of loading everything into memory and handles whitespace correctly.

```bash
# wrong - loads entire file into memory, breaks on spaces/tabs too
users=$(awk -F: '{print $1}' /etc/passwd)
for user in $users; do
    echo "user is $user"
done

# right - streams the file, splits only on the given delimiter
while IFS=: read -r user _; do
    echo "$user is user"
done < /etc/passwd
```

---

## References

- [Bash Style Guide (ysap.sh)](https://style.ysap.sh/)
- [BashGuide](https://mywiki.wooledge.org/BashGuide)
- [BashPitfalls](http://mywiki.wooledge.org/BashPitfalls)
- [Bash Practices](http://mywiki.wooledge.org/BashGuide/Practices)
