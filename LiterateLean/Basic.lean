module

public import Lean
public meta import Lean
public meta import LiterateLean.Internal.Unicode

public section

open Lean Elab Command Parser

namespace LiterateLean

meta def Internal.fencedCommandBody : Parser :=
  withForbidden "```" (categoryParser `command 0)

scoped syntax (name := leanFence) "```lean" Internal.fencedCommandBody* "```" : command

open scoped LiterateLean

namespace Internal

-- Lean fenced commands

@[command_elab leanFence]
meta def elabLeanFence : CommandElab
  | `(command| ```lean $cmds* ```) => cmds.forM elabCommand
  | _ => throwError "invalid Lean fenced block"

-- Markdown scanning

private meta partial def endOfPrefix?
    (c : ParserContext) (inputPos : String.Pos.Raw) (needle : String) : Option String.Pos.Raw :=
  let rec loop (inputPos needlePos : String.Pos.Raw) : Option String.Pos.Raw :=
    if hNeedle : needlePos.atEnd needle then
      some inputPos
    else if hInput : c.atEnd inputPos then
      none
    else if c.get' inputPos hInput == needlePos.get' needle hNeedle then
      loop (c.next' inputPos hInput) (needlePos.next' needle hNeedle)
    else
      none
  loop inputPos 0

private meta def hasDelimitedPrefix
    (c : ParserContext) (i : String.Pos.Raw) (needle : String) : Bool :=
  match endOfPrefix? c i needle with
  | none => false
  | some i => if h : c.atEnd i then true else (c.get' i h).isWhitespace

private meta def isNewline (c : ParserContext) (i : String.Pos.Raw) : Bool :=
  if h : c.atEnd i then false else c.get' i h == '\n'

/- Skip prose in one pass, stopping only at a Lean fence at the beginning of a line. -/
private meta partial def skipMarkdownFn (lineStart consumed : Bool) : ParserFn := fun c s =>
  let i := s.pos
  if lineStart && hasDelimitedPrefix c i "```lean" then
    if consumed then s else s.mkUnexpectedError "expected markdown text"
  else if h : c.atEnd i then
    if consumed then s else s.mkEOIError
  else
    let isNl := isNewline c i
    skipMarkdownFn isNl true c (s.next' c i h)

-- Markdown-leading tokens

meta def markdownUnicode : Parser := withFn (fun _ => markdownUnicodeFn) skip

meta def markdownPunctuation : Parser :=
  symbol "!" <|> symbol "\"" <|> symbol "#" <|> symbol "$" <|> symbol "%" <|> symbol "&" <|>
  symbol "'" <|> symbol "(" <|> symbol ")" <|> symbol "*" <|> symbol "+" <|> symbol "," <|>
  symbol "-" <|> symbol "." <|> symbol "/" <|> symbol ":" <|> symbol ";" <|> symbol "<" <|>
  symbol "=" <|> symbol ">" <|> symbol "?" <|> symbol "@" <|> symbol "[" <|> symbol "\\" <|>
  symbol "]" <|> symbol "^" <|> symbol "_" <|> symbol "`" <|> symbol "{" <|> symbol "|" <|>
  symbol "}" <|> symbol "~"

-- `public` is reserved, so list it explicitly to allow non-command prose using the word.
meta def markdownStartToken : Parser := leading_parser
  symbol "public" <|> markdownPunctuation <|> rawCh '`' <|> ident <|> rawIdent <|>
  numLit <|> strLit <|> charLit <|> scientificLit <|> markdownUnicode

-- Markdown command parser

private meta def markdownBlockParserFn : ParserFn := fun c s =>
  let i := s.pos
  if c.forbiddenTk? == some "```" then
    s.mkUnexpectedError "expected Lean command"
  -- Once the literate scope is open, this module command must still reach Lean's parser.
  else if hasDelimitedPrefix c i "public section" then
    s.mkUnexpectedError "expected Lean command"
  else if hasDelimitedPrefix c i "```lean" then
    s.mkUnexpectedError "expected markdown text"
  else
    skipMarkdownFn true false c s

meta def markdownBlock : Parser := leading_parser
  lookahead markdownStartToken >> withFn (fun _ => markdownBlockParserFn) skip

end Internal

attribute [scoped command_parser] Internal.markdownBlock

@[command_elab Internal.markdownBlock]
meta def Internal.elabMarkdownBlock : CommandElab := fun _ => pure ()

end LiterateLean
