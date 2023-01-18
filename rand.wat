(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32) ))
    (global $print_mem i32 (i32.const 8))
    (global $bufferPointer i32 (i32.const 100))
    (memory 1)
    (export "memory" (memory 0))
    (func $print (param $byte i32)
        (i32.store (i32.const 0) (get_global $print_mem))
        (i32.store (i32.const 4) (i32.const 1)) 
        (i32.store (get_global $print_mem) (get_local $byte))
        (call $fd_write (i32.const 1) (i32.const 0) (i32.const 1) (i32.const 8))
        drop
    )

    (func $main (export "_start")
        (call $random_get (get_global $bufferPointer) (i32.const 1) )
        (call $print (i32.load  (get_global $bufferPointer) ))
        drop
    )
)