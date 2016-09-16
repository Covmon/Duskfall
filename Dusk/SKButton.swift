//
//  SKButton.swift
//  Dusk
//
//  Created by Noah Covey on 3/13/16.
//  Copyright © 2016 Quantum Cat Games. All rights reserved.
//

import SpriteKit

class SKButton: SKNode {
    
    var button: SKSpriteNode
    var action: () -> Void
    var size: CGSize
    
    init(buttonImage: String, buttonAction: @escaping () -> Void) {
        
        button = SKSpriteNode(imageNamed: "\(buttonImage)")
        action = buttonAction
        self.size = button.size
        
        button.color = SKColor.black
        button.colorBlendFactor = 0
        super.init()
        
        self.isUserInteractionEnabled = true
        self.addChild(button)
        
        
        
        
    }

    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTexture(_ textureName: String) -> Void {
        
        button.texture = SKTexture(imageNamed: textureName)
        
    }
    
    func changeAction(_ newAction: @escaping () -> Void) {
        
        action = newAction
        
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        button.color = SKColor.black
        button.colorBlendFactor = 0.4
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if button.contains(location) {
                button.colorBlendFactor = 0.4
            } else {
                button.colorBlendFactor = 0
            }
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if button.contains(location) {
                button.colorBlendFactor = 0
                didSwipe = false
                action()
                if volumeOn {
                    self.run(SKAction.playSoundFileNamed("ButtonClick.aif", waitForCompletion: false))
                }
            } else {
                button.colorBlendFactor = 0
                didSwipe = false
            }
            
        }
        
    }
    
}
