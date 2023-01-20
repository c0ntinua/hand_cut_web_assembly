(module
    (import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32) ))
    (memory 1)
    (export "memory" (memory 0))
    (func  $rand_i32 (export "rand_i32") (result i32)
        i32.const 0
        i32.const 64
        i32.store
        i32.const 0
        i32.const 4
        call $random_get
        drop
        i32.const 64
        i32.load
    )
)
