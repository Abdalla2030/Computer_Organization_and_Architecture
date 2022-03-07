# To download gcc on windows:
# download mingw (and make sure gcc is chosen while installation) from: 
# mingw-get-setup.exe at the site https://osdn.net/projects/mingw/
# then append c:\mingw\bin; to the start of the PATH environment variable from control panel

# To compile this assembly program on windows:
# gcc -O3 -o sum.exe sum.s
# Example:
# The user inputs: 3 1.2 2 6.1
# The program outputs: sum=9.3 avg=3.1
#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
#   Abdalla Fadl Shehat -      20190305 
#------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------
.section .data       
 
input1: .asciz "%d"                # input1 to input integer n 
input2: .asciz "%lf"               # input2 to input double numbers
output_sum: .asciz "sum = %lf "    # output_sum to print the sum of numbers    
output_avg: .asciz "avg = %lf\n"   # output_avg to print the average of numbers   

n: .int 0                          # an integer n         
var: .double 0.0                   # double variable 
sum: .double 0.0                   # sum of numbers 
avg: .double 0.0                   # average of numbers     

.section .text                     # instructions
.globl _main                       # make _main accessible from external


_main:                             # the label indicating the start of the program

    # get the number of doubles numbers from the user -------------------------------------------
    
    pushl $n                         # push to stack the second parameter to scanf (the address of the integer variable n) 
    pushl $input1                    # push to stack the first parameter to scanf
    call _scanf                      # call scanf, it will use the two parameters on the top of the stack in the reverse order
    add $8, %esp                     # pop the above two parameters from the stack
    
    pushl %ebp                       # ebp is the base pointer for the current stack frame
    movl %esp,  %ebp   
    andl $-8, %esp   
    movl $0, %ecx                    # ecx iterates over the double numbers (0,1,...,n-1)
    
#///////////////////////////////////////////////////////////////////////////////////////
input_loop:
   
    pushl %ecx                       # push to stack ecx because _scanf may change it

    pushl $var                       # push to stack the second parameter to scanf
    pushl $input2                    # push to stack the first parameter to scanf
    call _scanf        
    add $8, %esp                     # pop the above two parameters from the stack


    # sum = sum + var 
    fldl var                        # push var to the top of stack
    faddl sum                       # add var to sum 
    fstpl sum                       # pop stack top into the memory variable sum 
  
    popl %ecx                       # pop ecx
    add $1, %ecx
    cmpl %ecx, n                    # compare %ecx and n and update some status flags that will be used by ja below
    ja input_loop                   # ja = jump if above: goto input_loop only if n is above %ecx
    
#///////////////////////////////////////////////////////////////////////////////////////

    # print the sum of numbers -------------------------------------------
    pushl sum+4                      # push to stack the high 32-bits of the second parameter to printf
    pushl sum                        # push to stack the low 32-bits of the second parameter to printf
    pushl $output_sum                # push to stack the first parameter to printf
    call _printf                     # call printf
    add $12, %esp                    # pop the two parameters
    

    # calculate average avg = sum/n -------------------------------------------
    fildl n                         # push n to the stack
    fldl sum                        # push sum to the stack             
    fdivp %st(0), %st(1)            # sum / n 
    fstpl avg                       # pop the floating point stack top into the memory variable avg


    # print the average of double numbers -------------------------------------------
    pushl avg+4                    # push to stack the high 32-bits of the second parameter to printf
    pushl avg                      # push to stack the low 32-bits of the second parameter to printf
    pushl $output_avg              # push to stack the first parameter to printf
    call _printf                   # call printf
    add $12, %esp                  # pop the two parameters
	
	movl %ebp, %esp                #restore the old stack pointer - release all used memory
	popl %ebp                      #restore old frame pointer (the caller function frame)
         
    ret                            # end the main function

