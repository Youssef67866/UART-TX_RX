module Main_Controller #(parameter P = 8) (
    input  logic V_INPUT,
    input  logic CLK,
    input  logic RST,
    input  logic P_EN,
    output logic BUSY,
    output logic [1:0] MUX_Sel,
    output logic Serializer_Load,
    output logic Serializer_Shift
);

    typedef enum logic [2:0] {
        Idle_S0,
        Start_Bit_S1,
        Data_Bits_S2,
        Parity_Bit_S3,
        Stop_Bit_S4
    } state_t;

    state_t Current_State, Next_State;
    logic [$clog2(P)-1:0] Data_Counter;
    logic P_EN_Latched;

    always_ff @(posedge CLK or negedge RST) begin
        if (!RST) begin
            Current_State <= Idle_S0;
            Data_Counter  <= 0;
            P_EN_Latched  <= 1'b0;
        end else begin
            Current_State <= Next_State;
            if (Current_State == Idle_S0 && V_INPUT)
                P_EN_Latched <= P_EN;
            if (Current_State == Data_Bits_S2)
                Data_Counter <= Data_Counter + 1'b1;
            else
                Data_Counter <= 0;
        end
    end

    always_comb begin
        BUSY              = 1'b1;
        MUX_Sel           = 2'b11;
        Serializer_Load   = 1'b0;
        Serializer_Shift  = 1'b0;
        Next_State        = Current_State;

        case (Current_State)
           Idle_S0: begin
    BUSY = 1'b0;
    if (V_INPUT) begin
        Serializer_Load = 1'b1;    
        Next_State      = Start_Bit_S1;
    end
end

Idle_S0: begin
                BUSY = 1'b0;
                if (V_INPUT)
                    Next_State = Start_Bit_S1;
end

            Data_Bits_S2: begin
                MUX_Sel          = 2'b01;
                Serializer_Shift = 1'b1;
                if (Data_Counter == P-1) begin
                    if (P_EN_Latched)
                        Next_State = Parity_Bit_S3;
                    else
                        Next_State = Stop_Bit_S4;
                end
            end

            Parity_Bit_S3: begin
                MUX_Sel = 2'b10;
                Next_State = Stop_Bit_S4;
            end

            Stop_Bit_S4: begin
                MUX_Sel = 2'b11;
                Next_State = Idle_S0;
            end

            default: Next_State = Idle_S0;
        endcase
    end

endmodule