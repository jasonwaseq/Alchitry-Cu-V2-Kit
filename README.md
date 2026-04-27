# Alchitry Cu V2 Toolkit

This repository is a small Verilog toolkit for the Alchitry Cu V2 FPGA board.
It follows the same Apio-style flow used by existing Cu helper projects, but
targets the Cu V2 hardware and includes a dedicated quarter-second pulse
generator.

The current top-level demo is a hardware sanity test that blinks the first
four LEDs at different rates:

- LED 1: 1 second
- LED 2: 2 seconds
- LED 3: 3 seconds
- LED 4: 4 seconds

The quarter-second pulse generator in `qsec_clks.v` is still validated by the
self-checking testbench in `qsec_clks_tb.v`, which asserts an exact 25,000,000
cycle spacing at the 100 MHz board clock.

Hardware facts used here:

- FPGA: Lattice iCE40HX8K-CB132IC
- Board oscillator: 100 MHz
- Constraint style: PCF `set_io` mappings

The key design goal is `qsec_clks.v`, which emits a one-clock-cycle pulse every
25,000,000 input clocks. With a 100 MHz clock source, that is exactly one
quarter of a second in clock cycles.

## Files

- `qsec_clks.v`: quarter-second pulse generator
- `test.v`: synthesis top level that blinks LED 0 from the quarter-second pulse generator
- `qsec_clks_tb.v`: self-checking testbench
- `alchitry_cu_v2.pcf`: Cu V2 board constraints
- `apio.ini`: Apio board configuration

## Build

There is no Makefile in this repository, so `make bitstream` will fail.

Use Apio for synthesis with the Cu board definition (when Apio is installed):

```text
apio build
```

### Manual bitstream flow (OSS CAD Suite)

Generate a bitstream for `lab 4 rtl/top.v` with:

```text
yosys -p 'read_verilog top.v qsec_clks.v edge_detector.v lfsr.v time_counter.v fsm.v led_shifter.v adder8.v ring_counter.v selector.v hex7seg.v countUD16L.v countUD4L.v; synth_ice40 -top top -json top.json'
nextpnr-ice40 --hx8k --package cb132 --json top.json --pcf alchitry_cu_v2.pcf --asc top.asc
icepack top.asc top.bin

```

Re-run all three commands before flashing. `openFPGALoader` only programs the existing
`top.bin`; it does not rebuild it from your Verilog sources.

Optional programming step:

```text
openFPGALoader -b ice40_generic top.bin
```

For upload, use the normal Alchitry Loader flow or OpenFPGALoader:  openFPGALoader -b ice40_generic test.bin   
path that can reliably access the Cu V2 USB device. In this workspace, WSL
`iceprog` verification was unreliable, while Alchitry Loader flashed the board
correctly.

## Simulation

The testbench is self-checking and runs the divider at a reduced clock rate so
it can complete quickly in simulation while still proving the exact cycle count.

Example with Icarus Verilog:

```text
iverilog -o qsec_clks_tb.out qsec_clks.v qsec_clks_tb.v && vvp qsec_clks_tb.out
```

Equivalent two-step command sequence:

```text
iverilog -g2012 -o qsec_clks_tb.vvp qsec_clks.v qsec_clks_tb.v
vvp qsec_clks_tb.vvp
```

## Board mapping

The constraint file uses the published Cu helper convention for the core board
signals:

- `clk` -> `P7`
- `rst_n` -> `P8`
- `led[0]`..`led[7]` -> `J11`, `K11`, `G12`, `H12`, `K14`, `J12`, `L14`, `K12`

These are the same board pins used by the existing Cu utility examples, so the
toolkit can be used immediately for synthesis and simulation work.
