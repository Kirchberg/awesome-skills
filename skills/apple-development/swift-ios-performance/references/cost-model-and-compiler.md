# Swift cost model and compiler behavior

## Contents

- Reasoning boundary
- Production optimization context
- Calls, allocation, layout, and copying
- Stored and computed shared values
- Dispatch, generics, and existentials
- Closures and exclusivity
- Compiler-control guardrails
- Verification

## Reasoning boundary

Use the language's semantic guarantees to establish correctness and a cost model
to form hypotheses. Use an optimized build, a benchmark, or profiling to prove a
specific runtime result.

Do not promise:

- that a local value stays on the stack;
- that a class instance, closure context, existential, or async frame allocates
  in every call context;
- that a function is or is not inlined or specialized;
- that `final`, `private`, a generic signature, or `static let` produces a
  particular instruction sequence.

The optimizer can remove, combine, sink, promote, specialize, or devirtualize
work when it has enough visibility. Resilience, dynamic replacement,
Objective-C exposure, module boundaries, and debug settings can limit that
visibility.

## Production optimization context

Inspect the affected target and configuration:

- `-Onone` preserves debug behavior and is not performance evidence.
- `-O` prioritizes runtime speed.
- `-Osize` performs optimization while prioritizing code size and is commonly a
  valid production choice for apps.
- Whole-module optimization can expose cross-file definitions, but current build
  systems and toolchains have additional compilation modes and cross-module
  optimization behavior. Inspect actual compiler invocations before advising a
  change.

Keep benchmark and app builds comparable. A result from a SwiftPM release
executable does not automatically describe an Xcode target built with different
settings, library evolution, or module boundaries.

## Calls, allocation, layout, and copying

Use four recurring dimensions:

### Function calls

A call has direct overhead, but its larger cost may be blocking inlining,
constant propagation, escape analysis, ARC elimination, or generic
specialization. Optimize call mechanics only after call frequency and callee
work are known.

### Memory allocation

Heap allocation normally adds allocator work, metadata, lifetime management, and
less predictable locality. Stack or inline storage often has a simpler lifetime,
but source syntax alone does not select the final region.

Look for:

- dynamic-size or escaping values;
- reference instances and captured closure contexts;
- collection growth and bridging;
- async frames whose state must survive suspension;
- repeated temporary buffers.

### Memory layout

Size, alignment, stride, indirection, and field order affect cache locality and
copy cost. Use `MemoryLayout` only for the static representation it reports; it
does not include referenced heap graphs or allocator overhead.

### Value copying

Assignment and argument passing follow value semantics, but the optimizer and
copy-on-write storage can avoid a deep copy. Conversely, a large aggregate,
existential payload, indirect representation, or loss of storage uniqueness can
make an apparently simple value expensive.

## Stored and computed shared values

Separate these declarations:

```swift
enum Shared {
    static let immutable = buildValue()
    static var mutable = buildValue()
    static var computed: Value { buildValue() }
}
```

Swift guarantees that stored type properties initialize lazily on first access,
only once, including concurrent first access. Both `immutable` and `mutable` are
stored. `computed` invokes a getter on access; it has no backing storage for the
returned value unless the getter or optimizer supplies reuse.

Apply these rules:

- Prefer stored `static let` for one immutable value whose shared lifetime and
  initialization cost are appropriate.
- Use stored `static var` only when the application truly needs mutable shared
  state and its actor isolation or synchronization is explicit.
- Use a computed type property for genuinely computed semantics, not to disguise
  construction of an expensive object on every access.
- Do not claim that `let` itself uses less memory or is always faster than
  stored `var`. The meaningful distinctions are mutability, optimization
  opportunities, synchronization, initialization, and lifetime.
- For a reference type, `static let` prevents replacing the stored reference;
  it does not freeze the instance's mutable properties or make concurrent
  mutation safe.
- Account for process-long retention after first access. Caching a formatter,
  regular expression, lookup table, or configuration can trade CPU and
  allocation for retained memory and shared-state constraints.
- Inspect actor isolation of the initializer and access. First access to a
  global or type property is execution, not a declaration-time event.

A trivial computed constant may be folded or inlined in an optimized caller.
Benchmark the real call context before replacing readable constants with stored
objects.

## Dispatch, generics, and existentials

### Class dispatch

An overridable class method normally requires an indirect dispatch mechanism.
`final` states a semantic restriction that can enable direct dispatch.
`private`, `fileprivate`, internal visibility plus sufficient module knowledge,
or whole-module optimization can allow the compiler to infer the same fact.

Add `final` because subclassing is not part of the design. Do not add it solely
as a speculative speed annotation or change an open API without compatibility
review.

Objective-C interoperability, `dynamic`, KVO, selectors, runtime replacement,
and resilience can require different dispatch. Preserve those contracts.

### Generics

A generic implementation can be specialized when the optimizer can see its
body and a concrete type. Across resilient module boundaries, `@inlinable` can
expose a public implementation for optimization, but it also makes referenced
implementation details part of the public ABI contract and can grow client code.
Treat that as an API decision.

### Existentials

An `any Protocol` value can introduce an existential container, metadata or
witness-table operations, indirect calls, and boxing when the payload does not
fit its representation. None of those costs is automatically material.

Keep existentials when heterogeneous storage, runtime substitution, or API
decoupling is the requirement. Consider a generic or opaque result only when:

- callers use one concrete type;
- specialization is visible and measurable;
- code-size and API complexity remain acceptable.

Do not rewrite an architecture around generics because a protocol appears in a
hot function signature.

## Closures and exclusivity

A nonescaping closure gives the optimizer stronger lifetime information. An
escaping closure may need a heap context for captured state and can extend the
lifetime of references or copy captured values. Async use can extend that
lifetime further.

Inspect:

- whether a closure must escape;
- which values it captures and by value or reference;
- whether a mutable local becomes boxed;
- whether a callback is created per element or per operation;
- whether retained state forms a cycle or simply lives longer than intended.

Do not add capture lists to reduce cost without modeling ownership. `weak` and
`unowned` change semantics and safety.

Swift enforces exclusive access for mutation. Dynamic exclusivity checks can
appear when the compiler cannot prove accesses do not overlap. Refactor an
observed hot check by shortening `inout` access, using local temporaries, or
clarifying aliasing. Never disable safety based only on a forum anecdote.

## Compiler-control guardrails

- Avoid `@inline(__always)` as a default; inlining can increase code size and
  instruction-cache pressure.
- Treat underscored attributes and optimizer flags as unsupported implementation
  details unless the project intentionally owns that risk.
- Use wrapping arithmetic only when wrapping is the required, tested semantics;
  it is not a blanket way to remove checks.
- Do not use unchecked collection access or unmanaged references until a profile
  proves the safety check or ARC traffic is material.
- Keep library evolution, binary compatibility, and downstream clients visible
  when exposing implementation for cross-module optimization.

## Verification

Use the cheapest evidence that answers the question:

1. complexity and lifetime proof for a clear algorithmic issue;
2. focused optimized benchmark for two source-level alternatives;
3. Allocations or Time Profiler for allocation, ARC, or call-path questions;
4. SIL or generated assembly to explain a measured difference;
5. Processor Trace or CPU Counters only for a residual instruction-level issue.

When inspecting SIL or assembly, compile the same source, optimization mode,
architecture, module context, and conditional flags as the candidate. Generated
code explains that build; it is not a permanent language guarantee.
