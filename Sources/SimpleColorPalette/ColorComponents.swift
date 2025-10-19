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

		/**
		Creates color components.

		- Note: Values are rounded to 5 decimal places. Opacity is clamped to 0...1.
		*/
		public init(
			red: Double,
			green: Double,
			blue: Double,
			opacity: Double = 1
		) {
			// We don't also round when setting the properties later on to maintain precision during calculations (like `red += 0.1`). Rounding only happens during initialization and serialization.

			self.red = red.rounded(toPlaces: 5)
			self.green = green.rounded(toPlaces: 5)
			self.blue = blue.rounded(toPlaces: 5)
			self.opacity = opacity.rounded(toPlaces: 5).clamped(to: 0...1)
		}
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

		self.init(
			red: components[0],
			green: components[1],
			blue: components[2],
			opacity: components.count == 4 ? components[3] : 1
		)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		if opacity == 1 {
			try container.encode([
				red.rounded(toPlaces: 5),
				green.rounded(toPlaces: 5),
				blue.rounded(toPlaces: 5)
			])
		} else {
			try container.encode([
				red.rounded(toPlaces: 5),
				green.rounded(toPlaces: 5),
				blue.rounded(toPlaces: 5),
				opacity.rounded(toPlaces: 5).clamped(to: 0...1)
			])
		}
	}
}

extension ColorPalette.Color.Components {
	/**
	Creates color components from a hex string.

	Supports the following formats:
	- RGB: `"#F00"` → red
	- RGBA: `"#F008"` → red with 50% opacity
	- RRGGBB: `"#FF0000"` → red
	- RRGGBBAA: `"#FF000080"` → red with 50% opacity

	The `#` prefix is optional. Both uppercase and lowercase hex digits are supported.

	- Note: The input is expected to be in sRGB color space, which is the standard color space for hex colors on the web and in design tools.

	```swift
	let red = ColorPalette.Color.Components(hexString: "#ff0000")
	let green = ColorPalette.Color.Components(hexString: "00ff00")
	let blue = ColorPalette.Color.Components(hexString: "#00f") // Short form
	let withHalfOpacity = ColorPalette.Color.Components(hexString: "#ff000080") // 50% opacity
	```

	- Note: Converting back to hex is not supported since the components can contain values outside the 0-1 range (wide gamut colors) which cannot be represented in the sRGB hex format.
	*/
	public init?(hexString: String) {
		var string = hexString.trimmingCharacters(in: .whitespaces)

		if string.hasPrefix("#") {
			string = String(string.dropFirst())
		}

		// Convert 3/4 character hex to 6/8 character hex
		if string.count == 3 || string.count == 4 {
			string = string.map { "\($0)\($0)" }.joined()
		}

		guard
			string.count == 6 || string.count == 8,
			let hexValue = Int(string, radix: 16)
		else {
			return nil
		}

		self.init(hex: hexValue)
	}

	/**
	Creates color components from a hex number.

	Supports the following formats:
	- RGB: `0xF00` → red
	- RGBA: `0xF008` → red with 50% opacity
	- RRGGBB: `0xFF0000` → red
	- RRGGBBAA: `0xFF000080` → red with 50% opacity

	- Note: The input is expected to be in sRGB color space, which is the standard color space for hex colors on the web and in design tools.

	```swift
	let red = ColorPalette.Color.Components(hex: 0xFF0000)
	let green = ColorPalette.Color.Components(hex: 0x00FF00)
	let blue = ColorPalette.Color.Components(hex: 0x00F)
	let withHalfOpacity = ColorPalette.Color.Components(hex: 0xFF000080) // 50% opacity
	```

	- Note: Converting back to hex is not supported since the components can contain values outside the 0-1 range (wide gamut colors) which cannot be represented in the sRGB hex format.
	*/
	public init?(hex: Int) {
		let red, green, blue, opacity: Double

		switch hex {
		case 0...0xFFF: // 12-bit RGB
			red = Double((hex >> 8) & 0xF) / 15
			green = Double((hex >> 4) & 0xF) / 15
			blue = Double(hex & 0xF) / 15
			opacity = 1
		case 0x1000...0xFFFF: // 16-bit RGBA
			red = Double((hex >> 12) & 0xF) / 15
			green = Double((hex >> 8) & 0xF) / 15
			blue = Double((hex >> 4) & 0xF) / 15
			opacity = Double(hex & 0xF) / 15
		case 0x10000...0xFFFFFF: // 24-bit RGB
			red = Double((hex >> 16) & 0xFF) / 255
			green = Double((hex >> 8) & 0xFF) / 255
			blue = Double(hex & 0xFF) / 255
			opacity = 1
		case 0x1000000...0xFFFFFFFF: // 32-bit RGBA
			red = Double((hex >> 24) & 0xFF) / 255
			green = Double((hex >> 16) & 0xFF) / 255
			blue = Double((hex >> 8) & 0xFF) / 255
			opacity = Double(hex & 0xFF) / 255
		default:
			return nil
		}

		self.init(
			red: red,
			green: green,
			blue: blue,
			opacity: opacity
		)
	}
}
