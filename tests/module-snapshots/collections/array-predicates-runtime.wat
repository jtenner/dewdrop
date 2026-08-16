(module
  (rec
    (type (;0;) (sub (struct (field i32))))
  )
  (rec
    (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  )
  (rec
    (type (;2;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  )
  (rec
    (type (;3;) (sub (struct (field funcref))))
  )
  (rec
    (type (;4;) (sub final 3 (struct (field funcref))))
  )
  (rec
    (type (;5;) (sub final 3 (struct (field funcref))))
  )
  (rec
    (type (;6;) (sub final 3 (struct (field funcref) (field eqref))))
  )
  (rec
    (type (;7;) (sub final 3 (struct (field funcref) (field eqref))))
  )
  (type (;8;) (array (mut i32)))
  (type (;9;) (array (mut i64)))
  (type (;10;) (array (mut f32)))
  (type (;11;) (array (mut f64)))
  (type (;12;) (array (mut v128)))
  (type (;13;) (array (mut eqref)))
  (type (;14;) (array (mut i8)))
  (type (;15;) (array (mut i16)))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref i32) (result eqref)))
  (type (;18;) (func (param eqref) (result (ref 2))))
  (type (;19;) (func (param eqref eqref) (result eqref)))
  (type (;20;) (func (param eqref)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref i32) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result (ref 2))))
  (type (;26;) (func (param eqref eqref eqref) (result eqref)))
  (type (;27;) (func (param eqref eqref)))
  (type (;28;) (func (param eqref eqref i32)))
  (type (;29;) (func (param eqref eqref) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result i32)))
  (type (;31;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;32;) (func (param i32 eqref) (result (ref 2))))
  (type (;33;) (func (param (ref 2) eqref) (result i32)))
  (type (;34;) (func (param (ref 2) eqref) (result i32)))
  (type (;35;) (func (param (ref 2) eqref) (result i32)))
  (type (;36;) (func (param (ref 2) eqref) (result (ref 0))))
  (type (;37;) (func (param (ref 2) eqref) (result (ref 0))))
  (type (;38;) (func (param (ref 2) eqref) (result (ref 0))))
  (type (;39;) (func (param (ref 2) eqref) (result (ref 0))))
  (type (;40;) (func (param (ref 2) eqref) (result i32)))
  (type (;41;) (func (param (ref 2) eqref) (result i32)))
  (type (;42;) (func (param (ref 2) eqref) (result i32)))
  (type (;43;) (func (param (ref 2) eqref) (result (ref 0))))
  (type (;44;) (func (param (ref 2) eqref) (result (ref 0))))
  (type (;45;) (func (param (ref 2) eqref) (result (ref 0))))
  (type (;46;) (func (param (ref 2) eqref) (result (ref 0))))
  (type (;47;) (func (param i32 i32) (result (ref 2))))
  (type (;48;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;49;) (func (param i32 eqref) (result i32)))
  (type (;50;) (func (param i32) (result i32)))
  (type (;51;) (func (param i32 i32) (result i32)))
  (type (;52;) (func (param eqref i32 i32) (result i32)))
  (type (;53;) (func (result (ref 2))))
  (type (;54;) (func (param (ref 0)) (result i32)))
  (type (;55;) (func (param (ref 0)) (result i32)))
  (type (;56;) (func))
  (type (;57;) (func))
  (type (;58;) (array (mut v128)))
  (type (;59;) (struct (field (ref 58)) (field i32) (field i32)))
  (type (;60;) (struct (field (ref 58)) (field i32) (field i32)))
  (type (;61;) (struct (field (ref 58)) (field i32) (field i32)))
  (type (;62;) (struct (field (mut (ref 58))) (field (mut i32)) (field (mut i32))))
  (type (;63;) (struct (field (mut (ref 58))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 48)))
  (memory (;0;) 1)
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (global (;2;) (mut eqref) ref.null eq)
  (global (;3;) (mut eqref) ref.null eq)
  (export "main" (func 17))
  (export "__dew_init" (func 22))
  (export "memory" (memory 0))
  (elem (;0;) declare func 13 14 15 16 18 19 20 21)
  (func (;1;) (type 40) (param (ref 2) eqref) (result i32)
    (local i32 i32 eqref i32 eqref eqref i32 i32)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              local.get 0
              ref.cast (ref 2)
              struct.get 2 1
              i32.lt_u
              if (result i32) ;; label = @6
                local.get 1
                local.set 7
                local.get 7
                ref.cast (ref 3)
                struct.get 3 0
                ref.test (ref 50)
                if (result i32) ;; label = @7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 8)
                  local.get 5
                  array.get 8
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 50)
                  call_ref 50
                else
                  local.get 7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 8)
                  local.get 5
                  array.get 8
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 23)
                  call_ref 23
                end
                i32.eqz
              else
                i32.const 0
              end
              if ;; label = @6
                i32.const 0
                local.set 9
                br 5 (;@1;)
              else
                local.get 3
                i32.const 1
                i32.add
                local.set 8
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 1
            local.set 9
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
  )
  (func (;2;) (type 41) (param (ref 2) eqref) (result i32)
    (local i32 i32 eqref i32 eqref eqref i32 i32)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              local.get 0
              ref.cast (ref 2)
              struct.get 2 1
              i32.lt_u
              if (result i32) ;; label = @6
                local.get 1
                local.set 7
                local.get 7
                ref.cast (ref 3)
                struct.get 3 0
                ref.test (ref 51)
                if (result i32) ;; label = @7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 8)
                  local.get 5
                  array.get 8
                  local.get 3
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 51)
                  call_ref 51
                else
                  local.get 7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 8)
                  local.get 5
                  array.get 8
                  local.get 3
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 52)
                  call_ref 52
                end
                i32.eqz
              else
                i32.const 0
              end
              if ;; label = @6
                i32.const 0
                local.set 9
                br 5 (;@1;)
              else
                local.get 3
                i32.const 1
                i32.add
                local.set 8
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 1
            local.set 9
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
  )
  (func (;3;) (type 42) (param (ref 2) eqref) (result i32)
    (local i32 i32 eqref i32 eqref eqref i32 i32)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              local.get 0
              ref.cast (ref 2)
              struct.get 2 1
              i32.lt_u
              if (result i32) ;; label = @6
                local.get 1
                local.set 7
                local.get 7
                ref.cast (ref 3)
                struct.get 3 0
                ref.test (ref 50)
                if (result i32) ;; label = @7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 8)
                  local.get 5
                  array.get 8
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 50)
                  call_ref 50
                else
                  local.get 7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 8)
                  local.get 5
                  array.get 8
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 23)
                  call_ref 23
                end
              else
                i32.const 0
              end
              if ;; label = @6
                i32.const 1
                local.set 9
                br 5 (;@1;)
              else
                local.get 3
                i32.const 1
                i32.add
                local.set 8
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 9
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
  )
  (func (;4;) (type 43) (param (ref 2) eqref) (result (ref 0))
    (local i32 i32 i32 eqref i32 eqref eqref i32 eqref)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    local.set 2
    i32.const 0
    local.set 9
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              local.get 0
              ref.cast (ref 2)
              struct.get 2 1
              i32.lt_u
              if ;; label = @6
                local.get 0
                local.get 3
                local.set 6
                local.set 5
                local.get 6
                local.get 5
                ref.cast (ref 2)
                struct.get 2 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 5
                ref.cast (ref 2)
                struct.get 2 0
                ref.cast (ref 8)
                local.get 6
                array.get 8
                local.set 4
                local.get 1
                local.set 8
                local.get 8
                ref.cast (ref 3)
                struct.get 3 0
                ref.test (ref 50)
                if (result i32) ;; label = @7
                  local.get 4
                  local.get 8
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 50)
                  call_ref 50
                else
                  local.get 8
                  local.get 4
                  local.get 8
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 23)
                  call_ref 23
                end
                if ;; label = @7
                  i32.const 1
                  local.get 4
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  ref.null eq
                  struct.new 1
                  local.set 10
                  br 6 (;@1;)
                else
                end
              else
              end
              local.get 3
              i32.const 1
              i32.add
              local.set 9
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            struct.new 0
            local.set 10
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 10
    ref.cast (ref 0)
  )
  (func (;5;) (type 44) (param (ref 2) eqref) (result (ref 0))
    (local i32 i32 eqref i32 eqref eqref i32 eqref)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              local.get 0
              ref.cast (ref 2)
              struct.get 2 1
              i32.lt_u
              if (result i32) ;; label = @6
                local.get 1
                local.set 7
                local.get 7
                ref.cast (ref 3)
                struct.get 3 0
                ref.test (ref 50)
                if (result i32) ;; label = @7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 8)
                  local.get 5
                  array.get 8
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 50)
                  call_ref 50
                else
                  local.get 7
                  local.get 0
                  local.get 3
                  local.set 5
                  local.set 4
                  local.get 5
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 4
                  ref.cast (ref 2)
                  struct.get 2 0
                  ref.cast (ref 8)
                  local.get 5
                  array.get 8
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  ref.cast (ref 23)
                  call_ref 23
                end
              else
                i32.const 0
              end
              if ;; label = @6
                i32.const 1
                local.get 3
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                ref.null eq
                struct.new 1
                local.set 9
                br 5 (;@1;)
              else
                local.get 3
                i32.const 1
                i32.add
                local.set 8
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            struct.new 0
            local.set 9
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    ref.cast (ref 0)
  )
  (func (;6;) (type 45) (param (ref 2) eqref) (result (ref 0))
    (local i32 i32 i32 i32 eqref i32 eqref eqref i32 eqref)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    local.set 2
    local.get 2
    local.set 10
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 10
          i32.const 0
          i32.eq
          if ;; label = @4
            i32.const 0
            struct.new 0
            local.set 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 10
            local.set 3
            local.get 3
            i32.const 1
            i32.sub
            local.set 4
            local.get 4
            local.get 0
            ref.cast (ref 2)
            struct.get 2 1
            i32.lt_u
            if ;; label = @5
              local.get 0
              local.get 4
              local.set 7
              local.set 6
              local.get 7
              local.get 6
              ref.cast (ref 2)
              struct.get 2 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 6
              ref.cast (ref 2)
              struct.get 2 0
              ref.cast (ref 8)
              local.get 7
              array.get 8
              local.set 5
              local.get 1
              local.set 9
              local.get 9
              ref.cast (ref 3)
              struct.get 3 0
              ref.test (ref 50)
              if (result i32) ;; label = @6
                local.get 5
                local.get 9
                ref.cast (ref 3)
                struct.get 3 0
                ref.cast (ref 50)
                call_ref 50
              else
                local.get 9
                local.get 5
                local.get 9
                ref.cast (ref 3)
                struct.get 3 0
                ref.cast (ref 23)
                call_ref 23
              end
              if ;; label = @6
                i32.const 1
                local.get 5
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                ref.null eq
                struct.new 1
                local.set 11
                br 5 (;@1;)
              else
              end
            else
            end
            local.get 4
            local.set 10
            br 2 (;@2;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 11
    ref.cast (ref 0)
  )
  (func (;7;) (type 46) (param (ref 2) eqref) (result (ref 0))
    (local i32 i32 i32 eqref i32 eqref eqref i32 eqref)
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    local.set 2
    local.get 2
    local.set 9
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          local.get 9
          i32.const 0
          i32.eq
          if ;; label = @4
            i32.const 0
            struct.new 0
            local.set 10
            br 3 (;@1;)
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 3
            local.get 3
            i32.const 1
            i32.sub
            local.set 4
            local.get 4
            local.get 0
            ref.cast (ref 2)
            struct.get 2 1
            i32.lt_u
            if (result i32) ;; label = @5
              local.get 1
              local.set 8
              local.get 8
              ref.cast (ref 3)
              struct.get 3 0
              ref.test (ref 50)
              if (result i32) ;; label = @6
                local.get 0
                local.get 4
                local.set 6
                local.set 5
                local.get 6
                local.get 5
                ref.cast (ref 2)
                struct.get 2 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 5
                ref.cast (ref 2)
                struct.get 2 0
                ref.cast (ref 8)
                local.get 6
                array.get 8
                local.get 8
                ref.cast (ref 3)
                struct.get 3 0
                ref.cast (ref 50)
                call_ref 50
              else
                local.get 8
                local.get 0
                local.get 4
                local.set 6
                local.set 5
                local.get 6
                local.get 5
                ref.cast (ref 2)
                struct.get 2 1
                i32.ge_u
                if ;; label = @7
                  unreachable
                end
                local.get 5
                ref.cast (ref 2)
                struct.get 2 0
                ref.cast (ref 8)
                local.get 6
                array.get 8
                local.get 8
                ref.cast (ref 3)
                struct.get 3 0
                ref.cast (ref 23)
                call_ref 23
              end
            else
              i32.const 0
            end
            if ;; label = @5
              i32.const 1
              local.get 4
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              ref.null eq
              struct.new 1
              local.set 10
              br 4 (;@1;)
            else
              local.get 4
              local.set 9
              br 3 (;@2;)
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 10
    ref.cast (ref 0)
  )
  (func (;8;) (type 47) (param i32 i32) (result (ref 2))
    (local eqref i32 eqref i32)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 8
    local.get 3
    local.get 3
    struct.new 2
    ref.cast (ref 2)
  )
  (func (;9;) (type 49) (param i32 eqref) (result i32)
    (local (ref 60) (ref 58) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 60)
    local.set 2
    local.get 2
    struct.get 60 0
    local.set 3
    local.get 2
    struct.get 60 1
    local.set 4
    local.get 2
    struct.get 60 2
    local.set 5
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        local.get 5
        i32.ge_u
        br_if 1 (;@1;)
        local.get 5
        local.get 6
        i32.sub
        local.tee 7
        i32.const 65520
        i32.gt_u
        if ;; label = @3
          i32.const 65520
          local.set 7
        end
        i32.const 0
        local.set 8
        block ;; label = @3
          loop ;; label = @4
            local.get 8
            local.get 7
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            local.get 6
            i32.add
            local.get 8
            i32.add
            local.set 9
            local.get 9
            i32.const 15
            i32.and
            i32.eqz
            local.get 8
            i32.const 64
            i32.add
            local.get 7
            i32.le_u
            i32.and
            if ;; label = @5
              i32.const 16
              local.get 8
              i32.add
              local.get 3
              local.get 9
              i32.const 4
              i32.shr_u
              array.get 58
              v128.store
              i32.const 16
              local.get 8
              i32.const 16
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 16
              i32.add
              i32.const 4
              i32.shr_u
              array.get 58
              v128.store
              i32.const 16
              local.get 8
              i32.const 32
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 32
              i32.add
              i32.const 4
              i32.shr_u
              array.get 58
              v128.store
              i32.const 16
              local.get 8
              i32.const 48
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 48
              i32.add
              i32.const 4
              i32.shr_u
              array.get 58
              v128.store
              local.get 8
              i32.const 64
              i32.add
              local.set 8
              br 1 (;@4;)
            end
            local.get 8
            i32.const 16
            i32.add
            local.get 7
            i32.le_u
            if ;; label = @5
              local.get 9
              i32.const 15
              i32.and
              i32.eqz
              if ;; label = @6
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 58
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 58
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 9
                i32.const 15
                i32.and
                i8x16.splat
                i8x16.add
                i8x16.swizzle
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                i32.const 1
                i32.add
                array.get 58
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 9
                i32.const 15
                i32.and
                i8x16.splat
                i8x16.add
                i32.const 16
                i8x16.splat
                i8x16.sub
                i8x16.swizzle
                v128.or
                local.set 11
              end
              i32.const 16
              local.get 8
              i32.add
              local.get 11
              v128.store
              local.get 8
              i32.const 16
              i32.add
              local.set 8
              br 1 (;@4;)
            end
            local.get 3
            local.get 9
            i32.const 4
            i32.shr_u
            array.get 58
            local.get 9
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.swizzle
            i8x16.extract_lane_u 0
            local.set 10
            i32.const 16
            local.get 8
            i32.add
            local.get 10
            i32.store8
            local.get 8
            i32.const 1
            i32.add
            local.set 8
            br 0 (;@4;)
          end
        end
        i32.const 0
        local.set 13
        block ;; label = @3
          loop ;; label = @4
            local.get 13
            local.get 7
            i32.ge_u
            br_if 1 (;@3;)
            i32.const 0
            i32.const 16
            local.get 13
            i32.add
            i32.store
            i32.const 4
            local.get 7
            local.get 13
            i32.sub
            i32.store
            local.get 0
            i32.const 0
            i32.const 1
            i32.const 8
            call 0
            i32.const 0
            i32.ne
            if ;; label = @5
              unreachable
            end
            i32.const 8
            i32.load
            local.tee 12
            i32.eqz
            local.get 12
            local.get 7
            local.get 13
            i32.sub
            i32.gt_u
            i32.or
            if ;; label = @5
              unreachable
            end
            local.get 13
            local.get 12
            i32.add
            local.set 13
            br 0 (;@4;)
          end
        end
        local.get 6
        local.get 7
        i32.add
        local.set 6
        br 0 (;@2;)
      end
    end
    local.get 6
  )
  (func (;10;) (type 53) (result (ref 2))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 8
    i32.const 0
    i32.const 0
    struct.new 2
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 4
    array.set 8
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 5
    array.set 8
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    i32.const 3
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 6
    array.set 8
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    i32.const 4
    local.set 7
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 7
    array.set 8
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    i32.const 5
    local.set 8
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 2)
        struct.get 2 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 2)
      struct.get 2 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 8
      local.set 3
      local.get 3
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 8)
      i32.const 0
      local.get 1
      ref.cast (ref 2)
      struct.get 2 1
      array.copy 8 8
      local.get 1
      ref.cast (ref 2)
      local.get 3
      struct.set 2 0
      local.get 1
      ref.cast (ref 2)
      local.get 3
      ref.cast (ref 8)
      array.len
      struct.set 2 2
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    local.get 8
    array.set 8
    local.get 1
    ref.cast (ref 2)
    local.get 1
    ref.cast (ref 2)
    struct.get 2 1
    i32.const 1
    i32.add
    struct.set 2 1
    local.get 0
    ref.cast (ref 2)
  )
  (func (;11;) (type 54) (param (ref 0)) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 1)
        struct.get 1 1
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;12;) (type 55) (param (ref 0)) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 1)
        struct.get 1 1
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;13;) (type 50) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
  )
  (func (;14;) (type 50) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.ne
  )
  (func (;15;) (type 50) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.eq
  )
  (func (;16;) (type 51) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.const 1
    i32.add
    i32.eq
  )
  (func (;17;) (type 56)
    (local eqref eqref eqref i32 eqref i32)
    call 10
    local.set 0
    local.get 0
    ref.cast (ref 2)
    ref.func 18
    struct.new 4
    call 1
    v128.const i32x4 0x72657665 0x72742079 0x00006575 0x00000000
    array.new_fixed 58 1
    i32.const 0
    i32.const 10
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    global.get 0
    call 1
    i32.eqz
    v128.const i32x4 0x72657665 0x61662079 0x0065736c 0x00000000
    array.new_fixed 58 1
    i32.const 0
    i32.const 11
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    global.get 1
    call 2
    v128.const i32x4 0x72657665 0x6e692079 0x65786564 0x00000064
    array.new_fixed 58 1
    i32.const 0
    i32.const 13
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    global.get 0
    call 3
    v128.const i32x4 0x656d6f73 0x75727420 0x00000065 0x00000000
    array.new_fixed 58 1
    i32.const 0
    i32.const 9
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    ref.func 19
    struct.new 5
    call 3
    i32.eqz
    v128.const i32x4 0x656d6f73 0x6c616620 0x00006573 0x00000000
    array.new_fixed 58 1
    i32.const 0
    i32.const 10
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    global.get 2
    call 4
    call 11
    i32.const 3
    i32.eq
    v128.const i32x4 0x646e6966 0x00000000 0x00000000 0x00000000
    array.new_fixed 58 1
    i32.const 0
    i32.const 4
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    global.get 2
    call 5
    call 12
    i32.const 2
    i32.eq
    v128.const i32x4 0x646e6966 0x646e6920 0x00007865 0x00000000
    array.new_fixed 58 1
    i32.const 0
    i32.const 10
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    global.get 3
    call 6
    call 11
    i32.const 5
    i32.eq
    v128.const i32x4 0x646e6966 0x73616c20 0x00000074 0x00000000
    array.new_fixed 58 1
    i32.const 0
    i32.const 9
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    global.get 3
    call 7
    call 12
    i32.const 4
    i32.eq
    v128.const i32x4 0x646e6966 0x73616c20 0x6e692074 0x00786564
    array.new_fixed 58 1
    i32.const 0
    i32.const 15
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 0
    call 8
    local.set 1
    local.get 0
    ref.cast (ref 2)
    ref.func 20
    local.get 1
    struct.new 6
    call 3
    v128.const i32x4 0x656d6f73 0x6f687320 0x63207472 0x75637269
    v128.const i32x4 0x00007469 0x00000000 0x00000000 0x00000000
    array.new_fixed 58 2
    i32.const 0
    i32.const 18
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 3
    array.get 8
    i32.const 2
    i32.eq
    v128.const i32x4 0x656d6f73 0x6c616320 0x6f63206c 0x00746e75
    array.new_fixed 58 1
    i32.const 0
    i32.const 15
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    i32.const 0
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 3
    local.get 5
    array.set 8
    local.get 0
    ref.cast (ref 2)
    ref.func 21
    local.get 1
    struct.new 7
    call 1
    i32.eqz
    v128.const i32x4 0x72657665 0x68732079 0x2074726f 0x63726963
    v128.const i32x4 0x00746975 0x00000000 0x00000000 0x00000000
    array.new_fixed 58 2
    i32.const 0
    i32.const 19
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 3
    array.get 8
    i32.const 3
    i32.eq
    v128.const i32x4 0x72657665 0x61632079 0x63206c6c 0x746e756f
    array.new_fixed 58 1
    i32.const 0
    i32.const 16
    struct.new 59
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x72702d79 0x63696465 0x73657461 0x6e75722d
    v128.const i32x4 0x656d6974 0x00000000 0x00000000 0x00000000
    array.new_fixed 58 3
    i32.const 0
    i32.const 36
    struct.new 60
    call 9
    drop
  )
  (func (;18;) (type 23) (param eqref i32) (result i32)
    local.get 1
    i32.const 0
    i32.gt_s
  )
  (func (;19;) (type 23) (param eqref i32) (result i32)
    local.get 1
    i32.const 9
    i32.gt_s
  )
  (func (;20;) (type 23) (param eqref i32) (result i32)
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 6)
    struct.get 6 1
    ref.cast (ref 2)
    i32.const 0
    local.set 3
    local.get 0
    ref.cast (ref 6)
    struct.get 6 1
    ref.cast (ref 2)
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 3
    array.get 8
    i32.const 1
    i32.add
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 3
    local.get 5
    array.set 8
    local.get 1
    i32.const 2
    i32.eq
  )
  (func (;21;) (type 23) (param eqref i32) (result i32)
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 7)
    struct.get 7 1
    ref.cast (ref 2)
    i32.const 0
    local.set 3
    local.get 0
    ref.cast (ref 7)
    struct.get 7 1
    ref.cast (ref 2)
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 3
    array.get 8
    i32.const 1
    i32.add
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 2)
    struct.get 2 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 8)
    local.get 3
    local.get 5
    array.set 8
    local.get 1
    i32.const 3
    i32.lt_s
  )
  (func (;22;) (type 57)
    ref.func 13
    struct.new 3
    global.set 0
    ref.func 16
    struct.new 3
    global.set 1
    ref.func 15
    struct.new 3
    global.set 2
    ref.func 14
    struct.new 3
    global.set 3
  )
)
