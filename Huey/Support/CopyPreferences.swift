import Foundation

/// Claves de UserDefaults compartidas entre @AppStorage y el modelo.
enum Prefs {
    static let language = "language"
    static let copyOnPick = "copyOnPick"
    static let copyFormat = "copyFormat"
    static let hexLowercase = "hexLowercase"
    static let hexIncludesHash = "hexIncludesHash"
}

/// Formato que se copia al elegir un color. El rawValue coincide con las etiquetas de `RGB.formats`.
enum CopyFormat: String, CaseIterable, Identifiable {
    case hex = "HEX"
    case rgb = "RGB"
    case hsl = "HSL"
    case hsb = "HSB"
    case cmyk = "CMYK"
    case oklch = "OKLCH"

    var id: String { rawValue }
}

extension RGB {
    /// HEX según las preferencias de minúsculas y "#".
    var styledHex: String {
        let defaults = UserDefaults.standard
        var text = hex
        if defaults.bool(forKey: Prefs.hexLowercase) { text = text.lowercased() }
        let includesHash = defaults.object(forKey: Prefs.hexIncludesHash) as? Bool ?? true
        if !includesHash { text.removeFirst() }
        return text
    }

    /// Texto que se copia al elegir, según el formato elegido en Ajustes.
    var copyText: String {
        let raw = UserDefaults.standard.string(forKey: Prefs.copyFormat) ?? ""
        let format = CopyFormat(rawValue: raw) ?? .hex
        if format == .hex { return styledHex }
        return formats.first { $0.label == format.rawValue }?.value ?? styledHex
    }
}
