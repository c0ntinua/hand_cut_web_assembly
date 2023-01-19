It's a slow climb, but I've learned a few more tricks. 



I was able to manage this output:

![Screenshot 2023-01-18 at 6 19 40 AM](https://user-images.githubusercontent.com/90075803/213168436-b89a3e6b-b34a-46d6-8a0a-8536f498be6a.png)

I'll share a few thoughts on my `blocks.wat` file. I got random numbers going, using 

`(import "wasi_unstable" "random_get" (func $random_get (param i32 i32) (result i32) ))`

This is another use of the iovec struct (input-output vector), which is an address to begin writing at and then a number of bytes to write. I wanted random i32 values, so I asked for 4 bytes.

`(call $random_get (get_global $iovecp) (i32.const 4) )`

As you can see, I stored an address globally, which hopefully makes it easier to switch out functions of this type. 

Another problem I needed to solve was to output i32 values, and I've still only done that in binary so far. I'm glad to see that WA has `i32.rotl` and `i32.rotr`, which is bit rotation, without the bits falling off the side and vanishing. I've used this feature, which is also in Rust, to implemene cellular automata.

In this case, I would just rotate the value 1 to the desired place and AND it with the number I wanted to print. Then I rotated the result back so the result would be 1 or 0. Finally I could add the proper amount to this value so that I'd print out the correct piece of ANSI code.


    (func $ith_bit (param $x i32) (param $i i32) (result i32);;rightmost bit is 0 (order of output)
        (local $mask i32)
        (local.set $mask (i32.rotl (i32.const 1) (local.get $i)));;rotate bit to nth posit
        (local.set $mask (i32.and (local.get $mask) (local.get $x)))
        (i32.rotr (local.get $mask) (local.get $i) )
    )
    
    
    
    (func $printBit (param $bit i32)
        (call $print (i32.add (get_local $bit) (i32.const 0x30)))
    )

I actually didn't need the digits in blocks.wat, but it was a waystation. Instead I used a function that printed a full block or an empty space for the arguments 1 and 0 respectively.
That was pretty straightforward, so I'll jump ahead to my first loops in this alien language.

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
    
I should mention that I found a great little reference: https://developer.mozilla.org/en-US/docs/WebAssembly/Reference/Control_flow/if...else
It's written in the stack style rather than the LISP style, but it's not too hard to switch between them. (The stack style requires less parentheses.)

In the function above I set aside space for my random_number (generated within the function) and my loop counter. I drop the return value of $random_get to avoid an error. Then I just count down
the number of blocks that still need printing, breaking when the counter <= 0, and the syntax looks backward, but this code works. 

Before I figured out loops, I was impatient to look at a single random i32 value, so I copied and pasted to get this inefficient monster:


     (func $print_binary (param $i i32)
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 31)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 30)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 29)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 28)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 27)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 26)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 25)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 24)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 23)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 22)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 21)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 20)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 19)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 18)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 17)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 16)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 15)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 14)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 13)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 12)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 11)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const 10)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  9)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  8)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  7)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  6)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  5)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  4)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  3)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  2)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  1)))
        (call $printBit ( call $nth_bit (local.get $i) (i32.const  0)))
    )


Once I looked at a few random numbers (and figured out that I needed to ask for 4 bytes), I looked up how to write a loop.


    (func $print_base_2 (param $x i32)
        (local $i i32)
        (local.set $i (i32.const 31))
        (loop $loop
            (call $printBit ( call $nth_bit (local.get $x) (local.get $i) ))
            (local.set $i (i32.sub (local.get $i) (i32.const 1)))
            (br_if $loop (i32.le_s (i32.const 0) (local.get $i) ))
        )
    )



I'll just end here by saying it's been fun to work at such a low level. Printing out a number takes a little research and work! That's largely because the resources aren't plentiful. I can imagine someone even writing an introduction to programming using WA. It's be like C in that you'd deal with pointers, but maybe dealing with a virtual machine is to live in a more rational universe, a nice place to start. I think WA is better than the GWBASIC I started with.



