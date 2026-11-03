import AppKit
import SwiftUI

/// Color sRGB con componentes 0–255.
struct RGB: Codable, Hashable {
    var r: Int
    var g: Int
    var b: Int
}

// MARK: - Conversión desde y hacia los tipos del sistema

extension RGB {
    /// Convierte cualquier NSColor (el que devuelve NSColorSampler) a sRGB 0–255.
    init?(_ color: NSColor) {
        guard let c = color.usingColorSpace(.sRGB) else { return nil }
        func byte(_ v: CGFloat) -> Int { Int((min(max(v, 0), 1) * 255).rounded()) }
        self.init(r: byte(c.redComponent), g: byte(c.greenComponent), b: byte(c.blueComponent))
    }

    var color: Color {
        Color(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

// MARK: - Formatos

extension RGB {
    var hex: String { String(format: "#%02X%02X%02X", r, g, b) }

    private var unit: (r: Double, g: Double, b: Double) {
        (Double(r) / 255, Double(g) / 255, Double(b) / 255)
    }

    private static func hue(_ r: Double, _ g: Double, _ b: Double, max: Double, d: Double) -> Double {
        if d == 0 { return 0 }
        let h: Double
        if max == r { h = ((g - b) / d).truncatingRemainder(dividingBy: 6) }
        else if max == g { h = (b - r) / d + 2 }
        else { h = (r - g) / d + 4 }
        return (h * 60 + 360).truncatingRemainder(dividingBy: 360)
    }

    var hsl: (h: Double, s: Double, l: Double) {
        let (r, g, b) = unit
        let mx = Swift.max(r, g, b), mn = Swift.min(r, g, b)
        let l = (mx + mn) / 2
        let d = mx - mn
        let s = d == 0 ? 0 : d / (1 - abs(2 * l - 1))
        return (Self.hue(r, g, b, max: mx, d: d), s * 100, l * 100)
    }

    var hsb: (h: Double, s: Double, b: Double) {
        let (r, g, b) = unit
        let mx = Swift.max(r, g, b), mn = Swift.min(r, g, b)
        let d = mx - mn
        return (Self.hue(r, g, b, max: mx, d: d), mx == 0 ? 0 : d / mx * 100, mx * 100)
    }

    /// Aproximación ingenua, sin perfil de color de imprenta.
    var cmyk: (c: Double, m: Double, y: Double, k: Double) {
        let k = 1 - Double(Swift.max(r, g, b)) / 255
        if k == 1 { return (0, 0, 0, 100) }
        func f(_ v: Int) -> Double { (1 - Double(v) / 255 - k) / (1 - k) * 100 }
        return (f(r), f(g), f(b), k * 100)
    }

    /// sRGB → lineal → OKLab (matrices de Björn Ottosson) → polares.
    var oklch: (l: Double, c: Double, h: Double) {
        func lin(_ v: Int) -> Double {
            let x = Double(v) / 255
            return x <= 0.04045 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4)
        }
        let (lr, lg, lb) = (lin(r), lin(g), lin(b))
        let l = cbrt(0.4122214708 * lr + 0.5363325363 * lg + 0.0514459929 * lb)
        let m = cbrt(0.2119034982 * lr + 0.6806995451 * lg + 0.1073969566 * lb)
        let s = cbrt(0.0883024619 * lr + 0.2817188376 * lg + 0.6299787005 * lb)
        let L = 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s
        let A = 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s
        let B = 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s
        let C = (A * A + B * B).squareRoot()
        let h = C < 0.0001 ? 0 : (atan2(B, A) * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
        return (L * 100, C, h)
    }

    /// Mismo orden y mismo texto que `formats()` en color.js.
    var formats: [(label: String, value: String)] {
        func n(_ v: Double, _ d: Int = 0) -> String { String(format: "%.\(d)f", v) }
        let h1 = hsl, h2 = hsb, k = cmyk, o = oklch
        return [
            ("HEX", hex),
            ("RGB", "rgb(\(r), \(g), \(b))"),
            ("HSL", "hsl(\(n(h1.h)), \(n(h1.s))%, \(n(h1.l))%)"),
            ("HSB", "hsb(\(n(h2.h)), \(n(h2.s))%, \(n(h2.b))%)"),
            ("CMYK", "cmyk(\(n(k.c))%, \(n(k.m))%, \(n(k.y))%, \(n(k.k))%)"),
            ("OKLCH", "oklch(\(n(o.l, 1))% \(n(o.c, 3)) \(n(o.h, 1)))"),
        ]
    }

    /// Texto legible sobre el color (luminancia relativa WCAG).
    var isLight: Bool {
        func lin(_ v: Int) -> Double {
            let x = Double(v) / 255
            return x <= 0.03928 ? x / 12.92 : pow((x + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b) > 0.4
    }
}

// MARK: - Crear desde otros espacios

extension RGB {
    /// h 0–360, s y b 0–1. Se usa el espacio sRGB para que coincida con `hsb`.
    init(h: Double, s: Double, b: Double) {
        let ns = NSColor(colorSpace: .sRGB, hue: h / 360, saturation: s, brightness: b, alpha: 1)
        self = RGB(ns) ?? RGB(r: 0, g: 0, b: 0)
    }

    /// Acepta "#F80", "ff8800", "rgb(255, 136, 0)", "hsl(32, 100%, 50%)",
    /// "hsb(32, 100%, 100%)", "cmyk(0%, 47%, 100%, 0%)" o simplemente "255 136 0".
    init?(parsing input: String) {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // HEX
        if let m = text.wholeMatch(of: /#?([0-9a-f]{3}|[0-9a-f]{6})/) {
            var hex = String(m.output.1)
            if hex.count == 3 { hex = hex.map { "\($0)\($0)" }.joined() }   // F80 → FF8800
            guard let v = UInt32(hex, radix: 16) else { return nil }
            self.init(r: Int(v >> 16 & 0xFF), g: Int(v >> 8 & 0xFF), b: Int(v & 0xFF))
            return
        }

        let n = text.matches(of: /\d+(\.\d+)?/).compactMap { Double($0.output.0) }
        func clamp(_ v: Double, _ hi: Double) -> Double { min(max(v, 0), hi) }

        if text.hasPrefix("hsl"), n.count >= 3 {
            // HSL → HSB y se reutiliza el init de arriba
            let h = clamp(n[0], 360), s = clamp(n[1], 100) / 100, l = clamp(n[2], 100) / 100
            let b = l + s * min(l, 1 - l)
            self.init(h: h, s: b == 0 ? 0 : 2 * (1 - l / b), b: b)
        } else if text.hasPrefix("hsb") || text.hasPrefix("hsv"), n.count >= 3 {
            self.init(h: clamp(n[0], 360), s: clamp(n[1], 100) / 100, b: clamp(n[2], 100) / 100)
        } else if text.hasPrefix("cmyk"), n.count >= 4 {
            let (c, m, y, k) = (clamp(n[0], 100) / 100, clamp(n[1], 100) / 100,
                                clamp(n[2], 100) / 100, clamp(n[3], 100) / 100)
            func ch(_ v: Double) -> Int { Int((255 * (1 - v) * (1 - k)).rounded()) }
            self.init(r: ch(c), g: ch(m), b: ch(y))
        } else if n.count >= 3 {   // "rgb(…)" o tres números sueltos
            self.init(r: Int(clamp(n[0], 255).rounded()), g: Int(clamp(n[1], 255).rounded()), b: Int(clamp(n[2], 255).rounded()))
        } else {
            return nil
        }
    }
}
