#if canImport(SwiftUI)
import SwiftUI

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
extension ColorPalette.Color {
	/**
	Creates a color from a resolved SwiftUI color.
	*/
	public init(_ color: Color.Resolved, name: String? = nil) {
		self.init(
			linearComponents: .init(
				red: color.linearRed.toDouble,
				green: color.linearGreen.toDouble,
				blue: color.linearBlue.toDouble,
				opacity: color.opacity.toDouble
			),
			name: name
		)
	}
}

// We intentionally don't have a init that accepts `ColorPalette.Color.Components` as it would not be clear that it's in the right format.
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
extension Color.Resolved {
	/**
	Creates a color from a ``ColorPalette`` color.
	*/
	public init(_ color: ColorPalette.Color) {
		let components = color.linearComponents
		self.init(
			colorSpace: .sRGBLinear,
			red: components.red.toFloat,
			green: components.green.toFloat,
			blue: components.blue.toFloat,
			opacity: components.opacity.toFloat
		)
	}
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
extension Color {
	/**
	Creates a color from a ``ColorPalette`` color.
	*/
	public init(_ color: ColorPalette.Color) {
		self.init(Color.Resolved(color))
	}
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
extension ColorPalette {
	/**
	Creates a color palette from an array of resolved SwiftUI colors.

	- Parameter resolvedColors: Array of resolved resolved SwiftUI colors to include in the palette.
	- Parameter name: Optional name for the palette.
	*/
	public init(
		resolvedColors: [SwiftUI.Color.Resolved],
		name: String? = nil
	) {
		self.init(
			resolvedColors.map { ColorPalette.Color($0) },
			name: name
		)
	}
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
extension ColorPalette {
	/**
	The colors in the palette as resolved SwiftUI colors.
	*/
	public var resolvedColors: [SwiftUI.Color.Resolved] {
		get {
			colors.map { .init($0) }
		}
		set {
			colors = newValue.map { .init($0) }
		}
	}
}
#endif
