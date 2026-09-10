(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\0a\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\01\01\81\81\80\02\00\00\00\00\00\00\00\00\01\01\03\00\00\01\01\00\00\00\00\02\01\85\81\90\02\00\00\00\00\00\00\00\00\01\01\04\02\00\00\01\7f\01\ff\01\01\00\01\7f\00\00\01\01\00\00\00\00\03\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\04\01\85\81\90\02\00\00\00\00\00\00\00\00\01\02\05\06\02\00\00\01\7f\01\ff\01\01\00\01\7f\00\00\01\01\00\00\00\00\05\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\06\01\85\81\90\02\00\00\00\00\00\00\00\00\01\02\00\07\03\00\00\01\7f\01\ff\01\01\00\01\7f\00\02\00\01\7f\00\00\01\01\00\00\00\00\07\01\00\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\08\01\81\81\80\02\00\00\00\00\00\00\00\00\01\01\01\00\00\01\01\00\00\00\00\09\01\85\81\90\02\00\00\00\00\00\00\00\00\01\02\02\08\00\00\01\00\00\01\00\00\02 \01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00,\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\02\03\03\03\04\00\00\00\00\00\01\01\01\01\00\00\0a\00\01\01\8b\80\fc\ff\0f\01\88\80\80\80\b0\81\c0\ff\ff\01\01\83\80\80\80\b0\81\c0\ff\ff\01\00\01\83\0a\00\03\0f\00\00\00\00\00\01\01\01\01\00\00\05\00\01\01\8b\80\fc\ff\0f\01\88\80\80\80\b0\81\c0\ff\ff\01\01\83\80\80\80\b0\81\c0\ff\ff\01\00\01\83\0a\00\03\1f\00\00\00\00\00\01\01\01\01\00\00\1c\00\01\01\8b\80\fc\ff\0f\01\88\80\80\80\b0\81\c0\ff\ff\01\01\83\80\80\80\b0\81\c0\ff\ff\01\00\01\83\0a\00\00\00\00\00\03\03\04\00\04\0a\00\00\00\00\00\01\01\8b\80\fc\ff\0f\01\88\80\80\80\b0\81\c0\ff\ff\01\01\83\80\80\80\b0\81\c0\ff\ff\01\00\01\83\0a\00\03\0f\00\01\05\00\00\00\00\00\01\01\8b\80\fc\ff\0f\01\88\80\80\80\b0\81\c0\ff\ff\01\01\83\80\80\80\b0\81\c0\ff\ff\01\00\01\83\0a\00\03\1f\00\04\1c\00\00\00\00\00\01\01\8b\80\fc\ff\0f\01\88\80\80\80\b0\81\c0\ff\ff\01\01\83\80\80\80\b0\81\c0\ff\ff\01\00\01\83\0a\00\00\00\06\02\06=\00\00\00\00\00\01\01\01\01\00\00\0a\00\01\01\8b\80\fc\ff\0f\01\8b\80\80\80\b0\81\c0\ff\ff\01\01\86\80\80\80\b0\81\c0\ff\ff\01\00\01\e1\0c\00\06\95\01\00\00\00\00\00\01\01\01\01\00\00\0c\00\01\01\8b\80\fc\ff\0f\01\8b\80\80\80\b0\81\c0\ff\ff\01\01\86\80\80\80\b0\81\c0\ff\ff\01\00\01\e1\0c\00\00\00\00\00\02\06=\00\04\0a\00\00\00\00\00\01\01\8b\80\fc\ff\0f\01\8b\80\80\80\b0\81\c0\ff\ff\01\01\86\80\80\80\b0\81\c0\ff\ff\01\00\01\e1\0c\00\06\95\01\00\04\0c\00\00\00\00\00\01\01\8b\80\fc\ff\0f\01\8b\80\80\80\b0\81\c0\ff\ff\01\01\86\80\80\80\b0\81\c0\ff\ff\01\00\01\e1\0c\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i64) (result i64)))
  (type (;9;) (func (param i32) (result i32)))
  (type (;10;) (sub (struct (field i32))))
  (type (;11;) (sub final 10 (struct (field i32) (field i32))))
  (type (;12;) (sub final 10 (struct (field i32) (field eqref))))
  (type (;13;) (sub (struct (field funcref))))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result eqref)))
  (type (;16;) (func (param eqref eqref) (result eqref)))
  (type (;17;) (func (param eqref)))
  (type (;18;) (func (param eqref i32)))
  (type (;19;) (func (param eqref) (result i32)))
  (type (;20;) (func (param eqref i32) (result i32)))
  (type (;21;) (func (param eqref eqref i32) (result eqref)))
  (type (;22;) (func (param eqref eqref eqref) (result eqref)))
  (type (;23;) (func (param eqref eqref)))
  (type (;24;) (func (param eqref eqref i32)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func (param eqref eqref i32) (result i32)))
  (type (;27;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;28;) (struct (field (mut (ref 5))) (field (mut i32))))
  (type (;29;) (struct (field (mut (ref 10))) (field i64) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (type (;30;) (func (param eqref) (result i64)))
  (type (;31;) (func (param eqref eqref) (result i32)))
  (type (;32;) (func (param i64 i32) (result i32)))
  (type (;33;) (func (result (ref 28))))
  (type (;34;) (func (param (ref 28) eqref i64) (result (ref 10))))
  (type (;35;) (func (param (ref 28) eqref) (result eqref)))
  (type (;36;) (func (result (ref 28))))
  (type (;37;) (func (param (ref 28) eqref) (result eqref)))
  (type (;38;) (func (result (ref 28))))
  (type (;39;) (func (param (ref 28) i32) (result i32)))
  (type (;40;) (func (result (ref 28))))
  (type (;41;) (func (param (ref 28) i32) (result i32)))
  (type (;42;) (func (param i32) (result i64)))
  (type (;43;) (func (param (ref 28) i32 i64) (result (ref 10))))
  (type (;44;) (func (param i32 i32) (result i32)))
  (type (;45;) (func (result (ref 28))))
  (type (;46;) (func))
  (export "main" (func 9))
  (func (;0;) (type 32) (param i64 i32) (result i32)
    (local i32)
    local.get 1
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      local.get 1
      i32.const 1
      i32.sub
      i32.and
      i32.const 0
      i32.ne
    end
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      i32.wrap_i64
      local.set 2
      local.get 2
      local.get 1
      i32.const 1
      i32.sub
      i32.and
    end
  )
  (func (;1;) (type 38) (result (ref 28))
    call 3
    ref.cast (ref 28)
  )
  (func (;2;) (type 39) (param (ref 28) i32) (result i32)
    local.get 0
    ref.cast (ref 28)
    local.get 1
    call 4
  )
  (func (;3;) (type 40) (result (ref 28))
    (local eqref i32 eqref i32)
    i32.const 16
    i32.const 0
    struct.new 10
    local.set 0
    local.set 1
    local.get 0
    local.get 1
    array.new 5
    local.set 2
    i32.const 0
    local.set 3
    local.get 2
    ref.cast (ref 5)
    local.get 3
    struct.new 28
    ref.cast (ref 28)
  )
  (func (;4;) (type 41) (param (ref 28) i32) (result i32)
    (local (ref null 29) eqref i32)
    local.get 0
    ref.cast (ref 28)
    local.get 1
    local.get 1
    call 5
    call 6
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 10)
            struct.get 10 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 12)
        struct.get 12 1
        ref.cast (ref 29)
        local.set 2
        local.get 2
        ref.cast (ref 29)
        ref.cast (ref 29)
        struct.get 29 8
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
  )
  (func (;5;) (type 42) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;6;) (type 43) (param (ref 28) i32 i64) (result (ref 10))
    (local i32 (ref null 29) eqref eqref eqref)
    local.get 2
    local.get 0
    ref.cast (ref 28)
    struct.get 28 0
    ref.cast (ref array)
    array.len
    call 0
    local.set 3
    local.get 0
    ref.cast (ref 28)
    struct.get 28 0
    ref.cast (ref 5)
    local.get 3
    array.get 5
    local.set 5
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 5
          ref.cast (ref 10)
          struct.get 10 0
          i32.const 0
          i32.eq
          if ;; label = @4
            i32.const 0
            struct.new 10
            local.set 6
            br 3 (;@1;)
            br 1 (;@3;)
          end
          local.get 5
          ref.cast (ref 10)
          struct.get 10 0
          i32.const 1
          i32.eq
          if ;; label = @4
            local.get 5
            ref.cast (ref 12)
            struct.get 12 1
            ref.cast (ref 29)
            local.set 4
            local.get 4
            ref.cast (ref 29)
            ref.cast (ref 29)
            struct.get 29 1
            local.get 2
            i64.eq
            if (result i32) ;; label = @5
              local.get 4
              ref.cast (ref 29)
              ref.cast (ref 29)
              struct.get 29 2
              local.get 1
              call 7
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 4
              ref.cast (ref 29)
              local.set 7
              i32.const 1
              local.get 7
              struct.new 12
              local.set 6
              br 4 (;@1;)
            else
              local.get 4
              ref.cast (ref 29)
              ref.cast (ref 29)
              struct.get 29 0
              local.set 5
              br 3 (;@2;)
            end
            unreachable
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 6
    ref.cast (ref 10)
  )
  (func (;7;) (type 44) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.eq
  )
  (func (;8;) (type 45) (result (ref 28))
    call 1
    ref.cast (ref 28)
  )
  (func (;9;) (type 46)
    (local eqref)
    call 8
    local.set 0
    local.get 0
    ref.cast (ref 28)
    i32.const 1
    call 2
    drop
  )
)
