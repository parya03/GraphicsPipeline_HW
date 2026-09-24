module teu (
    // Micro operations
    input  logic       en_load,
    input  logic [3:0] load_target,
    input  logic       en_bus,
    input  logic       bus_target,
    input  logic [2:0] fpu_operation,
    input  logic [4:0] fpu_in1_routing, // FPU In1
    input  logic [2:0] fpu_in2_routing, // FPU In2
    input  logic       fpu_input_switch, // Switch inputs to FPU (for division etc)
    input  logic [2:0] fpu_out_routing, // FPU Output

    // Bus
    input  wire [127:0] bus,
    
    // General digital logic stuff
    input  logic       clk,
    input  logic       reset,
    output  logic      stall, // Tell upstream to stall
);

    // Reg file
    reg [31:0] A[16];
    reg [31:0] b[4];
    reg [31:0] c[4];
    reg [31:0] s;

    FPU fpu

    always_ff @(posedge clk) begin
        if (reset)
            A <= 0;
            b <= 0;
            c <= 0;
            s <= 0;

            // data_out <= 0;
        else
            data_out <= data_in + 8'd1;
    end

endmodule
