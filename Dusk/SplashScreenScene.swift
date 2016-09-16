//
//  SplashScreenScene.swift
//  Dusk
//
//  Created by Noah Covey on 8/4/16.
//  Copyright © 2016 Quantum Cat Games. All rights reserved.
//

import SpriteKit
import UIKit

/*extension UILabel {
    func addCharacterSpacing(spacing: CGFloat, text: String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, text.characters.count))
        self.attributedText = attributedString
    }
}*/

class SplashScreenScene: SKScene {
    
    override func didMove(to view: SKView) {
        
        self.backgroundColor = SKColor.black
        
        let gradient = SKSpriteNode(imageNamed: "duskGradient")
        gradient.size = self.size
        gradient.anchorPoint = CGPoint(x: 0.5, y: 0)
        gradient.position = CGPoint(x: self.size.width/2, y: 0)
        gradient.alpha = 0
        gradient.zPosition = 90
        self.addChild(gradient)
        
        /*
        let titleLabel = UILabel()
        titleLabel.sizeToFit()
        titleLabel.addCharacterSpacing(5, text: "DUSK")
        titleLabel.font = UIFont(name: "DolceVitaLight", size: self.size.width/5)
        titleLabel.textColor = SKColor.whiteColor()
        view.addSubview(titleLabel)*/
        
        /*
        let attributedString = NSMutableAttributedString(string: "DUSK")
        //attributedString.addAttribute(NSKernAttributeName, value: 5, range: NSMakeRange(0, 4))
        attributedString.addAttribute(NSFontAttributeName, value: "DolceVitaLight", range: NSMakeRange(0, 4))
        //attributedString.addAttribute(NSStrokeColorAttributeName, value: SKColor.whiteColor(), range: NSMakeRange(0, 4))
        
        let titleLabel = SKAttributedLabelNode(size: self.size)
        titleLabel.attributedString = attributedString
        titleLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        self.addChild(titleLabel)*/
        
        
        let title = text("DUSK", fontSize: self.size.width/5, fontName: "DolceVitaLight", fontColor: SKColor.white)
        title.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        title.alpha = 0
        title.zPosition = 100
        self.addChild(title)
        
        let title2 = text("DUSK", fontSize: self.size.width/5, fontName: "DolceVitaLight", fontColor: SKColor.white)
        title2.position = CGPoint(x: self.size.width * 0.51, y: self.size.height * 0.558)
        title2.alpha = 0
        title2.zPosition = 100
        self.addChild(title2)
        
        let title3 = text("DUSK", fontSize: self.size.width/5, fontName: "DolceVitaLight", fontColor: SKColor.white)
        title3.position = CGPoint(x: self.size.width * 0.49, y: self.size.height * 0.558)
        title3.alpha = 0
        title3.zPosition = 100
        self.addChild(title3)
        
        let title4 = text("DUSK", fontSize: self.size.width/5, fontName: "DolceVitaLight", fontColor: SKColor.white)
        title4.position = CGPoint(x: self.size.width * 0.49, y: self.size.height * 0.542)
        title4.alpha = 0
        title4.zPosition = 100
        self.addChild(title4)
        
        let title5 = text("DUSK", fontSize: self.size.width/5, fontName: "DolceVitaLight", fontColor: SKColor.white)
        title5.position = CGPoint(x: self.size.width * 0.51, y: self.size.height * 0.542)
        title5.alpha = 0
        title5.zPosition = 100
        self.addChild(title5)
        
        let wait1 = SKAction.wait(forDuration: 0.5)
        
        let wait2 = SKAction.wait(forDuration: 1.3)
        
        let fade1 = SKAction.fadeIn(withDuration: 1)
        
        let fade2 = SKAction.fadeIn(withDuration: 1.3)
        
        let blurIn = SKAction.move(to: CGPoint(x: self.size.width/2, y: self.size.height * 0.55), duration: 1)
        
        let blurAndFadeIn = SKAction.group([fade1, blurIn])
        let remove = SKAction.removeFromParent()
        
        let titleUp = SKAction.moveTo(y: self.size.height * 0.8, duration: 1.3)
        titleUp.timingMode = .easeOut
        
        title.run(SKAction.sequence([wait1, fade1, titleUp]))
        
        title2.run(SKAction.sequence([wait1, blurAndFadeIn, remove]))
        title3.run(SKAction.sequence([wait1, blurAndFadeIn, remove]))
        title4.run(SKAction.sequence([wait1, blurAndFadeIn, remove]))
        title5.run(SKAction.sequence([wait1, blurAndFadeIn, remove]))

        
        gradient.run(SKAction.sequence([wait2, fade2]))
        
        let wait3 = SKAction.wait(forDuration: 2.8)
        
        
        let scene = GameScene(size: view.bounds.size)
        // Configure the view.
        let skView = self.view! as SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        let present = SKAction.run({
            skView.presentScene(scene)
        })
        
        self.run(SKAction.sequence([wait3, present]))
        
        


        
    }
    
    func text(_ text: String, fontSize: CGFloat, fontName: String, fontColor: UIColor) -> SKLabelNode {
        
        let text1 = SKLabelNode(text: text)
        text1.fontSize = fontSize
        text1.fontName = fontName
        text1.fontColor = fontColor
        
        return text1
        
    }

    
}
