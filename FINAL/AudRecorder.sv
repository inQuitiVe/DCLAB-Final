module AudRecorder (
	input 			i_rst_n, 
	input 			i_clk,
    // Input from WM8731 (AUD_ADCLRCK)
	input 			i_lrc,
    // Inputs from user
	input 			i_start,
	input 			i_stop,
    // Input from WM8731 (AUD_ADCDAT)
	input 			i_data,
    // Outputs to SRAM
	output [15:0]	o_data,
	output 			o_valid
);

// ===== States =====
localparam S_IDLE 	= 3'd1;
localparam S_WRITE 	= 3'd2;
localparam S_PAUSE 	= 3'd3;

// ===== Registers & Wires =====
logic [15:0] 	data_r, data_w;
logic [2:0] 	state_r, state_w;
logic [4:0] 	counter_r, counter_w;
logic 			start_w, start_r, stop_w, stop_r, lrc_r, lrc_w;
logic           valid_r , valid_w;
// ===== Output Assignments =====
assign o_data 		= data_r;
assign o_valid      = valid_r;

// ===== Combinational Circuits =====
always_comb begin
	// Default Values
    data_w 		= data_r;
    state_w 	= state_r;
    counter_w 	= counter_r;
	// input control
    lrc_w 		= i_lrc;
	start_w 	= i_start;
	stop_w 		= i_stop;
	valid_w   = valid_r;
	
	// FSM
	case(state_r)
		S_IDLE: begin
            if (i_start) begin
                state_w 	= S_WRITE;
                counter_w 	= 5'b0;
				valid_w     = 1'b0;
            end
        end
        S_WRITE: begin
			if (i_stop) begin
                state_w 	= S_IDLE;
				valid_w     = 1'b0;
            end
			else begin
				state_w 	= S_WRITE;
				// if lrc changes, wait for one cycle and start to write
				if (counter_r >= 5'd1 && counter_r <= 5'd16) begin
					valid_w     = 1'b0;
					data_w 		= {data_r[14:0], i_data};
					counter_w 	= counter_r + 5'b1;
				end
				// if 16 bits are written to SRAM, wait for next posedge
				else if (counter_r == 5'd17) begin
					counter_w 	= 5'd20;
					valid_w     = 1'b1;
				end
				else if (counter_r == 5'd20) begin
					counter_w 	= 5'd0;
					valid_w     = 1'b0;
				end
				// if lrc posedge comes, prepare to write
				else if (lrc_r == 1'b0 && i_lrc == 1'b1) begin
					counter_w 	= 5'b1;
				end
			end	 
        end
	endcase
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
        data_r 		<= 16'b0;
        state_r 	<= S_IDLE;
        counter_r   <= 5'b0;
        lrc_r 		<= i_lrc;
        start_r 	<= 1'b0;
		stop_r 		<= 1'b0;
		valid_r     <= 1'b0;
	end
	else begin
        data_r 	<= data_w;
        state_r 	<= state_w;
        counter_r <= counter_w;
        lrc_r 		<= lrc_w;
        start_r 	<= start_w;
		stop_r 	<= stop_w;
		valid_r     <= valid_w;
	end
end

endmodule
