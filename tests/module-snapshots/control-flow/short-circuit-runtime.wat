(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\0f\00\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\00\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\01\01\81\80\80\02\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\00\01\01\00\00\00\00\02\01\00\00\00\00\00\00\00\00\00\01\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\03\01\00\00\00\00\00\00\00\00\00\01\01\02\01\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\04\01\81\80\10\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\05\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\03\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\06\01\81\80\10\00\00\00\00\00\00\00\00\01\01\04\01\00\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\07\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\05\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\08\01\00\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\09\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\04\00\06\07\08\02\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\0a\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\09\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\0b\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\0c\01\00\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\0d\01\85\80\80\02\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\00\01\01\00\00\00\00\0e\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\06\01\09\0a\0b\0c\0d\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\00\00\01\00\00\0b\08\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\00\09\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\0a\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\0f\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\10\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\11\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\12\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\13\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\15\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\16\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\1a\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\02\0a\02\0a\14\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\13\00\0a\1c\00\00\00\00\00\01\01\01\01\00\00,\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\13\00\00\00\00\00\02\0a\14\00\01*\00\00\00\01\02\01\01\01\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\13\00\0a\1c\00\04,\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01\13\00\00\00\0e\10\0e/\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e7\00\00\00\00\00\01\01\01\01\00\00+\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0ej\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0er\00\00\00\00\00\01\01\01\01\00\00+\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\8b\01\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\93\01\00\00\00\00\00\01\01\01\01\00\00+\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\ac\01\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\b4\01\00\00\00\00\00\01\01\01\01\00\00+\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\e4\01\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\ec\01\00\00\00\00\00\01\01\01\01\00\00+\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\9c\02\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\a4\02\00\00\00\00\00\01\01\01\01\00\00+\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\e6\02\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\ee\02\00\00\00\00\00\01\01\01\01\00\00+\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\99\03\00\00\00\00\00\01\01\01\01\00\00*\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\a1\03\00\00\00\00\00\01\01\01\01\00\00,\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\00\00\00\00\10\0e/\00\01*\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e7\00\04+\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0ej\00\01*\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0er\00\04+\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\8b\01\00\01*\00\00\00\01\02\01\01\01\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\93\01\00\04+\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\ac\01\00\01*\00\00\00\01\02\01\01\01\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\b4\01\00\04+\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\e4\01\00\01*\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\ec\01\00\04+\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\9c\02\00\01*\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\a4\02\00\04+\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\e6\02\00\01*\00\00\00\01\02\01\03\03\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\ee\02\00\04+\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\99\03\00\01*\00\00\00\01\02\01\02\02\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\0e\a1\03\00\04,\00\00\00\00\00\01\01\b8\17\01\84\80\80\80\80\f7\02\01\84\80\80\80\80\f7\02\00\01\d0\03\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 eqref)))
  (type (;9;) (func (param i32) (result i32)))
  (type (;10;) (func (param i32) (result i32)))
  (type (;11;) (func (param i32) (result i32)))
  (type (;12;) (func (param i32) (result i32)))
  (type (;13;) (func (param v128) (result v128)))
  (type (;14;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;15;) (func (param eqref) (result i32)))
  (type (;16;) (func (param eqref i32) (result i32)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref i32) (result i32)))
  (type (;19;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;20;) (func))
  (type (;21;) (func (param i32 eqref) (result i32)))
  (type (;22;) (func (result i32)))
  (type (;23;) (func (param i32) (result i32)))
  (type (;24;) (func (param i32) (result i32)))
  (type (;25;) (func (param i32) (result i32)))
  (type (;26;) (func (result i32)))
  (type (;27;) (sub (struct (field funcref))))
  (type (;28;) (func (param eqref) (result eqref)))
  (type (;29;) (func (param eqref i32) (result eqref)))
  (type (;30;) (func (param eqref eqref) (result eqref)))
  (type (;31;) (func (param eqref)))
  (type (;32;) (func (param eqref i32)))
  (type (;33;) (func (param eqref) (result i32)))
  (type (;34;) (func (param eqref i32) (result i32)))
  (type (;35;) (func (param eqref eqref i32) (result eqref)))
  (type (;36;) (func (param eqref eqref eqref) (result eqref)))
  (type (;37;) (func (param eqref eqref)))
  (type (;38;) (func (param eqref eqref i32)))
  (type (;39;) (func (param eqref eqref) (result i32)))
  (type (;40;) (func (param eqref eqref i32) (result i32)))
  (type (;41;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;42;) (array (mut v128)))
  (type (;43;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;44;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;45;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;46;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (type (;47;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 19)))
  (memory (;0;) 1)
  (export "main" (func 14))
  (export "memory" (memory 0))
  (func (;1;) (type 8) (param i32 eqref)
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
  (func (;2;) (type 9) (param i32) (result i32)
    local.get 0
    i32.const 255
    i32.and
  )
  (func (;3;) (type 10) (param i32) (result i32)
    local.get 0
    call 2
  )
  (func (;4;) (type 15) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 44)
    struct.get 44 2
  )
  (func (;5;) (type 16) (param eqref i32) (result i32)
    (local (ref 14) i32 v128 v128 v128)
    local.get 0
    ref.cast (ref 14)
    ref.cast (ref 14)
    local.set 2
    local.get 1
    local.get 2
    ref.cast (ref 14)
    struct.get 14 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i32.const -1
      local.get 2
      ref.cast (ref 14)
      struct.get 14 1
      i32.sub
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
    local.get 2
    ref.cast (ref 14)
    struct.get 14 1
    local.get 1
    i32.add
    local.set 3
    local.get 2
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 4)
    local.get 3
    i32.const 4
    i32.shr_u
    array.get 4
    local.set 4
    local.get 3
    i32.const 15
    i32.and
    call 3
    i8x16.splat
    local.set 5
    local.get 4
    local.set 6
    local.get 6
    local.get 5
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;6;) (type 17) (param eqref) (result i32)
    local.get 0
    call 4
  )
  (func (;7;) (type 18) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;8;) (type 20))
  (func (;9;) (type 21) (param i32 eqref) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 1
    call 6
    local.set 2
    i32.const 0
    local.set 12
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 12
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 2
              local.get 3
              i32.sub
              local.set 4
              local.get 4
              i32.const 65520
              i32.gt_u
              if (result i32) ;; label = @6
                i32.const 65520
              else
                local.get 4
              end
              local.set 5
              i32.const 0
              local.set 10
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 10
                      local.set 6
                      local.get 6
                      local.get 5
                      i32.lt_u
                      if ;; label = @10
                        i32.const 16
                        local.get 6
                        i32.add
                        local.get 1
                        local.get 3
                        local.get 6
                        i32.add
                        call 7
                        i32.store8
                        local.get 6
                        i32.const 1
                        i32.add
                        local.set 10
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 8
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              i32.const 0
              local.set 11
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 11
                      local.set 7
                      local.get 7
                      local.get 5
                      i32.lt_u
                      if ;; label = @10
                        local.get 5
                        local.get 7
                        i32.sub
                        local.set 8
                        i32.const 0
                        i32.const 16
                        local.get 7
                        i32.add
                        i32.store
                        i32.const 4
                        local.get 8
                        i32.store
                        i32.const 8
                        i32.const 0
                        i32.store
                        local.get 0
                        i32.const 0
                        i32.const 1
                        i32.const 8
                        call 0
                        i32.const 0
                        i32.ne
                        if ;; label = @11
                          unreachable
                        else
                          i32.const 8
                          i32.load
                          local.set 9
                          local.get 9
                          i32.const 0
                          i32.eq
                          if (result i32) ;; label = @12
                            i32.const 1
                          else
                            local.get 9
                            local.get 8
                            i32.gt_u
                          end
                          if ;; label = @12
                            unreachable
                          else
                            local.get 7
                            local.get 9
                            i32.add
                            local.set 11
                            br 5 (;@7;)
                          end
                          unreachable
                        end
                        unreachable
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 8
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 3
              local.get 5
              i32.add
              local.set 12
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 2
            local.set 13
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 13
  )
  (func (;10;) (type 22) (result i32)
    i32.const 1
    v128.const i32x4 0x00444142 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 3
    struct.new 44
    call 9
    drop
    i32.const 1
  )
  (func (;11;) (type 23) (param i32) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      i32.const 1
      if (result i32) ;; label = @2
        local.get 0
        return
      else
        i32.const 0
      end
    else
      i32.const 0
    end
    drop
    i32.const 0
  )
  (func (;12;) (type 24) (param i32) (result i32)
    i32.const 0
    if (result i32) ;; label = @1
      i32.const 1
    else
      i32.const 1
      if (result i32) ;; label = @2
        local.get 0
        return
      else
        i32.const 0
      end
    end
    drop
    i32.const 0
  )
  (func (;13;) (type 25) (param i32) (result i32)
    (local i32 i32 i32)
    local.get 0
    local.set 2
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 2
            local.set 1
            local.get 1
            i32.const 0
            i32.gt_s
            if (result i32) ;; label = @5
              local.get 1
              i32.const 1
              i32.sub
              local.set 2
              br 3 (;@2;)
            else
              i32.const 0
            end
            drop
            i32.const 0
            if (result i32) ;; label = @5
              i32.const 1
            else
              i32.const 9
              local.set 3
              br 4 (;@1;)
            end
            drop
            i32.const 0
            local.set 3
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 3
  )
  (func (;14;) (type 26) (result i32)
    i32.const 0
    if (result i32) ;; label = @1
      call 10
    else
      i32.const 0
    end
    i32.eqz
    v128.const i32x4 0x736c6166 0x6e612065 0x6b732064 0x20737069
    v128.const i32x4 0x00736872 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 19
    struct.new 43
    call 1
    i32.const 1
    if (result i32) ;; label = @1
      i32.const 1
    else
      call 10
    end
    v128.const i32x4 0x65757274 0x20726f20 0x70696b73 0x68722073
    v128.const i32x4 0x00000073 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 17
    struct.new 43
    call 1
    i32.const 1
    v128.const i32x4 0x20646e61 0x756c6176 0x00000065 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 9
    struct.new 43
    call 1
    i32.const 1
    v128.const i32x4 0x7620726f 0x65756c61 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 8
    struct.new 43
    call 1
    i32.const 4
    call 11
    i32.const 4
    i32.eq
    v128.const i32x4 0x75746572 0x74206e72 0x756f7268 0x61206867
    v128.const i32x4 0x0000646e 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 18
    struct.new 43
    call 1
    i32.const 5
    call 12
    i32.const 5
    i32.eq
    v128.const i32x4 0x75746572 0x74206e72 0x756f7268 0x6f206867
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 17
    struct.new 43
    call 1
    i32.const 3
    call 13
    i32.const 9
    i32.eq
    v128.const i32x4 0x706f6f6c 0x61727420 0x6566736e 0x74207372
    v128.const i32x4 0x756f7268 0x6c206867 0x6369676f 0x6f206c61
    v128.const i32x4 0x61726570 0x73726f74 0x00000000 0x00000000
    array.new_fixed 42 3
    i32.const 0
    i32.const 40
    struct.new 43
    call 1
    i32.const 1
    v128.const i32x4 0x746e6f63 0x3a6c6f72 0x726f6873 0x69632d74
    v128.const i32x4 0x69756372 0x00000074 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 21
    struct.new 44
    call 9
  )
)
