(module
  (type (;0;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;1;) (func (param i32 eqref) (result i32)))
  (type (;2;) (sub (struct (field i32))))
  (type (;3;) (sub final 2 (struct (field i32) (field i32))))
  (type (;4;) (sub (struct (field i32))))
  (type (;5;) (sub final 4 (struct (field i32) (field i32))))
  (type (;6;) (sub (struct (field i32))))
  (type (;7;) (sub final 6 (struct (field i32) (field (ref 4)))))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field (ref 6)))))
  (type (;10;) (sub (struct (field i32))))
  (type (;11;) (sub final 10 (struct (field i32) (field (ref 8)))))
  (type (;12;) (sub (struct (field i32))))
  (type (;13;) (sub final 12 (struct (field i32) (field (ref 10)))))
  (type (;14;) (sub (struct (field i32))))
  (type (;15;) (sub final 14 (struct (field i32) (field (ref 12)))))
  (type (;16;) (sub (struct (field i32))))
  (type (;17;) (sub final 16 (struct (field i32) (field (ref 14)))))
  (type (;18;) (sub (struct (field i32))))
  (type (;19;) (sub final 18 (struct (field i32) (field (ref 16)))))
  (type (;20;) (sub (struct (field i32))))
  (type (;21;) (sub final 20 (struct (field i32) (field (ref 18)))))
  (type (;22;) (func (param (ref 2)) (result i32)))
  (type (;23;) (func (param (ref 20)) (result i32)))
  (type (;24;) (func (result i32)))
  (type (;25;) (array (mut v128)))
  (type (;26;) (struct (field (ref 25)) (field i32) (field i32)))
  (type (;27;) (struct (field (ref 25)) (field i32) (field i32)))
  (type (;28;) (struct (field (ref 25)) (field i32) (field i32)))
  (type (;29;) (struct (field (mut (ref 25))) (field (mut i32)) (field (mut i32))))
  (type (;30;) (struct (field (mut (ref 25))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 0)))
  (memory (;0;) 1)
  (export "main" (func 4))
  (export "memory" (memory 0))
  (func (;1;) (type 1) (param i32 eqref) (result i32)
    (local (ref 27) (ref 25) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 27)
    local.set 2
    local.get 2
    struct.get 27 0
    local.set 3
    local.get 2
    struct.get 27 1
    local.set 4
    local.get 2
    struct.get 27 2
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
              array.get 25
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
              array.get 25
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
              array.get 25
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
              array.get 25
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
                array.get 25
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 25
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
                array.get 25
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
            array.get 25
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
  (func (;2;) (type 22) (param (ref 2)) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 2
    block ;; label = @1
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 2
        ref.cast (ref 3)
        struct.get 3 1
        local.set 1
        i32.const 1
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 2
        ref.cast (ref 2)
        struct.get 2 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          local.get 2
          ref.cast (ref 3)
          struct.get 3 1
          local.set 1
          i32.const 1
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 2
          ref.cast (ref 2)
          struct.get 2 0
          i32.const 2
          i32.eq
          if (result i32) ;; label = @4
            local.get 2
            ref.cast (ref 3)
            struct.get 3 1
            local.set 1
            i32.const 1
          else
            i32.const 0
          end
          if (result i32) ;; label = @4
            i32.const 1
          else
            local.get 2
            ref.cast (ref 2)
            struct.get 2 0
            i32.const 3
            i32.eq
            if (result i32) ;; label = @5
              local.get 2
              ref.cast (ref 3)
              struct.get 3 1
              local.set 1
              i32.const 1
            else
              i32.const 0
            end
            if (result i32) ;; label = @5
              i32.const 1
            else
              local.get 2
              ref.cast (ref 2)
              struct.get 2 0
              i32.const 4
              i32.eq
              if (result i32) ;; label = @6
                local.get 2
                ref.cast (ref 3)
                struct.get 3 1
                local.set 1
                i32.const 1
              else
                i32.const 0
              end
              if (result i32) ;; label = @6
                i32.const 1
              else
                local.get 2
                ref.cast (ref 2)
                struct.get 2 0
                i32.const 5
                i32.eq
                if (result i32) ;; label = @7
                  local.get 2
                  ref.cast (ref 3)
                  struct.get 3 1
                  local.set 1
                  i32.const 1
                else
                  i32.const 0
                end
                if (result i32) ;; label = @7
                  i32.const 1
                else
                  local.get 2
                  ref.cast (ref 2)
                  struct.get 2 0
                  i32.const 6
                  i32.eq
                  if (result i32) ;; label = @8
                    local.get 2
                    ref.cast (ref 3)
                    struct.get 3 1
                    local.set 1
                    i32.const 1
                  else
                    i32.const 0
                  end
                  if (result i32) ;; label = @8
                    i32.const 1
                  else
                    local.get 2
                    ref.cast (ref 2)
                    struct.get 2 0
                    i32.const 7
                    i32.eq
                    if (result i32) ;; label = @9
                      local.get 2
                      ref.cast (ref 3)
                      struct.get 3 1
                      local.set 1
                      i32.const 1
                    else
                      i32.const 0
                    end
                    if (result i32) ;; label = @9
                      i32.const 1
                    else
                      local.get 2
                      ref.cast (ref 2)
                      struct.get 2 0
                      i32.const 8
                      i32.eq
                      if (result i32) ;; label = @10
                        local.get 2
                        ref.cast (ref 3)
                        struct.get 3 1
                        local.set 1
                        i32.const 1
                      else
                        i32.const 0
                      end
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 2
                        ref.cast (ref 2)
                        struct.get 2 0
                        i32.const 9
                        i32.eq
                        if (result i32) ;; label = @11
                          local.get 2
                          ref.cast (ref 3)
                          struct.get 3 1
                          local.set 1
                          i32.const 1
                        else
                          i32.const 0
                        end
                        if (result i32) ;; label = @11
                          i32.const 1
                        else
                          local.get 2
                          ref.cast (ref 2)
                          struct.get 2 0
                          i32.const 10
                          i32.eq
                          if (result i32) ;; label = @12
                            local.get 2
                            ref.cast (ref 3)
                            struct.get 3 1
                            local.set 1
                            i32.const 1
                          else
                            i32.const 0
                          end
                          if (result i32) ;; label = @12
                            i32.const 1
                          else
                            local.get 2
                            ref.cast (ref 2)
                            struct.get 2 0
                            i32.const 11
                            i32.eq
                            if (result i32) ;; label = @13
                              local.get 2
                              ref.cast (ref 3)
                              struct.get 3 1
                              local.set 1
                              i32.const 1
                            else
                              i32.const 0
                            end
                            if (result i32) ;; label = @13
                              i32.const 1
                            else
                              local.get 2
                              ref.cast (ref 2)
                              struct.get 2 0
                              i32.const 12
                              i32.eq
                              if (result i32) ;; label = @14
                                local.get 2
                                ref.cast (ref 3)
                                struct.get 3 1
                                local.set 1
                                i32.const 1
                              else
                                i32.const 0
                              end
                              if (result i32) ;; label = @14
                                i32.const 1
                              else
                                local.get 2
                                ref.cast (ref 2)
                                struct.get 2 0
                                i32.const 13
                                i32.eq
                                if (result i32) ;; label = @15
                                  local.get 2
                                  ref.cast (ref 3)
                                  struct.get 3 1
                                  local.set 1
                                  i32.const 1
                                else
                                  i32.const 0
                                end
                                if (result i32) ;; label = @15
                                  i32.const 1
                                else
                                  local.get 2
                                  ref.cast (ref 2)
                                  struct.get 2 0
                                  i32.const 14
                                  i32.eq
                                  if (result i32) ;; label = @16
                                    local.get 2
                                    ref.cast (ref 3)
                                    struct.get 3 1
                                    local.set 1
                                    i32.const 1
                                  else
                                    i32.const 0
                                  end
                                  if (result i32) ;; label = @16
                                    i32.const 1
                                  else
                                    local.get 2
                                    ref.cast (ref 2)
                                    struct.get 2 0
                                    i32.const 15
                                    i32.eq
                                    if (result i32) ;; label = @17
                                      local.get 2
                                      ref.cast (ref 3)
                                      struct.get 3 1
                                      local.set 1
                                      i32.const 1
                                    else
                                      i32.const 0
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      if ;; label = @2
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;3;) (type 23) (param (ref 20)) (result i32)
    (local i32 eqref i32)
    local.get 0
    local.set 2
    block ;; label = @1
      local.get 2
      ref.cast (ref 20)
      struct.get 20 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 2
        ref.cast (ref 21)
        struct.get 21 1
        ref.cast (ref 18)
        struct.get 18 0
        i32.const 0
        i32.eq
        if (result i32) ;; label = @3
          local.get 2
          ref.cast (ref 21)
          struct.get 21 1
          ref.cast (ref 19)
          struct.get 19 1
          ref.cast (ref 16)
          struct.get 16 0
          i32.const 0
          i32.eq
          if (result i32) ;; label = @4
            local.get 2
            ref.cast (ref 21)
            struct.get 21 1
            ref.cast (ref 19)
            struct.get 19 1
            ref.cast (ref 17)
            struct.get 17 1
            ref.cast (ref 14)
            struct.get 14 0
            i32.const 0
            i32.eq
            if (result i32) ;; label = @5
              local.get 2
              ref.cast (ref 21)
              struct.get 21 1
              ref.cast (ref 19)
              struct.get 19 1
              ref.cast (ref 17)
              struct.get 17 1
              ref.cast (ref 15)
              struct.get 15 1
              ref.cast (ref 12)
              struct.get 12 0
              i32.const 0
              i32.eq
              if (result i32) ;; label = @6
                local.get 2
                ref.cast (ref 21)
                struct.get 21 1
                ref.cast (ref 19)
                struct.get 19 1
                ref.cast (ref 17)
                struct.get 17 1
                ref.cast (ref 15)
                struct.get 15 1
                ref.cast (ref 13)
                struct.get 13 1
                ref.cast (ref 10)
                struct.get 10 0
                i32.const 0
                i32.eq
                if (result i32) ;; label = @7
                  local.get 2
                  ref.cast (ref 21)
                  struct.get 21 1
                  ref.cast (ref 19)
                  struct.get 19 1
                  ref.cast (ref 17)
                  struct.get 17 1
                  ref.cast (ref 15)
                  struct.get 15 1
                  ref.cast (ref 13)
                  struct.get 13 1
                  ref.cast (ref 11)
                  struct.get 11 1
                  ref.cast (ref 8)
                  struct.get 8 0
                  i32.const 0
                  i32.eq
                  if (result i32) ;; label = @8
                    local.get 2
                    ref.cast (ref 21)
                    struct.get 21 1
                    ref.cast (ref 19)
                    struct.get 19 1
                    ref.cast (ref 17)
                    struct.get 17 1
                    ref.cast (ref 15)
                    struct.get 15 1
                    ref.cast (ref 13)
                    struct.get 13 1
                    ref.cast (ref 11)
                    struct.get 11 1
                    ref.cast (ref 9)
                    struct.get 9 1
                    ref.cast (ref 6)
                    struct.get 6 0
                    i32.const 0
                    i32.eq
                    if (result i32) ;; label = @9
                      local.get 2
                      ref.cast (ref 21)
                      struct.get 21 1
                      ref.cast (ref 19)
                      struct.get 19 1
                      ref.cast (ref 17)
                      struct.get 17 1
                      ref.cast (ref 15)
                      struct.get 15 1
                      ref.cast (ref 13)
                      struct.get 13 1
                      ref.cast (ref 11)
                      struct.get 11 1
                      ref.cast (ref 9)
                      struct.get 9 1
                      ref.cast (ref 7)
                      struct.get 7 1
                      ref.cast (ref 4)
                      struct.get 4 0
                      i32.const 0
                      i32.eq
                      if (result i32) ;; label = @10
                        local.get 2
                        ref.cast (ref 21)
                        struct.get 21 1
                        ref.cast (ref 19)
                        struct.get 19 1
                        ref.cast (ref 17)
                        struct.get 17 1
                        ref.cast (ref 15)
                        struct.get 15 1
                        ref.cast (ref 13)
                        struct.get 13 1
                        ref.cast (ref 11)
                        struct.get 11 1
                        ref.cast (ref 9)
                        struct.get 9 1
                        ref.cast (ref 7)
                        struct.get 7 1
                        ref.cast (ref 5)
                        struct.get 5 1
                        local.set 1
                        i32.const 1
                      else
                        i32.const 0
                      end
                    else
                      i32.const 0
                    end
                  else
                    i32.const 0
                  end
                else
                  i32.const 0
                end
              else
                i32.const 0
              end
            else
              i32.const 0
            end
          else
            i32.const 0
          end
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 1
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;4;) (type 24) (result i32)
    i32.const 15
    i32.const 19
    struct.new 3
    call 2
    i32.const 0
    i32.const 0
    i32.const 0
    i32.const 0
    i32.const 0
    i32.const 0
    i32.const 0
    i32.const 0
    i32.const 0
    i32.const 23
    struct.new 5
    ref.cast (ref 4)
    struct.new 7
    ref.cast (ref 6)
    struct.new 9
    ref.cast (ref 8)
    struct.new 11
    ref.cast (ref 10)
    struct.new 13
    ref.cast (ref 12)
    struct.new 15
    ref.cast (ref 14)
    struct.new 17
    ref.cast (ref 16)
    struct.new 19
    ref.cast (ref 18)
    struct.new 21
    call 3
    i32.add
    i32.const 42
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x746e6f63 0x3a6c6f72 0x74746170 0x2d6e7265
      v128.const i32x4 0x7274616d 0x00007869 0x00000000 0x00000000
      array.new_fixed 25 2
      i32.const 0
      i32.const 22
      struct.new 27
      call 1
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 25 1
      i32.const 0
      i32.const 4
      struct.new 27
      call 1
    end
  )
)
