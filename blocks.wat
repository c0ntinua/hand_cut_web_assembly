(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32) ))
    (global $stdout i32 (i32.const 1))
    (global $iovecp i32 (i32.const 0))
    (global $iovecl i32 (i32.const 4))
    (global $out i32 (i32.const 8))
    (memory 1)
    (export "memory" (memory 0))
    (func $print (param $byte i32)
        (local $location i32)
        (local.set $location (i32.const 100))
        (i32.store (get_global $iovecp) (get_local $location))
        (i32.store (get_global $iovecl) (i32.const 1)) 
        (i32.store (get_local $location) (get_local $byte))
        (call $fd_write 
            (get_global $stdout) 
            (get_global $iovecp) 
            (get_global $iovecl)
            (local.get $location)
        )
        drop
    )
    (func $print_bit_as_block (param $bit i32)
        (if (local.get $bit) 
            (then (call $print_block ))
            (else (call $print (i32.const 0x20)))
        )
    )
    (func $ith_bit (param $x i32) (param $i i32) (result i32);;rightmost bit is 0 (order of output)
        (local $mask i32)
        (local.set $mask (i32.rotl (i32.const 1) (local.get $i)));;rotate bit to nth posit
        (local.set $mask (i32.and (local.get $mask) (local.get $x)))
        (i32.rotr (local.get $mask) (local.get $i) )
    )
    (func $print_random_blocks
        (local $ran i32 ) 
        (local $i i32 ) 
        (call $random_get (get_global $iovecp) (i32.const 4) )
        drop
        (local.set $ran (i32.load (get_global $iovecp ) ))
        (local.set $i (i32.const 31))
        (loop $loop
            (call $print_bit_as_block ( call $ith_bit (local.get $ran) (local.get $i) )) 
            (local.set $i (i32.sub (local.get $i) (i32.const 1))) ;; i = i - 1;
            (br_if $loop (i32.le_s (i32.const 0) (local.get $i) ));; if ($i <= 0) break;
        )
    )
    (func $print_random_block_matrix ( param $rows i32)
        (local $i i32 )
        (loop $loop
            (call $print_random_blocks) 
            (call $print (i32.const 0x0A))
            (local.set $rows (i32.sub (local.get $rows) (i32.const 1))) ;; i = i - 1;
            (br_if $loop (i32.le_s (i32.const 0) (local.get $rows) ));; if ($i <= 0) break;
        )
    )
    (func $print_random_block_matrix_wide ( param $rows i32)
        (local $i i32 )
        (loop $loop
            (call $print_random_blocks)
            (call $print_random_blocks) 
            (call $print_random_blocks)  
            (call $print (i32.const 0x0A))
            (local.set $rows (i32.sub (local.get $rows) (i32.const 1))) ;; i = i - 1;
            (br_if $loop (i32.le_s (i32.const 0) (local.get $rows) ));; if ($i <= 0) break;
        )
    )
    (func $print_block 
        (call $print (i32.const 0xE2))
        (call $print (i32.const 0x96))
        (call $print (i32.const 0x88))
    )
    (func $main (export "_start")
        (call $print_random_block_matrix_wide (i32.const 32))
        (call $print (i32.const 0x0A))
    )
)