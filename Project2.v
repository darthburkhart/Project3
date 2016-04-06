//`timescale 10ns/1ns
//DIRECTIVES
`define WORD [15:0]
`define OP [15:12]
`define REG1 [11:6]
`define REG2 [5:0]
`define REGZERO = 6'b0
`define REGONE  = 6'b1

`define JZ   4'h0
`define ADD  4'h1
`define AND  4'h2
`define ANY  4'h3
`define OR   4'h4
`define SHR  4'h5
`define XOR  4'h6
`define DUP  4'h7
`define LD   4'h8
`define ST   4'h9

`define LI   4'hA
`define ADDF 4'hB
`define F2I  4'hC
`define I2F  4'hD
`define INVF 4'hE
`define MULF 4'hF


//STATES
`define START 6'd0
`define ALUSTART 6'd1
`define ALUOP 6'd2
`define ALUEND 6'd3
`define INSTASK 6'd4
`define INSTWAIT 6'd5
`define MFC 6'd6
`define PCINC 6'd8
`define INSTRST 6'd9
`define INSTST 6'd10
`define DECODE 6'd11
`define LOADIMM 6'd12
`define STOREFROMMEM 6'd13
`define LDMFC 6'd14
`define DATAOUT 6'd15
`define LOADREG 6'd16
`define MDRST 6'd17
`define JUMPSTART 6'd18
`define ADD0 6'd19
`define PCLD 6'd20
`define WRITEMEM 6'd23
`define ISZERO 6'd24
`define HALT 6'd25
`define STEND 6'd26

`define CLEAR 1'b0;
//END DIRECTIVES


module register(in,out,clk,regin,regout,clr);
	output reg `WORD out;
	input `WORD in;
	input clk,regin,regout,clr;
	reg `WORD Q;
	
	initial begin
		Q <=16'b0;
		out <= 16'b0;
	end
	
	always @(posedge clk)
	begin
		if (regout == 1'b1)
		begin
			out <= Q;
		end
		if (regout == 1'b0)
		begin
			out <= 16'bZ;
		end
	end

	always @(negedge clk)
	begin
		if (regin == 1'b1)
		begin
			Q <= in;
			
		end
		if (regin == 1'b0)
		begin
			Q <= Q;
		end
	end
endmodule

module controller(instruction,clk,mfc,controls,conditionCodes,mdrCode, clr);
	input mfc,clk;
	input `WORD instruction, conditionCodes;
	output reg [0:63] controls;
	reg `WORD curr_state;
	reg `WORD nxt_state;
	reg firstWordFlag;
	input [3:0] mdrCode;
	reg skipNext;
	output reg clr;
	
	initial begin 
	controls[0:63] = 64'b0;
	curr_state <= `INSTASK;
	firstWordFlag <= 1'b1;
	nxt_state <= `INSTWAIT;
	skipNext <= 1'b0;
	clr <= 1'b0;
	end
	

	
	always @(posedge clk) begin
        
	end
	
	always @(negedge clk)
	begin
		curr_state <= nxt_state;
	end
	
	//Control Signals
	always @(curr_state)
	begin
		case(curr_state)
			`START: begin
				controls[0:63] <= 64'b0;
			end
			`ALUSTART: begin
				controls[8] <= 1'b1;
				controls[13] <= 1'b1;
				controls[14:19] <= instruction[5:0];
				controls[0:7] <= 8'b0;
				controls[9:12] <= 4'b0;
				controls[20:63] <= 44'b0;
			end
			`ALUOP: begin
				if (instruction[15:12] == `SHR) begin
					controls[10] <= 1'b1;
					controls[13] <= 1'b1;
					controls[14:19] <= 6'b000001;
					controls[23:26] <= instruction[15:12];
					controls[0:9] <= 10'b0;
					controls[11:12] <= 2'b0;
					controls[20:22] <= 3'b0;
					controls[27:63] <= 37'b0;
				end else begin
					controls[10] <= 1'b1;
					controls[13] <= 1'b1;
					controls[14:19] <= instruction[11:6];
					controls[23:26] <= instruction[15:12];
					controls[0:9] <= 10'b0;
					controls[11:12] <= 2'b0;
					controls[20:22] <= 3'b0;
					controls[27:63] <= 37'b0;
				end
			end
			`ALUEND: begin
				controls[11] <= 1'b1;
				controls[12] <= 1'b1;
				controls[14:19] <= instruction[11:6];
				controls[0:10] <= 11'b0;
				controls[13] <= 1'b0;
				controls[20:63] <= 44'b0;
			end
			`INSTASK: begin
				controls[3] <= 1'b1;
				controls[6] <= 1'b1;
				controls[8] <= 1'b1;
				controls[20] <= 1'b1;
				controls[0:2] <= 3'b0;
				controls[4:5] <= 2'b0;
				controls[7] <= 1'b0;
				controls[9:19] <= 11'b0;
				controls[21:63] <= 43'b0;
			end
			`INSTWAIT: begin
				controls[10] <= 1'b1;
				controls[13] <= 1'b1;
				controls[14:19] <= 6'b000001;
				controls[20] <= 1'b1;
				controls[23:26] <= `ADD;
				controls[0:9] <= 10'b0;
				controls[11:12] <= 2'b0;
				controls[21:22] <= 2'b0;
				controls[27:63] <= 37'b0;
			end
			`MFC: begin
				controls[20] <= 1'b1;
				controls[0:19] <= 20'b0;
				controls[21:63] <= 43'b0;
			end
			`PCINC: begin
				controls[2] <= 1'b1;
				controls[11] <= 1'b1;
				controls[27] <= 1'b1;
				controls[0:1] <= 2'b0;
				controls[3:10] <= 8'b0;
				controls[12:26] <= 15'b0;
				controls[28:63] <=36'b0;
			end
			`INSTRST: begin
				controls[0] <= 1'b1;
				controls[5] <= 1'b1;
				controls[1:4] <= 4'b0;
				controls[6:63] <= 58'b0;
				firstWordFlag <= 1'b0;
			end
			`INSTST: begin
				controls[0] <= 1'b1;
				controls[5] <= 1'b1;
				controls[1:4] <= 4'b0;
				controls[6:63] <= 58'b0;			
			end
			`DECODE: begin
				if (skipNext == 1'b1) begin
					//skipNext <= 1'b0;
					controls[0:63] <= 64'b0;
				end  else begin
					firstWordFlag <= 1'b1;
					controls[0:63] <= 64'b0;
				end
			end
			`LOADIMM: begin
				controls[5] <= 1'b1;
				controls[12] <= 1'b1;
				controls[14:19] <= instruction[11:6];
				controls[0:4] <= 5'b0;
				controls[6:11] <= 6'b0;
				controls[13] <= 1'b0;
				controls[20:63] <= 44'b0;
			end
			`STOREFROMMEM: begin
				controls[6] <= 1'b1;
				controls[13] <= 1'b1;
				controls[14:19] <= instruction[5:0];
				controls[20] <= 1'b1;
				controls[0:5] <= 6'b0;
				controls[7:12] <= 6'b0;
				controls[21:63] <= 43'b0;
			end
			`LDMFC: begin
				//Wait state
			end
			`DATAOUT: begin
				controls[4] <= 1'b1;
				controls[13] <= 1'b1;
				controls[14:19] <= instruction[11:6];
				controls[0:3] <= 4'b0;
				controls[5:12] <= 8'b0;
				controls[20:63] <= 44'b0;
			end
			`LOADREG: begin
				controls[14:19] <= instruction[5:0];
				controls[4] <= 1'b1;
				controls[13] <= 1'b1;
				controls[0:3] <= 4'b0;
				controls[5:12] <= 8'b0;
				controls[20:63] <= 44'b0;
			end
			`MDRST: begin
				controls[5] <= 1'b1;
				controls[14:19] <= instruction[11:6];
				controls[12] <= 1'b1;
				controls[0:4] <= 5'b0;
				controls[6:11] <= 6'b0;
				controls[13] <= 1'b0;
				controls[20:63] <= 44'b0;
			end
			`JUMPSTART: begin
				controls[14:19] <= instruction[11:6];
				controls[13] <= 1'b1;
				controls[8] <= 1'b1;
				controls[0:7] <= 8'b0;
				controls[9:12] <= 4'b0;
				controls[20:63] <= 44'b0;
			end
			`ADD0: begin
				controls[14:19] <= 6'b000000;
				controls[13] <= 1'b1;
				controls[23:26] <= `ADD;
				controls[0:12] <= 13'b0;
				controls[27:63] <= 37'b0;
				controls[20:22] <= 3'b0;
			end
			`ISZERO: begin
			
			end
			`PCLD: begin
				if (instruction[11:0] == 12'b000001000000)
				begin
					controls[0:63] <= 64'b0;
					skipNext <= 1'b1;
				end else begin
					controls[2] <= 1'b1;
					controls[13] <= 1'b1;
					controls[14:19] <= instruction[5:0];
					controls[0:1] <= 2'b0;
					controls[3:12] <= 10'b0;
					controls[20:63] <= 44'b0;
				end
			end
			`WRITEMEM: begin
				controls[14:19] <= instruction[5:0];
				controls[13] <= 1'b1;
				controls[6] <= 1'b1;
				controls[21] <= 1'b0;
				controls[0:5] <= 6'b0;
				controls[7:12] <= 6'b0;
				controls[20] <= 1'b0;
				controls[22:63] <= 42'b0;
			end
			`STEND: begin
				controls[21] <= 1'b1;
				controls[22:63] <= 42'b0;
				controls[0:20] <= 21'b0;
			end
			`HALT: begin
				clr <= 1'b1;
				controls[0:63] <= 64'b0;
			end
		endcase
	end

	always @(posedge clk or curr_state)
	begin
		case(curr_state)
			`START: begin
				nxt_state <= `INSTASK;
			end
			`ALUSTART: begin
				nxt_state <= `ALUOP;
			end
			`ALUOP: begin	
				nxt_state <= `ALUEND;
			end
			`ALUEND: begin
				nxt_state <= `INSTASK;
			end
			`INSTASK: begin
				nxt_state <= `INSTWAIT;
			end
			`INSTWAIT: begin
				nxt_state <= `MFC;
			end
			`MFC: begin
				if (mfc === 1'b1)
				begin
					nxt_state <= `PCINC;
				end else 
				begin
					nxt_state <= `MFC;
				end
			end
			`PCINC: begin
				if ((mdrCode == `LI))
				begin
					if (firstWordFlag == 1'b1)
					begin
						nxt_state <= `INSTRST;
					end else
					begin
						nxt_state <= `DECODE;
					end
				end  else if(instruction[15:12] == `LI) begin
					if (firstWordFlag == 1'b1)
					begin
						nxt_state <= `INSTST;
					end else
					begin
						nxt_state <= `DECODE;
					end
				end
				else
				begin
					nxt_state <= `INSTST;
				end
			end
			`INSTRST: begin
				nxt_state <= `INSTASK;
			end
			`INSTST: begin
				nxt_state <= `DECODE;
			end
			`DECODE: begin
				if (skipNext == 1'b1) begin
					skipNext <= 1'b0;
					nxt_state <= `INSTASK;
				end else begin
					firstWordFlag <= 1'b1;
					case(instruction[15:12])
						`ADD: begin
							nxt_state<=`ALUSTART;
						end
						`AND: begin
							nxt_state<=`ALUSTART;
						end
						`OR: begin
							nxt_state<=`ALUSTART;
						end
						`XOR: begin
							nxt_state<=`ALUSTART;
						end
						`SHR: begin
							nxt_state<=`ALUSTART;
						end
						`ANY: begin
							nxt_state<=`ALUSTART;
						end
						`LI: begin
							nxt_state<=`LOADIMM;
						end
						`LD: begin
							nxt_state<=`STOREFROMMEM;
						end
						`ST: begin
							nxt_state<=`DATAOUT;
						end
						`DUP: begin
							nxt_state<=`LOADREG;
						end
						`JZ: begin
							nxt_state<=`JUMPSTART;
						end
					endcase	
				end
			end	
				`LOADIMM: begin
					nxt_state<=`INSTASK;
				end
				`STOREFROMMEM: begin
					nxt_state<=`LDMFC;
				end
				`LDMFC: begin
					if (mfc === 1'b1)
						nxt_state<=`MDRST;
					else
						nxt_state <= `LDMFC;
				end
				`DATAOUT: begin
					nxt_state<=`WRITEMEM;
				end
				`WRITEMEM: begin
					nxt_state <= `STEND;
				end
				`STEND: begin
					nxt_state<= `INSTASK;
				end
				`LOADREG: begin
					nxt_state<=`MDRST;
				end
				`MDRST: begin
					nxt_state<=`INSTASK;
				end
				`JUMPSTART: begin
					nxt_state<=`ADD0;
				end
				`ADD0: begin
					nxt_state <= `ISZERO;
				end
				`ISZERO: begin
					if (conditionCodes[0] == 1'b0)
					begin
						nxt_state<=`INSTASK;
					end
					else if (instruction[11:0] == 12'b000000000000)
					begin
						nxt_state <= `HALT;
					end else begin
						nxt_state <= `PCLD;
					end
				end
				`PCLD: begin
					nxt_state <= `INSTASK;
				end
				`HALT: begin
					nxt_state <= `HALT;
				end
		endcase
	end

endmodule

module pc(in,out,clk,regin,regout,clr);
	input `WORD in;
	input clk,regin,regout,clr;
	output reg `WORD out;
	reg `WORD Q;
	
	initial begin
		Q <=16'b0;
		out <= 16'b0;
	end
	
	always @(posedge clk)
	begin
		if (regout == 1'b1)
		begin
			out <= Q;
		end
		if (regout == 1'b0)
		begin
			out <= 16'bZ;
		end
	end

	always @(negedge clk)
	begin
		if (regin == 1'b1)
		begin
			Q <= in;
			
		end
		if (regin == 1'b0)
		begin
			Q <= Q;
		end
	end
	
	always@(negedge clk) begin
	end
endmodule

module ir(in,out,contOut,clk,regin,regout,clr);
	input `WORD in;
	input clk,regin,regout,clr;
	output reg `WORD out;
	output reg `WORD contOut;
	reg `WORD Q;
	
	initial begin
		Q <=16'b0;
		out <= 16'b0;
	end
	
	always @(Q) begin
		contOut <= Q;
	end
		
	always @(posedge clk)
	begin
		if (regout == 1'b1)
		begin
			out <= Q;
		end
		if (regout == 1'b0)
		begin
			out <= 16'bZ;
		end
	end

	always @(negedge clk)
	begin
		if (regin == 1'b1)
		begin
			Q <= in;
			
		end
		if (regin == 1'b0)
		begin
			Q <= Q;
		end
	end
endmodule

module y(in,out,aluOut,clk,regin,regout,clr);
	input `WORD in;
	input clk,regin,regout,clr;
	output reg `WORD out;
	output `WORD aluOut;
	reg `WORD Q;
	
	initial begin
		Q <=16'b0;
		out <= 16'b0;
	end
	
	
	assign aluOut = Q;
	
		
	always @(posedge clk)
	begin
		if (regout == 1'b1)
		begin
			out <= Q;
		end
		if (regout == 1'b0)
		begin
			out <= 16'bZ;
		end
	end

	always @(negedge clk)
	begin
		if (regin == 1'b1)
		begin
			Q <= in;
			
		end
		if (regin == 1'b0)
		begin
			Q <= Q;
		end
	end

endmodule

module z(in,out,clk,regin,regout,clr);
	input `WORD in;
	input clk,regin,regout,clr;
	output reg `WORD out;
	reg `WORD state;
	//output `WORD aluOut;
	initial begin
		out <= 16'bZ;
		state <= 16'b1;
	end
	
	always @(negedge clk) begin
		if (regin == 1'b1) begin
			state <= in;
		end else begin
			state <= state;
		end
	end
	
	always @(posedge clk) begin
		if (regout == 1'b1) begin
			//out <= 16'b0;
			out <= state;
		end else begin
			out <= 16'bZ;
		end
	end
endmodule

module mar(in,out, clk, regin, regout, clr, ramout);
	input `WORD in;
	input clk, regin, regout, clr;
	output reg `WORD out;
	output `WORD ramout;
	reg `WORD outreg; 
	
	initial begin
		out <=16'bZ;
	end
	
	assign ramout =outreg;
	always @ (negedge clk) begin
		if (regin == 1'b1) begin
			outreg <= in;
		end else begin
			outreg <= outreg;
		end
	end
	always @(posedge clk) begin
		if (regout == 1'b1) begin
			out <= outreg;
		end else begin
			out <= 16'bZ;
		end
	end
endmodule

module mdr(in1,out1,in2,out2,clk,regin,regout,clr,mfc,memread,memwrite,mdrCode);
	input `WORD in1;
	input `WORD in2;
	output reg `WORD out1;
	output reg `WORD out2;
	input clk, regin,regout,clr,mfc,memread,memwrite;
	reg `WORD dataIn;
	wire `WORD dataOut;
	output [3:0] mdrCode;
	reg `WORD state;
	
	initial begin
		out1 <= 16'bZ;
		out2 <= 16'bZ;
		dataIn <= 16'b0;
	end
	
	assign mdrCode = dataIn[15:12];
	always @(mfc)
	begin
		if (mfc == 1'b1) begin
			dataIn <= in2;
		end
		else if (regin == 1'b1)begin
			dataIn <= in1;
		end else begin
			dataIn <= dataIn;
		end
	end
	
	always @(memwrite) begin
		if (memwrite == 1'b1) begin
			out2 <= dataIn;
		end else begin
			out2 <= 16'bZ;
		end	
	end
	
	always @(negedge clk) begin
		if(regin == 1'b1) begin
			dataIn <=in1;
		end else if (mfc == 1'b1) begin
			dataIn <=in2;
		end else begin
			dataIn <= dataIn;
		end
	end
	
	always @(posedge clk) begin
		if (regout == 1'b1) begin
			out1 <= dataIn;
			//out2 <= 16'bZ;
		end else begin
			out1 <= 16'bZ;
			//out2 <= 16'bZ;
		end
	end
	assign latch = regin | mfc;
endmodule

module RAM(clk,mdrin,mar,memread,memwrite,oe,mfc,mdrout,mfcReceived, memoryout);
	input `WORD mdrin;
	input `WORD mar;
	input memread, memwrite, oe,clk;
	output reg mfc;
	output reg `WORD mdrout;
	wire [31:0] k;
	reg `WORD mem[0:65535];
	input mfcReceived;
	output [65536*16-1:0] memoryout;
	initial begin

		//$readmemh1(mem);
		$readmemh("memoryInput1.txt",mem);
		mfc <= 1'b0;
		mdrout <= 16'b0;
	end
	genvar i;
	generate for (i = 0; i < 65536; i = i+1) begin:instmem
		assign memoryout[16*(i+1)-1 -: 16] = mem[i]; 
	end endgenerate
	
	always @(mfcReceived) begin
		mfc <= 0;
	end
	
	always @(memwrite or memread or mar or mdrin)
	begin
		if (memread == 1'b1)
		begin
			mdrout <= mem[mar];
			mfc <= 1'b1;
		end 
		else if (memwrite == 1'b1)
		begin
			mem[mar] <= mdrin;
			mfc <= 1'b0;
		end 

	end
endmodule


module ALU(opr1,opr2,out1,op,cc);
	input `WORD opr1;
	input `WORD opr2;
	output reg `WORD out1;
	input [3:0] op;
	output reg `WORD cc;
	
	initial begin
		out1 <= 16'b0;
		cc <= 16'b0;
	end
	
	always @(op or opr1 or opr2)
	begin
		case (op)
			`ADD: begin
				out1 <= opr1 + opr2;
			end
			`AND: begin
				out1 <= opr1 & opr2;
			end
			`ANY: begin
				out1 <= (opr1 == 16'b0 ? 16'b000000:16'b000001);
			end
			`OR: begin
				out1 <= opr1 | opr2;
			end	
			`SHR: begin
				out1 <= opr1 >> opr2;
				out1[15] <= opr1[15];
			end
			`XOR: begin
				out1 <= opr1 ^ opr2;
			end
		endcase
	end
	
	always @(out1)
	begin
		if (out1 == 16'b0 && op <7 && op>0)
		begin
			cc[0] <= 1'b1;
		end else if (op <7 && op>0) begin
			cc[0] <= 1'b0;
		end else begin
			cc <= cc;
		end
	end
endmodule


module registerFile(dataIn,dataOut,selReg,regin,regout,clk,memoryout);
	input `WORD dataIn;
	input [5:0] selReg;
	input regin,regout,clk;
	output reg `WORD dataOut;
	reg `WORD registers[0:63];
	wire[8:0] i;
	output [64*16-1:0] memoryout;
	
	initial begin
		dataOut <= 16'bZ;
		for (i = 0; i < 'd64; i = i+1) begin
			if (i < 2) begin
				registers[i] <= i;
			end else
			if (i == 2) begin
				registers[i] <= 16'h8000;
			end else
			if (i == 3) begin
				registers[i] <= 16'hFFFF;
			end else begin
				registers[i] <= 16'b0;
			end
		end
	end
	
	genvar g;
	generate for (g = 0; g < 64; g = g+1) begin:instmem
		assign memoryout[16*(g+1)-1 -: 16] = registers[g]; 
	end endgenerate
	

	always @(negedge clk) begin
		if (regin == 1'b1 && selReg != 6'b000000 && selReg != 6'b000001 && selReg != 6'b000010 && selReg != 6'b000011 ) begin
			registers[selReg] <= dataIn;
		end 

	end
	
	always @(posedge clk) begin
		if (regout == 1'b1) begin
			dataOut <= registers[selReg];
		end else begin
			dataOut <= 16'bZ;
		end
	end
endmodule

module testBench;
	wire [0:63] controls;
	wire mfc;
	wire `WORD conditionCodes;
	wire `WORD instruction;
	//reg `WORD instruction;
	reg clk;
	reg clr;
	wire clear;
	wire `WORD toRam;
	wire `WORD bus;
	wire `WORD mdrRAM;
	wire `WORD RAMmdr;
	wire [3:0] data;
	wire `WORD i;
	
	wire `WORD zWire;
	wire `WORD yWire;
	wire [65536*16-1:0] mem;
	wire [64*16-1:0] mem1;
	reg `WORD memTest [0:100];
	//output reg `WORD memRam ;//[0:65535];
	//output reg `WORD regFile ;//[0:63];
	assign clear = 0;
	z Z(zWire,bus,clk,controls[10],controls[11],clr);
	y Y(bus,bus,yWire,clk,controls[8],controls[9],clr);
	ALU alu(yWire,bus,zWire,controls[23:26],conditionCodes);
	
	controller cont(instruction,clk,mfc,controls,conditionCodes,data,clear);
	ir IR(bus,bus,instruction,clk,controls[0],controls[1],clr);
	pc PC(bus,bus,clk,controls[2],controls[3],clr);
	mar MAR(bus,bus,clk,controls[6],controls[7],clr,toRam);
	mdr MDR(bus,bus,RAMmdr,mdrRAM,clk,controls[4],controls[5],clr,mfc,controls[20],controls[21],data);
	RAM ram(clk,mdrRAM,toRam,controls[20],controls[21],controls[22],mfc,RAMmdr,controls[27],mem);
	registerFile rf(bus,bus,controls[14:19],controls[12], controls[13],clk,mem1);
	
	
	initial 
	begin
	$readmemh("memOut.txt",memTest);
//$dumpfile;
	//$dumpvars(0,testBench);
	
	#100 //Wait until ALL memory is initialized
	clr <= 1'b0;
	
		
        clk <= 0;
		while (clear != 1)
		begin

			#100;
			clk<=~clk;
			
		end
		for (i = 0; i<26; i = i+1) begin
			if (mem[(i+1)*16-1 -:16] != memTest[i]) begin
				$display("Error at RAM address %d",i);
			end
		end
		if (mem[(32769+1)*16-1 -:16] != memTest[26]) begin
				$display("Error at RAM address %d",26);
		end
		if (mem[(65536+1)*16-1 -:16] != memTest[27]) begin
				$display("Error at RAM address %d",27);
		end
		for (i = 0; i<64; i = i+1) begin
		if (mem1[(i+1)*16-1 -:16] != memTest[28+i]) begin
				$display("Error at RAM address %d",26);
		end
		end
	end
	
	
endmodule