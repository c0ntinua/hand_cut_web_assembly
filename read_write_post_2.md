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
    
    
An iovec (input output vector) is just a pair of i32 values side by side in (global) memory.  The one on the left (in the numerically lower memory position) is a pointer to some other spot in memory (where the data to be written can be found or the data to be read can be stored.) The one on the right, the very next i32, represents the number of bytes of that storage.   So (30, 5) says that the storage is located at address 30 and is 5 bytes long. This is logical enough. What's tricky is that there's a length parameter in fd_read and fd_write that does not refer to the length of the store but rather to the number of iovecs being pointed at. In fact it's an *array* of iovecs being pointed at. 

Basically I'm using ( fd_read (stdin) (address of iovec array) (len of iovec array) (place to store num bytes written).  So I put 2 iovecs in memory and stash my params accordingly. 


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

I haven't tried doing a multiple read, but I think there's a feature for turning on multiple return values. I'll have to go back and clean up rot64 and coil now that I've got some grip on these IO functions.  I hope someone bumps into this and has an AH HA moment like I finally did. 
