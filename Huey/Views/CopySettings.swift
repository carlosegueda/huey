import SwiftUI

struct CopySettings: View {
    @AppStorage(Prefs.copyFormat) private var copyFormat = CopyFormat.hex
    @AppStorage(Prefs.hexLowercase) private var hexLowercase = false
    @AppStorage(Prefs.hexIncludesHash) private var hexIncludesHash = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Picker("Formato a copiar", selection: $copyFormat) {
                ForEach(CopyFormat.allCases) { format in
                    Text(format.rawValue).tag(format)
                }
            }
            .controlSize(.small)

            Toggle("HEX en minúsculas", isOn: $hexLowercase)
                .toggleStyle(.switch)
                .controlSize(.mini)

            Toggle("Incluir # en el HEX", isOn: $hexIncludesHash)
                .toggleStyle(.switch)
                .controlSize(.mini)
        }
    }
}

#Preview {
    CopySettings()
        .padding()
}
