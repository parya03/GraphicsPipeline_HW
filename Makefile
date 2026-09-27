# ============================================================================
# Configuration
# ============================================================================

IVERILOG     := iverilog
IVERILOG_VPI := iverilog-vpi
VVP          := vvp
GTKWAVE      := gtkwave

BUILD_DIR := build
RTL_DIR   := rtl
SRC_DIR   := src

SIM_TOP    := sim_top
SIM_IMAGE  := $(BUILD_DIR)/sim.vvp
VPI_MODULE := cpp_test
VPI_FILE   := $(BUILD_DIR)/$(VPI_MODULE).vpi
WAVE_FILE  := $(BUILD_DIR)/wave.vcd


# ============================================================================
# Sources
# ============================================================================

RTL_SRCS := \
	$(RTL_DIR)/top.sv \
	$(RTL_DIR)/teu/teu.sv \
	$(RTL_DIR)/teu/fpu.sv \
	$(RTL_DIR)/fpu/adder/adder.v \
	$(RTL_DIR)/fpu/multiplier/multiplier.v \
	$(RTL_DIR)/fpu/divider/divider.v

TB_SRCS := \
	$(RTL_DIR)/sim_top.sv

VPI_SRCS := \
	$(SRC_DIR)/main.cpp \
	$(SRC_DIR)/vpi_interface.cpp

VPI_SRCS_ABS := $(abspath $(VPI_SRCS))


# ============================================================================
# Icarus Verilog flags
# ============================================================================

IVERILOG_FLAGS := \
	-g2012 \
	-s $(SIM_TOP) \
	-Wall


# ============================================================================
# Default target
# ============================================================================

.PHONY: all
all: $(SIM_IMAGE) $(VPI_FILE)


# ============================================================================
# Build simulation image and C++ VPI module
# ============================================================================

$(SIM_IMAGE): $(RTL_SRCS) $(TB_SRCS)
	@mkdir -p $(BUILD_DIR)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $^

$(VPI_FILE): $(VPI_SRCS)
	@mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && $(IVERILOG_VPI) --name=$(VPI_MODULE) $(VPI_SRCS_ABS)


# ============================================================================
# Run simulation
# ============================================================================

.PHONY: run
run: all
	$(VVP) -M$(abspath $(BUILD_DIR)) -m$(VPI_MODULE) $(SIM_IMAGE)


# ============================================================================
# Generate VCD waveform
# ============================================================================

.PHONY: wave
wave: run
	@echo "Waveform written to $(WAVE_FILE)"


# ============================================================================
# Open waveform in GTKWave
# ============================================================================

.PHONY: waves
waves: wave
	$(GTKWAVE) $(WAVE_FILE)


# ============================================================================
# Clean
# ============================================================================

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)


.PHONY: rebuild
rebuild: clean all


# ============================================================================
# Help
# ============================================================================

.PHONY: help
help:
	@echo "Targets:"
	@echo "  make          Build the Icarus simulation image and C++ VPI module"
	@echo "  make run      Build and run the simulation"
	@echo "  make wave     Run the simulation and generate a VCD waveform"
	@echo "  make waves    Generate a VCD waveform and open GTKWave"
	@echo "  make clean    Remove build artifacts"
	@echo "  make rebuild  Clean and rebuild"
	@echo "  make help     Show this help"
