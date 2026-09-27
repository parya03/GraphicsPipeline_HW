`timescale 1ns/1ps

module sim_top;
    logic         en_load;
    logic         load_src;
    logic [3:0]   load_target;
    logic         en_bus;
    logic         bus_target;
    logic [1:0]   fpu_operation;
    logic         fpu_input_stb;
    logic         fpu_output_ack;
    logic [4:0]   fpu_in1_routing;
    logic [3:0]   fpu_in2_routing;
    logic         fpu_input_switch;
    logic [2:0]   fpu_out_routing;
    logic         clk;
    logic         reset;
    logic         fpu_output_stb;

    logic [127:0] bus_drive;
    logic         bus_drive_enable;
    tri   [127:0] bus;

    assign bus = bus_drive_enable ? bus_drive : 128'bz;

    top dut (
        .en_load,
        .load_src,
        .load_target,
        .en_bus,
        .bus_target,
        .fpu_operation,
        .fpu_input_stb,
        .fpu_output_ack,
        .fpu_in1_routing,
        .fpu_in2_routing,
        .fpu_input_switch,
        .fpu_out_routing,
        .bus,
        .clk,
        .reset,
        .fpu_output_stb
    );

    initial begin
        $dumpfile("build/wave.vcd");
        $dumpvars(0, sim_top);
        $cpp_test;
    end
endmodule
