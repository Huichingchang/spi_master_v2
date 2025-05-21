`timescale 1ns/1ps
module spi_master_v2_tb;
	reg clk;
	reg rst_n;
	reg start;
	reg [7:0] data_in;
	reg [3:0] data_len;
	reg [1:0] cs_sel;
	reg miso;
	
	wire busy;
	wire done;
	wire [7:0] data_out;
	wire sclk;
	wire mosi;
	wire [3:0] cs_n;
	
	//測試資料陣列與計數器  
	reg [7:0] test_data [0:2];  //宣告陣列
	integer i;   //宣告計數器
	
	// Instantiate DUT
	spi_master_v2 uut(
		.clk(clk),
		.rst_n(rst_n),
		.start(start),
		.data_in(data_in),
		.data_len(data_len),
		.cs_sel(cs_sel),
		.busy(busy),
		.done(done),
		.data_out(data_out),
		.sclk(sclk),
		.mosi(mosi),
		.miso(miso),
		.cs_n(cs_n)
	);
	
	// Clock generation
	initial clk = 0;
	always #5 clk = ~clk;  // 100MHz
	
	// Stimulus
	initial begin
		$display("===SPI Master V2 Multi-Byte Transmission Test===");
		
		//Init
		rst_n = 0;
		start = 0;
		data_in = 8'h00;
		data_len = 4'd3;  // Transmit 3 Bytes
		cs_sel = 2'd1;
		miso = 0;
		
		// Load test data
		test_data[0] = 8'hA5;
		test_data[1] = 8'h3C;
		test_data[2] = 8'h7E;
		
		#20;
		rst_n = 1;
		
		//Trigger start
		#20;
		data_in = test_data[0];  // Send first byte
		start = 1;
		#10;
		start = 0;
		
		//Provide remining bytes during LOAD
		i = 1;
		 forever begin
			@(posedge clk);
			if (busy && (sclk == 0) && (uut.state == 2'b01)) begin // during LOAD
				if (i < data_len) begin
					data_in = test_data[i];
					i = i + 1;
				end
			end
			
			if (done) begin
				$display("Transmission complete. Final data_out = %h", data_out);
				#20;
				$stop;
			end
	   end
	end
endmodule