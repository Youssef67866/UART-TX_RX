module rx_parity
(
    input  logic [7:0] P_DATA,
    input  logic       RX_IN,
    input  logic       PAR_EN,
    input  logic       PAR_TYP,
    input  logic       parity_check,

    output logic       PARITY_ERROR
);

    logic calculated_parity;

    always_comb begin

        calculated_parity = 1'b0;
        PARITY_ERROR      = 1'b0;

        if (parity_check && PAR_EN) begin

            if (PAR_TYP)
                calculated_parity = ~(^P_DATA);
            else
                calculated_parity = ^P_DATA;

            PARITY_ERROR = (RX_IN != calculated_parity);

        end

    end

endmodule