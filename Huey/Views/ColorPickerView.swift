import SwiftUI

/// Selector de color: cuadrado saturación × brillo (blanco arriba-izq, negro abajo),
/// barra de tono, campo para pegar cualquier formato y lista de formatos para copiar.
struct ColorPickerView: View {
    @Environment(ColorStore.self) private var store
    let onBack: () -> Void
    let onCopy: (String) -> Void

    // El estado vive en HSB: así el tono no se pierde al bajar el brillo a negro.
    @State private var hue: Double = 0      // 0–360
    @State private var sat: Double = 1      // 0–1
    @State private var bri: Double = 1      // 0–1
    @State private var input = ""
    @State private var invalidInput = false

    private var rgb: RGB { RGB(h: hue, s: sat, b: bri) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            square
            hueBar
            inputRow
            preview
            FormatList(rgb: rgb, onCopy: onCopy)
        }
        .onAppear { if let c = store.current { set(c) } }
    }

    // MARK: Cabecera

    private var header: some View {
        HStack {
            Text("Selector de color").fontWeight(.bold)
            Spacer()
            Button { onBack() } label: {
                Image(systemName: "arrow.backward")
                    .frame(width: 16, height: 16)   // misma caja que el ⚙︎ del popover
            }
        }
        .frame(height: 24)
    }

    // MARK: Paleta

    private var square: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [.white, Color(hue: hue / 360, saturation: 1, brightness: 1)],
                               startPoint: .leading, endPoint: .trailing)
                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topLeading) {
                Circle()
                    .strokeBorder(.white, lineWidth: 2)
                    .shadow(radius: 1)
                    .frame(width: 14, height: 14)
                    .offset(x: sat * geo.size.width - 7, y: (1 - bri) * geo.size.height - 7)
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                sat = min(max(v.location.x / geo.size.width, 0), 1)
                bri = 1 - min(max(v.location.y / geo.size.height, 0), 1)
            })
        }
        .frame(height: 160)
    }

    private var hueBar: some View {
        GeometryReader { geo in
            LinearGradient(colors: stride(from: 0.0, through: 360, by: 60).map {
                Color(hue: $0 / 360, saturation: 1, brightness: 1)
            }, startPoint: .leading, endPoint: .trailing)
            .clipShape(Capsule())
            .overlay(alignment: .leading) {
                Circle()
                    .strokeBorder(.white, lineWidth: 2)
                    .shadow(radius: 1)
                    .frame(width: 14, height: 14)
                    .offset(x: hue / 360 * geo.size.width - 7)
                    .allowsHitTesting(false)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                hue = min(max(v.location.x / geo.size.width, 0), 1) * 360
            })
        }
        .frame(height: 14)
    }

    // MARK: Pegar

    private var inputRow: some View {
        HStack {
            TextField(text: $input) { Text(verbatim: "HEX, rgb(), hsl(), cmyk()…") }
                .textFieldStyle(.roundedBorder)
                .overlay(RoundedRectangle(cornerRadius: 5).strokeBorder(.red, lineWidth: 1).opacity(invalidInput ? 1 : 0))
                .onSubmit { apply(input) }
                .onChange(of: input) {
                    // En vivo: en cuanto el texto es un color válido, se mueven los pines.
                    invalidInput = false
                    if let c = RGB(parsing: input) { set(c) }
                }
            Button {
                if let text = Clipboard.read() { input = text; apply(text) }
            } label: {
                Image(systemName: "doc.on.clipboard")
            }
            .help("Pegar color")
        }
    }

    // MARK: Vista previa

    private var preview: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(rgb.color)
                .frame(height: 44)
                .overlay {
                    Text(verbatim: rgb.styledHex)
                        .font(.system(.body, design: .monospaced).weight(.semibold))
                        .foregroundStyle(rgb.isLight ? Color.black : .white)
                }
                .onTapGesture { onCopy(rgb.styledHex) }
                .help("Clic para copiar")
            Button { store.add(rgb) } label: {
                Image(systemName: "plus")
                    .frame(width: 16, height: 16)
            }
            .help("Guardar en recientes")
        }
    }

    // MARK: Ayudas

    private func apply(_ text: String) {
        if let c = RGB(parsing: text) { set(c) } else { invalidInput = true }
    }

    private func set(_ c: RGB) {
        let v = c.hsb
        hue = v.h; sat = v.s / 100; bri = v.b / 100
    }
}

#Preview {
    ColorPickerView(onBack: {}, onCopy: { _ in })
        .environment(ColorStore())
        .padding(14)
        .frame(width: 280)
}
