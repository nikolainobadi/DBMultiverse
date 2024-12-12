//
//  ZoomableImageView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 12/12/24.
//

import SwiftUI

struct ZoomableImageView: View {
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    let image: UIImage

    var body: some View {
        GeometryReader { geometry in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = calculateBoundedOffset(translation: gesture.translation, geometrySize: geometry.size)
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = min(max(lastScale * value, 1.0), 5.0)
                            offset = calculateBoundedOffset(translation: .zero, geometrySize: geometry.size )
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .gesture(
                    TapGesture(count: 2)
                        .onEnded {
                            resetValues()
                        }
                )
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: image) {
            resetValues()
        }
    }
}

// MARK: - Helper Functions
private extension ZoomableImageView {
    func resetValues() {
        withAnimation(.smooth) {
            scale = 1.0
            lastScale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }
    
    func calculateBoundedOffset(translation: CGSize, geometrySize: CGSize) -> CGSize {
        let totalWidth = geometrySize.width * scale
        let totalHeight = geometrySize.height * scale
        let maxOffsetX = max((totalWidth - geometrySize.width) / 2, 0)
        let maxOffsetY = max((totalHeight - geometrySize.height) / 2, 0)
        let boundedX = min(max(lastOffset.width + translation.width, -maxOffsetX), maxOffsetX)
        let boundedY = min(max(lastOffset.height + translation.height, -maxOffsetY), maxOffsetY)
        
        return .init(width: boundedX, height: boundedY)
    }
}
