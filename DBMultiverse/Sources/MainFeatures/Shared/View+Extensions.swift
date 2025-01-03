//
//  View+Extensions.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/2/25.
//

import SwiftUI

extension View {
    var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
