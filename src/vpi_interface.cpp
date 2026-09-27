#include "vpi_interface.hpp"

#include <cstdio>

namespace graphics_pipeline {
namespace {

void write_value(vpiHandle signal, std::uint32_t value)
{
    s_vpi_value signal_value {};
    signal_value.format = vpiIntVal;
    signal_value.value.integer = static_cast<PLI_INT32>(value);
    vpi_put_value(signal, &signal_value, nullptr, vpiNoDelay);
}

std::uint32_t read_value(vpiHandle signal)
{
    s_vpi_value signal_value {};
    signal_value.format = vpiIntVal;
    vpi_get_value(signal, &signal_value);
    return static_cast<std::uint32_t>(signal_value.value.integer);
}

} // namespace

bool TeuVpiInterface::bind_signal(
    vpiHandle& signal,
    const char* scope_name,
    const char* signal_name)
{
    char path[128] {};
    std::snprintf(path, sizeof(path), "%s.%s", scope_name, signal_name);
    signal = vpi_handle_by_name(path, nullptr);
    return signal != nullptr;
}

bool TeuVpiInterface::bind(const char* scope_name)
{
    return bind_signal(en_load_, scope_name, "en_load")
        && bind_signal(load_src_, scope_name, "load_src")
        && bind_signal(load_target_, scope_name, "load_target")
        && bind_signal(en_bus_, scope_name, "en_bus")
        && bind_signal(bus_target_, scope_name, "bus_target")
        && bind_signal(fpu_operation_, scope_name, "fpu_operation")
        && bind_signal(fpu_input_stb_, scope_name, "fpu_input_stb")
        && bind_signal(fpu_output_ack_, scope_name, "fpu_output_ack")
        && bind_signal(fpu_in1_routing_, scope_name, "fpu_in1_routing")
        && bind_signal(fpu_in2_routing_, scope_name, "fpu_in2_routing")
        && bind_signal(fpu_input_switch_, scope_name, "fpu_input_switch")
        && bind_signal(fpu_out_routing_, scope_name, "fpu_out_routing")
        && bind_signal(clk_, scope_name, "clk")
        && bind_signal(reset_, scope_name, "reset")
        && bind_signal(fpu_output_stb_, scope_name, "fpu_output_stb")
        && bind_signal(bus_drive_, scope_name, "bus_drive")
        && bind_signal(bus_drive_enable_, scope_name, "bus_drive_enable")
        && bind_signal(bus_, scope_name, "bus");
}

void TeuVpiInterface::set_clock(bool value) const
{
    write_value(clk_, value);
}

void TeuVpiInterface::set_reset(bool value) const
{
    write_value(reset_, value);
}

void TeuVpiInterface::clear_micro_operations() const
{
    write_value(en_load_, 0);
    write_value(load_src_, 0);
    write_value(load_target_, 0);
    write_value(en_bus_, 0);
    write_value(bus_target_, 0);
    write_value(fpu_operation_, 0);
    write_value(fpu_input_stb_, 0);
    write_value(fpu_output_ack_, 0);
    write_value(fpu_in1_routing_, 0);
    write_value(fpu_in2_routing_, 0);
    write_value(fpu_input_switch_, 0);
    write_value(fpu_out_routing_, 0);
}

void TeuVpiInterface::drive_bus(std::uint32_t low_word) const
{
    s_vpi_vecval bus_value[4] {};
    bus_value[0].aval = low_word;

    s_vpi_value value {};
    value.format = vpiVectorVal;
    value.value.vector = bus_value;
    vpi_put_value(bus_drive_, &value, nullptr, vpiNoDelay);
    write_value(bus_drive_enable_, 1);
}

void TeuVpiInterface::release_bus() const
{
    write_value(bus_drive_enable_, 0);
}

std::uint32_t TeuVpiInterface::read_bus_low_word() const
{
    return read_value(bus_);
}

void TeuVpiInterface::load_from_bus(LoadTarget target) const
{
    write_value(en_load_, 1);
    write_value(load_src_, 0);
    write_value(load_target_, static_cast<std::uint32_t>(target));
}

void TeuVpiInterface::load_from_fpu(LoadTarget target) const
{
    write_value(en_load_, 1);
    write_value(load_src_, 1);
    write_value(load_target_, static_cast<std::uint32_t>(target));
}

void TeuVpiInterface::store_scalar_to_bus() const
{
    write_value(en_bus_, 1);
    write_value(bus_target_, 1);
}

void TeuVpiInterface::configure_fpu(
    FpuOperation operation,
    bool input_strobe,
    bool output_ack,
    FpuIn1Route in1_route,
    FpuIn2Route in2_route,
    bool swap_inputs) const
{
    write_value(fpu_operation_, static_cast<std::uint32_t>(operation));
    write_value(fpu_input_stb_, input_strobe);
    write_value(fpu_output_ack_, output_ack);
    write_value(fpu_in1_routing_, static_cast<std::uint32_t>(in1_route));
    write_value(fpu_in2_routing_, static_cast<std::uint32_t>(in2_route));
    write_value(fpu_input_switch_, swap_inputs);
}

bool TeuVpiInterface::fpu_output_strobe() const
{
    return read_value(fpu_output_stb_) != 0;
}

} // namespace graphics_pipeline
