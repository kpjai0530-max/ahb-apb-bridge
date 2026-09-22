# AHB-to-APB Bridge RTL Design

Verilog HDL implementation of an AHB-to-APB bridge developed as the capstone project for my VLSI Design Internship at Maven Silicon.

## Overview

This project implements an RTL bridge between the AMBA AHB (Advanced High-performance Bus) and APB (Advanced Peripheral Bus) protocols.

The bridge receives AHB transactions, processes the address and control information, converts them into corresponding APB transfers, and returns the APB response/data to the AHB side.

### Main Components

- AHB Slave Interface – captures AHB address, data, and control signals and performs address decoding.
- APB Controller – FSM-based controller responsible for sequencing APB transfers and generating control signals.
- APB Interface – handles the APB-side address, data, and control signals.
- AHB Master & Testbench – generate AHB transactions for simulation and validation.

## Architecture

AHB
 |
 v
AHB Slave Interface
 |
 v
APB Controller (FSM)
 |
 v
APB Interface
 |
 v
APB

## Address Mapping

The AHB slave interface performs address decoding to select APB peripherals.

| Address Range | Peripheral Select |
|---------------|-------------------|
| 0x8000_0000 – 0x8000_03FF | PSEL[0] |
| 0x8000_0400 – 0x8000_07FF | PSEL[1] |
| 0x8000_0800 – 0x8000_0BFF | PSEL[2] |

## APB Controller

The APB controller uses a finite state machine to convert AHB transactions into APB transfers.

It generates and controls signals including:

- PSEL
- PENABLE
- PWRITE
- PADDR
- PWDATA

The controller handles the sequencing of APB read and write transactions.

## Simulation & Validation

The design was simulated using ModelSim.

The following transaction types were tested:

- Single write
- Single read
- Burst write
- Burst read

Waveforms were analyzed to observe AHB and APB signals and confirm the expected transaction behavior.

## Synthesis

The RTL was synthesized using Intel Quartus Prime to confirm that the design could successfully pass through an RTL synthesis flow.

## Tools & Technologies

- HDL: Verilog
- Simulation: ModelSim
- Synthesis: Intel Quartus Prime
- Protocols: AMBA AHB, AMBA APB
- Concepts: RTL Design, FSMs, Address Decoding, Bus Protocol Conversion

## Repository Structure

ahb-apb-bridge/
|
├── README.md
|
├── rtl/
|   ├── AHB_slave_interface.v
|   ├── apb_Controller.v
|   ├── apb_interface.v
|   └── bridge_top.v
|
├── testbench/
|   ├── ahb_master.v
|   ├── AHB_APB_bridge_top_tb.v
|   └── ahb_to_apb.v
|
└── docs/
    ├── architecture.png
    ├── simulation_waveform.png
    └── synthesis_result.png

## Key Learning Outcomes

- AMBA AHB and APB protocol fundamentals
- Verilog RTL design
- FSM-based control logic
- Bus protocol conversion
- Address decoding
- RTL simulation and waveform analysis
- RTL synthesis

## Future Improvements

- SystemVerilog-based verification
- Assertions and functional coverage
- More extensive corner-case testing
- Detailed synthesis timing and resource analysis
