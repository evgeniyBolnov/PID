module pid #(
	parameter real k_p = 0.9,
	parameter real k_i = 0.9,
	parameter real k_d = 0.9
) (
	input                      clk    ,
	input                      reset  ,
	input  logic signed [ 7:0] refer  ,
	input  logic signed [ 7:0] data   ,
	input                      enable ,
	output logic signed [15:0] control
);

	localparam integer b0 = integer'(k_p * 1024);
	localparam integer b1 = integer'(k_i * 1024);
	localparam integer b2 = integer'(k_d * 1024);

	logic signed [15:0] error     ;
	logic signed [15:0] prev_error;
	logic signed [15:0] prev_int  ;

	logic signed [15:0] P, I, D;

	assign P = error                ;
	assign I = (error + prev_int)   ;
	assign D = (error - prev_error) ;
	assign control = (P * b0 + I * b1 + D * b2) >>> 10;

	always_ff @(posedge clk or posedge reset)
		begin
			if (reset)
				begin
					error      <= '0;
					prev_error <= '0;
					prev_int   <= '0;
				end
			else
				begin
					if (enable)
						begin
							error      <= refer - data;
							prev_error <= error;
							prev_int   <= (I < 0 ) ? 0 : I;							
						end
				end
		end

endmodule
