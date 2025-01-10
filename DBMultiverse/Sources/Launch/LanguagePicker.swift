//
//  LanguagePicker.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftUI
import DBMultiverseComicKit

struct LanguagePicker: View {
    @Binding var selection: ComicLanguage
    
    var body: some View {
        Picker("Language", selection: $selection) {
            ForEach(ComicLanguage.allCases, id: \.rawValue) { language in
                Text(language.displayName)
                    .withFont()
                    .tag(language)
            }
        }
        .pickerStyle(.wheel)
    }
}
