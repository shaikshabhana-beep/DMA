`timescale 1ns/1ps

module dma_controller_tb;

    logic        clk;
    logic        rst;
    logic        start;

    logic [31:0] src_addr;
    logic [31:0] dst_addr;
    logic [15:0] transfer_len;

    logic [31:0] src_data;

    logic [31:0] src_read_addr;
    logic [31:0] dst_write_addr;
    logic [31:0] dst_data;

    logic        src_read;
    logic        dst_write;

    logic        busy;
    logic        done;

    // DUT
    dma_controller DUT (
        .clk             (clk),
        .rst             (rst),
        .start           (start),
        .src_addr        (src_addr),
        .dst_addr        (dst_addr),
        .transfer_len    (transfer_len),
        .src_data        (src_data),
        .src_read_addr   (src_read_addr),
        .dst_write_addr  (dst_write_addr),
        .dst_data        (dst_data),
        .src_read        (src_read),
        .dst_write       (dst_write),
        .busy            (busy),
        .done            (done)
    );

    // Clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Simple source memory model
    always_comb begin
        case (src_read_addr)

            32'h00001000:
                src_data = 32'hAAAA0001;

            32'h00001004:
                src_data = 32'hBBBB0002;

            32'h00001008:
                src_data = 32'hCCCC0003;

            32'h0000100C:
                src_data = 32'hDDDD0004;

            default:
                src_data = 32'h00000000;

        endcase
    end

    initial begin

        $display("============================================");
        $display("       HIGH-SPEED DMA CONTROLLER TEST");
        $display("============================================");

        // Initial values
        rst         = 1'b1;
        start       = 1'b0;
        src_addr    = 32'h00001000;
        dst_addr    = 32'h00002000;
        transfer_len = 16'd4;

        #12;

        rst = 1'b0;

        // Start DMA
        @(negedge clk);
        start = 1'b1;

        @(negedge clk);
        start = 1'b0;

        // Monitor transfer
        repeat (4) begin

            @(posedge clk);
            #1;

            $display(
                "SRC = 0x%08h | DST = 0x%08h | DATA = 0x%08h | READ = %b | WRITE = %b | BUSY = %b",
                src_read_addr,
                dst_write_addr,
                dst_data,
                src_read,
                dst_write,
                busy
            );

        end

        // Wait for completion
        @(posedge clk);
        #1;

        $display(
            "DMA DONE = %b | BUSY = %b",
            done,
            busy
        );

        #10;

        $display("============================================");
        $display("        DMA SIMULATION COMPLETED");
        $display("============================================");

        $finish;

    end

endmodule