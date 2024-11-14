//
//  ComicView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/13/24.
//

import SwiftUI

struct ComicView: View {
    @Binding var lastReadPage: Int
    @StateObject var viewModel: ComicViewModel
    
    var body: some View {
        VStack {
            if let info = viewModel.currentPage, let image = UIImage(data: info.imageData) {
                Text(info.title)
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Text("Loading...")
                    .padding()
            }
            
            HStack {
                HapticButton("Previous", action: viewModel.previousPage)
                    .tint(.red)
                    .disabled(viewModel.previousButtonDisabled)
                
                Spacer()
                
                HapticButton("Next", action: viewModel.nextPage)
                    .disabled(viewModel.nextButtonDisabled)
            }
            .padding()
        }
        .task {
            try? await viewModel.loadPages()
        }
        .onChange(of: viewModel.currentPageNumber) { _, newValue in
            lastReadPage = newValue
        }
    }
}


// MARK: - HapticButton
struct HapticButton: View {
    let title: String
    let action: () -> Void
    
    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button(title) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }
        .buttonStyle(.bordered)
    }
}
