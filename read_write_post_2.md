I'm starting to get the hand of fd_read and fd_write which are crucial for rolling your own WA away from the browser. I'll explain this code, to sum it up.





    (module
        (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
        (import "wasi_unstable" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
        (import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32) ))
        (memory 1)
        (export "memory" (memory 0))
        (func $write_i32_i32 (param $byte1 i32) (param $byte2 i32)
            (i32.store (i32.const 0) (i32.const 100))
            (i32.store (i32.const 4) (i32.const 1))
            (i32.store (i32.const 8) (i32.const 200))
            (i32.store (i32.const 12) (i32.const 1)) 
            (i32.store (i32.const 100) (local.get $byte1))
            (i32.store (i32.const 200) (local.get $byte2))
            (call $fd_write (i32.const 1) (i32.const 0) (i32.const 2) (i32.const 100))
            drop
        )
        (func $write_i32 (param $x i32)
            (i32.store (i32.const 0) (i32.const 100))
            (i32.store (i32.const 4) (i32.const 1))
            (i32.store (i32.const 100) (local.get $x))
            (call $fd_write (i32.const 1) (i32.const 0) (i32.const 1) (i32.const 100))
            drop
        )

        (func $read_i32 (result i32)
            (i32.store (i32.const 0) (i32.const 100))
            (i32.store (i32.const 4) (i32.const 1))
            (call $fd_read (i32.const 0) (i32.const 0) (i32.const 1) (i32.const 0))
            drop
            (i32.load (i32.const 100))
        )
        (func $main (export "_start")
            (call $write_i32 (call $read_i32))
            (call $write_i32 (i32.const 0x0A))
            (call $write_i32_i32 (i32.const 0x71) (i32.const 0x72))
        )

    )
