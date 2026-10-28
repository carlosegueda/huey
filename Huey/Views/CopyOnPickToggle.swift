import SwiftUI

struct CopyOnPickToggle: View {
    @AppStorage(Prefs.copyOnPick) private var copyOnPick = true

    var body: some View {
        Toggle("Copiar al elegir un color", isOn: $copyOnPick)
            .toggleStyle(.switch)
            .controlSize(.mini)
    }
}

#Preview {
    CopyOnPickToggle()
        .padding()
}
