`timescale  1ns / 1ps

module tb_threshold;

// threshold Parameters
parameter PERIOD       = 10    ;
parameter FFT          = 1024  ;
parameter HFFT         = FFT/2 ;
parameter LGFFT        = 10    ;
parameter ACCUTHRESH   = HFFT/2;
parameter COUNTTHRESH  = 100   ;

// threshold Inputs
reg   clk                                  = 0 ;
reg   rst                                  = 0 ;
reg   [LGFFT-2:0]  i_data                  = 0 ;

// threshold Outputs
wire  jump                                 ;
wire  [4:0]  height                        ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst  =  1;
end

threshold #(
    .FFT         ( FFT         ),
    .HFFT        ( HFFT        ),
    .LGFFT       ( LGFFT       ),
    .ACCUTHRESH  ( ACCUTHRESH  ),
    .COUNTTHRESH ( COUNTTHRESH ))
 u_threshold (
    .clk                     ( clk                 ),
    .rst                     ( rst                 ),
    .i_data                  ( i_data              ),

    .jump                    ( jump                ),
    .height                  ( height              )
);

initial
begin
    $fsdbDumpfile("max_mode.fsdb");
	$fsdbDumpvars;
    $fsdbDumpMDA;
    #(PERIOD*1000)
    $finish;
end
integer i;
initial 
begin
    for(i = 0; i<1000;i=i+1)begin
        @(posedge clk)
        i_data = i;
    end
end

endmodule