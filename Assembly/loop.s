# To compile this assembly program on windows: (make sure gcc is installed, for example it is installed with codeblocks-with-mingw)
# gcc -O3 -o loop.exe loop.s
# After running the program, enter a positive integer and press Enter

.section .data        # memory variables
input: .asciz "%d"    # string terminated by 0 that will be used for scanf parameter
output: .asciz "The sum is: %d\n"     # string terminated by 0 that will be used for printf parameter
n: .int 0             # the variable n which we will get from user using scanf
s: .int 0             # the variable s=1+2+3+...+n that will be calculated by the program and will be printed by printf, s is initialized to 0

.section .text        # instructions
.globl _main          # make _main accessible from external
_main:                # the label indicating the start of the program
   pushl $n           # push to stack the second parameter to scanf (the address of the integer variable n) the char "l" in pushl means 32-bits address
   pushl $input       # push to stack the first parameter to scanf
   call _scanf        # call scanf, it will use the two parameters on the top of the stack in the reverse order
   add $8, %esp       # pop the above two parameters from the stack (the esp register keeps track of the stack top, 8=2*4 bytes popped as param was 4 bytes)
   
   movl n, %ecx       # ecx <- n (the number of iterations)
   movl $1, %eax      # eax <- 1
loop1:
   addl %eax, s       # s += eax
   addl $1, %eax      # eax += 1
   loop loop1         # ecx -=1 , then goto loop1 only if ecx is not zero
   
   pushl s            # push to stack the second parameter to printf (the integer at label s)
   pushl $output      # push to stack the first parameter to printf
   call _printf       # call printf
   add $8, %esp       # pop the two parameters

   ret               # end the main function