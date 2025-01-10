//
//  AppUpdateCheckViewModel.swift
//  DBMultiverse
//
//  Created by Nikolai Nobadi on 1/9/25.
//

import Foundation
import NnAppVersionValidator

final class AppUpdateCheckViewModel: ObservableObject {
    @Published var updateInfo: AppUpdateInfo?
    
    private let appInfoJSONURL = "https://dl.dropboxusercontent.com/scl/fi/rg4z4w6rhbq4omq4za3zo/DBMultiverseCurrentAppVersionInfo.json?rlkey=gncv4aig6s0altc2c0rzyubkr&st=v6d6bxjl"
}


// MARK: - Actions
extension AppUpdateCheckViewModel {
    func fetchUpdateInfo() async {
        let url = URL(string: appInfoJSONURL)
        let service = makeAppUpdateValidationService(url: url, bundle: .main, selectedVersionNumber: .minor)
        if let info = try? await service.fetchAvailableUpdate() {
            await MainActor.run {
                updateInfo = info
            }
        } else {
            print("could not find any info")
        }
    }
}
