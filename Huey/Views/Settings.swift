import SwiftUI

  struct SettingsView: View {
      let onBack: () -> Void          // "prop" función: quién me usa decide qué pasa al volver

      var body: some View {
          VStack(alignment: .leading, spacing: 12) {
              
              
//              .buttonStyle(.borderless)

//              Button { store.clear() } label: {
//                   Image(systemName: "trash.circle.fill")
//                       .font(.system(size: 18))
//                       .foregroundStyle(.secondary)
//               }
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
              Divider()
              footer
          }
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
