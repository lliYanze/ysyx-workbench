
 import "DPI-C" function void stopnpc();
module EndNpc(
    input endflag
);
 always @(*) 
    if (endflag) stopnpc();

endmodule
