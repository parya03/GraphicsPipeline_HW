module top (
    input  logic       en_load,
    input  logic       load_src,
    input  logic [3:0] load_target,
    input  logic       en_bus,
    input  logic       bus_target,
    input  logic [1:0] fpu_operation,
    input  logic       fpu_input_stb,
    input  logic       fpu_output_ack,
    input  logic [4:0] fpu_in1_routing,
    input  logic [3:0] fpu_in2_routing,
    input  logic       fpu_input_switch,
    input  logic [2:0] fpu_out_routing,
    inout  wire [127:0] bus,
    input  logic       clk,
    input  logic       reset,
    output logic       fpu_output_stb
);

    teu teu_i (
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

endmodule
