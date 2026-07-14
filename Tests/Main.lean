import Lean

structure TestCase where
  path : String
  shouldSucceed : Bool

private def runTest (test : TestCase) : IO Bool := do
  let output ← IO.Process.output {
    cmd := "lake"
    args := #["env", "lean", test.path]
  }
  let succeeded := output.exitCode == 0
  if succeeded == test.shouldSucceed then
    IO.println s!"PASS {test.path}"
    return true
  else
    let expectation := if test.shouldSucceed then "succeed" else "fail"
    IO.eprintln s!"FAIL {test.path}: expected Lean to {expectation}"
    if !output.stdout.isEmpty then IO.eprintln output.stdout
    if !output.stderr.isEmpty then IO.eprintln output.stderr
    return false

def main : IO UInt32 := do
  let tests : Array TestCase := #[
    ⟨"Tests/Fixtures/Accepted.lean", true⟩,
    ⟨"Tests/Fixtures/OrdinaryImport.lean", true⟩,
    ⟨"Tests/Fixtures/ScopeDisabled.lean", false⟩,
    ⟨"Tests/Fixtures/UnterminatedFence.lean", false⟩,
    ⟨"Tests/Fixtures/InvalidLean.lean", false⟩
  ]
  let mut failed := false
  for test in tests do
    if !(← runTest test) then failed := true
  return if failed then 1 else 0
