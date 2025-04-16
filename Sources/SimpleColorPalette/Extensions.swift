#if canImport(CoreTransferable)
import CoreTransferable

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, visionOS 1, *)
extension ColorPalette: Transferable {
	public static var transferRepresentation: some TransferRepresentation {
		CodableRepresentation(contentType: .simpleColorPalette)
			.suggestedFileName {
				$0.name.flatMap {
					"\($0).color-palette"
				}
			}
	}
}
#endif

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers

extension UTType {
	/**
	- Important: Don't forget to [declare](https://github.com/simple-color-palette/spec#uniform-type-identifier) `UTImportTypeDeclarations` in `Info.plist`.
	*/
	public static var simpleColorPalette: Self {
		.init(importedAs: "com.sindresorhus.simple-color-palette", conformingTo: .json)
	}
}
#endif
