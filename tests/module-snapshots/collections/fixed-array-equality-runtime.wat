(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param (ref 5) (ref 5)) (result i32)))
  (type (;9;) (func (param (ref 5) (ref 5)) (result i32)))
  (type (;10;) (func (param (ref 5) (ref 5)) (result i32)))
  (type (;11;) (func (param (ref 0) (ref 0)) (result i32)))
  (type (;12;) (func (param (ref 0) (ref 0)) (result i32)))
  (type (;13;) (func (param (ref 5) (ref 5)) (result i32)))
  (type (;14;) (func (param (ref 5) (ref 5)) (result i32)))
  (type (;15;) (func (param (ref 1) (ref 1)) (result i32)))
  (type (;16;) (func (param (ref 0) (ref 0)) (result i32)))
  (type (;17;) (func (param (ref 5) (ref 5)) (result i32)))
  (type (;18;) (func (param (ref 1) (ref 1)) (result i32)))
  (type (;19;) (struct (field i32)))
  (type (;20;) (func (param (ref 19) (ref 19)) (result i32)))
  (type (;21;) (func (param (ref 19) (ref 19)) (result i32)))
  (type (;22;) (func (param i32) (result (ref 19))))
  (type (;23;) (func))
  (type (;24;) (array (mut v128)))
  (type (;25;) (struct (field (ref 24)) (field i32) (field i32)))
  (type (;26;) (struct (field (ref 24)) (field i32) (field i32)))
  (type (;27;) (struct (field (ref 24)) (field i32) (field i32)))
  (type (;28;) (struct (field (mut (ref 24))) (field (mut i32)) (field (mut i32))))
  (type (;29;) (struct (field (mut (ref 24))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 11))
  (func (;0;) (type 11) (param (ref 0) (ref 0)) (result i32)
    local.get 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    call 5
  )
  (func (;1;) (type 12) (param (ref 0) (ref 0)) (result i32)
    local.get 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    call 5
    i32.eqz
  )
  (func (;2;) (type 13) (param (ref 5) (ref 5)) (result i32)
    local.get 0
    ref.cast (ref 5)
    local.get 1
    ref.cast (ref 5)
    call 6
  )
  (func (;3;) (type 14) (param (ref 5) (ref 5)) (result i32)
    local.get 0
    ref.cast (ref 5)
    local.get 1
    ref.cast (ref 5)
    call 6
    i32.eqz
  )
  (func (;4;) (type 15) (param (ref 1) (ref 1)) (result i32)
    local.get 0
    ref.cast (ref 1)
    local.get 1
    ref.cast (ref 1)
    call 7
  )
  (func (;5;) (type 16) (param (ref 0) (ref 0)) (result i32)
    (local i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 0)
    array.len
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 0)
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
  (func (;6;) (type 17) (param (ref 5) (ref 5)) (result i32)
    (local i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 5)
    array.len
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 5)
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
                ref.cast (ref 19)
                local.get 1
                ref.cast (ref 5)
                local.get 3
                array.get 5
                ref.cast (ref 19)
                call 8
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
  (func (;7;) (type 18) (param (ref 1) (ref 1)) (result i32)
    (local i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 1)
    array.len
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 1)
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
  (func (;8;) (type 20) (param (ref 19) (ref 19)) (result i32)
    i32.const 1
    if (result i32) ;; label = @1
      local.get 0
      struct.get 19 0
      local.get 1
      struct.get 19 0
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;9;) (type 21) (param (ref 19) (ref 19)) (result i32)
    local.get 0
    local.get 1
    call 8
    i32.eqz
  )
  (func (;10;) (type 22) (param i32) (result (ref 19))
    local.get 0
    struct.new 19
    ref.cast (ref 19)
  )
  (func (;11;) (type 23)
    (local eqref eqref eqref eqref i32)
    i32.const 3
    local.set 4
    i32.const 7
    local.get 4
    array.new 0
    local.set 0
    i32.const 3
    local.set 4
    i32.const 7
    local.get 4
    array.new 0
    local.set 1
    i32.const 3
    local.set 4
    i32.const 7
    local.get 4
    array.new 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    i32.const 2
    i32.const 8
    array.set 0
    local.get 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    call 0
    v128.const i32x4 0x61757165 0x6373206c 0x72616c61 0x78696620
    v128.const i32x4 0x61206465 0x79617272 0x69642073 0x72656666
    array.new_fixed 24 2
    i32.const 0
    i32.const 32
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 0)
    call 1
    v128.const i32x4 0x66666964 0x6e657265 0x63732074 0x72616c61
    v128.const i32x4 0x78696620 0x61206465 0x79617272 0x6f632073
    v128.const i32x4 0x7261706d 0x71652065 0x006c6175 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 43
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    local.set 4
    i32.const 7
    local.get 4
    array.new 0
    call 1
    v128.const i32x4 0x66666964 0x6e657265 0x656c2074 0x6874676e
    v128.const i32x4 0x6f632073 0x7261706d 0x71652065 0x006c6175
    array.new_fixed 24 2
    i32.const 0
    i32.const 31
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 4
    i32.const 4
    call 10
    local.get 4
    array.new 5
    local.set 0
    i32.const 2
    local.set 4
    i32.const 4
    call 10
    local.get 4
    array.new 5
    local.set 1
    i32.const 2
    local.set 4
    i32.const 4
    call 10
    local.get 4
    array.new 5
    local.set 2
    local.get 2
    ref.cast (ref 5)
    i32.const 1
    i32.const 5
    call 10
    array.set 5
    local.get 0
    ref.cast (ref 5)
    local.get 1
    ref.cast (ref 5)
    call 2
    v128.const i32x4 0x61757165 0x6572206c 0x65726566 0x2065636e
    v128.const i32x4 0x65786966 0x72612064 0x73796172 0x66696420
    v128.const i32x4 0x00726566 0x00000000 0x00000000 0x00000000
    array.new_fixed 24 3
    i32.const 0
    i32.const 35
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 5)
    local.get 2
    ref.cast (ref 5)
    call 3
    v128.const i32x4 0x66666964 0x6e657265 0x65722074 0x65726566
    v128.const i32x4 0x2065636e 0x65786966 0x72612064 0x73796172
    v128.const i32x4 0x6d6f6320 0x65726170 0x75716520 0x00006c61
    array.new_fixed 24 3
    i32.const 0
    i32.const 46
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 4
    i64.const 9
    local.get 4
    array.new 1
    local.set 0
    i32.const 2
    local.set 4
    i64.const 9
    local.get 4
    array.new 1
    local.set 1
    local.get 0
    ref.cast (ref 1)
    local.get 1
    ref.cast (ref 1)
    call 4
    v128.const i32x4 0x61757165 0x6977206c 0x66206564 0x64657869
    v128.const i32x4 0x72726120 0x20737961 0x66666964 0x00007265
    array.new_fixed 24 2
    i32.const 0
    i32.const 30
    struct.new 25
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
