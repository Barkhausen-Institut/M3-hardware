# M³ Hardware

This repository contains the hardware RTL code of the M³ operating system [1].
Currently, only the following components are included:
- Network-on-chip: set up as a star-mesh topology with 4 routers
- Trusted Communication Unit (TCU) [2]

## Repository structure

The source code is distributed into several "units", while each unit can contain source code, constraints for synthesis, scripts, and testbenches. The directory "global_src" contains header files used by multiple units.

## Supported platforms

In general, this RTL code targets both FPGA and ASIC implementations. Specific blocks (e.g. memory, clock generators) must be replaced accordingly by using the define "FPGA_COMPILE".

Later, scripts to simulate and synthesize the RTL code for a selected FPGA will be added.


## Getting started

Currently, the repository only contains hardware RTL code. Simulation and synthesis scripts will be added later.


# References

[1] Microkernel-based system for heterogeneous manycores: https://github.com/Barkhausen-Institut/M3

[2] Specification of Trusted Communication Unit: https://github.com/Barkhausen-Institut/TCU-if

