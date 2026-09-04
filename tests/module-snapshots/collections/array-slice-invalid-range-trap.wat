(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\03\00\01\01\00\00\00\00\00\00\00\00\01\00\03\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\02\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\81\81\b0\02\00\00\00\00\00\00\00\00\01\01\00\03\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\02\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\02\01\81\81\b0\02\00\00\00\00\00\00\00\00\01\01\01\00\00\01\00\00\01\00\00\02\1b\03\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\02\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\1d\02\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\02\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\00\02\01\02\01=\00\00\00\00\00\01\01\01\01\00\00\00\00\01\01\8d\80\fc\ff\0f\01\d7\80\80\80\d0\81\c0\ff\ff\01\01\b2\80\80\80\d0\81\c0\ff\ff\01\00\01\a9s\00\01c\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\8d\80\fc\ff\0f\01\d7\80\80\80\d0\81\c0\ff\ff\01\01\b2\80\80\80\d0\81\c0\ff\ff\01\00\01\a9s\00\00\00\00\00\02\01=\00\01\00\00\00\00\00\00\01\01\8d\80\fc\ff\0f\01\d7\80\80\80\d0\81\c0\ff\ff\01\01\b2\80\80\80\d0\81\c0\ff\ff\01\00\01\a9s\00\01c\00\04\08\00\00\00\00\00\01\01\8d\80\fc\ff\0f\01\d7\80\80\80\d0\81\c0\ff\ff\01\01\b2\80\80\80\d0\81\c0\ff\ff\01\00\01\a9s\00\00\00\02\04\02\06\00\00\00\00\00\01\01\01\01\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\02\0d\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\02_\00\00\00\00\00\01\01\01\01\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\02\9e\02\00\00\00\00\00\01\01\01\01\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\00\00\00\00\04\02\06\00\01\00\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\02\0d\00\04\08\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\02_\00\01\00\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\02\9e\02\00\01\00\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\14\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field eqref) (field (mut i32))))
  (type (;10;) (sub (struct (field funcref))))
  (type (;11;) (func (param eqref) (result eqref)))
  (type (;12;) (func (param eqref i32) (result eqref)))
  (type (;13;) (func (param eqref) (result (ref 8))))
  (type (;14;) (func (param eqref eqref) (result eqref)))
  (type (;15;) (func (param eqref)))
  (type (;16;) (func (param eqref i32)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref i32) (result i32)))
  (type (;19;) (func (param eqref eqref i32) (result eqref)))
  (type (;20;) (func (param eqref eqref) (result (ref 8))))
  (type (;21;) (func (param eqref eqref eqref) (result eqref)))
  (type (;22;) (func (param eqref eqref)))
  (type (;23;) (func (param eqref eqref i32)))
  (type (;24;) (func (param eqref eqref) (result i32)))
  (type (;25;) (func (param eqref eqref i32) (result i32)))
  (type (;26;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;27;) (func (param i32 i32 i32)))
  (type (;28;) (func (param (ref 8) i32 i32) (result (ref 8))))
  (type (;29;) (func (param (ref 8) i32 i32) (result (ref 8))))
  (type (;30;) (func))
  (type (;31;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;32;) (struct))
  (type (;33;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;34;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;35;) (struct (field (mut eqref)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 27) (param i32 i32 i32)
    local.get 1
    local.get 2
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      local.get 0
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;1;) (type 29) (param (ref 8) i32 i32) (result (ref 8))
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 8)
    struct.get 8 1
    local.get 1
    local.get 2
    call 0
    local.get 0
    local.get 1
    local.get 2
    local.set 4
    local.set 6
    local.set 3
    local.get 6
    local.get 4
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    local.get 3
    ref.cast (ref 8)
    struct.get 8 1
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    local.get 6
    i32.sub
    local.set 4
    local.get 4
    array.new_default 0
    local.set 5
    local.get 5
    ref.cast (ref 0)
    i32.const 0
    local.get 3
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 6
    local.get 4
    array.copy 0 0
    local.get 5
    local.get 4
    local.get 4
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;2;) (type 30)
    (local eqref eqref i32 eqref i32 i32)
    i32.const 8
    local.set 2
    local.get 2
    array.new_default 0
    i32.const 0
    local.get 2
    struct.new 8
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 8)
      struct.get 8 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 8)
        struct.get 8 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 8)
      struct.get 8 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      struct.set 8 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 8 2
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 4
    array.set 0
    local.get 1
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.const 1
    i32.add
    struct.set 8 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 8)
      struct.get 8 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 8)
        struct.get 8 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 8)
      struct.get 8 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      struct.set 8 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 8 2
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 5
    array.set 0
    local.get 1
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.const 1
    i32.add
    struct.set 8 1
    local.get 0
    ref.cast (ref 8)
    i32.const 0
    i32.const 4
    call 1
    drop
  )
)
