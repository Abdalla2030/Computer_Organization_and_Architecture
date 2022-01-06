# To download gcc on windows:
# download mingw (and make sure gcc is chosen while installation) from: 
# mingw-get-setup.exe at the site https://osdn.net/projects/mingw/
# then append c:\mingw\bin; to the start of the PATH environment variable from control panel

# To compile this assembly program on windows:
# gcc -O3 -o simd.exe simd.s
# After running the program, enter a positive integer (n<=400) and then enter n integers then press enter

#------------------------------------------------------------------------------------------------------

.section .data        # initialized memory variables, will be part of the exe

input: .asciz "%d"    # string terminated by 0 that will be used for scanf parameter
outsum: .asciz "The sum is: %d\n"     # string terminated by 0 that will be used for printf parameter
outavg: .asciz "The average is: %f\n"     # string terminated by 0 that will be used for printf parameter
n: .int 0             # the variable n which we will get from user using scanf
res: .fill 16         # 16 bytes, each bytes is filled with zero
avg: .double 0

#------------------------------------------------------------------------------------------------------

.section .bss         # uninitialized memory variables, may not be part of the exe

.align 16
.lcomm arr, 400       # arr is an array that can hold at most 400 32-bits integers
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

   # sum the n integers -----------------------------------------------------------------

   movl n, %ecx       
   sall $2, %ecx      # shift left ecx by 2, ecx=4*n

   movdqu res, %xmm1   # xmm1 contains 4 integers, each integer will store a partial sum. initialize to zeros
   movdqu %xmm1, arr(,%ecx,1) # put 4 additional zeros at the end of the input array (to avoid problems when n is not multiple of 4)

   movl $arr, %ebx    # ebx iterates over the integer array (arr+0, arr+4*4, arr+8*4, ...)
   add $arr, %ecx     # now ecx contains the after-last address of the array (will be used to stop the loop)
   
comp_loop:

   # printf changes sse-registers (xmm0-xmm3), so do not try to printf here for debugging

   movdqa (%ebx), %xmm0  # move 4 integers from arr to %xmm0. use aligned move for better performance
   paddd %xmm0, %xmm1    # add these 4 integers to the partial sums in %xmm1
   
   # This line can be used instead of the above lines, but which method is faster?
   # paddd (%ebx), %xmm1    # add these 4 integers to the partial sums in %xmm1

   add $16, %ebx         # go to the next 4 integers

   cmp %ebx, %ecx     # compare %ecx and %ebx
   ja comp_loop       # ja = jump if above: goto input_loop only if %ecx is above %ebx
   
   # extract and sum the resulting 4 integers in xmm1 ----------------------------------

   movdqu %xmm1, res
   
   movl $0, %eax
   add res, %eax
   add res+4, %eax
   add res+8, %eax
   add res+12, %eax

   # print the sum of integers ---------------------------------------------------------

   pushl %eax         # the printf call will corrupt eax

   pushl %eax         # push to stack the second parameter to printf
   pushl $outsum      # push to stack the first parameter to printf
   call _printf       # call printf
   add $8, %esp       # pop the two parameters

   popl %eax          # the printf call will corrupt eax

   # calculate the average of integers -------------------------------------------------

   # the following lines convert from integer (%eax) to double (avg)
   movl %eax, res
   fildl n            # convert n to double and push it to stack
   fildl res          # convert res to double and push it to stack
   fdivp %st(0), %st(1)  # multiplies the two items on stack top and pops them and pushes the result
   fstpl avg

   # print the average of integers -------------------------------------------------------------

   pushl avg+4
   pushl avg
   pushl $outavg      # push to stack the first parameter to printf
   call _printf       # call printf
   add $12, %esp      # pop the two parameters

   ret                # end the main function
   
#------------------------------------------------------------------------------------------------------

   # fidivl n: can be used instead of:
   # fildl n
   # fdivp %st(0), %st(1)
   
   # another way for int to double conversion
   # movl %eax, res
   # cvtdq2pd res, %xmm0
   # movdqu %xmm0, avg