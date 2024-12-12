////
////  CachedChaptersView.swift
////  DBMultiverse
////
////  Created by Nikolai Nobadi on 12/12/24.
////
//
//import Foundation
//
//struct CachedChaptersView: View {
//    @StateObject private var cacheManager = CacheManager()
//
//    var body: some View {
//        List(cacheManager.cachedChapters) { chapter in
//            HStack {
//                Text("Chapter \(chapter.number)")
//                Spacer()
//                Text("\(chapter.imageCount) Images")
//                    .foregroundColor(.secondary)
//            }
//        }
//        .onAppear {
//            cacheManager.loadCachedChapters()
//        }
//        .navigationTitle("Cached Chapters")
//    }
//}
//
//
//// MARK: - Preview
//#Preview {
//    CachedChaptersView()
//}
