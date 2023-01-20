(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_unstable" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))
    (import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32) ))
    (memory 1)
    (export "memory" (memory 0))
    (func $ith_bit (param $x i32) (param $i i32)  (result i32)
        i32.const 1
        local.get $i
        i32.rotl
        local.get $x
        i32.and
        local.get $i
        i32.rotr
    )
    (func $write (param $x i32)
        i32.const 100
        local.get $x
        i32.store
        i32.const 0
        i32.const 100
        i32.store
        i32.const 4
        i32.const 1
        i32.store
        i32.const 1
        i32.const 0
        i32.const 1
        i32.const 100
        call $fd_write
        drop
    )
    (func $read (result i32)
        i32.const 0
        i32.const 100
        i32.store
        i32.const 4
        i32.const 1
        i32.store
        i32.const 0
        i32.const 0
        i32.const 1
        i32.const 0
        call $fd_read
        drop
        i32.const 100
        i32.load
    )
    (func $linefeed
        i32.const 0x0A
        call $write
    )
    (func $as_digit (param $x i32) (result i32)
        local.get $x
        i32.const 0x30
        i32.add
    )
    (func $write_digit (param $x i32) 
        local.get $x
        call $as_digit
        call $write
    )
    (func $pow_10 (param $p i32) (result i32)
        (local $r i32)
        i32.const 1
        local.set $r
        loop $loop
            local.get $p
            i32.const 1
            i32.sub
            local.set $p

            local.get $r
            i32.const 10
            i32.mul
            local.set $r

            local.get $p
            i32.const 0
            i32.gt_s
            br_if $loop
        end
        local.get $r
    )
    (func $write_binary (param $x i32)
        (local $i i32)
        i32.const 31
        local.set $i 
        loop $loop
            local.get $x
            local.get $i
            call $ith_bit
            call $write_digit
            local.get $i
            i32.const 1
            i32.sub
            local.set $i
            i32.const 0
            local.get $i
            i32.le_s
            br_if $loop
        end
        call $linefeed
    )
    (func  $rand_i32 (export "rand_i32") (result i32)
        i32.const 0
        i32.const 4
        call $random_get
        drop
        i32.const 0
        i32.load
    )
    (func $write_dec (param $x i32)
        (local $p i32)
        (local $q i32)
        i32.const 9
        local.set $p
        loop $loop
            local.get $x
            local.get $p
            call $pow_10
            i32.div_u
            local.tee $q
            local.get $x
            local.get $p
            select
            call $write_digit
            local.get $q
            call $>=0
            if
                local.get $x
                local.get $q
                local.get $p
                call $pow_10
                i32.mul
                i32.sub
                local.set $x
            end
            local.get $p
            call $-1
            local.tee $p
            call $>=0
            br_if $loop
        end
    )
    (func $-1 (param $x i32) (result i32)
        local.get $x
        i32.const 1
        i32.sub
    )
    (func $>=0 (param $x i32) (result i32)
        local.get $x
        i32.const 0
        i32.ge_s
    )
    (func $main (export "_start")
        i32.const 100
        call $write_dec
        ;;call $write_digit
    )
    
)
