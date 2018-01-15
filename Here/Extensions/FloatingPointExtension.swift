//
//  FloatingPointExtension.swift
//  Here
//
//  Created by robin ustarroz on 15/01/2018.
//  Copyright © 2018 robin ustarroz. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}
