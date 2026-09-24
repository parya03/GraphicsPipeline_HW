#include "Vtop.h"

#include "verilated.h"
#include "verilated_fst_c.h"

#include <iostream>

int main(int argc, char** argv)
{
    Verilated::commandArgs(argc, argv);

    // Create DUT
    Vtop* dut = new Vtop;

    // Enable waveform tracing
    Verilated::traceEverOn(true);

    VerilatedFstC* trace = new VerilatedFstC;
    dut->trace(trace, 99);
    trace->open("build/wave.fst");

    vluint64_t time = 0;

    auto tick = [&]() {
        // Falling edge
        dut->clk = 0;
        dut->eval();
        trace->dump(time++);

        // Rising edge
        dut->clk = 1;
        dut->eval();
        trace->dump(time++);
    };

    // ------------------------------------------------------------------------
    // Reset
    // ------------------------------------------------------------------------

    dut->reset = 1;
    dut->data_in = 0;

    tick();
    tick();

    dut->reset = 0;

    // ------------------------------------------------------------------------
    // Test inputs
    // ------------------------------------------------------------------------

    for (int i = 0; i < 10; ++i) {
        dut->data_in = i;

        tick();

        std::cout
            << "data_in = "
            << static_cast<int>(dut->data_in)
            << ", data_out = "
            << static_cast<int>(dut->data_out)
            << '\n';
    }

    // ------------------------------------------------------------------------
    // Cleanup
    // ------------------------------------------------------------------------

    trace->close();

    delete trace;
    delete dut;

    return 0;
}