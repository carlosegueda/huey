import SwiftUI

struct PopoverView: View {
    @Environment(ColorStore.self) private var store
    @State private var toast: String?
    @State private var showSettings = false
    @AppStorage("closeAfterPick") private var closeAfterPick = true
    @AppStorage(Prefs.hexLowercase) private var hexLowercase = false      // redibuja al cambiar el estilo del HEX
    @AppStorage(Prefs.hexIncludesHash) private var hexIncludesHash = true
    @Binding var isPresented: Bool

    var body: some View {
          ZStack(alignment: .topLeading) {
              mainView
                  .opacity(showSettings ? 0 : 1)   // invisible, pero sigue ocupando espacio
                  .disabled(showSettings)          // y no se puede pulsar (ni Enter)

              if showSettings {
                  SettingsView { showSettings = false }
                      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
              }
          }
          .padding(14)
          .frame(width: 280)
          .overlay(alignment: .top) { toastView }
      }
    
    
    // MARK: mainview
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
    
    // MARK: header
    
    
    private var header: some View{
        HStack{
           
            Text("Huey").fontWeight(.bold)
            Spacer()
            Button { NSApplication.shared.terminate(nil)} label: {
                 Image(systemName: "power")
             }
            
        }
    }
     

    // MARK: Muestra grande

    private var swatch: some View {
        let color = store.current
        return RoundedRectangle(cornerRadius: 10)
            .fill(color?.color ?? Color.secondary.opacity(0.15))
            .frame(height: 72)
            .overlay {
                Text(color?.hex ?? "Sin color")
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
                    .help(c.map { "\($0.hex) — clic para ver, doble clic para copiar" } ?? "")
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
                store.pick {
                    if !closeAfterPick {
                                  isPresented = true
                              }
                }} label: {
                 Image(systemName: "eyedropper")
                }.keyboardShortcut(.defaultAction)
            Spacer()
            Button { showSettings = true } label: {
            Image(systemName: "gearshape")
            }
        }
    }

    
    
    
    
    
    // MARK: Aviso "Copiado"

    @ViewBuilder private var toastView: some View {
        if let toast {
            Text(toast)
                .font(.caption)
                .padding(.horizontal, 20).padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .padding(.top, 70)
                .transition(.opacity)
        }
    }

    private func copy(_ text: String) {
        Clipboard.copy(text)
        withAnimation { toast = "Copiado \(text)" }
        Task {
            try? await Task.sleep(for: .seconds(1.1))
            withAnimation { if toast == "Copiado \(text)" { toast = nil } }
        }
    }
}

#Preview {
    PopoverView(isPresented: .constant(true)).environment(ColorStore())
    
}
