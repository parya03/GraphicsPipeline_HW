module teu (
    // Micro operations
    input  logic       en_load,
    input  logic       load_src, // Load from bus (0) or FPU (1)
    input  logic [3:0] load_target,
    input  logic [1:0] load_offset, // Offset in load to handle loading vectors
    input  logic       en_bus,
    input  logic       bus_target,
    input  logic [1:0] fpu_operation,
    input  logic       fpu_input_stb, // Strobe for FPU inputs
    input  logic       fpu_output_ack, // Acknowledge that FPU output has been received
    input  logic [4:0] fpu_in1_routing, // FPU In1
    input  logic [3:0] fpu_in2_routing, // FPU In2
    input  logic       fpu_input_switch, // Switch inputs to FPU (for division etc)
    // input  logic [2:0] fpu_out_routing, // FPU Output

    // Bus
    inout  wire [127:0] bus,
    
    // General digital logic stuff
    input  logic       clk,
    input  logic       reset,
    output logic       fpu_output_stb // Strobe from FPU's side
);

    // Reg file
    reg [31:0] A[16];
    reg [31:0] b[4];
    reg [31:0] c[4];
    reg [31:0] s;

    // module fpu (
    //     // I/O
    //     input  logic [31:0] in1,
    //     input  logic [31:0] in2,
    //     input  logic        in_stb, // Strobe; are both inputs valid - hold for 2 cycles
    //     input  logic  [1:0] op,
    //     input  logic        fpu_output_ack, // Ack that FPU output has been received

    //     output logic [31:0] out,
    //     output logic        fpu_out_stb, // Strobe from FPU's side
        
    //     // General digital logic stuff
    //     input  logic       reset,
    //     input  logic       clk,
    // );
    logic [31:0] fpu_in1_temp;
    logic [31:0] fpu_in2_temp;
    logic [31:0] fpu_in1;
    logic [31:0] fpu_in2;
    // wire [31:0] fpu_out_temp;
    wire [31:0] fpu_out;
    wire [127:0] load_val = load_src ? {96'b0, fpu_out} : bus;

    logic [127:0] bus_drive;
    assign bus = en_bus ? bus_drive : 128'bz; // Drive the bus

    // FPU instance
    fpu fpu_i (
        .in1(fpu_in1),
        .in2(fpu_in2),
        .in_stb(fpu_input_stb), // Strobe; are both inputs valid - hold for 2 cycles
        .op(fpu_operation),
        .fpu_output_ack(fpu_output_ack), // Ack that FPU output has been received
        .out(fpu_out),
        .fpu_out_stb(fpu_output_stb), // Strobe from FPU's side
        .reset(reset),
        .clk(clk)
    );

    always_comb begin
        fpu_in1_temp = 32'b0;
        fpu_in2_temp = 32'b0;
        fpu_in1 = 32'b0;
        fpu_in2 = 32'b0;
        bus_drive = 128'b0;

        // FPU input 1 routing
        case(fpu_in1_routing[4])
            1'b0: fpu_in1_temp = s;
            1'b1: fpu_in1_temp = A[fpu_in1_routing[3:0]];
            default: fpu_in1_temp = 32'b0;
        endcase

        // FPU input 2 routing
        case(fpu_in2_routing[3:2])
            2'b00: fpu_in2_temp = s; // Just use scalar
            2'b01: fpu_in2_temp = b[fpu_in2_routing[1:0]];
            2'b10: fpu_in2_temp = c[fpu_in2_routing[1:0]];
            2'b11: fpu_in2_temp = 0; // Error case?
            default: fpu_in2_temp = 32'b0;
        endcase

        case(fpu_input_switch)
            1'b1: begin
                fpu_in1 = fpu_in2_temp;
                fpu_in2 = fpu_in1_temp;
            end
            1'b0: begin
                fpu_in1 = fpu_in1_temp;
                fpu_in2 = fpu_in2_temp;
            end
            default: begin
                fpu_in1 = 32'b0;
                fpu_in2 = 32'b0;
            end
        endcase

        // Drive bus with scalar or c
        if(bus_target == 1'b1) begin
            bus_drive[31:0] = s;
            bus_drive[127:32] = 96'b0;
        end
        else begin
            bus_drive[31:0] = c[0];
            bus_drive[63:32] = c[1];
            bus_drive[95:64] = c[2];
            bus_drive[127:96] = c[3];
        end
    end

    wire [3:0] A_col = {2'b0, load_target[1:0]};
    always @(posedge clk) begin
        if (reset) begin
            for (integer i = 0; i < 16; i = i + 1) begin
                A[i] <= 32'b0;
            end

            for (integer i = 0; i < 4; i = i + 1) begin
                b[i] <= 32'b0;
                c[i] <= 32'b0;
            end

            s <= 32'b0;

            // data_out <= 0;
        end
        else begin
            if(en_load == 1'b1) begin
                // Pick if loading from 
                // Pick if scalar or vector regs
                if(load_target[3] == 1'b1) begin
                    s <= load_val[31:0];
                end
                else begin
                    // Pick if A or b
                    if(load_target[2] == 1'b1) begin
                        // A
                        A[A_col] <= load_val[31:0];
                        A[A_col + 4] <= load_val[63:32];
                        A[A_col + 8] <= load_val[95:64];
                        A[A_col + 12] <= load_val[127:96];
                    end
                    else begin
                        // b
                        b[0] <= load_val[31:0];
                        b[1] <= load_val[63:32];
                        b[2] <= load_val[95:64];
                        b[3] <= load_val[127:96];
                    end
                end
            end
        end
    end

endmodule
