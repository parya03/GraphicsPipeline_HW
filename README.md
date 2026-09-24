# GraphicsPipeline_HW
HW implementation of graphics pipeline

## Design
May change.

The goal of this design is to accelerate 3D graphics with big SIMD operations. Therefore, emphasis is placed on single-precision (32-bit) floating point operations between 4D vectors, 4x4 matrices, and scalars.

There is intended to be some extent of programmability, but much of it may be fixed-function for simplicity.

Some notation that is used is:
- **A**: Uppercase A representing a 4x4 matrix input
- $\vec{a}$: A vector input
- $\vec{b}$: The second vector input
- $\vec{c}$: A vector output
- **s**: A scalar input/output

### Thread Execution Unit (TEU)
The most basic unit of data manipulation. It's basically a big datapath element that gets copy pasted into an overall core.

A TEU contains:
- A register file containing:
    - A 16xf32 that can be treated as 4x4 matrix **A** or 4D vector $\vec{a}$ (the first column of **A**)
    - A 4xf32 vector $\vec{b}$
    - A 4xf32 vector $\vec{c}$
    - A single f32 scalar value **s**
- An FPU

The TEU does not have decode logic. All operations are done via microops from the overall core unit.

### Programmable Processing Core ("Core")
The top-level organized unit of operation that contains TEUs. Right now aiming for 32 TEUs per core.

The core contains:
- Decode logic
    - Takes commands/instructions and converts them into microops that are (generally) shared between all TEUs
- TEUs
- Bus (currently planning on 128 bit)
- Memory buffers (caches?)

## AI Acknowledgement
AI tools were used for menial stuff (print statements, verbose syntax, "enhanced" repeating of code manually). But the code is still my own.

I also used AI for some more "menial" Verilog stuff.