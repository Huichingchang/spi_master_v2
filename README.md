# SPI Master V2 - Verilog Implementation

## 📦 Project Overview

This project implements a Verilog-based **SPI Master Controller** supporting:

- Multi-byte transmission
- Configurable chip-select (CS) for up to 4 slave devices
- Clean FSM-based architecture ready for feature extension

This version is fully verified via ModelSim simulation and is suitable for learning, verification, or use in digital system design portfolios.

---

## 🔧 Key Features

- ✅ Supports both single-byte and multi-byte transfers
- ✅ Master generates SCLK and MOSI signals
- ✅ Selectable chip-select line via `cs_sel`
- ✅ `busy` and `done` handshake interface
- ✅ Fully testbench-driven and simulation verified

---

## 🧱 RTL Block Diagram

<img src="doc/RTL_spi_master_v2_basic_multi_byte.png" alt="RTL Block Diagram" width="600">

---

## 📈 Simulation Waveform

<img src="doc/wave_spi_master_v2_basic_multi_byte.png" alt="Simulation Waveform" width="600">

### Description:

- Transmitted sequence: `0xA5 → 0x3C → 0x7E`
- `data_out` result: `0x80` due to all-zero MISO input
- `done` goes high after the last byte is shifted
- `cs_n = 4'b1101` → CS1 is active low throughout transmission

---

## 🧪 Simulation Setup

- **Tool**: ModelSim Intel FPGA Edition 10.5b
- **Files**: `spi_master_v2.v`, `spi_master_v2_tb.v`
- **Test behavior**:
  - System reset applied
  - Injected 3 bytes via `data_in`
  - Monitored outputs: `mosi`, `sclk`, `cs_n`, `data_out`, `done`

---

## 📁 Directory Structure
spi_master_v2_project/
├── doc/
│   ├── RTL_spi_master_v2_basic_multi_byte.png
│   └── wave_spi_master_v2_basic_multi_byte.png
├── src/
├── tb/
└── README.md


