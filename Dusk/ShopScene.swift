//
//  ShopScene.swift
//  Dusk
//
//  Created by Noah Covey on 6/20/16.
//  Copyright © 2016 Quantum Cat Games. All rights reserved.
//

import SpriteKit
import GameKit

class ShopScene: SKScene {
    
    var backButton: SKButton!
    
    var coinDisplay: SKLabelNode!
    var coinIcon: SKSpriteNode!
    
    var title: SKLabelNode!
    
    var moveableNode = SKNode()
    var scrollView: SKScrollView!
    
    var scale1: CGFloat = 0.55
    
    var unlockedCharactersLabel: SKLabelNode!
    
    //var cropNode: SKCropNode!
    
    override func didMove(to view: SKView) {
        
        //gems += 5000
        
        self.addChild(moveableNode)
        //gems = 5000
        lastScene = "shop"
        
        //MARK: BACKGROUND & GRADIENT
        var buttonNumber = ""
        var gradName = "duskGradient"
        
        if currentLevel == 2 {
            buttonNumber = "2"
            gradName = "nightGradient"
        } else if currentLevel == 3 {
            buttonNumber = "3"
            gradName = "dawnGradient"
        }
        
        print("enter shop scene")
        
        if currentLevel == 1 {
            self.backgroundColor = UIColor(red: 248/255, green: 177/255, blue: 149/255, alpha: 1)
        } else if currentLevel == 2 {
            self.backgroundColor = UIColor(red: 53/255, green: 92/255, blue: 125/255, alpha: 1)
        } else if currentLevel == 3 {
            self.backgroundColor = UIColor(red: 102/255, green: 205/255, blue: 212/255, alpha: 1)
        }
        
        let gradient = SKSpriteNode(imageNamed: gradName)
        gradient.size = self.size
        gradient.anchorPoint = CGPoint(x: 0.5, y: 0)
        gradient.position = CGPoint(x: self.size.width/2, y: 0)
        gradient.zPosition = -100
        self.addChild(gradient)
        
        //MARK: TOP GRADIENT
        let contentNode = SKSpriteNode(imageNamed: "\(gradName)Top")
        contentNode.size = CGSize(width: self.size.width, height: self.size.height * 0.22)
        contentNode.alpha = 0.97
        contentNode.zPosition = 5
        contentNode.anchorPoint = CGPoint(x: 0.5, y: 0)
        contentNode.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.78)
        self.addChild(contentNode)
        
        func goBack() -> Void {
            presentGame()
        }
        
        var scale: CGFloat
        
        //MARK: BACK BUTTON
        backButton = SKButton(buttonImage: "xButton\(buttonNumber)", buttonAction: goBack)
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            scale = 1.05
        default:
            scale = 0.7
        }
        backButton.alpha = 0.0
        backButton.position = CGPoint(x: self.size.width * 0.13, y: self.size.height * 0.93)
        backButton.setScale(scale)
        backButton.zPosition = 6
        self.addChild(backButton)
        backButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        
        //MARK: TITLE
        title = text("SHOP", fontSize: self.size.width/7, fontName: "DolceVitaLight", fontColor: SKColor.white)
        title.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.86)
        title.alpha = 0
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            title.position.y = self.size.height * 0.88
        default:
            break
        }
        
        title.zPosition = 6
        title.verticalAlignmentMode = .center
        self.addChild(title)
        title.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
        
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.8)
        
        //MARK: HOW MANY UNLOCKED CHARACTERS
        var textSizeDivider: CGFloat = 24
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            textSizeDivider = 30
        default:
            break
        }
        
        unlockedCharactersLabel = text("\(unlockedCharacters.count)/\(allCharacters.count) characters unlocked", fontSize: self.size.width/textSizeDivider, fontName: "Roboto-Light", fontColor: SKColor.white)
        unlockedCharactersLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.795)
        unlockedCharactersLabel.alpha = 0
        unlockedCharactersLabel.zPosition = 6
        self.addChild(unlockedCharactersLabel)
        unlockedCharactersLabel.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
        
        //MARK: COIN DISPLAY
        coinIcon = SKSpriteNode(imageNamed: "coin")
        coinIcon.position = CGPoint(x: self.size.width * 0.94, y: self.size.height * 0.94)
        coinIcon.zPosition = 6
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            coinIcon.setScale(0.7)
            coinIcon.position.y = self.size.height * 0.94
        default:
            coinIcon.setScale(0.4)
        }
        self.addChild(coinIcon)
        
        coinDisplay = text("\(gems)", fontSize: self.size.width/12, fontName: "Roboto-Light", fontColor: SKColor.white)
        coinDisplay.horizontalAlignmentMode = .right
        coinDisplay.zPosition = 6
        coinDisplay.position = CGPoint(x: self.size.width * 0.9, y: self.size.height * 0.94)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            coinDisplay.position.y = self.size.height * 0.94
            coinDisplay.fontSize = self.size.width/13
        default:
            break
        }
        coinDisplay.verticalAlignmentMode = .center
        self.addChild(coinDisplay)


        
        //MARK: SCROLL VIEW
        let scrollRect = CGRect(x: 0, y: self.size.height * 0.25, width: self.size.width, height: self.size.height * 0.75)
        scrollView = SKScrollView(frame: scrollRect, scene: self, moveableNode: moveableNode)
        
        let rowNum: Double = Double(allCharacters.count)/3.0
        let numRows = ceil(rowNum)
        print("num rows is \(numRows)")
        
        let endY = self.size.height * (0.7 - CGFloat((0.13 * CGFloat(numRows - 1))))
        let difference = self.size.height * 0.75 - endY
        let height = difference + (self.size.height * 0.1)
        print("scroll view height will be \(height)")
        print("thats \(height/self.size.height) screen heights")
        
        scrollView.contentSize = CGSize(width: self.frame.size.width, height: height)
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        view.addSubview(scrollView)
        
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            scale1 = 0.55
            if self.size.width < 375 {
                print("size is \(self.size.width)")
                scale1 = 0.47
            }
        case .pad:
            scale1 = 0.9
        default:
            scale1 = 0.7
        }
        
        func isSelected(_ characterName: String) -> Bool {
            if characterName == character {
                return true
            } else {
                return false
            }
            
        }
        
        func isUnlocked(_ characterName: String) -> Bool {
            for char in unlockedCharacters {
                if char == characterName {
                    return true
                }
            }
            return false
        }
        
        //MARK: CREATE CARDS
        for char in allCharacters {
            var card: SKSpriteNode
            var image: SKSpriteNode?
            var unlocked = false
            var imageName: String = "5000Locked"
            
            let index1: Int = allCharacters.index(of: char)!
            
            switch index1 {
            case 2...(num1000Characters + 1):
                imageName = "1000Locked"
            case (num1000Characters + 2)...(num1000Characters + num3000Characters + 1):
                imageName = "3000Locked"
            case (num1000Characters + num3000Characters + 2)...(num1000Characters + num3000Characters + num5000Characters + 1):
                imageName = "5000Locked"
            case 1:
                imageName = "0Locked"
            default:
                print("ERROR - NO CHARACTER AT INDEX \(index1)")
                break
            }

            if isSelected(char) {
                unlocked = true
                card = SKSpriteNode(imageNamed: "selected\(currentLevel)")
                image = SKSpriteNode(imageNamed: "\(char)\(currentLevel)")
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    image!.setScale(0.6)
                default:
                    image!.setScale(0.4)
                }
                image?.alpha = 0
            } else if isUnlocked(char) {
                unlocked = true
                card = SKSpriteNode(imageNamed: "unlocked")
                image = SKSpriteNode(imageNamed: "\(char)\(currentLevel)")
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    image!.setScale(0.6)
                default:
                    image!.setScale(0.4)
                }
                image?.alpha = 0
            } else {
                card = SKSpriteNode(imageNamed: imageName)
                
            }
            card.setScale(scale1)
            card.alpha = 0
            card.zPosition = 4

            //POSITION CARDS BY COLUMN
            let index = allCharacters.index(of: char)! + 1
            
            var fraction: CGFloat = 5
            
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                fraction = 4
            default:
                break
            }
            
            if index % 3 == 1 {
                card.position.x = self.size.width/fraction
                if unlocked {
                    image!.position.x = self.size.width/fraction
                }
            } else if index % 3 == 2 {
                card.position.x = self.size.width/2
                if unlocked {
                    image!.position.x = self.size.width/2
                }
            } else if index % 3 == 0 {
                card.position.x = self.size.width * ((fraction - 1.0)/fraction)
                if unlocked {
                    image!.position.x = self.size.width * ((fraction - 1.0)/fraction)
                }
            }
            
            //POSITION CARDS BY ROW
            let rowNum: Double = Double(index)/3.0
            let row = ceil(rowNum)
            
            let posY = self.size.height * (0.7 - CGFloat((0.13 * CGFloat(row - 1))))
            card.position.y = posY
            if unlocked {
                image!.position.y = posY
            }
            
            card.name = char
            image?.name = "image"
            image?.zPosition = 4
            
            if unlocked {
                moveableNode.addChild(image!)
                image?.run(SKAction.fadeIn(withDuration: 0.3))
                image?.run(SKAction.repeatForever(SKAction.rotate(byAngle: 2 * CGFloat((M_PI)), duration: 3)))
            }
            moveableNode.addChild(card)
            card.run(SKAction.fadeIn(withDuration: 0.3))
            
 
        }
        
    }
    
    func text(_ text: String, fontSize: CGFloat, fontName: String, fontColor: UIColor) -> SKLabelNode {
        
        let text1 = SKLabelNode(text: text)
        text1.fontSize = fontSize
        text1.fontName = fontName
        text1.fontColor = fontColor
        
        return text1
        
    }
    
    func presentGame() {
        let scene = GameScene(size: view!.bounds.size)
        let skView = self.view! as SKView
        
        scrollView.removeFromSuperview()
        
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        let getRidOfUI = SKAction.fadeOut(withDuration: 0.3)
        title.run(getRidOfUI)
        backButton.run(getRidOfUI)
        unlockedCharactersLabel.run(getRidOfUI)
        
        for char in allCharacters {
            moveableNode.enumerateChildNodes(withName: char, using: {
                node, stop in
                    node.run(getRidOfUI)
            })
        }
        
        moveableNode.enumerateChildNodes(withName: "image", using: {
            node, stop in
                node.run(getRidOfUI)
        })
        
        
        let present = SKAction.run({ skView.presentScene(scene) })
        backButton.run(SKAction.sequence([getRidOfUI, present]))
    }
    
    func clickCard(_ name: String) -> Void {
        var unlocked: Bool = false
        var is3000: Bool = false
        var is5000: Bool = false
        var cost = 1000
        
        let index1: Int = allCharacters.index(of: name)!
        
        switch index1 {
        case 2...(num1000Characters + 1):
            cost = 1000
        case (num1000Characters + 2)...(num1000Characters + num3000Characters + 1):
            cost = 3000
            is3000 = true
        case (num1000Characters + num3000Characters + 2)...(num1000Characters + num3000Characters + num5000Characters + 1):
            cost = 5000
            is3000 = true
            is5000 = true
        case 1:
            cost = 0
        default:
            print("ERROR - NO CHARACTER AT INDEX \(index1)")
            break
        }
    
        for char in unlockedCharacters {

            if char == name {
                unlocked = true
                break
            }
        }
        
        if name == character {
            if volumeOn {
                self.run(SKAction.playSoundFileNamed("ButtonClick.aif", waitForCompletion: false))
            }
            presentGame()
            return
        }
        
        if unlocked {
            character = name
            GameData.sharedInstance.currentCharacter = character
            GameData.sharedInstance.save()
            if volumeOn {
                self.run(SKAction.playSoundFileNamed("ButtonClick.aif", waitForCompletion: false))
            }
            for card in unlockedCharacters {
                print("unlocked Character is \(card)")
                let node: SKNode = moveableNode.childNode(withName: card)!
                let sprite: SKSpriteNode? = node as? SKSpriteNode
                sprite?.texture = SKTexture(imageNamed: "unlocked")
            }
            moveableNode.enumerateChildNodes(withName: name, using: {
                node, stop in
                let sprite: SKSpriteNode? = node as? SKSpriteNode
                sprite?.texture = SKTexture(imageNamed: "selected\(currentLevel)")
            })
        } else if !unlocked { //UNLOCK THE CLICKED CHARACTER
            if gems >= cost {
                gems -= cost
                coinDisplay.text = "\(gems)"
                
                
                unlockedCharacters.append(name)
                GameData.sharedInstance.unlockedCharacters = unlockedCharacters
                
                unlockedCharactersLabel.text = "\(unlockedCharacters.count)/\(allCharacters.count) characters unlocked"
                
                GameData.sharedInstance.gems = gems
                
                numUnlockedCharacters = unlockedCharacters.count
                
                if gameCenterEnabled {
                reportAchievementToGameCenter("com.quantumcat.dusk.unlock1Character", numberAchieved: numUnlockedCharacters, totalRequired: 1)
                reportAchievementToGameCenter("com.quantumcat.dusk.unlock5Characters", numberAchieved: numUnlockedCharacters, totalRequired: 5)
                reportAchievementToGameCenter("com.quantumcat.dusk.unlock10Characters", numberAchieved: numUnlockedCharacters, totalRequired: 10)
                reportAchievementToGameCenter("com.quantumcat.dusk.unlock20Characters", numberAchieved: numUnlockedCharacters, totalRequired: 20)
                reportAchievementToGameCenter("com.quantumcat.dusk.unlockAllCharacters", numberAchieved: numUnlockedCharacters, totalRequired: allCharacters.count)
                }

                character = name
                GameData.sharedInstance.currentCharacter = character
                GameData.sharedInstance.save()
                
                if volumeOn {
                    self.run(SKAction.playSoundFileNamed("FreeGiftSound.aif", waitForCompletion: false))
                }
                
                for card in unlockedCharacters {
                    let node: SKNode = moveableNode.childNode(withName: card)!
                    let sprite: SKSpriteNode? = node as? SKSpriteNode
                    sprite?.texture = SKTexture(imageNamed: "unlocked")
                }
                moveableNode.enumerateChildNodes(withName: name, using: {
                    node, stop in
                    let sprite: SKSpriteNode? = node as? SKSpriteNode
                    sprite?.texture = SKTexture(imageNamed: "selected\(currentLevel)")
                    
                    let image = SKSpriteNode(imageNamed: "\(name)\(currentLevel)")
                    var scale: CGFloat = 1
                    switch UIDevice.current.userInterfaceIdiom {
                    case .pad:
                        scale = 0.6
                    default:
                        scale = 0.4
                    }
                    image.zPosition = 4
                    image.setScale(scale)
                    image.name = "image"
                    image.alpha = 0
                    image.position = sprite!.position
                    self.moveableNode.addChild(image)
                    image.run(SKAction.fadeIn(withDuration: 0.3))
                    image.run(SKAction.repeatForever(SKAction.rotate(byAngle: 2 * CGFloat((M_PI)), duration: 3)))

                })
                
                switch dailyChallengeCurrent {
                case 7:
                    completeChallenge()
                case 14:
                    completeChallenge()
                case 8:
                    if is3000 {
                        completeChallenge()
                    }
                case 26:
                    if is3000 {
                        completeChallenge()
                    }
                case 9:
                    if is5000 {
                        completeChallenge()
                    }
                case 67:
                    if is5000 {
                        completeChallenge()
                    }
                case 90:
                    if is5000 {
                        completeChallenge()
                    }
                default:
                    break
                }
                
                
            } else {
                let node = moveableNode.childNode(withName: name)
                let sprite: SKSpriteNode? = node as? SKSpriteNode
                sprite?.color = SKColor.red
                sprite?.colorBlendFactor = 0
                
                let colorize = SKAction.colorize(withColorBlendFactor: 0.9, duration: 0.2)
                let deColorize = SKAction.colorize(withColorBlendFactor: 0, duration: 0.2)
                
                sprite?.run(SKAction.sequence([colorize, deColorize]))
                
                if volumeOn {
                    self.run(SKAction.playSoundFileNamed("ErrorSound.aif", waitForCompletion: false))
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            nodesTouched = nodes(at: location)
            for node in nodesTouched {
                node.touchesBegan(touches, with: event) // touches began in this case
                let theName = (node as! SKNode).name
                print(theName)
                if theName != nil && theName != "image" {
                    clickCard(theName!)
                }
                
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            nodesTouched = nodes(at: location)
            for node in nodesTouched {
                node.touchesMoved(touches, with: event) // touches began in this case
                
            }
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            nodesTouched = nodes(at: location)
            for node in nodesTouched {
                node.touchesEnded(touches, with: event) // touches began in this case
                
            }
        }

    }
    
    func reportAchievementToGameCenter(_ achievementId: String, numberAchieved: Int, totalRequired: Int) {
        
        let achievement = GKAchievement(identifier: achievementId)
        
        achievement.percentComplete = Double(numberAchieved/totalRequired) * 100
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement], withCompletionHandler: nil)
        
    }
    
}


