// swift-tools-version:6.0
import PackageDescription

let package = Package(
	name: "SimpleColorPalette",
	platforms: [
		.macOS(.v12),
		.iOS(.v15),
		.tvOS(.v15),
		.watchOS(.v10),
		.visionOS(.v1)
	],
	products: [
		.library(
			name: "SimpleColorPalette",
			targets: [
				"SimpleColorPalette"
			]
		)
	],
	targets: [
		.target(
			name: "SimpleColorPalette",
			swiftSettings: [
				.swiftLanguageMode(.v5)
			]
		),
		.testTarget(
			name: "SimpleColorPaletteTests",
			dependencies: [
				"SimpleColorPalette"
			],
			swiftSettings: [
				.swiftLanguageMode(.v5)
			]
		)
	]
)
