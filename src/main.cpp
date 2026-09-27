#include "vpi_interface.hpp"

#include <cstdint>

namespace {

using graphics_pipeline::FpuIn1Route;
using graphics_pipeline::FpuIn2Route;
using graphics_pipeline::FpuOperation;
using graphics_pipeline::LoadTarget;
using graphics_pipeline::TeuVpiInterface;

constexpr std::uint32_t kHalfPeriod = 5;
constexpr std::uint32_t kResetCycles = 2;
constexpr std::uint32_t kInputStrobeCycles = 5;
constexpr std::uint32_t kFpuTimeoutCycles = 100;
constexpr std::uint32_t kScalarInput = 0x3fc00000; // 1.5f
constexpr std::uint32_t kVectorB0Input = 0x40100000; // 2.25f
constexpr std::uint32_t kExpectedSum = 0x40700000; // 3.75f

enum class TestPhase {
    Reset,
    LoadScalar,
    VerifyScalarStore,
    LoadVectorB,
    StartAddition,
    WaitForAddition,
    LoadFpuResult,
    VerifyResultStore,
};

TeuVpiInterface teu;
TestPhase phase = TestPhase::Reset;
bool clock_is_high = false;
std::uint32_t reset_cycles = 0;
std::uint32_t input_strobe_cycles = 0;
std::uint32_t fpu_wait_cycles = 0;

void fail(const char* message)
{
    vpi_printf("FAIL: %s\n", message);
    vpi_control(vpiFinish, 1);
}

void expect_bus_value(std::uint32_t expected, const char* label)
{
    const std::uint32_t actual = teu.read_bus_low_word();
    if (actual != expected) {
        vpi_printf(
            "FAIL: %s: expected 0x%08x, got 0x%08x\n",
            label,
            expected,
            actual);
        vpi_control(vpiFinish, 1);
    }
}

void drive_current_cycle()
{
    teu.clear_micro_operations();
    teu.release_bus();
    teu.set_reset(false);

    switch (phase) {
    case TestPhase::Reset:
        teu.set_reset(true);
        break;
    case TestPhase::LoadScalar:
        teu.drive_bus(kScalarInput);
        teu.load_from_bus(LoadTarget::Scalar);
        break;
    case TestPhase::VerifyScalarStore:
        teu.store_scalar_to_bus();
        break;
    case TestPhase::LoadVectorB:
        teu.drive_bus(kVectorB0Input);
        teu.load_from_bus(LoadTarget::VectorB);
        break;
    case TestPhase::StartAddition:
        teu.configure_fpu(
            FpuOperation::Add,
            true,
            false,
            FpuIn1Route::Scalar,
            FpuIn2Route::VectorB0,
            false);
        break;
    case TestPhase::WaitForAddition:
        teu.configure_fpu(
            FpuOperation::Add,
            false,
            false,
            FpuIn1Route::Scalar,
            FpuIn2Route::VectorB0,
            false);
        break;
    case TestPhase::LoadFpuResult:
        teu.load_from_fpu(LoadTarget::Scalar);
        teu.configure_fpu(
            FpuOperation::Add,
            false,
            true,
            FpuIn1Route::Scalar,
            FpuIn2Route::VectorB0,
            false);
        break;
    case TestPhase::VerifyResultStore:
        teu.store_scalar_to_bus();
        break;
    }
}

void advance_test()
{
    switch (phase) {
    case TestPhase::Reset:
        ++reset_cycles;
        if (reset_cycles == kResetCycles) {
            phase = TestPhase::LoadScalar;
        }
        break;
    case TestPhase::LoadScalar:
        phase = TestPhase::VerifyScalarStore;
        break;
    case TestPhase::VerifyScalarStore:
        expect_bus_value(kScalarInput, "scalar bus store");
        phase = TestPhase::LoadVectorB;
        break;
    case TestPhase::LoadVectorB:
        phase = TestPhase::StartAddition;
        break;
    case TestPhase::StartAddition:
        ++input_strobe_cycles;
        if (input_strobe_cycles == kInputStrobeCycles) {
            phase = TestPhase::WaitForAddition;
        }
        break;
    case TestPhase::WaitForAddition:
        ++fpu_wait_cycles;
        if (teu.fpu_output_strobe()) {
            phase = TestPhase::LoadFpuResult;
        } else if (fpu_wait_cycles == kFpuTimeoutCycles) {
            fail("timed out waiting for the FPU addition result");
        }
        break;
    case TestPhase::LoadFpuResult:
        phase = TestPhase::VerifyResultStore;
        break;
    case TestPhase::VerifyResultStore:
        expect_bus_value(kExpectedSum, "FPU addition result");
        vpi_printf("PASS: TEU bus load/store and FPU addition test completed.\n");
        vpi_control(vpiFinish, 0);
        break;
    }
}

PLI_INT32 tick(p_cb_data);

void schedule_tick()
{
    s_vpi_time delay {};
    delay.type = vpiSimTime;
    delay.low = kHalfPeriod;

    s_cb_data callback {};
    callback.reason = cbAfterDelay;
    callback.cb_rtn = tick;
    callback.time = &delay;

    if (vpi_register_cb(&callback) == nullptr) {
        fail("could not schedule a simulation tick");
    }
}

PLI_INT32 tick(p_cb_data)
{
    if (!clock_is_high) {
        teu.set_clock(true);
        clock_is_high = true;
    } else {
        teu.set_clock(false);
        clock_is_high = false;
        advance_test();
        drive_current_cycle();
    }

    schedule_tick();
    return 0;
}

PLI_INT32 start_test(ICARUS_VPI_CONST PLI_BYTE8*)
{
    if (!teu.bind("sim_top")) {
        fail("could not find one or more sim_top TEU signals");
        return 0;
    }

    clock_is_high = false;
    phase = TestPhase::Reset;
    reset_cycles = 0;
    input_strobe_cycles = 0;
    fpu_wait_cycles = 0;
    teu.set_clock(false);
    teu.set_reset(true);
    teu.release_bus();
    drive_current_cycle();
    schedule_tick();
    return 0;
}

void register_cpp_test()
{
    s_vpi_systf_data task {};
    task.type = vpiSysTask;
    task.tfname = "$cpp_test";
    task.calltf = start_test;
    vpi_register_systf(&task);
}

} // namespace

extern "C" void (*vlog_startup_routines[])(void) = {
    register_cpp_test,
    nullptr,
};
