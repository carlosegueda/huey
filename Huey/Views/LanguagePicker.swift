import SwiftUI

struct LanguagePicker: View {
    @AppStorage(Prefs.language) private var language = AppLanguage.english

    var body: some View {
        Picker("Idioma", selection: $language) {
            ForEach(AppLanguage.allCases) { lang in
                Text(verbatim: lang.name).tag(lang)
            }
        }
        .controlSize(.small)
    }
}

#Preview {
    LanguagePicker()
        .padding()
}
