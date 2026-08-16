(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 i32) (result i32)))
  (type (;9;) (func (param i32 i32) (result i32)))
  (type (;10;) (func (param i32 i32) (result i32)))
  (type (;11;) (func (param i32 i32) (result i32)))
  (type (;12;) (func (param i32 i32) (result i32)))
  (type (;13;) (func (param i32 i64 i32) (result i32)))
  (type (;14;) (func (param i32 i64 i64 i32) (result i32)))
  (type (;15;) (func (param i32 i64 i64) (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (type (;17;) (func (param i32) (result i32)))
  (type (;18;) (func (param i32 i32) (result i32)))
  (type (;19;) (func (param i32 i32) (result i32)))
  (type (;20;) (func (param i32 i64 i64) (result i32)))
  (type (;21;) (func (param i32 i32) (result i32)))
  (type (;22;) (func (param i32 i64) (result i32)))
  (type (;23;) (func (param i32 i64 i64 i32) (result i32)))
  (type (;24;) (func (param i32 i32 i32 i64 i32) (result i32)))
  (type (;25;) (func (param i32 i32) (result i32)))
  (type (;26;) (func (param i32 i32 i32) (result i32)))
  (type (;27;) (func (param i32 i32 i32 i64 i32) (result i32)))
  (type (;28;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;29;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;30;) (func (param i32 i32 i32 i64 i32) (result i32)))
  (type (;31;) (func (param i32 i32) (result i32)))
  (type (;32;) (func (param i32 i64 i32 i32) (result i32)))
  (type (;33;) (func (param i32) (result i32)))
  (type (;34;) (func (param i32 i32) (result i32)))
  (type (;35;) (func (param i32 i32 i32) (result i32)))
  (type (;36;) (func (param i32 i32 i32 i32 i32) (result i32)))
  (type (;37;) (func (param i32 i32 i32 i32 i64 i64 i32) (result i32)))
  (type (;38;) (func (param i32 i32 i32 i32 i32 i32 i32) (result i32)))
  (type (;39;) (func (param i32 i32 i32 i32 i32 i64 i64 i32 i32) (result i32)))
  (type (;40;) (func (param i32 i32 i32 i32 i32 i32) (result i32)))
  (type (;41;) (func (param i32 i32 i32) (result i32)))
  (type (;42;) (func (param i32 i32 i32 i32 i32 i32) (result i32)))
  (type (;43;) (func (param i32 i32 i32 i32 i32) (result i32)))
  (type (;44;) (func (param i32 i32 i32) (result i32)))
  (type (;45;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;46;) (func (param i32)))
  (type (;47;) (func (param i32) (result i32)))
  (type (;48;) (func (result i32)))
  (type (;49;) (func (param i32 i32) (result i32)))
  (type (;50;) (func (param i32 i32 i32) (result i32)))
  (type (;51;) (func (param i32 i32 i32 i32 i32 i32) (result i32)))
  (type (;52;) (func (param i32 i32 i32 i32 i32) (result i32)))
  (type (;53;) (func (param i32 i32) (result i32)))
  (type (;54;) (func (param i32)))
  (type (;55;) (func (result i32)))
  (type (;56;) (sub (struct (field funcref))))
  (type (;57;) (func (param eqref) (result eqref)))
  (type (;58;) (func (param eqref i32) (result eqref)))
  (type (;59;) (func (param eqref eqref) (result eqref)))
  (type (;60;) (func (param eqref)))
  (type (;61;) (func (param eqref i32)))
  (type (;62;) (func (param eqref) (result i32)))
  (type (;63;) (func (param eqref i32) (result i32)))
  (type (;64;) (func (param eqref eqref i32) (result eqref)))
  (type (;65;) (func (param eqref eqref eqref) (result eqref)))
  (type (;66;) (func (param eqref eqref)))
  (type (;67;) (func (param eqref eqref i32)))
  (type (;68;) (func (param eqref eqref) (result i32)))
  (type (;69;) (func (param eqref eqref i32) (result i32)))
  (type (;70;) (func (param eqref eqref eqref i32) (result eqref)))
  (import "wasi_snapshot_preview1" "args_get" (func (;0;) (type 8)))
  (import "wasi_snapshot_preview1" "args_sizes_get" (func (;1;) (type 9)))
  (import "wasi_snapshot_preview1" "environ_get" (func (;2;) (type 10)))
  (import "wasi_snapshot_preview1" "environ_sizes_get" (func (;3;) (type 11)))
  (import "wasi_snapshot_preview1" "clock_res_get" (func (;4;) (type 12)))
  (import "wasi_snapshot_preview1" "clock_time_get" (func (;5;) (type 13)))
  (import "wasi_snapshot_preview1" "fd_advise" (func (;6;) (type 14)))
  (import "wasi_snapshot_preview1" "fd_allocate" (func (;7;) (type 15)))
  (import "wasi_snapshot_preview1" "fd_close" (func (;8;) (type 16)))
  (import "wasi_snapshot_preview1" "fd_datasync" (func (;9;) (type 17)))
  (import "wasi_snapshot_preview1" "fd_fdstat_get" (func (;10;) (type 18)))
  (import "wasi_snapshot_preview1" "fd_fdstat_set_flags" (func (;11;) (type 19)))
  (import "wasi_snapshot_preview1" "fd_fdstat_set_rights" (func (;12;) (type 20)))
  (import "wasi_snapshot_preview1" "fd_filestat_get" (func (;13;) (type 21)))
  (import "wasi_snapshot_preview1" "fd_filestat_set_size" (func (;14;) (type 22)))
  (import "wasi_snapshot_preview1" "fd_filestat_set_times" (func (;15;) (type 23)))
  (import "wasi_snapshot_preview1" "fd_pread" (func (;16;) (type 24)))
  (import "wasi_snapshot_preview1" "fd_prestat_get" (func (;17;) (type 25)))
  (import "wasi_snapshot_preview1" "fd_prestat_dir_name" (func (;18;) (type 26)))
  (import "wasi_snapshot_preview1" "fd_pwrite" (func (;19;) (type 27)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;20;) (type 28)))
  (import "wasi_snapshot_preview1" "fd_read" (func (;21;) (type 29)))
  (import "wasi_snapshot_preview1" "fd_readdir" (func (;22;) (type 30)))
  (import "wasi_snapshot_preview1" "fd_renumber" (func (;23;) (type 31)))
  (import "wasi_snapshot_preview1" "fd_seek" (func (;24;) (type 32)))
  (import "wasi_snapshot_preview1" "fd_sync" (func (;25;) (type 33)))
  (import "wasi_snapshot_preview1" "fd_tell" (func (;26;) (type 34)))
  (import "wasi_snapshot_preview1" "path_create_directory" (func (;27;) (type 35)))
  (import "wasi_snapshot_preview1" "path_filestat_get" (func (;28;) (type 36)))
  (import "wasi_snapshot_preview1" "path_filestat_set_times" (func (;29;) (type 37)))
  (import "wasi_snapshot_preview1" "path_link" (func (;30;) (type 38)))
  (import "wasi_snapshot_preview1" "path_open" (func (;31;) (type 39)))
  (import "wasi_snapshot_preview1" "path_readlink" (func (;32;) (type 40)))
  (import "wasi_snapshot_preview1" "path_remove_directory" (func (;33;) (type 41)))
  (import "wasi_snapshot_preview1" "path_rename" (func (;34;) (type 42)))
  (import "wasi_snapshot_preview1" "path_symlink" (func (;35;) (type 43)))
  (import "wasi_snapshot_preview1" "path_unlink_file" (func (;36;) (type 44)))
  (import "wasi_snapshot_preview1" "poll_oneoff" (func (;37;) (type 45)))
  (import "wasi_snapshot_preview1" "proc_exit" (func (;38;) (type 46)))
  (import "wasi_snapshot_preview1" "proc_raise" (func (;39;) (type 47)))
  (import "wasi_snapshot_preview1" "sched_yield" (func (;40;) (type 48)))
  (import "wasi_snapshot_preview1" "random_get" (func (;41;) (type 49)))
  (import "wasi_snapshot_preview1" "sock_accept" (func (;42;) (type 50)))
  (import "wasi_snapshot_preview1" "sock_recv" (func (;43;) (type 51)))
  (import "wasi_snapshot_preview1" "sock_send" (func (;44;) (type 52)))
  (import "wasi_snapshot_preview1" "sock_shutdown" (func (;45;) (type 53)))
  (memory (;0;) 1)
  (export "main" (func 47))
  (export "memory" (memory 0))
  (func (;46;) (type 54) (param i32)
    local.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;47;) (type 55) (result i32)
    i32.const 0
    i32.const 64
    i32.store
    i32.const 4
    i32.const 0
    i32.store
    i32.const 8
    i32.const 0
    i32.store
    i32.const 128
    i32.const 256
    call 0
    call 46
    i32.const 384
    i32.const 388
    call 1
    call 46
    i32.const 512
    i32.const 640
    call 2
    call 46
    i32.const 768
    i32.const 772
    call 3
    call 46
    i32.const 1
    i32.const 896
    call 4
    call 46
    i32.const 1
    i64.const 7
    i32.const 904
    call 5
    call 46
    i32.const 3
    i64.const 11
    i64.const 13
    i32.const 2
    call 6
    call 46
    i32.const 3
    i64.const 17
    i64.const 19
    call 7
    call 46
    i32.const 9
    call 8
    call 46
    i32.const 3
    call 9
    call 46
    i32.const 3
    i32.const 1024
    call 10
    call 46
    i32.const 3
    i32.const 1
    call 11
    call 46
    i32.const 3
    i64.const 23
    i64.const 29
    call 12
    call 46
    i32.const 3
    i32.const 1088
    call 13
    call 46
    i32.const 3
    i64.const 31
    call 14
    call 46
    i32.const 3
    i64.const 37
    i64.const 41
    i32.const 3
    call 15
    call 46
    i32.const 3
    i32.const 0
    i32.const 1
    i64.const 43
    i32.const 8
    call 16
    call 46
    i32.const 3
    i32.const 1152
    call 17
    call 46
    i32.const 3
    i32.const 1216
    i32.const 0
    call 18
    call 46
    i32.const 3
    i32.const 0
    i32.const 1
    i64.const 47
    i32.const 8
    call 19
    call 46
    i32.const 0
    i32.const 0
    i32.const 1
    i32.const 8
    call 21
    call 46
    i32.const 3
    i32.const 1280
    i32.const 0
    i64.const 53
    i32.const 1344
    call 22
    call 46
    i32.const 7
    i32.const 8
    call 23
    call 46
    i32.const 3
    i64.const -59
    i32.const 2
    i32.const 1408
    call 24
    call 46
    i32.const 3
    call 25
    call 46
    i32.const 3
    i32.const 1472
    call 26
    call 46
    i32.const 9
    i32.const 0
    i32.const 1
    i32.const 8
    call 20
    call 46
    i32.const 3
    i32.const 1536
    i32.const 0
    call 27
    call 46
    i32.const 3
    i32.const 1
    i32.const 1600
    i32.const 0
    i32.const 1664
    call 28
    call 46
    i32.const 3
    i32.const 1
    i32.const 1728
    i32.const 0
    i64.const 61
    i64.const 67
    i32.const 3
    call 29
    call 46
    i32.const 3
    i32.const 1
    i32.const 1792
    i32.const 0
    i32.const 4
    i32.const 1856
    i32.const 0
    call 30
    call 46
    i32.const 3
    i32.const 1
    i32.const 1920
    i32.const 0
    i32.const 1
    i64.const 71
    i64.const 73
    i32.const 1
    i32.const 1984
    call 31
    call 46
    i32.const 3
    i32.const 2048
    i32.const 0
    i32.const 2112
    i32.const 0
    i32.const 2176
    call 32
    call 46
    i32.const 3
    i32.const 2240
    i32.const 0
    call 33
    call 46
    i32.const 3
    i32.const 2304
    i32.const 0
    i32.const 4
    i32.const 2368
    i32.const 0
    call 34
    call 46
    i32.const 2432
    i32.const 0
    i32.const 3
    i32.const 2496
    i32.const 0
    call 35
    call 46
    i32.const 3
    i32.const 2560
    i32.const 0
    call 36
    call 46
    i32.const 2624
    i32.const 2688
    i32.const 0
    i32.const 2752
    call 37
    call 46
    i32.const 23
    call 38
    i32.const 2
    call 39
    call 46
    call 40
    call 46
    i32.const 2816
    i32.const 0
    call 41
    call 46
    i32.const 5
    i32.const 1
    i32.const 2880
    call 42
    call 46
    i32.const 5
    i32.const 0
    i32.const 1
    i32.const 0
    i32.const 2944
    i32.const 2948
    call 43
    call 46
    i32.const 5
    i32.const 0
    i32.const 1
    i32.const 0
    i32.const 3008
    call 44
    call 46
    i32.const 5
    i32.const 3
    call 45
    call 46
    i32.const 46
  )
)
