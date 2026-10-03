# TinyCore-X — 16-bit RISC FPGA Processor

TinyCore-X is a custom 16-bit multicycle RISC-style processor implemented in SystemVerilog and developed in Xilinx Vivado.

The project explores architectural acceleration for DSP-oriented workloads through two custom hardware features:

- Multiply-Accumulate (`MAC`) instruction
- Zero-overhead hardware loop controller (`LOOP`)

The processor was designed, verified through self-checking SystemVerilog testbenches, synthesized, implemented, and benchmarked using a dot-product workload.

## Key Features

- 16-bit datapath
- 16-bit fixed-width instruction format
- 5-bit opcode
- 8 general-purpose 16-bit registers
- Multicycle FSM-based control unit
- Harvard-style instruction and data memories
- Signed two's-complement arithmetic
- ALU status flags: Zero, Negative, Carry, Overflow
- Dedicated multiplication hardware
- Custom MAC instruction
- Zero-overhead hardware loop
- PC-relative branches and jumps
- SystemVerilog implementation
- Vivado synthesis and timing analysis

## Architecture

The processor contains the following main blocks:

- Program Counter
- Instruction Memory
- Instruction Register
- Instruction Decoder
- Control Unit
- Register File
- Arithmetic Logic Unit
- Flags Register
- Multiplier
- MAC Unit
- Data Memory
- Hardware Loop Controller
- Writeback Multiplexer
- Next-PC Control Logic

The processor uses a multicycle architecture. Most instructions execute using:

```text
FETCH → DECODE → EXECUTE
```

The MAC instruction uses an additional cycle because the register file contains two read ports while MAC requires three operands:

```text
FETCH → DECODE → MAC_READ → MAC_EXEC
```

## Instruction Set

| Opcode | Instruction |
|---|---|
| `00000` | NOP |
| `00001` | MOVI |
| `00010` | MOV |
| `00011` | ADD |
| `00100` | SUB |
| `00101` | AND |
| `00110` | OR |
| `00111` | XOR |
| `01000` | MUL |
| `01001` | LOAD |
| `01010` | STORE |
| `01011` | JMP |
| `01100` | BEQ |
| `01101` | LOOP |
| `01110` | MAC |
| `01111` | SHL |
| `10000` | SHR |
| `10001` | SAR |
| `10010` | ROL |
| `10011` | ROR |
| `10100` | RCL |
| `10101` | RCR |
| `10110` | HALT |

## Instruction Formats

### Register-Register

```text
15          11 10       8 7        5 4        2 1   0
+-------------+-----------+----------+----------+-----+
|   opcode    |    Rd     |   Rs1    |   Rs2    | 00  |
+-------------+-----------+----------+----------+-----+
```

### MOVI

```text
15          11 10       8 7                     0
+-------------+-----------+-----------------------+
|   opcode    |    Rd     |         imm8          |
+-------------+-----------+-----------------------+
```

### LOAD / STORE / BEQ

```text
15          11 10       8 7        5 4            0
+-------------+-----------+----------+--------------+
|   opcode    |  field1   |  field2  | signed imm5  |
+-------------+-----------+----------+--------------+
```

### LOOP

```text
15          11 10       8 7                     0
+-------------+-----------+-----------------------+
|   opcode    |    Rc     |      body_length      |
+-------------+-----------+-----------------------+
```

## ALU Operations

The ALU supports:

- Addition
- Subtraction
- AND
- OR
- XOR
- Logical shift left
- Logical shift right
- Arithmetic shift right
- Rotate left
- Rotate right
- Rotate through carry left
- Rotate through carry right

The processor maintains four status flags:

```text
Z - Zero
N - Negative
C - Carry
V - Overflow
```

## MAC Acceleration

The custom MAC instruction performs:

```text
Rd = Rd + Rs1 * Rs2
```

Instead of executing:

```asm
MUL
ADD
```

the processor can execute a single MAC instruction.

Because the register file has two read ports, MAC uses two execution states:

```text
MAC_READ
MAC_EXEC
```

## Zero-Overhead Hardware Loop

TinyCore-X includes a dedicated hardware loop controller.

A `LOOP` instruction configures:

- loop start address
- loop end address
- iteration count

When the final instruction in the loop body completes, the loop controller redirects the PC automatically without executing explicit decrement or branch instructions.

This removes software loop-control overhead from repeated DSP workloads.

## Verification

Individual SystemVerilog testbenches were developed for:

- ALU
- Register File
- Program Counter
- Instruction Decoder
- Instruction Memory
- Data Memory
- Flags Register
- Multiplier
- MAC Unit
- Hardware Loop Controller
- Control Unit

The integrated processor was also tested with programs exercising:

- MOVI
- ADD
- MUL
- MAC
- LOAD
- STORE
- SHL
- Hardware LOOP
- HALT

## Dot-Product Benchmark

The optimization was evaluated using:

```text
A = [2, 3, 4, 5]
B = [1, 2, 3, 4]
```

The expected result is:

```text
2*1 + 3*2 + 4*3 + 5*4 = 40
```

Three implementations were compared.

| Implementation | Cycles | Speedup |
|---|---:|---:|
| MUL + ADD + software loop | 123 | 1.000x |
| MAC + software loop | 115 | 1.070x |
| MAC + hardware LOOP | 85 | 1.447x |

The fully optimized implementation reduced execution from:

```text
123 cycles → 85 cycles
```

corresponding to a:

**30.9% reduction in clock cycles**

and a:

**1.447x speedup**

over the baseline implementation.

## FPGA Synthesis Results

Vivado synthesis reported:

| Resource | Usage |
|---|---:|
| LUTs | 447 |
| Registers | 225 |
| DSP blocks | 2 |

The two DSP resources are used by the multiplier and MAC datapaths.

The hardware loop controller requires relatively little additional hardware while significantly reducing software loop overhead.

Resource measurements were obtained with hierarchy preservation enabled so that the complete processor architecture remained present during synthesis.

## Timing

Timing closure was achieved using an:

```text
11 ns clock period
```

corresponding to approximately:

```text
90.9 MHz
```

At this clock frequency:

| Implementation | Execution Time |
|---|---:|
| Baseline | 1.353 us |
| MAC | 1.265 us |
| MAC + LOOP | 0.935 us |

## Tools

- SystemVerilog
- Xilinx Vivado 2020.2
- Vivado Simulator
- Git
- GitHub

## Project Structure

```text
TinyCoreX.srcs/
├── sources_1/
│   └── new/
│       ├── alu.sv
│       ├── control_unit.sv
│       ├── data_memory.sv
│       ├── flags_register.sv
│       ├── instruction_decoder.sv
│       ├── instruction_memory.sv
│       ├── loop_controller.sv
│       ├── mac_unit.sv
│       ├── multiplier.sv
│       ├── program_counter.sv
│       ├── register_file.sv
│       └── tinycore.sv
│
├── sim_1/
│   └── new/
│       ├── alu_tb.sv
│       ├── control_unit_tb.sv
│       ├── data_memory_tb.sv
│       ├── flags_register_tb.sv
│       ├── instruction_decoder_tb.sv
│       ├── instruction_memory_tb.sv
│       ├── loop_controller_tb.sv
│       ├── mac_unit_tb.sv
│       ├── multiplier_tb.sv
│       ├── program_counter_tb.sv
│       ├── register_file_tb.sv
│       ├── tinycore_tb.sv
│       └── tinycore_benchmark_tb.sv
│
└── constrs_1/
    └── new/
        └── tinycore_const.xdc
```

## Future Improvements

Possible future improvements include:

- Pipelined execution
- Three-port register file for single-cycle MAC operand access
- Improved branch handling
- Expanded instruction set
- Interrupt support
- BRAM-based memories
- Configurable processor parameters
- Further critical-path optimization

## Author

**Dita Paul Costin**

Electronics, Telecommunications and Information Technology student  
National University of Science and Technology POLITEHNICA Bucharest

Interested in FPGA development, digital hardware design, processor architecture and digital verification.