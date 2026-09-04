module rx_sampler #(parameter n = 8) (
    input  logic CLK,
    input  logic RSTN,
    input  logic shift,
    input  logic RX_IN,
    output logic [n-1:0] P_DATA
);

    logic [n-1:0] shift_reg;
    logic [$clog2(n)-1:0] cnt;

    always_ff @(posedge CLK or negedge RSTN) begin
        if (!RSTN) begin
            shift_reg <= 0;
            cnt       <= 0;
        end else if (shift) begin
            shift_reg[cnt] <= RX_IN;
            if (cnt == n-1) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

    assign P_DATA = shift_reg;

endmodule