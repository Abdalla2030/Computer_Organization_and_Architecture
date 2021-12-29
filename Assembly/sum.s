# To download gcc on windows:
# download mingw (and make sure gcc is chosen while installation) from: 
# mingw-get-setup.exe at the site https://osdn.net/projects/mingw/
# then append c:\mingw\bin; to the start of the PATH environment variable from control panel

# To compile this assembly program on windows:
# gcc -O3 -o sum.exe sum.s
# After running the program, enter a positive integer (n<=100) and then enter n integers then press enter

#------------------------------------------------------------------------------------------------------

.section .data        # initialized memory variables, will be part of the exe

input: .asciz "%d"    # string terminated by 0 that will be used for scanf parameter
output: .asciz "The sum is: %d\n"     # string terminated by 0 that will be used for printf parameter
n: .int 0             # the variable n which we will get from user using scanf

#------------------------------------------------------------------------------------------------------

.section .bss         # uninitialized memory variables, may not be part of the exe

.lcomm arr, 400       # arr is an array that can hold at most 100 32-bits integers
                      # lcomm means that the variable cannot be accessed from other files

#------------------------------------------------------------------------------------------------------

.section .text        # instructions

.globl _main          # make _main accessible from external

_main:                # the label indicating the start of the program

   # get the number of integers from the user -------------------------------------------

   pushl $n           # push to stack the second parameter to scanf (the address of the integer variable n) the char "l" in pushl means 32-bits address
   pushl $input       # push to stack the first parameter to scanf
   call _scanf        # call scanf, it will use the two parameters on the top of the stack in the reverse order
   add $8, %esp       # pop the above two parameters from the stack (the esp register keeps track of the stack top, 8=2*4 bytes popped as param was 4 bytes)

   # get the n integers from the user ---------------------------------------------------

   movl $0, %ecx      # ecx iterates over the integer array (0,1,...,n-1)
   movl $arr, %ebx    # ebx iterates over the integer array (0,4,8, ...)
   
input_loop:
   
   pushl %ecx         # push to stack ecx because _scanf may change it
   pushl %ebx         # push to stack ebx because _scanf may change it

   pushl %ebx         # push to stack the second parameter to scanf
   pushl $input       # push to stack the first parameter to scanf
   call _scanf        # call scanf, it will use the two parameters on the top of the stack in the reverse order
   add $8, %esp       # pop the above two parameters from the stack
   
   popl %ebx          # pop ebx
   popl %ecx          # pop ecx

   add $4, %ebx
   add $1, %ecx
   
   cmpl %ecx, n       # compare %ecx and n and update some status flags that will be used by ja below
   ja input_loop      # ja = jump if above: goto input_loop only if n is above %ecx

   # sum the n integers ------------------------------------------------------------------

   movl $0, %ecx      # ecx iterates over the integer array (0,1,...,n-1)
   movl $0, %eax      # eax stores the sum

comp_loop:

   add arr(, %ecx, 4), %eax   # base(offset, index, size)  will get the value at: base + offset + index * size  (here offset=0 because it does not exist)

   add $1, %ecx

   cmp %ecx, n        # compare %ecx and n and update some status flags that will be used by ja below
   ja comp_loop       # ja = jump if above: goto input_loop only if n is above %ecx
   
   # print the sum of integers -------------------------------------------------------------

   pushl %eax         # push to stack the second parameter to printf
   pushl $output      # push to stack the first parameter to printf
   call _printf       # call printf
   add $8, %esp       # pop the two parameters

   ret                # end the main function
   
#------------------------------------------------------------------------------------------------------