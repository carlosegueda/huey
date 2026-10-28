import SwiftUI

  struct SettingsView: View {
      let onBack: () -> Void          // "prop" función: quién me usa decide qué pasa al volver

      var body: some View {
          VStack(alignment: .leading, spacing: 20) {
              
              Button { onBack() } label: {
                   Image(systemName: "arrow.backward")
               }
              
//              .buttonStyle(.borderless)
              
//              Button { store.clear() } label: {
//                   Image(systemName: "trash.circle.fill")
//                       .font(.system(size: 18))
//                       .foregroundStyle(.secondary)
//               }
              Divider()
              CopyOnPickToggle()
              LaunchAtLoginToggle()
              CloseViewAfterPick()
              CopySettings()
              Spacer()
              Divider()
              footer
          }
      }
  }

private var footer: some View {
    HStack {
        Spacer()
        Button { NSApplication.shared.terminate(nil)} label: {
             Image(systemName: "power")
         }
    }
}




  #Preview {
      SettingsView(onBack: { print("atrás") })
          .padding(14)
          .frame(width: 280)
  }
