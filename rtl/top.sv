module top (
    input  logic       clk,
    input  logic       reset,
    input  logic [7:0] data_in,
    output logic [7:0] data_out
);

    always_ff @(posedge clk) begin
        if (reset)
            data_out <= 8'h00;
        else
            data_out <= data_in + 8'd1;
    end

endmodule
