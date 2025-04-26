#if canImport(AppKit)
import AppKit
import Testing
@testable import SimpleColorPalette

@Suite(.serialized)
struct AppKitExtensionsTests {
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
