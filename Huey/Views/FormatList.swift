import SwiftUI

/// Lista de formatos (HEX, RGB, HSL…). Clic en una fila para copiarla.
struct FormatList: View {
    let rgb: RGB?
    let onCopy: (String) -> Void

    var body: some View {
        VStack(spacing: 2) {
            let color = rgb ?? RGB(r: 0, g: 0, b: 0)
            ForEach(color.formats, id: \.label) { item in
                let value = item.label == CopyFormat.hex.rawValue ? color.styledHex : item.value
                Button {
                    onCopy(value)
                } label: {
                    HStack {
                        Text(item.label)
                            .foregroundStyle(.secondary)
                            .frame(width: 53, alignment: .leading)
                        Text(rgb == nil ? "—" : value)
                            .lineLimit(1)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                }
                .buttonStyle(.plain)
                .disabled(rgb == nil)
            }
        }
    }
}
