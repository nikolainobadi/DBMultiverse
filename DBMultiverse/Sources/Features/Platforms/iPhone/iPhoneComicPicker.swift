//
//  iPhoneComicPicker.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct iPhoneComicPicker: View {
    @Binding var selection: ComicType
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(ComicType.allCases, id: \.self) { type in
                Text(type.title)
                    .withFont(textColor: selection == type ? Color.white : type.color)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(selection == type ? type.color : Color.clear)
                    .cornerRadius(8)
                    .onTapGesture {
                        selection = type
                    }
            }
        }
        .padding()
    }
}
