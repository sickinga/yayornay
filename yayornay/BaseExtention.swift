//
//  BaseExtention.swift
//  yayornay
//
//  Created by Thomas Sickinger on 01.02.23.
//

import Foundation
import SwiftUI

extension Color {
    static let yay = Color("YayColor")
    static let nay = Color("NayColor")
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
