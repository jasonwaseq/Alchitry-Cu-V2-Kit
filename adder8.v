module FA(
    input a,
    input b,
    input Cin,
    output s,
    output Cout
);
    assign s = a ^ b ^ Cin;
    assign Cout = (a & b) | (a & Cin) | (b & Cin);
endmodule

module adder8(
    input [7:0] A,
    input [7:0] B,
    input Cin,
    output [7:0] S,
    output ovfl,
    output Cout
);
    wire [6:0] C;
    
    FA fa0(.a(A[0]), .b(B[0]), .Cin(Cin), .s(S[0]), .Cout(C[0]));
    FA fa1(.a(A[1]), .b(B[1]), .Cin(C[0]), .s(S[1]), .Cout(C[1]));
    FA fa2(.a(A[2]), .b(B[2]), .Cin(C[1]), .s(S[2]), .Cout(C[2]));
    FA fa3(.a(A[3]), .b(B[3]), .Cin(C[2]), .s(S[3]), .Cout(C[3]));
    FA fa4(.a(A[4]), .b(B[4]), .Cin(C[3]), .s(S[4]), .Cout(C[4]));
    FA fa5(.a(A[5]), .b(B[5]), .Cin(C[4]), .s(S[5]), .Cout(C[5]));
    FA fa6(.a(A[6]), .b(B[6]), .Cin(C[5]), .s(S[6]), .Cout(C[6]));
    FA fa7(.a(A[7]), .b(B[7]), .Cin(C[6]), .s(S[7]), .Cout(Cout));
    
    assign ovfl = C[6] ^ Cout;
endmodule