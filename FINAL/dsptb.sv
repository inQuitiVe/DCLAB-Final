`timescale  1ns / 1ps
module tb_NewDSP;

// NewDSP Parameters
parameter PERIOD    = 10                       ;
parameter FFT_iter  = 10                       ;
parameter FFT       = 2**FFT_iter              ;
parameter HFFT      = FFT/2                        ;
parameter FFTTHRED  = 16'b1_000_000_000_000_000;

// NewDSP Inputs
logic   rst_n                                = 0 ;
logic   clk                                  = 0 ;
logic   i_start                              = 0 ;
logic  signed [15:0]  i_data[FFT-1:0]              ;

// NewDSP Outputs
logic  [FFT_iter-2:0]  o_data               ;
logic  o_analy_finish                       ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
    #(PERIOD) i_start = 1;
    #(PERIOD*3) i_start = 0;
end

initial 
    begin
        i_data[0:511] = '{512{16'b10}};
        i_data[512:1023] = '{512{16'b0}};

    end


NewDSP #(
    .FFT      ( FFT      ),
    .FFT_iter ( FFT_iter ),
    .HFFT     ( HFFT     ),
    .FFTTHRED ( FFTTHRED ))
 u_NewDSP (
    .i_rst_n                 ( rst_n                           ),
    .i_clk                   ( clk                             ),
    .i_start                 ( i_start                         ),
    .i_data                  ( i_data                          ),

    .o_data                  ( o_data                          ),
    .o_analy_finish          ( o_analy_finish                  )
);

initial
begin
	$fsdbDumpfile("max_mode.fsdb");
	$fsdbDumpvars;
    $fsdbDumpMDA;
    #(PERIOD*100)
    $finish;
end

endmodule