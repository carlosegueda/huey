import SwiftUI
import MenuBarExtraAccess

@main
struct HueyApp: App {
    @State private var store = ColorStore()
    @State private var isMenuPresented = false

    var body: some Scene {
        MenuBarExtra("Huey", systemImage: "eyedropper") {
            PopoverView(isPresented: $isMenuPresented)
                .environment(store)
        }
        .menuBarExtraAccess(isPresented: $isMenuPresented)
        .menuBarExtraStyle(.window)
     
    }   
}
