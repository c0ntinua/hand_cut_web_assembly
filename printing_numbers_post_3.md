The LISP style has its advantages, but the code looks cleaner in the Forth style. And Forth is fascinating. I feel like I'm learning some alternative Forth. So I switched.

The agony and the fun of this hand-cut assembly is that you get to (you have to) build the very simplest tools so that you can build tools that are only slightly less simple. For example, it took me days to print out a number in decimal. I'm basically writing a primitive printf in piecemeal fashion. But I finally got there.

    (func $write_dec (param $x i32)
          (local $p i32)
          (local $q i32)
          (local $w i32)
          i32.const 0
          local.set $w
          i32.const 9
          local.set $p
          loop $loop
              local.get $x
              local.get $p
              call $pow_10
              i32.div_u
              local.tee $q
              call $>0
              local.get $p
              call $==0
              i32.or
              if
                  i32.const 1
                  local.set $w
              end
              local.get $w
              if
                  local.get $q
                  local.get $x
                  local.get $p
                  select
                  call $write_digit
              end
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
      
      
 I'm more delighted than I should be that I'm allowed to name functions `>=0` and `-1`.
 
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
