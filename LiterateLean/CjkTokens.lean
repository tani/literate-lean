import Lean
open Lean Elab Command Parser

namespace LiterateLean

def cjkvRanges : List (Nat × Nat) := [
  (0x3041, 0x3096),   -- ひらがな
  (0x30A1, 0x30FA),   -- カタカナ
  (0x30FC, 0x30FF),   -- 長音・踊り字
  (0x4E00, 0x9FFF),   -- CJK Unified (基本)
  (0x3400, 0x4DBF),   -- CJK Ext A
  (0x20000, 0x323AF), -- CJK Ext B ~ I (拡張漢字)
  (0xF900, 0xFAFF),   -- CJK Compatibility
  (0xAC00, 0xD7AF),   -- Hangul Syllables
  (0x1100, 0x11FF),   -- Jamo
  (0x3130, 0x318F),   -- Compatibility Jamo
  (0xA960, 0xA97F),   -- Jamo Ext A
  (0xD7B0, 0xD7FF),   -- Jamo Ext B
  (0x0100, 0x024F),   -- Latin Ext A & B
  (0x1E00, 0x1EFF),   -- Latin Extended Additional
  (0xA720, 0xA7FF),   -- Latin Extended-D
  (0x3000, 0x303F),   -- 全角スペース、、。、「」など
  (0x2E80, 0x2FDF),   -- CJK 部首補助・康熙部首
  (0x3200, 0x32FF),   -- 囲み文字
  (0x3300, 0x33FF),   -- CJK 互換文字
  (0xFF01, 0xFFEF)    -- 全角英数および全角記号
]

elab "add_cjk_tokens" : command => do
  for (s, e) in cjkvRanges do
    for i in [s:e+1] do
      let c := Char.ofNat i
      liftCoreM <| Lean.Parser.addToken c.toString .global

add_cjk_tokens

end LiterateLean
