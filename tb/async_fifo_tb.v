`timescale 1ns/1ps

module tb_async_fifo;

parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 4;

reg wr_clk;
reg rd_clk;
reg wr_rst;
reg rd_rst;
reg wr_en;
reg rd_en;
reg [DATA_WIDTH-1:0] wr_data;

wire [DATA_WIDTH-1:0] rd_data;
wire full;
wire empty;

async_fifo #(DATA_WIDTH, ADDR_WIDTH) dut (
    .wr_clk(wr_clk),
    .wr_rst(wr_rst),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .full(full),
    .rd_clk(rd_clk),
    .rd_rst(rd_rst),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .empty(empty)
);

// Different clocks (CDC testing)
always #5 wr_clk = ~wr_clk;
always #7 rd_clk = ~rd_clk;

initial begin
    $dumpfile("async_fifo.vcd");
    $dumpvars(0, tb_async_fifo);
end

initial begin
    wr_clk = 0;
    rd_clk = 0;
    wr_rst = 1;
    rd_rst = 1;
    wr_en = 0;
    rd_en = 0;
    wr_data = 0;

    #20;
    wr_rst = 0;
    rd_rst = 0;

    $display("STARTING CDC FIFO TEST");

    // Write data
    repeat(12) begin
        @(posedge wr_clk);
        if (!full) begin
            wr_en = 1;
            wr_data = wr_data + 1;
        end
    end
    wr_en = 0;

    // Read data
    repeat(12) begin
        @(posedge rd_clk);
        if (!empty)
            rd_en = 1;
    end
    rd_en = 0;

    #50;
    $display("FIFO TEST PASSED");
    $finish;
end

endmodule
