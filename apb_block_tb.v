`timescale 1ns/1ps

module tb_apb_dma_config;

    reg pclk;
    reg presetn;

    reg psel;
    reg penable;
    reg pwrite;
    reg [7:0] paddr;
    reg [31:0] pwdata;
    wire [31:0] prdata;

    wire dma_start;
    wire [31:0] dst_addr;
    wire [15:0] transfer_size;
    reg dma_done;

    // DUT
    apb_dma_config dut (
        .pclk(pclk),
        .presetn(presetn),
        .psel(psel),
        .penable(penable),
        .pwrite(pwrite),
        .paddr(paddr),
        .pwdata(pwdata),
        .prdata(prdata),
        .dma_start(dma_start),
        .dst_addr(dst_addr),
        .transfer_size(transfer_size),
        .dma_done(dma_done)
    );

    // Clock generation
    always #5 pclk = ~pclk;

    // Waveform dump
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_apb_dma_config);
    end

    // APB Write Task
    task apb_write(input [7:0] addr, input [31:0] data);
    begin
        @(posedge pclk);
        psel = 1;
        pwrite = 1;
        paddr = addr;
        pwdata = data;
        penable = 0;

        @(posedge pclk);
        penable = 1;

        @(posedge pclk);
        psel = 0;
        penable = 0;
    end
    endtask

    // APB Read Task
    task apb_read(input [7:0] addr);
    begin
        @(posedge pclk);
        psel = 1;
        pwrite = 0;
        paddr = addr;
        penable = 0;

        @(posedge pclk);
        penable = 1;

        @(posedge pclk);
        $display("READ ADDR %h DATA = %h", addr, prdata);

        psel = 0;
        penable = 0;
    end
    endtask

    initial begin
        $display("Starting APB DMA CONFIG TEST");

        pclk = 0;
        presetn = 0;
        psel = 0;
        penable = 0;
        pwrite = 0;
        paddr = 0;
        pwdata = 0;
        dma_done = 0;

        // Reset
        #20;
        presetn = 1;

        // Write destination address
        apb_write(8'h04, 32'h8000_0000);

        // Write transfer size
        apb_write(8'h08, 32'd256);

        // Start DMA
        apb_write(8'h00, 32'h1);

        #10;
        if (dma_start)
            $display("DMA START TRIGGERED ✔");

        // Read back registers
        apb_read(8'h04);
        apb_read(8'h08);

        // DMA completion
        #20;
        dma_done = 1;
        #10;
        dma_done = 0;

        apb_read(8'h0C);

        #50;
        $display("TEST COMPLETED SUCCESSFULLY");
        $finish;
    end

endmodule