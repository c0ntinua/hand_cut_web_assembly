(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_unstable" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
    (global $print_mem i32 (i32.const 8))
    (global $byte_read i32 (i32.const 12))
    (memory 1)
    (export "memory" (memory 0))
    (func $print (param $byte i32)
        (i32.store (i32.const 0) (get_global $print_mem))
        (i32.store (i32.const 4) (i32.const 1)) 
        (i32.store (get_global $print_mem) (get_local $byte))
        (call $fd_write (i32.const 1) (i32.const 0) (i32.const 1) (i32.const 8))
        drop
    )
    (func $read (param $byte i32)
        (i32.store (i32.const 0) (get_global $print_mem))
        (i32.store (i32.const 4) (i32.const 1)) 
        (i32.store (get_global $print_mem) (get_local $byte))
        (call $fd_write (i32.const 1) (i32.const 0) (i32.const 1) (i32.const 8))
        drop
    )

    (func $main (export "_start")
        ;;print the ansi escape code "ESC [ 2 j" in ASCII bytes
        (call $clearTheScreen)
        ;;print utf-8 code for full block
        (call $printFullUnicodeBlock)
        ;;print line feed byte
        (call $print (i32.const 0x0A))
    )
)