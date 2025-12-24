//
//  ChapterHeaderView.swift
//  DBMultiverseWidgetsExtension
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import DBMultiverseComicKit

struct ChapterHeaderView: View {
    let chapter: Int

    var body: some View {
        HStack {
            Text("Ch")
                .textLinearGradient(.yellowText)
            Text("\(chapter)")
                .textLinearGradient(.redText)
        }
        .withFont()
        .bold()
        .font(.title2)
    }
}
