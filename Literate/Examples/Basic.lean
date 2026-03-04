-- -*- mode: markdown -*-

import Literate

# Comprehensive markdown coverage

> quoted line one
> quoted line two

- list item one
- list item two

*emphasis* markers * as * inline *

This line has punctuation : , . ; ! ? and brackets [ ref ] ( "https://example.com" )
This line has numbers 0 1 2 3 and path / docs / v1

`a`
`Literate.Examples.success`

~~~lean
namespace Literate.Examples

def success := "first fenced block"
#check success

/-
multiline comment in fenced Lean block
-/

end Literate.Examples
~~~

Interleaving prose after first fenced block

~~~lean
namespace Literate.Examples

def answer : Nat := 42
#check answer

example (x : Nat) : 0 < match x with
  | 0   => 1
  | n+1 => x + n := by
  grind

end Literate.Examples
~~~

Final prose line should be ignored

-- vim: set filetype=markdown :
