//
//  CoverImageDelegateAdapter.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import Foundation
import DBMultiverseComicKit

/// Adapter that bridges between the CoverImageDelegate protocol and CoverImageManager implementation.
final class CoverImageDelegateAdapter {
    private let manager: CoverImageManager
    
    /// Initializes the adapter with a CoverImageManager instance.
    /// - Parameter manager: The CoverImageManager to wrap. Defaults to a new instance.
    public init(manager: CoverImageManager = CoverImageManager()) {
        self.manager = manager
    }
}


// MARK: - CoverImageDelegate
extension CoverImageDelegateAdapter: CoverImageDelegate {
    func saveCurrentChapterData(imageData: Data, metadata: CoverImageMetaData) {
        manager.saveCurrentChapterData(imageData: imageData, metadata: metadata)
    }
    
    func updateProgress(to newProgress: Int) {
        manager.updateProgress(to: newProgress)
    }
}
