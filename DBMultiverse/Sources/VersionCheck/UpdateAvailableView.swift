//
//  UpdateAvailableView.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftUI
import DBMultiverseComicKit
import NnAppVersionValidator

struct UpdateAvailableView: View {
    @Environment(\.openURL) var openURL
    @Binding var canCheckForUpdates: Bool
    
    let info: AppUpdateInfo
    let finished: () -> Void
    
    var body: some View {
        ComicNavStack(path: .constant(.init())) {
            VStack {
                VStack {
                    Text("A new version is available")
                    Text("Version \(info.version.fullVersionNumber)")
                        .withFont(.title)
                }
                .padding()
                .withFont()
                
                if let releaseNotes = info.releaseNotes {
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Release Notes")
                            .padding()
                            .withFont(.headline)
                        
                        Text(releaseNotes)
                            .padding()
                            .withFont(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                    }
                    Spacer()
                }
                
                if let updateURL = info.updateURL, let url = URL(string: updateURL) {
                    Spacer()
                    Button("Download New Version") {
                        openURL(url)
                        finished()
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .withFont(.title3, autoSizeLineLimit: 1)
                    Spacer()
                }
                
                Button("Don't show me this again") {
                    canCheckForUpdates = false
                }
                .padding()
                .tint(.red)
                .buttonStyle(.bordered)
                .withFont(.caption, textColor: .red)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


// MARK: - Preview
#Preview {
    UpdateAvailableView(canCheckForUpdates: .constant(true), info: .sample, finished: { })
}

extension AppUpdateInfo {
    static var sample: AppUpdateInfo {
        return .init(version: .init(majorNum: 1, minorNum: 2, patchNum: 0), releaseNotes: "I did some stuff", updateURL: "nil")
    }
}
