module I2cInitializer (
    input i_rst_n,
    input i_clk,
    input i_start,
    output o_finished,
    output o_sclk,
    output o_sdat,
    output o_oen
	 //output o_show // you are outputing (you are not outputing only when you are "ack"ing.)
);
// ===== States =====
parameter S_IDLE       = 3'b000;
parameter S_PREP       = 3'b001;
parameter S_START      = 3'b010;
parameter S_BLUE       = 3'b011;
parameter S_GREEN      = 3'b100;
parameter S_BACK_START = 3'b101;
parameter S_FINISH     = 3'b110;
parameter S_STOP       = 3'b111;
//======= InitialData =======
localparam logic [23:0] InitialData[0:10] = 

'{
	 24'b00110100_000_1111_0_0000_0000, //Reset
	 24'b00110100_000_0000_0_1001_0111, //left line in
	 24'b00110100_000_0001_0_1001_0111, //right line in
	 24'b00110100_000_0010_0_0111_1001, //left headphone out
	 24'b00110100_000_0011_0_0111_1001, //right headphone out
    24'b00110100_000_0100_0_0001_0101, //Analogue Audio Path Control
    24'b00110100_000_0101_0_0000_0000, //Digital Audio Path Control
    24'b00110100_000_0110_0_0000_0000, //Power Down Control 
    24'b00110100_000_0111_0_0100_0010, //Digital Audio Interface Format
    24'b00110100_000_1000_0_0001_1001, //Sampling Control
    24'b00110100_000_1001_0_0000_0001  //Active Control

} ;


// ===== Output Buffers =====
logic   finished_r, finished_w;
logic   sclk_r    , sclk_w;
logic   sdat_r    , sdat_w;
logic   oen_r     , oen_w;


// ===== Output Assignments =====
assign o_finished  = finished_r;
assign o_sclk      = sclk_r;
assign o_sdat      = sdat_r;
assign o_oen       = oen_r;
// ===== Registers & Wires =====
logic [2:0] state_r , state_w;
logic [4:0] BitCounter_r  , BitCounter_w;
logic [3:0] DataCounter_r , DataCounter_w;
logic [4:0] bit_address;



assign bit_address = (BitCounter_r  > 23) ? 0 : (23 - BitCounter_r);
//assign o_show = state_r;
always_comb begin
    sclk_w = sclk_r;
    sdat_w = sdat_r;
    oen_w  = oen_r;
    finished_w = finished_r;
    state_w = state_r;
    BitCounter_w  = BitCounter_r;
    DataCounter_w = DataCounter_r;
    case(state_r)
        S_IDLE:begin
				DataCounter_w = 3'b0;
				BitCounter_w  = 5'b0;
				sclk_w 		  = 1'b1;
				sdat_w 		  = 1'b1;
				finished_w 	  = 1'b0;
				oen_w  		  = 1'b1;
            if(i_start)begin
                state_w = S_PREP;
            end
        end
        S_PREP:begin
            sdat_w  = 1'b0;
            state_w = S_START;
        end
        S_START:begin
            state_w = S_BLUE;
            sclk_w  = 1'b0;
            sdat_w  = InitialData[DataCounter_r][bit_address];
			BitCounter_w = BitCounter_r + 1;
        end
        S_BLUE:begin //readvalue
            state_w = S_GREEN;
            sclk_w  = 1'b1;
            if((BitCounter_r == 25)) begin
                state_w = S_STOP;
            end
        end
        S_GREEN:begin //givevalue
            state_w = S_BLUE;
            sclk_w  = 1'b0;
            sdat_w  = InitialData[DataCounter_r][bit_address];
            if ((BitCounter_r == 8) || (BitCounter_r == 16) || (BitCounter_r == 24)) begin
                if (oen_r == 1) begin //ack
                    oen_w = 1'b0;
                    sdat_w = 1'b1;
                end
                else begin
                    oen_w = 1'b1;
                    BitCounter_w = BitCounter_r + 1;
                end
            end
            else begin
                BitCounter_w = BitCounter_r + 1;
                oen_w   = 1'b1;
            end
        end
        S_STOP:begin
            state_w = S_BACK_START;
            sdat_w  = 1'b1;
            BitCounter_w = 5'd0;
        end
        S_BACK_START:begin
            sclk_w  = 1'b1;
            sdat_w  = 1'b1;
            state_w = S_PREP;
            DataCounter_w = DataCounter_r + 1;
            if (DataCounter_r == 10)
                state_w = S_FINISH;
        end
        S_FINISH:begin
            finished_w = 1'b1;
            //state_w    = S_IDLE;
        end
    endcase
end



always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_IDLE;
		sclk_r <= 1'b1;
		sdat_r <= 1'b1;
		finished_r <= 1'b0;
		oen_r <= 1'b1;
		DataCounter_r <= 3'b0;
		BitCounter_r <= 5'b0;
	end
	else begin
		state_r     <= state_w;		
		sclk_r      <= sclk_w;
		sdat_r      <= sdat_w;
		finished_r  <= finished_w;
		oen_r       <= oen_w;
		DataCounter_r <= DataCounter_w;
		BitCounter_r  <= BitCounter_w;
	end
end

endmodule
