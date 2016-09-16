//
//  SettingsScene.swift
//  Dusk
//
//  Created by Noah Covey on 4/23/16.
//  Copyright © 2016 Quantum Cat Games. All rights reserved.
//

import SpriteKit
import AVFoundation
import StoreKit

class SettingsScene: SKScene, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var backButton: SKButton!
    var title: SKLabelNode!
    
    var coinDisplay: SKLabelNode!
    var coinIcon: SKSpriteNode!
    
    var volumeButton: SKButton!
    var helpButton: SKButton!
    var restoreButton: SKButton!
    var likeUsButton: SKButton!
    var removeAdsButton: SKButton!
    
    var volumeText: SKLabelNode!
    var helpText: SKLabelNode!
    var likeUsText: SKLabelNode!
    var restoreText: SKLabelNode!
    var removeAdsText: SKLabelNode!
    
    var developedByText: SKLabelNode!
    var logo: SKButton!
    var twitter: SKButton!
    var facebook: SKButton!
    
    var iapAvailable: Bool = false
    
    override func didMove(to view: SKView) {
        
        //MARK: IAPS
        if SKPaymentQueue.canMakePayments() {
            print("iap is enabled, loading")
            let productId: NSSet = NSSet(objects: "com.quantumcat.dusk.removeAds", "com.quantumcat.dusk.unlockNight", "com.quantumcat.dusk.unlockDawn")
            var request: SKProductsRequest = SKProductsRequest(productIdentifiers: productId as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("iap is disabled, please enable")
        }
        
        lastScene = "settings"
        
        var buttonNumber = ""
        var gradName = "duskGradient"
        
        if currentLevel == 2 {
            buttonNumber = "2"
            gradName = "nightGradient"
        } else if currentLevel == 3 {
            buttonNumber = "3"
            gradName = "dawnGradient"
        }
        
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
        self.addChild(backButton)
        backButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        
        //MARK: TITLE
        title = SKLabelNode(text: "OPTIONS")
        title.fontSize = self.size.width/7
        title.verticalAlignmentMode = . center
        title.fontColor = SKColor.white
        title.fontName = "DolceVitaLight"
        title.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.83)
        title.alpha = 0
        self.addChild(title)
        title.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
        
        func presentGame() {
            let scene = GameScene(size: view.bounds.size)
            let skView = self.view! as SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            let getRidOfUI = SKAction.fadeOut(withDuration: 0.3)
            title.run(getRidOfUI)
            volumeButton.run(getRidOfUI)
            volumeText.run(getRidOfUI)
            helpButton.run(getRidOfUI)
            helpText.run(getRidOfUI)
            likeUsText.run(getRidOfUI)
            likeUsButton.run(getRidOfUI)
            removeAdsText.run(getRidOfUI)
            removeAdsButton.run(getRidOfUI)
            restoreButton.run(getRidOfUI)
            restoreText.run(getRidOfUI)
            developedByText.run(getRidOfUI)
            logo.run(getRidOfUI)
            twitter.run(getRidOfUI)
            facebook.run(getRidOfUI)
            
            let present = SKAction.run({ skView.presentScene(scene) })
            backButton.run(SKAction.sequence([getRidOfUI, present]))
        }
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        
        //MARK: COIN DISPLAY
        coinIcon = SKSpriteNode(imageNamed: "coin")
        coinIcon.position = CGPoint(x: self.size.width * 0.94, y: self.size.height * 0.94)
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
        
        //MARK: BUTTON ACTIONS
        
        func restore() -> Void {
            print("restore purchases button pressed")
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
        
        func removeAds() -> Void {
            print("remove ads button pressed")
            if iapAvailable {
                for product in list {
                    let productId = product.productIdentifier
                    if productId == "com.quantumcat.dusk.removeAds" {
                        p = product
                        buyProduct()
                    }
                }
            } else {
                //ERROR, IN APP PURCHASES HAVE NOT LOADED YET
            }

        }
        
        
        func mute() -> Void {
            volumeOn = false
            GameData.sharedInstance.volumeOn = false
            GameData.sharedInstance.save()
            if currentLevel == 1 {
                volumeButton.setTexture("volumeOffButton")
            } else if currentLevel == 2 {
                volumeButton.setTexture("volumeOffButton2")
            } else if currentLevel == 3 {
                volumeButton.setTexture("volumeOffButton3")
            } else {
                volumeButton.setTexture("volumeOffButton")
            }
            volumeButton.changeAction(unMute)
            
            if backgroundMusicPlayer != nil {
                if backgroundMusicPlayer!.isPlaying {
                    backgroundMusicPlayer?.pause()
                }
            }
            
            if backgroundMusicPlayer2 != nil {
                if backgroundMusicPlayer2!.isPlaying {
                    backgroundMusicPlayer2?.pause()
                }
            }
            
            if backgroundMusicPlayer3 != nil {
            
                if backgroundMusicPlayer3!.isPlaying {
                    backgroundMusicPlayer3?.pause()
                }
                
            }
        
        }
        
        func unMute() -> Void {
            volumeOn = true
            GameData.sharedInstance.volumeOn = true
            GameData.sharedInstance.save()
            if currentLevel == 1 {
                volumeButton.setTexture("volumeOnButton")
            } else if currentLevel == 2 {
                volumeButton.setTexture("volumeOnButton2")
            } else if currentLevel == 3 {
                volumeButton.setTexture("volumeOnButton3")
            } else {
                volumeButton.setTexture("volumeOnButton")
            }
            volumeButton.changeAction(mute)
            
            if currentLevel == 1 {
            if backgroundMusicPlayer == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "DuskMusic2", withExtension: "m4a")
                backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer!.numberOfLoops = -1
            } else if !musicSilenced {
                backgroundMusicPlayer!.play()

            }
            } else if currentLevel == 2 {
                if backgroundMusicPlayer2 == nil {
                    let backgroundMusicURL = Bundle.main.url(forResource: "NightMusic", withExtension: "m4a")
                    backgroundMusicPlayer2 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                    backgroundMusicPlayer2!.numberOfLoops = -1
                } else if !musicSilenced {
                    backgroundMusicPlayer2!.play()
                    
                }
            } else if currentLevel == 3 {
                if backgroundMusicPlayer3 == nil {
                    let backgroundMusicURL = Bundle.main.url(forResource: "DawnMusic", withExtension: "m4a")
                    backgroundMusicPlayer3 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                    backgroundMusicPlayer3!.numberOfLoops = -1
                } else if !musicSilenced {
                    backgroundMusicPlayer3!.play()
                    
                }
            }
            
        }
        
        func help() -> Void {
            tutorialNeeded = true
            presentGame()
        }
        
        func likeUs() -> Void {
            let url1 = "fb://profile/503287153144438"
            let url2 = "https://www.facebook.com/ketchappgames"
            //UIApplication.tryURL([url1, url2])
        }
        
        func goFacebook() -> Void {
            let url1 = "fb://profile/502025146670643"
            let url2 = "https://www.facebook.com/Quantum-Cat-Games-502025146670643/"
            UIApplication.tryURL([url1, url2])
        }
        
        func goTwitter() -> Void {
            let url1 = "twitter://user?screen_name=QuantumCatGames"
            let url2 = "https://twitter.com/QuantumCatGames"
            UIApplication.tryURL([url1, url2])
        }
        
        func goWeb() -> Void {
            let url1 = "http://quantumcatgames.weebly.com"
            UIApplication.tryURL([url1])
        }
        
        //MARK: BUTTONS
        if volumeOn == true {
            volumeButton = SKButton(buttonImage: "volumeOnButton\(buttonNumber)", buttonAction: mute)
        } else {
            volumeButton = SKButton(buttonImage: "volumeOffButton\(buttonNumber)", buttonAction: unMute)
        }
        volumeButton.setScale(scale)
        volumeButton.alpha = 0.0
        volumeButton.position = CGPoint(x: self.size.width * (1/4), y: self.size.height * 0.65)
        self.addChild(volumeButton)
        volumeButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        
        volumeText = SKLabelNode(text: "Mute")
        volumeText.fontName = "Roboto-Light"
        volumeText.fontSize = self.size.height / 40
        volumeText.fontColor = SKColor.white
        volumeText.position = CGPoint(x: volumeButton.position.x, y: volumeButton.position.y - ((volumeButton.size.height * scale * 0.43) + (volumeButton.size.height * scale/2)))
        volumeText.alpha = 0
        self.addChild(volumeText)
        volumeText.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
        
        helpButton = SKButton(buttonImage: "helpButton\(buttonNumber)", buttonAction: help)
        helpButton.setScale(scale)
        helpButton.alpha = 0
        helpButton.position = CGPoint(x: self.size.width * (3/4), y: self.size.height * 0.65)
        self.addChild(helpButton)
        helpButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        
        helpText = SKLabelNode(text: "Reset Tutorial")
        helpText.fontName = "Roboto-Light"
        helpText.fontSize = self.size.height / 40
        helpText.fontColor = SKColor.white
        helpText.position = CGPoint(x: helpButton.position.x, y: helpButton.position.y - ((helpButton.size.height * scale * 0.43) + (helpButton.size.height * scale/2)))
        helpText.alpha = 0
        self.addChild(helpText)
        helpText.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
        
        likeUsButton = SKButton(buttonImage: "likeButton\(buttonNumber)", buttonAction: likeUs)
        likeUsButton.setScale(scale)
        likeUsButton.alpha = 0
        likeUsButton.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.53)
        self.addChild(likeUsButton)
        likeUsButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        
        likeUsText = SKLabelNode(text: "Like Us")
        likeUsText.fontName = "Roboto-Light"
        likeUsText.fontSize = self.size.height / 40
        likeUsText.fontColor = SKColor.white
        likeUsText.position = CGPoint(x: likeUsButton.position.x, y: likeUsButton.position.y - ((likeUsButton.size.height * scale * 0.43) + (likeUsButton.size.height * scale/2)))
        likeUsText.alpha = 0
        self.addChild(likeUsText)
        likeUsText.run(SKAction.fadeAlpha(to: 1, duration: 0.3))

        restoreButton = SKButton(buttonImage: "restoreButton\(buttonNumber)", buttonAction: restore)
        restoreButton.setScale(scale)
        restoreButton.alpha = 0
        restoreButton.position = CGPoint(x: self.size.width * (3/4), y: self.size.height * 0.43)
        self.addChild(restoreButton)
        restoreButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        
        restoreText = text("Restore Purchases", fontSize: self.size.height/40, fontName: "Roboto-Light", fontColor: SKColor.white)
        restoreText.position = CGPoint(x: restoreButton.position.x, y: restoreButton.position.y - ((restoreButton.size.height * scale * 0.43) + (restoreButton.size.height * scale/2)))
        restoreText.alpha = 0
        self.addChild(restoreText)
        restoreText.run(SKAction.fadeIn(withDuration: 0.3))
        
        removeAdsButton = SKButton(buttonImage: "removeAdsButton\(buttonNumber)", buttonAction: removeAds)
        removeAdsButton.setScale(scale)
        removeAdsButton.alpha = 0
        removeAdsButton.position = CGPoint(x: self.size.width * (1/4), y: self.size.height * 0.43)
        self.addChild(removeAdsButton)
        removeAdsButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        
        removeAdsText = text("Remove Ads", fontSize: self.size.height/40, fontName: "Roboto-Light", fontColor: SKColor.white)
        removeAdsText.position = CGPoint(x: removeAdsButton.position.x, y: removeAdsButton.position.y - ((removeAdsButton.size.height * scale * 0.43) + (removeAdsButton.size.height * scale/2)))
        removeAdsText.alpha = 0
        self.addChild(removeAdsText)
        removeAdsText.run(SKAction.fadeIn(withDuration: 0.3))

        developedByText = text("Developed by Quantum Cat Games", fontSize: self.size.height/35, fontName: "Roboto-Regular", fontColor: SKColor.white)
        developedByText.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.26)
        developedByText.alpha = 0
        self.addChild(developedByText)
        developedByText.run(SKAction.fadeIn(withDuration: 0.3))
        
        logo = SKButton(buttonImage: "logo", buttonAction: goWeb)
        logo.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.18)
        logo.setScale(self.size.width * 0.16/logo.size.height)
        logo.alpha = 0
        self.addChild(logo)
        logo.run(SKAction.fadeAlpha(to: 0.7, duration: 0.3))
        
        twitter = SKButton(buttonImage: "twitter", buttonAction: goTwitter)
        twitter.setScale(self.size.width * 0.16/twitter.size.height)
        twitter.position = CGPoint(x: self.size.width/2 - (((twitter.size.width * (self.size.width * 0.16/twitter.size.height))/2) + self.size.width * 0.12), y: self.size.height * 0.18)
        twitter.alpha = 0
        self.addChild(twitter)
        twitter.run(SKAction.fadeAlpha(to: 0.7, duration: 0.3))
        
        facebook = SKButton(buttonImage: "facebook", buttonAction: goFacebook)
        facebook.setScale(self.size.width * 0.16/facebook.size.height)
        facebook.position = CGPoint(x: self.size.width/2 + (((facebook.size.width * (self.size.width * 0.16/facebook.size.height))/2) + self.size.width * 0.12), y: self.size.height * 0.18)
        facebook.alpha = 0
        self.addChild(facebook)
        facebook.run(SKAction.fadeAlpha(to: 0.7, duration: 0.3))
        
        
    }
    
    func text(_ text: String, fontSize: CGFloat, fontName: String, fontColor: UIColor) -> SKLabelNode {
        
        let text1 = SKLabelNode(text: text)
        text1.fontSize = fontSize
        text1.fontName = fontName
        text1.fontColor = fontColor
        
        return text1
        
    }
    
    //MARK: IN APP PURCHASES
    
    var list = [SKProduct]()
    var p = SKProduct()
    
    func buyProduct() {
        
        print("buy \(p.productIdentifier)")
        let pay = SKPayment(product: p)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(pay as SKPayment)
        
    }
    
    func remove() {
        //currentBannerAd.removeFromSuperview()
        print("ADS SUCCESSFULLY REMOVED")
        hasRemovedAds = true
        GameData.sharedInstance.hasRemovedAds = true
        GameData.sharedInstance.save()

        let alert = UIAlertController(title: "Thank You", message: "Ads removed successfully.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
        }))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func unlockNightNow() {
        nightUnlocked = true
        GameData.sharedInstance.level2Unlocked = true
        GameData.sharedInstance.save()
    }
    
    func unlockDawnNow() {
        
        dawnUnlocked = true
        GameData.sharedInstance.level3Unlocked = true
        GameData.sharedInstance.save()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        print("products request")
        let myProduct = response.products
        for product in myProduct {
            print("product added")
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            
            list.append(product as SKProduct)
        }
        
        iapAvailable = true
        
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        print("add payment")
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            print("error is")
            print(trans.error)
            switch trans.transactionState {
                
            case .purchased:
                print("buy, ok unlock iap here")
                print(p.productIdentifier)
                let prodId = p.productIdentifier as String
                switch prodId {
                case "com.quantumcat.dusk.removeAds":
                    print("removing ads")
                    remove()
                    queue.finishTransaction(trans)
                case "com.quantumcat.dusk.unlockNight":
                    print("unlock level 2 right now")
                    unlockNightNow()
                    queue.finishTransaction(trans)
                case "com.quantumcat.dusk.unlockDawn":
                    print("unlock level 3 right now")
                    unlockDawnNow()
                    queue.finishTransaction(trans)
                default:
                    print("iap not set up")
                    
                    
                }
            case .failed:
                print("buy error")
                queue.finishTransaction(trans)
            default:
                print("default in payment queue")
                
                
            }
            
        }
        
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
        print("transactions restore")
        //let purchasedItemIds = []
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction as SKPaymentTransaction
            let prodId = t.payment.productIdentifier as String
            print("restoring")
            switch prodId {
            case "com.quantumcat.dusk.removeAds":
                print("restore remove ads")
                remove()
                queue.finishTransaction(transaction)
            case "com.quantumcat.dusk.unlockNight":
                print("restore level 2 right now")
                unlockNightNow()
                queue.finishTransaction(transaction)
                print("finished transaction night")
            case "com.quantumcat.dusk.unlockDawn":
                print("restore level 3 right now")
                unlockDawnNow()
                queue.finishTransaction(transaction)
                print("finished transaction dawn")
            default:
                print("iap not set up")
                
                
            }
            
        }
        
    }
    
    func finishTransaction(_ trans:SKPaymentTransaction) {
        print("finished transaction")
    }
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("removed transaction")
    }
    

    
}
