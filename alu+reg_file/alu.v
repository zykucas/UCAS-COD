`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

`define ALUOP_AND 3'b000
`define ALUOP_OR 3'b001
`define ALUOP_XOR 3'b100
`define ALUOP_NOR 3'b101
`define ALUOP_ADD 3'b010
`define ALUOP_SUB 3'b110
`define ALUOP_SLT 3'b111
`define ALUOP_SLTU 3'b011


//加法器模块
module ADD(
	input [`DATA_WIDTH-1:0] A,
	input [`DATA_WIDTH-1:0] B,
	input  cin,
	output [`DATA_WIDTH-1:0] result,
	output cout
);

assign {cout,result}=A+B+{32'b0,cin};

endmodule

//ALU模块
module alu(
	input  [`DATA_WIDTH - 1:0]  A,
	input  [`DATA_WIDTH - 1:0]  B,
	input  [              2:0]  ALUop,
	output                      Overflow,
	output                      CarryOut,
	output                      Zero,
	output [`DATA_WIDTH - 1:0]  Result
);
	//八种运算对应的操作符
	wire op_and = ALUop == `ALUOP_AND;
	wire op_or = ALUop == `ALUOP_OR;
	wire op_xor = ALUop == `ALUOP_XOR;
	wire op_nor = ALUop == `ALUOP_NOR;
	wire op_add = ALUop == `ALUOP_ADD;
	wire op_sub = ALUop == `ALUOP_SUB;
	wire op_slt = ALUop == `ALUOP_SLT;  
	wire op_sltu = ALUop == `ALUOP_SLTU;  

	wire [31:0] and_res = A & B;
	wire [31:0] or_res = A | B;
	wire [31:0] xor_res = A ^ B;
	wire [31:0] nor_res = (~A) & (~B);
	wire [31:0] add_res,sub_res,slt_res,slt_sub_res,sltu_res,sltu_sub_res
		    ,addnum,res;
	wire cin,off,
	     of_add,of_sub,of_slt,of_sltu;

	//例化加法器
	ADD add(.A(A),.B(addnum),.cin(cin),.result(res),.cout(off)); 

	assign addnum= {32{op_add}} & B  |  {32{op_sub}} & (~B) | {32{op_slt}} & (~B) | {32{op_sltu}} & (~B) ;  //选择被加数
	assign cin= {op_add} & (1'b0) |  {op_sub} & (1'b1) | {op_slt} & (1'b1) | {op_sltu} & (1'b1);   //选择进位输入
	assign add_res={32{op_add}} & res;  
	assign sub_res={32{op_sub}} & res;
	assign slt_sub_res={32{op_slt}} & res; 
	assign sltu_sub_res={32{op_sltu}} & res;  //选择加法器输出的和
	assign of_add={op_add} & off;
	assign of_sub={op_sub} & off;
	assign of_slt={op_slt} & off;
	assign of_sltu={op_sltu} & off;	//选择加法器输出的进位

    	//有符号数加减运算的溢出
	assign Overflow = {op_add} & ((A[31] == B[31]) && (A[31]!=add_res[31])) 
			  | {op_sub} & ((A[31] == ~B[31]) && (Result[31] != A[31]))
			  | {op_and|op_or|op_slt} & 1'b0;   
			     
	//无符号数加减运算的溢出
	assign CarryOut = {op_add} & (of_add) | {op_sub} & ((B!=32'b0)?(~of_sub):0) | {op_and|op_or|op_slt} & 1'b0;  
	
	assign slt_res[0]= ((A==B) & 0) 
			   | ((A!=B & A[31] == B[31]) & (~of_slt))
			   | ((A!=B & A[31] != B[31]) & (A[31]));   //分情况输出比较结果
	assign slt_res[31:1]=0;  //slt_res补位
	assign sltu_res[0] = (B == 32'b0) & 1'b0 | (B != 32'b0) & (~of_sltu);
	assign sltu_res[31:1] = 0;


	assign Result =
		{32{op_and}} & and_res |
		{32{op_or }} & or_res |
		{32{op_xor}} & xor_res |
		{32{op_nor }} & nor_res |
		{32{op_add}} & add_res |
		{32{op_sub}} & sub_res |
		{32{op_slt}} & slt_res |
		{32{op_sltu}} & sltu_res  ;

	assign Zero = (Result==32'b0);
endmodule
