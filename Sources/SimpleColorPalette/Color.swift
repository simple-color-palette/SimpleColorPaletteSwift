import Foundation

extension ColorPalette {
	/**
	Represents a single color.

	- Tip: When working with pasteboard or `NSFileProvider`, convert individual colors to `NSColor`/`UIColor` via `SwiftUI.Color` first.
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

extension ColorPalette.Color: Codable {
	enum CodingKeys: String, CodingKey {
		case name
		case linearComponents = "components"
	}
}
