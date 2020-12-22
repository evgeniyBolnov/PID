module AMM_Master #(
	parameter ADDR_WIDTH = 2       ,
	parameter SLAVE_ADDR = 16'hDEAD
) (
	input                         clk              ,
	input                         reset            ,
	input        [ADDR_WIDTH-1:0] ams_address      ,
	input                         ams_write        ,
	input        [          31:0] ams_writedata    ,
	input                         ams_read         ,
	output logic [          31:0] ams_readdata     ,
	output logic [          31:0] ams_readdatavalid,
	output logic                  ams_waitrequest
);

	logic [31:0] ram[2**ADDR_WIDTH];


	localparam min_wait_request    = 5;
	localparam valid_delay_request = 5;

	int ams_waitrequest_cnt = 0;
	int ams_valid_delay     = 0;

	always_ff @(posedge clk or posedge reset)
		if (reset)
			begin
				ams_waitrequest     <= '1;
				ams_waitrequest_cnt <= '0;
			end
		else
			begin
				if (ams_read && ams_waitrequest_cnt > min_wait_request)
					begin
						ams_waitrequest     <= '0;
						ams_waitrequest_cnt <= '0;
					end
				else
					ams_waitrequest <= 1'b1;
				if (ams_waitrequest)
					ams_waitrequest_cnt <= ams_waitrequest_cnt + 1;
			end

	always_ff @(posedge clk or posedge reset)
		if (reset)
			begin
				ams_valid_delay   <= '0;
				ams_readdata      <= '0;
				ams_readdatavalid <= '0;
			end
		else
			begin
				if (ams_read && ~ams_waitrequest)
					begin
						ams_valid_delay <= ams_valid_delay + 1;
					end
				if (ams_valid_delay > 0)
					begin
						if (ams_valid_delay == valid_delay_request)
							begin
								ams_readdata      <= ram[ams_address];
								ams_readdatavalid <= 1'b1;
								ams_valid_delay   <= '0;
							end
						else
							begin
								ams_readdatavalid <= '0;
								ams_valid_delay   <= ams_valid_delay + 1;
							end
					end
				else
					ams_readdatavalid <= '0;
			end

endmodule