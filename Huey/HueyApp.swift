import SwiftUI
import MenuBarExtraAccess

@main
struct HueyApp: App {
    @State private var store = ColorStore()

    var body: some Scene {
        MenuBarExtra("Huey", systemImage: "eyedropper") {
            PopoverView()
                .environment(store)
        }
        .menuBarExtraAccess(isPresented: $store.isPanelOpen)
        .menuBarExtraStyle(.window)
    }
}
