module MUX
(
    input  logic [1:0] MUX_Sel,
    input  logic Serial_Out,
    input  logic Parity_CLC_Out,
    output logic TX_OUTPUT
);

    always_comb begin

        case (MUX_Sel)

            2'b00: TX_OUTPUT = 1'b0;          
            2'b01:TX_OUTPUT = Serial_Out;   
            2'b10:TX_OUTPUT = Parity_CLC_Out; 
            2'b11:TX_OUTPUT = 1'b1;          
            default: TX_OUTPUT = 1'b1;

        endcase

    end

endmodule