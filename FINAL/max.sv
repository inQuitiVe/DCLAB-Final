module max1024#(
      parameter                       FFT  = 1024,
      parameter                       HFFT = FFT/2,
      parameter                       LGFFT = 10
      ) (
       input                    clk,
       input                    rstn,
       input                    en,

       input signed [15:0]      TimeCoord [FFT-1:0], 
       output             valid,
       output [LGFFT-1:0] argmax   
       );

logic signed [15:0] buffer[LGFFT:0][FFT-1:0]; 
logic [LGFFT-1:0] arg [LGFFT:0][FFT-1:0];
logic [LGFFT:0]   en_r ;

assign buffer[0][FFT-1:0] = TimeCoord[FFT-1:0];
integer argIDX = 0;



always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        en_r   <= 'b0 ;
    end
    else begin
        en_r   <= {en_r[LGFFT-1:0], en} ;
    end
end

assign argmax = arg[LGFFT][0];
assign valid = en_r[LGFFT];




// 0
integer zero;
always_ff@(posedge clk) begin
    for (zero = 0; zero < 256; zero++)begin
        if (en) begin
        arg[0+1][zero]     <= (buffer[0][zero] > buffer[0][zero+HFFT/(2**0)]) ? arg[0][zero] : arg[0][zero+HFFT/(2**0)];
        buffer[0+1][zero]  <= (buffer[0][zero] > buffer[0][zero+HFFT/(2**0)]) ? buffer[0][zero] : buffer[0][zero+HFFT/(2**0)];
        end
    end
end

// 1
integer one;
always_ff@(posedge clk) begin
    for (one = 0; one < 128; one++)begin
        if (en_r[0] == 1) begin
        arg[1+1][one]     <= (buffer[1][one] > buffer[1][one+HFFT/(2**1)]) ? arg[1][one] : arg[1][one+HFFT/(2**1)];
        buffer[1+1][one]  <= (buffer[1][one] > buffer[1][one+HFFT/(2**1)]) ? buffer[1][one] : buffer[1][one+HFFT/(2**1)];
        end
    end     
end

// 2
integer two;
always_ff@(posedge clk) begin
    for (two = 0; two < 64; two++)begin
        if (en_r[2] == 1) begin
        arg[2+1][two]     <= (buffer[2][two] > buffer[2][two+HFFT/(2**2)]) ? arg[2][two] : arg[2][two+HFFT/(2**2)];
        buffer[2+1][two]  <= (buffer[2][two] > buffer[2][two+HFFT/(2**2)]) ? buffer[2][two] : buffer[2][two+HFFT/(2**2)];
        end
    end
end

// 3
integer three;
always_ff@(posedge clk) begin
    for (three = 0; three < 32; three++)begin
        if (en_r[3] == 1) begin
        arg[3+1][three]     <= (buffer[3][three] > buffer[3][three+HFFT/(2**3)]) ? arg[3][three] : arg[3][three+HFFT/(2**3)];
        buffer[3+1][three]  <= (buffer[3][three] > buffer[3][three+HFFT/(2**3)]) ? buffer[3][three] : buffer[3][three+HFFT/(2**3)];
        end
    end
end

// 4
integer four;
always_ff@(posedge clk) begin
    for (four = 0; four < 16; four++)begin
        if (en_r[4] == 1) begin
        arg[4+1][four]     <= (buffer[4][four] > buffer[4][four+HFFT/(2**4)]) ? arg[4][four] : arg[4][four+HFFT/(2**4)];
        buffer[4+1][four]  <= (buffer[4][four] > buffer[4][four+HFFT/(2**4)]) ? buffer[4][four] : buffer[4][four+HFFT/(2**4)];
        end
    end
end

// 5
integer five;
always_ff@(posedge clk) begin
    for (five = 0; five < 8; five++)begin
        if (en_r[5] == 1) begin
        arg[5+1][five]     <= (buffer[5][five] > buffer[5][five+HFFT/(2**5)]) ? arg[5][five] : arg[5][five+HFFT/(2**5)];
        buffer[5+1][five]  <= (buffer[5][five] > buffer[5][five+HFFT/(2**5)]) ? buffer[5][five] : buffer[5][five+HFFT/(2**5)];
        end
    end
end

// 6
integer six;
always_ff@(posedge clk) begin
    for (six = 0; six < 4; six++)begin
        if (en_r[6] == 1) begin
        arg[6+1][six]     <= (buffer[6][six] > buffer[6][six+HFFT/(2**6)]) ? arg[6][six] : arg[6][six+HFFT/(2**6)];
        buffer[6+1][six]  <= (buffer[6][six] > buffer[6][six+HFFT/(2**6)]) ? buffer[6][six] : buffer[6][six+HFFT/(2**6)];
        end
    end
end

// 7
integer seven;
always_ff@(posedge clk) begin
    for (seven = 0; seven < 2; seven++)begin
        if (en_r[7] == 1) begin
        arg[7+1][seven]     <= (buffer[7][seven] > buffer[7][seven+HFFT/(2**7)]) ? arg[7][seven] : arg[7][seven+HFFT/(2**7)];
        buffer[7+1][seven]  <= (buffer[7][seven] > buffer[7][seven+HFFT/(2**7)]) ? buffer[7][seven] : buffer[7][seven+HFFT/(2**7)];
        end
    end
end

// 8
integer eight;
always_ff@(posedge clk) begin
    for (eight = 0; eight < 1; eight++)begin
        if (en_r[8] == 1) begin
        arg[8+1][eight]     <= (buffer[8][eight] > buffer[8][eight+HFFT/(2**8)]) ? arg[8][eight] : arg[8][eight+HFFT/(2**8)];
        buffer[8+1][eight]  <= (buffer[8][eight] > buffer[8][eight+HFFT/(2**8)]) ? buffer[8][eight] : buffer[8][eight+HFFT/(2**8)];
        end
    end 
end



assign arg [0][0]= 0;
assign arg [0][1]= 1;
assign arg [0][2]= 2;
assign arg [0][3]= 3;
assign arg [0][4]= 4;
assign arg [0][5]= 5;
assign arg [0][6]= 6;
assign arg [0][7]= 7;
assign arg [0][8]= 8;
assign arg [0][9]= 9;
assign arg [0][10]= 10;
assign arg [0][11]= 11;
assign arg [0][12]= 12;
assign arg [0][13]= 13;
assign arg [0][14]= 14;
assign arg [0][15]= 15;
assign arg [0][16]= 16;
assign arg [0][17]= 17;
assign arg [0][18]= 18;
assign arg [0][19]= 19;
assign arg [0][20]= 20;
assign arg [0][21]= 21;
assign arg [0][22]= 22;
assign arg [0][23]= 23;
assign arg [0][24]= 24;
assign arg [0][25]= 25;
assign arg [0][26]= 26;
assign arg [0][27]= 27;
assign arg [0][28]= 28;
assign arg [0][29]= 29;
assign arg [0][30]= 30;
assign arg [0][31]= 31;
assign arg [0][32]= 32;
assign arg [0][33]= 33;
assign arg [0][34]= 34;
assign arg [0][35]= 35;
assign arg [0][36]= 36;
assign arg [0][37]= 37;
assign arg [0][38]= 38;
assign arg [0][39]= 39;
assign arg [0][40]= 40;
assign arg [0][41]= 41;
assign arg [0][42]= 42;
assign arg [0][43]= 43;
assign arg [0][44]= 44;
assign arg [0][45]= 45;
assign arg [0][46]= 46;
assign arg [0][47]= 47;
assign arg [0][48]= 48;
assign arg [0][49]= 49;
assign arg [0][50]= 50;
assign arg [0][51]= 51;
assign arg [0][52]= 52;
assign arg [0][53]= 53;
assign arg [0][54]= 54;
assign arg [0][55]= 55;
assign arg [0][56]= 56;
assign arg [0][57]= 57;
assign arg [0][58]= 58;
assign arg [0][59]= 59;
assign arg [0][60]= 60;
assign arg [0][61]= 61;
assign arg [0][62]= 62;
assign arg [0][63]= 63;
assign arg [0][64]= 64;
assign arg [0][65]= 65;
assign arg [0][66]= 66;
assign arg [0][67]= 67;
assign arg [0][68]= 68;
assign arg [0][69]= 69;
assign arg [0][70]= 70;
assign arg [0][71]= 71;
assign arg [0][72]= 72;
assign arg [0][73]= 73;
assign arg [0][74]= 74;
assign arg [0][75]= 75;
assign arg [0][76]= 76;
assign arg [0][77]= 77;
assign arg [0][78]= 78;
assign arg [0][79]= 79;
assign arg [0][80]= 80;
assign arg [0][81]= 81;
assign arg [0][82]= 82;
assign arg [0][83]= 83;
assign arg [0][84]= 84;
assign arg [0][85]= 85;
assign arg [0][86]= 86;
assign arg [0][87]= 87;
assign arg [0][88]= 88;
assign arg [0][89]= 89;
assign arg [0][90]= 90;
assign arg [0][91]= 91;
assign arg [0][92]= 92;
assign arg [0][93]= 93;
assign arg [0][94]= 94;
assign arg [0][95]= 95;
assign arg [0][96]= 96;
assign arg [0][97]= 97;
assign arg [0][98]= 98;
assign arg [0][99]= 99;
assign arg [0][100]= 100;
assign arg [0][101]= 101;
assign arg [0][102]= 102;
assign arg [0][103]= 103;
assign arg [0][104]= 104;
assign arg [0][105]= 105;
assign arg [0][106]= 106;
assign arg [0][107]= 107;
assign arg [0][108]= 108;
assign arg [0][109]= 109;
assign arg [0][110]= 110;
assign arg [0][111]= 111;
assign arg [0][112]= 112;
assign arg [0][113]= 113;
assign arg [0][114]= 114;
assign arg [0][115]= 115;
assign arg [0][116]= 116;
assign arg [0][117]= 117;
assign arg [0][118]= 118;
assign arg [0][119]= 119;
assign arg [0][120]= 120;
assign arg [0][121]= 121;
assign arg [0][122]= 122;
assign arg [0][123]= 123;
assign arg [0][124]= 124;
assign arg [0][125]= 125;
assign arg [0][126]= 126;
assign arg [0][127]= 127;
assign arg [0][128]= 128;
assign arg [0][129]= 129;
assign arg [0][130]= 130;
assign arg [0][131]= 131;
assign arg [0][132]= 132;
assign arg [0][133]= 133;
assign arg [0][134]= 134;
assign arg [0][135]= 135;
assign arg [0][136]= 136;
assign arg [0][137]= 137;
assign arg [0][138]= 138;
assign arg [0][139]= 139;
assign arg [0][140]= 140;
assign arg [0][141]= 141;
assign arg [0][142]= 142;
assign arg [0][143]= 143;
assign arg [0][144]= 144;
assign arg [0][145]= 145;
assign arg [0][146]= 146;
assign arg [0][147]= 147;
assign arg [0][148]= 148;
assign arg [0][149]= 149;
assign arg [0][150]= 150;
assign arg [0][151]= 151;
assign arg [0][152]= 152;
assign arg [0][153]= 153;
assign arg [0][154]= 154;
assign arg [0][155]= 155;
assign arg [0][156]= 156;
assign arg [0][157]= 157;
assign arg [0][158]= 158;
assign arg [0][159]= 159;
assign arg [0][160]= 160;
assign arg [0][161]= 161;
assign arg [0][162]= 162;
assign arg [0][163]= 163;
assign arg [0][164]= 164;
assign arg [0][165]= 165;
assign arg [0][166]= 166;
assign arg [0][167]= 167;
assign arg [0][168]= 168;
assign arg [0][169]= 169;
assign arg [0][170]= 170;
assign arg [0][171]= 171;
assign arg [0][172]= 172;
assign arg [0][173]= 173;
assign arg [0][174]= 174;
assign arg [0][175]= 175;
assign arg [0][176]= 176;
assign arg [0][177]= 177;
assign arg [0][178]= 178;
assign arg [0][179]= 179;
assign arg [0][180]= 180;
assign arg [0][181]= 181;
assign arg [0][182]= 182;
assign arg [0][183]= 183;
assign arg [0][184]= 184;
assign arg [0][185]= 185;
assign arg [0][186]= 186;
assign arg [0][187]= 187;
assign arg [0][188]= 188;
assign arg [0][189]= 189;
assign arg [0][190]= 190;
assign arg [0][191]= 191;
assign arg [0][192]= 192;
assign arg [0][193]= 193;
assign arg [0][194]= 194;
assign arg [0][195]= 195;
assign arg [0][196]= 196;
assign arg [0][197]= 197;
assign arg [0][198]= 198;
assign arg [0][199]= 199;
assign arg [0][200]= 200;
assign arg [0][201]= 201;
assign arg [0][202]= 202;
assign arg [0][203]= 203;
assign arg [0][204]= 204;
assign arg [0][205]= 205;
assign arg [0][206]= 206;
assign arg [0][207]= 207;
assign arg [0][208]= 208;
assign arg [0][209]= 209;
assign arg [0][210]= 210;
assign arg [0][211]= 211;
assign arg [0][212]= 212;
assign arg [0][213]= 213;
assign arg [0][214]= 214;
assign arg [0][215]= 215;
assign arg [0][216]= 216;
assign arg [0][217]= 217;
assign arg [0][218]= 218;
assign arg [0][219]= 219;
assign arg [0][220]= 220;
assign arg [0][221]= 221;
assign arg [0][222]= 222;
assign arg [0][223]= 223;
assign arg [0][224]= 224;
assign arg [0][225]= 225;
assign arg [0][226]= 226;
assign arg [0][227]= 227;
assign arg [0][228]= 228;
assign arg [0][229]= 229;
assign arg [0][230]= 230;
assign arg [0][231]= 231;
assign arg [0][232]= 232;
assign arg [0][233]= 233;
assign arg [0][234]= 234;
assign arg [0][235]= 235;
assign arg [0][236]= 236;
assign arg [0][237]= 237;
assign arg [0][238]= 238;
assign arg [0][239]= 239;
assign arg [0][240]= 240;
assign arg [0][241]= 241;
assign arg [0][242]= 242;
assign arg [0][243]= 243;
assign arg [0][244]= 244;
assign arg [0][245]= 245;
assign arg [0][246]= 246;
assign arg [0][247]= 247;
assign arg [0][248]= 248;
assign arg [0][249]= 249;
assign arg [0][250]= 250;
assign arg [0][251]= 251;
assign arg [0][252]= 252;
assign arg [0][253]= 253;
assign arg [0][254]= 254;
assign arg [0][255]= 255;
assign arg [0][256]= 256;
assign arg [0][257]= 257;
assign arg [0][258]= 258;
assign arg [0][259]= 259;
assign arg [0][260]= 260;
assign arg [0][261]= 261;
assign arg [0][262]= 262;
assign arg [0][263]= 263;
assign arg [0][264]= 264;
assign arg [0][265]= 265;
assign arg [0][266]= 266;
assign arg [0][267]= 267;
assign arg [0][268]= 268;
assign arg [0][269]= 269;
assign arg [0][270]= 270;
assign arg [0][271]= 271;
assign arg [0][272]= 272;
assign arg [0][273]= 273;
assign arg [0][274]= 274;
assign arg [0][275]= 275;
assign arg [0][276]= 276;
assign arg [0][277]= 277;
assign arg [0][278]= 278;
assign arg [0][279]= 279;
assign arg [0][280]= 280;
assign arg [0][281]= 281;
assign arg [0][282]= 282;
assign arg [0][283]= 283;
assign arg [0][284]= 284;
assign arg [0][285]= 285;
assign arg [0][286]= 286;
assign arg [0][287]= 287;
assign arg [0][288]= 288;
assign arg [0][289]= 289;
assign arg [0][290]= 290;
assign arg [0][291]= 291;
assign arg [0][292]= 292;
assign arg [0][293]= 293;
assign arg [0][294]= 294;
assign arg [0][295]= 295;
assign arg [0][296]= 296;
assign arg [0][297]= 297;
assign arg [0][298]= 298;
assign arg [0][299]= 299;
assign arg [0][300]= 300;
assign arg [0][301]= 301;
assign arg [0][302]= 302;
assign arg [0][303]= 303;
assign arg [0][304]= 304;
assign arg [0][305]= 305;
assign arg [0][306]= 306;
assign arg [0][307]= 307;
assign arg [0][308]= 308;
assign arg [0][309]= 309;
assign arg [0][310]= 310;
assign arg [0][311]= 311;
assign arg [0][312]= 312;
assign arg [0][313]= 313;
assign arg [0][314]= 314;
assign arg [0][315]= 315;
assign arg [0][316]= 316;
assign arg [0][317]= 317;
assign arg [0][318]= 318;
assign arg [0][319]= 319;
assign arg [0][320]= 320;
assign arg [0][321]= 321;
assign arg [0][322]= 322;
assign arg [0][323]= 323;
assign arg [0][324]= 324;
assign arg [0][325]= 325;
assign arg [0][326]= 326;
assign arg [0][327]= 327;
assign arg [0][328]= 328;
assign arg [0][329]= 329;
assign arg [0][330]= 330;
assign arg [0][331]= 331;
assign arg [0][332]= 332;
assign arg [0][333]= 333;
assign arg [0][334]= 334;
assign arg [0][335]= 335;
assign arg [0][336]= 336;
assign arg [0][337]= 337;
assign arg [0][338]= 338;
assign arg [0][339]= 339;
assign arg [0][340]= 340;
assign arg [0][341]= 341;
assign arg [0][342]= 342;
assign arg [0][343]= 343;
assign arg [0][344]= 344;
assign arg [0][345]= 345;
assign arg [0][346]= 346;
assign arg [0][347]= 347;
assign arg [0][348]= 348;
assign arg [0][349]= 349;
assign arg [0][350]= 350;
assign arg [0][351]= 351;
assign arg [0][352]= 352;
assign arg [0][353]= 353;
assign arg [0][354]= 354;
assign arg [0][355]= 355;
assign arg [0][356]= 356;
assign arg [0][357]= 357;
assign arg [0][358]= 358;
assign arg [0][359]= 359;
assign arg [0][360]= 360;
assign arg [0][361]= 361;
assign arg [0][362]= 362;
assign arg [0][363]= 363;
assign arg [0][364]= 364;
assign arg [0][365]= 365;
assign arg [0][366]= 366;
assign arg [0][367]= 367;
assign arg [0][368]= 368;
assign arg [0][369]= 369;
assign arg [0][370]= 370;
assign arg [0][371]= 371;
assign arg [0][372]= 372;
assign arg [0][373]= 373;
assign arg [0][374]= 374;
assign arg [0][375]= 375;
assign arg [0][376]= 376;
assign arg [0][377]= 377;
assign arg [0][378]= 378;
assign arg [0][379]= 379;
assign arg [0][380]= 380;
assign arg [0][381]= 381;
assign arg [0][382]= 382;
assign arg [0][383]= 383;
assign arg [0][384]= 384;
assign arg [0][385]= 385;
assign arg [0][386]= 386;
assign arg [0][387]= 387;
assign arg [0][388]= 388;
assign arg [0][389]= 389;
assign arg [0][390]= 390;
assign arg [0][391]= 391;
assign arg [0][392]= 392;
assign arg [0][393]= 393;
assign arg [0][394]= 394;
assign arg [0][395]= 395;
assign arg [0][396]= 396;
assign arg [0][397]= 397;
assign arg [0][398]= 398;
assign arg [0][399]= 399;
assign arg [0][400]= 400;
assign arg [0][401]= 401;
assign arg [0][402]= 402;
assign arg [0][403]= 403;
assign arg [0][404]= 404;
assign arg [0][405]= 405;
assign arg [0][406]= 406;
assign arg [0][407]= 407;
assign arg [0][408]= 408;
assign arg [0][409]= 409;
assign arg [0][410]= 410;
assign arg [0][411]= 411;
assign arg [0][412]= 412;
assign arg [0][413]= 413;
assign arg [0][414]= 414;
assign arg [0][415]= 415;
assign arg [0][416]= 416;
assign arg [0][417]= 417;
assign arg [0][418]= 418;
assign arg [0][419]= 419;
assign arg [0][420]= 420;
assign arg [0][421]= 421;
assign arg [0][422]= 422;
assign arg [0][423]= 423;
assign arg [0][424]= 424;
assign arg [0][425]= 425;
assign arg [0][426]= 426;
assign arg [0][427]= 427;
assign arg [0][428]= 428;
assign arg [0][429]= 429;
assign arg [0][430]= 430;
assign arg [0][431]= 431;
assign arg [0][432]= 432;
assign arg [0][433]= 433;
assign arg [0][434]= 434;
assign arg [0][435]= 435;
assign arg [0][436]= 436;
assign arg [0][437]= 437;
assign arg [0][438]= 438;
assign arg [0][439]= 439;
assign arg [0][440]= 440;
assign arg [0][441]= 441;
assign arg [0][442]= 442;
assign arg [0][443]= 443;
assign arg [0][444]= 444;
assign arg [0][445]= 445;
assign arg [0][446]= 446;
assign arg [0][447]= 447;
assign arg [0][448]= 448;
assign arg [0][449]= 449;
assign arg [0][450]= 450;
assign arg [0][451]= 451;
assign arg [0][452]= 452;
assign arg [0][453]= 453;
assign arg [0][454]= 454;
assign arg [0][455]= 455;
assign arg [0][456]= 456;
assign arg [0][457]= 457;
assign arg [0][458]= 458;
assign arg [0][459]= 459;
assign arg [0][460]= 460;
assign arg [0][461]= 461;
assign arg [0][462]= 462;
assign arg [0][463]= 463;
assign arg [0][464]= 464;
assign arg [0][465]= 465;
assign arg [0][466]= 466;
assign arg [0][467]= 467;
assign arg [0][468]= 468;
assign arg [0][469]= 469;
assign arg [0][470]= 470;
assign arg [0][471]= 471;
assign arg [0][472]= 472;
assign arg [0][473]= 473;
assign arg [0][474]= 474;
assign arg [0][475]= 475;
assign arg [0][476]= 476;
assign arg [0][477]= 477;
assign arg [0][478]= 478;
assign arg [0][479]= 479;
assign arg [0][480]= 480;
assign arg [0][481]= 481;
assign arg [0][482]= 482;
assign arg [0][483]= 483;
assign arg [0][484]= 484;
assign arg [0][485]= 485;
assign arg [0][486]= 486;
assign arg [0][487]= 487;
assign arg [0][488]= 488;
assign arg [0][489]= 489;
assign arg [0][490]= 490;
assign arg [0][491]= 491;
assign arg [0][492]= 492;
assign arg [0][493]= 493;
assign arg [0][494]= 494;
assign arg [0][495]= 495;
assign arg [0][496]= 496;
assign arg [0][497]= 497;
assign arg [0][498]= 498;
assign arg [0][499]= 499;
assign arg [0][500]= 500;
assign arg [0][501]= 501;
assign arg [0][502]= 502;
assign arg [0][503]= 503;
assign arg [0][504]= 504;
assign arg [0][505]= 505;
assign arg [0][506]= 506;
assign arg [0][507]= 507;
assign arg [0][508]= 508;
assign arg [0][509]= 509;
assign arg [0][510]= 510;
assign arg [0][511]= 511;



// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//             buffer_f <= 'b0;
//       end
//       else if (en_r[LGFFT+1]) begin
//             buffer_f <= buffer2[0] > buffer2[1] ? buffer2[0] : buffer2[1];
//       end
// end

// always_ff@(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer0 <= '{HFFT{'b0}};
//       end
//       else if (en) begin
//         for (a = 0; a < HFFT; a=a+1)begin
//             buffer0[a] <= TimeCoord [a] > TimeCoord [a+HFFT] ? TimeCoord [a] : TimeCoord [a+HFFT];
//         end
//       end
// end

// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer1 <= '{HFFT{'b0}};
//       end
//       else if (en_r[0]) begin
//         for (b = 0; b < HFFT/2; b=b+1)begin
//             buffer1[b] <= buffer0[b] > buffer0[b+HFFT/2] ? buffer0[b] : buffer0[b+HFFT/2];
//         end
//       end
// end

// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer2 <= '{HFFT{'b0}};
//       end
//       else if (en_r[1]) begin
//         for (c = 0; c < HFFT/4; c=c+1)begin
//             buffer2[c] <= buffer1[c] > buffer1[c+HFFT/4] ? buffer1[c] : buffer1[c+HFFT/4];
//         end
//       end
// end


// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer3 <= '{HFFT{'b0}};
//       end
//       else if (en_r[2]) begin
//         for (d = 0; d < 64; d=d+1)begin
//             buffer3[d] <= buffer2[d] > buffer2[d+64] ? buffer2[d] : buffer2[d+64];
//         end
//       end
// end

// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer4 <= '{HFFT{'b0}};
//       end
//       else if (en_r[3]) begin
//         for (e = 0; e < 32; e=e+1)begin
//             buffer4[e] <= buffer3[e] > buffer3[e+32] ? buffer3[e] : buffer3[e+32];
//         end
//       end
// end

// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer5 <= '{HFFT{'b0}};
//       end
//       else if (en_r[4]) begin
//         for (f = 0; f < 16; f=f+1)begin
//             buffer5[f] <= buffer4[f] > buffer4[f+16] ? buffer4[f] : buffer4[f+16];
//         end
//       end
// end

// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer6 <= '{HFFT{'b0}};
//       end
//       else if (en_r[5]) begin
//         for (g = 0; g < 8; g=g+1)begin
//             buffer6[g] <= buffer5[g] > buffer5[g+8] ? buffer5[g] : buffer5[g+8];
//         end
//       end
// end



// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer7 <= '{HFFT{'b0}};
//       end
//       else if (en_r[6]) begin
//         for (h = 0; h < 4; h=h+1)begin  
//             buffer7[h] <= buffer6[h] > buffer6[h+4] ? buffer6[h] : buffer6[h+4];
//         end
//       end
// end

// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//           buffer8 <= '{HFFT{'b0}};
//       end
//       else if (en_r[7]) begin
//         for (i = 0; i < 2; i=i+1)begin
//             buffer8[i] <= buffer7[i] > buffer7[i+2] ? buffer7[i] : buffer7[i+2];
//         end
//       end
// end
        
// always_ff @(posedge clk or negedge rstn) begin
//       if (!rstn) begin
//             buffer_f <= 'b0;
//       end
//       else if (en_r[8]) begin
//             buffer_f <= buffer8[0] > buffer8[1] ? buffer8[0] : buffer8[1];
//       end
// end


endmodule