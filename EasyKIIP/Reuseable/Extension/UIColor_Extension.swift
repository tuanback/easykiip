//
//  UIColor_Extension.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
  
  convenience init(hexString: String, alpha: CGFloat = 1.0) {
    let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    let scanner = Scanner(string: hexString)
    if (hexString.hasPrefix("#")) {
      scanner.scanLocation = 1
    }
    var color: UInt32 = 0
    scanner.scanHexInt32(&color)
    let mask = 0x000000FF
    let r = Int(color >> 16) & mask
    let g = Int(color >> 8) & mask
    let b = Int(color) & mask
    let red = CGFloat(r) / 255.0
    let green = CGFloat(g) / 255.0
    let blue = CGFloat(b) / 255.0
    self.init(red:red, green:green, blue:blue, alpha:alpha)
  }
  
  class var appBackground: UIColor {
    if #available(iOS 13.0, *) {
      return UIColor.systemBackground
    } else {
      return UIColor.white
    }
  }
  
  class var appSecondaryBackground: UIColor {
    if #available(iOS 13.0, *) {
      return UIColor.systemGray6
    } else {
      return UIColor(hexString: "F2F2F2")
    }
  }
  
  class var appSystemGray3: UIColor {
    if #available(iOS 13.0, *) {
      return UIColor.systemGray3
    } else {
      return UIColor(hexString: "C7C7CC")
    }
  }
  
  class var appLabelBlack: UIColor {
    if #available(iOS 13.0, *) {
      return UIColor.label
    } else {
      return UIColor.black
    }
  }
  
  class var appSecondaryLabel: UIColor {
    if #available(iOS 13.0, *) {
      return UIColor.secondaryLabel
    }
    else {
      return UIColor(hexString: "3C3C43", alpha: 0.6)
    }
  }
  
  class var appShadowColor: UIColor {
    if #available(iOS 13.0, *) {
      return UIColor.label
    } else {
      return UIColor.black
    }
  }
  
  class var appRed: UIColor {
    return UIColor(hexString: "EB5757")
  }
}
