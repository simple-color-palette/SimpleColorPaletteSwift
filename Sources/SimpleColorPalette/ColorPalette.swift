import Foundation

/**
A Swift implementation of the [Simple Color Palette](https://simplecolorpalette.com) format — a minimal JSON-based file format for defining color palettes.

A palette contains colors with optional names, and the palette itself can also have a name. Colors are stored in extended sRGB color space (wide gamut). While colors are serialized in their linear form, the API primarily works with non-linear (gamma-corrected) values since these better match human perception and are what most color pickers and design tools use.

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
*/
public struct ColorPalette: Hashable, Sendable {
	public var colors: [Color]
	public var name: String?

	/**
	Creates a new color palette with the specified colors and optional name.
	*/
	public init(
		_ colors: [Color],
		name: String? = nil
	) {
		self.colors = colors
		self.name = name
	}
}

// In an extension so Codable methods will not show up in docs.
extension ColorPalette: Codable {}

extension ColorPalette {
	// Future text: Serializes the palette to a stable, portable data format.
	/**
	Serializes the palette to a portable data format.
	*/
	public func serialized() throws -> Data {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		return try encoder.encode(self)
	}

	/**
	Creates a palette from serialized data.
	*/
	public init(serialized data: Data) throws {
		self = try JSONDecoder().decode(Self.self, from: data)
	}

	/**
	Loads a palette from a file.

	- Parameter url: The file URL to read the palette from.
	*/
	public init(contentsOf url: URL) throws {
		let data = try Data(contentsOf: url)
		try self.init(serialized: data)
	}

	/**
	Writes the palette to a file.

	- Parameters:
		- url: The file URL to write the palette to. Use the `.color-palette` file extension.
	*/
	public func write(to url: URL, options: Data.WritingOptions = []) throws {
		try serialized().write(to: url, options: options)
	}
}
