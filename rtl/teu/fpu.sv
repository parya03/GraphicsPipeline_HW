module fpu (
    // I/O
    input  logic [31:0] in1,
    input  logic [31:0] in2,
    input  logic        in_stb, // Strobe; are both inputs valid - hold for 2 cycles
    input  logic  [1:0] op,
    input  logic        fpu_output_ack, // Ack that FPU output has been received

    output logic [31:0] out,
    output logic        fpu_out_stb, // Strobe from FPU's side
    
    // General digital logic stuff
    input  logic       reset,
    input  logic       clk
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
    logic add_input_stb, z_ack_add;
    wire z_stb_add;
    wire [31:0] out_add;

    adder adder (
        .input_a      (in1),
        .input_b      (in2),
        .input_a_stb  (add_input_stb),
        .input_b_stb  (add_input_stb),
        .output_z_ack (z_ack_add),
        .clk          (clk),
        .rst          (reset),
        .output_z     (out_add),
        .output_z_stb (z_stb_add),
        .input_a_ack  (),
        .input_b_ack  ()
    );


    // Multiplier
    logic mul_input_stb, z_ack_mul;
    wire z_stb_mul;
    wire [31:0] out_mul;

    multiplier multiplier (
        .input_a      (in1),
        .input_b      (in2),
        .input_a_stb  (mul_input_stb),
        .input_b_stb  (mul_input_stb),
        .output_z_ack (z_ack_mul),
        .clk          (clk),
        .rst          (reset),
        .output_z     (out_mul),
        .output_z_stb (z_stb_mul),
        .input_a_ack  (),
        .input_b_ack  ()
    );


    // Divider
    logic div_input_stb, z_ack_div;
    wire z_stb_div;
    wire [31:0] out_div;

    divider divider (
        .input_a      (in1),
        .input_b      (in2),
        .input_a_stb  (div_input_stb),
        .input_b_stb  (div_input_stb),
        .output_z_ack (z_ack_div),
        .clk          (clk),
        .rst          (reset),
        .output_z     (out_div),
        .output_z_stb (z_stb_div),
        .input_a_ack  (),
        .input_b_ack  ()
    );

    wire [31:0] out_sub = 32'b0; // Null right now

    always_comb begin
        add_input_stb = 1'b0;
        mul_input_stb = 1'b0;
        div_input_stb = 1'b0;
        z_ack_add = 1'b0;
        z_ack_mul = 1'b0;
        z_ack_div = 1'b0;
        out = 32'b0;
        fpu_out_stb = 1'b0;

        case(op)
            2'b00: begin
                add_input_stb = in_stb;
                z_ack_add = fpu_output_ack;
                out = out_add;
                fpu_out_stb = z_stb_add;
            end
            2'b01: begin
                out = out_sub;
                fpu_out_stb = 1'b0; // Null for now
            end
            2'b10: begin
                mul_input_stb = in_stb;
                z_ack_mul = fpu_output_ack;
                out = out_mul;
                fpu_out_stb = z_stb_mul;
            end
            2'b11: begin
                div_input_stb = in_stb;
                z_ack_div = fpu_output_ack;
                out = out_div;
                fpu_out_stb = z_stb_div;
            end
            default: begin
                out = 32'b0;
                fpu_out_stb = 1'b0;
            end
        endcase
    end

    // always_ff @(posedge clk) begin
    //     if (reset)
    //         A <= 0;
    //         b <= 0;
    //         c <= 0;
    //         s <= 0;

    //         // data_out <= 0;
    //     else
    //         data_out <= data_in + 8'd1;
    // end

endmodule
