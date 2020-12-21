module pid_tb;

	import "DPI-C" function int get_temp(input int signal);

	logic clk   = 0;
	logic reset = 0;

	integer temperature    ;
	integer control     = 0;
	integer refer       = 0;
	integer k           = 0;

	default clocking main @(posedge clk);
	endclocking

	initial fork
		forever #1 clk = ~clk;
		begin
			##1 reset = 1;
			##2 reset = 0;
			##100000 refer = 20;
			##100000 refer = -20;
			// ##100 refer = 40;
			// ##100 refer = -40;
			// ##100 refer = 80;
			// ##100 refer = -45;
			// ##100 refer = 180;
			// ##100 refer = 0;
			##200000 $finish;
		end
	join


	logic [15:0] temp_address;
	logic temp_read;
	logic [31:0] temp_readdata;
	logic temp_readdatavalid;
	logic temp_waitrequest;
	logic [15:0] pwm_address;
	logic pwm_write;
	logic [31:0] pwm_writedata;
	logic pwm_waitrequest;

	pid_control #(
		.SENSOR_ADDR(16'hdead),
		.PWM_ADDR   (16'hdead)
	) pid_control_inst (
		.clk               (clk               ),
		.reset             (reset             ),
		.temp_address      (temp_address      ),
		.temp_read         (temp_read         ),
		.temp_readdata     (temp_readdata     ),
		.temp_readdatavalid(temp_readdatavalid),
		.temp_waitrequest  (temp_waitrequest  ),
		.pwm_address       (pwm_address       ),
		.pwm_write         (pwm_write         ),
		.pwm_writedata     (pwm_writedata     ),
		.pwm_waitrequest   (pwm_waitrequest   )
	);

	localparam min_wait_request    = 5;
	localparam valid_delay_request = 5;

	int temp_waitrequest_cnt = 0;
	int temp_valid_delay     = 0;
	int pwm_waitrequest_cnt  = 0;
	int pwm_valid_delay      = 0;

	always_ff @(posedge clk or posedge reset)
		if (reset)
			begin
				temp_waitrequest     <= '1;
				temp_waitrequest_cnt <= '0;
			end
		else
			begin
				if (temp_read && temp_waitrequest_cnt > min_wait_request)
					begin
						temp_waitrequest     <= '0;
						temp_waitrequest_cnt <= '0;
					end
				else
					temp_waitrequest <= 1'b1;
				if (temp_waitrequest)
					temp_waitrequest_cnt <= temp_waitrequest_cnt + 1;
			end

	always_ff @(posedge clk or posedge reset)
		if (reset)
			begin
				temp_valid_delay   <= '0;
				temp_readdata      <= '0;
				temp_readdatavalid <= '0;
			end
		else
			begin
				if (temp_read && ~temp_waitrequest && temp_address == 16'hDEAD)
					begin
						temp_valid_delay <= temp_valid_delay + 1;
					end
				if (temp_valid_delay > 0)
					begin
						if (temp_valid_delay == valid_delay_request)
							begin
								temp_readdata      <= temperature;
								temp_readdatavalid <= 1'b1;
								temp_valid_delay   <= '0;
							end
						else
							begin
								temp_readdatavalid <= '0;
								temp_valid_delay   <= temp_valid_delay + 1;
							end
					end
				else
					temp_readdatavalid <= '0;
			end

	always_ff @(posedge clk or posedge reset)
		if (reset)
			begin
				pwm_waitrequest     <= '1;
				pwm_waitrequest_cnt <= '0;
			end
		else
			begin
				if (pwm_write && pwm_waitrequest_cnt > min_wait_request)
					begin
						pwm_waitrequest     <= '0;
						pwm_waitrequest_cnt <= '0;
					end
				else
					begin
						pwm_waitrequest <= 1'b1;
					end
				if (pwm_waitrequest)
					pwm_waitrequest_cnt <= pwm_waitrequest_cnt + 1;
			end

	always_ff @(posedge clk or posedge reset)
		if (reset)
			begin
				control <= '0;
			end
		else
			begin
				if (pwm_write && ~pwm_waitrequest && pwm_address == 16'hDEAD)
					control <= pwm_writedata;
			end

	always @(posedge clk)
		begin
			if (k < 10)
				begin
					k           <= k+ 1;
					temperature <= 30;
				end
			else
				begin
					if (control < 0)
						temperature <= get_temp(0);
					else if (control > 4095)
						temperature <= get_temp(4095);
					else
						temperature <= get_temp(control);
				end
		end

endmodule