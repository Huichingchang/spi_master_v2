`timescale 1ns/1ps
module spi_master_v2 #(
	parameter DATA_WIDTH = 8,
	parameter MAX_CS = 4,
	parameter CS_SEL_WIDTH = 2  // log2(MAX_CS)
)(		
	input clk,
	input rst_n,

	//控制介面
	input start,
	input [DATA_WIDTH-1:0] data_in,
	input [3:0] data_len,  //幾個Byte要送
	input [CS_SEL_WIDTH-1:0] cs_sel,  //選哪一個CS
	
	output reg busy,
	output reg done,
	output reg [DATA_WIDTH-1:0] data_out,
	
	output reg sclk,
	output reg mosi,
	input miso,
	output reg [MAX_CS-1:0] cs_n

);

	// FSM狀態定義
	localparam IDLE = 2'b00;
	localparam LOAD = 2'b01;
	localparam SHIFT = 2'b10;
	localparam FINISH = 2'b11;
	
	reg [1:0] state, next_state;
	
	reg [DATA_WIDTH-1:0] shift_reg;
	reg [2:0] bit_cnt;
	reg [3:0] byte_cnt;
	
	// CS 控制
	integer i;
	always @(*) begin
		for (i = 0; i < MAX_CS; i = i + 1) begin
			cs_n[i] = 1'b1;
		end
		if (busy) begin
			cs_n[cs_sel] = 1'b0;
		end
	end
	
	// FSM狀態轉移邏輯
	always @(*) begin
		next_state = state;
		case(state)
			IDLE: if (start) next_state = LOAD;
			LOAD: next_state = SHIFT;
			SHIFT: if (bit_cnt == 3'd7) begin
				if (byte_cnt == data_len - 1)
					 next_state = FINISH;
				else
					 next_state = LOAD;
			   end
			FINISH: next_state = IDLE;
		endcase
	end
	
	//主邏輯(同步區塊)
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			state <= IDLE;
			shift_reg <= 0;
			bit_cnt <= 0;
			byte_cnt <= 0;
			busy <= 0;
			done <= 0;
			sclk <= 0;
			mosi <= 0;
			data_out <= 0;
		end
		else begin
			state <= next_state;
			
			case (state)
				IDLE: begin
					done <= 0;
					busy <= 0;
					byte_cnt <= 0;
					sclk <= 0;
					mosi <= 0;
				end
				
				LOAD: begin
					shift_reg <= data_in;  //外部提供資料
					bit_cnt <= 0; 
					mosi <= data_in[DATA_WIDTH-1];  //預設先送MSB
					byte_cnt <= byte_cnt + 1;  
					busy <= 1;
				end
				
				SHIFT: begin
					sclk <= ~sclk;
					
					if (sclk == 0) begin  // edge: output
					   mosi <= shift_reg[DATA_WIDTH-1];
						shift_reg <= {shift_reg[DATA_WIDTH-2:0], miso};
						bit_cnt <= bit_cnt + 1;
					end
				end
				
				FINISH: begin
					busy <= 0;
					done <= 1;
					sclk <= 0;
					data_out <= shift_reg;
				end
			endcase
			
			// done清除:只保持一拍
			if (state == FINISH) 
				done <= 1;
		   else
				done <= 0;
		end
	end
endmodule