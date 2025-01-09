//
//  DBMultiverseWidgets.swift
//  DBMultiverseWidgets
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ComicImageEntry {
        ComicImageEntry(date: Date(), image: .init("sampleCoverImage"), family: context.family)
    }

    func getSnapshot(in context: Context, completion: @escaping (ComicImageEntry) -> Void) {
        completion(ComicImageEntry(date: Date(), image: .init("sampleCoverImage"), family: context.family))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ComicImageEntry>) -> Void) {
        let imagePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("latestChapterImage.jpg").path
        let image = makeImage(path: imagePath)
        let entry = ComicImageEntry(date: .now, image: image, family: context.family)
    
        completion(.init(entries: [entry], policy: .atEnd))
    }
    
    func makeImage(path: String?) -> Image? {
        guard let path, let uiImage = UIImage(contentsOfFile: path) else {
            return nil
        }
        
        return .init(uiImage: uiImage)
    }
}

struct ComicImageEntry: TimelineEntry {
    let date: Date
    let image: Image?
    let family: WidgetFamily
}

struct DBMultiverseWidgets: Widget {
    let kind: String = "DBMultiverseWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DBMultiverseWidgetContentView(entry: entry)
                .containerBackground(LinearGradient.starrySky, for: .widget)
        }
        .configurationDisplayName("DBMultiverse Widget")
        .description("Quickly jump back into the action where you last left off.")
        .supportedFamilies(UIDevice.current.userInterfaceIdiom == .pad ? [.systemMedium] : [.systemSmall])
    }
}


// MARK: - Preview
#Preview(as: .systemSmall) {
    DBMultiverseWidgets()
} timeline: {
    ComicImageEntry(date: .now, image: .init("sampleCoverImage"), family: .systemSmall)
}
//#Preview(as: .systemMedium) {
//    DBMultiverseWidgets()
//} timeline: {
//    ComicImageEntry(date: .now, image: .init("sampleCoverImage"), family: .systemMedium)
//}

struct DBMultiverseWidgetContentView: View {
    let entry: ComicImageEntry
    
    var body: some View {
        if entry.family == .systemSmall {
            SmallWidgetView(entry: entry)
        } else {
            MediumWidgetView()
        }
    }
}

struct MediumWidgetView: View {
    var body: some View {
        VStack {
            
        }
    }
}

struct SmallWidgetView: View {
    let entry: ComicImageEntry

    var body: some View {
        VStack {
            HStack {
                Text("Ch")
                    .textLinearGradient(.yellowText)
                Text("1")
                    .textLinearGradient(.redText)
                
                Text(" - 85%")
                    .bold()
                    .font(.caption)
                    .foregroundStyle(.white)
            }
            .bold()
            .font(.title2)

            if let image = entry.image {
                image
                    .resizable()
                    .frame(width: 70, height: 90)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}


import SwiftUI

extension LinearGradient {
    static var starrySky: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.0, green: 0.0, blue: 0.5), // Dark blue
                Color(red: 0.0, green: 0.4, blue: 1.0)  // Lighter blue
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    static var yellowText: LinearGradient {
        return makeTopBottomTextGradient(colors: [.yellow, .yellow, Color.yellow.opacity(0.7)])
    }
    
    static var redText: LinearGradient {
        return makeTopBottomTextGradient(colors: [.red, .red.opacity(0.9), .red.opacity(0.7)])
    }
}


// MARK: - Helpers
fileprivate extension LinearGradient {
    static func makeTopBottomTextGradient(colors: [Color]) -> LinearGradient {
        return .init(gradient: .init(colors: colors), startPoint: .top, endPoint: .bottom)
    }
}

/// A view modifier that applies a linear gradient to the text color of a SwiftUI view.
struct LinearGradientTextColorViewModifier: ViewModifier {
    /// The linear gradient to be applied to the text color.
    let gradient: LinearGradient
    
    /// Modifies the content view to apply the linear gradient to the text color.
    func body(content: Content) -> some View {
        content
            .overlay(
                gradient.mask(content)
            )
    }
}

public extension View {
    /// Applies a linear gradient to the text color of the view.
    /// - Parameter gradient: The linear gradient to apply to the text color.
    /// - Returns: A modified view with gradient text coloring.
    func textLinearGradient(_ gradient: LinearGradient) -> some View {
        modifier(LinearGradientTextColorViewModifier(gradient: gradient))
    }
}
