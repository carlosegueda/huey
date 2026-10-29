import SwiftUI

struct PopoverView: View {
    @Environment(ColorStore.self) private var store
    @State private var toast: String?
    @State private var showSettings = false
    @AppStorage(Prefs.hexLowercase) private var hexLowercase = false      // redibuja al cambiar el estilo del HEX
    @AppStorage(Prefs.hexIncludesHash) private var hexIncludesHash = true
    @AppStorage(Prefs.language) private var language = AppLanguage.english

    var body: some View {
        Group {
            if showSettings {
                SettingsView {
                    withAnimation(.smooth(duration: 0.3)) { showSettings = false }
                }
                .transition(.opacity)
            } else {
                mainView
                    .transition(.opacity)
            }
        }
        .padding(14)
        .frame(width: 280)
        .overlay(alignment: .top) { toastView }
        .environment(\.locale, Locale(identifier: language.rawValue))   // idioma de todos los textos de dentro
    }

    // MARK: Pantalla principal

    private var mainView: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            Divider()
            swatch
            formatList
            historyRow
            Divider()
            footer
        }
    }

    // MARK: Cabecera

    private var header: some View {
        HStack {
            Text("Huey").fontWeight(.bold)
            Spacer()
            Button {
                withAnimation(.smooth(duration: 0.3)) { showSettings = true }
            } label: {
                Image(systemName: "gearshape")
                    .frame(width: 16, height: 16)   // misma caja que el ← de Configuración
            }
        }
        .frame(height: 24)
    }

    // MARK: Muestra grande

    private var swatch: some View {
        let color = store.current
        return RoundedRectangle(cornerRadius: 10)
            .fill(color?.color ?? Color.secondary.opacity(0.15))
            .frame(height: 72)
            .overlay {
                (color.map { Text(verbatim: $0.hex) } ?? Text("Sin color"))
                    .font(.system(.title3, design: .monospaced).weight(.semibold))
                    .foregroundStyle(color.map { $0.isLight ? Color.black : .white } ?? .secondary)
            }
    }

    // MARK: Formatos

    private var formatList: some View {
        VStack(spacing: 2) {
            let rgb = store.current ?? RGB(r: 0, g: 0, b: 0)
            ForEach(rgb.formats, id: \.label) { item in
                let value = item.label == CopyFormat.hex.rawValue ? rgb.styledHex : item.value
                Button {
                    copy(value)
                } label: {
                    HStack {
                        Text(item.label)
                            .foregroundStyle(.secondary)
                            .frame(width: 53, alignment: .leading)
                        Text(store.current == nil ? "—" : value)
                            .lineLimit(1)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                }
                .buttonStyle(.plain)
                .disabled(store.current == nil)
            }
        }
    }

    // MARK: Recientes

    private var historyRow: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { i in
                let c = store.history.indices.contains(i) ? store.history[i] : nil
                Circle()
                    .fill(c?.color ?? Color.clear)
                    .overlay(Circle().strokeBorder(.secondary.opacity(0.4), lineWidth: 1))
                    .overlay(Circle().strokeBorder(.primary, lineWidth: 2).opacity(c != nil && i == store.selected ? 1 : 0))
                    .frame(width: 26, height: 26)
                    .help(c.map { Text("\($0.hex) — clic para ver, doble clic para copiar") } ?? Text(verbatim: ""))
                    .onTapGesture(count: 2) { if let c { copy(c.copyText) } }
                    .onTapGesture { if c != nil { store.selected = i } }
            }
            Spacer()
            if !store.history.isEmpty {
                Button { store.clear() } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.borderless)
                .help("Borrar historial")
            }
        }
    }

    // MARK: Pie

    private var footer: some View {
        HStack {
            Button {
                store.pick()
            } label: {
                Image(systemName: "eyedropper")
            }
            .keyboardShortcut(.defaultAction)
            Spacer()
            Button { NSApplication.shared.terminate(nil) } label: {
                Image(systemName: "power")
            }
        }
        .frame(height: 24)
    }

    // MARK: Aviso "Copiado"

    @ViewBuilder private var toastView: some View {
        if let toast {
            Text("Copiado \(toast)")
                .font(.caption)
                .padding(.horizontal, 20).padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .padding(.top, 85)
                .transition(.scale(scale: 0.95).combined(with: .opacity))
        }
    }

    private func copy(_ text: String) {
        Clipboard.copy(text)
        withAnimation(.smooth(duration: 0.3)) { toast = text }
        Task {
            try? await Task.sleep(for: .seconds(1.1))
            withAnimation(.smooth(duration: 0.3)) { if toast == text { toast = nil } }
        }
    }
}

#Preview {
    PopoverView().environment(ColorStore())
}
