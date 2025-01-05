//
//  FancyPicker.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/4/25.
//

import SwiftUI

struct FancyPicker: View {
    @Namespace private var namespace
    @Binding var selection: ComicType
    
    var body: some View {
        HStack {
            ForEach(ComicType.allCases) { type in
                ComitTypeButton(type, selection: $selection, namespace: namespace)
                    .padding(.horizontal)
            }
        }
        .frame(maxHeight: getHeightPercent(5))
        .animation(.easeInOut, value: selection)
    }
}


// MARK: - Button
fileprivate struct ComitTypeButton: View {
    @Binding var selection: ComicType
    @State private var offset: CGFloat = 0
    @State private var rotation: CGFloat = 0

    let type: ComicType
    let namespace: Namespace.ID
    
    private var isSelected: Bool {
        selection == type
    }
    
    init(_ type: ComicType, selection: Binding<ComicType>, namespace: Namespace.ID) {
        self.type = type
        self._selection = selection
        self.namespace = namespace
    }

    var body: some View {
        Button(action: { selection = type }) {
            ZStack {
                Capsule()
                    .fill(type.color.opacity(0.2))
                    .frame(maxWidth: getWidthPercent(20))
                    .matchedGeometryEffect(id: "picker", in: namespace)
                    .onlyShow(when: isSelected)
                
                HStack(spacing: 10) {
                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? type.color : .black.opacity(0.6))
                        .rotationEffect(.degrees(rotation))
                        .scaleEffect(isSelected ? 1 : 0.9)
                        .animation(.easeInOut, value: rotation)
                        .opacity(isSelected ? 1 : 0.7)
                        .offset(y: offset)
                        .animation(.default, value: offset)
                    
                    Text(type.title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? type.color : .gray)
                        .padding(.trailing, 20)
                }
                .padding(.vertical, 10)
            }
        }
        .buttonStyle(.plain)
        .onChange(of: selection) { _, newValue in
            if newValue == type {
                offset = -60
                rotation += (type.id < newValue.id) ? 360 : -360

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    offset = 0
                    rotation += (type.id < newValue.id) ? 720 : -720
                }
            }
        }
    }
}

