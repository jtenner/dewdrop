(module
  ;; Inline builtin signatures. The builtins themselves consume no function
  ;; indices because calls to them lower directly to Wasm instructions.
  (type (;0;) (func (param i32 i32) (result i32))) ;; i32_add
  (type (;1;) (func (param i32 i32) (result i32))) ;; i32_sub
  (type (;2;) (func (param i32 i32) (result i32))) ;; i32_lte

  ;; Erased trait requirement signatures. These remain in the current type
  ;; section even though the statically selected calls need no dictionaries.
  (type (;3;) (func (param eqref eqref) (result eqref))) ;; Add::add
  (type (;4;) (func (param eqref eqref) (result eqref))) ;; Sub::sub
  (type (;5;) (func (param eqref eqref) (result i32)))   ;; Lte::lte

  ;; Concrete I32 implementation signatures. Their module-visible wrapper
  ;; functions were directized and elided from the function/code sections.
  (type (;6;) (func (param i32 i32) (result i32))) ;; Add for I32
  (type (;7;) (func (param i32 i32) (result i32))) ;; Sub for I32
  (type (;8;) (func (param i32 i32) (result i32))) ;; Lte for I32

  ;; fib(I32) -> I32
  (type (;9;) (func (param i32) (result i32)))

  (export "fib" (func 0))

  (func (;0;) (type 9) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.le_s
    if (result i32)
      local.get 0
    else
      local.get 0
      i32.const 1
      i32.sub
      call 0

      local.get 0
      i32.const 2
      i32.sub
      call 0

      i32.add
    end
  )
)
