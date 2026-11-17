---
name: literate-lean
description: Write or convert Lean 4 files into literate documents using LiterateLean, with Markdown prose interleaved with checked Lean code. Use when the user requests literate Lean source or work with tani/literate-lean.
---

# Literate Lean

Produce `.lean` files that read as Markdown and compile as Lean. Keep explanatory prose outside code fences and executable declarations, proofs, and commands inside explicit Lean fences.

## Project setup

Inspect the target project's `lean-toolchain` and Lake configuration before adding a dependency. This checkout targets `leanprover/lean4:v4.32.0`; do not silently change an existing project's toolchain to match it.

If LiterateLean is absent, add it to the target project's `lakefile.toml`:

```toml
[[require]]
name = "LiterateLean"
git = "https://github.com/tani/literate-lean.git"
rev = "main"
```

Preserve an existing dependency revision. For a `lakefile.lean` project, express the same requirement using that file's existing Lake DSL conventions. Run `lake update` when adding the dependency to resolve it and update the manifest.

## File structure

Indent header commands by four spaces so Markdown displays them as an implicit code block. Put imports before the literate content and explicitly enable the syntax with `open scoped LiterateLean` in each file that needs it.

Start each literate source file with the indented Lean comment `    /- -*- mode: markdown; -*- -/` to select Markdown mode in Emacs. End the file with `<!-- vim: set filetype=markdown : -->` after all Lean fences to select Markdown syntax in Vim.

~~~~markdown
    /- -*- mode: markdown; -*- -/
    import LiterateLean
    open scoped LiterateLean

# A checked result

The definition and its proof are checked by Lean.

```lean
def answer : Nat := 42

example : answer = 42 := by
  rfl
```

<!-- vim: set filetype=markdown : -->
~~~~

- Use a line beginning with exactly three backticks followed by `lean` to open executable code, followed by whitespace or a newline. Close it with three backticks. Keep fence lines unindented and omit extra language attributes.
- Put every intended executable command after the header inside a Lean fence. Markdown scanning skips prose until the next recognized Lean fence; unfenced Lean text can be ignored instead of checked.
- Keep explanations outside Lean fences. Inside them, ordinary Lean parsing and elaboration apply; invalid code and unterminated fences must fail.
- Labels such as `leaning`, other language fences, and ordinary Markdown are prose, not checked Lean. Avoid placing an executable `lean` fence inside a prose example that should remain inert.
- When converting existing source, preserve declaration order, namespace and section boundaries, visibility, and proof meaning. Multiple Lean fences elaborate sequentially in the same file.

## Library visibility

For a library using Lean's module system, keep the implementation's LiterateLean import private when downstream modules should remain ordinary Lean:

~~~~markdown
    /- -*- mode: markdown; -*- -/
    module

    import LiterateLean
    public import Lean
    open scoped LiterateLean

    public section

# Implementation

```lean
def answer : Nat := 42
```

<!-- vim: set filetype=markdown : -->
~~~~

A façade can use `public import MyLibrary.Basic` to re-export declarations. Importing a façade does not activate the literate parser; downstream files must explicitly open the scope if they want Markdown syntax.

## Verification

Run `lake build`, then `lake env lean path/to/ChangedFile.lean` for literate files not included in the build targets. Check that each declaration and proof intended for verification is inside a recognized Lean fence; a successful compiler run alone cannot detect code accidentally swallowed as prose.

When changing LiterateLean itself, also run `lake test` and `lake env lean LiterateLean/Examples/Basic.lean`. The tests cover accepted prose, ordinary imports, disabled scope, invalid fenced Lean, and unterminated fences.

Consult the bundled [README](README.md) for source conventions, [example](LiterateLean/Examples/Basic.lean) for supported Markdown, and [parser implementation](LiterateLean/Basic.lean) when investigating syntax behavior. Resolve these links relative to this skill directory, not the target project.
