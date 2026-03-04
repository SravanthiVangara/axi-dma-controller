`timescale 1ns/1ps

module tb_dma_controller;

reg clk;
reg rst;
reg dma_start;
reg fifo_full;
reg fifo_empty;
reg axi_ready;

wire wr_en;
wire rd_en;
wire dma_busy;
wire dma_done;
wire dma_interrupt;

dma_controller dut (
    .clk(clk),
    .rst(rst),
    .dma_start(dma_start),
    .fifo_full(fifo_full),
    .fifo_empty(fifo_empty),
    .axi_ready(axi_ready),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .dma_busy(dma_busy),
    .dma_done(dma_done),
    .dma_interrupt(dma_interrupt)
);

always #5 clk = ~clk;

initial begin
    $dumpfile("dma_controller.vcd");
    $dumpvars(0, tb_dma_controller);
end

initial begin
    clk = 0;
    rst = 1;
    dma_start = 0;
    fifo_full = 0;
    fifo_empty = 1;
    axi_ready = 0;

    #20 rst = 0;

    $display("TEST 1: Normal DMA Flow");

    // Start DMA
    #10 dma_start = 1;
    #10 dma_start = 0;

    // FIFO filling
    #30 fifo_full = 1;

    // Allow sending
    #20 fifo_full = 0;
    fifo_empty = 0;
    axi_ready = 1;

    // FIFO becomes empty
    #50 fifo_empty = 1;

    #30;

    $display("TEST 2: AXI Backpressure");

    // Start again
    #10 dma_start = 1;
    #10 dma_start = 0;

    #30 fifo_full = 1;
    #20 fifo_full = 0;
    fifo_empty = 0;

    // AXI not ready
    axi_ready = 0;
    #40;

    // Now ready
    axi_ready = 1;
    #40 fifo_empty = 1;

    #50;
    $display("DMA TEST COMPLETED");
    $finish;
end

endmodule
