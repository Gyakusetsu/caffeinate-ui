// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "CaffeinateUI",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .target(
            name: "CaffeinateCore",
            path: "Sources/CaffeinateUI"
        ),
        .executableTarget(
            name: "CaffeinateUI",
            dependencies: ["CaffeinateCore"],
            path: "Sources/CaffeinateUIMain",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Resources/Info.plist"
                ])
            ]
        ),
        .testTarget(
            name: "CaffeinateUITests",
            dependencies: ["CaffeinateCore"]
        )
    ]
)
