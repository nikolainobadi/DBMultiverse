//
//  CoverImageDelegate.swift
//  DBMultiverseComicKit
//
//  Created by Nikolai Nobadi on 1/10/25.
//

import Foundation

/// Protocol defining the interface for managing cover image operations.
/// This abstraction allows for different implementations of cover image storage and progress tracking.
public protocol CoverImageDelegate {
    /// Saves the current chapter data including the cover image and metadata.
    /// - Parameters:
    ///   - imageData: The raw image data to be saved.
    ///   - metadata: The metadata associated with the cover image.
    func saveCurrentChapterData(imageData: Data, metadata: CoverImageMetaData)
    
    /// Updates the reading progress for the current chapter.
    /// - Parameter newProgress: The new progress value (0-100).
    func updateProgress(to newProgress: Int)
}