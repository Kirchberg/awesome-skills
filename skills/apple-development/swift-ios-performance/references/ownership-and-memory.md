# Ownership, ARC, and memory lifetime

## Contents

- Choose semantics before representation
- Value size and copying
- Copy-on-write
- Slices and borrowed views
- ARC and object lifetime
- Closure and task captures
- Bridging and autorelease boundaries
- Shared storage and caches
- Review checklist

## Choose semantics before representation

Use a value type when independent values and mutation isolation are the model.
Use a reference type when stable identity, shared mutation, inheritance, or an
object lifetime is the model.

Do not reduce the choice to “struct is stack, class is heap”:

- a struct can contain `Array`, `String`, `Data`, a class reference, an
  existential, or another indirectly stored value;
- a class reference is small to copy but its instance allocation, ARC traffic,
  indirection, and object graph still have costs;
- a large inline value can increase copies, argument movement, and cache
  pressure;
- a reference graph can improve sharing but worsen locality and lifetime
  predictability.

Model semantics first, then measure the representation used by the hot path.

## Value size and copying

Inspect the complete value:

- stored fields and nested aggregates;
- indirect enum cases or existential payloads;
- referenced copy-on-write buffers;
- frequency of assignment, capture, return, and mutation;
- whether the optimizer can consume, borrow, or eliminate a copy;
- module boundaries and generic abstraction.

`MemoryLayout<T>.size`, `stride`, and `alignment` describe the inline
representation of `T`. They do not include pointed-to storage, allocator
metadata, collection capacity, or retained object graphs.

For a large value:

1. confirm that copying appears in a benchmark, profile, SIL, or generated code;
2. shorten lifetime or avoid duplicate materialization first;
3. consider composing existing copy-on-write storage;
4. implement custom copy-on-write only when the semantic type and mutation
   pattern justify its complexity;
5. consider noncopyable or borrowing APIs only under a compatible toolchain and
   deliberate API design.

Do not replace a value with a class merely because it has several fields.

## Copy-on-write

Swift standard-library collections use value semantics with shared storage until
mutation requires a unique buffer. Copy-on-write can turn an apparent copy into
cheap sharing, but it can also create an unexpected full copy.

Look for:

- two live collection values sharing storage when either mutates;
- mutation through a helper that returns a new collection instead of mutating an
  `inout` value;
- repeated conversions that lose storage identity;
- escaped buffers, slices, or bridges that prevent a uniqueness fast path;
- nested copy-on-write values inside a large aggregate.

Use `isKnownUniquelyReferenced` only inside a correctly designed custom
copy-on-write wrapper. It answers uniqueness for one class reference at one
moment; it does not provide synchronization or make concurrent mutation safe.

Preserve value semantics when optimizing. A shared reference hidden inside a
struct without uniqueness handling changes behavior.

## Slices and borrowed views

`ArraySlice` and `Substring` are efficient views that can share the original
storage. This avoids immediate copying but can keep a much larger buffer alive.

Use a view when:

- consumption is local and short-lived;
- the base remains needed anyway;
- avoiding an intermediate copy is valuable.

Materialize an `Array` or `String` when:

- a tiny result escapes into long-lived state;
- the large base should otherwise be released;
- an API needs independent storage;
- measurement shows retained capacity is material.

Do not copy every slice preemptively. Compare avoided copy cost with retained
memory and actual lifetime.

`Span` is a non-owning, nonescaping view with lifetime constraints. Use it only
with a compatible toolchain and read `low-level-and-accelerated.md`.

## ARC and object lifetime

ARC manages class instances and captured reference state. Retains and releases
can be optimized, but high-frequency reference traffic, bridging, and object
graphs can remain visible in a hot path.

Reason from ownership:

- **strong** keeps the object alive;
- **weak** allows deallocation and becomes `nil`;
- **unowned** does not keep the object alive and requires the referenced object
  to remain valid when accessed.

Choose `weak` or `unowned` to express a proven lifetime relationship and break a
cycle, not to win a microbenchmark. A mistaken unowned relationship is a crash
risk.

Swift may release an object after its last use rather than at the closing brace.
Use `withExtendedLifetime` when correctness requires a longer lifetime. Do not
add artificial lifetime extension to make debugging behavior look predictable.

Distinguish:

- an unreachable allocation leak;
- a retain cycle;
- a reachable object that outlives its useful work;
- an intentional cache;
- a transient peak with multiple representations.

Use `app-performance` for heap, memory-graph, footprint, or termination
diagnosis. Use this skill to correct the source-level ownership mechanism once
identified.

## Closure and task captures

Escaping closures and unstructured tasks can extend captured lifetimes. A
closure may capture:

- an immutable snapshot by value;
- a reference to shared mutable state;
- a box for a captured mutable local;
- `self`, directly or through another captured object.

Review the ownership graph rather than adding `[weak self]` mechanically:

- a short-lived structured child task may correctly retain its inputs;
- a stored callback can form a cycle with its owner;
- a long-running unstructured task can keep a feature graph alive;
- a weak capture can silently skip required work after deallocation;
- an unowned capture requires a lifetime proof.

Break cycles at the ownership boundary with the correct semantics. Cancel
long-lived work at the lifecycle boundary when cancellation is part of the
design. Do not confuse cancellation with immediate release; the task must observe
and complete cancellation.

## Bridging and autorelease boundaries

Swift values can bridge to Foundation and Objective-C representations. A bridge
may be constant-time sharing, lazy, or a conversion with allocation and copying;
the exact path depends on types and storage.

Inspect hot loops that:

- pass Swift collections or strings repeatedly to Objective-C APIs;
- receive autoreleased objects from Foundation;
- convert between `String` and `NSString`, `Data` and `NSData`, or Swift
  collections and `NSArray` or `NSDictionary`;
- build multiple encoded or decoded representations at once.

An explicit `autoreleasepool` can bound temporary Objective-C objects in a
measured batch loop. It does not release live Swift references, replace correct
ownership, or improve every Foundation call.

Avoid claiming zero-copy interoperability without checking the concrete API and
storage form.

## Shared storage and caches

A stored global or type property initializes lazily, and its storage remains for
the process lifetime. An unchanged stored reference keeps its value rooted; a
mutable property can replace that value. A cache can trade repeated CPU and
allocation for retained memory, synchronization, and invalidation.

Before introducing shared storage, define:

- ownership and isolation;
- maximum retained size;
- key and eviction behavior;
- whether values depend on locale, calendar, time zone, user settings, account,
  or configuration;
- memory-pressure behavior if the cache is substantial;
- whether per-feature lifetime is shorter and more appropriate.

Prefer immutable shared configuration when it is truly universal. Do not turn a
mutable formatter, decoder, scratch buffer, or feature-specific cache into a
global singleton to avoid construction.

## Review checklist

- Is identity or value independence the intended semantic?
- What inline bytes and referenced storage does the value contain?
- Where can copies occur, and which are deep after copy-on-write?
- Does a slice, closure, task, cache, or type property extend a large lifetime?
- Are ARC operations frequent because of representation or API boundaries?
- Is shared mutable state isolated and synchronized?
- Does a bridge or autorelease pool create a transient peak?
- Can the same result be produced with less retained state?
- What correctness and lifetime tests protect the proposed change?
- Which benchmark or allocation capture can falsify the hypothesis?
