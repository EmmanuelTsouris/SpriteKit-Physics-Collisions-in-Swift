//
//  ShipSprite.swift
//  SpriteKit Physics Collisions in Swift
//
//  Created by Emmanuel Tsouris on 12/30/15.
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
import SpriteKit

class ShipSprite : SKSpriteNode {
    
    // Child nodes used to add effects to the ship.
    var exhaustNode : SKEmitterNode!
    var visibleDamageNode : SKEmitterNode!
    
    var engineEngagedAlpha : CGFloat = 0
    var timeLastFiredMissile : CFTimeInterval = 0
    
    var health = 0
    
    class func shipSprite() -> ShipSprite {
        let ship = ShipSprite(imageNamed: "spaceship.png")
        
        // This is a bounding shape that approximates the rocket.
        let boundingPath = CGPathCreateMutable()
        CGPathMoveToPoint(boundingPath, nil, -12, -38);
        CGPathAddLineToPoint(boundingPath, nil, 12, -38);
        CGPathAddLineToPoint(boundingPath, nil, 9, +18);
        CGPathAddLineToPoint(boundingPath, nil, 2, +38);
        CGPathAddLineToPoint(boundingPath, nil, -2, +38);
        CGPathAddLineToPoint(boundingPath, nil, -9, +18);
        CGPathAddLineToPoint(boundingPath, nil, -12, -38);
        
        if (SHOW_SHIP_PHYSICS_OVERLAY) {
            let shipOverlayShape = SKShapeNode()
            shipOverlayShape.path = boundingPath
            shipOverlayShape.strokeColor = SKColor.clearColor()
            shipOverlayShape.fillColor = SKColor(calibratedRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
            
            ship.addChild(shipOverlayShape)
        }
        
        ship.physicsBody = SKPhysicsBody(polygonFromPath: boundingPath)
        
        ship.physicsBody!.categoryBitMask = PhysicsCategory.ship.rawValue
        ship.physicsBody!.collisionBitMask = PhysicsCategory.ship.rawValue | PhysicsCategory.asteroid.rawValue | PhysicsCategory.planet.rawValue | PhysicsCategory.edge.rawValue
        ship.physicsBody!.contactTestBitMask = PhysicsCategory.ship.rawValue | PhysicsCategory.asteroid.rawValue | PhysicsCategory.planet.rawValue | PhysicsCategory.edge.rawValue
        
        // The ship doesn't slow down when it moves forward, but it does slow its angular rotation. In practice,
        // this feels better for a game.
        ship.physicsBody!.linearDamping = 0
        ship.physicsBody!.angularDamping = 0.5
        
        return ship
    }
    
    init(imageNamed: String) {
        let shipTex = SKTexture(imageNamed: imageNamed)
        super.init(texture: shipTex, color: SKColor.clearColor(), size: shipTex.size())
        health = ShipHealth.startingShipHealth
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showDamage() {
        // When the ship first shows damage, a damage node is created and added as a child.
        // If it takes more damage, then the number of particles is increased.
    
        if (self.visibleDamageNode == nil) {
        
            let damageEmitter = SKEmitterNode(fileNamed: "damage.sks")
        
            self.visibleDamageNode = damageEmitter
            self.visibleDamageNode.name = "damaged"
    
            // Make the scene the target node because the ship is moving around in the scene. Smoke particles
            // should be spawned based on the ship, but should otherwise exist independently of the ship.
    
            self.visibleDamageNode.targetNode = self.scene;
    
            self.addChild(self.visibleDamageNode)
        
        }
        else
        {
            self.visibleDamageNode.particleBirthRate = self.visibleDamageNode.particleBirthRate * 2
        }
    }
    
    func makeExhaustNode() {
        
        let emitter = SKEmitterNode(fileNamed: "exhaust.sks")
        
        // Hard coded position at the back of the ship.
        emitter!.position = CGPointMake(0,-40)
        emitter!.name = "exhaust"
        
        // Make the scene the target node because the ship is moving around in the scene. Exhaust particles
        // should be spawned based on the ship, but should otherwise exist independently of the ship.
        
        emitter!.targetNode = self.scene;
        
        // The exhaust node is always emitting particles, but the alpha of the particles is adjusted depending on whether
        // the engines are engaged or not. This adds a subtle effect when the ship is idling.
        
        self.engineEngagedAlpha = emitter!.particleAlpha;
        emitter!.particleAlpha = CGFloat(ShipControl.engineIdleAlpha)
        
        self.addChild(emitter!)
        self.exhaustNode = emitter
        
    }

    func makeExhaustNodeIfNeeded(){
        if (self.exhaustNode == nil)
        {
            makeExhaustNode()
        }
    }

    func applyDamage(amount: Int) {
        // If the ship takes too much damage, blow it up. Otherwise, decrement the health (and show damage if necessary).
        if (amount >= health)
        {
            if (health > 0)
            {
                health = 0;
                explode()
            }
        }
        else
        {
            health -= amount;
            if (health < ShipHealth.showDamageBelowHealth)
            {
                showDamage()
            }
        }

    }
    
    func explode() {
        // Create a bunch of explosion emitters and send them flying in all directions. Then remove the ship from the scene.
        
        let scene : SpaceScene = self.scene as! SpaceScene
        
        for var i = 0; i < ShipExplosion.numberOfChunks; i++ {

            let explosion = scene.newExplosionNode(ShipExplosion.shipExplosionDuration)
            
            let highNum = M_PI*Double(2)
            
            let angle = myRand(0, high: CGFloat(highNum));
            let speed = myRand(ShipExplosion.shipChunkMinimumSpeed, high: ShipExplosion.shipChunkMaximumSpeed)
            
            let expPosX = myRand(self.position.x-ShipExplosion.shipChunkDispersion, high: self.position.x+ShipExplosion.shipChunkDispersion)
            let expPosY = myRand(self.position.y-ShipExplosion.shipChunkDispersion, high: self.position.y+ShipExplosion.shipChunkDispersion)
            
            explosion.position = CGPointMake(expPosX, expPosY);
            
            // Use the physics system to animate the movement of the explosion chunks. As implemented, these chunks do not
            // collide or hit anything.
            explosion.physicsBody = SKPhysicsBody(circleOfRadius: 0.25)
            explosion.physicsBody!.collisionBitMask = 0
            explosion.physicsBody!.contactTestBitMask = 0
            explosion.physicsBody!.categoryBitMask = 0
            
            explosion.physicsBody!.velocity = CGVectorMake(cos(angle)*speed,sin(angle)*speed)
            
            scene.addChild(explosion)
        }
        
        // Once the ship is covered with particles it is removed.
        let sequence = SKAction.sequence([SKAction.waitForDuration(ShipExplosion.removeShipTime), SKAction.removeFromParent()]);
        
        self.runAction(sequence);
    }

    func shipOrientation() -> CGFloat {
        // The ship art is oriented so that it faces the top of the scene, but Sprite Kit's rotation default is to the right.
        // This method calculates the ship orientation for use in other calculations.
        return self.zRotation + CGFloat(M_PI_2);
    }
    
    func shipExhaustAngle() -> CGFloat {
        // The ship art is oriented so that it faces the top of the scene, but Sprite Kit's rotation default is to the right.
        // This method calculates the direction for the ship's rear.
        return self.zRotation - CGFloat(M_PI_2);
    }
    
    func activateMainEngine() {
        // Add flames out the back and apply thrust to the ship.
        
        let shipDirection = shipOrientation()
        
        let shipForce = CGVectorMake(ShipControl.mainEngineThrust*cos(shipDirection), ShipControl.mainEngineThrust*sin(shipDirection))
        
        self.physicsBody?.applyForce(shipForce)
        
        makeExhaustNodeIfNeeded()
        
        self.exhaustNode.particleAlpha = self.engineEngagedAlpha
        self.exhaustNode.emissionAngle = shipExhaustAngle()
    }
    
    func deactivateMainEngine() {
        // Cut the engine exhaust.
        
        self.makeExhaustNodeIfNeeded()
        
        self.exhaustNode.particleAlpha = ShipControl.engineIdleAlpha
        self.exhaustNode.emissionAngle = shipExhaustAngle()
    }
    
    func reverseThrust() {
        // Apply a small amount of thrust to reduce the ship's speed. (No visible special effect).
        let reverseDirection = shipOrientation() + CGFloat(M_PI)
        
        let revThrustX = ShipControl.reverseThrust*cos(reverseDirection)
        let revThrustY = ShipControl.reverseThrust*sin(reverseDirection)
        
        // calculate an impulse to thrust the ship forward.
        let reverseForce = CGVectorMake(revThrustX, revThrustY)
        
        self.physicsBody?.applyForce(reverseForce)
    }
    
    func rotateShipLeft() {
        // Apply a small amount of thrust to turn the ship to the left. (No visible special effect).
        
        self.physicsBody?.applyTorque(ShipControl.lateralThrust)
    }
    
    func rotateShipRight() {
        // Apply a small amount of thrust to turn the ship to the right. (No visible special effect).
        
        self.physicsBody?.applyTorque(-ShipControl.lateralThrust)
    }
    
    func attemptMissileLaunch(currentTime: NSTimeInterval) {
        // Fire a missile if there's one ready
        
        let timeSinceLastFired = currentTime - self.timeLastFiredMissile
        
        if (timeSinceLastFired > ShipControl.firingInterval)
        {
            self.timeLastFiredMissile = currentTime;
            
            let shipDirection = shipOrientation()
            
            let scene = self.scene as! SpaceScene
            
            let missile = scene.newMissileNode()
            
            missile.position = CGPointMake(self.position.x + ShipControl.missileLaunchDistance*cos(shipDirection),
                self.position.y + ShipControl.missileLaunchDistance*sin(shipDirection))
            
            scene.addChild(missile)
            
            let missileImpulse = CGVectorMake(ShipControl.missileLaunchImpulse*cos(shipDirection), ShipControl.missileLaunchImpulse*sin(shipDirection))
            
            // Start with the ship's velocity, and then give it a little kick.
            missile.physicsBody!.velocity = self.physicsBody!.velocity
            missile.physicsBody!.applyImpulse(missileImpulse)
        }
    }
    
}
