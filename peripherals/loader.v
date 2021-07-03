`timescale 1ns/1ps

module loader(input       clk_i,
              input       reset_i,
              input       uart_rx_irq,
              input [7:0] uart_rx_byte,

              output reg reset_o,
			  output reg [31:0] reset_cause_reg,
              output led1, led2, led3, led4);

parameter S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4;
parameter SYS_CLK_FREQ = 100000000;

reg [2:0] state, next_state;
reg [31:0] counter;
assign led1 = state == S0;
assign led2 = state == S1;
assign led3 = state == S2;
assign led4 = state == S3;

always @(posedge clk_i or negedge reset_i)
begin
	if(!reset_i)
		state <= S0;
	else
		state <= next_state;
end

always @(*)
begin
	case(state)
		S0: reset_o = 1'b1;
		S1: reset_o = 1'b1;
		S2: reset_o = 1'b0;
		S3: reset_o = 1'b1;
		S4:
		begin
			if(counter == 2*SYS_CLK_FREQ)
				reset_o = 1'b0;
			else
				reset_o = 1'b1;
		end
		default: reset_o = 1'b1;
	endcase
end

always @(*)
begin
	case(state)
		S0:
		begin
			if(uart_rx_irq && uart_rx_byte == 8'h2d) // 0x2d == '-'
				next_state = S1;
			else
				next_state = S0;
		end

		S1:
		begin
			if(uart_rx_irq && uart_rx_byte == 8'h70) // 0x70 == 'p'
				next_state = S2;
			else if (uart_rx_irq && uart_rx_byte == 8'h5f)
				next_state = S1;
			else if(uart_rx_irq)
				next_state = S0;
			else
				next_state = S1;
		end

		S2: next_state = S3;

		S3:
		begin
			if(uart_rx_irq)
				next_state = S4;
			else
				next_state = S3;
		end

		S4:
		begin
			if(counter == 2*SYS_CLK_FREQ)
				next_state = S0;
			else
				next_state = S4;
		end

		default: next_state = S0;
	endcase
end

always @(posedge clk_i or negedge reset_i)
begin
	if(!reset_i)
		reset_cause_reg <= 32'b0;
	else
	begin
		if(next_state == S2)
			reset_cause_reg <= 32'b1;
		else if(next_state == S0)
			reset_cause_reg <= 32'b0;
	end
end

always @(posedge clk_i or negedge reset_i)
begin
	if(!reset_i)
		counter <= 32'b0;
	else
	begin
		if(state == S4)
		begin
			if(uart_rx_irq)
                counter <= 32'b0;
            else
                counter <= counter + 32'b1;
		end
		else
			counter <= 32'b0;
	end
end

endmodule
