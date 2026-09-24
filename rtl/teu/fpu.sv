module fpu (
    // I/O
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  logic        stb, // Strobe; are both inputs valid - hold for 2 cycles
    output logic [31:0] out,
    input  logic  [1:0] op,
    input  logic        out_acc, // Accumulate on output
    
    // General digital logic stuff
    input  logic       reset,
    input  logic       clk,
    output logic       stall, // Stall upstream while FPU does its thing
);

    // General module layout for FPU library
    // module adder(
    //     input_a,
    //     input_b,
    //     input_a_stb,
    //     input_b_stb,
    //     output_z_ack,
    //     clk,
    //     rst,
    //     output_z,
    //     output_z_stb,
    //     input_a_ack,
    //     input_b_ack);

    // Adder
    wire z_ack_add, z_stb_add;
    wire [31:0] out_add;

    adder adder (
        .input_a      (in1),
        .input_b      (in2),
        .input_a_stb  (stb),
        .input_b_stb  (stb),
        .output_z_ack (z_ack_add),
        .clk          (clk),
        .rst          (reset),
        .output_z     (out_add),
        .output_z_stb (z_stb_add),
        .input_a_ack  (),
        .input_b_ack  ()
    );


    // Multiplier
    wire z_ack_mul, z_stb_mul;
    wire [31:0] out_mul;

    multiplier multiplier (
        .input_a      (in1),
        .input_b      (in2),
        .input_a_stb  (stb),
        .input_b_stb  (stb),
        .output_z_ack (z_ack_mul),
        .clk          (clk),
        .rst          (reset),
        .output_z     (out_mul),
        .output_z_stb (z_stb_mul),
        .input_a_ack  (),
        .input_b_ack  ()
    );


    // Divider
    wire z_ack_div, z_stb_div;
    wire [31:0] out_div;

    divider divider (
        .input_a      (in1),
        .input_b      (in2),
        .input_a_stb  (stb),
        .input_b_stb  (stb),
        .output_z_ack (z_ack_div),
        .clk          (clk),
        .rst          (reset),
        .output_z     (out_div),
        .output_z_stb (z_stb_div),
        .input_a_ack  (),
        .input_b_ack  ()
    );

    wire out_sub = 0; // Null right now

    always @(*) begin
        case(op)
            2'b00: out = out_add;
            2'b01: out = out_sub;
            2'b10: out = out_mul;
            2'b11: out = out_div;
        endcase
    end

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
