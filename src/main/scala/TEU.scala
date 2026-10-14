//> using repository https://central.sonatype.com/repository/maven-snapshots
//> using scala 2.13.18
//> using dep org.chipsalliance::chisel:7.16.0
//> using plugin org.chipsalliance:::chisel-plugin:7.16.0
//> using options -unchecked -deprecation -language:reflectiveCalls -feature -Xcheckinit
//> using options -Xfatal-warnings -Ywarn-dead-code -Ywarn-unused -Ymacro-annotations

import chisel3._
// _root_ disambiguates from package chisel3.util.circt if user imports chisel3.util._
import _root_.circt.stage.ChiselStage

class TEU extends Module {
  // Typedef F32 for clarity
  def F32(): UInt = UInt(32.W)

  // I/O signals
  val load_enable = IO(Input(Bool()))
  val load_target = IO(Input(UInt(4.W)))
  val load_src = IO(Input(UInt(1.W)))
  val load_offset = IO(Input(UInt(2.W)))

  val bus_enable = IO(Input(Bool())) // Expose to bus
  val bus_src = IO(Input(UInt(1.W)))

  val fpu_op = IO(Input(UInt(2.W)))
  val fpu_in1 = IO(Input(UInt(5.W)))
  val fpu_in2 = IO(Input(UInt(4.W)))
  val fpu_inputs_switch = IO(Input(Bool())) // Switch their order or not

  // Tri-states are poorly supported and suck to test so just have an external mux handle it
  val bus_in = IO(Input(UInt(128.W)))
  val bus_out = IO(Input(UInt(128.W)))

  // Registers
  val A = Reg(Vec(16, F32()))
  val B = Reg(Vec(4, F32()))
  val C = Reg(Vec(4, F32()))
  val s = F32()

  when(load_enable) {
    
  }
}

object Main extends App {
  println(
    ChiselStage.emitSystemVerilog(
      gen = new Foo,
      firtoolOpts = Array("-disable-all-randomization", "-strip-debug-info", "-default-layer-specialization=enable")
    )
  )
}
