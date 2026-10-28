import SwiftUI
import ServiceManagement

struct LaunchAtLoginToggle: View {
    @State private var enabled = SMAppService.mainApp.status == .enabled

    var body: some View {
        Toggle("Abrir al iniciar sesión", isOn: $enabled)
            .toggleStyle(.switch)
            .controlSize(.mini)
            .onChange(of: enabled) { _, on in
                do {
                    if on { try SMAppService.mainApp.register() }
                    else { try SMAppService.mainApp.unregister() }
                } catch {
                    enabled = SMAppService.mainApp.status == .enabled
                }
            }
    }
}
