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
            (get_global $out)
        )
        drop
    )
    (func $print_bit (param $bit i32)
        (call $print (i32.add (get_local $bit) (i32.const 0x30)));; shift up by 0x30 to get ASCII code digit
    )
    (func $ith_bit (param $x i32) (param $i i32) (result i32);;rightmost bit is 0 (order of output)
        (local $mask i32)
        (local.set $mask (i32.rotl (i32.const 1) (local.get $i)));;rotate bit to nth posit
        (local.set $mask (i32.and (local.get $mask) (local.get $x)))
        (i32.rotr (local.get $mask) (local.get $i) )
    )
    (func $print_base_2 (param $x i32)
        (local $i i32)
        (local.set $i (i32.const 31))
        (loop $loop
            (call $print_bit ( call $ith_bit (local.get $x) (local.get $i) )) 
            (local.set $i (i32.sub (local.get $i) (i32.const 1))) ;; i = i - 1;
            (br_if $loop (i32.le_s (i32.const 0) (local.get $i) ));; if ($i <= 0) break;
        )
    )
    (func $main (export "_start")
        (local $ran i32 )  
        (call $random_get (get_global $iovecp) (i32.const 4) );; *$iovecp = 4 random bytes
        drop;; discard return value of $random_get to keep stack empty, since $main returns void
        (local.set $ran (i32.load (get_global $iovecp ) ));; $ran = *$iovecp
        (call $print_base_2 (local.get $ran) );;print $ran in binary
        (call $print (i32.const 0x0A));;console line feed, for next prompt  
    )
)