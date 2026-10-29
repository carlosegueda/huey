import AppKit
import ScreenCaptureKit
import SwiftUI

/// Estado de la lupa que dibuja `LoupeOverlay`.
@MainActor
@Observable
final class LoupeModel {
    /// Posición del cursor en coordenadas globales de AppKit (origen abajo a la izquierda).
    var mouse: CGPoint = NSEvent.mouseLocation
    /// Los píxeles alrededor del cursor, sin ampliar.
    var image: CGImage?
    /// El color del píxel central.
    var color: NSColor?

    var rgb: RGB? { color.flatMap { RGB($0) } }
}

/// Lupa propia: muestra en vivo el color bajo el cursor.
/// Necesita el permiso de Grabación de pantalla; sin él, `ColorStore` usa `NSColorSampler`.
@MainActor
final class ScreenSampler {
    /// Lado del cuadro capturado, en píxeles. Impar, para que haya un píxel central.
    static let gridSize = 15

    static var hasPermission: Bool { CGPreflightScreenCaptureAccess() }

    /// Muestra el aviso del sistema la primera vez; después solo devuelve false.
    static func requestPermission() { CGRequestScreenCaptureAccess() }

    private let model = LoupeModel()
    private var panels: [NSPanel] = []
    private var timer: Timer?
    private var monitor: Any?
    private var completion: ((NSColor?) -> Void)?
    private var content: SCShareableContent?
    private var ownWindows: [SCWindow] = []
    private var capturing = false
    private var needsCapture = false

    /// Abre la lupa. `completion` recibe el color elegido, o nil si se cancela con Esc.
    func show(completion: @escaping (NSColor?) -> Void) {
        guard self.completion == nil else { return }   // ya está abierta
        self.completion = completion
        start()
        // La lista de ventanas se pide con la lupa ya en pantalla: así incluye sus ventanas
        // y se pueden excluir de la captura. Si no, la lupa se capturaría a sí misma.
        Task {
            guard let content = try? await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true) else {
                finish(with: nil)
                return
            }
            let pid = ProcessInfo.processInfo.processIdentifier
            self.content = content
            ownWindows = content.windows.filter { $0.owningApplication?.processID == pid }
            capture()
        }
    }

    // MARK: Abrir y cerrar

    private func start() {
        for screen in NSScreen.screens {
            let panel = OverlayPanel(contentRect: screen.frame, styleMask: [.borderless, .nonactivatingPanel],
                                     backing: .buffered, defer: false)
            panel.level = .screenSaver
            panel.isOpaque = false
            panel.backgroundColor = NSColor(white: 0, alpha: 0.01)   // con alfa 0 los clics atravesarían la ventana
            panel.hasShadow = false
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            let hosting = NSHostingView(rootView: LoupeOverlay(model: model, screenFrame: screen.frame))
            hosting.sizingOptions = []   // que el contenido no redimensione la ventana
            panel.contentView = hosting
            panel.setFrame(screen.frame, display: true)
            panel.orderFrontRegardless()
            panels.append(panel)
        }
        NSApp.activate()
        panels.first { NSMouseInRect(NSEvent.mouseLocation, $0.frame, false) }?.makeKey()
        NSCursor.hide()

        // Clic = elegir, Esc = cancelar.
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .keyDown]) { [weak self] event in
            guard let self else { return event }
            if event.type == .leftMouseDown {
                finish(with: model.color)
                return nil
            }
            if event.keyCode == 53 {   // Esc
                finish(with: nil)
                return nil
            }
            return event
        }

        // Seguir el cursor leyendo su posición 60 veces por segundo.
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
    }

    private func finish(with color: NSColor?) {
        timer?.invalidate()
        timer = nil
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        if !panels.isEmpty { NSCursor.unhide() }
        panels.forEach { $0.orderOut(nil) }
        panels = []
        model.image = nil
        model.color = nil
        content = nil
        ownWindows = []
        let completion = self.completion
        self.completion = nil
        completion?(color)
    }

    // MARK: Captura

    private func tick() {
        let mouse = NSEvent.mouseLocation
        guard mouse != model.mouse else { return }
        model.mouse = mouse
        capture()
    }

    /// Captura el cuadro bajo el cursor. Solo hay una captura en curso; si el cursor
    /// se mueve mientras tanto, se repite al terminar con la posición más reciente.
    private func capture() {
        guard !capturing else {
            needsCapture = true
            return
        }
        let mouse = model.mouse
        guard let screen = NSScreen.screens.first(where: { NSMouseInRect(mouse, $0.frame, false) }),
              let displayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID,
              let display = content?.displays.first(where: { $0.displayID == displayID }) else { return }

        // ScreenCaptureKit mide en puntos con origen arriba a la izquierda de cada pantalla.
        let local = CGPoint(x: mouse.x - screen.frame.minX, y: screen.frame.maxY - mouse.y)
        let side = CGFloat(Self.gridSize) / screen.backingScaleFactor   // gridSize píxeles, en puntos
        let config = SCStreamConfiguration()
        config.sourceRect = CGRect(x: local.x - side / 2, y: local.y - side / 2, width: side, height: side)
        config.width = Self.gridSize
        config.height = Self.gridSize
        config.showsCursor = false
        config.colorSpaceName = CGColorSpace.sRGB
        let filter = SCContentFilter(display: display, excludingWindows: ownWindows)

        capturing = true
        Task {
            let image = try? await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
            capturing = false
            if let image, completion != nil {
                model.image = image
                let center = Self.gridSize / 2
                model.color = NSBitmapImageRep(cgImage: image).colorAt(x: center, y: center)
            }
            if needsCapture, completion != nil {
                needsCapture = false
                capture()
            }
        }
    }
}

/// Panel sin bordes que puede recibir el teclado (para Esc).
private final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
}
