include ../../../../Makefile.local

.PHONY: clean
clean:
	rm -rf logfiles results reports $(VIVADO_SYNTH_DIR) .cache .Xil


.PHONY: backup
backup:
	rm -rf backup
	mkdir -p backup
	cp -r logfiles backup/logfiles
	cp -r results backup/results
	cp -r reports backup/reports


#Synthesis
.PHONY: synth
synth: scripts/synth.tcl ../../source/fpga_files.tcl
	mkdir -p ip_proj
	mkdir -p logfiles
	mkdir -p results
	mkdir -p reports
	mkdir -p $(VIVADO_SYNTH_DIR)
	vivado -tempDir $(VIVADO_SYNTH_DIR) -mode batch -journal logfiles/synth.jou -log logfiles/synth.log -source scripts/synth.tcl


#Implementation
.PHONY: impl
impl: results/synth.dcp scripts/impl.tcl
	vivado -tempDir $(VIVADO_SYNTH_DIR) -mode batch -journal logfiles/impl.jou -log logfiles/impl.log -source scripts/impl.tcl


#bit file generation
.PHONY: bit
bit: results/impl.dcp scripts/bit.tcl
	vivado -tempDir $(VIVADO_SYNTH_DIR) -mode batch -journal logfiles/bit.jou -log logfiles/bit.log -source scripts/bit.tcl


#synth + impl + bit-gen
.PHONY: all
.SILENT:
all: synth impl bit


