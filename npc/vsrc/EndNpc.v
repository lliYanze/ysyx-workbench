
 import "DPI-C" function void stopnpc(input int state);
module EndNpc(
    input endflag,
  input wire [31:0] state
);
 always @(*) 
    if (endflag) stopnpc(state);

endmodule
