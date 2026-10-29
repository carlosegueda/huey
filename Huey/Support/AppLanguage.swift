import Foundation

/// Idiomas de la interfaz. El rawValue es el identificador de Locale.
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"
    case portuguese = "pt-BR"
    case russian = "ru"

    var id: String { rawValue }

    /// Nombre en su propio idioma, para que siempre se reconozca en el menú.
    var name: String {
        switch self {
        case .english: "English"
        case .spanish: "Español"
        case .portuguese: "Português"
        case .russian: "Русский"
        }
    }
}
