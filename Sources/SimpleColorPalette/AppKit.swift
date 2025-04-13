#if canImport(AppKit)
import AppKit
import SwiftUI

@available(macOS 14, *)
extension ColorPalette {
	/**
	Creates a color palette from an AppKit color list.
	*/
	public init(colorList: NSColorList) {
		let colors: [Color] = colorList.allKeys.compactMap { key in
			guard let nsColor = colorList.color(withKey: key) else {
				return nil
			}

			return Color(SwiftUI.Color(nsColor).resolve(in: .init()), name: key)
		}

		self.init(
			colors,
			name: colorList.name
		)
	}
}

@available(macOS 14, *)
extension NSColorList {
	/**
	Creates a color list from a ``ColorPalette``.
	*/
	public convenience init(_ palette: ColorPalette) {
		self.init(name: palette.name ?? "")

		for (index, color) in palette.colors.enumerated() {
			insertColor(
				NSColor(Color(color)),
				key: color.name ?? Color.Resolved(color).formattedRGBForPresentation,
				at: index
			)
		}
	}
}
#endif
