//
//  WidgetSyncState.swift
//
//
//  Created by Nikolai Nobadi on 1/11/25.
//

import Foundation

public struct WidgetSyncState: Codable, Equatable, Sendable {
    public let chapter: Int
    public let progress: Int
    
    public init(chapter: Int, progress: Int) {
        self.chapter = chapter
        self.progress = progress
    }
}
