# SimpleColorPalette

> A Swift implementation of the [Simple Color Palette](https://simplecolorpalette.com) format — a minimal JSON-based file format for defining color palettes

*Feedback wanted on the API.*

## Install

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/simple-color-palette/SimpleColorPaletteSwift", from: "0.2.0")
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app)

## Usage

[API documentation](https://swiftpackageindex.com/simple-color-palette/simplecolorpaletteswift/documentation/simplecolorpalette/colorpalette)

```swift
import SimpleColorPalette

let palette = ColorPalette(
	[
		.init(components: .init(red: 1, green: 0, blue: 0), name: "Red"),
		.init(components: .init(red: 0, green: 1, blue: 0), name: "Green")
	],
	name: "Traffic Lights"
)

let url = URL.downloadsDirectory.appending(path: "Traffic Lights.color-palette")

// Save palette
try palette.write(to: url)

// Load palette
let loadedPalette = try ColorPalette(contentsOf: url)
```

## Related

- [Defaults](https://github.com/sindresorhus/Defaults) - Swifty and modern UserDefaults
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Add user-customizable global keyboard shortcuts to your macOS app
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift+archived%3Afalse&type=repositories)
