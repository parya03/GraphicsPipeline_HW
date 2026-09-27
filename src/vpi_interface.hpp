#pragma once

#include <vpi_user.h>

#include <cstdint>

namespace graphics_pipeline {

enum class LoadTarget : std::uint8_t {
    VectorB = 0b0000,
    Scalar = 0b1000,
};

enum class FpuOperation : std::uint8_t {
    Add = 0b00,
    Subtract = 0b01,
    Multiply = 0b10,
    Divide = 0b11,
};

enum class FpuIn1Route : std::uint8_t {
    Scalar = 0b00000,
};

enum class FpuIn2Route : std::uint8_t {
    Scalar = 0b0000,
    VectorB0 = 0b0100,
};

class TeuVpiInterface {
public:
    bool bind(const char* scope_name);

    void set_clock(bool value) const;
    void set_reset(bool value) const;
    void clear_micro_operations() const;

    void drive_bus(std::uint32_t low_word) const;
    void release_bus() const;
    std::uint32_t read_bus_low_word() const;

    void load_from_bus(LoadTarget target) const;
    void load_from_fpu(LoadTarget target) const;
    void store_scalar_to_bus() const;
    void configure_fpu(
        FpuOperation operation,
        bool input_strobe,
        bool output_ack,
        FpuIn1Route in1_route,
        FpuIn2Route in2_route,
        bool swap_inputs) const;

    bool fpu_output_strobe() const;

private:
    bool bind_signal(vpiHandle& signal, const char* scope_name, const char* signal_name);

    vpiHandle en_load_ = nullptr;
    vpiHandle load_src_ = nullptr;
    vpiHandle load_target_ = nullptr;
    vpiHandle en_bus_ = nullptr;
    vpiHandle bus_target_ = nullptr;
    vpiHandle fpu_operation_ = nullptr;
    vpiHandle fpu_input_stb_ = nullptr;
    vpiHandle fpu_output_ack_ = nullptr;
    vpiHandle fpu_in1_routing_ = nullptr;
    vpiHandle fpu_in2_routing_ = nullptr;
    vpiHandle fpu_input_switch_ = nullptr;
    vpiHandle fpu_out_routing_ = nullptr;
    vpiHandle clk_ = nullptr;
    vpiHandle reset_ = nullptr;
    vpiHandle fpu_output_stb_ = nullptr;
    vpiHandle bus_drive_ = nullptr;
    vpiHandle bus_drive_enable_ = nullptr;
    vpiHandle bus_ = nullptr;
};

} // namespace graphics_pipeline
