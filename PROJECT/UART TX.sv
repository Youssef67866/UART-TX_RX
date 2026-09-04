module uart_tx #(parameter DATA_W = 8) (
    input  logic [DATA_W-1:0] i_data,
    input  logic i_valid,
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic i_par_en,
    input  logic i_par_odd,
    output logic o_tx,
    output logic o_busy
);

    logic [DATA_W-1:0] data_latched;
    logic par_en_latched;
    logic par_odd_latched;
    logic [1:0] MUX_Sel_Wire;
    logic Serializer_Load_Wire;
    logic Serializer_Shift_Wire;
    logic Serial_Out_Wire;
    logic Parity_CLC_Out_Wire;
    // logic data_done_wire; // يمكنك تركه غير موصول

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            data_latched    <= '0;
            par_en_latched  <= 1'b0;
            par_odd_latched <= 1'b0;
        end else if (i_valid && !o_busy) begin
            data_latched    <= i_data;
            par_en_latched  <= i_par_en;
            par_odd_latched <= i_par_odd;
        end
    end

    Main_Controller #(.P(DATA_W)) Module_1 (
        .V_INPUT(i_valid && !o_busy),
        .CLK(i_clk),
        .RST(i_rst_n),
        .P_EN(i_par_en),
        .BUSY(o_busy),
        .MUX_Sel(MUX_Sel_Wire),
        .Serializer_Load(Serializer_Load_Wire),
        .Serializer_Shift(Serializer_Shift_Wire)
    );

    Parity_Bit #(.P(DATA_W)) Module_2 (
        .P_INPUT(data_latched),
        .P_BIT(par_odd_latched),
        .Parity_CLC_Out(Parity_CLC_Out_Wire)
    );

    Serializer #(.P(DATA_W)) Module_3 (
        .CLK(i_clk),
        .RST(i_rst_n),
        .Serializer_Load(Serializer_Load_Wire),
        .Serializer_Shift(Serializer_Shift_Wire),
        .P_INPUT(data_latched),
        .P_BIT(Parity_CLC_Out_Wire),
        .Serial_Out(Serial_Out_Wire),
        .data_done()  // ترك غير موصول
    );

    MUX Module_4 (
        .MUX_Sel(MUX_Sel_Wire),
        .Serial_Out(Serial_Out_Wire),
        .Parity_CLC_Out(Parity_CLC_Out_Wire),
        .TX_OUTPUT(o_tx)
    );

endmodule