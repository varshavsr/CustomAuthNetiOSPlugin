//
//  UIColor+Theme.swift
//  AuthorizeNetSwift
//
//  Created by varsha s rao on 04/06/18.
//  Copyright © 2018. All rights reserved.
//

import UIKit

extension UIColor {
    
    fileprivate static func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: a)
    }
    
    fileprivate static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        return rgba(r, g, b, 1.0)
    }
    
    static func hexStringToUIColor(hex: String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        
        if cString.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func lightGreyColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#EFEFEF")
    }
    
    // Navigation colors
    static func navBarBackgroundColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#2B9996")
    }
    
    static func navBarTitleColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#FFFFFF")
    }
    
    // Background colors
    static func screenBackgroundColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#DEFFFF")
    }
    
    // All textcolors
    static func primaryTextDarkColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#000000")
    }
    
    static func secondaryTextColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#666666")
    }
    
    static func linksTextColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#01a0e3")
    }

    // Button colors
    static func buttonBackGroundColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#2B9996")
    }
    
    static func buttonDisabledBackGroundColor() -> UIColor{
        return UIColor.hexStringToUIColor(hex: "#b3b3b3")
    }
    
    static func darkBlueColor() -> UIColor {
        let color = UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        return color
    }
}
