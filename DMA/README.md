# High-Speed DMA Controller

A SystemVerilog-based Direct Memory Access (DMA) controller designed to transfer a block of data from a source address to a destination address with minimal CPU involvement.

## Features

* 32-bit source address
* 32-bit destination address
* 16-bit transfer length
* Start control
* Busy status
* Done status
* Single-word transfer per clock cycle
* Simple finite state machine
* Synthesizable SystemVerilog RTL
* Testbench with expected simulation output

## Project Structure

```text
high-speed-dma-controller/
├── README.md
├── rtl/
│   └── dma_controller.sv
├── testbench/
│   └── dma_controller_tb.sv
└── output/
    └── expected_output.txt
```

## Working Principle

The DMA controller receives a source address, destination address, and transfer length.

When `start` is asserted, the controller enters the transfer state and copies one data word from the source memory interface to the destination memory interface on each clock cycle.

After all requested words are transferred, the `done` signal is asserted.

## Interface

| Signal         | Width | Description                  |
| -------------- | ----: | ---------------------------- |
| `clk`          |     1 | System clock                 |
| `rst`          |     1 | Active-high reset            |
| `start`        |     1 | Starts DMA transfer          |
| `src_addr`     |    32 | Source starting address      |
| `dst_addr`     |    32 | Destination starting address |
| `transfer_len` |    16 | Number of words to transfer  |
| `src_data`     |    32 | Data read from source        |
| `dst_data`     |    32 | Data written to destination  |
| `src_read`     |     1 | Source read request          |
| `dst_write`    |     1 | Destination write request    |
| `busy`         |     1 | DMA transfer in progress     |
| `done`         |     1 | Transfer completed           |

## DMA Operation

```text
CPU
 |
 | Start DMA
 v
+-------------------+
| DMA Controller    |
+-------------------+
     |         |
     | Read    | Write
     v         v
 Source      Destination
 Memory       Memory
```

For every transfer:

```text
Source Address  -> Read Data -> Destination
       |                            |
       +---- Address Increment -----+
```

Both source and destination addresses are incremented by 4 bytes after each 32-bit word transfer.

## State Machine

The controller uses three states:

```text
IDLE
  |
  | start
  v
TRANSFER
  |
  | transfer complete
  v
DONE
  |
  v
IDLE
```

## Example

If:

```text
Source Address  = 0x00001000
Destination     = 0x00002000
Transfer Length = 4
```

The controller performs:

```text
0x00001000 -> 0x00002000
0x00001004 -> 0x00002004
0x00001008 -> 0x00002008
0x0000100C -> 0x0000200C
```

## Simulation

Using Icarus Verilog:

```bash
iverilog -g2012 -o dma_sim rtl/dma_controller.sv testbench/dma_controller_tb.sv
vvp dma_sim
```

## Expected Result

The testbench verifies that:

* DMA starts correctly.
* The busy signal becomes active.
* Source and destination addresses increment correctly.
* Data is transferred for the requested number of words.
* The done signal becomes active after completion.

## Applications

* Memory-to-memory data transfer
* FPGA systems
* Processor peripherals
* High-speed data acquisition
* Networking hardware
* Multimedia systems
* Embedded systems

## Author

Created as a SystemVerilog digital hardware design project.
