---
name: aos-debugging
description: A structured debugging loop for tracking down a bug, failing test, exception, stack trace, regression, or "this used to work" report. Use proactively when investigating why code is broken, reproducing a failure, or diagnosing unexpected behavior — before changing any code. Prevents guess-driven editing by forcing reproduction, hypothesis, and a single verified fix.
---

# Diagnosing bugs

This is a model-invoked discipline. When something is broken, resist the urge to start
editing. Work the loop.

## 1. Reproduce first

- Get a deterministic reproduction: the exact command, input, and expected vs. actual.
- If you cannot reproduce it, say so and gather more signal (logs, a failing test, the
  stack trace) before touching code.
- Capture the smallest reproduction you can — a failing unit test is ideal.

## 2. Locate, don't guess

- Read the stack trace top-down to the first frame in our code.
- Read the actual source at that location — do not assume what it does.
- Form **one** hypothesis at a time, stated concretely: "X is null because Y returns early
  when Z."

## 3. Confirm the hypothesis before fixing

- Prove it with a log, a breakpoint, a test, or by reading the data flow end to end.
- If the evidence contradicts the hypothesis, discard it and form a new one. Do not stack
  speculative fixes.

## 4. Fix at the root, once

- Change the smallest thing that addresses the root cause — not the symptom.
- No shotgun edits, no "try this and see." One deliberate change.
- If the fix touches business logic, keep it in the service layer (see
  [aos-implementing-features](../aos-implementing-features/SKILL.md)).

## 5. Verify and lock it in

- Re-run the reproduction. Confirm it now passes.
- Add a regression test that would have caught this bug, so it stays fixed.
- Run the surrounding test suite to confirm nothing else broke.

## Anti-patterns to avoid

- Editing multiple files hoping one sticks.
- "Fixing" by adding a null-check at the symptom while the real cause is upstream.
- Removing a failing assertion instead of fixing the behavior.
- Declaring it fixed without re-running the reproduction.
