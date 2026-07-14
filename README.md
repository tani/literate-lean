# LiterateLean for Lean 4

`literate-lean` is a small Lean 4 library for literate-programming style source files.
It allows markdown-like prose in Lean files while executing explicit ```` ```lean ```` fenced blocks.
This is a practical example of a [polyglot](https://en.wikipedia.org/wiki/Polyglot_(computing)) source style.

LiterateLean 3 targets Lean 4.32, uses Lean's module system, and requires
`open scoped LiterateLean` in files that enable the literate syntax.

<img alt="image" src="https://github.com/user-attachments/assets/6534c42a-7009-4117-9ace-b92ea7afa69b" />

## Features

- ```` ```lean...``` ```` command blocks are elaborated as normal Lean commands.
- Markdown heading lines like `# Heading text` are accepted and ignored.
- Plain prose lines composed of identifiers are accepted and ignored.

## Install

Add this package to your `lakefile.toml`:

```toml
[[require]]
name = "LiterateLean"
git = "https://github.com/tani/literate-lean.git"
rev = "main"
```

Then import it and open its syntax scope:

```lean
import LiterateLean
open scoped LiterateLean
```

## Usage

### Source convention

As a convention, indent the header of a LiterateLean file by four spaces. This
includes commands such as `module`, `import`, `public import`, and
`public section`, as well as `open scoped LiterateLean`, which explicitly enables
the literate syntax. Markdown then displays the header as an indented (implicit)
code block, while Lean accepts the indentation normally. This is a gentleman's
agreement for keeping LiterateLean sources readable as both Lean and Markdown.

~~~lean
    import LiterateLean
    open scoped LiterateLean

# This heading is ignored

This line is prose and is ignored

```lean
namespace Demo

def success := "This was evaluated!"
#check success

end Demo
```
~~~

## Private imports

With Lean's module system, a library can use LiterateLean for its implementation
without exposing the Markdown command parser to downstream modules:

~~~lean
    module

    import LiterateLean
    public import Lean
    open scoped LiterateLean

    public section

# Literate library implementation

```lean
def answer : Nat := 42
```
~~~

A public façade can re-export those declarations while keeping LiterateLean private:

```lean
module

public import MyLibrary.Basic
```

The Markdown parser is scoped, so importing the façade does not activate it.
Only files that explicitly use `open scoped LiterateLean` accept Markdown prose.

Downstream files can then remain ordinary Lean:

```lean
import MyLibrary

#eval answer
```

## Development

```bash
lake build
lake env lean LiterateLean/Examples/Basic.lean
```

## Copyright

Copyright (c) 2025-2026 Taniguchi Masaya. All Right Reserved.
