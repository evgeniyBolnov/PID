module pid_control #(
  parameter SENSOR_ADDR = 16'h0000,
  parameter PWM_ADDR    = 16'h0000,
  parameter INIT_REFER  = 0       ,
  parameter PWM_WIDTH   = 16      ,
  parameter TEMP_WIDTH  = 16
) (
  input                         clk               ,
  input                         reset             ,
  //Avalon-MM i2c tem read
  output logic [TEMP_WIDTH-1:0] temp_address      ,
  output logic                  temp_read         ,
  input        [          31:0] temp_readdata     ,
  input                         temp_readdatavalid,
  input                         temp_waitrequest  ,
  //Avalon-MM PWM out
  output logic [ PWM_WIDTH-1:0] pwm_address       ,
  output logic                  pwm_write         ,
  output logic [          31:0] pwm_writedata     ,
  input                         pwm_waitrequest   ,
  //Avalon-MM CSR
  input        [           1:0] csr_address       ,
  input                         csr_write         ,
  input        [          31:0] csr_writedata     ,
  input                         csr_read          ,
  output logic [          31:0] csr_readdata
);

  enum logic [3:0] {
    TEMP_IDLE,
    TEMP_RESET,
    TEMP_READ,
    TEMP_CALC,
    TEMP_READ_PID,
    TEMP_WRITE_PID,
    TEMP_FINISH
  } temp_state;

  logic signed [ 7:0] readed_temp;
  logic               enable_pid ;
  logic signed [15:0] pid_wire   ;
  logic signed [15:0] pid_data   ;
  logic signed [ 7:0] refer      ;

  always_ff @(posedge clk or posedge reset)
    begin
      if (reset)
        begin
          refer <= INIT_REFER;
        end
      else
        begin
          if (csr_write)
            case (csr_address)
              2'h0 : refer <= csr_writedata;
            endcase
          if (csr_read)
            case (csr_address)
              2'h0 : csr_readdata <= {{24{refer[7]}}, refer};
            endcase
        end
    end

  always_ff @(posedge clk or posedge reset)
    begin
      if (reset)
        begin
          temp_state    <= TEMP_RESET;
          readed_temp   <= '0;
          temp_read     <= '0;
          temp_address  <= '0;
          enable_pid    <= '0;
          pid_data      <= '0;
          pwm_address   <= '0;
          pwm_write     <= '0;
          pwm_writedata <= '0;
        end
      else
        begin
          pid_data <= pid_wire;
          case (temp_state)
            TEMP_IDLE :
              begin
                temp_address <= SENSOR_ADDR;
                temp_read    <= 1'b1;
                enable_pid   <= '0;
                if (~temp_waitrequest)
                  temp_state <= TEMP_READ;
              end
            TEMP_READ :
              begin
                temp_read    <= 1'b0;
                temp_address <= '0;
                if (temp_readdatavalid)
                  begin
                    readed_temp <= temp_readdata;
                    temp_state  <= TEMP_CALC;
                  end
              end
            TEMP_CALC :
              begin
                enable_pid <= 1'b1;
                temp_state <= TEMP_READ_PID;
              end
            TEMP_READ_PID :
              begin
                enable_pid <= '0;
                temp_state <= TEMP_WRITE_PID;
              end
            TEMP_WRITE_PID :
              begin
                pwm_address   <= PWM_ADDR;
                pwm_write     <= 1'b1;
                pwm_writedata <= (pid_data < 0) ? 0 : (pid_data > 4095) ? 4095 : pid_data;
                temp_state    <= TEMP_FINISH;
              end
            TEMP_FINISH :
              begin
                if (!pwm_waitrequest)
                  begin
                    pwm_address   <= '0;
                    pwm_writedata <= '0;
                    pwm_write     <= '0;
                    temp_state    <= TEMP_IDLE;
                  end
              end
            default : temp_state <= TEMP_IDLE;
          endcase
        end
    end

  pid #(
    .k_p(0.9),
    .k_i(0.5),
    .k_d(0.5)
  ) pid_inst (
    .clk    (clk        ),
    .reset  (reset      ),
    .refer  (refer      ),
    .data   (readed_temp),
    .enable (enable_pid ),
    .control(pid_wire   )
  );


endmodule