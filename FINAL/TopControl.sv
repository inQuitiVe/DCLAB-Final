module TopControl (
    input       i_rst_n,
	input       i_clk,
    
	 // I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,

    input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,

    output      [4:0] o_state,
    output      [7:0] o_avg_vol,
	 output       o_jump,
    output       [15:0] o_jump_height, // sync wuth jump
    output       o_run,
    output       [15:0] o_run_speed,
	 output 		 i2c_finish
    );
	parameter S_IDLE       = 3'd0;
    parameter S_I2C        = 3'd1;
    parameter S_I2C_FIN    = 3'd2;
    parameter S_RECD       = 3'd3;


    logic [2:0]  state_r   , state_w ;
    logic [7:0]  avg_volumn_r , avg_volumn_w , avg_volumn;
    logic signed [15:0] rec_data;
    logic d_valid , av_valid;
    logic i2c_oen, i2c_sdat, i2c_finished;
    logic i2c_start_w		, i2c_start_r;
    logic recorder_start_w	, recorder_start_r;
    logic recorder_stop_w	, recorder_stop_r;
    assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;
    assign o_state = state_r;
    assign o_avg_vol = avg_volumn_r;
	 assign o_run = (avg_volumn_r >= 8'd30) ? 1'b1 : 1'b0;
	 assign o_run_speed = (avg_volumn_r >= 8'd60) ? 16'd4 :
								 (avg_volumn_r >= 8'd45) ? 16'd3 : 16'd2;
	assign i2c_finish = i2c_finished;

	//assign o_jump = 1'b0;
	//assign i_run  = 1'b0;
    I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(i2c_start_r),
	.o_finished(i2c_finished),
	.o_sclk(o_I2C_SCLK),             // 1'b
	.o_sdat(i2c_sdat),           
	.o_oen(i2c_oen)
    );
    AudRecorder u_AudRecorder(
    .i_rst_n ( i_rst_n ),
    .i_clk   ( i_AUD_BCLK   ),
    .i_lrc   ( i_AUD_ADCLRCK ),
    .i_start ( recorder_start_r ),
    .i_stop  ( recorder_stop_r  ),
    .i_data  ( i_AUD_ADCDAT ),
    .o_data  ( rec_data  ),
    .o_valid  ( d_valid  )
    );
    average2048 u_average2048(
    .i_clk    ( i_AUD_BCLK    ),
    .i_rst_n  ( i_rst_n  ),
    .in_valid ( d_valid ),
    .in_data  ( rec_data  ),
    .o_valid  ( av_valid  ),
    .avg_volumn  ( avg_volumn  )
    );
    always_comb begin
        state_w          = state_r;
        i2c_start_w      = i2c_start_r;    
        recorder_start_w = recorder_start_r;
        recorder_stop_w  = recorder_stop_r;
        avg_volumn_w        = avg_volumn_r;
        case (state_r)
            S_IDLE: begin
                i2c_start_w = 1'b1;
                state_w = S_I2C;
            end
            S_I2C: begin
                if (i2c_finished == 1'b1) begin
                    state_w = S_I2C_FIN;
                    i2c_start_w = 1'b0;
                end
            end
            S_I2C_FIN: begin
                state_w = S_RECD;
                recorder_start_w = 1'b1;
                recorder_stop_w = 1'b0;
            end
            S_RECD: begin
                if (av_valid) avg_volumn_w = avg_volumn ;
            end
        endcase
    end
	always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_IDLE;
		i2c_start_r <= 1'b0;	//must be 0
		recorder_start_r <= 1'b0;
		recorder_stop_r <= 1'b0;
        avg_volumn_r    <= 8'd0;
	end
	else begin
		state_r <= state_w;
		i2c_start_r <= i2c_start_w;
		recorder_start_r <= recorder_start_w;
		recorder_stop_r <= recorder_stop_w;
        avg_volumn_r    <= avg_volumn_w;
	end
end
endmodule
