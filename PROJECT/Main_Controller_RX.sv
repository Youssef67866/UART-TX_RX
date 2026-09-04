module Main_Controller_rX #(parameter P = 8) (
    input  logic Serial_In,
    input  logic clk,
    input  logic rst,
    input  logic Parity_Enable,
    input  logic Parity_Error_In,
    output logic Busy,
    output logic Frame_Error,
    output logic Valid,
    output logic Parity_Error_Out,
    output logic Deserializer_Shift,
    output logic Parity_Check,
    output logic Stop_Check
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
    logic Parity_Enable_Latched;
    logic Latch_Parity_Error;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            Current_State         <= Idle_S0;
            Data_Counter          <= '0;
            Parity_Enable_Latched <= 1'b0;
            Latch_Parity_Error    <= 1'b0;
            Valid                 <= 1'b0;
            Frame_Error           <= 1'b0;
            Parity_Error_Out      <= 1'b0;
        end else begin
            Current_State <= Next_State;
            Valid            <= 1'b0;
            Frame_Error      <= 1'b0;
            Parity_Error_Out <= 1'b0;

            if (Current_State == Idle_S0 && Serial_In == 1'b0) begin
                Parity_Enable_Latched <= Parity_Enable;
            end

            if (Current_State == Data_Bits_S2) begin
                if (Data_Counter == P-1)
                    Data_Counter <= '0;
                else
                    Data_Counter <= Data_Counter + 1'b1;
            end else begin
                Data_Counter <= '0;
            end

            if (Current_State == Parity_Bit_S3) begin
                Latch_Parity_Error <= Parity_Error_In;
            end

            if (Current_State == Stop_Bit_S4) begin
                Valid <= 1'b1;
                if (Serial_In != 1'b1)
                    Frame_Error <= 1'b1;
                if (Parity_Enable_Latched)
                    Parity_Error_Out <= Latch_Parity_Error;
            end
        end
    end

    always_comb begin
        Busy               = 1'b1;
        Deserializer_Shift = 1'b0;
        Parity_Check       = 1'b0;
        Stop_Check         = 1'b0;
        Next_State         = Current_State;

        case (Current_State)
          Idle_S0: begin
                Busy = 1'b0;
                if (Serial_In == 1'b0)
                    Next_State = Start_Bit_S1;
                    end

            Start_Bit_S1: begin
                Next_State = Data_Bits_S2;
            end

            Data_Bits_S2: begin
                Deserializer_Shift = 1'b1;
                if (Data_Counter == P-1) begin
                    if (Parity_Enable_Latched)
                        Next_State = Parity_Bit_S3;
                    else
                        Next_State = Stop_Bit_S4;
                end
            end

            Parity_Bit_S3: begin
                Parity_Check = 1'b1;
                Next_State = Stop_Bit_S4;
            end

            Stop_Bit_S4: begin
                Stop_Check = 1'b1;
                Next_State = Idle_S0;
            end

            default: Next_State = Idle_S0;
        endcase
    end

endmodule