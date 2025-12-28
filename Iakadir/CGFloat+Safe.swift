//
//  CGFloat+Safe.swift
//  Iakadir
//
//  Created by digital on 28/12/2025.
//

import SwiftUI

extension CGFloat {
    var safe: CGFloat { self.isFinite ? self : 0 }
}

extension Double {
    var safeCGFloat: CGFloat { self.isFinite ? CGFloat(self) : 0 }
}
