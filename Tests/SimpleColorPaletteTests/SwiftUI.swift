#if canImport(SwiftUI)
import SwiftUI
import Testing
@testable import SimpleColorPalette

@Suite(.serialized)
struct SwiftUIExtensionsTests {
	private let testColor = ColorPalette.Color(
		components: .init(red: 0.5, green: 0.7, blue: 0.3, opacity: 0.8),
		name: "Test"
	)

	private func assertResolvedColor(
		_ color: Color.Resolved,
		red: Float,
		green: Float,
		blue: Float,
		opacity: Float = 1,
		precision: Float = 0.0001
	) {
		#expect(abs(color.red - red) < precision)
		#expect(abs(color.green - green) < precision)
		#expect(abs(color.blue - blue) < precision)
		#expect(abs(color.opacity - opacity) < precision)
	}

	@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
	@Test
	func testColorConversions() {
		let swiftUIColor = Color(testColor)
		let resolved = swiftUIColor.resolve(in: .init())

		assertResolvedColor(
			resolved,
			red: 0.5,
			green: 0.7,
			blue: 0.3,
			opacity: 0.8
		)

		let paletteColor = ColorPalette.Color(resolved, name: "Test")
		let components = paletteColor.components

		#expect(abs(components.red - 0.5) < 0.0001)
		#expect(abs(components.green - 0.7) < 0.0001)
		#expect(abs(components.blue - 0.3) < 0.0001)
		#expect(abs(components.opacity - 0.8) < 0.0001)
		#expect(paletteColor.name == "Test")
	}

	@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
	@Test
	func testResolvedColors() {
		let resolved = [
			Color.Resolved(colorSpace: .sRGB, red: 1, green: 0, blue: 0, opacity: 1),
			Color.Resolved(colorSpace: .sRGB, red: 0, green: 1, blue: 0, opacity: 0.5)
		]

		var palette = ColorPalette(resolvedColors: resolved)
		#expect(palette.colors.count == 2)

		let retrieved = palette.resolvedColors
		for (orig, ret) in zip(resolved, retrieved) {
			assertResolvedColor(
				ret,
				red: orig.red,
				green: orig.green,
				blue: orig.blue,
				opacity: orig.opacity
			)
		}

		// Test setter
		palette.resolvedColors = [resolved[0]]
		#expect(palette.colors.count == 1)
		assertResolvedColor(
			palette.resolvedColors[0],
			red: 1,
			green: 0,
			blue: 0
		)
	}
}
#endif
