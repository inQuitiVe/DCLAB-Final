module NewDSP #(
	parameter FFT = 8,
	parameter FFT_iter = 3,
	parameter HFFT = 4,
	parameter FFTTHRED = 16'b1_000_000_000_000_000
	)(
	input			i_rst_n,
	input			i_clk,
	input			i_start,
	// Input from SRAM
	input signed [15:0]	i_data[FFT-1:0],
	output [FFT_iter-2:0]	o_data,
	output          o_analy_finish
);


// ===== States =====
localparam S_IDLE 	= 0;
localparam S_ANALYS  = 1;
localparam S_FINDMAX = 2;

// ===== Registers & Wires =====
logic  [1:0]		state_w, state_r;
logic signed [15:0]      FFT_data[HFFT-1:0];
logic signed [15:0]  TimeCoord_w[FFT-1:0] ,TimeCoord_r[FFT-1:0];
logic signed [15:0]  FreqCoord[FFT-1:0],IM[FFT-1:0];
logic analysis_start_w, analysis_start_r;
logic analysis_finish,analysis_finish2;
logic analysis_finish_w, analysis_finish_r;
logic findmax_start_w, findmax_start_r,findmax_finish;
logic [FFT_iter:0] Fmax ;
logic [30:0] norm [HFFT-1:0];

fft1024  #(
	.FFT(FFT),
	.LGFFT(FFT_iter),
	.HFFT(HFFT)
	)u_fft1024 (
    .clk                     ( i_clk     ),
    .rst                     ( i_rst_n   ),
    .en                      ( analysis_start_r),
    .TimeCoord        		  ( TimeCoord_r ),

    .valid                   ( analysis_finish ),
    .FreqCoord               ( FreqCoord ),
	.IM                      ( IM )
);



max1024 #(
	.FFT(FFT/2),
	.LGFFT(FFT_iter-1),
	.HFFT(HFFT/2)
)u_max1024(
	.clk                     ( i_clk     ),
    .rstn                    ( i_rst_n   ),
    .en                      ( findmax_start_r),
    .TimeCoord          	 ( FFT_data  ),

    .valid                   ( findmax_finish ),
    .argmax                  ( o_data )
);

// // ===== Output Assignments =====
//assign o_analy_finish = o_analy_finish_r;
genvar ftrIDX;
generate 
	for(ftrIDX=0; ftrIDX<HFFT; ftrIDX=ftrIDX+1)begin: ftr
		assign norm  [ftrIDX]  =  FreqCoord[ftrIDX+1][14:0]*FreqCoord[ftrIDX+1][14:0] + IM[ftrIDX+1][14:0]*IM[ftrIDX+1][14:0];
		assign FFT_data[ftrIDX]  =  norm  [ftrIDX] > FFTTHRED ? norm[ftrIDX][30:15] : 'b0;
	end
endgenerate

assign o_analy_finish   =  findmax_finish;


// ===== Combinational Circuits =====
always_comb begin

	// Default Values
	state_w 	= state_r;
	analysis_start_w = analysis_start_r;
	analysis_finish_w = analysis_finish_r;
	TimeCoord_w = TimeCoord_r;
	findmax_start_w = findmax_start_r ;
	
	// FSM
	case(state_r)
		S_IDLE: begin
			if (i_start) begin
				state_w 	= S_ANALYS;
				TimeCoord_w = i_data;
				analysis_start_w = 1'b1;
				analysis_finish_w = 1'b0;
			end
		end


		S_ANALYS:begin
//			analysis_finish_w = analysis_finish;
			analysis_start_w = 1'b0;
			if (analysis_finish == 1'b1 ) begin
				analysis_finish_w = 1'b1;
				findmax_start_w = 1'b1;
				state_w =S_FINDMAX;
			end
		end

		S_FINDMAX:begin
			findmax_start_w = 1'b0;
			if (findmax_finish == 1'b1 ) begin
				state_w = S_IDLE;
			end
		end
	endcase
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		state_r 	<= S_IDLE;
		TimeCoord_r 	  <= '{FFT{'b0}};
		analysis_start_r <= 1'b0;
		analysis_finish_r <= 1'b0;
		findmax_start_r <= 1'b0;
//		o_analy_finish_r <= 1'b1;
	end
	else begin
		state_r 	<= state_w;
		TimeCoord_r 	<= TimeCoord_w;
		analysis_start_r <= analysis_start_w;
		analysis_finish_r <= analysis_finish_w;
		findmax_start_r <= findmax_start_w;
//		o_analy_finish_r <= o_analy_finish_w;
	end
end

endmodule
