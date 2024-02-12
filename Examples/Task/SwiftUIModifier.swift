//
//  SwiftUIModifier.swift
//  Rudder
//
//  Created by Pallab Maiti on 08/02/24.
//  Copyright © 2024 Rudder Labs India Pvt Ltd. All rights reserved.
//

// NOTE: Use of this file can be seen in SwiftUI-iOS application.

import Foundation
import Rudder

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 13, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal struct SwiftUIViewModifier: SwiftUI.ViewModifier {
    let client: RudderProtocol
    let name: String
    let category: String?
    let properties: ScreenProperties?
    let option: MessageOption?
        
    func body(content: Content) -> some View {
        content.onAppear {
            client.screen(name, category: category, properties: properties, option: option)
        }
    }
}

@available(iOS 13, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension SwiftUI.View {
    /// Record SwiftUI Views.
    ///
    /// - Parameters:
    ///   - name: The name of the View.
    ///   - category: The category or type of View, if any.
    ///   - properties: Extra data properties regarding the screen call, if any.
    ///   - option: Extra screen event options, if any.
    ///   - client: The insatnce of RSClient.
    /// - Returns: This view after applying a `ViewModifier` for monitoring the view.
    func recordScreen(
        name: String,
        category: String? = nil,
        properties: ScreenProperties? = nil,
        option: MessageOption? = nil,
        in client: RudderProtocol
    ) -> some View {
        return modifier(
            SwiftUIViewModifier(
                client: client,
                name: name,
                category: category,
                properties: properties,
                option: option
            )
        )
    }
}

#endif
