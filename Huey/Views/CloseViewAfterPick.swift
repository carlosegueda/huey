import SwiftUI

struct CloseViewAfterPick: View {
    @AppStorage(Prefs.closeAfterPick) private var closeAfterPick = true

    var body: some View {
        Toggle("Cerrar al seleccionar un color", isOn: $closeAfterPick)
            .toggleStyle(.switch)
            .controlSize(.mini)
    }
}
