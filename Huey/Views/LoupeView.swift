import SwiftUI

/// Lo que se dibuja sobre una pantalla mientras la lupa está abierta.
struct LoupeOverlay: View {
    let model: LoupeModel
    let screenFrame: CGRect

    private let loupeSize: CGFloat = 120
    private let cardOffset: CGFloat = 42   // del borde de la lupa al centro de la tarjeta

    var body: some View {
        GeometryReader { geo in
            // Cada pantalla tiene su panel; solo dibuja el que tiene el cursor.
            if NSMouseInRect(model.mouse, screenFrame, false) {
                // De coordenadas globales de AppKit a las de esta vista (origen arriba a la izquierda).
                let p = CGPoint(x: model.mouse.x - screenFrame.minX, y: screenFrame.maxY - model.mouse.y)
                let fitsBelow = p.y + loupeSize / 2 + cardOffset * 2 < geo.size.height
                let cardY = fitsBelow ? p.y + loupeSize / 2 + cardOffset : p.y - loupeSize / 2 - cardOffset
                let cardX = min(max(p.x, 100), geo.size.width - 100)

                magnifier.position(p)
                card.position(x: cardX, y: cardY)
            }
        }
    }

    // MARK: Lupa

    private var magnifier: some View {
        let cell = loupeSize / CGFloat(ScreenSampler.gridSize)
        return ZStack {
            if let image = model.image {
                Image(decorative: image, scale: 1)
                    .interpolation(.none)   // píxeles nítidos, sin suavizar
                    .resizable()
            } else {
                Color.black.opacity(0.2)
            }
            // Recuadro del píxel central, el que se elige.
            Rectangle()
                .strokeBorder(.white, lineWidth: 1.5)
                .frame(width: cell, height: cell)
                .shadow(color: .black.opacity(0.6), radius: 1)
        }
        .frame(width: loupeSize, height: loupeSize)
        .clipShape(Circle())
        .overlay(Circle().strokeBorder(model.rgb?.color ?? .white, lineWidth: 4))
        .overlay(Circle().strokeBorder(.black.opacity(0.25), lineWidth: 1))
        .shadow(color: .black.opacity(0.3), radius: 8)
    }

    // MARK: Valores

    private var card: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 6)
                .fill(model.rgb?.color ?? .clear)
                .frame(width: 36, height: 36)
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.primary.opacity(0.2)))
            VStack(alignment: .leading, spacing: 2) {
                ForEach(values, id: \.label) { item in
                    Text(verbatim: item.value)
                }
            }
            .font(.system(size: 11, design: .monospaced))
        }
        .padding(10)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .fixedSize()
    }

    private var values: [(label: String, value: String)] {
        guard let rgb = model.rgb else { return [] }
        return rgb.formats.filter { ["HEX", "RGB", "HSL"].contains($0.label) }
    }
}
