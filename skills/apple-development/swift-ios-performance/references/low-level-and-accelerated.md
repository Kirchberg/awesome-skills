# Low-level and accelerated Swift

## Contents

- Escalation gate
- InlineArray
- Span and borrowed views
- Initialized storage construction
- Unsafe buffer access
- SIMD and Accelerate
- Safety and validation record

## Escalation gate

Use low-level techniques only after all of these are true:

- a representative optimized benchmark or profile identifies the exact hot path;
- algorithm, data structure, repeated work, materialization, allocation, and
  concurrency granularity have already been considered;
- the expected win has a specific mechanism;
- the project toolchain and deployment targets support the chosen API or a
  maintainable fallback;
- correctness tests cover boundaries, empty and maximum inputs, malformed data,
  aliasing, overflow, and concurrency as applicable;
- maintainers can review and own the resulting safety contract.

Do not use unsafe code to make a benchmark interesting.

## InlineArray

`InlineArray`, introduced in Swift 6.2, stores a fixed number of elements inline
without a separate allocation for element storage.

It is a candidate when:

- element count is fixed at compile time;
- avoiding one separate allocation is material;
- the complete inline size remains reasonable;
- eager value copying is acceptable or eliminated;
- the API does not need to resize dynamically.

Account for:

- elements copy eagerly with the value rather than through `Array` copy-on-write;
- a large inline array can increase value-copy cost and stack pressure;
- when stored in a class, the inline elements live in the class's heap
  allocation; only the separate array-storage allocation is avoided;
- bounds checks remain for ordinary subscripting;
- generic integer parameters and syntax require a compatible compiler;
- current Apple SDK documentation gives the type iOS-family availability tied to
  the Swift 6.2-era platform SDKs, including iOS 26.

Do not make `InlineArray` an unconditional replacement in an app supporting
earlier deployment targets. Verify the exact compiler and SDK availability, and
retain an `Array`, tuple, or other supported representation when required.

Benchmark copying and complete-operation latency, not allocation count alone.

## Span and borrowed views

`Span`, introduced in Swift 6.2, is a non-owning, nonescaping view over initialized
contiguous memory. Its lifetime is tied to the viewed storage, and ordinary
access is bounds-checked.

Use it when:

- an API should borrow rather than allocate or copy a buffer;
- the caller owns contiguous storage for the complete access;
- a safe view can replace a pointer-based interface;
- generic algorithms can operate without taking ownership.

Do not claim that `Span` automatically accelerates an `Array`. Its value is
safer borrowed access and the opportunity to avoid ownership or conversion; the
actual call path still needs measurement.

Keep the span within the compiler-enforced lifetime. Do not attempt to erase or
circumvent its nonescaping guarantees.

Use `MutableSpan` only with exclusive mutable access. Use raw spans only when the
byte-level representation and initialization state are correct.

As with `InlineArray`, verify compiler, SDK, and deployment compatibility before
adopting it in an iOS app with older targets.

## Initialized storage construction

Collection initializers that expose uninitialized capacity can avoid writing
temporary values before filling a result. They are useful for a proven
allocation or initialization hot path with a known result bound.

Prefer a safe `OutputSpan`-based API when the project's toolchain and deployment
targets support it. When using
`init(unsafeUninitializedCapacity:initializingWith:)`:

- never read uninitialized memory;
- initialize exactly the elements reported in the initialized count;
- keep the count within capacity;
- advance the initialized count immediately after each successful element
  initialization so the array can destroy that prefix if the closure throws;
- do not manually destroy elements already included in the initialized count;
- do not expose partially initialized storage;
- test empty, exact-capacity, maximum, and error cases.

A normal `reserveCapacity` plus `append` is often fast enough and substantially
easier to review.

## Unsafe buffer access

Use closure-scoped APIs such as `withUnsafeBytes`,
`withUnsafeBufferPointer`, or their mutable variants to borrow existing storage.

Inside the closure:

- keep the pointer within its documented lifetime;
- check bounds before pointer arithmetic;
- respect alignment for typed loads and stores;
- bind or rebind memory only according to Swift's memory-binding rules;
- avoid overlapping mutable access;
- preserve initialization and deinitialization of nontrivial values;
- avoid escaping the pointer through storage, a callback, or a task.

Do not assume a `Data` base address is aligned for an arbitrary type. Decode
explicit byte order and use an API that supports unaligned loads when the
toolchain and format call for it.

Use `assumingMemoryBound`, unchecked subscripts, `Unmanaged`, and manual
allocation only with a separately documented invariant. Prefer safe indexing
until a profile proves checks are material.

For C and Objective-C interoperation, follow the imported API's ownership
annotations. Do not use `Unmanaged` to second-guess an already-correct importer.

## SIMD and Accelerate

Use standard-library SIMD types for fixed-width vector arithmetic when:

- the operation is naturally element-wise;
- data layout and alignment are suitable;
- scalar tails and small inputs remain correct;
- the optimized compiler does not already produce equivalent vectorization.

Use Accelerate for supported large-scale operations such as:

- vector arithmetic and conversion;
- digital signal processing;
- linear algebra;
- image processing;
- selected numerical functions.

Accelerate primitives are tuned for Apple hardware and can improve speed and
energy, but boundary conversion, allocation, setup, and small-input overhead can
dominate. Prefer APIs that write into reusable output storage when the lifetime
and ownership are clear.

Do not reproduce an Accelerate example's published speedup as a forecast. Compare
the same operation, precision, input size, output, and device.

Avoid hand-written vector code when a maintained framework primitive expresses
the operation. Avoid framework conversion when the workload is too small or data
is already in an incompatible representation.

## Safety and validation record

For each low-level change, record:

- measured baseline and candidate;
- Swift, Xcode, SDK, OS, architecture, and deployment availability;
- buffer owner and lifetime;
- element initialization and deinitialization rules;
- bounds, alignment, aliasing, and byte-order assumptions;
- fallback path for unsupported targets;
- correctness, fuzz, malformed-input, sanitizer, and concurrency tests;
- allocation, memory, binary-size, and energy tradeoffs;
- why the safe higher-level implementation was insufficient.

Run Address Sanitizer or other repository-supported diagnostics on focused tests
when unsafe memory is introduced. Then validate performance again without
sanitizer instrumentation in the matched optimized configuration.

Keep the safe version as a reference implementation when practical. Differential
tests between safe and optimized implementations are often the strongest guard.
