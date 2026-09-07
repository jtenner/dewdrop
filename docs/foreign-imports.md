# Foreign host imports

Use `foreign import` for functions supplied by the host:

```dew
foreign import "custom.host" as Host {
  fn send(value: I64) -> I32 = "send"
}

pub fn run(value: I64) -> I32 {
  Host.send(value)
}
```

The strings are the exact Wasm import module and field. This declaration emits
an import of `custom.host.send` with the signature `(i64) -> i32`. It does not
need a linked provider module. The host must supply a function with that ABI.
Foreign host calls retain exported linear memory for pointer-based interfaces.
Host namespaces cannot start with `link:`; that prefix is reserved for linked
providers and is rejected during collection.

`foreign impl "library" as Library` still means a statically linked Wasm
provider. Its emitted namespace is `link:library`. Both forms use the same
parameter, result, call-target, and operand checks. No standard-module path or
function name selects the host-import mode.

Foreign members cannot have bodies, generic parameters, or receivers. Their
namespace is private to the declaring module. A `pub` member exports the callable
through normal module imports. A library can also use ordinary public Dew
wrappers when it needs argument checks or other work. Give those wrappers and
their foreign members distinct Dew names.
