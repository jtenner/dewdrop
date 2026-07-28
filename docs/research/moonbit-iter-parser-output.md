# MoonBit `Iter` and parser output design

Date: 2026-07-28

## Finding

MoonBit's `Iter` is lazy: iterator work runs when the consumer pulls values. The language documentation warns that eager control-flow and error propagation cannot automatically cross this lazy boundary.

Relevant official documentation:

- https://docs.moonbitlang.com/en/stable/language/error_codes/E4211.html
- https://docs.moonbitlang.com/en/latest/language/fundamentals.html

## Dew design consequence

Returning two lazy iterators backed by one parser creates an ownership and buffering problem. If the consumer advances declarations but not diagnostics, the parser must retain diagnostics. If the consumer advances diagnostics first, it may need to parse and retain declarations. Memory then depends on consumption order and can grow to the size of the input.

A single event iterator avoids this problem:

```dew
enum ParseEvent {
  Declaration(Declaration)
  Diagnostic(Diagnostic)
}

fn parse(tokens: Iter[Token]) -> Iter[ParseEvent]
```

The parser emits each declaration or diagnostic as soon as it is available. It does not buffer one output channel for another. Consumers choose what to retain. This keeps the core parser API lazy, deterministic, and bounded by parser state plus the current event, excluding separately retained source/token data.

Convenience adapters may route events to callbacks or collections, but they should not replace the single event stream as the core low-memory interface.
