# quiver-adapters

Framework adapters for Quiver HTTP/3. This package contains integration layers for Vapor and Hummingbird applications that want to use Quiver's HTTP/3 stack.

## Products

| Product | Purpose |
| --- | --- |
| `QuiverVapor` | Vapor integration helpers backed by `quiver-http3`. |
| `QuiverHummingbird` | Hummingbird integration helpers backed by `quiver-http3` and `swift-http-types`. |

## Installation

Add the package to your `Package.swift`:

```swift
dependencies: [
	.package(url: "https://github.com/hironichu/quiver-adapters.git", branch: "main")
]
```

Then depend on the adapter you need:

```swift
.target(
	name: "MyTarget",
	dependencies: [
		.product(name: "QuiverVapor", package: "quiver-adapters"),
		.product(name: "QuiverHummingbird", package: "quiver-adapters"),
	]
)
```

## Local Development

Keep this package next to `quiver-http3` and `quiver-quic`:

```text
quiver-packages/
├── quiver-quic/
├── quiver-http3/
└── quiver-adapters/
```

For Swift CI style local dependency testing, set `SWIFTCI_USE_LOCAL_DEPS=1` and place a local `swift-nio` checkout one directory above `quiver-packages`.

Set `QUIVER_PACKAGES_PATH=/path/to/quiver-packages` if your local Quiver package checkouts live somewhere else.

## Dependencies

- `quiver-http3` for HTTP/3 request/response handling.
- `vapor` for the Vapor adapter product.
- `hummingbird` and `swift-http-types` for the Hummingbird adapter product.
- `swift-nio` and `swift-log` for networking primitives and diagnostics.

## Development Commands

```bash
swift build
swift test
```

## Relationship To Quiver

The root `quiver` package conditionally re-exports these adapters through the `VaporSupport` and `HummingbirdSupport` package traits.
