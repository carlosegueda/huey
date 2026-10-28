import AppKit
import Observation
import KeyboardShortcuts

@MainActor
@Observable
final class ColorStore {
    private(set) var history: [RGB] = []
    var selected = 0

    var current: RGB? { history.indices.contains(selected) ? history[selected] : nil }

    private static let historyKey = "history"
    private static let maxHistory = 6

    init() {
        load()
        KeyboardShortcuts.onKeyUp(for: .pickColor) { [weak self] in
            self?.pick()
        }
//        KeyboardShortcuts.Recorder("Atajo:", name: .pickColor)
    }

    // MARK: Elegir

    func pick(onPicked: (() -> Void)? = nil) {
        NSColorSampler().show { [weak self] color in
            guard let color, let rgb = RGB(color) else { return } // nil = cancelado con Esc
            Task { @MainActor in
                self?.add(rgb)
                let copyOnPick = UserDefaults.standard.object(forKey: Prefs.copyOnPick) as? Bool ?? true
                if copyOnPick { Clipboard.copy(rgb.copyText) }
                onPicked?()
            }
        }
    }
    
//    func justshow(){
//        NSColorSampler().show { color in print(color as Any)
//            
//        }
//    }
//    
    // MARK: Historial

    func add(_ rgb: RGB) {
        history.removeAll { $0 == rgb }   // si ya estaba, sube al principio
        history.insert(rgb, at: 0)
        history = Array(history.prefix(Self.maxHistory))
        selected = 0
        save()
    }

    func clear() {
        history = []
        selected = 0
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.historyKey),
              let saved = try? JSONDecoder().decode([RGB].self, from: data) else { return }
        history = saved
    }

    private func save() {
        let data = try? JSONEncoder().encode(history)
        UserDefaults.standard.set(data, forKey: Self.historyKey)
    }
}
