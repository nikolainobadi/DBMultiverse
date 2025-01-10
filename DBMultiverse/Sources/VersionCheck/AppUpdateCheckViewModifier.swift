//
//  AppUpdateCheckViewModifier.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import SwiftUI
import DBMultiverseComicKit
import NnAppVersionValidator

struct AppUpdateCheckViewModifier: ViewModifier {
    @Binding var canCheckForUpdates: Bool
    @StateObject var viewModel: AppUpdateCheckViewModel = .init()
    
    func body(content: Content) -> some View {
        content
            .showingViewWithOptional(viewModel.updateInfo) { updateInfo in
                UpdateAvailableView(canCheckForUpdates: $canCheckForUpdates, info: updateInfo) {
                    viewModel.updateInfo = nil
                }
            }
            .task {
                if canCheckForUpdates {
                    await viewModel.fetchUpdateInfo()
                }
            }
    }
}

extension View {
    func onAppUpdateAvailable(canCheckForUpdates: Binding<Bool>) -> some View {
        modifier(AppUpdateCheckViewModifier(canCheckForUpdates: canCheckForUpdates))
    }
}
