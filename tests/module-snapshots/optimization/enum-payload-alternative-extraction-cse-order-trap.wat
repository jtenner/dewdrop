(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\04\00\01\01\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\01\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\02\01\01\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\03\01\81\81\90\02\00\00\00\00\00\00\00\00\01\03\00\01\02\00\00\01\00\00\01\00\00\00\00\00\00\01\03\01\03\0e\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\bf\01\00\00\00\00\00\01\03\0e\00\04\09\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\bf\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32) (field i32))))
  (type (;10;) (func (param (ref 8)) (result (ref 8))))
  (type (;11;) (func (result i32)))
  (type (;12;) (func (result i32)))
  (type (;13;) (func (result i32)))
  (export "main" (func 3))
  (func (;0;) (type 10) (param (ref 8)) (result (ref 8))
    local.get 0
    ref.cast (ref 8)
  )
  (func (;1;) (type 11) (result i32)
    unreachable
  )
  (func (;2;) (type 12) (result i32)
    i32.const 1
    i32.const 0
    i32.div_s
  )
  (func (;3;) (type 13) (result i32)
    (local i32 i32 i32 i32 eqref i32 i32 i32)
    call 1
    local.set 6
    call 2
    local.set 7
    i32.const 0
    local.get 6
    local.get 7
    struct.new 9
    call 0
    local.set 4
    block ;; label = @1
      local.get 4
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 4
        ref.cast (ref 9)
        struct.get 9 1
        local.set 0
        i32.const 1
        if (result i32) ;; label = @3
          local.get 4
          ref.cast (ref 9)
          struct.get 9 2
          local.set 1
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 4
        ref.cast (ref 8)
        struct.get 8 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          local.get 4
          ref.cast (ref 9)
          struct.get 9 1
          local.set 0
          i32.const 1
          if (result i32) ;; label = @4
            local.get 4
            ref.cast (ref 9)
            struct.get 9 2
            local.set 1
            i32.const 1
          else
            i32.const 0
          end
        else
          i32.const 0
        end
      end
      if ;; label = @2
        local.get 0
        i32.const 0
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 1
          i32.const 1
          i32.add
        else
          local.get 1
        end
        local.set 5
        br 1 (;@1;)
      end
      local.get 4
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 2
      i32.eq
      if ;; label = @2
        i32.const 0
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
)
