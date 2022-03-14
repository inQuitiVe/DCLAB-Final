module threshold#(
      parameter                       FFT  = 1024,
      parameter                       HFFT = FFT/2,
      parameter                       LGFFT = 10,
      parameter                       ACCUTHRESH = HFFT/2,
      parameter                       COUNTTHRESH = 200
      ) (
    input                            clk,
    input                            rst,
    input [LGFFT-2:0]             i_data,
    output                          jump,
    output[4:0]                   height 
);


logic [32:0] counter_r,counter_w;
localparam S_IDLE = 0;
localparam S_ACCUM = 1;

logic state_r,state_w;
logic [LGFFT-2:0] height_r,height_w;
logic jump_r,jump_w;

assign height = height_r[LGFFT-3] ? 30 :
                height_r[LGFFT-4] ? 27 :
                height_r[LGFFT-5] ? 24 :
                height_r[LGFFT-6] ? 21 :
                height_r[LGFFT-7] ? 18 :
                height_r[LGFFT-8] ? 15 :
                1;
assign jump = jump_r;

always_comb begin
    state_w = state_r;
    jump_w = jump_r;
    height_w = height_r;
	 counter_w = counter_r;
    case (state_r) 
        S_IDLE : begin
            jump_w = 0;
            if (i_data >= ACCUTHRESH)begin
                counter_w = 0;
                state_w = S_ACCUM;
                height_w = i_data;
            end
        end
        S_ACCUM : begin
            if (counter_r == COUNTTHRESH)begin
                state_w = S_IDLE;
                jump_w  = 1'b1;
            end
            if (i_data >= ACCUTHRESH)begin
                counter_w = counter_r + 1;
                if(height_r < i_data) height_w = i_data;
            end
            else begin
                state_w = S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge clk or negedge rst) begin
    if(!rst)begin
        state_r       <=   'b0;
        jump_r        <=   'b0;
        height_r      <=   'b0;
		  counter_r     <=   'b0;
    end
    else  begin
        state_r       <=   state_w;
        jump_r        <=   jump_w;
        height_r      <=   height_w;
		  counter_r     <=   counter_w;
    end
end

endmodule