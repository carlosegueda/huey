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

    private let sampler = ScreenSampler()

    init() {
        load()
        KeyboardShortcuts.onKeyUp(for: .pickColor) { [weak self] in
            self?.pick()
        }
    }

    // MARK: Elegir

    func pick(onPicked: (() -> Void)? = nil) {
        let handler: (NSColor?) -> Void = { [weak self] color in
            guard let color, let rgb = RGB(color) else { return } // nil = cancelado con Esc
            Task { @MainActor in
                self?.add(rgb)
                let copyOnPick = UserDefaults.standard.object(forKey: Prefs.copyOnPick) as? Bool ?? true
                if copyOnPick { Clipboard.copy(rgb.copyText) }
                onPicked?()
            }
        }
        // La lupa propia muestra los valores en vivo, pero necesita Grabación de pantalla.
        // Sin permiso, se pide y mientras tanto se usa la lupa del sistema.
        if ScreenSampler.hasPermission {
            sampler.show(completion: handler)
        } else {
            ScreenSampler.requestPermission()
            NSColorSampler().show(selectionHandler: handler)
        }
    }

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
