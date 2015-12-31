//
//  HelperFunctions.swift
//  SpriteKitCollisionsSwift
//
//  Created by Emmanuel Tsouris on 11/6/15.
//  Copyright © 2015 DigitalSand. All rights reserved.
//

import Foundation

func myRandf() -> CGFloat {
    return CGFloat(rand() / RAND_MAX)
}

func myRand(low: CGFloat, high: CGFloat) -> CGFloat {
    return myRandf() * (high - low) + low
}