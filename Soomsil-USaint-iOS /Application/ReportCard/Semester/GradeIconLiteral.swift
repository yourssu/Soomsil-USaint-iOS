//
//  GradeIconLiteral.swift
//  Soomsil-USaint-iOS 
//
//  Created by 최지우 on 12/19/24.
//

import SwiftUI

public enum Icon {
    public static var dotsHorizontalLine: Image { .load(name: "ic_dots_horizontal_line") }
    public static var xLineBold: Image { .load(name: "ic_xcircle_filled_modified") }
    public static var settingLine: Image { .load(name: "ic_setting_line") }
    public static var aMinus: Image { .load(name: "A-") }
    public static var aPlus: Image { .load(name: "A+") }
    public static var aZero: Image { .load(name: "A0") }
    public static var bMinus: Image { .load(name: "B-") }
    public static var bPlus: Image { .load(name: "B+") }
    public static var bZero: Image { .load(name: "B0") }
    public static var cMinus: Image { .load(name: "C-") }
    public static var cPlus: Image { .load(name: "C+") }
    public static var cZero: Image { .load(name: "C0") }
    public static var dMinus: Image { .load(name: "D-") }
    public static var dPlus: Image { .load(name: "D+") }
    public static var dZero: Image { .load(name: "D0") }
    public static var fail: Image { .load(name: "F") }
    public static var pass: Image { .load(name: "P") }
    public static var unknown: Image { .load(name: "Unknown") }
    public static var boardLine: Image { .load(name: "ic_drawer_line") }
    public static var boardFilled: Image { .load(name: "ic_drawer_filled") }
    public static var drawerIcon: Image { .load(name: "ic_drawer_main") }
    public static var dotsVerticalLine: Image { .load(name: "ic_dots_vertical_line") }
    public static var xLineGrey: Image { .load(name: "ic_x_line") }
    
    public static func grade(from string: String) -> Image {
        return Image(string, bundle: Bundle(identifier: "com.yourssu.SoomsilUI"))
    }
}

extension Image {
    static func load(name: String) -> Image {
        return Image(name)
    }
}

