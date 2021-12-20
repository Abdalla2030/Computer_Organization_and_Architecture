# To compile this assembly program on windows: (make sure gcc is installed, for example it is installed with codeblocks-with-mingw) -m32
# gcc -O3 -o float.exe float.s
# After running the program, enter a positive integer and press Enter

.section .data        # memory variables

input: .asciz "%d"    # string terminated by 0 that will be used for scanf parameter
output: .asciz "The sum is: %lf\n"     # string terminated by 0 that will be used for printf parameter

n: .int 0             # the variable n which we will get from user using scanf
s: .double 0.0        # the variable s=1/1+1/2+1/3+...+1/n that will be calculated by the program and will be printed by printf, s is initialized to 0
one: .double 1.0
r: .double 1.0


.section .text        # instructions
.globl _main          # make _main accessible from external

_main:                # the label indicating the start of the program
   pushl $n           # push to stack the second parameter to scanf (the address of the integer variable n) the char "l" in pushl means 32-bits address
   pushl $input       # push to stack the first parameter to scanf
   call _scanf        # call scanf, it will use the two parameters on the top of the stack in the reverse order
   add $8, %esp       # pop the above two parameters from the stack (the esp register keeps track of the stack top, 8=2*4 bytes popped as param was 4 bytes)
   
   movl n, %ecx       # ecx <- n (the number of iterations)
loop1:
   # the following 4 instructions increase s by 1/r
   fldl one           # push 1 to the floating point stack
   fdivl r            # pop the floating point stack top (1), divide it over r and push the result (1/r)

   faddl s            # pop the floating point stack top (1/r), add it to s, and push the result (s+(1/r))
   fstl s             # pop the floating point stack top (s+(1/r)) into the memory variable s

   # the following 3 instructions increase r by 1   
   fldl one           # push 1 to the floating point stack
   faddl r            # pop the floating point stack top (1), add it to r and push the result (r+1)
   fstl r             # pop the floating point stack top (r+1) into the memory variable s

   loop loop1         # ecx -=1 , then goto loop1 only if ecx is not zero
   
   pushl s+4          # push to stack the high 32-bits of the second parameter to printf (the double at label s)
   pushl s            # push to stack the low 32-bits of the second parameter to printf (the double at label s)
   pushl $output      # push to stack the first parameter to printf
   call _printf       # call printf
   add $12, %esp      # pop the two parameters

   ret               # end the main function