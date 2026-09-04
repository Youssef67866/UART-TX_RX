module Parity_Bit #(parameter P = 8)
(
    input  logic [P-1:0] P_INPUT,
    input  logic P_BIT,
    output logic Parity_CLC_Out
);

    always_comb begin

        if (P_BIT)
            Parity_CLC_Out = ~(^P_INPUT);
        else
            Parity_CLC_Out = ^P_INPUT;

    end

endmodule