# Collections, algorithms, and text

## Contents

- Start with the algorithm
- Array growth and reuse
- Choose collections by operation
- Avoid unnecessary materialization
- Copy-on-write and mutation
- String and Substring
- Data and byte processing
- Reusable Foundation values
- Review checklist

## Start with the algorithm

Estimate work at representative scale before choosing a Swift-specific trick.
Record:

- input size and distribution;
- number of passes;
- complexity of lookup, insertion, removal, sorting, grouping, and hashing;
- temporary output size;
- early-exit opportunities;
- ordering and uniqueness requirements.

Prefer a better algorithm over a cheaper spelling of the same algorithm. Common
high-value changes include:

- replacing repeated linear membership checks with a set when hashing cost and
  memory are acceptable;
- selecting only the needed smallest or largest elements instead of sorting the
  full input;
- combining repeated scans when one pass stays readable and correct;
- moving invariant parsing, normalization, or formatting out of a repeated loop;
- avoiding work for results the caller discards.

Do not fuse passes when it obscures correctness, changes ordering, or prevents
framework vectorization. Benchmark the actual data sizes.

## Array growth and reuse

`Array` grows geometrically, so repeated `append` has amortized constant-time
behavior. Use `reserveCapacity` when a useful final count or upper estimate is
known and intermediate reallocations are material.

Good candidates:

- mapping a collection with known count into a manually built result;
- decoding a header that declares a bounded element count;
- accumulating one output per accepted input with a realistic upper bound.

Guardrails:

- Reserving is a request and may allocate more storage than requested.
- Calling `reserveCapacity(currentCount + smallIncrement)` before every growth
  can defeat geometric growth and create worse behavior.
- A large overestimate increases retained memory.
- Calling it on bridged array storage can force contiguous unique storage.
- `Array.map` and other collection algorithms can use known or estimated counts;
  a hand-written loop plus reservation is not automatically faster.

Use `removeAll(keepingCapacity: true)` for a buffer that is repeatedly rebuilt
at a similar size and whose retained storage fits the memory contract. Use the
default when the memory should be released or the next size is unknown.

## Choose collections by operation

### Array

Prefer `Array` for compact ordered storage, indexed access, appending at the end,
and sequential traversal. Removal or insertion near the front or middle moves
following elements.

### Deque

Consider `Deque` from Swift Collections for frequent insertion or removal at
both ends. Account for the package dependency, deployment policy, actual sizes,
and any difference in locality. Do not replace ordinary arrays that mainly
append and iterate.

### Set and Dictionary

Use hashing when membership or key lookup dominates and keys have suitable
`Hashable` behavior. Account for:

- hashing cost;
- capacity and bucket overhead;
- loss of order unless the chosen type defines one;
- duplicate-key semantics;
- denial-of-service or collision concerns for untrusted workloads.

For small collections, a linear scan can be faster and smaller. Measure the
crossover for the application.

### ContiguousArray

`ContiguousArray` can be more predictable when elements are class instances or
`@objc` protocol values and no `NSArray` bridging is needed. For struct or enum
elements, Apple documents efficiency similar to `Array`.

Do not make it a default alias. Verify that bridging is absent and that a
benchmark shows a relevant difference.

### Ordered collections

Use `OrderedSet` or `OrderedDictionary` when order plus uniqueness or keyed
lookup is a real invariant. Their extra storage and update work are not free.

## Avoid unnecessary materialization

An eager `map`, `filter`, `sorted`, or conversion can allocate a full result.
Chained eager operations can create several intermediates.

Choose among:

- standard eager algorithms when the full result is required and clarity wins;
- `.lazy` when downstream work stops early or a chain can avoid intermediates;
- `reduce(into:)` or a clear loop when one mutable accumulator avoids repeated
  result construction;
- a specialized Swift Algorithms operation that represents the intent without
  copying elements unnecessarily;
- one final materialization at an API or ownership boundary.

Lazy evaluation is not free:

- full consumption still performs all element work;
- wrappers and generic layers can affect optimization;
- a lazy pipeline can retain its base longer;
- repeated iteration repeats computation;
- escaping or type erasure can change representation.

Use `prefix` before expensive downstream work when semantics permit. Do not sort
an entire collection before taking a few results when a selection algorithm
expresses the same ordering requirement.

## Copy-on-write and mutation

Prefer in-place mutation of a uniquely owned collection when the API semantics
already call for mutation. Watch for:

- returning a new large collection and assigning it back;
- keeping an old copy alive across mutation;
- mutating nested collections through computed properties;
- repeated `+` concatenation in a loop;
- bridging that prevents a uniqueness fast path.

An `inout` helper can preserve the caller's storage, but it also creates an
exclusive access for the call duration. Keep the access narrow and do not adopt
`inout` without an API and exclusivity review.

For custom copy-on-write, hide the reference storage, check uniqueness before
mutation, preserve value semantics, and test copied values independently.

## String and Substring

Swift `String` is a Unicode-correct collection of extended grapheme clusters.
Character boundaries are variable-width. Avoid code that repeatedly walks from
`startIndex` to an integer offset or assumes character count is a byte count.

Choose the semantic view:

- `Character` for user-perceived characters;
- `unicodeScalars` for Unicode scalar processing;
- `utf8` for protocols and parsers defined in UTF-8 bytes;
- Foundation or specialized parsing APIs when they already implement the task
  efficiently.

Swift's native preferred representation is UTF-8, but strings can have bridged
or other storage. Use contiguous UTF-8 access only through the supported APIs
and handle the unavailable-contiguous-storage path.

`Substring` shares storage with its base. Keep it as a short-lived parsing view;
convert a small escaping result to `String` when retaining the large source would
be wasteful.

Avoid repeated interpolation or `+` concatenation for a large result. Append
into one result with a useful reservation or use an API such as `joined` that
can size and construct the output appropriately. Verify on representative
Unicode and ASCII-heavy inputs.

## Data and byte processing

Define whether the operation needs:

- ownership of bytes;
- a non-owning view;
- mutable contiguous storage;
- decoding into typed values;
- bridging to `NSData`;
- an async or escaping lifetime.

Use `withUnsafeBytes` or contiguous-storage APIs only within their closure
lifetime. Never store the pointer or assume alignment. Prefer byte-oriented
parsing over repeated `Data` slicing and conversion when the format is defined
in bytes and a benchmark supports it.

A `Data` slice or bridge may share storage or copy depending on the operation
and representation. Do not assert zero-copy behavior without documentation or
measurement.

## Reusable Foundation values

Construction of a formatter, regular expression, decoder, encoder, locale-aware
object, or parser configuration may be worth reusing when profiles show repeated
setup. Select lifetime deliberately:

- local for cheap or request-specific configuration;
- feature-owned for shared use with bounded lifetime;
- stored `static let` only for immutable, universal configuration whose
  process-long retention and isolation are correct.

Do not share a mutable formatter, encoder, decoder, or scratch buffer across
concurrent work without an explicit safety contract. Include locale, calendar,
time zone, user settings, and configuration invalidation in the cache key or
lifetime.

## Review checklist

- Is the asymptotic algorithm suitable at production size?
- How many full passes and intermediate results are created?
- Is capacity known, reused sensibly, or retained excessively?
- Does the collection match its frequent operations?
- Does copy-on-write stay unique through mutation?
- Could a small slice retain a large base?
- Is text processed at the correct Unicode or byte semantic level?
- Does bridging or conversion occur inside a repeated loop?
- Is shared reuse safe, correctly invalidated, and memory-bounded?
- Which optimized benchmark or allocation trace will decide the tradeoff?
