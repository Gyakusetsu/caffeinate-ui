// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "CaffeinateUI",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "CaffeinateUI",
            path: "Sources/CaffeinateUI",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Resources/Info.plist"
                ])
            ]
        )
    ]
)
