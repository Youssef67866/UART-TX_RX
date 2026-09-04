module uart_rx #(
    parameter DATA_W = 8
)
(
    input  logic i_clk,
    input  logic i_rst_n,
    input  logic i_rx,
    input  logic i_par_en,
    input  logic i_par_odd,
    output logic [DATA_W-1:0] o_data,
    output logic o_valid,
    output logic o_busy,
    output logic o_parity_err,
    output logic o_frame_err
);

    logic deserializer_shift;
    logic parity_check;
    logic parity_error_internal;   // من rx_parity → داخل للـ controller
    logic [DATA_W-1:0] rx_data;
    logic valid_raw;
    logic stop_check;
    logic frame_err_raw;           // خارج من الـ controller بس
    logic parity_err_raw;          // خارج من الـ controller بس

    Main_Controller_rX #(.P(DATA_W)) Controller (
        .Serial_In(i_rx),
        .clk(i_clk),
        .rst(i_rst_n),
        .Parity_Enable(i_par_en),
        .Parity_Error_In(parity_error_internal),
        .Busy(o_busy),
        .Frame_Error(frame_err_raw),
        .Valid(valid_raw),
        .Parity_Error_Out(parity_err_raw),
        .Deserializer_Shift(deserializer_shift),
        .Parity_Check(parity_check),
        .Stop_Check(stop_check)
    );

    rx_sampler #(.n(DATA_W)) Serializer (
        .CLK(i_clk),
        .RSTN(i_rst_n),
        .shift(deserializer_shift),
        .RX_IN(i_rx),
        .P_DATA(rx_data)
    );

    assign o_data = rx_data;

    rx_parity Parity_Checker (
        .P_DATA(rx_data),
        .RX_IN(i_rx),
        .PAR_EN(i_par_en),
        .PAR_TYP(i_par_odd),
        .parity_check(parity_check),
        .PARITY_ERROR(parity_error_internal)   // مش parity_err_raw
    );

    // امسح السطر ده تمامًا:
    // assign frame_err_raw = stop_check && (i_rx != 1'b1);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            o_valid      <= 1'b0;
            o_parity_err <= 1'b0;
            o_frame_err  <= 1'b0;
        end else begin
            o_valid <= valid_raw;
            if (valid_raw) begin
                o_parity_err <= parity_err_raw;
                o_frame_err  <= frame_err_raw;
            end
        end
    end

endmodule