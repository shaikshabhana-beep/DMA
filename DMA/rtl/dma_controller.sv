module dma_controller (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,

    input  logic [31:0] src_addr,
    input  logic [31:0] dst_addr,
    input  logic [15:0] transfer_len,

    input  logic [31:0] src_data,

    output logic [31:0] src_read_addr,
    output logic [31:0] dst_write_addr,
    output logic [31:0] dst_data,

    output logic        src_read,
    output logic        dst_write,

    output logic        busy,
    output logic        done
);

    typedef enum logic [1:0] {
        IDLE,
        TRANSFER,
        DONE
    } state_t;

    state_t state;

    logic [31:0] current_src_addr;
    logic [31:0] current_dst_addr;
    logic [15:0] remaining_count;

    always_ff @(posedge clk) begin

        if (rst) begin
            state             <= IDLE;
            current_src_addr  <= 32'h0;
            current_dst_addr  <= 32'h0;
            remaining_count   <= 16'h0;

            src_read_addr     <= 32'h0;
            dst_write_addr    <= 32'h0;
            dst_data          <= 32'h0;

            src_read          <= 1'b0;
            dst_write         <= 1'b0;
            busy              <= 1'b0;
            done              <= 1'b0;
        end

        else begin

            // Default control signals
            src_read  <= 1'b0;
            dst_write <= 1'b0;
            done      <= 1'b0;

            case (state)

                IDLE: begin
                    busy <= 1'b0;

                    if (start && (transfer_len != 0)) begin

                        current_src_addr <= src_addr;
                        current_dst_addr <= dst_addr;
                        remaining_count  <= transfer_len;

                        busy  <= 1'b1;
                        state <= TRANSFER;
                    end
                end

                TRANSFER: begin

                    busy <= 1'b1;

                    // Read from source
                    src_read      <= 1'b1;
                    src_read_addr <= current_src_addr;

                    // Write to destination
                    dst_write      <= 1'b1;
                    dst_write_addr <= current_dst_addr;
                    dst_data       <= src_data;

                    // Increment addresses
                    current_src_addr <= current_src_addr + 32'd4;
                    current_dst_addr <= current_dst_addr + 32'd4;

                    if (remaining_count == 16'd1) begin
                        remaining_count <= 16'd0;
                        state <= DONE;
                    end
                    else begin
                        remaining_count <= remaining_count - 16'd1;
                    end
                end

                DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;

                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                    busy  <= 1'b0;
                    done  <= 1'b0;
                end

            endcase
        end
    end

endmodule