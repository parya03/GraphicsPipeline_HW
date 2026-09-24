# ============================================================================
# Configuration
# ============================================================================

TARGET := sim

CXX       := clang++
VERILATOR := verilator
GTKWAVE   := gtkwave

BUILD_DIR := build
RTL_DIR   := rtl
SRC_DIR   := src

TOP := top

WAVE_FILE := $(BUILD_DIR)/wave.fst


# ============================================================================
# Sources
# ============================================================================

RTL_SRCS := \
	$(RTL_DIR)/top.sv

CPP_SRCS := \
	$(SRC_DIR)/main.cpp

RTL_SRCS_ABS := $(abspath $(RTL_SRCS))
CPP_SRCS_ABS := $(abspath $(CPP_SRCS))


# ============================================================================
# Compiler flags
# ============================================================================

CXXFLAGS := \
	-std=c++20 \
	-Wall \
	-Wextra \
	-Wpedantic \
	-O2 \
	-g

INCLUDES := \
	-I$(abspath src) \
	-I$(abspath include)

	


# ============================================================================
# Verilator flags
# ============================================================================

VERILATOR_FLAGS := \
	--cc \
	--exe \
	--build \
	--sv \
	--trace-fst \
	--top-module $(TOP) \
	--Mdir $(BUILD_DIR)/verilator \
	-CFLAGS "$(CXXFLAGS) $(INCLUDES)" \
	-Wall


# ============================================================================
# Default target
# ============================================================================

.PHONY: all
all: $(TARGET)


# ============================================================================
# Build simulation
# ============================================================================

$(TARGET): $(RTL_SRCS) $(CPP_SRCS)
	@mkdir -p $(BUILD_DIR)

	$(VERILATOR) \
		$(VERILATOR_FLAGS) \
		$(RTL_SRCS_ABS) \
		$(CPP_SRCS_ABS) \
		-o $(TARGET)

	@cp $(BUILD_DIR)/verilator/$(TARGET) $@


# ============================================================================
# Run simulation
# ============================================================================

.PHONY: run
run: $(TARGET)
	./$(TARGET)


# ============================================================================
# Generate FST waveform
# ============================================================================

.PHONY: wave
wave: $(TARGET)
	@mkdir -p $(BUILD_DIR)
	./$(TARGET)
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
	rm -rf $(BUILD_DIR) $(TARGET)


.PHONY: rebuild
rebuild: clean all


# ============================================================================
# Debug build
# ============================================================================

.PHONY: debug
debug:
	$(MAKE) clean
	$(MAKE) \
		CXXFLAGS="-std=c++20 -Wall -Wextra -Wpedantic -O0 -g" \
		all


# ============================================================================
# Help
# ============================================================================

.PHONY: help
help:
	@echo "Targets:"
	@echo "  make          Build simulation"
	@echo "  make run      Build simulation and run"
	@echo "  make wave     Run simulation and generate FST waveform"
	@echo "  make waves    Generate FST waveform and open GTKWave"
	@echo "  make clean    Remove build artifacts"
	@echo "  make rebuild  Clean and rebuild"
	@echo "  make debug    Build with debug flags"
	@echo "  make help     Show this help"
