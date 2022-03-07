// Install the file: iverilog-10.0-x86_setup.exe from: bleyer.org/icarus/
// Add the path C:\iverilog\bin to the PATH environment variable
// Go the folder containing ALU_N_bits.vl, then execute the following commands from the command prompt:
// iverilog -o ALU_N_bits ALU_N_bits.vl
// vvp ALU_N_bits 
///////////////////////////////////////////////////////////////////////////////////////
//      Assignment -2 (( N-bits ALU ))         
//      Abdalla Fadl Shehata  -    20190305  
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
`define NUM_BITS 8 // Try 4,5,6,7,8
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
module adding_one(a,s,cin,cout); // adding one to first number (a) n bits if selection inputs are s0=0,s1=0,s2=0 ( 0 0 0 )
    parameter N = `NUM_BITS-1;
    input [N:0] a;
    input cin;
    output cout;
    output [N+1:0] s;                 ///////////////////////////////////////////////////
    wire [N:0] b = 8'b00000001;      // WE CHANGE b ACCORDING TO NUMBER OF BITS ( N ) // 
    wire [N:0] carry;               ///////////////////////////////////////////////////
    generate
    genvar i;
    for(i=0;i<=N;i=i+1)
    begin
      if (i==0) full_adder fa1(a[i],b[i],cin,s[i],carry[i]);
      else      full_adder fa2(a[i],b[i],carry[i-1],s[i],carry[i]);
    end
    endgenerate  
      full_adder fa3(1'b0,1'b0,carry[N],s[N+1],cout); 
endmodule
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
module arithmetic_shift_right(A,C); // arithmetic shift right for first number (a) n bits if selection inputs are s0=0,s1=0,s2=1 ( 0 0 1 )
    parameter N = `NUM_BITS-1;
    input [N:0] A;                    
    output[N+1:0] C;
    generate
    genvar i;
    for(i=0;i<=N;i=i+1)
    begin
      if (i==N)   buf  b1(C[i],1'b0);
      else        buf  b2(C[i],A[i+1]);
    end
    endgenerate 
    buf  b2(C[N+1],1'b0);   
endmodule
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module full_adder(a,b,cin,s,cout);   // full adder module 
    output s,cout; 
    wire w1,w2,w3; 
    input a,b,cin; 
    xor(w1,a,b);
    xor(s,w1,cin);
    and(w2,a,b);
    and(w3,w1,cin);
    or(cout,w3,w2);
endmodule
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module full_adder_test(a,b,s,cin,cout); // full adder test if  selection inputs are s0=0,s1=1,s2=0    ( 0 1 0 )
    parameter N = `NUM_BITS-1;
    input [N:0] a,b;
    input cin;
    output cout;
    output [N+1:0] s;   
    wire  carry_out;
    wire [N:0] carry;       
    genvar i;
    generate 
    for(i=0;i<=N;i=i+1)
     begin
        if(i==0) full_adder fa1(a[i],b[i],cin,s[i],carry[i]);
        else     full_adder fa2(a[i],b[i],carry[i-1],s[i],carry[i]);
     end
   endgenerate
       full_adder fa3(1'b0,1'b0,carry[N],s[N+1],cout);
endmodule
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module twos_complement(A,Z); // Two's complement of a 4 bit number
    parameter N = `NUM_BITS-1;
    input [N:0] A; 
    output [N+1:0] Z; 
    output cout;
    wire [N:0] a;
    generate
    genvar i;
    for(i=0;i<=N;i=i+1)
    begin
      not(a[i],A[i]);
    end
    endgenerate 
    wire [N:0] in;
    generate
    genvar j;
    for(j=0;j<=N;j=j+1)
    begin
      assign in[j] = a[j];
    end
    endgenerate                                             ///////////////////////////////////////////////////
    full_adder_test fa(in,8'b00000001,Z,1'b0,cout);        // WE CHANGE b ACCORDING TO NUMBER OF BITS ( N ) //      
endmodule                                                 ////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module substract_test(A,B,C); // substract two 4 bits number if selection inputs are s0=0,s1=1,s2=1 ( 0 1 1 )
    parameter N = `NUM_BITS-1;
    input [N:0] A,B;
    output [N+1:0] C;
    output [N+1:0] C2;
    output cout;
    wire [N+1:0] out;
    twos_complement fa1(B,out);
    wire [N:0] out2;
    generate
    genvar i;
    for(i=0;i<=N;i=i+1)
    begin
     buf b1(out2[i],out[i]);
    end
    endgenerate 
    full_adder_test fa(A,out2,C2,1'b0,cout);
    generate
    genvar j;
    for(j=0;j<=N;j=j+1)
    begin
     buf b2(C[j],C2[j]);
    end
    endgenerate
    not(C[N+1],C2[N+1]);        
endmodule
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module substract_one(A,C); // substract one from first number (a) 4 bits if selection inputs are s0=1,s1=0,s2=0 ( 1 0 0 )
    parameter N = `NUM_BITS-1;
    input [N:0] A,B;
    output [N+1:0] C;
    output [N+1:0] C2;
    output cout;
    wire [N+1:0] out;                          ///////////////////////////////////////////////////
    wire [N:0] B = 8'b00000001;               // WE CHANGE b ACCORDING TO NUMBER OF BITS ( N ) // 
    twos_complement fa1(B,out);              ////////////////////////////////////////////////////
    wire [N:0] out2;
    generate
    genvar i;
    for(i=0;i<=N;i=i+1)
    begin
     buf b1(out2[i],out[i]);
    end
    endgenerate 
    full_adder_test fa(A,out2,C2,1'b0,cout);
    generate
    genvar j;
    for(j=0;j<=N;j=j+1)
    begin
     buf b2(C[j],C2[j]);
    end
    endgenerate
    not(C[N+1],C2[N+1]);        
endmodule
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module AND(a,b,c);    //    AND operation of 2 Numbers A and B if selection inputs are s0=1,s1=0,s2=1 ( 1 0 1 )
    parameter N = `NUM_BITS-1;
    input [N:0] a,b;
    output [N+1:0] c;
    generate
    genvar i;
    for(i=0;i<=N;i=i+1)
    begin
      and(c[i],a[i],b[i]);
    end
    endgenerate   
endmodule
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module OR(a,b,c);    //    OR operation of 2 Numbers A and B if selection inputs are s0=1,s1=1,s2=0 ( 1 1 0 )  
    parameter N = `NUM_BITS-1;
    input [N:0] a,b;
    output [N+1:0] c;
    generate
    genvar i;
    for(i=0;i<=N;i=i+1)
    begin
      or(c[i],a[i],b[i]);
    end
    endgenerate 
endmodule
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module XOR(a,b,c);     //  XOR operation of 2 Numbers A and B if selection inputs are s0=1,s1=1,s2=1 ( 1 1 1 )
    parameter N = `NUM_BITS-1;
    input [N:0] a,b;
    output [N+1:0] c;
    generate
    genvar i;
    for(i=0;i<=N;i=i+1)
    begin
      xor(c[i],a[i],b[i]);
    end
    endgenerate 
endmodule
//////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////
module mux_8to_1(out,i0,i1,i2,i3,i4,i5,i6,i7,s0,s1,s2); // 8:1 multiplexer 
    input i0,i1,i2,i3,i4,i5,i6,i7,s0,s1,s2;
    output out;
    wire w1,w2,w3,w4,w5,w6,w7,w8,s00,s01,s02;
    not(s00,s0);
    not(s01,s1);
    not(s02,s2);
    and(w1,i0,s00,s01,s02);
    and(w2,i1,s00,s01,s2);
    and(w3,i2,s00,s1,s02);
    and(w4,i3,s00,s1,s2);
    and(w5,i4,s0,s01,s02);
    and(w6,i5,s0,s01,s2);
    and(w7,i6,s0,s1,s02);
    and(w8,i7,s0,s1,s2);
    or(out,w1,w2,w3,w4,w5,w6,w7,w8);
endmodule
///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
module ALU(a,b,outp,s0,s1,s2);
    parameter N = `NUM_BITS-1;
    input [N:0] a,b;
    input s0,s1,s2;
    output cout;
    wire [N+1:0] c1,c2,c3,c4,c5,c6,c7,c8;
    output [N+1:0]outp;
    adding_one fa0(a,c1,1'b0,cout);            //      carry = 0 
    arithmetic_shift_right fa1(a,c2);
    full_adder_test fa2(a,b,c3,1'b0,cout);     //      carry = 0 
    substract_test fa3(a,b,c4);
    substract_one fa4(a,c5);
    AND fa5(a,b,c6);
    OR fa6(a,b,c7);
    XOR fa7(a,b,c8);
    generate
    genvar i;
    for(i=0;i<=N+1;i=i+1)
    begin
      mux_8to_1 mux_obj(outp[i],c1[N+1-i],c2[N+1-i],c3[N+1-i],c4[N+1-i],c5[N+1-i],c6[N+1-i],c7[N+1-i],c8[N+1-i],s0,s1,s2);
    end
    endgenerate   
endmodule
//*************************************************************************************************************//
//*************************************************************************************************************//
//*************************************************[[[[[[[Main]]]]]]]******************************************//
module main();
    parameter N = `NUM_BITS-1;  // N = 8 bits , WE CAN CHANGE N IN LINE 12   [ N CAN BE 4 OR 5 OR 6 OR 7 OR 8 ] 
    reg [N:0] a,b;
    reg s0,s1,s2;
    wire [N+1:0] outp;
    ALU obj(a,b,outp,s0,s1,s2);
    initial    
    begin
        s0=0;s1=0;s2=0;
        a<= 8'b00001010;
        b<= 8'b00000011;        
        // TO DISPLAY THE RESULT
        if(N==7) $monitor("RESULT = %b %b %b %b %b %b %b %b %b\n",outp[0],outp[1],outp[2],outp[3],outp[4],outp[5],outp[6],outp[7],outp[8]);
        if(N==6) $monitor("RESULT = %b %b %b %b %b %b %b %b\n",outp[0],outp[1],outp[2],outp[3],outp[4],outp[5],outp[6],outp[7]);
        if(N==5) $monitor("RESULT = %b %b %b %b %b %b %b\n",outp[0],outp[1],outp[2],outp[3],outp[4],outp[5],outp[6]);
        if(N==4) $monitor("RESULT = %b %b %b %b %b %b\n",outp[0],outp[1],outp[2],outp[3],outp[4],outp[5]);
        if(N==3) $monitor("RESULT = %b %b %b %b %b\n",outp[0],outp[1],outp[2],outp[3],outp[4]);  
    end 
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
<<selection inputs>>       <<operation>>

s0     s1     s2              output

0      0      0                a+1

0      0      1             shift right (a)

0      1      0                 a+b

0      1      1                 a-b

1      0      0                 a-1

1      0      1               a and b 

1      1      0               a or b

1      1      1               a xor b

*/
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////