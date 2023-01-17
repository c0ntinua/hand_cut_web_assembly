(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (global $print_mem i32 (i32.const 8))
    (memory 1)
    (export "memory" (memory 0))
    (func $print (param $byte i32)
        ;;First we store the address of the bytes to printed (in this case just one byte) at address 0.
        ;;This address is stored above in a global variable, since we use it twice, so we actually copy it to address 0.
        (i32.store (i32.const 0) (get_global $print_mem))
        ;;Now we store the number of bytes to be printed at address 4, the next possible address, since an i32 is 4 bytes.
        ;;Since this function prints only one byte, we store the value 1 at this address.
        (i32.store (i32.const 4) (i32.const 1))
        ;;Now we actually store the local value (the byte given to be printed) in the memory where promised.
        ;;So the $byte will be stored at $print_mem.
        (i32.store (get_global $print_mem) (get_local $byte))
        ;;Finally we call fd_write, giving it 1 first to indicate stdout as a destination.
        ;;Then we give it the address of the address of the bytes to be written, prepared above.
        ;;Then we give it the number of bytes to be written.
        ;;Finally we give it an address where it can store the number of bytes written.
        ;;In this case we just overwrite the byte that was just written. 
        (call $fd_write (i32.const 1) (i32.const 0) (i32.const 1) (get_global $print_mem))
        drop
    )
    (func $main (export "_start")
        (call $print (i32.const 0x68))
        (call $print (i32.const 0x65))
        (call $print (i32.const 0x6C))
        (call $print (i32.const 0x6C))
        (call $print (i32.const 0x6F))
        (call $print (i32.const 0x20))
        (call $print (i32.const 0x77))
        (call $print (i32.const 0x6F))
        (call $print (i32.const 0x72))
        (call $print (i32.const 0x6C))
        (call $print (i32.const 0x64))
        (call $print (i32.const 0x0A))
    )
)