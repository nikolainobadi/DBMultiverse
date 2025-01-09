//
//  DBMultiverseWidgets.swift
//  DBMultiverseWidgets
//
//  Created by Nikolai Nobadi on 1/8/25.
//

import SwiftUI
import WidgetKit

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


// MARK: - ContentView
fileprivate struct DBMultiverseWidgetContentView: View {
    let entry: ComicImageEntry
    
    var body: some View {
        if entry.family == .systemSmall {
            SmallWidgetView(entry: entry)
        } else {
            MediumWidgetView()
        }
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
