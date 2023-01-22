module AMM_Master #(
  parameter ADDR_WIDTH = 16
) (
  input                         clk            ,
  input                         reset          ,
  output logic [ADDR_WIDTH-1:0] amm_address    ,
  output logic                  amm_write      ,
  output logic [          31:0] amm_writedata  ,
  output logic                  amm_read       ,
  input        [          31:0] amm_readdata   ,
  input                         amm_waitrequest
);

  typedef struct packed{
    logic [ADDR_WIDTH-1:0] addr;
    logic [          31:0] data;
  } data_st;

  enum logic [2:0]{
    IDLE,
    SET,
    READ
  } read_state;

  data_st                rx_q[$];
  logic [ADDR_WIDTH-1:0] tx_q[$];

  data_st readed_data[$];

  event read_complete;

  always_ff @(posedge clk or posedge reset)
    begin
      if (reset)
        begin
          amm_write     <= '0;
          amm_writedata <= '0;
          amm_address   <= '0;
          amm_read      <= '0;
          rx_q.delete();
          tx_q.delete();
          readed_data.delete();
          read_state    <= IDLE;
        end
      else
        begin
          if (rx_q.size() > 0 && read_state == IDLE)
            begin
              if (amm_write)
                begin
                  if (!amm_waitrequest)
                    begin
                      amm_write     <= '0;
                      amm_writedata <= '0;
                      amm_address   <= '0;
                      $display("Write command sended [%x(%d)]=%x(%d)", rx_q[0].addr, signed'(rx_q[0].addr), rx_q[0].data, signed'(rx_q[0].data));
                      rx_q.pop_front();
                    end
                end
              else
                begin
                  amm_write     <= 1'b1;
                  amm_writedata <= rx_q[0].data;
                  amm_address   <= rx_q[0].addr;
                end
            end
          else
            begin
              case(read_state)
                IDLE :
                  if (tx_q.size() > 0)
                    begin
                      amm_read    <= 1'b1;
                      amm_address <= tx_q[0];
                      read_state  <= SET;
                    end
                SET :
                  begin
                    if (~amm_waitrequest)
                      begin
                        read_state  <= READ;
                        amm_read    <= '0;
                        amm_address <= '0;
                      end
                  end
                READ :
                  begin
                    $display("Readed data [%x]=%x(%d)", tx_q[0], amm_readdata, amm_readdata);
                    readed_data.push_back({tx_q[0], amm_readdata});
                    tx_q.pop_front();
                    -> read_complete;
                    read_state <= IDLE;
                  end
              endcase
            end
        end
    end

    task automatic add_send(int addr, int data);
      begin
        rx_q.push_back({addr[ADDR_WIDTH-1:0], data});
      end
    endtask

    task automatic add_read(int addr);
      begin
        tx_q.push_back(addr[ADDR_WIDTH-1:0]);
      end
    endtask

    function logic [31:0] get_read_value();
      begin
        return readed_data.pop_front();
      end
    endfunction

endmodule