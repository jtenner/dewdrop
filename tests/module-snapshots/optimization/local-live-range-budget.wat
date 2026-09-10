(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\06\00\01\81\80\90\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\81\80\90\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\02\01\81\80\90\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\00\01\01\00\00\00\00\03\01\85\80\90\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\00\01\01\00\00\00\00\04\01\85\81\90\02\00\00\00\00\00\00\00\00\01\05\00\01\02\03\05\00\00\01\00\00\01\00\00\05\01\80\80\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\01\0b\01\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\01\04\05\04\06\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\04\11\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\04\1d\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\04+\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\049\00\00\00\00\00\01\01\01\01\00\00\08\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\00\00\00\00\05\04\06\00\04\08\00\00\00\00\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\04\11\00\04\08\00\00\00\00\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\04\1d\00\04\08\00\00\00\00\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\04+\00\04\08\00\00\00\00\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\049\00\04\08\00\00\00\00\00\01\01\b8\17\01\87\80\80\80\80\f7\02\01\86\80\80\80\80\f7\02\00\01\cd\06\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field i32)))
  (type (;9;) (func (param (ref 8)) (result i32)))
  (type (;10;) (func (param (ref 8)) (result i32)))
  (type (;11;) (func (param (ref 8) i32) (result i32)))
  (type (;12;) (func (param (ref 8)) (result i32)))
  (type (;13;) (func (param eqref eqref) (result eqref)))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (export "main" (func 4))
  (func (;0;) (type 9) (param (ref 8)) (result i32)
    (local (ref 8))
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    i32.add
  )
  (func (;1;) (type 10) (param (ref 8)) (result i32)
    (local (ref 8) i32)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    i32.add
  )
  (func (;2;) (type 11) (param (ref 8) i32) (result i32)
    (local (ref 8))
    local.get 0
    local.set 2
    local.get 1
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 8)
      struct.get 8 0
    else
      local.get 2
      ref.cast (ref 8)
      struct.get 8 0
    end
  )
  (func (;3;) (type 12) (param (ref 8)) (result i32)
    (local (ref 8) i32 i32 i32 i32 i32)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    local.set 2
    i32.const 0
    local.set 5
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 5
          i32.const 0
          i32.eq
          if ;; label = @4
            local.get 1
            ref.cast (ref 8)
            struct.get 8 0
            local.set 6
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 5
            local.set 3
            local.get 3
            i32.const 1
            i32.sub
            local.set 5
            br 2 (;@2;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 6
    local.set 4
    local.get 2
    local.get 4
    i32.add
  )
  (func (;4;) (type 15) (result i32)
    (local i32 i32 i32 i32 i32)
    i32.const 2
    local.set 0
    local.get 0
    struct.new 8
    call 0
    i32.const 3
    local.set 1
    local.get 1
    struct.new 8
    call 1
    i32.add
    i32.const 4
    local.set 2
    local.get 2
    struct.new 8
    i32.const 1
    call 2
    i32.add
    i32.const 5
    local.set 3
    local.get 3
    struct.new 8
    i32.const 0
    call 2
    i32.add
    i32.const 6
    local.set 4
    local.get 4
    struct.new 8
    call 3
    i32.add
    i32.const 7
    call 5
    i32.add
  )
  (func (;5;) (type 16) (param i32) (result i32)
    (local i32)
    local.get 0
    local.set 1
    local.get 1
    drop
    local.get 1
  )
)
