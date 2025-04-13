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
