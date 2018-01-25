//
// UIColor+LetterAvatarKit.swift
//  Shades
//
//  Created by John Nik on 11/20/17.
//  Copyright © 2017 johnik703. All rights reserved.
//

import UIKit
import Foundation

/// Returns a color by HEX code.
///
/// - Parameters:
///     - hex: HEX code.
/// - Returns: The color by HEX code.
func LAKUIColorByHEX(_ hex: Int) -> UIColor {
    return LAKUIColorByRGB(red: CGFloat((hex & 0xFF0000) >> 16), green: CGFloat((hex & 0x00FF00) >> 8), blue: CGFloat((hex & 0x0000FF)))
}

/// Returns a color by RGB.
///
/// - Parameters:
///     - red: A value of red color component.
///     - green: A value of green color component.
///     - blue: A value of blue color component.
/// - Returns: The color by RGB.
func LAKUIColorByRGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: CGFloat(1.0))
}

extension UIColor {
    private struct ColorKey {
        static var value = "org.peschenkov.LetterAvatarKit.UIColor.colors"
    }
    
    /// Colors from http://flatuicolors.com/
    public enum HEXColor {
        /// TURQUOISE
        static let turquoiseColor = 0x1ABC9C
        /// EMERALD
        static let emeraldColor = 0x2ECC71
        /// PITER RIVER
        static let piterRiverColor = 0x3498DB
        /// AMETHYST
        static let amethystColor = 0x9B59B6
        /// WET ASPHALT
        static let wetAsphaltColor = 0x34495E
        /// GREEN SEA
        static let greenSeaColor = 0x16A085
        /// NEPHRITIS
        static let nephritisColor = 0x27AE60
        /// BELIZE HOLE
        static let belizeHoldeColor = 0x2980B9
        /// WISTERIA
        static let wisteriaColor = 0x8E44AD
        /// MIDNIGHT BLUE
        static let midnightBlueColor = 0x2C3E50
        /// SUN FLOWER
        static let sunflowerColor = 0xF1C40F
        /// CARROT
        static let carrotColor = 0xE67E22
        /// ALIZARIN
        static let alizarinColor = 0xE74C3C
        /// CONCRETE
        static let concreteColor = 0x95A5A6
        /// ORANGE
        static let orangeColor = 0xF39C12
        /// PUMPKIN
        static let pumpkinColor = 0xD35400
        /// POMEGRANATE
        static let pomegranateColor = 0xC0392B
        /// SILVER
        static let silverColor = 0xBDC3C7
        /// ASBESTOS
        static let asbestosColor = 0x7F8C8D
    }
    
    static open var colors: [ UIColor ] {
        get {
            var colors = objc_getAssociatedObject(self, &ColorKey.value)
            if colors == nil {
                colors = [
                    LAKUIColorByHEX(HEXColor.turquoiseColor),
                    LAKUIColorByHEX(HEXColor.emeraldColor),
                    LAKUIColorByHEX(HEXColor.piterRiverColor),
                    LAKUIColorByHEX(HEXColor.amethystColor),
                    LAKUIColorByHEX(HEXColor.wetAsphaltColor),
                    LAKUIColorByHEX(HEXColor.greenSeaColor),
                    LAKUIColorByHEX(HEXColor.nephritisColor),
                    LAKUIColorByHEX(HEXColor.belizeHoldeColor),
                    LAKUIColorByHEX(HEXColor.wisteriaColor),
                    LAKUIColorByHEX(HEXColor.midnightBlueColor),
                    LAKUIColorByHEX(HEXColor.sunflowerColor),
                    LAKUIColorByHEX(HEXColor.carrotColor),
                    LAKUIColorByHEX(HEXColor.alizarinColor),
                    LAKUIColorByHEX(HEXColor.concreteColor),
                    LAKUIColorByHEX(HEXColor.orangeColor),
                    LAKUIColorByHEX(HEXColor.pumpkinColor),
                    LAKUIColorByHEX(HEXColor.pomegranateColor),
                    LAKUIColorByHEX(HEXColor.silverColor),
                    LAKUIColorByHEX(HEXColor.asbestosColor)
                ]
                objc_setAssociatedObject(self, &ColorKey.value, colors, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return colors as! [ UIColor ]
            }
            return colors as! [ UIColor ]
        }
    }
}
