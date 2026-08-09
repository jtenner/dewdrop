(module
  (rec
    (type (;0;) (func (param eqref) (result i32)))
  )
  (rec
    (type (;1;) (struct (field (ref null 0))))
  )
  (rec
    (type (;2;) (struct (field eqref) (field (ref 1))))
  )
  (type (;3;) (func (param i32) (result i32)))
  (type (;4;) (func (param i32 eqref) (result eqref)))
  (type (;5;) (func (param i32 i32) (result eqref)))
  (type (;6;) (func (param eqref) (result i32)))
  (type (;7;) (func (result i32)))
  (type (;8;) (struct (field i32)))
  (type (;9;) (func))
  (global (;0;) (mut (ref null 1)) ref.null 1)
  (export "main" (func 4))
  (export "__dew_init" (func 5))
  (elem (;0;) declare func 2)
  (func (;0;) (type 3) (param i32) (result i32)
    local.get 0
  )
  (func (;1;) (type 5) (param i32 i32) (result eqref)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
    end
    struct.new 8
    global.get 0
    ref.cast (ref 1)
    struct.new 2
  )
  (func (;2;) (type 0) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 8)
    struct.get 8 0
    call 0
  )
  (func (;3;) (type 6) (param eqref) (result i32)
    (local eqref)
    local.get 0
    local.tee 1
    ref.cast (ref 2)
    struct.get 2 0
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    struct.get 1 0
    call_ref 0
  )
  (func (;4;) (type 7) (result i32)
    i32.const 1
    i32.const 42
    call 1
    call 3
  )
  (func (;5;) (type 9)
    ref.func 2
    struct.new 1
    global.set 0
  )
)
