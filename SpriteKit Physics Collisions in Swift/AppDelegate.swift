//
//  AppDelegate.swift
//  SpriteKit Physics Collisions in Swift
//
//  Created by Emmanuel Tsouris on 12/30/15.
//  Copyright (c) 2015 EmmanuelTsouris. All rights reserved.
//

import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        let scene = SpaceScene(size:self.skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        self.skView!.presentScene(scene)
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        self.skView!.ignoresSiblingOrder = true
        
        self.skView!.showsFPS = true
        self.skView!.showsNodeCount = true
        self.skView!.showsDrawCount = true
        self.skView!.showsPhysics = true

    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }
}
