#if canImport(SwiftUI)
import SwiftUI
#endif

extension Float {
	var toDouble: Double { .init(self) }
}

extension Double {
	var toFloat: Float { .init(self) }
}


extension Comparable {
	func clamped(to range: ClosedRange<Self>) -> Self {
		min(max(self, range.lowerBound), range.upperBound)
	}

	func clamped(to range: PartialRangeThrough<Self>) -> Self {
		min(self, range.upperBound)
	}

	func clamped(to range: PartialRangeFrom<Self>) -> Self {
		max(self, range.lowerBound)
	}
}


extension Double {
	/**
	Rounds the number to specified decimal places using banker's rounding.

	- Parameter places: Number of decimal places (must be >= 0).
	- Returns: The rounded number.
	*/
	func rounded(toPlaces places: Int) -> Self {
		guard places >= 0 else {
			return self
		}

		let multiplier = pow(10.0, Self(places))
		return (self * multiplier).rounded(.toNearestOrEven) / multiplier
	}
}


#if canImport(SwiftUI)
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
extension Color.Resolved {
	var formattedRGBForPresentation: String {
		let red = Int((red * 0xFF).rounded())
		let green = Int((green * 0xFF).rounded())
		let blue = Int((blue * 0xFF).rounded())
		let opacity = Int((opacity.clamped(to: 0...1) * 100).rounded())

		return opacity < 100
			? String(format: "%d %d %d %d%%", red, green, blue, opacity)
			: String(format: "%d %d %d", red, green, blue)
	}
}
#endif
