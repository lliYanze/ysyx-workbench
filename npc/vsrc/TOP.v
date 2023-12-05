module TOP(
  input   clock,
  input   reset,
  input   io_in_a,
  input   io_in_b,
  output  io_out
);
  assign io_out = io_in_a ^ io_in_b; // @[TOP.scala 9:21]
  always @(posedge clock) begin
    `ifndef SYNTHESIS
    `ifdef PRINTF_COND
      if (`PRINTF_COND) begin
    `endif
        if (~reset) begin
          $fwrite(32'h80000002,"io.in_a = %d, io.in_b = %d, io.out = %d\n",io_in_a,io_in_b,io_out); // @[TOP.scala 10:9]
        end
    `ifdef PRINTF_COND
      end
    `endif
    `endif // SYNTHESIS
  end
endmodule
