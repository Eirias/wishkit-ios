//
//  Theme.swift
//  wishkit-ios
//
//  Created by Martin Lasek on 2/18/23.
//  Copyright © 2023 Martin Lasek. All rights reserved.
//

import SwiftUI

public struct Theme {

    /// This is for the Add-Button, Segmented Control, and Vote-Button.
    public var primaryColor: Color

    /// This is for the background color of cells and text fields.
    public var secondaryColor: Scheme?

    /// This is for the background color of the view/ViewController.
    public var tertiaryColor: Scheme?

    /// The badge that shows the state of a feature.
    public var badgeColor: BadgeTheme

    /// The color of the title and description of a feature.
    public var textColor: Scheme?
    
    /// The fonts used in the WishKit UI
    public var font: Theme.Font

    init(
        primaryColor: Color = Theme.systemGreen,
        badgeColor: BadgeTheme = .default(),
        secondaryColor: Scheme? = nil,
        tertiaryColor: Scheme? = nil,
        textColor: Scheme? = nil,
        font: Theme.Font = .init()
    ) {
        self.primaryColor = primaryColor
        self.badgeColor = badgeColor
        self.secondaryColor = secondaryColor
        self.tertiaryColor = tertiaryColor
        self.textColor = textColor
        self.font = font
    }

    #if os(macOS)
    private static let systemGreen = Color(NSColor.systemGreen)
    #elseif canImport(UIKit)
    private static let systemGreen = Color(UIColor.systemGreen)
    #endif
}

struct PrivateTheme {
    struct ColorScheme {
        let light: Color
        let dark: Color
    }

    static let systemBackgroundColor = ColorScheme(
        light: Color(red: 242/255, green: 242/255, blue: 247/255),
        dark: Color(red: 28/255, green: 28/255, blue: 30/255)
    )

    static let elementBackgroundColor = ColorScheme(
        light: .white,
        dark: Color(red: 44/255, green: 44/255, blue: 46/255)
    )
}

// MARK: - StatusBadge

extension Theme {
    public struct BadgeTheme {

        var pending: Color

        var approved: Color

        var implemented: Color

        var rejected: Color

        init(pending: Color, approved: Color, implemented: Color, rejected: Color) {
            self.pending = pending
            self.approved = approved
            self.implemented = implemented
            self.rejected = rejected
        }

        static func `default`() -> BadgeTheme {
            return BadgeTheme(
                pending: .yellow,
                approved: .blue,
                implemented: .green,
                rejected: .red
            )
        }
    }
}

extension Theme {
    public struct Scheme {
        var light: Color
        var dark: Color

        public init(light: Color, dark: Color) {
            self.light = light
            self.dark = dark
        }

        /// Convenience function to set ligth and dark mode colors.
        static public func `set`(light: Color, dark: Color) -> Scheme {
            return Scheme(light: light, dark: dark)
        }

        /// Sets the same color for light and dark mode.
        static public func `setBoth`(to color: Color) -> Scheme {
            return Scheme(light: color, dark: color)
        }
    }
}

extension Theme {
    public struct Font {
        /// Used on the `CreateWishView`, `CommentFieldView`, `SeperatorView` and the `SingleCommentView`.
        var caption2: SwiftUI.Font
        /// Used on the `CommentFieldView`
        var footnote: SwiftUI.Font
        /// Used on the `WishView`
        var defaultTextSmall: SwiftUI.Font
        /// Used on the `WishView` and `WKButton`
        var defaultText: SwiftUI.Font
        /// Used on the `WishView`
        var defaultTextTinyMedium: SwiftUI.Font
        
        public init(caption2: SwiftUI.Font = .caption2,
             footnote: SwiftUI.Font = .footnote,
             defaultTextSmall: SwiftUI.Font = .system(size: 13),
             defaultText: SwiftUI.Font = .system(size: 17, weight: .semibold),
             defaultTextTinyMedium: SwiftUI.Font = .system(size: 10, weight: .medium)
        ) {
            self.caption2 = caption2
            self.footnote = footnote
            self.defaultTextSmall = defaultTextSmall
            self.defaultText = defaultText
            self.defaultTextTinyMedium = defaultTextTinyMedium
        }
    }
}
