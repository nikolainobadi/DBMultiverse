//
//  OldComicView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 11/13/24.
//

import SwiftUI
import NnSwiftUIKit

struct OldComicView: View {
    @Binding var lastReadPage: Int
    @StateObject var viewModel: ComicViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if let info = viewModel.currentPage, let image = UIImage(data: info.imageData) {
                Text(info.title)
                    .padding(5)
                    .font(.headline)
                
                Text(viewModel.currentPagePosition)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
            } else {
                Spacer()
                Text("Loading pages...")
                    .padding()
                    .font(.title)
            }
            
            Spacer()
            
            HStack {
                HapticButton("Previous", action: viewModel.previousPage)
                    .tint(.red)
                    .disabled(viewModel.previousButtonDisabled)
                
                Spacer()
                
                HapticButton("Next", action: viewModel.nextPage)
                    .disabled(viewModel.nextButtonDisabled)
                    .showingConditionalView(when: viewModel.isLastPage) {
                        HapticButton("Finish Chapter") {
                            viewModel.finishChapter()
                            dismiss()
                        }
                    }
            }
            .padding()
        }
        .asyncTask {
            try await viewModel.loadPages()
        }
        .onChange(of: viewModel.currentPageNumber) { _, newValue in
            lastReadPage = newValue
        }
    }
}
