(module
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
  (type (;10;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;11;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field eqref) (field (mut i32))))
  (type (;13;) (sub (struct (field funcref))))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result eqref)))
  (type (;16;) (func (param eqref) (result (ref 11))))
  (type (;17;) (func (param eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref)))
  (type (;19;) (func (param eqref i32)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref eqref) (result (ref 11))))
  (type (;24;) (func (param eqref eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref)))
  (type (;26;) (func (param eqref eqref i32)))
  (type (;27;) (func (param eqref eqref) (result i32)))
  (type (;28;) (func (param eqref eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;30;) (func))
  (type (;31;) (func (param (ref 11) (ref 11) i32 i32 eqref)))
  (type (;32;) (func (param (ref 11) eqref)))
  (type (;33;) (func (param (ref 11) eqref) (result (ref 11))))
  (type (;34;) (func (param (ref 11) eqref)))
  (type (;35;) (func (param (ref 11) eqref) (result (ref 11))))
  (type (;36;) (func (param (ref 11) (ref 11) i32 i32 eqref)))
  (type (;37;) (func (param (ref 11) eqref)))
  (type (;38;) (func (param (ref 11) (ref 11) i32 i32 eqref)))
  (type (;39;) (func (param eqref eqref) (result i32)))
  (type (;40;) (func (param eqref eqref) (result i32)))
  (type (;41;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;42;) (func (param i32 eqref) (result i32)))
  (type (;43;) (struct (field i32) (field i32)))
  (type (;44;) (struct))
  (type (;45;) (struct))
  (type (;46;) (func (result (ref 11))))
  (type (;47;) (func (param i32) (result (ref 11))))
  (type (;48;) (func (result (ref 11))))
  (type (;49;) (func (result (ref 11))))
  (type (;50;) (func (param i32 i32) (result (ref 11))))
  (type (;51;) (func (param (ref 8)) (result i32)))
  (type (;52;) (func (param (ref 8)) (result i32)))
  (type (;53;) (func (param i32) (result i32)))
  (type (;54;) (func (param i32 i32) (result i32)))
  (type (;55;) (func (param i32 i32 i32) (result i32)))
  (type (;56;) (func (param i32) (result i32)))
  (type (;57;) (func (param i32 i32) (result i32)))
  (type (;58;) (func (param i32) (result i32)))
  (type (;59;) (func (param i32) (result i32)))
  (type (;60;) (func (param i32 i32) (result i32)))
  (type (;61;) (func (param i32) (result (ref 11))))
  (type (;62;) (func (param i32) (result eqref)))
  (type (;63;) (func (param i32 i32) (result i32)))
  (type (;64;) (func (param (ref 44) i32 i32) (result i32)))
  (type (;65;) (func (param (ref 45) (ref 43) (ref 43)) (result i32)))
  (type (;66;) (func (result (ref 11))))
  (type (;67;) (func (param eqref eqref) (result i32)))
  (type (;68;) (func (param (ref 43)) (result i32)))
  (type (;69;) (func (param (ref 43)) (result i32)))
  (type (;70;) (func))
  (type (;71;) (func))
  (type (;72;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;73;) (struct))
  (type (;74;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;75;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;76;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;77;) (array (mut v128)))
  (type (;78;) (struct (field (ref 77)) (field i32) (field i32)))
  (type (;79;) (struct (field (ref 77)) (field i32) (field i32)))
  (type (;80;) (struct (field (ref 77)) (field i32) (field i32)))
  (type (;81;) (struct (field (mut (ref 77))) (field (mut i32)) (field (mut i32))))
  (type (;82;) (struct (field (mut (ref 77))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 41)))
  (memory (;0;) 1)
  (export "main" (func 35))
  (export "memory" (memory 0))
  (func (;1;) (type 30))
  (func (;2;) (type 34) (param (ref 11) eqref)
    (local i32 eqref i32 i32 i32 i32 eqref i32 eqref i32 i32 i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    i32.const 2
    i32.lt_u
    if ;; label = @1
    else
      local.get 0
      local.set 8
      local.get 8
      ref.cast (ref 11)
      struct.get 11 1
      local.set 9
      local.get 9
      array.new_default 0
      local.set 10
      local.get 10
      ref.cast (ref 0)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 9
      array.copy 0 0
      local.get 10
      local.get 9
      local.get 9
      struct.new 11
      local.set 3
      i32.const 1
      local.set 4
      i32.const 1
      local.set 5
      i32.const 1
      local.set 11
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 11
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 4
              local.get 2
              i32.lt_u
              if ;; label = @6
                local.get 5
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 11)
                  local.get 3
                  ref.cast (ref 11)
                  local.get 4
                  local.get 2
                  local.get 1
                  call 4
                else
                  local.get 3
                  ref.cast (ref 11)
                  local.get 0
                  ref.cast (ref 11)
                  local.get 4
                  local.get 2
                  local.get 1
                  call 4
                end
                local.get 5
                i32.eqz
                local.set 5
                local.get 4
                local.get 2
                i32.const 2
                i32.div_u
                i32.gt_u
                if ;; label = @7
                  local.get 2
                  local.set 4
                else
                  local.get 4
                  i32.const 2
                  i32.mul
                  local.set 4
                end
                i32.const 1
                local.set 11
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 1
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
      i32.eqz
      if ;; label = @2
        i32.const 0
        local.set 13
        block ;; label = @3
          loop ;; label = @4
            block ;; label = @5
              i32.const 1
              if ;; label = @6
                local.get 13
                local.set 6
                local.get 6
                local.get 2
                i32.lt_u
                if ;; label = @7
                  local.get 3
                  local.get 6
                  local.set 9
                  local.set 8
                  local.get 9
                  local.get 8
                  ref.cast (ref 11)
                  struct.get 11 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 8
                  ref.cast (ref 11)
                  struct.get 11 0
                  ref.cast (ref 0)
                  local.get 9
                  array.get 0
                  local.set 7
                  local.get 0
                  local.get 6
                  local.set 9
                  local.get 7
                  local.set 12
                  local.set 8
                  local.get 9
                  local.get 8
                  ref.cast (ref 11)
                  struct.get 11 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 8
                  ref.cast (ref 11)
                  struct.get 11 0
                  ref.cast (ref 0)
                  local.get 9
                  local.get 12
                  array.set 0
                  local.get 6
                  i32.const 1
                  i32.add
                  local.set 13
                  br 3 (;@4;)
                  br 2 (;@5;)
                end
              end
              i32.const 1
              if ;; label = @6
                call 1
                br 3 (;@3;)
                br 1 (;@5;)
              end
              unreachable
            end
            unreachable
          end
          unreachable
        end
      else
      end
    end
  )
  (func (;3;) (type 35) (param (ref 11) eqref) (result (ref 11))
    (local eqref eqref i32 eqref)
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.set 4
    local.get 4
    array.new_default 5
    local.set 5
    local.get 5
    ref.cast (ref 5)
    i32.const 0
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    i32.const 0
    local.get 4
    array.copy 5 5
    local.get 5
    local.get 4
    local.get 4
    struct.new 11
    local.set 2
    local.get 2
    ref.cast (ref 11)
    local.get 1
    call 5
    local.get 2
    ref.cast (ref 11)
  )
  (func (;4;) (type 36) (param (ref 11) (ref 11) i32 i32 eqref)
    (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32)
    i32.const 0
    local.set 27
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 27
            local.set 5
            local.get 5
            local.get 3
            i32.lt_u
            if ;; label = @5
              local.get 2
              local.get 3
              local.get 5
              i32.sub
              i32.gt_u
              if (result i32) ;; label = @6
                local.get 3
              else
                local.get 5
                local.get 2
                i32.add
              end
              local.set 6
              local.get 2
              local.get 3
              local.get 6
              i32.sub
              i32.gt_u
              if (result i32) ;; label = @6
                local.get 3
              else
                local.get 6
                local.get 2
                i32.add
              end
              local.set 7
              local.get 5
              local.set 8
              local.get 6
              local.set 9
              local.get 5
              local.set 10
              i32.const 1
              local.set 22
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    local.get 22
                    i32.const 1
                    i32.eq
                    if ;; label = @9
                      local.get 8
                      local.get 6
                      i32.lt_u
                      if (result i32) ;; label = @10
                        local.get 9
                        local.get 7
                        i32.lt_u
                      else
                        i32.const 0
                      end
                      if ;; label = @10
                        local.get 0
                        local.get 8
                        local.set 18
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 18
                        array.get 0
                        local.set 11
                        local.get 0
                        local.get 9
                        local.set 18
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 18
                        array.get 0
                        local.set 12
                        local.get 4
                        ref.cast (ref 44)
                        local.get 12
                        local.get 11
                        call 28
                        if ;; label = @11
                          local.get 1
                          local.get 10
                          local.set 18
                          local.get 12
                          local.set 20
                          local.set 17
                          local.get 18
                          local.get 17
                          ref.cast (ref 11)
                          struct.get 11 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 17
                          ref.cast (ref 11)
                          struct.get 11 0
                          ref.cast (ref 0)
                          local.get 18
                          local.get 20
                          array.set 0
                          local.get 9
                          i32.const 1
                          i32.add
                          local.set 9
                        else
                          local.get 1
                          local.get 10
                          local.set 18
                          local.get 11
                          local.set 21
                          local.set 17
                          local.get 18
                          local.get 17
                          ref.cast (ref 11)
                          struct.get 11 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 17
                          ref.cast (ref 11)
                          struct.get 11 0
                          ref.cast (ref 0)
                          local.get 18
                          local.get 21
                          array.set 0
                          local.get 8
                          i32.const 1
                          i32.add
                          local.set 8
                        end
                        local.get 10
                        i32.const 1
                        i32.add
                        local.set 10
                        i32.const 1
                        local.set 22
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 8
              local.set 24
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 24
                      local.set 13
                      local.get 13
                      local.get 6
                      i32.lt_u
                      if ;; label = @10
                        local.get 0
                        local.get 13
                        local.set 18
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 18
                        array.get 0
                        local.set 14
                        local.get 1
                        local.get 10
                        local.set 18
                        local.get 14
                        local.set 23
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 18
                        local.get 23
                        array.set 0
                        local.get 10
                        i32.const 1
                        i32.add
                        local.set 10
                        local.get 13
                        i32.const 1
                        i32.add
                        local.set 24
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 9
              local.set 26
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 26
                      local.set 15
                      local.get 15
                      local.get 7
                      i32.lt_u
                      if ;; label = @10
                        local.get 0
                        local.get 15
                        local.set 18
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 18
                        array.get 0
                        local.set 16
                        local.get 1
                        local.get 10
                        local.set 18
                        local.get 16
                        local.set 25
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 0)
                        local.get 18
                        local.get 25
                        array.set 0
                        local.get 10
                        i32.const 1
                        i32.add
                        local.set 10
                        local.get 15
                        i32.const 1
                        i32.add
                        local.set 26
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 7
              local.set 27
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 1
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;5;) (type 37) (param (ref 11) eqref)
    (local i32 eqref i32 i32 i32 eqref eqref i32 eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    i32.const 2
    i32.lt_u
    if ;; label = @1
    else
      local.get 0
      local.set 8
      local.get 8
      ref.cast (ref 11)
      struct.get 11 1
      local.set 9
      local.get 9
      array.new_default 5
      local.set 10
      local.get 10
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 9
      array.copy 5 5
      local.get 10
      local.get 9
      local.get 9
      struct.new 11
      local.set 3
      i32.const 1
      local.set 4
      i32.const 1
      local.set 5
      i32.const 1
      local.set 11
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 11
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 4
              local.get 2
              i32.lt_u
              if ;; label = @6
                local.get 5
                if ;; label = @7
                  local.get 0
                  ref.cast (ref 11)
                  local.get 3
                  ref.cast (ref 11)
                  local.get 4
                  local.get 2
                  local.get 1
                  call 6
                else
                  local.get 3
                  ref.cast (ref 11)
                  local.get 0
                  ref.cast (ref 11)
                  local.get 4
                  local.get 2
                  local.get 1
                  call 6
                end
                local.get 5
                i32.eqz
                local.set 5
                local.get 4
                local.get 2
                i32.const 2
                i32.div_u
                i32.gt_u
                if ;; label = @7
                  local.get 2
                  local.set 4
                else
                  local.get 4
                  i32.const 2
                  i32.mul
                  local.set 4
                end
                i32.const 1
                local.set 11
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 1
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
      i32.eqz
      if ;; label = @2
        i32.const 0
        local.set 13
        block ;; label = @3
          loop ;; label = @4
            block ;; label = @5
              i32.const 1
              if ;; label = @6
                local.get 13
                local.set 6
                local.get 6
                local.get 2
                i32.lt_u
                if ;; label = @7
                  local.get 3
                  local.get 6
                  local.set 9
                  local.set 8
                  local.get 9
                  local.get 8
                  ref.cast (ref 11)
                  struct.get 11 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 8
                  ref.cast (ref 11)
                  struct.get 11 0
                  ref.cast (ref 5)
                  local.get 9
                  array.get 5
                  local.set 7
                  local.get 0
                  local.get 6
                  local.set 9
                  local.get 7
                  local.set 12
                  local.set 8
                  local.get 9
                  local.get 8
                  ref.cast (ref 11)
                  struct.get 11 1
                  i32.ge_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 8
                  ref.cast (ref 11)
                  struct.get 11 0
                  ref.cast (ref 5)
                  local.get 9
                  local.get 12
                  array.set 5
                  local.get 6
                  i32.const 1
                  i32.add
                  local.set 13
                  br 3 (;@4;)
                  br 2 (;@5;)
                end
              end
              i32.const 1
              if ;; label = @6
                call 1
                br 3 (;@3;)
                br 1 (;@5;)
              end
              unreachable
            end
            unreachable
          end
          unreachable
        end
      else
      end
    end
  )
  (func (;6;) (type 38) (param (ref 11) (ref 11) i32 i32 eqref)
    (local i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref i32 eqref eqref i32 eqref eqref eqref i32 eqref i32 eqref i32 i32)
    i32.const 0
    local.set 27
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 27
            local.set 5
            local.get 5
            local.get 3
            i32.lt_u
            if ;; label = @5
              local.get 2
              local.get 3
              local.get 5
              i32.sub
              i32.gt_u
              if (result i32) ;; label = @6
                local.get 3
              else
                local.get 5
                local.get 2
                i32.add
              end
              local.set 6
              local.get 2
              local.get 3
              local.get 6
              i32.sub
              i32.gt_u
              if (result i32) ;; label = @6
                local.get 3
              else
                local.get 6
                local.get 2
                i32.add
              end
              local.set 7
              local.get 5
              local.set 8
              local.get 6
              local.set 9
              local.get 5
              local.set 10
              i32.const 1
              local.set 22
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    local.get 22
                    i32.const 1
                    i32.eq
                    if ;; label = @9
                      local.get 8
                      local.get 6
                      i32.lt_u
                      if (result i32) ;; label = @10
                        local.get 9
                        local.get 7
                        i32.lt_u
                      else
                        i32.const 0
                      end
                      if ;; label = @10
                        local.get 0
                        local.get 8
                        local.set 18
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 5)
                        local.get 18
                        array.get 5
                        local.set 11
                        local.get 0
                        local.get 9
                        local.set 18
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 5)
                        local.get 18
                        array.get 5
                        local.set 12
                        local.get 4
                        ref.cast (ref 45)
                        local.get 12
                        ref.cast (ref 43)
                        local.get 11
                        ref.cast (ref 43)
                        call 29
                        if ;; label = @11
                          local.get 1
                          local.get 10
                          local.set 18
                          local.get 12
                          local.set 20
                          local.set 17
                          local.get 18
                          local.get 17
                          ref.cast (ref 11)
                          struct.get 11 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 17
                          ref.cast (ref 11)
                          struct.get 11 0
                          ref.cast (ref 5)
                          local.get 18
                          local.get 20
                          array.set 5
                          local.get 9
                          i32.const 1
                          i32.add
                          local.set 9
                        else
                          local.get 1
                          local.get 10
                          local.set 18
                          local.get 11
                          local.set 21
                          local.set 17
                          local.get 18
                          local.get 17
                          ref.cast (ref 11)
                          struct.get 11 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 17
                          ref.cast (ref 11)
                          struct.get 11 0
                          ref.cast (ref 5)
                          local.get 18
                          local.get 21
                          array.set 5
                          local.get 8
                          i32.const 1
                          i32.add
                          local.set 8
                        end
                        local.get 10
                        i32.const 1
                        i32.add
                        local.set 10
                        i32.const 1
                        local.set 22
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 8
              local.set 24
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 24
                      local.set 13
                      local.get 13
                      local.get 6
                      i32.lt_u
                      if ;; label = @10
                        local.get 0
                        local.get 13
                        local.set 18
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 5)
                        local.get 18
                        array.get 5
                        local.set 14
                        local.get 1
                        local.get 10
                        local.set 18
                        local.get 14
                        local.set 23
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 5)
                        local.get 18
                        local.get 23
                        array.set 5
                        local.get 10
                        i32.const 1
                        i32.add
                        local.set 10
                        local.get 13
                        i32.const 1
                        i32.add
                        local.set 24
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 9
              local.set 26
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 26
                      local.set 15
                      local.get 15
                      local.get 7
                      i32.lt_u
                      if ;; label = @10
                        local.get 0
                        local.get 15
                        local.set 18
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 5)
                        local.get 18
                        array.get 5
                        local.set 16
                        local.get 1
                        local.get 10
                        local.set 18
                        local.get 16
                        local.set 25
                        local.set 17
                        local.get 18
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 17
                        ref.cast (ref 11)
                        struct.get 11 0
                        ref.cast (ref 5)
                        local.get 18
                        local.get 25
                        array.set 5
                        local.get 10
                        i32.const 1
                        i32.add
                        local.set 10
                        local.get 15
                        i32.const 1
                        i32.add
                        local.set 26
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 1
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 7
              local.set 27
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 1
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
  )
  (func (;7;) (type 39) (param eqref eqref) (result i32)
    (local (ref 78) (ref 78) (ref 77) (ref 77) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 78)
    local.set 2
    local.get 1
    ref.cast (ref 78)
    local.set 3
    local.get 2
    struct.get 78 2
    local.tee 6
    local.get 3
    struct.get 78 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 78 0
    local.set 4
    local.get 3
    struct.get 78 0
    local.set 5
    local.get 2
    struct.get 78 1
    local.set 7
    local.get 3
    struct.get 78 1
    local.set 8
    i32.const 0
    local.set 9
    loop ;; label = @1
      local.get 9
      local.get 6
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 9
      i32.const 16
      i32.add
      local.get 6
      i32.le_u
      if ;; label = @2
        local.get 7
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 77
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 77
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 77
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 10
        end
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 77
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 77
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 77
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
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
        local.get 10
        local.get 11
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 7
        i32.const 16
        i32.add
        local.set 7
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        br 1 (;@1;)
      end
      local.get 4
      local.get 7
      i32.const 4
      i32.shr_u
      array.get 77
      local.get 7
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 77
      local.get 8
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i32.ne
      if ;; label = @2
        i32.const 0
        return
      end
      local.get 7
      i32.const 1
      i32.add
      local.set 7
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;8;) (type 40) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 7
  )
  (func (;9;) (type 42) (param i32 eqref) (result i32)
    (local (ref 79) (ref 77) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 79)
    local.set 2
    local.get 2
    struct.get 79 0
    local.set 3
    local.get 2
    struct.get 79 1
    local.set 4
    local.get 2
    struct.get 79 2
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
              array.get 77
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
              array.get 77
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
              array.get 77
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
              array.get 77
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
                array.get 77
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 77
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
                array.get 77
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
            array.get 77
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
  (func (;10;) (type 46) (result (ref 11))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;11;) (type 47) (param i32) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    array.new_default 0
    i32.const 0
    local.get 2
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;12;) (type 48) (result (ref 11))
    (local eqref i32 eqref)
    i32.const 3
    local.set 1
    local.get 1
    array.new_default 5
    i32.const 0
    local.get 1
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;13;) (type 49) (result (ref 11))
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    local.set 0
    local.get 0
    i32.const 1
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 2
    local.set 5
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 5
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 3
    local.set 6
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 4
    local.set 7
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 7
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 5
    local.set 8
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 11)
      struct.get 11 2
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
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      struct.set 11 0
      local.get 1
      ref.cast (ref 11)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    array.set 0
    local.get 1
    ref.cast (ref 11)
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
  )
  (func (;14;) (type 50) (param i32 i32) (result (ref 11))
    (local eqref eqref i32 eqref i32 i32)
    i32.const 2
    local.set 4
    local.get 4
    array.new_default 0
    i32.const 0
    local.get 4
    struct.new 11
    local.set 2
    local.get 2
    local.get 0
    local.set 6
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 3
    ref.cast (ref 11)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 2
    local.get 1
    local.set 7
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 7
    array.set 0
    local.get 3
    ref.cast (ref 11)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 2
    ref.cast (ref 11)
  )
  (func (;15;) (type 51) (param (ref 8)) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 9)
        struct.get 9 1
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;16;) (type 52) (param (ref 8)) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          local.set 3
          br 2 (;@1;)
        end
        local.get 2
        ref.cast (ref 9)
        struct.get 9 1
        local.set 1
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;17;) (type 53) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.mul
  )
  (func (;18;) (type 54) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
  )
  (func (;19;) (type 55) (param i32 i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
    local.get 2
    i32.add
  )
  (func (;20;) (type 56) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
  )
  (func (;21;) (type 57) (param i32 i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 1
      i32.const 2
      i32.rem_u
      i32.const 1
      i32.eq
    else
      i32.const 0
    end
  )
  (func (;22;) (type 58) (param i32) (result i32)
    local.get 0
    i32.const 3
    i32.eq
  )
  (func (;23;) (type 59) (param i32) (result i32)
    local.get 0
    i32.const 2
    i32.rem_s
    i32.const 0
    i32.ne
  )
  (func (;24;) (type 60) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.const 1
    i32.add
    i32.eq
  )
  (func (;25;) (type 61) (param i32) (result (ref 11))
    local.get 0
    local.get 0
    i32.const 10
    i32.add
    call 14
    ref.cast (ref 11)
  )
  (func (;26;) (type 62) (param i32) (result eqref)
    local.get 0
    i32.const 1
    i32.eq
    if (result eqref) ;; label = @1
      v128.const i32x4 0x00656e6f 0x00000000 0x00000000 0x00000000
      array.new_fixed 77 1
      i32.const 0
      i32.const 3
      struct.new 78
    else
      local.get 0
      i32.const 2
      i32.eq
      if (result eqref) ;; label = @2
        v128.const i32x4 0x006f7774 0x00000000 0x00000000 0x00000000
        array.new_fixed 77 1
        i32.const 0
        i32.const 3
        struct.new 78
      else
        v128.const i32x4 0x6568746f 0x00000072 0x00000000 0x00000000
        array.new_fixed 77 1
        i32.const 0
        i32.const 5
        struct.new 78
      end
    end
  )
  (func (;27;) (type 63) (param i32 i32) (result i32)
    local.get 1
    i32.const 0
    i32.gt_s
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      i32.add
    else
      local.get 0
    end
  )
  (func (;28;) (type 64) (param (ref 44) i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.gt_s
  )
  (func (;29;) (type 65) (param (ref 45) (ref 43) (ref 43)) (result i32)
    local.get 1
    ref.cast (ref 43)
    struct.get 43 0
    local.get 2
    ref.cast (ref 43)
    struct.get 43 0
    i32.lt_s
  )
  (func (;30;) (type 66) (result (ref 11))
    (local eqref i32 eqref)
    i32.const 5
    local.set 1
    local.get 1
    array.new_default 5
    i32.const 0
    local.get 1
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;31;) (type 67) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 8
  )
  (func (;32;) (type 68) (param (ref 43)) (result i32)
    local.get 0
    ref.cast (ref 43)
    struct.get 43 0
  )
  (func (;33;) (type 69) (param (ref 43)) (result i32)
    local.get 0
    ref.cast (ref 43)
    struct.get 43 1
  )
  (func (;34;) (type 70)
    (local eqref eqref (ref 43) (ref 43) (ref 43) (ref 43) (ref 43) (ref 43) eqref i32 eqref eqref eqref eqref eqref eqref)
    call 13
    local.set 0
    local.get 0
    ref.cast (ref 11)
    struct.new 44
    call 2
    local.get 0
    i32.const 0
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 9
    array.get 0
    i32.const 5
    i32.eq
    v128.const i32x4 0x63736564 0x69646e65 0x6620676e 0x74737269
    array.new_fixed 77 1
    i32.const 0
    i32.const 16
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 9
    array.get 0
    i32.const 4
    i32.eq
    v128.const i32x4 0x63736564 0x69646e65 0x7320676e 0x6e6f6365
    v128.const i32x4 0x00000064 0x00000000 0x00000000 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 17
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 9
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x63736564 0x69646e65 0x7420676e 0x64726968
    array.new_fixed 77 1
    i32.const 0
    i32.const 16
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 9
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x63736564 0x69646e65 0x6620676e 0x7472756f
    v128.const i32x4 0x00000068 0x00000000 0x00000000 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 17
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 9
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x63736564 0x69646e65 0x6620676e 0x68746669
    array.new_fixed 77 1
    i32.const 0
    i32.const 16
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 30
    local.set 0
    local.get 0
    i32.const 2
    i32.const 0
    struct.new 43
    local.set 11
    local.set 8
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 8
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 9
      local.get 9
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 9
      array.new_default 5
      local.set 10
      local.get 10
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 8
      ref.cast (ref 11)
      local.get 10
      struct.set 11 0
      local.get 8
      ref.cast (ref 11)
      local.get 10
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 11
    array.set 5
    local.get 8
    ref.cast (ref 11)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 1
    i32.const 1
    struct.new 43
    local.set 12
    local.set 8
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 8
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 9
      local.get 9
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 9
      array.new_default 5
      local.set 10
      local.get 10
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 8
      ref.cast (ref 11)
      local.get 10
      struct.set 11 0
      local.get 8
      ref.cast (ref 11)
      local.get 10
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 12
    array.set 5
    local.get 8
    ref.cast (ref 11)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 2
    i32.const 2
    struct.new 43
    local.set 13
    local.set 8
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 8
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 9
      local.get 9
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 9
      array.new_default 5
      local.set 10
      local.get 10
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 8
      ref.cast (ref 11)
      local.get 10
      struct.set 11 0
      local.get 8
      ref.cast (ref 11)
      local.get 10
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 13
    array.set 5
    local.get 8
    ref.cast (ref 11)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 1
    i32.const 3
    struct.new 43
    local.set 14
    local.set 8
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 8
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 9
      local.get 9
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 9
      array.new_default 5
      local.set 10
      local.get 10
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 8
      ref.cast (ref 11)
      local.get 10
      struct.set 11 0
      local.get 8
      ref.cast (ref 11)
      local.get 10
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 14
    array.set 5
    local.get 8
    ref.cast (ref 11)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    i32.const 2
    i32.const 4
    struct.new 43
    local.set 15
    local.set 8
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 8
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 8
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 9
      local.get 9
      local.get 8
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 9
      array.new_default 5
      local.set 10
      local.get 10
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 5)
      i32.const 0
      local.get 8
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 5 5
      local.get 8
      ref.cast (ref 11)
      local.get 10
      struct.set 11 0
      local.get 8
      ref.cast (ref 11)
      local.get 10
      ref.cast (ref 5)
      array.len
      struct.set 11 2
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    local.get 15
    array.set 5
    local.get 8
    ref.cast (ref 11)
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    struct.new 45
    call 3
    local.set 1
    local.get 0
    i32.const 0
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 9
    array.get 5
    ref.cast (ref 43)
    ref.cast (ref 43)
    local.set 2
    local.get 1
    i32.const 0
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 9
    array.get 5
    ref.cast (ref 43)
    ref.cast (ref 43)
    local.set 3
    local.get 1
    i32.const 1
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 9
    array.get 5
    ref.cast (ref 43)
    ref.cast (ref 43)
    local.set 4
    local.get 1
    i32.const 2
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 9
    array.get 5
    ref.cast (ref 43)
    ref.cast (ref 43)
    local.set 5
    local.get 1
    i32.const 3
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 9
    array.get 5
    ref.cast (ref 43)
    ref.cast (ref 43)
    local.set 6
    local.get 1
    i32.const 4
    local.set 9
    local.set 8
    local.get 9
    local.get 8
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 8
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 5)
    local.get 9
    array.get 5
    ref.cast (ref 43)
    ref.cast (ref 43)
    local.set 7
    local.get 2
    call 33
    i32.const 0
    i32.eq
    v128.const i32x4 0x74737563 0x73206d6f 0x6574726f 0x6f732064
    v128.const i32x4 0x65637275 0x00000000 0x00000000 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 20
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    call 32
    i32.const 1
    i32.eq
    v128.const i32x4 0x62617473 0x6b20656c 0x66207965 0x74737269
    array.new_fixed 77 1
    i32.const 0
    i32.const 16
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    call 33
    i32.const 1
    i32.eq
    v128.const i32x4 0x62617473 0x6520656c 0x6c617571 0x72696620
    v128.const i32x4 0x6f207473 0x72656472 0x00000000 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 24
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    call 33
    i32.const 3
    i32.eq
    v128.const i32x4 0x62617473 0x6520656c 0x6c617571 0x63657320
    v128.const i32x4 0x20646e6f 0x6564726f 0x00000072 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 25
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    call 32
    i32.const 2
    i32.eq
    v128.const i32x4 0x62617473 0x6b20656c 0x73207965 0x6e6f6365
    v128.const i32x4 0x72672064 0x0070756f 0x00000000 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 23
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 5
    call 33
    i32.const 0
    i32.eq
    v128.const i32x4 0x62617473 0x7320656c 0x6e6f6365 0x72672064
    v128.const i32x4 0x2070756f 0x73726966 0x00000074 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 25
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 6
    call 33
    i32.const 2
    i32.eq
    v128.const i32x4 0x62617473 0x7320656c 0x6e6f6365 0x72672064
    v128.const i32x4 0x2070756f 0x6f636573 0x0000646e 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 26
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 7
    call 33
    i32.const 4
    i32.eq
    v128.const i32x4 0x62617473 0x7320656c 0x6e6f6365 0x72672064
    v128.const i32x4 0x2070756f 0x72696874 0x00000064 0x00000000
    array.new_fixed 77 2
    i32.const 0
    i32.const 25
    struct.new 78
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;35;) (type 71)
    call 34
    i32.const 1
    v128.const i32x4 0x6c6c6f63 0x69746365 0x3a736e6f 0x61727261
    v128.const i32x4 0x6f632d79 0x7261706d 0x726f7461 0x6e75722d
    v128.const i32x4 0x656d6974 0x00000000 0x00000000 0x00000000
    array.new_fixed 77 3
    i32.const 0
    i32.const 36
    struct.new 79
    call 9
    drop
  )
)
