import SwiftUI

struct SettingsView: View {
    let onBack: () -> Void          // "prop" función: quién me usa decide qué pasa al volver

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Configuración").fontWeight(.bold)
                Spacer()
                Button { onBack() } label: {
                    Image(systemName: "arrow.backward")
                        .frame(width: 16, height: 16)   // misma caja que el ⚙︎ del popover
                }
            }
            .frame(height: 24)
            Divider()
            CopyOnPickToggle()
            LaunchAtLoginToggle()
            CloseViewAfterPick()
            CopySettings()
            LanguagePicker()
            Spacer()
            Text("Versión \(appVersion)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
            footer
        }
    }

    /// "1.0.0 (1)": Version y Build del target, leídos del Info.plist.
    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "?"
        let build = info?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }

    private var footer: some View {
        HStack {
            Spacer()
            Button { NSApplication.shared.terminate(nil) } label: {
                Image(systemName: "power")
            }
        }
        .frame(height: 24)
    }
}

#Preview {
    SettingsView(onBack: { print("atrás") })
        .padding(14)
        .frame(width: 280)
}
