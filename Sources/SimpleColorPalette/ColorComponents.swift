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

		- Note: Values are rounded to 4 decimal places. Opacity is clamped to 0...1.
		*/
		public init(
			red: Double,
			green: Double,
			blue: Double,
			opacity: Double = 1
		) {
			// We don't also round when setting the properties later on to maintain precision during calculations (like `red += 0.1`). Rounding only happens during initialization and serialization.

			self.red = red.rounded(toPlaces: 4)
			self.green = green.rounded(toPlaces: 4)
			self.blue = blue.rounded(toPlaces: 4)
			self.opacity = opacity.rounded(toPlaces: 4).clamped(to: 0...1)
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
				red.rounded(toPlaces: 4),
				green.rounded(toPlaces: 4),
				blue.rounded(toPlaces: 4)
			])
		} else {
			try container.encode([
				red.rounded(toPlaces: 4),
				green.rounded(toPlaces: 4),
				blue.rounded(toPlaces: 4),
				opacity.rounded(toPlaces: 4).clamped(to: 0...1)
			])
		}
	}
}
