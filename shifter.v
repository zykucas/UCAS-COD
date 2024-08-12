`timescale 10 ns / 1 ns

`define DATA_WIDTH 32

`define SHIFTOP_LEFT 2'b00
`define SHIFTOP_RIGHT_ART 2'b11
`define SHIFTOP_RIGHT_LOG 2'b10

module shifter (
	input  [`DATA_WIDTH - 1:0] A,
	input  [              4:0] B,
	input  [              1:0] Shiftop,
	output [`DATA_WIDTH - 1:0] Result
); 
	// 三种运算对应的操作码
	wire op_left = Shiftop == `SHIFTOP_LEFT;
	wire op_right_art = Shiftop == `SHIFTOP_RIGHT_ART;
	wire op_right_log = Shiftop == `SHIFTOP_RIGHT_LOG; 

	wire [31:0] ari_num = ~(32'hffffffff >> B);   //辅助计算算数右移结果
	wire [31:0] left_res = A<<B;
	wire [31:0] right_art_res = (A[31]) ? (ari_num ^ (A >> B)) : (A >> B);
	wire [31:0] right_log_res = A>>B;
	
	//选择最终结果
	assign Result =
		{32{op_left}} & left_res |
		{32{op_right_art}} & right_art_res |
		{32{op_right_log}} & right_log_res ;  
endmodule
