module fft1024#(
      parameter                       FFT  = 1024,
      parameter                       HFFT = FFT/2,
      parameter                       LGFFT = 10,        // lg(FFT)
      parameter                       PREC  = 36
      ) (
       input                    clk,
       input                    rst,
       input                    en,

       input  signed [15:0]      TimeCoord [FFT-1:0],  
       output                    valid,
       output signed [15:0]      FreqCoord [FFT-1:0],
       output signed [15:0]      IM  [FFT-1:0]
       );



   //operating data
   wire signed [15:0]             xm_real [LGFFT:0] [FFT-1:0];      // LGFFT+1  *  FFT
   wire signed [15:0]             xm_imag [LGFFT:0] [FFT-1:0];
   wire                           en_connect [LGFFT:0] [HFFT-1:0];     // 11* 512       
   

   //factor, multiplied by 0x2000
   reg signed [15:0]             factor_real [0:HFFT-1];     //  relate to readmem  (e^(-2npi/FFT))
   reg signed [15:0]             factor_imag [0:HFFT-1];
   reg        [LGFFT-1:0]        reverse_index[0:FFT-1];

   //
   initial begin
      $readmemh("./FFT_1024_cos.mem",factor_real);  //  24kb
      $readmemh("./FFT_1024_sin.mem",factor_imag);  //  24kb
      $readmemb("./index.mem",reverse_index);       //  10kb
   end

   genvar i;
   generate
   for (i = 0;i < FFT;i = i + 1)begin: RVerse
        assign xm_real[0][i] = TimeCoord[reverse_index[i]];
   end
   endgenerate
   assign en_connect[0] = '{HFFT{en}};
   assign xm_imag[0] = '{FFT{'b0}};

   //butter instantiaiton
   //integer              index[11:0] ;
   genvar               m, k;
   generate
      for(m=0; m<LGFFT; m=m+1) begin: stage
         for (k=0; k<HFFT; k=k+1) begin: unit
            butterfly   #(
               .PREC (PREC)
            ) u_butter(
               .clk         (clk                                      ) ,
               .rstn        (rst                                      ) ,
               .en          (en_connect[m][k]                   ),

               .xp_real     (xm_real[ m ] [k[m:0] < (1<<m) ?
                                          (k[2*LGFFT-1:m] << (m+1)) + k[m:0] :
                                          (k[LGFFT+1:m] << (m+1)) + (k[m:0]-(1<<m))] ),
               .xp_imag     (xm_imag[ m ] [k[m:0] < (1<<m) ?
                                          (k[2*LGFFT-1:m] << (m+1)) + k[m:0] :
                                          (k[2*LGFFT-1:m] << (m+1)) + (k[m:0]-(1<<m))] ),
               .xq_real     (xm_real[ m ] [k[m:0] < (1<<m) ?
                                          (k[2*LGFFT-1:m] << (m+1)) + k[m:0] + (1<<m):
                                          (k[2*LGFFT-1:m] << (m+1)) + k[m:0] ]),
               .xq_imag     (xm_imag[ m ] [k[m:0] < (1<<m) ?
                                          (k[2*LGFFT-1:m] << (m+1)) + k[m:0]+ (1<<m):
                                          (k[2*LGFFT-1:m] << (m+1)) + k[m:0] ]),

               .factor_real (factor_real[k[m:0]<(1<<m)? k[m:0] : k[m:0]-(1<<m) ]),
					.factor_imag (factor_imag[k[m:0]<(1<<m)? k[m:0] : k[m:0]-(1<<m) ]),

               //output data
               .valid       (en_connect[m+1][k]                ),
               .yp_real     (xm_real[ m+1 ][k[m:0] < (1<<m) ?
                                            (k[2*LGFFT-1:m] << (m+1)) + k[m:0] :
                                            (k[2*LGFFT-1:m] << (m+1)) + (k[m:0]-(1<<m))] ),
               .yp_imag     (xm_imag[ m+1 ][(k[m:0]) < (1<<m) ?
                                            (k[2*LGFFT-1:m] << (m+1)) + k[m:0] :
                                            (k[2*LGFFT-1:m] << (m+1)) + (k[m:0]-(1<<m))] ),
               .yq_real     (xm_real[ m+1 ][(k[m:0] < (1<<m) ?
                                            (k[2*LGFFT-1:m] << (m+1)) + k[m:0] + (1<<m):
                                            (k[2*LGFFT-1:m] << (m+1)) + k[m:0] )]),
               .yq_imag     (xm_imag[ m+1 ][((k[m:0]) < (1<<m) ?
                                            (k[2*LGFFT-1:m] << (m+1)) + k[m:0] + (1<<m):
                                            (k[2*LGFFT-1:m] << (m+1)) + k[m:0] )])
             );
         end
      end
   endgenerate

   assign     valid = en_connect[LGFFT][0];
   assign     FreqCoord = xm_real[LGFFT] ;
   assign     IM = xm_imag[LGFFT] ;


endmodule
