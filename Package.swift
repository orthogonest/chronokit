// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "chronokit",
    products: [
        .library(
            name: "ChronoKit",
            targets: ["ChronoKit"]
        ),
        .library(
            name: "ChronoCore",
            targets: ["ChronoCore"]
        ),
        .library(
            name: "ChronoFormatter",
            targets: ["ChronoFormatter"]
        ),
        .library(
            name: "ChronoParser",
            targets: ["ChronoParser"]
        ),
        .library(
            name: "ChronoSystem",
            targets: ["ChronoSystem"]
        ),
        .library(
            name: "ChronoTZ",
            targets: ["ChronoTZ"]
        ),
        .library(
            name: "ChronoFoundation",
            targets: ["ChronoFoundation"]
        ),
    ],
    targets: [
        // MARK: - Kit Libraries

        .target(
            name: "ChronoKit",
            dependencies: [
                "ChronoCore",
                "ChronoFormatter",
                "ChronoCalendar",
                "ChronoParser",
                "ChronoSystem",
                "ChronoTZ",
            ],
            path: "Sources/ChronoKit"
        ),
        .target(
            name: "ChronoCore",
            dependencies: ["ChronoCalendar"],
            path: "Sources/ChronoCore"
        ),
        .target(
            name: "ChronoFormatter",
            dependencies: ["ChronoCore", "ChronoCalendar"],
            path: "Sources/ChronoFormatter"
        ),
        .target(
            name: "ChronoCalendar",
            path: "Sources/ChronoCalendar"
        ),
        .target(
            name: "ChronoParser",
            dependencies: ["ChronoCore", "ChronoCalendar"],
            path: "Sources/ChronoParser"
        ),
        .target(
            name: "ChronoSystem",
            dependencies: ["ChronoCore"],
            path: "Sources/ChronoSystem"
        ),
        .target(
            name: "ChronoTZ",
            dependencies: [
                "ChronoCore",
                "ChronoCalendar",
                "ChronoSystem",
            ],
            path: "Sources/ChronoTZ",
            resources: [
                .embedInCode("Resources/iana.tzdb"),
            ]
        ),

        // MARK: - Compatibility Layer

        .target(
            name: "ChronoFoundation",
            dependencies: ["ChronoCore"],
            path: "Sources/ChronoFoundation"
        ),

        // MARK: - Build-time Tools

        .target(
            name: "ChronoTZGenCore",
            dependencies: ["ChronoSystem", "ChronoTZ"],
            path: "Tools/ChronoTZGenCore"
        ),
        .executableTarget(
            name: "ChronoTZGen",
            dependencies: ["ChronoTZGenCore", "ChronoSystem"],
            path: "Tools/ChronoTZGen"
        ),

        // MARK: - Unit Tests

        .testTarget(
            name: "ChronoCoreTests",
            dependencies: ["ChronoCore"],
            path: "Tests/Unit/ChronoCoreTests"
        ),
        .testTarget(
            name: "ChronoFormatterTests",
            dependencies: [
                "ChronoCore",
                "ChronoFormatter",
                "ChronoCalendar",
                "ChronoSystem",
            ],
            path: "Tests/Unit/ChronoFormatterTests"
        ),
        .testTarget(
            name: "ChronoCalendarTests",
            dependencies: ["ChronoCalendar"],
            path: "Tests/Unit/ChronoCalendarTests"
        ),
        .testTarget(
            name: "ChronoParserTests",
            dependencies: [
                "ChronoCore",
                "ChronoParser",
                "ChronoCalendar",
            ],
            path: "Tests/Unit/ChronoParserTests"
        ),
        .testTarget(
            name: "ChronoSystemTests",
            dependencies: ["ChronoCore", "ChronoSystem"],
            path: "Tests/Unit/ChronoSystemTests"
        ),
        .testTarget(
            name: "ChronoTZTests",
            dependencies: [
                "ChronoCore",
                "ChronoCalendar",
                "ChronoSystem",
                "ChronoTZ",
            ],
            path: "Tests/Unit/ChronoTZTests"
        ),
        .testTarget(
            name: "ChronoTZGenTests",
            dependencies: [
                "ChronoSystem",
                "ChronoTZ",
                "ChronoTZGenCore",
            ],
            path: "Tests/Unit/ChronoTZGenTests"
        ),
        .testTarget(
            name: "ChronoFoundationTests",
            dependencies: [
                "ChronoCore",
                "ChronoFoundation",
            ],
            path: "Tests/Unit/ChronoFoundationTests"
        ),

        // MARK: - Integration Tests

        .testTarget(
            name: "ChronoIntegrationTests",
            dependencies: [
                "ChronoCore",
                "ChronoFormatter",
                "ChronoCalendar",
                "ChronoParser",
                "ChronoSystem",
                "ChronoTZ",
            ],
            path: "Tests/Integration"
        ),

        // MARK: - Property Tests

        .testTarget(
            name: "ChronoPropertyTests",
            dependencies: [
                "ChronoCore",
                "ChronoFormatter",
                "ChronoCalendar",
                "ChronoParser",
                "ChronoSystem",
                "ChronoTZ",
            ],
            path: "Tests/Property"
        ),
    ]
)

for target in package.targets {
    target.swiftSettings = [
        .swiftLanguageMode(.v6),
        .enableUpcomingFeature("StrictConcurrency"),
    ]
}
