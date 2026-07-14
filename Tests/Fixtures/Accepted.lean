module

public import LiterateLean
open scoped LiterateLean

public section

public sectional notes are markdown, not a module command
```leaning is another markdown fence marker

今日は良い天気です。

```lean
public def testedAnswer : Nat := 42

example : testedAnswer = 42 := rfl
```

Prose at the end of the file is ignored.
