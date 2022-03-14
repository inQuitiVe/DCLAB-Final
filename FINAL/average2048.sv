module average2048#(
      parameter                 NUM  = 2048
      ) (
       input                    i_clk,
       input                    i_rst_n,
       input                    in_valid,
       input  signed [15:0]     in_data,
       output                   o_valid,
       output [7:0]             avg_volumn 
       );


// ===== States =====
localparam S_IDLE = 3'd0;
localparam S_CAL 	= 3'd1;
localparam S_OUT 	= 3'd2;

logic [2:0]  state_r , state_w;
logic        valid_r , valid_w;
logic [15:0] abs_data;
logic [7:0]  volumn;
logic [19:0] volumn_acc_r , volumn_acc_w;
logic [11:0] counter_r    , counter_w;
assign abs_data = (in_data[15]) ?  (~in_data + 1) : in_data;
assign volumn = (abs_data[14]) ? 100 :
                (abs_data[13]) ? 90  :
                (abs_data[12]) ? 80  :
                (abs_data[11]) ? 70  :
                (abs_data[10]) ? 60  :
                (abs_data[9])  ? 50  :
                (abs_data[8])  ? 40  :
                (abs_data[7])  ? 30  :
                (abs_data[6])  ? 20  :
                (abs_data[5])  ? 10  : 0;
assign avg_volumn = volumn_acc_r[18:11];
assign o_valid    = valid_r;
// ===== Combinational Circuits =====
always_comb begin
	// Default Values
        state_w = state_r;
        counter_w = counter_r;
        volumn_acc_w = volumn_acc_r;
        valid_w      = valid_r;
	// FSM
	case(state_r)
		S_IDLE: begin
            if (in_valid) begin
                state_w 	 = S_CAL;
                counter_w 	 = 12'd0;
                volumn_acc_w =  volumn;
            end
        end
        S_CAL: begin
            if (in_valid) begin
                state_w 	= S_CAL;
                counter_w 	= counter_r + 1;
                volumn_acc_w=  volumn_acc_r + volumn;            
            end
			if (counter_r == 12'd2047) begin
                state_w 	= S_OUT;
                valid_w     = 1'b1;
            end
        end
        S_OUT: begin
            state_w  = S_IDLE;
            valid_w  = 1'b0;
        end
	endcase
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
        state_r      = state_w;
        counter_r    = 12'd0;
        volumn_acc_r = 20'd0;
        valid_r      = 1'b0;
	end
	else begin
        state_r      = state_w;
        counter_r    = counter_w;
        volumn_acc_r = volumn_acc_w;
        valid_r      = valid_w;
	end
end

endmodule