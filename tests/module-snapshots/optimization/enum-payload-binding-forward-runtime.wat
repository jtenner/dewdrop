(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\02\00\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\01\01\81\81\90\02\00\00\00\00\00\00\00\00\01\01\00\00\00\01\00\00\01\00\00\00\00\00\00\01\00\01\00\08\00\00\00\00\00\01\01\01\01\00\00\09\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01#\00\00\00\00\00\01\00\08\00\04\09\00\00\00\00\00\01\01\b8\17\01\81\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01#\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32))))
  (type (;10;) (func (param i32) (result (ref 8))))
  (type (;11;) (func (result i32)))
  (export "main" (func 1))
  (func (;0;) (type 10) (param i32) (result (ref 8))
    (local (ref null 8) i32 i32 i32)
    local.get 0
    local.set 3
    i32.const 0
    local.get 3
    struct.new 9
    ref.cast (ref 8)
  )
  (func (;1;) (type 11) (result i32)
    (local i32 eqref i32)
    i32.const 42
    call 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 1
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          ref.cast (ref 9)
          struct.get 9 1
          local.set 0
          local.get 0
          local.set 2
          br 2 (;@1;)
        end
        i32.const 0
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
)
