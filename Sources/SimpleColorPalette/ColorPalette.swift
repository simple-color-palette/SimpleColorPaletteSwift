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
	/**
	Represents a single color.
	*/
	public struct Color: Hashable, Sendable {
		/**
		The color components in extended linear sRGB color space.

		- Note: For most purposes, you will want to use ``components`` instead which returns normal sRGB values, meaning adjusted for human perception and display on screens.
		*/
		public var linearComponents: Components

		/**
		Optional name for the color.
		*/
		public var name: String?

		/**
		Creates a color using extended linear sRGB components.

		- Note: For most purposes, you will want to use the “components” initializer instead.
		*/
		public init(
			linearComponents: Components,
			name: String? = nil
		) {
			self.linearComponents = linearComponents
			self.name = name
		}
	}
}

extension ColorPalette.Color {
	/**
	Creates a color using extended non-linear sRGB components.

	- Note: If you don't know the difference between linear and non-linear, this is the initializer you want.
	*/
	public init(components: Components, name: String? = nil) {
		self.init(
			linearComponents: .init(
				red: Self.sRGBToLinear(components.red),
				green: Self.sRGBToLinear(components.green),
				blue: Self.sRGBToLinear(components.blue),
				opacity: components.opacity
			),
			name: name
		)
	}

	private static func sRGBToLinear(_ srgb: Double) -> Double {
		guard srgb > 0.04045 else {
			return srgb / 12.92
		}

		return pow((srgb + 0.055) / 1.055, 2.4)
	}
}

extension ColorPalette.Color {
	/**
	The color components in extended non-linear sRGB color space.

	- Note: This is probably what you want. The color components adjusted for human perception and display on screens.
	*/
	public var components: Components {
		Components(
			red: Self.linearToSRGB(linearComponents.red),
			green: Self.linearToSRGB(linearComponents.green),
			blue: Self.linearToSRGB(linearComponents.blue),
			opacity: linearComponents.opacity
		)
	}

	private static func linearToSRGB(_ linear: Double) -> Double {
		guard linear > 0.0031308 else {
			return linear * 12.92
		}

		return pow(linear, 1 / 2.4) * 1.055 - 0.055
	}
}

extension ColorPalette.Color {
	/**
	Color components representing RGB values and opacity.
	*/
	public struct Components: Hashable, Sendable {
		public var red: Double
		public var green: Double
		public var blue: Double

		/**
		The opacity value.

		It is automatically clamped to 0...1.
		*/
		public var opacity: Double {
			didSet {
				let clamped = opacity.clamped(to: 0...1)

				if clamped != opacity {
					opacity = clamped
				}
			}
		}

		public init(
			red: Double,
			green: Double,
			blue: Double,
			opacity: Double = 1
		) {
			self.red = red
			self.green = green
			self.blue = blue
			self.opacity = opacity.clamped(to: 0...1)
		}
	}
}

extension ColorPalette.Color: Codable {
	enum CodingKeys: String, CodingKey {
		case name
		case linearComponents = "components"
	}
}

extension ColorPalette.Color.Components: Codable {
	enum CodingError: Error {
		case invalidComponentCount
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let components = try container.decode([Double].self)

		guard components.count == 3 || components.count == 4 else {
			throw CodingError.invalidComponentCount
		}

		red = components[0]
		green = components[1]
		blue = components[2]
		opacity = components.count == 4 ? components[3].clamped(to: 0...1) : 1
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		if opacity == 1 {
			try container.encode([red, green, blue])
		} else {
			try container.encode([red, green, blue, opacity.clamped(to: 0...1)])
		}
	}
}

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
