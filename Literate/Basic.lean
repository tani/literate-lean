import Lean

open Lean Elab Command

/-!
# Literate

Lean command syntax for literate-programming style documents:
- `~~~lean ... ~~~` executes enclosed Lean commands.
- Markdown-like prose lines are accepted as no-op commands.

This lets a `.lean` file mix prose and executable Lean snippets.
-/

namespace Literate

/--
A fenced Lean command block. Every inner command is elaborated in order.
-/
syntax (name := leanFence) "~~~lean" command* "~~~" : command

@[command_elab leanFence]
def elabLeanFence : CommandElab := fun stx =>
  match stx with
  | `(command| ~~~lean $cmds* ~~~) =>
      for cmd in cmds do
        elabCommand cmd
  | _ => throwError "invalid Lean fenced block"

/-- Markdown heading line, ignored by elaboration. -/
syntax (name := markdownHeading) "#" (ident)* : command

/-- Explicit placeholder command token, ignored by elaboration. -/
syntax (name := anyTextCommand) "any_text" : command

/--
General markdown prose line formed by identifiers.
These lines are accepted and ignored.
-/
syntax (name := markdownTextGeneral) (ident)+ : command

@[command_elab markdownHeading]
def elabMarkdownHeading : CommandElab := fun _ => pure ()

@[command_elab anyTextCommand]
def elabAnyTextCommand : CommandElab := fun _ => pure ()

@[command_elab markdownTextGeneral]
def elabMarkdownTextGeneral : CommandElab := fun _ => pure ()

end Literate
