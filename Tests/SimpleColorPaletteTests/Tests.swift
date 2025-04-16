import SwiftUI
import Testing
@testable import SimpleColorPalette

@Suite(.serialized)
final class ColorPaletteTests {
	private func assertComponents(
		_ components: ColorPalette.Color.Components,
		red: Double,
		green: Double,
		blue: Double,
		opacity: Double = 1,
		precision: Double = 0.0001
	) {
		#expect(abs(components.red - red) < precision)
		#expect(abs(components.green - green) < precision)
		#expect(abs(components.blue - blue) < precision)
		#expect(abs(components.opacity - opacity) < precision)
	}

	@Test
	func testOpacityClamping() {
		let high = ColorPalette.Color.Components(red: 0, green: 0, blue: 0, opacity: 1.5)
		let low = ColorPalette.Color.Components(red: 0, green: 0, blue: 0, opacity: -0.5)

		#expect(high.opacity == 1.0)
		#expect(low.opacity == 0.0)
	}

	@Test
	func testLinearConversion() {
		let color = ColorPalette.Color(
			components: .init(red: 0.5, green: 0.7, blue: 0.3, opacity: 0.8)
		)

		let reconverted = ColorPalette.Color(components: color.components)
		assertComponents(
			reconverted.linearComponents,
			red: color.linearComponents.red,
			green: color.linearComponents.green,
			blue: color.linearComponents.blue,
			opacity: 0.8
		)
	}

	@Test
	func testSerialization() throws {
		let original = ColorPalette(
			[
				.init(components: .init(red: 1, green: 0, blue: 0), name: "Red"),
				.init(components: .init(red: 0, green: 1, blue: 0, opacity: 0.5), name: "Green")
			],
			name: "Test"
		)

		let data = try original.serialized()
		let decoded = try ColorPalette(serialized: data)

		#expect(decoded.name == original.name)
		#expect(decoded.colors.count == original.colors.count)

		for (orig, dec) in zip(original.colors, decoded.colors) {
			#expect(orig.name == dec.name)
			assertComponents(
				dec.components,
				red: orig.components.red,
				green: orig.components.green,
				blue: orig.components.blue,
				opacity: orig.components.opacity
			)
		}
	}

	@Test
	func testFileOperations() throws {
		let original = ColorPalette(
			[.init(components: .init(red: 1, green: 0, blue: 0), name: "Red")],
			name: "Test"
		)

		let url = FileManager.default.temporaryDirectory.appending(
			path: "test.color-palette",
			directoryHint: .notDirectory
		)

		try original.write(to: url)
		let loaded = try ColorPalette(contentsOf: url)

		#expect(loaded.name == original.name)
		#expect(loaded.colors.count == original.colors.count)

		try? FileManager.default.removeItem(at: url)
	}

	@Test
	func testEmptyPalette() throws {
		let empty = ColorPalette([], name: nil)
		let decoded = try ColorPalette(serialized: empty.serialized())

		#expect(decoded.colors.isEmpty)
		#expect(decoded.name == nil)
	}

	@Test
	func testInvalidData() {
		let invalidData = """
		{"colors":[{"components":[1.0],"name":"Invalid"}]}
		""".data(using: .utf8)!

		#expect(throws: ColorPalette.Color.Components.CodingError.invalidComponentCount) {
			_ = try ColorPalette(serialized: invalidData)
		}
	}

	@Test
	func testPrecision() throws {
		let color = ColorPalette.Color.Components(
			red: 0.12345,    // Should round to 0.1234 (actual behavior)
			green: 0.12350,  // Should round to 0.1235
			blue: 0.12344,   // Should round to 0.1234
			opacity: 0.12349 // Should round to 0.1235
		)

		let data = try JSONEncoder().encode(color)
		let json = String(data: data, encoding: .utf8)!

		#expect(json == "[0.1234,0.1235,0.1234,0.1235]")
	}
}

#if canImport(SwiftUI)
import SwiftUI

@Suite(.serialized)
final class SwiftUIExtensionsTests {
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

#if canImport(AppKit)
import AppKit

@Suite(.serialized)
final class AppKitExtensionsTests {
	private func createTestPalette() -> ColorPalette {
		ColorPalette(
			[
				.init(components: .init(red: 1, green: 0, blue: 0), name: "Red"),
				.init(components: .init(red: 0, green: 1, blue: 0, opacity: 0.5), name: "Green")
			],
			name: "Test"
		)
	}

	// swiftlint:disable no_cgfloat
	private func assertNSColor(
		_ color: NSColor?,
		red: CGFloat,
		green: CGFloat,
		blue: CGFloat,
		alpha: CGFloat = 1,
		precision: CGFloat = 0.0001
	) {
		var red2: CGFloat = 0
		var green2: CGFloat = 0
		var blue2: CGFloat = 0
		var alpha2: CGFloat = 0
		color?.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
		#expect(abs(red2 - red) < precision)
		#expect(abs(green2 - green) < precision)
		#expect(abs(blue2 - blue) < precision)
		#expect(abs(alpha2 - alpha) < precision)
	}
	// swiftlint:enable no_cgfloat

	@available(macOS 14, *)
	@Test
	func testConversions() {
		let colorList = NSColorList(name: "Test")
		colorList.insertColor(NSColor.red, key: "Red", at: 0)
		colorList.insertColor(
			NSColor(red: 0, green: 1, blue: 0, alpha: 0.5),
			key: "Green",
			at: 1
		)

		let palette = ColorPalette(colorList: colorList)
		#expect(palette.name == "Test")
		#expect(palette.colors.count == 2)
		#expect(palette.colors[0].name == "Red")
		#expect(palette.colors[1].name == "Green")

		let newList = NSColorList(palette)
		#expect(newList.name == "Test")
		#expect(newList.allKeys.count == 2)
		assertNSColor(newList.color(withKey: "Red"), red: 1, green: 0, blue: 0)
		assertNSColor(
			newList.color(withKey: "Green"),
			red: 0,
			green: 1,
			blue: 0,
			alpha: 0.5
		)
	}

	@available(macOS 14, *)
	@Test
	func testUnnamedColors() {
		let palette = ColorPalette(
			[
				.init(components: .init(red: 1, green: 0, blue: 0)),
				.init(components: .init(red: 0, green: 1, blue: 0, opacity: 0.5))
			]
		)

		let list = NSColorList(palette)
		#expect(list.allKeys.count == 2)
		#expect(list.allKeys[0] == "255 0 0")
		#expect(list.allKeys[1] == "0 255 0 50%")
	}

	@available(macOS 14, *)
	@Test
	func testEmptyColorList() {
		let emptyList = NSColorList(name: "Empty")
		let palette = ColorPalette(colorList: emptyList)
		#expect(palette.colors.isEmpty)
		#expect(palette.name == "Empty")

		let newList = NSColorList(ColorPalette([], name: "Empty"))
		#expect(newList.allKeys.isEmpty)
		#expect(newList.name == "Empty")
	}
}
#endif
