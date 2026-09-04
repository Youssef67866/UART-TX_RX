module Serializer #(parameter P = 8) (
    input  logic CLK,
    input  logic RST,
    input  logic Serializer_Load,
    input  logic Serializer_Shift,
    input  logic [P-1:0] P_INPUT,
    input  logic P_BIT,
    output logic Serial_Out,
    output logic data_done
);

    logic [P+2:0] SREG;
    logic [$clog2(P+3)-1:0] cnt;

    assign Serial_Out = SREG[0];

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            SREG    <= '1;
            cnt     <= 0;
            data_done <= 1'b0;
        end else begin
            data_done <= 1'b0;
            if (Serializer_Load) begin
                SREG <= {1'b1, P_BIT, P_INPUT, 1'b0};
                cnt  <= 0;
            end else if (Serializer_Shift) begin
                SREG <= {1'b1, SREG[P+2:1]};
                if (cnt == P-1) begin   
                    cnt <= 0;
                    data_done <= 1'b1;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end
    end

endmodule