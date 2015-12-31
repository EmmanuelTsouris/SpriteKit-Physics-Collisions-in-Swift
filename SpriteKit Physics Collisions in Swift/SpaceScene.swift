//
//  SpaceScene.swift
//  SpriteKit Physics Collisions in Swift
//
//  Created by Emmanuel Tsouris on 12/30/15.
//  Copyright (c) 2015 EmmanuelTsouris. All rights reserved.
//

import Foundation
import SpriteKit

class SpaceScene : SKScene, SKPhysicsContactDelegate {
    
    var actions = [Bool]()
    
    var contentCreated = false
    var controlledShip : ShipSprite!
    var playerAction = PlayerAction()
    
    var frontWheel = SKShapeNode()
    var rearWheel = SKShapeNode()
    
    func makeWheel() -> SKShapeNode {
        let WheelSize = CGSizeMake(20, 60)
        
        let wheel = SKShapeNode(rectOfSize: WheelSize)
        
        wheel.strokeColor = SKColor.clearColor()
        wheel.fillColor = SKColor.redColor() //Red:0.0 green:1.0 blue:0.0 alpha:0.5
        
        wheel.physicsBody = SKPhysicsBody(rectangleOfSize: WheelSize)
        
        return wheel
    }
    
    override func didMoveToView(view: SKView) {
        if (!self.contentCreated)
        {
            createSceneContents()
            self.contentCreated = true
        }
    }
    
    func createSceneContents() {
        self.backgroundColor = SKColor.blackColor()
        self.scaleMode = SKSceneScaleMode.AspectFit
        
        print("H: \(self.size.height) W: \(self.size.width)")
        
        // Give the scene an edge and configure other physics info on the scene.
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        self.physicsBody!.categoryBitMask = PhysicsCategory.edge.rawValue
        self.physicsBody!.collisionBitMask = 0
        self.physicsBody!.contactTestBitMask = 0
        self.physicsWorld.gravity = CGVectorMake(0,0)
        self.physicsWorld.contactDelegate = self
        
        // In this sample, the positions of everything is hard coded.
        // In an actual game, you might implement this in an archive that is loaded from a file.

        self.controlledShip = ShipSprite.shipSprite()
        self.controlledShip.position = CGPointMake (100,500)
        
        self.addChild(self.controlledShip)
        
        // Car Wheels
        
        frontWheel = makeWheel()
        frontWheel.position = CGPointMake(frontWheel.frame.width/2 - frontWheel.frame.width/2, frontWheel.frame.height/2)
        self.addChild(frontWheel)
        
        // this ship isn't connected to any controls so it doesn't move, except when it collides with something.
        let targetShip = ShipSprite.shipSprite()
        targetShip.position = CGPointMake(500,500)
        self.addChild(targetShip)
        
        let rock = newAsteroidNode()
        rock.position = CGPointMake(100,200)
        self.addChild(rock)
        
        let planet = newPlanetNode()
        planet.position = CGPointMake(500,100)
        self.addChild(planet)

    }
    
    func newMissileNode() -> SKNode {
        // Creates and returns a new missile game object.
        //This method loads a preconfigured emitter from an archive, and then configures it with a physics body.
        let missile = SKEmitterNode(fileNamed: "missile.sks")
        
        // The missile particles should be spawned in the scene, not on the missile object.
        missile!.targetNode = self
        
        missile!.physicsBody = SKPhysicsBody(circleOfRadius: shotSize)
        missile!.physicsBody!.categoryBitMask = PhysicsCategory.missile.rawValue
        missile!.physicsBody!.contactTestBitMask = PhysicsCategory.ship.rawValue | PhysicsCategory.asteroid.rawValue | PhysicsCategory.planet.rawValue | PhysicsCategory.edge.rawValue
        missile!.physicsBody!.collisionBitMask = 0;
        
        return missile!
    }
    
    
    func newAsteroidNode() -> SKNode {
        // Creates and returns a new asteroid game object.
        // For this sample, we just use a shape node for the asteroid.
        
        let asteroid = SKShapeNode()
        
        let myPath = CGPathCreateMutable()
        CGPathAddArc(myPath, nil, 0,0, asteroidSize, 0, CGFloat(M_PI*2.0), true)
        asteroid.path = myPath
        
        asteroid.strokeColor = SKColor.clearColor()
        asteroid.fillColor = SKColor.brownColor()
        
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroidSize)
        
        asteroid.physicsBody!.categoryBitMask = PhysicsCategory.asteroid.rawValue
        asteroid.physicsBody!.collisionBitMask = PhysicsCategory.ship.rawValue | PhysicsCategory.asteroid.rawValue | PhysicsCategory.edge.rawValue
        asteroid.physicsBody!.contactTestBitMask = PhysicsCategory.planet.rawValue
        
        return asteroid
    }
    
    func newPlanetNode() -> SKNode {
        // Creates and returns a new planet game object.
        // For this sample, we just use a shape node for the planet.
    
        let planet = SKShapeNode()
        
        let myPath = CGPathCreateMutable()
        CGPathAddArc(myPath, nil, 0,0, planetSize, 0, CGFloat(M_PI*2.0), true)
        planet.path = myPath
        
        planet.strokeColor = SKColor.clearColor()
        planet.fillColor = SKColor.greenColor()
        
        planet.physicsBody = SKPhysicsBody(circleOfRadius: planetSize)
        
        planet.physicsBody!.categoryBitMask = PhysicsCategory.planet.rawValue
        planet.physicsBody!.collisionBitMask = PhysicsCategory.planet.rawValue | PhysicsCategory.edge.rawValue
        planet.physicsBody!.contactTestBitMask = 0
        
        return planet
    }
    
    func newExplosionNode(explosionDuration: NSTimeInterval) -> SKEmitterNode {
        let emitter = SKEmitterNode(fileNamed: "explosion.sks")
        
        // Explosions always place their particles into the scene.
        emitter!.targetNode = self
        
        // Stop spawning particles after enough have been spawned.
        emitter!.numParticlesToEmit = Int(CGFloat(explosionDuration) * emitter!.particleBirthRate)
        
        // Calculate a time value that allows all the spawned particles to die. After this, the emitter node can be removed.
        
        let totalTime = CGFloat(explosionDuration) + emitter!.particleLifetime+emitter!.particleLifetimeRange/2
        
        let sequence = SKAction.sequence([SKAction.waitForDuration(Double(totalTime)), SKAction.removeFromParent()]);
        
        self.runAction(sequence);
        
        return emitter!
    }
    
    // Physics Handling and Game Logic
    
    func detonateMissile(missile: SKNode) {
        let explosion = newExplosionNode(missileExplosionDuration)
        explosion.position = missile.position
        
        self.addChild(explosion)
        missile.removeFromParent()
    }
    
    func attackTarget(target: SKPhysicsBody, missile: SKNode) {
        // Only ships take damage from missiles.
        if ((target.categoryBitMask & PhysicsCategory.ship.rawValue) != 0)
        {
            let targetShip = target.node as! ShipSprite
            targetShip.applyDamage(missileDamage)
        }
        
        detonateMissile(missile)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // Handle contacts between two physics bodies.
        
        // Contacts are often a double dispatch problem; the effect you want is based
        // on the type of both bodies in the contact. This sample  solves
        // this in a brute force way, by checking the types of each. A more complicated
        // example might use methods on objects to perform the type checking.
        
        var firstBody : SKPhysicsBody!
        var secondBody : SKPhysicsBody!
        
        // The contacts can appear in either order, and so normally you'd need to check
        // each against the other. In this example, the category types are well ordered, so
        // the code swaps the two bodies if they are out of order. This allows the code
        // to only test collisions once.
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Missiles attack whatever they hit, then explode.
        
        if ((firstBody.categoryBitMask & PhysicsCategory.missile.rawValue) != 0)
        {
            attackTarget(secondBody, missile: firstBody.node!)
        }
        
        // Ships collide and take damage. The collision damage is based on the strength of the collision.
        if ((firstBody.categoryBitMask & PhysicsCategory.ship.rawValue) != 0)
        {
            // The edge exists just to keep all gameplay on one screen, so ships should not take damage when they hit the
            // edge.
            
            if ((contact.collisionImpulse > collisonDamageThreshold) && ((secondBody.categoryBitMask & PhysicsCategory.edge.rawValue) == 0))
            {
                let targetShip = firstBody.node as! ShipSprite
                targetShip.applyDamage(Int(contact.collisionImpulse / collisonDamageThreshold))
                
                // If two ships collide with each other, both take damage. Planets and asteroids take no damage from ships.
                if ((secondBody.categoryBitMask & PhysicsCategory.ship.rawValue) != 0)
                {
                    let targetShip = secondBody.node as! ShipSprite
                    targetShip.applyDamage(Int(contact.collisionImpulse / collisonDamageThreshold))
                }
            }
        }
        
        // Asteroids that hit planets are destroyed.
        if (((firstBody.categoryBitMask & PhysicsCategory.asteroid.rawValue) != 0) &&
            ((secondBody.categoryBitMask & PhysicsCategory.planet.rawValue) != 0))
        {
            firstBody.node?.removeFromParent()
        }
        
    }
    
    // Controls and Control Logic
    
    override func update(currentTime: NSTimeInterval) {
        // This runs once every frame. Other sorts of logic might run from here. For example,
        // if the target ship was controlled by the computer, you might run AI from this routine.
        
        updatePlayerShip(currentTime)
        
    }
    
    func updatePlayerShip(currentTime: NSTimeInterval) {
        // Use the stored key information to control the ship
        
        if (playerAction.Forward)
        {
            self.controlledShip.activateMainEngine()
        }
        else
        {
            self.controlledShip.deactivateMainEngine()
        }
        
        if (playerAction.Back)
        {
            self.controlledShip.reverseThrust()
        }
        
        if (playerAction.Left)
        {
            self.controlledShip.rotateShipLeft()
        }
        
        if (playerAction.Right)
        {
            self.controlledShip.rotateShipRight()
        }
        
        if (playerAction.LaunchMissile)
        {
            self.controlledShip.attemptMissileLaunch(currentTime)
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        let keyCode = theEvent.keyCode
        
        //Left
        if(keyCode == 123) {
            playerAction.Left = true
        }
        
        //Right
        if(keyCode == 124) {
            playerAction.Right = true
        }
        
        //Down
        if(keyCode == 125) {
            playerAction.Back = true
        }
        
        //Up
        if(keyCode == 126) {
            playerAction.Forward = true
        }
        
        //Fire Missile
        if (keyCode == 49) {
            playerAction.LaunchMissile = true
        }
    }
    
    override func keyUp(theEvent: NSEvent) {
        let keyCode = theEvent.keyCode
        
        //Left
        if(keyCode == 123) {
            playerAction.Left = false
        }
        
        //Right
        if(keyCode == 124) {
            playerAction.Right = false
        }
        
        //Down
        if(keyCode == 125) {
            playerAction.Back = false
        }
        
        //Up
        if(keyCode == 126) {
            playerAction.Forward = false
        }
        
        //Fire Missile
        if (keyCode == 49) {
            playerAction.LaunchMissile = false
        }
        
    }

}