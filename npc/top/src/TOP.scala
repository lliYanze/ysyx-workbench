import chisel3._

class TOP extends Module {
  val io = IO(new Bundle {
    val in_a = Input(UInt(1.W))
    val in_b = Input(UInt(1.W))
    val out  = Output(UInt(1.W))
  })
  io.out := io.in_a ^ io.in_b
  printf("io.in_a: %d, io.in_b: %d, io.out: %d\n", io.in_a, io.in_b, io.out)
}
