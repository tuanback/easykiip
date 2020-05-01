//
//  UIFront_Extension.swift
//  EasyKIIP_iOS
//
//  Created by Tuan on 2020/04/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import UIKit

private let appFontName = "AvenirNext"

extension UIFont {
  
  class func appFontBold(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: appFontName + "-Bold", size: fontSize)!
  }

  class func appFontItalic(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: appFontName + "-Italic", size: fontSize)!
  }
  
  class func appFontDemiBold(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: appFontName + "-DemiBold", size: fontSize)!
  }
  
  class func appFontHeavy(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: appFontName + "-Heavy", size: fontSize)!
  }
  
  class func appFontMedium(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: appFontName + "-Medium", size: fontSize)!
  }
  
  class func appFontRegular(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: appFontName + "-Regular", size: fontSize)!
  }
  
  class func appFontUltraLight(ofSize fontSize: CGFloat) -> UIFont {
    return UIFont(name: appFontName + "-UltraLight", size: fontSize)!
  }
  
}
