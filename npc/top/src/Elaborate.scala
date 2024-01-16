import circt.stage._

object Elaborate extends App {
  def top = new TOP()
  val useMFC = false // use MLIR-based firrtl compiler
  // val useMFC    = true // use MLIR-based firrtl compiler
  val generator = Seq(chisel3.stage.ChiselGeneratorAnnotation(() => top))
  val firtoolOptions = Seq(
    FirtoolOption("--lowering-options=disallowLocalVariables"),
    FirtoolOption("--lowering-options=disallowPackedArrays"),
    )
  if (useMFC) {
    val lyz_generator = generator :+ CIRCTTargetAnnotation(CIRCTTarget.Verilog)
    // (new ChiselStage).execute(args, generator :+ CIRCTTargetAnnotation(CIRCTTarget.Verilog))
    (new ChiselStage).execute(args, lyz_generator ++ firtoolOptions)
  } else {
    (new chisel3.stage.ChiselStage).execute(args, generator)
  }
}
