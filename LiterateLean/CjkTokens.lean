import Lean
open Lean Elab Command Parser

namespace LiterateLean

def cjkvRanges : List (Nat × Nat) := [
  (0x00A1, 0xD7FF),
  (0xE000, 0x10FFFF)
]

elab "add_cjk_tokens" : command => do
  for (s, e) in cjkvRanges do
    for i in [s:e+1] do
      -- Filter out ASCII / control characters to not break built-in parser identifiers like `c`, `s`
      if i > 0x00A0 then
        let ch := Char.ofNat i
        liftCoreM <| Lean.Parser.addToken ch.toString .global

add_cjk_tokens

end LiterateLean
