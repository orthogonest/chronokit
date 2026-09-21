<h1 align="center">
  ChronoKit
</h1>

<p align="center">
  A lightweight, high-performance, foundation-free, and zero-dependency date and time primitives library for Swift.
</p>

<br><br>

ChronoKit is designed for systems where runtime efficiency and binary size are critical, providing a pure alternative to `Foundation.Date` with absolutely no external or framework dependencies.

## Features

- **Zero Foundation Framework Dependency**: Core modules are written in 100% pure Swift, making the library ideal for Linux servers, Embedded Swift, and WebAssembly (WASM).
- **Core Types**: Strictly typed primitives (`Instant`, `PlainDate`, `PlainTime`, `PlainDateTime`, `ZonedDateTime`) to enforce correct time representation.
- **Standards Compliant**: Native support for **RFC 3339**, **RFC 5322**, and **RFC 2822** (legacy support).
- **Zero-Allocation**: Custom byte-level parser and formatter designed for high-throughput serialization and logging.
- **IANA Integration (`ChronoTZ`)**: High-performance, compile-time embedded timezone support with memory-pooled lookups and BLOB deduplication.

## Quick Start

```swift
import ChronoKit

/// Parse an RFC 3339 string
let instant = Instant(rfc3339: "2026-04-26T12:00:00Z")!

/// Convert to wall-clock time
let plain = try! instant.plainDateTime(in: "America/New_York")

/// Convert to zoned date time
let datetime = instant.dateTime(in: FixedOffset.utc)

print(plain) // 2026-04-26T08:00:00
print(datetime) // 2026-04-26T12:00:00Z
```

### Apple Ecosystem Interoperability

To maintain compatibility with the broader Swift ecosystem, the optional `ChronoFoundation` module provides non-intrusive, bidirectional bridge proxies via `.foundation` and `.chrono` namespaces.
This allows ChronoKit types to seamlessly interoperate with existing packages and APIs that depend on native `Foundation` types:

```swift
import ChronoFoundation
import ChronoKit
import Foundation

// --- Outbound: ChronoKit -> Foundation ---
let plainDate = PlainDate(year: 2026, month: 9, day: 21)
let nativeComponents = plainDate.foundation.components // Returns Foundation.DateComponents

let chronoInstant = Instant(seconds: 1_790_000_000, nanoseconds: 0)
let nativeDate = chronoInstant.foundation.date // Returns Foundation.Date (lossy conversion)

// --- Inbound: Foundation -> ChronoKit ---
let systemDate = Foundation.Date()
let instantFromApple = systemDate.chrono.instant // Returns ChronoCore.Instant

let systemZone = Foundation.TimeZone.current
let chronoZone = systemZone.chrono.timeZone // Returns ChronoCore.TimeZone fully compliant
```

> [!WARNING]
> **Precision Truncation Notice**
> `ChronoKit` primitives maintain strict 1-nanosecond (`1e-9`) lossless resolution using a split `Int64`/`Int32` layout.
> However, `Foundation.Date` relies entirely on a 64-bit floating-point `Double`.
> Due to [IEEE 754](https://ieeexplore.ieee.org/document/8766229) mantissa limits on modern epochs, bridging conversions passing through `Foundation.Date` are inherently lossy and bounded to a `1e-6` (microsecond) threshold.
> For highly critical or precision-sensitive operations, keep executions entirely within the native `ChronoKit` integer primitives.

## Supported Standards

| Standard     | Description                                      |
| ------------ | ------------------------------------------------ |
| **RFC 3339** | Date and Time on the Internet (Timestamps)       |
| **RFC 5322** | Internet Message Format                          |
| **RFC 2822** | Obsolete Internet Message Format (Legacy Bridge) |

## Performance Philosophy

ChronoKit completely avoids `Foundation`'s heavy runtime overhead and transitive baggage by manipulating direct memory buffers for parsing, formatting, and resource handling.
It is designed to be embedded in low-level systems, CLI tools, and performance-sensitive services.

## Acknowledgments

Calendrical logic built upon the foundational work of [Howard Hinnant](https://howardhinnant.github.io/date_algorithms.html).
His efficient algorithms for date and time calculation serve as the core of **ChronoKit**.
