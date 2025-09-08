//
//  LanguageSelectionView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftUI
import DBMultiverseComicKit

struct LanguageSelectionView: View {
    @State var selection: ComicLanguage
    @State private var didChangeLanguage = false
    @Environment(\.dismiss) private var dismiss
    
    let updateLanguage: (ComicLanguage) -> Void
    
    var body: some View {
        VStack {
            Text(selection.displayName)
                .withFont(.largeTitle, textColor: didChangeLanguage ? .red : .primary, autoSizeLineLimit: 1)
            
            LanguagePicker(selection: $selection)
                .padding(.vertical)
            
            VStack {
                Spacer()
                Text("If you change your language, all your cached image data will be reset.")
                    .padding()
                    .withFont()
                    .multilineTextAlignment(.center)
                
                Spacer()
                Button("Update Language") {
                    updateLanguage(selection)
                    dismiss()
                }
                .tint(.red)
                .withFont()
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .onlyShow(when: didChangeLanguage)
        }
        .navigationBarBackButtonHidden(true)
        .animation(.easeInOut, value: didChangeLanguage)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .trackingItemChanges(item: selection, itemDidChange: $didChangeLanguage)
        .withDiscardChangesNavBarDismissButton(
            message: "You've selected a new language.",
            itemToModify: selection,
            dismissButtonInfo: .init(prompt: "Don't change language.")
        )
    }
}


// MARK: - Preview
#Preview {
    LanguageSelectionView(selection: .english, updateLanguage: { _ in })
}
