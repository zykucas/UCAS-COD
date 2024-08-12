`timescale 10 ns / 1 ns

`define DATA_WIDTH 32
`define ADDR_WIDTH 5

module reg_file(
	input                       clk,
	input  [`ADDR_WIDTH - 1:0]  waddr,
	input  [`ADDR_WIDTH - 1:0]  raddr1,
	input  [`ADDR_WIDTH - 1:0]  raddr2,
	input                       wen,
	input  [`DATA_WIDTH - 1:0]  wdata,
	output [`DATA_WIDTH - 1:0]  rdata1,
	output [`DATA_WIDTH - 1:0]  rdata2
);

	//wire 	clk;
	reg 	[31:0] rf [31:0]; 
	//wire 	[31:0] rdata1;
	//wire 	[31:0] rdata2;
	//wire 	[31:0] wdata;
	//wire 	[4:0] raddr1;
	//wire 	[4:0] raddr2;
	//wire 	[4:0] waddr;

	always @(posedge clk) 
	begin
		if (waddr!=0&&wen==1) //写入条件
			rf[waddr] <= wdata;
	end

	assign rdata1=((raddr1==0)?32'd0:rf[raddr1]);
	assign rdata2=((raddr2==0)?32'd0:rf[raddr2]);	


endmodule
