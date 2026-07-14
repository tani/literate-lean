module

public meta import Lean

public section

open Lean Parser

namespace LiterateLean.Internal

private meta def markdownUnicodeRanges : List (Nat × Nat) := [
  -- Hangul Jamo
  (0x1100, 0x11FF),
  -- Enclosed Alphanumerics
  (0x2460, 0x24FF),
  -- Geometric Shapes
  (0x25A0, 0x25FF),
  -- CJK Radicals Supplement
  (0x2E80, 0x2EFF),
  -- Kangxi Radicals
  (0x2F00, 0x2FDF),
  -- Ideographic Description Characters
  (0x2FF0, 0x2FFF),
  -- CJK Symbols and Punctuation
  (0x3000, 0x303F),
  -- Hiragana
  (0x3040, 0x309F),
  -- Katakana
  (0x30A0, 0x30FF),
  -- Bopomofo
  (0x3100, 0x312F),
  -- Hangul Compatibility Jamo
  (0x3130, 0x318F),
  -- Kanbun
  (0x3190, 0x319F),
  -- Bopomofo Extended
  (0x31A0, 0x31BF),
  -- CJK Strokes
  (0x31C0, 0x31EF),
  -- Katakana Phonetic Extensions
  (0x31F0, 0x31FF),
  -- Enclosed CJK Letters and Months
  (0x3200, 0x32FF),
  -- CJK Compatibility
  (0x3300, 0x33FF),
  -- CJK Unified Ideographs Extension A
  (0x3400, 0x4DBF),
  -- Yijing Hexagram Symbols
  (0x4DC0, 0x4DFF),
  -- CJK Unified Ideographs
  (0x4E00, 0x9FFF),
  -- Yi Syllables
  (0xA000, 0xA48F),
  -- Yi Radicals
  (0xA490, 0xA4CF),
  -- Hangul Jamo Extended-A
  (0xA960, 0xA97F),
  -- Hangul Syllables
  (0xAC00, 0xD7AF),
  -- Hangul Jamo Extended-B
  (0xD7B0, 0xD7FF),
  -- CJK Compatibility Ideographs
  (0xF900, 0xFAFF),
  -- Halfwidth and Fullwidth Forms
  (0xFF00, 0xFFEF),
  -- Ideographic Symbols and Punctuation
  (0x16FE0, 0x16FFF),
  -- Kana Supplement
  (0x1B000, 0x1B0FF),
  -- Kana Extended-A
  (0x1B100, 0x1B12F),
  -- Small Kana Extension
  (0x1B130, 0x1B16F),
  -- Enclosed Alphanumeric Supplement
  (0x1F100, 0x1F1FF),
  -- Enclosed Ideographic Supplement
  (0x1F200, 0x1F2FF),
  -- CJK Unified Ideographs Extension B
  (0x20000, 0x2A6DF),
  -- CJK Unified Ideographs Extension C
  (0x2A700, 0x2B73F),
  -- CJK Unified Ideographs Extension D
  (0x2B740, 0x2B81F),
  -- CJK Unified Ideographs Extension E
  (0x2B820, 0x2CEAF),
  -- CJK Unified Ideographs Extension F
  (0x2CEB0, 0x2EBEF),
  -- CJK Unified Ideographs Extension I
  (0x2EBF0, 0x2EE5F),
  -- CJK Compatibility Ideographs Supplement
  (0x2F800, 0x2FA1F),
  -- CJK Unified Ideographs Extension G
  (0x30000, 0x3134F),
  -- CJK Unified Ideographs Extension H
  (0x31350, 0x323AF),
  -- CJK Unified Ideographs Extension J
  (0x323B0, 0x3347F)
]

private meta def registerMarkdownUnicodeTokens : CoreM Unit := do
  for (s, e) in markdownUnicodeRanges do
    for i in [s:e+1] do
      let ch := Char.ofNat i
      Lean.Parser.addToken ch.toString .global

-- The leading parser must know these characters as tokens before literate files are parsed.
run_meta registerMarkdownUnicodeTokens

private meta def isMarkdownUnicode (c : Char) : Bool :=
  let v := c.val.toNat
  markdownUnicodeRanges.any fun (s, e) => s ≤ v && v ≤ e

meta def markdownUnicodeFn : ParserFn :=
  satisfyFn isMarkdownUnicode "CJKV character"

end LiterateLean.Internal
