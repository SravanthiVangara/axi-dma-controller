
`timescale 1ns/1ps

module tb_dma_top;

reg clk;
reg rst;
reg dma_start;

reg AWREADY;
reg WREADY;
reg BVALID;

reg [31:0] adc_data;

wire dma_interrupt;

// DUT
dma_top dut (
    .clk(clk),
    .rst(rst),
    .dma_start(dma_start),
    .AWREADY(AWREADY),
    .WREADY(WREADY),
    .BVALID(BVALID),
    .adc_data(adc_data),
    .dma_interrupt(dma_interrupt)
);

// Clock
always #5 clk = ~clk;

// Generate ADC data stream
always @(posedge clk) begin
    adc_data <= $random;
end

//-------------------------------------
// AXI behavior model
//-------------------------------------
initial begin
    AWREADY = 0;
    WREADY  = 0;
    BVALID  = 0;

    forever begin
        #20 AWREADY = 1;
        #10 AWREADY = 0;

        #20 WREADY = 1;
        #10 WREADY = 0;

        #20 BVALID = 1;
        #10 BVALID = 0;
    end
end

//-------------------------------------
// Test sequence
//-------------------------------------
initial begin
    $dumpfile("dma_wave.vcd");
    $dumpvars(0, tb_dma_top);

    clk = 0;
    rst = 1;
    dma_start = 0;
    adc_data = 0;

    #20 rst = 0;

    //---------------------------------
    // TEST 1: Single DMA Start
    //---------------------------------
    #20;
    dma_start = 1;
    #10;
    dma_start = 0;

    //---------------------------------
    // TEST 2: Continuous data transfer
    //---------------------------------
    #200;

    //---------------------------------
    // TEST 3: Multiple DMA triggers
    //---------------------------------
    repeat(3) begin
        #100;
        dma_start = 1;
        #10 dma_start = 0;
    end

    //---------------------------------
    // Finish
    //---------------------------------
    #500;
    $finish;
end

endmodule