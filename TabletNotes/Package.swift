// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "TabletNotes",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "TabletNotes",
            targets: ["TabletNotes"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.3.1")
    ],
    targets: [
        .target(
            name: "TabletNotes",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ],
            path: "TabletNotes"),
        .testTarget(
            name: "TabletNotesTests",
            dependencies: ["TabletNotes"]),
    ]
) 