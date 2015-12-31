//
//  Contants.swift
//  SpriteKit Physics Collisions in Swift
//
//  Created by Emmanuel Tsouris on 12/30/15.
//  Copyright (c) 2015 EmmanuelTsouris. All rights reserved.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Emmanuel Tsouris
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

// This enables debug code to show the bounding shape of the ship superimposed over the sprite.
let SHOW_SHIP_PHYSICS_OVERLAY = true

// These constans are used to define the physics interactions between physics bodies in the scene.
enum PhysicsCategory : UInt32 {
    case missile   = 1
    case ship    = 2
    case asteroid  = 4
    case planet = 8
    case edge = 16
}

// Constants used to adjust ship behavior

// In an actual game, instead of hard coding these, you might want to load them from a property list
struct ShipHealth
{
    static let startingShipHealth = 10
    static let showDamageBelowHealth = 4
}

// Used to configure a ship explosion.
struct ShipExplosion
{
    static let shipExplosionDuration : CFTimeInterval = 0.6
    static let shipChunkMinimumSpeed : CGFloat = 300
    static let shipChunkMaximumSpeed : CGFloat = 750
    static let shipChunkDispersion : CGFloat = 30
    static let numberOfChunks = 30
    static let removeShipTime = 0.35
}

// Used to control the ship, usually by applying physics forces to the ship.
struct ShipControl
{
    static let mainEngineThrust : CGFloat = 10
    static let reverseThrust : CGFloat = 1.0
    static let lateralThrust : CGFloat = 0.01
    static let firingInterval = 0.1
    static let missileLaunchDistance : CGFloat = 45
    static let engineIdleAlpha : CGFloat = 0.05
    static let missileLaunchImpulse : CGFloat = 0.5
}

/* Simulation constants used to tweak game play. */

// sizes for the various kinds of objects
let shotSize : CGFloat = 4
let asteroidSize : CGFloat = 18
let planetSize : CGFloat = 128

// explosion constants
let missileExplosionDuration : NSTimeInterval = 0.1

// collison constants
let collisonDamageThreshold : CGFloat = 3.0

// missile constants
let missileDamage = 1

