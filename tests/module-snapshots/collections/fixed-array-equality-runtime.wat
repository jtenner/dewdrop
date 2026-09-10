(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\12\00\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\01\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\02\01\81\80 \00\00\00\00\00\00\00\00\01\00\03\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\02\00\01\7f\00\00\01\01\00\00\00\00\03\01\85\80\90\02\00\00\00\00\00\00\00\00\01\01\0b\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\04\01\85\80\90\02\00\00\00\00\00\00\00\00\01\01\0b\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\05\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\06\01\81\80 \00\00\00\00\00\00\00\00\01\00\03\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\02\00\01\7f\00\00\01\01\00\00\00\00\07\01\85\80\90\02\00\00\00\00\00\00\00\00\01\01\0c\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\08\01\85\80\90\02\00\00\00\00\00\00\00\00\01\01\0c\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\09\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\0a\01\85\80\90\02\00\00\00\00\00\00\00\00\01\01\0d\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\0b\01\85\80\90\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\0c\01\85\80\90\02\00\00\00\00\00\00\00\00\01\01\0e\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\0d\01\85\80\90\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\0e\01\81\80\10\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\0f\01\81\80\10\00\00\00\00\00\00\00\00\01\01\0e\02\00\00\01\7f\01\ff\01\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\10\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\11\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\0c\00\01\02\03\04\05\06\07\08\09\0a\10\00\00\01\00\00\01\00\00\10\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\0e\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\0f\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\10\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\11\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\12\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\13\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\14\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\15\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\16\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\17\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\18\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\19\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\1a\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\1c\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\1d\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\05\01\01\01\0c\00\00\00\00\00\01\01\01\01\00\00\00\00\01\01\8a\80\fc\ff\0f\01\82\80\80\80\a0\81\c0\ff\ff\01\01\80\80\80\80\a0\81\c0\ff\ff\01\00\01_\00\00\00\00\00\01\01\0c\00\01\00\00\00\00\00\00\01\01\8a\80\fc\ff\0f\01\82\80\80\80\a0\81\c0\ff\ff\01\01\80\80\80\80\a0\81\c0\ff\ff\01\00\01_\00\00\00\05\01\05\0c\00\00\00\00\00\01\01\01\01\00\00\05\00\01\01\8a\80\fc\ff\0f\01\82\80\80\80\a0\81\c0\ff\ff\01\01\80\80\80\80\a0\81\c0\ff\ff\01\00\01_\00\00\00\00\00\01\05\0c\00\01\05\00\00\00\00\00\01\01\8a\80\fc\ff\0f\01\82\80\80\80\a0\81\c0\ff\ff\01\01\80\80\80\80\a0\81\c0\ff\ff\01\00\01_\00\00\00\09\01\09\0c\00\00\00\00\00\01\01\01\01\00\00\01\00\01\01\8a\80\fc\ff\0f\01\82\80\80\80\a0\81\c0\ff\ff\01\01\80\80\80\80\a0\81\c0\ff\ff\01\00\01_\00\00\00\00\00\01\09\0c\00\01\01\00\00\00\00\00\01\01\8a\80\fc\ff\0f\01\82\80\80\80\a0\81\c0\ff\ff\01\01\80\80\80\80\a0\81\c0\ff\ff\01\00\01_\00\00\00\10\01\10\06\00\00\00\00\00\01\01\01\01\00\00\1b\00\01\01\b8\17\01\85\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01W\00\00\00\00\00\01\10\06\00\04\1b\00\00\00\00\00\01\01\b8\17\01\85\80\80\80\80\f7\02\01\82\80\80\80\80\f7\02\00\01W\00\00\00\11\0c\11M\00\00\00\00\00\01\01\01\01\00\00 \00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11U\00\00\00\00\00\01\01\01\01\00\00!\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\99\01\00\00\00\00\00\01\01\01\01\00\00 \00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\a1\01\00\00\00\00\00\01\01\01\01\00\00!\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\d7\01\00\00\00\00\00\01\01\01\01\00\00 \00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\df\01\00\00\00\00\00\01\01\01\01\00\00!\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\cb\02\00\00\00\00\00\01\01\01\01\00\00 \00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\d3\02\00\00\00\00\00\01\01\01\01\00\00!\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\97\03\00\00\00\00\00\01\01\01\01\00\00 \00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\9f\03\00\00\00\00\00\01\01\01\01\00\00!\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\e1\03\00\00\00\00\00\01\01\01\01\00\00 \00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\e9\03\00\00\00\00\00\01\01\01\01\00\00!\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\00\00\00\00\0c\11M\00\01 \00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11U\00\04!\00\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\99\01\00\01 \00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\a1\01\00\04!\00\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\d7\01\00\01 \00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\df\01\00\04!\00\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\cb\02\00\01 \00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\d3\02\00\04!\00\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\97\03\00\01 \00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\9f\03\00\04!\00\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\e1\03\00\01 \00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\11\e9\03\00\04!\00\00\00\00\00\01\01\b8\17\01\86\80\80\80\80\f7\02\01\83\80\80\80\80\f7\02\00\01\97\01\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (func (param i32 eqref) (result eqref)))
  (type (;10;) (func (param eqref i32 eqref)))
  (type (;11;) (func (param eqref eqref) (result i32)))
  (type (;12;) (func (param eqref eqref) (result i32)))
  (type (;13;) (func (param eqref eqref) (result i32)))
  (type (;14;) (func (param i32 i32) (result (ref 0))))
  (type (;15;) (func (param eqref i32 i32)))
  (type (;16;) (func (param eqref (ref 0)) (result i32)))
  (type (;17;) (func (param eqref (ref 0)) (result i32)))
  (type (;18;) (func (param i32 eqref) (result (ref 5))))
  (type (;19;) (func (param eqref i32 eqref)))
  (type (;20;) (func (param eqref (ref 5)) (result i32)))
  (type (;21;) (func (param eqref (ref 5)) (result i32)))
  (type (;22;) (func (param i32 i64) (result (ref 1))))
  (type (;23;) (func (param eqref (ref 1)) (result i32)))
  (type (;24;) (func (param eqref (ref 0)) (result i32)))
  (type (;25;) (func (param eqref (ref 5)) (result i32)))
  (type (;26;) (func (param eqref (ref 1)) (result i32)))
  (type (;27;) (struct (field i32)))
  (type (;28;) (func (param (ref 27) (ref 27)) (result i32)))
  (type (;29;) (func (param (ref 27) (ref 27)) (result i32)))
  (type (;30;) (func (param i32) (result (ref 27))))
  (type (;31;) (func))
  (type (;32;) (array (mut v128)))
  (type (;33;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;34;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;35;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;36;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (type (;37;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 17))
  (func (;0;) (type 8) (param i32 eqref)
    (local eqref)
    local.get 1
    local.set 2
    local.get 0
    i32.eqz
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;1;) (type 14) (param i32 i32) (result (ref 0))
    (local i32 i32)
    local.get 0
    local.get 1
    local.set 2
    local.set 3
    local.get 2
    local.get 3
    array.new 0
    ref.cast (ref 0)
  )
  (func (;2;) (type 15) (param eqref i32 i32)
    local.get 0
    ref.cast (ref 0)
    local.get 1
    local.get 2
    array.set 0
  )
  (func (;3;) (type 16) (param eqref (ref 0)) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 0)
    call 11
  )
  (func (;4;) (type 17) (param eqref (ref 0)) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 0)
    call 11
    i32.eqz
  )
  (func (;5;) (type 18) (param i32 eqref) (result (ref 5))
    (local eqref i32)
    local.get 0
    local.get 1
    local.set 2
    local.set 3
    local.get 2
    local.get 3
    array.new 5
    ref.cast (ref 5)
  )
  (func (;6;) (type 19) (param eqref i32 eqref)
    local.get 0
    ref.cast (ref 5)
    local.get 1
    local.get 2
    array.set 5
  )
  (func (;7;) (type 20) (param eqref (ref 5)) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 5)
    call 12
  )
  (func (;8;) (type 21) (param eqref (ref 5)) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 5)
    call 12
    i32.eqz
  )
  (func (;9;) (type 22) (param i32 i64) (result (ref 1))
    (local i64 i32)
    local.get 0
    local.get 1
    local.set 2
    local.set 3
    local.get 2
    local.get 3
    array.new 1
    ref.cast (ref 1)
  )
  (func (;10;) (type 23) (param eqref (ref 1)) (result i32)
    local.get 0
    local.get 1
    ref.cast (ref 1)
    call 13
  )
  (func (;11;) (type 24) (param eqref (ref 0)) (result i32)
    (local i32 i32 i32 i32)
    local.get 0
    ref.cast (ref array)
    array.len
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref array)
    array.len
    i32.ne
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 0
      local.set 4
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 4
              local.set 3
              local.get 3
              local.get 2
              i32.lt_u
              if ;; label = @6
                local.get 0
                ref.cast (ref 0)
                local.get 3
                array.get 0
                local.get 1
                ref.cast (ref 0)
                local.get 3
                array.get 0
                i32.eq
                if ;; label = @7
                  local.get 3
                  i32.const 1
                  i32.add
                  local.set 4
                  br 4 (;@3;)
                else
                  i32.const 0
                  local.set 5
                  br 5 (;@2;)
                end
                unreachable
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              i32.const 1
              local.set 5
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 5
    end
  )
  (func (;12;) (type 25) (param eqref (ref 5)) (result i32)
    (local i32 i32 i32 i32)
    local.get 0
    ref.cast (ref array)
    array.len
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref array)
    array.len
    i32.ne
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 0
      local.set 4
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 4
              local.set 3
              local.get 3
              local.get 2
              i32.lt_u
              if ;; label = @6
                local.get 0
                ref.cast (ref 5)
                local.get 3
                array.get 5
                ref.cast (ref 27)
                local.get 1
                ref.cast (ref 5)
                local.get 3
                array.get 5
                ref.cast (ref 27)
                call 14
                if ;; label = @7
                  local.get 3
                  i32.const 1
                  i32.add
                  local.set 4
                  br 4 (;@3;)
                else
                  i32.const 0
                  local.set 5
                  br 5 (;@2;)
                end
                unreachable
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              i32.const 1
              local.set 5
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 5
    end
  )
  (func (;13;) (type 26) (param eqref (ref 1)) (result i32)
    (local i32 i32 i32 i32)
    local.get 0
    ref.cast (ref array)
    array.len
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref array)
    array.len
    i32.ne
    if (result i32) ;; label = @1
      i32.const 0
    else
      i32.const 0
      local.set 4
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 4
              local.set 3
              local.get 3
              local.get 2
              i32.lt_u
              if ;; label = @6
                local.get 0
                ref.cast (ref 1)
                local.get 3
                array.get 1
                local.get 1
                ref.cast (ref 1)
                local.get 3
                array.get 1
                i64.eq
                if ;; label = @7
                  local.get 3
                  i32.const 1
                  i32.add
                  local.set 4
                  br 4 (;@3;)
                else
                  i32.const 0
                  local.set 5
                  br 5 (;@2;)
                end
                unreachable
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              i32.const 1
              local.set 5
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 5
    end
  )
  (func (;14;) (type 28) (param (ref 27) (ref 27)) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 27)
      struct.get 27 0
      local.get 1
      ref.cast (ref 27)
      struct.get 27 0
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;15;) (type 29) (param (ref 27) (ref 27)) (result i32)
    local.get 0
    ref.cast (ref 27)
    local.get 1
    ref.cast (ref 27)
    call 14
    i32.eqz
  )
  (func (;16;) (type 30) (param i32) (result (ref 27))
    (local i32)
    local.get 0
    local.set 1
    local.get 1
    struct.new 27
    ref.cast (ref 27)
  )
  (func (;17;) (type 31)
    (local eqref eqref eqref)
    i32.const 3
    i32.const 7
    call 1
    local.set 0
    i32.const 3
    i32.const 7
    call 1
    local.set 1
    i32.const 3
    i32.const 7
    call 1
    local.set 2
    local.get 2
    i32.const 2
    i32.const 8
    call 2
    local.get 0
    local.get 1
    ref.cast (ref 0)
    call 3
    v128.const i32x4 0x61757165 0x6373206c 0x72616c61 0x78696620
    v128.const i32x4 0x61206465 0x79617272 0x69642073 0x72656666
    array.new_fixed 32 2
    i32.const 0
    i32.const 32
    struct.new 33
    call 0
    local.get 0
    local.get 2
    ref.cast (ref 0)
    call 4
    v128.const i32x4 0x66666964 0x6e657265 0x63732074 0x72616c61
    v128.const i32x4 0x78696620 0x61206465 0x79617272 0x6f632073
    v128.const i32x4 0x7261706d 0x71652065 0x006c6175 0x00000000
    array.new_fixed 32 3
    i32.const 0
    i32.const 43
    struct.new 33
    call 0
    local.get 0
    i32.const 2
    i32.const 7
    call 1
    ref.cast (ref 0)
    call 4
    v128.const i32x4 0x66666964 0x6e657265 0x656c2074 0x6874676e
    v128.const i32x4 0x6f632073 0x7261706d 0x71652065 0x006c6175
    array.new_fixed 32 2
    i32.const 0
    i32.const 31
    struct.new 33
    call 0
    i32.const 2
    i32.const 4
    call 16
    call 5
    local.set 0
    i32.const 2
    i32.const 4
    call 16
    call 5
    local.set 1
    i32.const 2
    i32.const 4
    call 16
    call 5
    local.set 2
    local.get 2
    i32.const 1
    i32.const 5
    call 16
    call 6
    local.get 0
    local.get 1
    ref.cast (ref 5)
    call 7
    v128.const i32x4 0x61757165 0x6572206c 0x65726566 0x2065636e
    v128.const i32x4 0x65786966 0x72612064 0x73796172 0x66696420
    v128.const i32x4 0x00726566 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 3
    i32.const 0
    i32.const 35
    struct.new 33
    call 0
    local.get 0
    local.get 2
    ref.cast (ref 5)
    call 8
    v128.const i32x4 0x66666964 0x6e657265 0x65722074 0x65726566
    v128.const i32x4 0x2065636e 0x65786966 0x72612064 0x73796172
    v128.const i32x4 0x6d6f6320 0x65726170 0x75716520 0x00006c61
    array.new_fixed 32 3
    i32.const 0
    i32.const 46
    struct.new 33
    call 0
    i32.const 2
    i64.const 9
    call 9
    local.set 0
    i32.const 2
    i64.const 9
    call 9
    local.set 1
    local.get 0
    local.get 1
    ref.cast (ref 1)
    call 10
    v128.const i32x4 0x61757165 0x6977206c 0x66206564 0x64657869
    v128.const i32x4 0x72726120 0x20737961 0x66666964 0x00007265
    array.new_fixed 32 2
    i32.const 0
    i32.const 30
    struct.new 33
    call 0
  )
)
