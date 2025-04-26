import SwiftUI
import Testing
@testable import SimpleColorPalette

@Suite(.serialized)
struct ColorPaletteTests {
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

	@Test
	func testHexStringInitialization() {
		// Test basic formats
		assertComponents(ColorPalette.Color.Components(hexString: "#FF0000")!, red: 1, green: 0, blue: 0)
		assertComponents(ColorPalette.Color.Components(hexString: "F00")!, red: 1, green: 0, blue: 0)

		// Test with opacity
		assertComponents(
			ColorPalette.Color.Components(hexString: "#FF000080")!,
			red: 1,
			green: 0,
			blue: 0,
			opacity: 128.0 / 255.0
		)
		assertComponents(
			ColorPalette.Color.Components(hexString: "F008")!,
			red: 1,
			green: 0,
			blue: 0,
			opacity: 8.0 / 15.0
		)

		// Test invalid formats
		for invalid in ["", "#", "#F", "#FF", "#FFFFF", "#FFFFFFF", "#GG0000"] {
			#expect(ColorPalette.Color.Components(hexString: invalid) == nil)
		}
	}

	@Test
	func testHexIntInitialization() {
		// Test basic formats
		assertComponents(ColorPalette.Color.Components(hex: 0xFF0000)!, red: 1, green: 0, blue: 0)
		assertComponents(ColorPalette.Color.Components(hex: 0xF00)!, red: 1, green: 0, blue: 0)

		// Test partial values
		let partial = ColorPalette.Color.Components(hex: 0x123456)!
		assertComponents(
			partial,
			red: Double(0x12) / 255,
			green: Double(0x34) / 255,
			blue: Double(0x56) / 255
		)

		// Test with opacity
		assertComponents(
			ColorPalette.Color.Components(hex: 0xFF000080)!,
			red: 1,
			green: 0,
			blue: 0,
			opacity: 128.0 / 255.0
		)

		// Test invalid values
		#expect(ColorPalette.Color.Components(hex: -1) == nil)
		#expect(ColorPalette.Color.Components(hex: 0x1_0000_0000) == nil)
	}

	@Test
	func testHexRoundTrip() {
		let originalHex = 0xFF8040
		let components = ColorPalette.Color.Components(hex: originalHex)!

		// Convert back to hex (this would be a new method we need to add)
		let red = Int(components.red * 255)
		let green = Int(components.green * 255)
		let blue = Int(components.blue * 255)
		let reconstructedHex = (red << 16) | (green << 8) | blue

		#expect(reconstructedHex == originalHex)
	}
}
