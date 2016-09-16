//
//  GameScene.swift
//  Dusk
//
//  Created by Noah Covey on 3/11/16.
//  Copyright (c) 2016 Quantum Cat Games. All rights reserved.
//

import SpriteKit
import AVFoundation
import GameKit
import StoreKit

var backgroundMusicPlayer: AVAudioPlayer?
var backgroundMusicPlayer2: AVAudioPlayer?
var backgroundMusicPlayer3: AVAudioPlayer?

var lastDusk = 0
var lastNight = 0
var lastDawn = 0

var numTaps: Int = 0

var didSwipe = false

var dailyChallengeSpaceDown: Bool = false

var gamePaused = false

var timeCount:TimeInterval = 21600.0

extension SKNode {
    class func unarchiveFromFile(_ file : String) -> SKNode? {
        guard let
            path = Bundle.main.path(forResource: file, ofType: "sks"),
            let sceneData = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) else {
                return nil
        }
        
        let archiver = NSKeyedUnarchiver(forReadingWith: sceneData)
        archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
        
        guard let scene = archiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? SKNode else {
            return nil
        }
        
        archiver.finishDecoding()
        return scene
    }
}

extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
    
}

extension SKAction {
    class func shake(_ duration:CGFloat, amplitudeX:Int = 3, amplitudeY:Int = 3) -> SKAction {
        let numberOfShakes = duration / 0.015 / 2.0
        var actionsArray:[SKAction] = []
        for _ in 1...Int(numberOfShakes) {
            let dx = CGFloat(arc4random_uniform(UInt32(amplitudeX))) - CGFloat(amplitudeX / 2)
            let dy = CGFloat(arc4random_uniform(UInt32(amplitudeY))) - CGFloat(amplitudeY / 2)
            let forward = SKAction.moveBy(x: dx, y:dy, duration: 0.015)
            let reverse = forward.reversed()
            actionsArray.append(forward)
            actionsArray.append(reverse)
        }
        return SKAction.sequence(actionsArray)
    }
}

extension UIApplication {
    class func tryURL(_ urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(URL(string: url)!) {
                application.openURL(URL(string: url)!)
                return
            }
        }
    }
}


var score: Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate, GKGameCenterControllerDelegate, SKStoreProductViewControllerDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    var world: SKNode!
    
    var price: String = "$0.99"
    var priceDisplay: SKLabelNode!
    
    var numberOfLevels = 35
    var numberOfMediumLevels = 6
    var numberOfEasyLevels = 9
    var startLevel = 1
    
    var last = 0
    
    var didCollectGift: Bool = false
    var iapAvailable: Bool = false
    
    var player: SKSpriteNode!
    var player2: SKSpriteNode!
    var player3: SKSpriteNode!
    
    var coinIcon: SKSpriteNode!
    var coinDisplay: SKLabelNode!
    var newCoinsIcon: SKSpriteNode!
    var newCoinsDisplay: SKLabelNode!
    
    var trail: SKEmitterNode!
    var trail2: SKEmitterNode!
    var trail3: SKEmitterNode!
    
    var lock: SKSpriteNode!
    
    var unlockNightButton: SKButton!
    var unlockDawnButton: SKButton!
    
    var lockedText1: SKLabelNode!
    var lockedText2: SKLabelNode!
    
    var scoreBoard: SKLabelNode!
    var guideCircle: SKSpriteNode!
    
    var dead = false
    
    var transitioningLevels = false
    
    var gradient: SKSpriteNode!
    var nightGradient: SKSpriteNode!
    var dawnGradient: SKSpriteNode!
    
    var background1: SKSpriteNode!
    
    var darkener: SKSpriteNode!
    var instructionsText1: SKLabelNode!
    var instructionsText2: SKLabelNode!
    var instructionsText3: SKLabelNode!
    var swipeCircle: SKShapeNode!
    var confetti: SKEmitterNode!
    
    var title: SKLabelNode!
    var touchToStart: SKLabelNode!
    var scoreLabel: SKLabelNode!
    
    var scoreMarker: SKLabelNode!
    var scoreMarker2: SKLabelNode!
    var scoreMarker3: SKLabelNode!
    
    var bestLabel: SKLabelNode!
    
    var bestMarker: SKLabelNode!
    var bestMarker2: SKLabelNode!
    var bestMarker3: SKLabelNode!
    
    var timer = Timer()
    
    var cheapestItem: Int = 5000

    var highScoreImage: SKSpriteNode!
    var dailyBestLabel: SKLabelNode!
    
    var pauseButton: SKButton!
    var playButton: SKButton!
    var homeButton: SKButton!
    
    var shopButton: SKButton!
    var rateButton: SKButton!
    var leaderboardButton: SKButton!
    var settingsButton: SKButton!
    var removeAdsButton: SKButton!
    var likeButton: SKButton!
    var giftButton: SKButton!
    var shareButtonCircle: SKButton!
    
    var shopButton2: SKButton!
    var rateButton2: SKButton!
    var leaderboardButton2: SKButton!
    var settingsButton2: SKButton!
    var removeAdsButton2: SKButton!
    var likeButton2: SKButton!
    var giftButton2: SKButton!
    var shareButtonCircle2: SKButton!
    
    var shopButton3: SKButton!
    var rateButton3: SKButton!
    var leaderboardButton3: SKButton!
    var settingsButton3: SKButton!
    var removeAdsButton3: SKButton!
    var likeButton3: SKButton!
    var giftButton3: SKButton!
    var shareButtonCircle3: SKButton!
    
    var leftTouch: SKButton!
    var rightTouch: SKButton!
    
    var rightArrow: SKButton!
    var leftArrow: SKButton!
    
    var leftArrow2: SKButton!
    var rightArrow2: SKButton!
    
    var leftArrow3: SKButton!
    var rightArrow3: SKButton!
        
    var levelText: SKLabelNode!
    //var bestText: SKLabelNode!
    
    var movingRight: Bool = true
    
    var center: CGPoint!
    var radius: CGFloat!
    
    var iPadScale: CGFloat = 1.5
    var segmentHeight:CGFloat = 400
    var segmentWidth: CGFloat = 320
    
    var speedRotate: CGFloat = 125.0
    var speedGame: Double = 4.0
    
    var isHolding: Bool = false
    var gameStarted: Bool = false
    
    var leftSwipe: UISwipeGestureRecognizer!
    var rightSwipe: UISwipeGestureRecognizer!
    
    var path: UIBezierPath!
    
    let timerEnd: TimeInterval = 0.0
    
    //MARK: UPDATE TIMER
    func updateTimer() {
        if timeCount > timerEnd {
            timeCount -= 1.0
            
        } else {
            print("turn gift available")
            giftAvailable = true
            giftButton.setTexture("giftButton1")
            giftButton2.setTexture("giftButton2")
            giftButton3.setTexture("giftButton3")
            giftButton.changeAction(gift)
            giftButton2.changeAction(gift)
            giftButton3.changeAction(gift)
            
            giftButton.removeAllActions()
            giftButton2.removeAllActions()
            giftButton3.removeAllActions()

            let bigger = SKAction.scale(by: 1.2, duration: 0.3)
            bigger.timingMode = .easeInEaseOut
            
            let rotateLeft1 = SKAction.rotate(byAngle: CGFloat(-(M_PI/24)), duration: 0.05)
            let rotateRight = SKAction.rotate(byAngle: CGFloat(M_PI/12), duration: 0.1)
            let rotateLeft = SKAction.rotate(byAngle: CGFloat(-(M_PI/12)), duration: 0.1)
            
            let shake = SKAction.sequence([rotateLeft1, rotateRight, rotateLeft, rotateRight, rotateLeft1])
            let wait = SKAction.wait(forDuration: 1)
            
            let grow = SKAction.group([bigger, shake])
                
            let smaller = SKAction.scale(by: 1/1.2, duration: 0.5)
            smaller.timingMode = .easeInEaseOut
        
            let pulse = SKAction.repeatForever(SKAction.sequence([grow, wait, smaller]))
        
            giftButton.run(pulse, withKey: "pulse")
            giftButton2.run(pulse, withKey: "pulse")
            giftButton3.run(pulse, withKey: "pulse")

        
            timeCount = 21600.0
            timer.invalidate()
        }
    }
    /*
    func timeString(time: NSTimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }*/
    
    
    let labelColor = UIColor(red: 227/255, green: 190/255, blue: 200/255, alpha: 1)
    var labelColor2: UIColor = UIColor(red: 190/255, green: 199/255, blue: 216/255, alpha: 1)
    var labelColor3: UIColor = UIColor(red: 228/255, green: 252/255, blue: 247/255, alpha: 1)
    
    //MARK: GIFT

    func gift() -> Void {
        if !swipeTutorialNeeded && !level3TutorialNeeded {
            
            if giftAvailable {
                print("gift available")
                giftAvailable = false
                didCollectGift = true
                
                let num25ToGain: Int = Int(arc4random_uniform(UInt32(9)))
                let gemsToGain = (25 * num25ToGain) + 500
                
                gems += gemsToGain
                
                var fader: iiFaderForAvAudioPlayer
                switch currentLevel {
                case 1:
                    fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
                case 2:
                    fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
                case 3:
                    fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer3!)
                default:
                    fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
                }
                
                fader.fade(fromVolume: 1.0, toVolume: 0.7, duration: 0.3, velocity: 1, onFinished:  { finished in
                    let wait = SKAction.wait(forDuration: 0.5)
                    
                    let fade = SKAction.run( { fader.fadeIn(0.3, velocity: 2) } )
                    
                    self.run(SKAction.sequence([wait,fade]))
                })
                
                
                if volumeOn {
                    self.run(SKAction.playSoundFileNamed("FreeGiftSound.aif", waitForCompletion: false))
                }
                
                let explosion = SKEmitterNode(fileNamed: "CoinExplosion.sks")
                explosion?.position = giftButton.position
                explosion?.zPosition = 19
                self.addChild(explosion!)
                let wait = SKAction.wait(forDuration: 2.8)
                explosion?.run(SKAction.sequence([wait, SKAction.removeFromParent()]))
                

                if gems >= cheapestItem && (gems - 500 < cheapestItem) {
                    
                    let bigger = SKAction.scale(by: 1.2, duration: 0.3)
                    bigger.timingMode = .easeInEaseOut
                    
                    let rotateLeft1 = SKAction.rotate(byAngle: CGFloat(-(M_PI/24)), duration: 0.05)
                    let rotateRight = SKAction.rotate(byAngle: CGFloat(M_PI/12), duration: 0.1)
                    let rotateLeft = SKAction.rotate(byAngle: CGFloat(-(M_PI/12)), duration: 0.1)
                    
                    let shake = SKAction.sequence([rotateLeft1, rotateRight, rotateLeft, rotateRight, rotateLeft1])
                    let wait = SKAction.wait(forDuration: 1)
                    
                    let grow = SKAction.group([bigger, shake])
                    
                    let smaller = SKAction.scale(by: 1/1.2, duration: 0.5)
                    smaller.timingMode = .easeInEaseOut
                    
                    let pulse = SKAction.repeatForever(SKAction.sequence([grow, wait, smaller]))
                    
                    shopButton.run(pulse)
                    shopButton2.run(pulse)
                    shopButton3.run(pulse)
                    
                }
                
                
                    newCoinsIcon = SKSpriteNode(imageNamed: "coin")
                    newCoinsIcon.position = CGPoint(x: self.size.width * 0.94, y: self.size.height * 0.89)
                    switch UIDevice.current.userInterfaceIdiom {
                    case .pad:
                        newCoinsIcon.setScale(0.6)
                        newCoinsIcon.position.y = self.size.height * 0.89
                    default:
                        newCoinsIcon.setScale(0.35)
                    }
                    newCoinsIcon.alpha = 0
                    self.addChild(newCoinsIcon)
                    newCoinsIcon.run(SKAction.fadeAlpha(to: 0.6, duration: 0.8))
                    
                    newCoinsDisplay = text("+\(gemsToGain)", fontSize: self.size.width/15, fontName: "Roboto-Light", fontColor: SKColor.white)
                    newCoinsDisplay.horizontalAlignmentMode = .right
                    newCoinsDisplay.position = CGPoint(x: self.size.width * 0.9, y: self.size.height * 0.89)
                    newCoinsDisplay.alpha = 0
                    switch UIDevice.current.userInterfaceIdiom {
                    case .pad:
                        newCoinsDisplay.position.y = self.size.height * 0.89
                        newCoinsDisplay.fontSize = self.size.width/17
                    default:
                        break
                    }
                    newCoinsDisplay.verticalAlignmentMode = .center
                    self.addChild(newCoinsDisplay)
                    newCoinsDisplay.run(SKAction.fadeAlpha(to: 0.6, duration: 0.8))
                
                
                func updateLabel(_ node: SKNode!, t: CGFloat) {
                    
                    let coinToAdd = ceil(Double(gemsToGain) * Double(t/2)) + Double(gems - gemsToGain)
                    coinDisplay.text = "\(Int(coinToAdd))"
                }
                
                self.run(SKAction.customAction(withDuration: 2, actionBlock: updateLabel))
                
                let coinBig = SKAction.scale(by: 1.2, duration: 0.1)
                let coinSmall = SKAction.scale(by: 1/1.2, duration: 0.1)
                
                let coinPulse = SKAction.repeat(SKAction.sequence([coinBig, coinSmall]), count: 10)
                coinIcon.run(coinPulse)
                coinDisplay.run(coinPulse)
                
                giftButton.setTexture("dailyChallengeButton1")
                giftButton2.setTexture("dailyChallengeButton2")
                giftButton3.setTexture("dailyChallengeButton3")
                
                giftButton.changeAction(goToDailyChallenge)
                giftButton2.changeAction(goToDailyChallenge)
                giftButton3.changeAction(goToDailyChallenge)
                
                if dailyChallengeCurrent == 10 {
                    completeChallenge()
                    
                }
                
                var scale: CGFloat = 0.5
                
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    scale = 1.1
                default:
                    scale = 0.5
                }
                
                if dailyChallengeCompleted && rewardAlreadyCollected {
                    giftButton.removeAllActions()
                    giftButton2.removeAllActions()
                    giftButton3.removeAllActions()
                    let scaleDown = SKAction.scale(to: scale * 1.2, duration: 0.3)
                    giftButton.run(scaleDown)
                    giftButton2.run(scaleDown)
                    giftButton3.run(scaleDown)
                }
                
                if dailyChallengeCompleted && !rewardAlreadyCollected {
                    giftButton.setTexture("challengeCompleteButton1")
                    giftButton2.setTexture("challengeCompleteButton2")
                    giftButton3.setTexture("challengeCompleteButton3")
                }
                
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
                
                UIApplication.shared.applicationIconBadgeNumber = 0
                
                let date = Date()
                giftDate = date.addingTimeInterval(21600)
                //giftDate = date.dateByAddingTimeInterval(180)
                print("date is \(date)")
                print("gift date is \(giftDate)")
                
                GameData.sharedInstance.gems = gems
                GameData.sharedInstance.giftDate = giftDate
                GameData.sharedInstance.save()
                
                func askForNotifications() {
                    UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
                    
                    hasChosenNotifications = true
                    GameData.sharedInstance.hasChosenNotifications = true
                    GameData.sharedInstance.save()
                    
                    
                }
                
                if !hasChosenNotifications {
                    let alert = UIAlertController(title: "Free Gifts", message: "Would you like to be notified the next time a gift is available?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "No", style: .default, handler: {
                        (alert: UIAlertAction!) in
                        allowsNotifications = false
                        GameData.sharedInstance.allowsNotifications = false
                        hasChosenNotifications = true
                        GameData.sharedInstance.hasChosenNotifications = true
                        GameData.sharedInstance.save()
                        
                    }))
                    alert.addAction(UIAlertAction(title: "Yes!", style: .default, handler: {
                        (alert: UIAlertAction!) in
                        askForNotifications()
                        allowsNotifications = true
                        GameData.sharedInstance.allowsNotifications = true
                        GameData.sharedInstance.save()
                    }))
                    
                    
                    self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                }
                
                if allowsNotifications && hasChosenNotifications {
                    print("creating notification in gift function")
                    let notification: UILocalNotification = UILocalNotification()
                    notification.alertBody = "Free gift available. Come claim it now!"
                    notification.alertAction = "collect gift"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.applicationIconBadgeNumber = 1
                    notification.category = "GIFT"
                    notification.fireDate = giftDate as Date
                    
                    UIApplication.shared.scheduleLocalNotification(notification)
                    
                }
                
                
                
                
                
            }
            
        } else {
            
            
            
        }
    }


    
    //MARK: SWIPE RIGHT
    func swipeRight() -> Void {
        if !gameStarted {
        //MARK: GO FROM LEVEL 1 TO 2, WHICH IS UNLOCKED
        if currentLevel == 1 && nightUnlocked && !transitioningLevels {
            print("\(transitioningLevels)")
            transitioningLevels = true
            print("\(transitioningLevels)")
            let moveGradient = SKAction.moveBy(x: -self.size.width, y: 0, duration: 0.33)
            moveGradient.timingMode = .easeOut
            
            gradient.run(moveGradient)
            nightGradient.run(moveGradient)
            dawnGradient.run(moveGradient)
            let colorize = SKAction.colorize(with: UIColor(red: 59/255, green: 92/255, blue: 125/255, alpha: 1), colorBlendFactor: 1.0, duration: 0.3)
            
            background1.run(colorize)
            
            currentLevel = 2
            
            if swipeTutorialNeeded {
                
                darkener.run(SKAction.fadeOut(withDuration: 0.3))
                instructionsText2.run(SKAction.fadeOut(withDuration: 0.3))
                instructionsText1.run(SKAction.fadeOut(withDuration: 0.3))
                instructionsText3.run(SKAction.fadeOut(withDuration: 0.3))
                swipeCircle.removeAllActions()
                swipeCircle.run(SKAction.fadeOut(withDuration: 0.3))
                
                swipeTutorialNeeded = false
                
            }
            
            if dailyBestAchievedNight {
                dailyBestLabel.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
            } else if dailyBestAchievedDusk {
                dailyBestLabel.run(SKAction.fadeOut(withDuration: 0.3))
            }
            
            if backgroundMusicPlayer2 == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "NightMusic", withExtension: "m4a")
                backgroundMusicPlayer2 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer2!.numberOfLoops = -1
            }
            if backgroundMusicPlayer2!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer2!.play()
                backgroundMusicPlayer2!.volume = 0
            }
            
            let fader1 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
            let fader2 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            
            fader2.fadeIn(0.3, velocity: 2)
            fader1.fadeOut(0.3, velocity: 2) {finished in
                backgroundMusicPlayer?.pause()
                self.transitioningLevels = false
            }
            
            player2.run(SKAction.fadeIn(withDuration: 0.3))
            
            if trail2 == nil {
                trail2 = SKEmitterNode(fileNamed: "Trail2.sks")
                trail2?.zPosition = 0
                trail2?.targetNode = self
                trail2?.isHidden = true
            
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    trail2?.particleScale = 0.6
                default:
                    break
                }
                player.addChild(trail2!)
            } else {
                trail2.particleBirthRate = 60
            }
            
            levelText.text = "LEVEL 2: NIGHT"
            //bestText.text = "BEST: \(highScoreNight)"
            bestLabel.text = "\(highScoreNight)"
            scoreLabel.text = "\(lastNight)"
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            
            scoreMarker.run(fadeOut)
            bestMarker.run(fadeOut)
            
            scoreMarker2.run(fadeIn)
            bestMarker2.run(fadeIn)
            
            shopButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rateButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leaderboardButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            settingsButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            removeAdsButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leftArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rightArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            giftButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            shareButtonCircle2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            likeButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            
            shopButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rateButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leaderboardButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            settingsButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            removeAdsButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leftArrow.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rightArrow.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            giftButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            shareButtonCircle.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            likeButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))

            
        } else if currentLevel == 1 && !nightUnlocked && !transitioningLevels {
            //MARK: GO FROM LEVEL 1 TO 2, WHICH IS LOCKED
            transitioningLevels = true
            
            levelText.text = "LEVEL 2: NIGHT"
            //bestText.text = "LOCKED"
            currentLevel = 2
            let moveGradient = SKAction.moveBy(x: -self.size.width, y: 0, duration: 0.33)
            moveGradient.timingMode = .easeOut
            
            gradient.run(moveGradient)
            nightGradient.run(moveGradient)
            dawnGradient.run(moveGradient)
            let colorize = SKAction.colorize(with: UIColor(red: 59/255, green: 92/255, blue: 125/255, alpha: 1), colorBlendFactor: 1.0, duration: 0.3)
            
            background1.run(colorize)
            
            if dailyBestAchievedDusk {
                dailyBestLabel.run(SKAction.fadeOut(withDuration: 0.3))
            }
            
            if backgroundMusicPlayer2 == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "NightMusic", withExtension: "m4a")
                backgroundMusicPlayer2 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer2!.numberOfLoops = -1
            }
            if backgroundMusicPlayer2!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer2!.play()
                backgroundMusicPlayer2!.volume = 0
            }
            
            let fader1 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
            let fader2 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            
            fader2.fadeIn(0.3, velocity: 2)
            fader1.fadeOut(0.3, velocity: 2) {finished in
                backgroundMusicPlayer?.pause()
                self.transitioningLevels = false
            }
            
            player2.run(SKAction.fadeIn(withDuration: 0.3))
            
            trail2 = SKEmitterNode(fileNamed: "Trail2.sks")
            trail2?.zPosition = 0
            trail2?.targetNode = self
            trail2?.isHidden = true
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                trail2?.particleScale = 0.6
            default:
                break
            }
            player.addChild(trail2!)
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            
            scoreMarker.run(fadeOut)
            bestMarker.run(fadeOut)
            
            scoreMarker2.run(fadeIn)
            bestMarker2.run(fadeIn)
            
            
            lock = SKSpriteNode(imageNamed: "lock")
            lock.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.39)
            lock.alpha = 0
            lock.color = UIColor(red: 192/255, green: 108/255, blue: 132/255, alpha: 1)
            lock.colorBlendFactor = 0
            lock.zPosition = 15
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                lock.setScale(0.55)
            default:
                lock.setScale(0.9)
            }
            self.addChild(lock)
            lock.run(SKAction.fadeIn(withDuration: 0.4))
            
            lockedText1 = text("Reach 100 on level 1", fontSize: self.size.width/24, fontName: "Roboto-Light", fontColor: SKColor.white)
            lockedText1.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
            lockedText1.alpha = 0.0
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                lockedText1.fontSize = self.size.width/33
            default:
                break
            }
            self.addChild(lockedText1)
            lockedText1.run(SKAction.fadeIn(withDuration: 0.3))

            
            lockedText2 = text("to unlock level 2.", fontSize: self.size.width/24, fontName: "Roboto-Light", fontColor: SKColor.white)
            lockedText2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.27)
            lockedText2.alpha = 0.0
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                lockedText2.fontSize = self.size.width/33
            default:
                break
            }
            self.addChild(lockedText2)
            lockedText2.run(SKAction.fadeIn(withDuration: 0.3))
            
            unlockNightButton.run(SKAction.fadeIn(withDuration: 0.2))
            priceDisplay.run(SKAction.fadeIn(withDuration: 0.2))

            touchToStart.removeFromParent()
            bestLabel.text = "\(highScoreNight)"
            scoreLabel.text = "\(lastNight)"
            
            shopButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rateButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leaderboardButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            settingsButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            removeAdsButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leftArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rightArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            giftButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            shareButtonCircle2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            likeButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))

            
            shopButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rateButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leaderboardButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            settingsButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            removeAdsButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leftArrow.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rightArrow.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            giftButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            shareButtonCircle.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            likeButton.run(SKAction.fadeAlpha(to: 0, duration: 0.3))

            
        } else if currentLevel == 2 && dawnUnlocked && !transitioningLevels { //MOVE TO LEVEL 3
            //MARK: GO FROM LEVEL 2 TO 3, WHICH IS UNLOCKED
            
            transitioningLevels = true
            levelText.text = "LEVEL 3: DAWN"
            
            let moveGradient = SKAction.moveBy(x: -self.size.width, y: 0, duration: 0.33)
            moveGradient.timingMode = .easeOut

            gradient.run(moveGradient)
            nightGradient.run(moveGradient)
            dawnGradient.run(moveGradient)
            let colorize = SKAction.colorize(with: UIColor(red: 102/255, green: 205/255, blue: 212/255, alpha: 1), colorBlendFactor: 1.0, duration: 0.3)
            
            background1.run(colorize)
            
            currentLevel = 3
            
            if level3TutorialNeeded {
                
                darkener.run(SKAction.fadeOut(withDuration: 0.3))
                instructionsText2.run(SKAction.fadeOut(withDuration: 0.3))
                instructionsText1.run(SKAction.fadeOut(withDuration: 0.3))
                instructionsText3.run(SKAction.fadeOut(withDuration: 0.3))
                swipeCircle.removeAllActions()
                swipeCircle.run(SKAction.fadeOut(withDuration: 0.3))
                
                level3TutorialNeeded = false
                
            }
            
            if dailyBestAchievedDawn {
                dailyBestLabel.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
            } else if dailyBestAchievedNight {
                dailyBestLabel.run(SKAction.fadeOut(withDuration: 0.3))

            }
            
            if backgroundMusicPlayer3 == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "DawnMusic", withExtension: "m4a")
                backgroundMusicPlayer3 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer3!.numberOfLoops = -1
            }
            if backgroundMusicPlayer3!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer3!.play()
                backgroundMusicPlayer3!.volume = 0
            }
            
            let fader2 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            let fader3 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer3!)
            
            fader3.fadeIn(0.3, velocity: 2)
            fader2.fadeOut(0.3, velocity: 2) {finished in
                backgroundMusicPlayer2?.pause()
                self.transitioningLevels = false
            }
            
            player2.run(SKAction.fadeOut(withDuration: 0.3))
            player3.run(SKAction.fadeIn(withDuration: 0.3))
            
            if trail3 == nil {
                trail3 = SKEmitterNode(fileNamed: "Trail3.sks")
                trail3?.zPosition = 0
                trail3?.targetNode = self
                trail3?.isHidden = true
            
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    trail3?.particleScale = 0.6
                default:
                    break
                }
                player.addChild(trail3!)
            } else {
                trail3.particleBirthRate = 60
            }
            
            trail2.particleBirthRate = 0
            
            bestLabel.text = "\(highScoreDawn)"
            scoreLabel.text = "\(lastDawn)"
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            
            scoreMarker2.run(fadeOut)
            bestMarker2.run(fadeOut)
            
            scoreMarker3.run(fadeIn)
            bestMarker3.run(fadeIn)

            
            shopButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rateButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leaderboardButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            settingsButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            removeAdsButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leftArrow3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rightArrow3.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
            giftButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            shareButtonCircle3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            likeButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))

            
            shopButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rateButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leaderboardButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            settingsButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            removeAdsButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leftArrow2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rightArrow2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            giftButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            shareButtonCircle2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            likeButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))


            
        } else if currentLevel == 2 && !dawnUnlocked && !transitioningLevels {
            //MARK: GO FROM LEVEL 2 TO LEVEL 3, WHICH IS LOCKED
            
            transitioningLevels = true
            levelText.text = "LEVEL 3: DAWN"
            currentLevel = 3
            
            let moveGradient = SKAction.moveBy(x: -self.size.width, y: 0, duration: 0.33)
            moveGradient.timingMode = .easeOut

            gradient.run(moveGradient)
            nightGradient.run(moveGradient)
            dawnGradient.run(moveGradient)
            
            
            let colorize = SKAction.colorize(with: UIColor(red: 102/255, green: 205/255, blue: 212/255, alpha: 1), colorBlendFactor: 1.0, duration: 0.3)
            
            background1.run(colorize)
            
            if dailyBestAchievedNight {
                dailyBestLabel.run(SKAction.fadeOut(withDuration: 0.3))
            }
            
            if backgroundMusicPlayer3 == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "DawnMusic", withExtension: "m4a")
                backgroundMusicPlayer3 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer3!.numberOfLoops = -1
            }
            if backgroundMusicPlayer3!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer3!.play()
                backgroundMusicPlayer3!.volume = 0
            }
            
            let fader2 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            let fader3 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer3!)
            
            fader3.fadeIn(0.3, velocity: 2)
            fader2.fadeOut(0.3, velocity: 2) {finished in
                backgroundMusicPlayer2?.pause()
                self.transitioningLevels = false
            }
            
            player2.run(SKAction.fadeOut(withDuration: 0.3))
            player3.run(SKAction.fadeIn(withDuration: 0.3))
            
            if trail3 == nil {
                trail3 = SKEmitterNode(fileNamed: "Trail3.sks")
                trail3?.zPosition = 0
                trail3?.targetNode = self
                trail3?.isHidden = true
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    trail3?.particleScale = 0.6
                default:
                    break
                }
                player.addChild(trail3!)
            } else {
                trail3.particleBirthRate = 60
            }
            
            trail2.particleBirthRate = 0
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            
            scoreMarker2.run(fadeOut)
            bestMarker2.run(fadeOut)
            
            scoreMarker3.run(fadeIn)
            bestMarker3.run(fadeIn)
            
            if nightUnlocked {
            lock = SKSpriteNode(imageNamed: "lock")
            lock.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.39)
            lock.alpha = 0
                lock.zPosition = 15

            lock.color = UIColor(red: 192/255, green: 108/255, blue: 132/255, alpha: 1)
            lock.colorBlendFactor = 0
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                lock.setScale(0.55)
            default:
                lock.setScale(0.9)
            }
            self.addChild(lock)
            lock.run(SKAction.fadeIn(withDuration: 0.4))
            
            lockedText1 = text("Reach 100 on level 2", fontSize: self.size.width/24, fontName: "Roboto-Light", fontColor: SKColor.white)
            lockedText1.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
            lockedText1.alpha = 0.0
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                lockedText1.fontSize = self.size.width/33
            default:
                break
            }
            self.addChild(lockedText1)
            lockedText1.run(SKAction.fadeIn(withDuration: 0.3))
            
            
            lockedText2 = text("to unlock level 3.", fontSize: self.size.width/24, fontName: "Roboto-Light", fontColor: SKColor.white)
            lockedText2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.27)
            lockedText2.alpha = 0.0
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                lockedText2.fontSize = self.size.width/33
            default:
                break
            }
            self.addChild(lockedText2)
            lockedText2.run(SKAction.fadeIn(withDuration: 0.3))
                
                unlockDawnButton.run(SKAction.fadeIn(withDuration: 0.2))
                priceDisplay.run(SKAction.fadeIn(withDuration: 0.2))


            } else {
                unlockNightButton.run(SKAction.fadeOut(withDuration: 0.2))
                priceDisplay.run(SKAction.fadeOut(withDuration: 0.2))
                lockedText1.text = "Reach 100 on level 2"
                lockedText2.text = "to unlock level 3."
            }
            
            touchToStart.removeFromParent()
            bestLabel.text = "\(highScoreDawn)"
            scoreLabel.text = "\(lastDawn)"
            
            shopButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rateButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leaderboardButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            settingsButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            removeAdsButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leftArrow3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rightArrow3.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
            giftButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            shareButtonCircle3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            likeButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))


            
            shopButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rateButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leaderboardButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            settingsButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            removeAdsButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leftArrow2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rightArrow2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            giftButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            shareButtonCircle2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            likeButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))

        }
        
    }
    }
    //MARK: SWIPE LEFT
    func swipeLeft() -> Void {
        if !gameStarted {
        print("move back to level 1 if we're on level 2")
        //MARK: GO FROM LEVEL 2 TO LEVEL 1
        if currentLevel == 2 && !transitioningLevels {
            
            transitioningLevels = true
            
            let moveGradient = SKAction.moveBy(x: self.size.width, y: 0, duration: 0.33)
            moveGradient.timingMode = .easeOut
            
            gradient.run(moveGradient)
            nightGradient.run(moveGradient)
            dawnGradient.run(moveGradient)
            
            let colorize = SKAction.colorize(with: UIColor(red: 248/255, green: 177/255, blue: 149/255, alpha: 1), colorBlendFactor: 1.0, duration: 0.3)
            
            background1.run(colorize)
            
            currentLevel = 1
            
            if dailyBestAchievedDusk {
                dailyBestLabel.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
            } else if dailyBestAchievedNight {
                dailyBestLabel.run(SKAction.fadeOut(withDuration: 0.3))
            }
            
            if backgroundMusicPlayer == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "DuskMusic2", withExtension: "m4a")
                backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer!.numberOfLoops = -1
            }
            if backgroundMusicPlayer!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer!.play()
                backgroundMusicPlayer!.volume = 0
            }
            
            let fader1 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            let fader2 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
            
            fader2.fadeIn(0.3, velocity: 2)
            fader1.fadeOut(0.3, velocity: 2) {finished in
                backgroundMusicPlayer2?.pause()
                self.transitioningLevels = false
            }
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            
            scoreMarker.run(fadeIn)
            bestMarker.run(fadeIn)
            
            scoreMarker2.run(fadeOut)
            bestMarker2.run(fadeOut)

            player2.run(SKAction.fadeOut(withDuration: 0.3))
            
            trail2.particleBirthRate = 0
            
            levelText.text = "LEVEL 1: DUSK"
            //bestText.text = "BEST: \(highScore)"
            bestLabel.text = "\(highScore)"
            scoreLabel.text = "\(lastDusk)"


            if !nightUnlocked {
                lock.run(SKAction.fadeOut(withDuration: 0.1))
                lockedText1.run(SKAction.fadeOut(withDuration: 0.1))
                lockedText2.run(SKAction.fadeOut(withDuration: 0.1))
                self.addChild(touchToStart)
                
                unlockNightButton.run(SKAction.fadeOut(withDuration: 0.2))
                priceDisplay.run(SKAction.fadeOut(withDuration: 0.2))
            }

            
            shopButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rateButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leaderboardButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            settingsButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            removeAdsButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leftArrow2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rightArrow2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            shareButtonCircle2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            giftButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            likeButton2.run(SKAction.fadeAlpha(to: 0, duration: 0.3))

            
            shopButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rateButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leaderboardButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            settingsButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            removeAdsButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leftArrow.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
            rightArrow.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            shareButtonCircle.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            giftButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            likeButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))



        } else if currentLevel == 3 && nightUnlocked && !transitioningLevels {
            //MARK: GO FROM LEVEL 3 TO LEVEL 2, WHICH IS UNLOCKED
            transitioningLevels = true
            
            let moveGradient = SKAction.moveBy(x: self.size.width, y: 0, duration: 0.33)
            moveGradient.timingMode = .easeOut
            
            gradient.run(moveGradient)
            nightGradient.run(moveGradient)
            dawnGradient.run(moveGradient)
            
            let colorize = SKAction.colorize(with: UIColor(red: 59/255, green: 92/255, blue: 125/255, alpha: 1), colorBlendFactor: 1.0, duration: 0.3)
            
            background1.run(colorize)
            
            currentLevel = 2
            
            if dailyBestAchievedNight {
                dailyBestLabel.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
            } else if dailyBestAchievedDawn {
                dailyBestLabel.run(SKAction.fadeOut(withDuration: 0.3))
            }
            
            if backgroundMusicPlayer2 == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "NightMusic", withExtension: "m4a")
                backgroundMusicPlayer2 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer2!.numberOfLoops = -1
            }
            if backgroundMusicPlayer2!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer2!.play()
                backgroundMusicPlayer2!.volume = 0
            }
            
            let fader2 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            let fader3 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer3!)
            
            fader2.fadeIn(0.3, velocity: 2)
            fader3.fadeOut(0.3, velocity: 2) {finished in
                backgroundMusicPlayer3?.pause()
                self.transitioningLevels = false
            }
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            
            scoreMarker2.run(fadeIn)
            bestMarker2.run(fadeIn)

            
            scoreMarker3.run(fadeOut)
            bestMarker3.run(fadeOut)
            
            player3.run(SKAction.fadeOut(withDuration: 0.3))
            player2.run(SKAction.fadeIn(withDuration: 0.3))
            
            if trail2 == nil {
  
                trail2 = SKEmitterNode(fileNamed: "Trail2.sks")
                trail2?.zPosition = 0
                trail2?.targetNode = self
                trail2?.isHidden = true
 

                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    trail2?.particleScale = 0.6
                default:
                    break
                }
                player.addChild(trail2!)
            } else {
                trail2.particleBirthRate = 60
            }
            
            trail3.particleBirthRate = 0
            
            
            
            levelText.text = "LEVEL 2: NIGHT"
            bestLabel.text = "\(highScoreNight)"
            scoreLabel.text = "\(lastNight)"

            if !dawnUnlocked {
                lock.run(SKAction.fadeOut(withDuration: 0.1))
                lockedText1.run(SKAction.fadeOut(withDuration: 0.1))
                lockedText2.run(SKAction.fadeOut(withDuration: 0.1))
                self.addChild(touchToStart)
                
                unlockDawnButton.run(SKAction.fadeOut(withDuration: 0.2))
                priceDisplay.run(SKAction.fadeOut(withDuration: 0.2))

            }
            
            shopButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rateButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leaderboardButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            settingsButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            removeAdsButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leftArrow3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rightArrow3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            shareButtonCircle3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            giftButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            likeButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))

            
            shopButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rateButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leaderboardButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            settingsButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            removeAdsButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leftArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rightArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            shareButtonCircle2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            giftButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            likeButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))


            
        } else if currentLevel == 3 && !nightUnlocked && !transitioningLevels {
            //MARK: GO FROM LEVEL 3 TO 2, WHICH IS LOCKED
            transitioningLevels = true
            
            let moveGradient = SKAction.moveBy(x: self.size.width, y: 0, duration: 0.33)
            moveGradient.timingMode = .easeOut
            
            gradient.run(moveGradient)
            nightGradient.run(moveGradient)
            dawnGradient.run(moveGradient)
            
            let colorize = SKAction.colorize(with: UIColor(red: 59/255, green: 92/255, blue: 125/255, alpha: 1), colorBlendFactor: 1.0, duration: 0.3)
            
            background1.run(colorize)
            
            currentLevel = 2
            
            if dailyBestAchievedNight {
                dailyBestLabel.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
            }
            
            if backgroundMusicPlayer2 == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "NightMusic", withExtension: "m4a")
                backgroundMusicPlayer2 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer2!.numberOfLoops = -1
            }
            if backgroundMusicPlayer2!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer2!.play()
                backgroundMusicPlayer2!.volume = 0
            }
            
            let fader2 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            let fader3 = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer3!)
            
            fader2.fadeIn(0.3, velocity: 2)
            fader3.fadeOut(0.3, velocity: 2) {finished in
                backgroundMusicPlayer3?.pause()
                self.transitioningLevels = false
            }
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            
            scoreMarker2.run(fadeIn)
            bestMarker2.run(fadeIn)

            scoreMarker3.run(fadeOut)
            bestMarker3.run(fadeOut)
            

            player3.run(SKAction.fadeOut(withDuration: 0.3))
            player2.run(SKAction.fadeIn(withDuration: 0.3))
            
            if trail2 == nil {
                trail2 = SKEmitterNode(fileNamed: "Trail2.sks")
                trail2?.zPosition = 0
                trail2?.targetNode = self
                trail2?.isHidden = true
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    trail2?.particleScale = 0.6
                default:
                    break
                }
                player.addChild(trail2!)
            } else {
                trail2.particleBirthRate = 60
            }
            
            trail3.particleBirthRate = 0
            
            unlockNightButton.run(SKAction.fadeIn(withDuration: 0.2))
            priceDisplay.run(SKAction.fadeIn(withDuration: 0.2))

            
            levelText.text = "LEVEL 2: NIGHT"
            bestLabel.text = "\(highScoreNight)"
            scoreLabel.text = "\(lastNight)"
            
            lockedText1.text = "Reach 100 on level 1"
            lockedText2.text = "to unlock level 2."
            
            shopButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rateButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leaderboardButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            settingsButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            removeAdsButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            leftArrow3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            rightArrow3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            shareButtonCircle3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            giftButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))
            likeButton3.run(SKAction.fadeAlpha(to: 0, duration: 0.3))

            
            shopButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rateButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leaderboardButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            settingsButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            removeAdsButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            leftArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            rightArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            shareButtonCircle2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            giftButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
            likeButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))



        }
    }
    }
    
    
    
    func swipedRight(_ sender: UISwipeGestureRecognizer) {
        print("swipe right detected")
        if !gameStarted {
            swipeLeft()
            didSwipe = true
        }
    }
    
    func swipedLeft(_ sender: UISwipeGestureRecognizer) {
        print("swiped left detected")
        if !gameStarted {
            swipeRight()
            didSwipe = true
        }
    }
    
    func pauseWhenComeBack() {
        if !dead && gameStarted {
            gamePaused = true
            world.isPaused = true
            gradient.isPaused = true
            dawnGradient.isPaused = true
            nightGradient.isPaused = true
            
            darkener.run(SKAction.fadeAlpha(to: 0.8, duration: 0.25))
            homeButton.run(SKAction.fadeIn(withDuration: 0.3))
            homeButton.isUserInteractionEnabled = true
            playButton.run(SKAction.fadeIn(withDuration: 0.3))
            playButton.isUserInteractionEnabled = true
            pauseButton.run(SKAction.fadeOut(withDuration: 0.3))
            pauseButton.isUserInteractionEnabled = false        }
    }
    
    func pauseGame() {
        
        print("pause")
        print("dead is \(dead)")
        print("game started is \(gameStarted)")
        print("paused is \(gamePaused)")
        if !dead && gameStarted && !gamePaused {
            gamePaused = true
            world.isPaused = true
            gradient.isPaused = true
            dawnGradient.isPaused = true
            nightGradient.isPaused = true
            
            darkener.run(SKAction.fadeAlpha(to: 0.8, duration: 0.25))
            homeButton.run(SKAction.fadeIn(withDuration: 0.3))
            homeButton.isUserInteractionEnabled = true
            playButton.run(SKAction.fadeIn(withDuration: 0.3))
            playButton.isUserInteractionEnabled = true
            pauseButton.run(SKAction.fadeOut(withDuration: 0.3))
            pauseButton.isUserInteractionEnabled = false
        }
        
    }
    
    
    
    func unpause() {
        
        gamePaused = false
        
        let unpause = SKAction.run({
            self.world.isPaused = false
            self.gradient.isPaused = false
            self.dawnGradient.isPaused = false
            self.nightGradient.isPaused = false
        })
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        
        darkener.run(SKAction.sequence([fadeOut,unpause]))
        homeButton.run(fadeOut)
        homeButton.isUserInteractionEnabled = false
        playButton.run(fadeOut)
        playButton.isUserInteractionEnabled = false
        pauseButton.run(SKAction.fadeIn(withDuration: 0.3))
        pauseButton.isUserInteractionEnabled = true
    }
    
    func checkForPause() {
        print("check for pause")
        print("gamePaused is \(gamePaused)")
        if gamePaused && gameStarted {
            print("pause the game here")
            let thePause = SKAction.run({
            self.pauseWhenComeBack()
            })
            let wait = SKAction.wait(forDuration: 0.0001)
            
            self.run(SKAction.sequence([wait, thePause]))
        }
        
        if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint {
            musicSilenced = true
            print("music just started playing")
            //pause music
            if currentLevel == 1 && (backgroundMusicPlayer?.isPlaying)! {
                backgroundMusicPlayer?.pause()
            } else if currentLevel == 2 && (backgroundMusicPlayer2?.isPlaying)! {
                backgroundMusicPlayer2?.pause()
            } else if currentLevel == 3 && (backgroundMusicPlayer3?.isPlaying)! {
                backgroundMusicPlayer3?.pause()
            }
        } else {
            //play music
            musicSilenced = false
            print("music just stopped playing")
            if currentLevel == 1 && !(backgroundMusicPlayer?.isPlaying)! && volumeOn {
                backgroundMusicPlayer?.play()
            } else if currentLevel == 2 && !(backgroundMusicPlayer2?.isPlaying)! && volumeOn {
                backgroundMusicPlayer2?.play()
            } else if currentLevel == 3 && !(backgroundMusicPlayer3?.isPlaying)! && volumeOn {
                backgroundMusicPlayer3?.play()
            }
        }

    }
    
    func reloadTimer() {
        
        
        let currentDate = Date()

        if !giftAvailable {
            timeCount = giftDate.timeIntervalSince(currentDate)
            print("reload timer")
        }
        
        if !hasDayPassed {
        switch currentDate.compare(dailyBestDate as Date) {
        case .orderedAscending:
            break
        case .orderedDescending:
            
            hasDayPassed = true
            

            let bigger = SKAction.scale(by: 1.2, duration: 0.3)
            bigger.timingMode = .easeInEaseOut
            
            let rotateLeft1 = SKAction.rotate(byAngle: CGFloat(-(M_PI/24)), duration: 0.05)
            let rotateRight = SKAction.rotate(byAngle: CGFloat(M_PI/12), duration: 0.1)
            let rotateLeft = SKAction.rotate(byAngle: CGFloat(-(M_PI/12)), duration: 0.1)
            
            let shake = SKAction.sequence([rotateLeft1, rotateRight, rotateLeft, rotateRight, rotateLeft1])
            let wait = SKAction.wait(forDuration: 1)
            
            let grow = SKAction.group([bigger, shake])
            
            let smaller = SKAction.scale(by: 1/1.2, duration: 0.5)
            smaller.timingMode = .easeInEaseOut
            
            let pulse = SKAction.repeatForever(SKAction.sequence([grow, wait, smaller]))
                
            giftButton.run(pulse, withKey: "pulse")
            giftButton2.run(pulse, withKey: "pulse")
            giftButton3.run(pulse, withKey: "pulse")

            resetDay()
            
        case .orderedSame:
            break
            }
        }
 
    }
    
    func playPauseMusic() {
        if AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint {
            musicSilenced = true
            print("music just started playing")
            //pause music
            if currentLevel == 1 && (backgroundMusicPlayer?.isPlaying)! {
                backgroundMusicPlayer?.pause()
            } else if currentLevel == 2 && (backgroundMusicPlayer2?.isPlaying)! {
                backgroundMusicPlayer2?.pause()
            } else if currentLevel == 3 && (backgroundMusicPlayer3?.isPlaying)! {
                backgroundMusicPlayer3?.pause()
            }
        } else {
            //play music
            musicSilenced = false
            print("music just stopped playing")
            if currentLevel == 1 && !(backgroundMusicPlayer?.isPlaying)! && volumeOn {
                backgroundMusicPlayer?.play()
            } else if currentLevel == 2 && !(backgroundMusicPlayer2?.isPlaying)! && volumeOn {
                backgroundMusicPlayer2?.play()
            } else if currentLevel == 3 && !(backgroundMusicPlayer3?.isPlaying)! && volumeOn {
                backgroundMusicPlayer3?.play()
            }
        }
    }
    
    //MARK: PRESENT NEW SCENE
    func newScene(_ scene: String) {
        let skView = self.view! as SKView
        view!.removeGestureRecognizer(leftSwipe)
        view!.removeGestureRecognizer(rightSwipe)
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        
        timer.invalidate()
        
        let getRidOfUIFast = SKAction.fadeOut(withDuration: 0.3)
        
        title.run(getRidOfUIFast)
        touchToStart.run(getRidOfUIFast)
        shopButton.run(getRidOfUIFast)
        settingsButton.run(getRidOfUIFast)
        leaderboardButton.run(getRidOfUIFast)
        removeAdsButton.run(getRidOfUIFast)
        rateButton.run(getRidOfUIFast)
        player.run(getRidOfUIFast)
        trail!.run(getRidOfUIFast)
        levelText.run(getRidOfUIFast)
        leftArrow.run(getRidOfUIFast)
        rightArrow.run(getRidOfUIFast)
        scoreLabel.run(getRidOfUIFast)
        scoreMarker.run(getRidOfUIFast)
        bestMarker.run(getRidOfUIFast)
        bestLabel.run(getRidOfUIFast)
        likeButton.run(getRidOfUIFast)
        shareButtonCircle.run(getRidOfUIFast)
        giftButton.run(getRidOfUIFast)

        
        if didCollectGift {
            newCoinsDisplay.run(getRidOfUIFast)
            newCoinsIcon.run(getRidOfUIFast)
            didCollectGift = false
        }
        
        if dailyBestAchievedDusk || dailyBestAchievedDawn || dailyBestAchievedNight {
            dailyBestLabel.run(getRidOfUIFast)
        }
        
        if !nightUnlocked {
            print("remove unlock night button")
            unlockNightButton.run(getRidOfUIFast)
        }
        if !dawnUnlocked && nightUnlocked {
            unlockDawnButton.run(getRidOfUIFast)
        }
        
        shopButton2.run(getRidOfUIFast)
        settingsButton2.run(getRidOfUIFast)
        leaderboardButton2.run(getRidOfUIFast)
        removeAdsButton2.run(getRidOfUIFast)
        rateButton2.run(getRidOfUIFast)
        leftArrow2.run(getRidOfUIFast)
        rightArrow2.run(getRidOfUIFast)
        likeButton2.run(getRidOfUIFast)
        shareButtonCircle2.run(getRidOfUIFast)
        giftButton2.run(getRidOfUIFast)
        bestMarker2.run(getRidOfUIFast)
        scoreMarker2.run(getRidOfUIFast)

        shopButton3.run(getRidOfUIFast)
        settingsButton3.run(getRidOfUIFast)
        leaderboardButton3.run(getRidOfUIFast)
        removeAdsButton3.run(getRidOfUIFast)
        rateButton3.run(getRidOfUIFast)
        leftArrow3.run(getRidOfUIFast)
        rightArrow3.run(getRidOfUIFast)
        likeButton3.run(getRidOfUIFast)
        shareButtonCircle3.run(getRidOfUIFast)
        giftButton3.run(getRidOfUIFast)
        bestMarker3.run(getRidOfUIFast)
        scoreMarker3.run(getRidOfUIFast)
        
        priceDisplay.run(getRidOfUIFast)
        
        if (currentLevel == 2 && !nightUnlocked) || (currentLevel == 3 && !dawnUnlocked) {
            print("remove lock")
            lock.run(SKAction.fadeOut(withDuration: 0.1))
            lockedText1.run(getRidOfUIFast)
            lockedText2.run(getRidOfUIFast)
            
        }
        print(guideCircle.parent != nil)
        if scene == "settings" {
            let scene = SettingsScene(size: view!.bounds.size)
            scene.scaleMode = .aspectFill
            
            let present = SKAction.run( {skView.presentScene(scene)} )
            guideCircle.run(SKAction.sequence([getRidOfUIFast, present]))
        } else if scene == "shop" {
            let scene = ShopScene(size: view!.bounds.size)
            scene.scaleMode = .aspectFill
            print("here")
            let present = SKAction.run( {skView.presentScene(scene)} )
            guideCircle.run(SKAction.sequence([getRidOfUIFast, present]))
        } else if scene == "dailyChallenge" {
            print("here 1")
            let scene = DailyChallengeScene(size: view!.bounds.size)
            scene.scaleMode = .aspectFill
            let present = SKAction.run( {skView.presentScene(scene)} )
            guideCircle.run(SKAction.sequence([getRidOfUIFast, present]))
        }
        
        
    }
    
    
    func goToDailyChallenge() -> Void {
        
        newScene("dailyChallenge")
        
    }
    
    func unlockDawn() -> Void {
        if iapAvailable {
            for product in list {
                let productId = product.productIdentifier
                if productId == "com.quantumcat.dusk.unlockDawn" {
                    p = product
                    buyProduct()
                }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "In-app purchase not loaded. Try again later.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                (alert: UIAlertAction!) in
            }))
            self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }

    
    //MARK: ---------------------------------------------------------------------------------
    //MARK: DID MOVE TO VIEW
    override func didMove(to view: SKView) {
        
        //MARK: IAPS
        if SKPaymentQueue.canMakePayments() {
            let productId: NSSet = NSSet(objects: "com.quantumcat.dusk.removeAds", "com.quantumcat.dusk.unlockNight", "com.quantumcat.dusk.unlockDawn")
            var request: SKProductsRequest = SKProductsRequest(productIdentifiers: productId as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("iap is disabled, please enable")
        }
        
        
        
        //gems += 2000
        //nightUnlocked = true
        //dawnUnlocked = true
        //giftAvailable = true
        //swipeTutorialNeeded = true
        //highScore = 2
        //tutorialNeeded = false
        //dailyChallengeCurrent = 91
        
        
        var lockedCharacters = allCharacters
        for char in lockedCharacters {
            for unlocked in unlockedCharacters {
                if char == unlocked {
                    lockedCharacters.remove(at: lockedCharacters.index(of: char)!)
                }
            }
        }
        
        cheapestItem = 5000
        for char in lockedCharacters {
            if char == "face" {
                cheapestItem = 0
                break
            } else if char == "clock" || char == "angry" || char == "peace" || char == "sun" {
                cheapestItem = 1000
                break
            } else if char == "baseball" || char == "basketball" || char == "yingYang" || char == "eye" || char == "disco" {
                cheapestItem = 3000
                break
            }
        }

        
        
        //MARK: NOTIFICATION LISTENING
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTimer), name: NSNotification.Name.UIApplicationWillEnterForeground, object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playPauseMusic), name: NSNotification.Name.AVAudioSessionSilenceSecondaryAudioHint, object: AVAudioSession.sharedInstance())
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkForPause), name: NSNotification.Name.UIApplicationDidBecomeActive, object: UIApplication.shared)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name.UIApplicationWillResignActive, object: UIApplication.shared)
        
        //MARK: PHYSICS WORLD
        world = SKNode()
        self.addChild(world)
        
        physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            segmentHeight = iPadScale * segmentHeight
            segmentWidth = iPadScale * segmentWidth
        default: break
        }
        
        
        //FONTS: DolceVitaLight, DolceVita, Roboto-Regular, Roboto-Thin, Roboto-Light, Roboto-Bold
        
        
        //MARK: BACKGROUND
        //print(self.size.height)
        //print(self.size.width)
        
        if currentLevel == 1 {
            background1 = SKSpriteNode(color: UIColor(red: 248/255, green: 177/255, blue: 149/255, alpha: 1), size: self.size)
        } else if currentLevel == 2 {
            background1 = SKSpriteNode(color: UIColor(red: 59/255, green: 92/255, blue: 125/255, alpha: 1), size: self.size)
        } else if currentLevel == 3 {
            background1 = SKSpriteNode(color: UIColor(red: 102/255, green: 205/255, blue: 212/255, alpha: 1), size: self.size)
        }
        else {
            background1 = SKSpriteNode(color: UIColor(red: 248/255, green: 177/255, blue: 149/255, alpha: 1), size: self.size)
        }
        background1.zPosition = -1000
        background1.anchorPoint = CGPoint(x: 0, y: 0)
        background1.position = CGPoint.zero
        self.addChild(background1)
        
        gradient = SKSpriteNode(imageNamed: "duskGradient")
        gradient.size = self.size
        gradient.anchorPoint = CGPoint(x: 0.5, y: 0)
        if currentLevel == 1 {
            gradient.position = CGPoint(x: self.size.width/2, y: 0)
        } else if currentLevel == 2 {
            gradient.position = CGPoint(x: -(self.size.width/2), y: 0)
        } else if currentLevel == 3 {
            gradient.position = CGPoint(x: -(self.size.width * 1.5), y: 0)
        }
        gradient.zPosition = -100
        self.addChild(gradient)
        
        nightGradient = SKSpriteNode(imageNamed: "nightGradient")
        nightGradient.size = self.size
        nightGradient.anchorPoint = CGPoint(x: 0.5, y: 0)
        if currentLevel == 1 {
            nightGradient.position = CGPoint(x: self.size.width * 1.5, y: 0)
        } else if currentLevel == 2 {
            nightGradient.position = CGPoint(x: self.size.width/2, y: 0)
        } else if currentLevel == 3 {
            nightGradient.position = CGPoint(x: -(self.size.width/2), y: 0)
        }
        nightGradient.zPosition = -100
        self.addChild(nightGradient)
        
        dawnGradient = SKSpriteNode(imageNamed: "dawnGradient")
        dawnGradient.size = self.size
        dawnGradient.anchorPoint = CGPoint(x: 0.5, y: 0)
        if currentLevel == 1 {
            dawnGradient.position = CGPoint(x: self.size.width * 2.5, y: 0)
        } else if currentLevel == 2 {
            dawnGradient.position = CGPoint(x: self.size.width * 1.5, y: 0)
        } else if currentLevel == 3 {
            dawnGradient.position = CGPoint(x: self.size.width/2, y: 0)
        }
        dawnGradient.zPosition = -100
        self.addChild(dawnGradient)
        
        darkener = SKSpriteNode(color: SKColor.black, size: self.size)
        darkener.zPosition = 19
        darkener.alpha = 0
        darkener.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(darkener)
        
        
        //MARK: POINT/LENGTHS BASED ON SCREEN SIZE
        center = CGPoint(x: self.size.width/2, y: self.size.height * 0.33)
        radius = 82.5
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            radius = 123.75
            speedRotate = 125 * (123.75/82.5)
        default:
            break
        }
        
        setupAudio()
        
        //MARK: TITLE AND TAP TO START
        title = SKLabelNode(text: "DUSK")
        title.fontName = "DolceVitaLight"
        title.fontSize = self.size.width/5
        title.fontColor = SKColor.white
        title.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.85)
        if !justLaunched {
            title.alpha = 0
        } else {
            title.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.8)
        }
        self.addChild(title)
        
        let titleDown = SKAction.moveTo(y: self.size.height * 0.8, duration: 2.2)
        titleDown.timingMode = .easeOut
        
        if !justLaunched {
            title.run(SKAction.fadeAlpha(to: 1.0, duration: 2))
            title.run(titleDown)
        } else {
            justLaunched = false
        }

        
        touchToStart = SKLabelNode(text: "Tap to Start")
        touchToStart.fontColor = SKColor.white
        touchToStart.verticalAlignmentMode = .center
        touchToStart.fontSize = self.size.width/20
        touchToStart.fontName = "Roboto-Light"
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            touchToStart.fontSize = self.size.width/25
        default:
            break
        }
        touchToStart.position = CGPoint(x: self.size.width/2, y: center.y)
        if !(currentLevel == 2 && !nightUnlocked) && !(currentLevel == 3 && !dawnUnlocked) {
            self.addChild(touchToStart)
        }
        
        let fadeOut = SKAction.fadeAlpha(to: 0.1, duration: 0.8)
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.8)
        let wait = SKAction.wait(forDuration: 0.2)
        
        touchToStart.run(SKAction.repeatForever(SKAction.sequence([fadeOut, fadeIn, wait])))
        
    
        
        //MARK: SCORE
        scoreMarker = text("LAST", fontSize: self.size.width/16, fontName: "Roboto-Light", fontColor: labelColor)
        scoreMarker.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.73)
        scoreMarker.alpha = 0
        self.addChild(scoreMarker)
        if currentLevel == 1 {
            scoreMarker.run(fadeIn)
        }
        
        scoreMarker2 = text("LAST", fontSize: self.size.width/16, fontName: "Roboto-Light", fontColor: labelColor2)
        scoreMarker2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.73)
        scoreMarker2.alpha = 0
        self.addChild(scoreMarker2)
        if currentLevel == 2 {
            scoreMarker2.run(fadeIn)
        }
        
        scoreMarker3 = text("LAST", fontSize: self.size.width/16, fontName: "Roboto-Light", fontColor: labelColor3)
        scoreMarker3.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.73)
        scoreMarker3.alpha = 0
        self.addChild(scoreMarker3)
        if currentLevel == 3 {
            scoreMarker3.run(fadeIn)
        }
        
        var scoreLabelText: String
        
        switch currentLevel {
        case 1:
            scoreLabelText = "\(lastDusk)"
        case 2:
            scoreLabelText = "\(lastNight)"
        case 3:
            scoreLabelText = "\(lastDawn)"
        default:
            scoreLabelText = "\(lastDusk)"
        }

        scoreLabel = text(scoreLabelText, fontSize: self.size.width/6, fontName: "Roboto-Bold", fontColor: SKColor.white)
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.643)
        if justOpenedApp || lastScene == "settings" || lastScene == "shop" || lastScene == "dailyChallenge" {
            scoreLabel.alpha = 0
        }
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            scoreLabel.position.y = self.size.height * 0.62
        default:
            break
        }
        self.addChild(scoreLabel)
        scoreLabel.run(fadeIn)
        
        
        //MARK: HIGH SCORE
        
        bestMarker = text("BEST", fontSize: self.size.width/18, fontName: "Roboto-Light", fontColor: labelColor)
        bestMarker.position = CGPoint(x: self.size.width/4.5, y: self.size.height * 0.71)
        bestMarker.alpha = 0
        self.addChild(bestMarker)
        if currentLevel == 1 {
            bestMarker.run(fadeIn)
        }
        
        bestMarker2 = text("BEST", fontSize: self.size.width/18, fontName: "Roboto-Light", fontColor: labelColor2)
        bestMarker2.position = CGPoint(x: self.size.width/4.5, y: self.size.height * 0.71)
        bestMarker2.alpha = 0
        self.addChild(bestMarker2)
        if currentLevel == 2 {
            bestMarker2.run(fadeIn)
        }
        
        bestMarker3 = text("BEST", fontSize: self.size.width/18, fontName: "Roboto-Light", fontColor: labelColor3)
        bestMarker3.position = CGPoint(x: self.size.width/4.5, y: self.size.height * 0.71)
        bestMarker3.alpha = 0
        self.addChild(bestMarker3)
        if currentLevel == 3 {
            bestMarker3.run(fadeIn)
        }
        
        if currentLevel == 1 {
            bestLabel = text("\(highScore)", fontSize: self.size.width/8, fontName: "Roboto-Bold", fontColor: SKColor.white)
        } else if currentLevel == 2 {
            bestLabel = text("\(highScoreNight)", fontSize: self.size.width/8, fontName: "Roboto-Bold", fontColor: SKColor.white)
        } else if currentLevel == 3 {
            bestLabel = text("\(highScoreDawn)", fontSize: self.size.width/8, fontName: "Roboto-Bold", fontColor: SKColor.white)

        }
        
        bestLabel.position = CGPoint(x: self.size.width/4.5, y: self.size.height * 0.643)
        bestLabel.alpha = 0
        self.addChild(bestLabel)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            bestLabel.position.y = self.size.height * 0.62
        default:
            break
        }
        bestLabel.run(fadeIn)
        
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
        if lastScene == "game" {
            coinIcon.alpha = 0
        }
        self.addChild(coinIcon)
        coinIcon.run(fadeIn)
        
        coinDisplay = text("\(gems)", fontSize: self.size.width/12, fontName: "Roboto-Light", fontColor: SKColor.white)
        coinDisplay.horizontalAlignmentMode = .right
        coinDisplay.position = CGPoint(x: self.size.width * 0.9, y: self.size.height * 0.94)
        if lastScene == "game" {
            coinDisplay.alpha = 0
        }
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            coinDisplay.position.y = self.size.height * 0.94
            coinDisplay.fontSize = self.size.width/13
        default:
            break
        }
        coinDisplay.verticalAlignmentMode = .center
        self.addChild(coinDisplay)
        coinDisplay.run(fadeIn)
        
        /*if !justOpenedApp && lastScene == "game" {
            newCoinsIcon = SKSpriteNode(imageNamed: "coin")
            newCoinsIcon.position = CGPoint(x: self.size.width * 0.94, y: self.size.height * 0.89)
            switch UIDevice.currentDevice().userInterfaceIdiom {
            case .Pad:
                newCoinsIcon.setScale(0.6)
                newCoinsIcon.position.y = self.size.height * 0.89
            default:
                newCoinsIcon.setScale(0.35)
            }
            newCoinsIcon.alpha = 0
            self.addChild(newCoinsIcon)
            newCoinsIcon.runAction(SKAction.fadeAlphaTo(0.6, duration: 0.8))
            
            newCoinsDisplay = text("+\(score)", fontSize: self.size.width/15, fontName: "Roboto-Light", fontColor: SKColor.whiteColor())
            newCoinsDisplay.horizontalAlignmentMode = .Right
            newCoinsDisplay.position = CGPoint(x: self.size.width * 0.9, y: self.size.height * 0.89)
            newCoinsDisplay.alpha = 0
            switch UIDevice.currentDevice().userInterfaceIdiom {
            case .Pad:
                newCoinsDisplay.position.y = self.size.height * 0.89
                newCoinsDisplay.fontSize = self.size.width/17
            default:
                break
            }
            newCoinsDisplay.verticalAlignmentMode = .Center
            self.addChild(newCoinsDisplay)
            newCoinsDisplay.runAction(SKAction.fadeAlphaTo(0.6, duration: 0.8))
        }*/
        
        //MARK: PLAYER
        player = SKSpriteNode(imageNamed: "\(character)1")
        player.setScale(0.4)
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                player.setScale(0.6)
            default:
                player.setScale(0.4)
        }
        player.position = CGPoint(x: center.x, y: center.y + radius)
        player.zPosition = 17
        
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
        player.physicsBody?.categoryBitMask = 2
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.isDynamic = false
        player.physicsBody?.contactTestBitMask = 1
        

        player.alpha = 0.0
        
        world.addChild(player)
        
        player.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        
        player2 = SKSpriteNode(imageNamed: "\(character)2")
        player2.alpha = 0
        player2.zPosition = 1
        player.addChild(player2)
        if currentLevel == 2 {
            player2.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        }
        
        player3 = SKSpriteNode(imageNamed: "\(character)3")
        player3.alpha = 0
        player3.zPosition = 1
        player.addChild(player3)
        if currentLevel == 3 {
            player3.run(SKAction.fadeAlpha(to: 1.0, duration: 0.3))
        }
        
        
        
        //MARK: TRAIL
        
        trail = SKEmitterNode(fileNamed: "Trail1.sks")
        trail?.zPosition = -1
        trail?.targetNode = self
        trail?.alpha = 0.0
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            trail?.particleScale = 0.6
        default:
            break
        }
        player.addChild(trail!)
        trail!.run(SKAction.fadeAlpha(to: 0.1, duration: 0.3))
        
        if currentLevel == 2 {
            trail2 = SKEmitterNode(fileNamed: "Trail2.sks")
            trail2?.zPosition = 0
            trail2?.targetNode = self
            trail2?.isHidden = true
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                trail2?.particleScale = 0.6
            default:
                break
            }
            player.addChild(trail2!)
        }
        
        if currentLevel == 3 {
            trail3 = SKEmitterNode(fileNamed: "Trail3.sks")
            trail3?.zPosition = 0
            trail3?.targetNode = self
            trail3?.isHidden = true
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                trail3?.particleScale = 0.6
            default:
                break
            }
            player.addChild(trail3!)
        }
        
    
        //MARK: GUIDE CIRCLE
        guideCircle = SKSpriteNode(imageNamed: "guideCircle")
        guideCircle.size = CGSize(width: radius * 2, height: radius * 2)
        guideCircle.position = center
        guideCircle.zPosition = -1.0
        guideCircle.alpha = 0.0
        world.addChild(guideCircle)
        
        guideCircle.run(SKAction.fadeAlpha(to: 0.4, duration: 0.3))
        
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat((M_PI)/2.0), endAngle: CGFloat(((M_PI)/2.0) + (4 * M_PI)), clockwise: true)
        let moveRight = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: speedRotate)
        
        player.run(SKAction.repeatForever(moveRight.reversed()))
        
        //MARK: SCOREBOARD
        
        scoreBoard = SKLabelNode(text: "0")
        scoreBoard.fontColor = SKColor.white
        scoreBoard.fontSize = self.size.width/6
        scoreBoard.fontName = "Roboto-Bold" //Roboto-Regular, DolceVita, Roboto-Light
        scoreBoard.alpha = 0
        scoreBoard.verticalAlignmentMode = .bottom
        scoreBoard.position = CGPoint(x: self.size.width/2, y: self.size.height)
        scoreBoard.zPosition = 18
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            scoreBoard.setScale(0.6)
        default:
            scoreBoard.setScale(0.8)
        }
        world.addChild(scoreBoard)
        
        
        //MARK: CREATE SWIPE GESTURE RECOGNIZER
        rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedRight))
        rightSwipe.direction = .right
        rightSwipe.cancelsTouchesInView = false
        view.addGestureRecognizer(rightSwipe)
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipedLeft))
        leftSwipe.direction = .left
        leftSwipe.cancelsTouchesInView = false
        view.addGestureRecognizer(leftSwipe)
        
        //MARK: -----------------------------
        //MARK: BUTTON ACTIONS
        
        //MARK: COLLECT REWARD FROM DAILY CHALLENGE


        
        
        //MARK: SHARE
        func share() -> Void {
            if !swipeTutorialNeeded && !level3TutorialNeeded  {
                
                var textToShare: String
                
                switch currentLevel {
                case 1:
                    textToShare = "Wow! My high score in Dusk on level 1 is \(highScore)! #DuskGame"
                case 2:
                    textToShare = "Wow! My high score in Dusk on level 2 is \(highScoreNight)! #DuskGame"
                case 3:
                    textToShare = "Wow! My high score in Dusk on level 3 is \(highScoreDawn)! #DuskGame"
                default:
                    textToShare = "Wow! My high score in Dusk on level 1 is \(highScore)! #DuskGame"
                }
                
                let screenshot = SKAction.run({
                    
                UIGraphicsBeginImageContextWithOptions(CGSize(width: self.size.width, height: self.size.height), false, UIScreen.main.scale)
                self.view?.drawHierarchy(in: (self.view?.bounds)!, afterScreenUpdates: true)
                    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                UIGraphicsEndImageContext()
                    
                    if let website = URL(string: "https://itunes.apple.com/app/id1130135749") {
                        
                        //TODO: CHANGE LINK TO CORRECT LINK
                        
                        let objectsToShare = [textToShare, website, image] as [Any]
                        let shareSheetVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        shareSheetVC.excludedActivityTypes = [UIActivityType.addToReadingList, UIActivityType.assignToContact, UIActivityType.postToVimeo, UIActivityType.print]
                        if #available(iOS 9.0, *) {
                            shareSheetVC.excludedActivityTypes?.append(UIActivityType.openInIBooks)
                        }
                        
                        let currentViewController:UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                        switch UIDevice.current.userInterfaceIdiom {
                        case .phone:
                            currentViewController.present(shareSheetVC, animated: true, completion: nil)
                        case.pad:
                            shareSheetVC.modalPresentationStyle = UIModalPresentationStyle.popover
                            shareSheetVC.popoverPresentationController?.sourceView = self.view
                            shareSheetVC.popoverPresentationController?.sourceRect = CGRect(x: self.size.width/2, y: self.size.height, width: 0, height: 0)
                            
                            currentViewController.present(shareSheetVC, animated: true, completion: nil)
                        default:
                            currentViewController.present(shareSheetVC, animated: true, completion: nil)
                            
                        }
                        
                    }
                })
                
                let wait = SKAction.wait(forDuration: 0.1)
                self.run(SKAction.sequence([wait, screenshot]))
                
                
            }
        }
        
        //MARK: RATE
        func rate() -> Void {
            if !swipeTutorialNeeded && !level3TutorialNeeded {
                openStoreProductWithiTunesItemIdentifier("1130135749")
                
            }
        }
        
        func openStoreProductWithiTunesItemIdentifier(_ identifier: String) {
            let storeViewController = SKStoreProductViewController()
            storeViewController.delegate = self
            print("here")
            let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
            storeViewController.loadProduct(withParameters: parameters) { [weak self] (loaded, error) -> Void in
                if loaded {
                    // Parent class of self is UIViewContorller
                    let vc = self!.view?.window?.rootViewController
                    vc!.present(storeViewController, animated: true, completion: nil)
                }
            }
        }
        
        
        //MARK: LIKE
        func like() -> Void {
            if !swipeTutorialNeeded && !level3TutorialNeeded {
                let url1 = "fb://profile/503287153144438"
                let url2 = "https://www.facebook.com/ketchappgames"
                //UIApplication.tryURL([url1, url2])
                //TODO: OPEN FACEBOOK AT CORRECT URL
            }
        }
        
        
        //MARK: GO TO SETTINGS
        func goToSettings() -> Void {
            if !swipeTutorialNeeded && !level3TutorialNeeded {
                newScene("settings")
            }
        }
        
        //MARK: GO TO SHOP
        
        func goToShop() -> Void {
            if !swipeTutorialNeeded && !level3TutorialNeeded {
                newScene("shop")
            }
        }
        
        func leaderboard() -> Void {
            if !swipeTutorialNeeded && !level3TutorialNeeded {
                let vc = self.view?.window?.rootViewController
                let gc = GKGameCenterViewController()
                gc.gameCenterDelegate = self
                gc.viewState = .leaderboards
                vc?.present(gc, animated: true, completion: nil)
            }
        }
        
        //MARK: REMOVE ADS
        func removeAds() -> Void {
            if !swipeTutorialNeeded && !level3TutorialNeeded {
                print("remove ads button pressed")
                print("iap available is \(iapAvailable)")
                if iapAvailable {
                    for product in list {
                        let productId = product.productIdentifier
                        if productId == "com.quantumcat.dusk.removeAds" {
                            p = product
                            buyProduct()
                        }
                    }
                } else {
                    let alert = UIAlertController(title: "Error", message: "In-app purchase not loaded. Try again later.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                        (alert: UIAlertAction!) in
                    }))
                    self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }

            }
        }
        
        //MARK: UNLOCK LEVELS WITH IAP
        func unlockNight() -> Void {
            if iapAvailable {
                for product in list {
                    let productId = product.productIdentifier
                    if productId == "com.quantumcat.dusk.unlockNight" {
                        p = product
                        buyProduct()
                    }
                }
            } else {
                let alert = UIAlertController(title: "Error", message: "In-app purchase not loaded. Try again later.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    (alert: UIAlertAction!) in
                }))
                self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        
        
        let newRadius = radius + (self.size.height * 0.07)
        
        var buttonScale: CGFloat
        let buttonFade = SKAction.fadeAlpha(to: 0.9, duration: 0.3)
        
        //MARK: BUTTONS
        
        let bigger = SKAction.scale(by: 1.2, duration: 0.3)
        bigger.timingMode = .easeInEaseOut
        
        let rotateLeft1 = SKAction.rotate(byAngle: CGFloat(-(M_PI/24)), duration: 0.05)
        let rotateRight = SKAction.rotate(byAngle: CGFloat(M_PI/12), duration: 0.1)
        let rotateLeft = SKAction.rotate(byAngle: CGFloat(-(M_PI/12)), duration: 0.1)
        
        let shake = SKAction.sequence([rotateLeft1, rotateRight, rotateLeft, rotateRight, rotateLeft1])
        let wait2 = SKAction.wait(forDuration: 1)
        
        let grow = SKAction.group([bigger, shake])
        
        let smaller = SKAction.scale(by: 1/1.2, duration: 0.5)
        smaller.timingMode = .easeInEaseOut
        
        let pulse = SKAction.repeatForever(SKAction.sequence([grow, smaller, wait2]))
        
        //MARK: SHOP BUTTON
        shopButton = SKButton(buttonImage: "shopButton", buttonAction: goToShop)
        shopButton.position = CGPoint(x: self.size.width/2, y: center.y + newRadius)
        shopButton.zPosition = 10
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            buttonScale = 1.05
        default:
            buttonScale = 0.7
        }
        shopButton.setScale(buttonScale)
        shopButton.alpha = 0.0
        self.addChild(shopButton)
        if currentLevel == 1 {
            shopButton.run(buttonFade)
        }
        
        shopButton2 = SKButton(buttonImage: "shopButton2", buttonAction: goToShop)
        shopButton2.position = CGPoint(x: self.size.width/2, y: center.y + newRadius)
        shopButton2.zPosition = 11
        shopButton2.setScale(buttonScale)
        shopButton2.alpha = 0.0
        self.addChild(shopButton2)
        if currentLevel == 2 {
            shopButton2.run(buttonFade)
        }
        
        shopButton3 = SKButton(buttonImage: "shopButton3", buttonAction: goToShop)
        shopButton3.position = CGPoint(x: self.size.width/2, y: center.y + newRadius)
        shopButton3.zPosition = 12
        shopButton3.setScale(buttonScale)
        shopButton3.alpha = 0.0
        self.addChild(shopButton3)
        if currentLevel == 3 {
            shopButton3.run(buttonFade)
        }
        
        if gems >= cheapestItem {
            shopButton.run(pulse)
            shopButton2.run(pulse)
            shopButton3.run(pulse)

        }
        
        //MARK: RATE BUTTON
        
        rateButton = SKButton(buttonImage: "rateButton", buttonAction: rate)
        rateButton.position = CGPoint(x: center.x - (newRadius * CGFloat(sin(M_PI/6))), y: center.y + (newRadius * CGFloat(cos(M_PI/6))))
        rateButton.zPosition = 10
        rateButton.setScale(buttonScale)
        rateButton.alpha = 0.0
        self.addChild(rateButton)
        if currentLevel == 1 {
            rateButton.run(buttonFade)
        }
        
        rateButton2 = SKButton(buttonImage: "rateButton2", buttonAction: rate)
        rateButton2.position = CGPoint(x: center.x - (newRadius * CGFloat(sin(M_PI/6))), y: center.y + (newRadius * CGFloat(cos(M_PI/6))))
        rateButton2.zPosition = 11
        rateButton2.setScale(buttonScale)
        rateButton2.alpha = 0.0
        self.addChild(rateButton2)
        if currentLevel == 2 {
            rateButton2.run(buttonFade)
        }
        
        rateButton3 = SKButton(buttonImage: "rateButton3", buttonAction: rate)
        rateButton3.position = CGPoint(x: center.x - (newRadius * CGFloat(sin(M_PI/6))), y: center.y + (newRadius * CGFloat(cos(M_PI/6))))
        rateButton3.zPosition = 12
        rateButton3.setScale(buttonScale)
        rateButton3.alpha = 0.0
        self.addChild(rateButton3)
        if currentLevel == 3 {
            rateButton3.run(buttonFade)
        }
        
        //MARK: SETTINGS BUTTON
        
        settingsButton = SKButton(buttonImage: "settingsButton", buttonAction: goToSettings)
        settingsButton.position = CGPoint(x: center.x - (newRadius * CGFloat(sin(M_PI/3))), y: center.y + (newRadius * CGFloat(cos(M_PI/3))))
        settingsButton.zPosition = 10
        settingsButton.setScale(buttonScale)
        settingsButton.alpha = 0.0
        self.addChild(settingsButton)
        if currentLevel == 1 {
            settingsButton.run(buttonFade)
        }
        
        settingsButton2 = SKButton(buttonImage: "settingsButton2", buttonAction: goToSettings)
        settingsButton2.position = CGPoint(x: center.x - (newRadius * CGFloat(sin(M_PI/3))), y: center.y + (newRadius * CGFloat(cos(M_PI/3))))
        settingsButton2.zPosition = 11
        settingsButton2.setScale(buttonScale)
        settingsButton2.alpha = 0.0
        self.addChild(settingsButton2)
        if currentLevel == 2 {
            settingsButton2.run(buttonFade)
        }
        
        settingsButton3 = SKButton(buttonImage: "settingsButton3", buttonAction: goToSettings)
        settingsButton3.position = CGPoint(x: center.x - (newRadius * CGFloat(sin(M_PI/3))), y: center.y + (newRadius * CGFloat(cos(M_PI/3))))
        settingsButton3.zPosition = 12
        settingsButton3.setScale(buttonScale)
        settingsButton3.alpha = 0.0
        self.addChild(settingsButton3)
        if currentLevel == 3 {
            settingsButton3.run(buttonFade)
        }
        
        //MARK: LEADERBOARD BUTTON
        
        leaderboardButton = SKButton(buttonImage: "leaderboardButton", buttonAction: leaderboard)
        leaderboardButton.position = CGPoint(x: center.x + ((newRadius * CGFloat(sin(M_PI/6)))), y: center.y + (newRadius * CGFloat(cos(M_PI/6))))
        leaderboardButton.zPosition = 10
        leaderboardButton.setScale(buttonScale)
        leaderboardButton.alpha = 0.0
        self.addChild(leaderboardButton)
        if currentLevel == 1 {
            leaderboardButton.run(buttonFade)
        }
        
        leaderboardButton2 = SKButton(buttonImage: "leaderboardButton2", buttonAction: leaderboard)
        leaderboardButton2.position = CGPoint(x: center.x + ((newRadius * CGFloat(sin(M_PI/6)))), y: center.y + (newRadius * CGFloat(cos(M_PI/6))))
        leaderboardButton2.zPosition = 11
        leaderboardButton2.setScale(buttonScale)
        leaderboardButton2.alpha = 0.0
        self.addChild(leaderboardButton2)
        if currentLevel == 2 {
            leaderboardButton2.run(buttonFade)
        }
        
        leaderboardButton3 = SKButton(buttonImage: "leaderboardButton3", buttonAction: leaderboard)
        leaderboardButton3.position = CGPoint(x: center.x + ((newRadius * CGFloat(sin(M_PI/6)))), y: center.y + (newRadius * CGFloat(cos(M_PI/6))))
        leaderboardButton3.zPosition = 12
        leaderboardButton3.setScale(buttonScale)
        leaderboardButton3.alpha = 0.0
        self.addChild(leaderboardButton3)
        if currentLevel == 3 {
            leaderboardButton3.run(buttonFade)
        }
        
        var scale: CGFloat = 1.05
        
        //MARK: REMOVE ADS BUTTON
        
        removeAdsButton = SKButton(buttonImage: "removeAdsButton", buttonAction: removeAds)
        removeAdsButton.position = CGPoint(x: center.x + (newRadius * CGFloat(sin(M_PI/3))), y: center.y + (newRadius * CGFloat(cos(M_PI/3))))
        removeAdsButton.zPosition = 10
        removeAdsButton.setScale(buttonScale)
        removeAdsButton.alpha = 0.0
        self.addChild(removeAdsButton)
        if currentLevel == 1 {
            removeAdsButton.run(buttonFade)
        }

        removeAdsButton2 = SKButton(buttonImage: "removeAdsButton2", buttonAction: removeAds)
        removeAdsButton2.position = CGPoint(x: center.x + (newRadius * CGFloat(sin(M_PI/3))), y: center.y + (newRadius * CGFloat(cos(M_PI/3))))
        removeAdsButton2.zPosition = 11
        removeAdsButton2.setScale(buttonScale)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            scale = 1.1
        default:
            scale = 0.5
        }
        removeAdsButton2.alpha = 0.0
        self.addChild(removeAdsButton2)
        if currentLevel == 2 {
            removeAdsButton2.run(buttonFade)
        }
        
        removeAdsButton3 = SKButton(buttonImage: "removeAdsButton3", buttonAction: removeAds)
        removeAdsButton3.position = CGPoint(x: center.x + (newRadius * CGFloat(sin(M_PI/3))), y: center.y + (newRadius * CGFloat(cos(M_PI/3))))
        removeAdsButton3.zPosition = 12
        removeAdsButton3.setScale(buttonScale)
        removeAdsButton3.alpha = 0.0
        self.addChild(removeAdsButton3)
        if currentLevel == 3 {
            removeAdsButton3.run(buttonFade)
        }
        
        //MARK: LIKE BUTTON
        
        likeButton = SKButton(buttonImage: "likeButton", buttonAction: like)
        likeButton.position = CGPoint(x: center.x - newRadius, y: center.y)
        likeButton.alpha = 0
        likeButton.zPosition = 10
        likeButton.setScale(buttonScale)
        self.addChild(likeButton)
        if currentLevel == 1 {
            likeButton.run(buttonFade)
        }
        
        likeButton2 = SKButton(buttonImage: "likeButton2", buttonAction: like)
        likeButton2.position = CGPoint(x: center.x - newRadius, y: center.y)
        likeButton2.alpha = 0
        likeButton2.zPosition = 11
        likeButton2.setScale(buttonScale)
        self.addChild(likeButton2)
        if currentLevel == 2 {
            likeButton2.run(buttonFade)
        }
        
        likeButton3 = SKButton(buttonImage: "likeButton3", buttonAction: like)
        likeButton3.position = CGPoint(x: center.x - newRadius, y: center.y)
        likeButton3.alpha = 0
        likeButton3.zPosition = 12
        likeButton3.setScale(buttonScale)
        self.addChild(likeButton3)
        if currentLevel == 3 {
            likeButton3.run(buttonFade)
        }
        
        //MARK: SHARE BUTTON
        
        shareButtonCircle = SKButton(buttonImage: "shareButton", buttonAction: share)
        shareButtonCircle.position = CGPoint(x: center.x + newRadius, y: center.y)
        shareButtonCircle.alpha = 0
        shareButtonCircle.zPosition = 10
        shareButtonCircle.setScale(buttonScale)
        self.addChild(shareButtonCircle)
        if currentLevel == 1 {
            shareButtonCircle.run(buttonFade)
        }
        
        shareButtonCircle2 = SKButton(buttonImage: "shareButton2", buttonAction: share)
        shareButtonCircle2.position = CGPoint(x: center.x + newRadius, y: center.y)
        shareButtonCircle2.alpha = 0
        shareButtonCircle2.zPosition = 11
        shareButtonCircle2.setScale(buttonScale)
        self.addChild(shareButtonCircle2)
        if currentLevel == 2 {
            shareButtonCircle2.run(buttonFade)
        }
        
        shareButtonCircle3 = SKButton(buttonImage: "shareButton3", buttonAction: share)
        shareButtonCircle3.position = CGPoint(x: center.x + newRadius, y: center.y)
        shareButtonCircle3.alpha = 0
        shareButtonCircle3.zPosition = 12
        shareButtonCircle3.setScale(buttonScale)
        self.addChild(shareButtonCircle3)
        if currentLevel == 3 {
            shareButtonCircle3.run(buttonFade)
        }
        
        //MARK: PLAY, PAUSE, HOME BUTTON
        pauseButton = SKButton(buttonImage: "pauseButton\(currentLevel)", buttonAction: pauseGame)
        
        let pauseY = self.size.height * 0.88 + (scoreBoard.frame.size.height/2)
        
        pauseButton.position = CGPoint(x: self.size.width * 0.85, y: pauseY)
        pauseButton.zPosition = 18
        pauseButton.setScale(buttonScale)
        pauseButton.alpha = 0
        self.addChild(pauseButton)
        
        playButton = SKButton(buttonImage: "playButton\(currentLevel)", buttonAction: unpause)
        playButton.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.5)
        playButton.zPosition = 21
        playButton.setScale(0.8)
        playButton.isUserInteractionEnabled = false
        playButton.alpha = 0
        self.addChild(playButton)
        
        let bigger2 = SKAction.scale(by: 1.1, duration: 0.3)
        bigger2.timingMode = .easeInEaseOut
        let smaller2 = SKAction.scale(by: 1/1.1, duration: 0.5)
        smaller2.timingMode = .easeInEaseOut
        
        let pulse2 = SKAction.repeatForever(SKAction.sequence([bigger2, smaller2]))
        
        playButton.run(pulse2)
        
        
        homeButton = SKButton(buttonImage: "homeButton\(currentLevel)", buttonAction: returnToHome)
        homeButton.position = CGPoint(x: self.size.width * 0.15, y: pauseY)
        homeButton.zPosition = 21
        homeButton.setScale(buttonScale)
        homeButton.isUserInteractionEnabled = false
        homeButton.alpha = 0
        self.addChild(homeButton)
        
        
        var giftBtnImg: String
        var giftBtnAction: () -> Void
        switch giftAvailable {
        case true:
            giftBtnImg = "giftButton"
            giftBtnAction = gift
        case false:
            if dailyChallengeCompleted && !rewardAlreadyCollected {
                giftBtnImg = "challengeCompleteButton"
                giftBtnAction = goToDailyChallenge
            } else if dailyChallengeCompleted && rewardAlreadyCollected {
                giftBtnImg = "newChallengeTomorrowButton"
                giftBtnAction = goToDailyChallenge
            } else {
                giftBtnImg = "dailyChallengeButton"
                giftBtnAction = goToDailyChallenge
            }
            
        }
        
        //MARK: GIFT BUTTON ON TOP
        giftButton = SKButton(buttonImage: "\(giftBtnImg)1", buttonAction: giftBtnAction)
        //giftButton.button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        giftButton.position = CGPoint(x: self.size.width * (3.47/4.5), y: self.size.height * 0.643 + (giftButton.size.height/4))
        
        giftButton.setScale(scale * 1.2)
        giftButton.zPosition = 10
        giftButton.alpha = 0
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            giftButton.position.y = self.size.height * 0.62 + (giftButton.size.height * 1.2/2)
        default:
            break
        }
        self.addChild(giftButton)
        if currentLevel == 1 {
            giftButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.8))
        }
        
        giftButton2 = SKButton(buttonImage: "\(giftBtnImg)2", buttonAction: giftBtnAction)
        giftButton2.button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        giftButton2.position = CGPoint(x: self.size.width * (3.47/4.5), y: self.size.height * 0.643 + (giftButton.size.height/4))
        giftButton2.setScale(scale * 1.2)
        giftButton2.alpha = 0
        giftButton2.zPosition = 11
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            giftButton2.position.y = self.size.height * 0.62 + (giftButton.size.height * 1.2/2)
        default:
            break
        }
        self.addChild(giftButton2)
        if currentLevel == 2 {
            giftButton2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.8))
        }
        
        giftButton3 = SKButton(buttonImage: "\(giftBtnImg)3", buttonAction: giftBtnAction)
        giftButton3.button.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        giftButton3.position = CGPoint(x: self.size.width * (3.47/4.5), y: self.size.height * 0.643 + (giftButton.size.height/4))
        giftButton3.setScale(scale * 1.2)
        giftButton3.alpha = 0
        giftButton3.zPosition = 11
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            giftButton3.position.y = self.size.height * 0.62 + (giftButton.size.height * 1.2/2)
        default:
            break
        }
        self.addChild(giftButton3)
        if currentLevel == 3 {
            giftButton3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.8))
        }
        
        if !giftAvailable {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        
        if giftAvailable || (!rewardAlreadyCollected && dailyChallengeCompleted) || (!dailyChallengeCompleted && !hasSeenChallenge) {
            
            let bigger = SKAction.scale(by: 1.2, duration: 0.3)
            bigger.timingMode = .easeInEaseOut
            
            let rotateLeft1 = SKAction.rotate(byAngle: CGFloat(-(M_PI/24)), duration: 0.05)
            let rotateRight = SKAction.rotate(byAngle: CGFloat(M_PI/12), duration: 0.1)
            let rotateLeft = SKAction.rotate(byAngle: CGFloat(-(M_PI/12)), duration: 0.1)
            
            let shake = SKAction.sequence([rotateLeft1, rotateRight, rotateLeft, rotateRight, rotateLeft1])
            let wait = SKAction.wait(forDuration: 1)
            
            let grow = SKAction.group([bigger, shake])
            
            let smaller = SKAction.scale(by: 1/1.2, duration: 0.5)
            smaller.timingMode = .easeInEaseOut
            
            let pulse = SKAction.repeatForever(SKAction.sequence([grow, smaller, wait]))
            
            giftButton.run(pulse, withKey: "pulse")
            giftButton2.run(pulse, withKey: "pulse")
            giftButton3.run(pulse, withKey: "pulse")
        }
        
        
        
        if !giftAvailable && dailyChallengeCompleted && !rewardAlreadyCollected && !swipeTutorialNeeded && !level3TutorialNeeded {
            
            confetti = SKEmitterNode(fileNamed: "Confetti1.sks")
            confetti?.position = giftButton.position
            confetti?.zPosition = 20
            self.addChild(confetti!)
            let wait = SKAction.wait(forDuration: 2.8)
            confetti?.run(SKAction.sequence([wait, SKAction.removeFromParent()]))
            
            let sound = SKAction.playSoundFileNamed("ChallengeCompleteSound.aif", waitForCompletion: false)
            let fadeOut = SKAction.run({
                
                var fader: iiFaderForAvAudioPlayer
                switch currentLevel {
                case 1:
                    fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
                case 2:
                    fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
                case 3:
                    fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer3!)
                default:
                    fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
                }
                
                fader.fade(fromVolume: 1.0, toVolume: 0.7, duration: 0.3, velocity: 1, onFinished:  { finished in
                    let wait = SKAction.wait(forDuration: 0.3)
                    
                    let fade = SKAction.run( { fader.fadeIn(0.3, velocity: 2) } )
                    
                    self.run(SKAction.sequence([wait,fade]))
                })
                
                
            })
            
            let group = SKAction.group([fadeOut, sound])
            self.run(group)

        }

        
        
        //MARK: LEVELS
        
        leftTouch = SKButton(buttonImage: "leftTouch", buttonAction: swipeLeft)
        leftTouch.position = CGPoint(x: self.size.width * 0.24, y: self.size.height * 0.15)
        leftTouch.zPosition = 20
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            leftTouch.setScale(1.4)
        default:
            leftTouch.setScale(1.35)
        }
        self.addChild(leftTouch)
        
        rightTouch = SKButton(buttonImage: "rightTouch", buttonAction: swipeRight)
        rightTouch.position = CGPoint(x: self.size.width * 0.76, y: self.size.height * 0.15)
        rightTouch.zPosition = 20
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            rightTouch.setScale(1.4)
        default:
            rightTouch.setScale(1.35)
        }
        self.addChild(rightTouch)

        
        //MARK: LEFT ARROW
        
        leftArrow = SKButton(buttonImage: "leftArrow", buttonAction: swipeLeft)
        leftArrow.position = CGPoint(x: self.size.width * 0.24, y: self.size.height * 0.15)
        leftArrow.alpha = 0
        leftArrow.zPosition = 20
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            leftArrow.setScale(1.15)
        default:
            leftArrow.setScale(0.75)
        }
        self.addChild(leftArrow)
        if currentLevel == 1 {
            leftArrow.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
        }
        
        leftArrow2 = SKButton(buttonImage: "leftArrow2", buttonAction: swipeLeft)
        leftArrow2.position = CGPoint(x: self.size.width * 0.24, y: self.size.height * 0.15)
        leftArrow2.alpha = 0
        leftArrow2.zPosition = 21
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            leftArrow2.setScale(1.15)
        default:
            leftArrow2.setScale(0.75)
        }
        self.addChild(leftArrow2)
        if currentLevel == 2 {
            leftArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        }
        
        leftArrow3 = SKButton(buttonImage: "leftArrow3", buttonAction: swipeLeft)
        leftArrow3.position = CGPoint(x: self.size.width * 0.24, y: self.size.height * 0.15)
        leftArrow3.alpha = 0
        leftArrow3.zPosition = 21
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            leftArrow3.setScale(1.15)
        default:
            leftArrow3.setScale(0.75)
        }
        self.addChild(leftArrow3)
        if currentLevel == 3 {
            leftArrow3.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        }
        
        //MARK: RIGHT ARROW
        
        rightArrow = SKButton(buttonImage: "rightArrow", buttonAction: swipeRight)
        rightArrow.position = CGPoint(x: self.size.width * 0.76, y: self.size.height * 0.15)
        rightArrow.alpha = 0
        rightArrow.zPosition = 20
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            rightArrow.setScale(1.15)
        default:
            rightArrow.setScale(0.75)
        }
        self.addChild(rightArrow)
        if currentLevel == 1 {
            rightArrow.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        }
        
        rightArrow2 = SKButton(buttonImage: "rightArrow2", buttonAction: swipeRight)
        rightArrow2.position = CGPoint(x: self.size.width * 0.76, y: self.size.height * 0.15)
        rightArrow2.alpha = 0
        rightArrow2.zPosition = 21
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            rightArrow2.setScale(1.15)
        default:
            rightArrow2.setScale(0.75)
        }
        self.addChild(rightArrow2)
        if currentLevel == 2 {
            rightArrow2.run(SKAction.fadeAlpha(to: 0.9, duration: 0.3))
        }
        
        rightArrow3 = SKButton(buttonImage: "rightArrow3", buttonAction: swipeRight)
        rightArrow3.position = CGPoint(x: self.size.width * 0.76, y: self.size.height * 0.15)
        rightArrow3.alpha = 0
        rightArrow3.zPosition = 21
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            rightArrow3.setScale(1.15)
        default:
            rightArrow3.setScale(0.75)
        }
        self.addChild(rightArrow3)
        if currentLevel == 3 {
            rightArrow3.run(SKAction.fadeAlpha(to: 0.2, duration: 0.3))
        }
        
        
        
        //MARK: LOCKS AND UNLOCK BUTTONS
        var lvText = "LEVEL 1: DUSK"
        if currentLevel == 2 {
            lvText = "LEVEL 2: NIGHT"
            
            if !nightUnlocked {
            lockedText1 = text("Reach 100 on level 1", fontSize: self.size.width/24, fontName: "Roboto-Light", fontColor: SKColor.white)
            lockedText1.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
            lockedText1.alpha = 0.0
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    lockedText1.fontSize = self.size.width/33
                default:
                    break
                }
            self.addChild(lockedText1)
            lockedText1.run(SKAction.fadeIn(withDuration: 0.3))
            
            
            lockedText2 = text("to unlock level 2.", fontSize: self.size.width/24, fontName: "Roboto-Light", fontColor: SKColor.white)
            lockedText2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.27)
            lockedText2.alpha = 0.0
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    lockedText2.fontSize = self.size.width/33
                default:
                    break
                }
            self.addChild(lockedText2)
            lockedText2.run(SKAction.fadeIn(withDuration: 0.3))
            
            
            lock = SKSpriteNode(imageNamed: "lock")
            lock.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.39)
            lock.alpha = 0
                lock.zPosition = 15

            lock.color = UIColor(red: 192/255, green: 108/255, blue: 132/255, alpha: 0.6)
            lock.colorBlendFactor = 0
            switch UIDevice.current.userInterfaceIdiom {
            case .phone:
                lock.setScale(0.55)
            default:
                lock.setScale(0.9)
            }
            self.addChild(lock)
            lock.run(SKAction.fadeIn(withDuration: 0.4))
                
                
                unlockNightButton = SKButton(buttonImage: "unlockNowNight", buttonAction: unlockNight)
                unlockNightButton.position = CGPoint(x: self.size.width/2, y: center.y + (radius/2.3))
                unlockNightButton.alpha = 0
                unlockNightButton.zPosition = 17
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    unlockNightButton.setScale(1.5)
                default:
                    break
                }
                self.addChild(unlockNightButton)
                unlockNightButton.run(SKAction.fadeAlpha(to: 1, duration: 0.2))
                
            } else {
                if !dawnUnlocked {
                    unlockDawnButton = SKButton(buttonImage: "unlockNowDawn", buttonAction: unlockDawn)
                    unlockDawnButton.position = CGPoint(x: self.size.width/2, y: center.y + (radius/2.3))
                    unlockDawnButton.alpha = 0
                    unlockDawnButton.zPosition = 17
                    switch UIDevice.current.userInterfaceIdiom {
                    case .pad:
                        unlockDawnButton.setScale(1.5)
                    default:
                        break
                    }
                    self.addChild(unlockDawnButton)
                }
            }
            
            
        } else if currentLevel == 3 {
            lvText = "LEVEL 3: DAWN"
            
            if !dawnUnlocked {
                lockedText1 = text("Reach 100 on level 2", fontSize: self.size.width/24, fontName: "Roboto-Light", fontColor: SKColor.white)
                lockedText1.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
                lockedText1.alpha = 0.0
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    lockedText1.fontSize = self.size.width/33
                default:
                    break
                }
                self.addChild(lockedText1)
                lockedText1.run(SKAction.fadeIn(withDuration: 0.3))
                
                
                lockedText2 = text("to unlock level 3.", fontSize: self.size.width/24, fontName: "Roboto-Light", fontColor: SKColor.white)
                lockedText2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.27)
                lockedText2.alpha = 0.0
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    lockedText2.fontSize = self.size.width/33
                default:
                    break
                }
                self.addChild(lockedText2)
                lockedText2.run(SKAction.fadeIn(withDuration: 0.3))
                
                
                lock = SKSpriteNode(imageNamed: "lock")
                lock.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.39)
                lock.alpha = 0
                lock.zPosition = 15

                lock.color = UIColor(red: 192/255, green: 108/255, blue: 132/255, alpha: 0.6)
                lock.colorBlendFactor = 0
                switch UIDevice.current.userInterfaceIdiom {
                case .phone:
                    lock.setScale(0.55)
                default:
                    lock.setScale(0.9)
                }
                self.addChild(lock)
                lock.run(SKAction.fadeIn(withDuration: 0.4))
                
                if !nightUnlocked {
                    unlockNightButton = SKButton(buttonImage: "unlockNowNight", buttonAction: unlockNight)
                    unlockNightButton.position = CGPoint(x: self.size.width/2, y: center.y + (radius/2.3))
                    unlockNightButton.alpha = 0
                    unlockNightButton.zPosition = 17
                    switch UIDevice.current.userInterfaceIdiom {
                    case .pad:
                        unlockNightButton.setScale(1.5)
                    default:
                        break
                    }
                    self.addChild(unlockNightButton)
                } else {
                    unlockDawnButton = SKButton(buttonImage: "unlockNowDawn", buttonAction: unlockDawn)
                    unlockDawnButton.position = CGPoint(x: self.size.width/2, y: center.y + (radius/2.3))
                    unlockDawnButton.alpha = 0
                    unlockDawnButton.zPosition = 17
                    switch UIDevice.current.userInterfaceIdiom {
                    case .pad:
                        unlockDawnButton.setScale(1.5)
                    default:
                        break
                    }
                    self.addChild(unlockDawnButton)
                    unlockDawnButton.run(SKAction.fadeIn(withDuration: 0.2))

                }
            }
        }
        
        if currentLevel == 1 && !nightUnlocked {
            
            unlockNightButton = SKButton(buttonImage: "unlockNowNight", buttonAction: unlockNight)
            unlockNightButton.position = CGPoint(x: self.size.width/2, y: center.y + (radius/2.3))
            unlockNightButton.alpha = 0
            unlockNightButton.zPosition = 17
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                unlockNightButton.setScale(1.5)
            default:
                break
            }
            self.addChild(unlockNightButton)
            
        }
        
        if currentLevel == 1 && nightUnlocked && !dawnUnlocked {
            unlockDawnButton = SKButton(buttonImage: "unlockNowDawn", buttonAction: unlockDawn)
            unlockDawnButton.position = CGPoint(x: self.size.width/2, y: center.y + (radius/2.3))
            unlockDawnButton.alpha = 0
            unlockDawnButton.zPosition = 17
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                unlockDawnButton.setScale(1.5)
            default:
                break
            }
            self.addChild(unlockDawnButton)
        }
        
        priceDisplay = text(price, fontSize: self.size.width/33, fontName: "Roboto-Light", fontColor: SKColor.white)
        priceDisplay.position = CGPoint(x: self.size.width/2, y: center.y + (radius/2.43))
        priceDisplay.alpha = 0
        priceDisplay.zPosition = 17.5
        priceDisplay.verticalAlignmentMode = .top
        self.addChild(priceDisplay)
        if (currentLevel == 2 && !nightUnlocked) || (currentLevel == 3 && !dawnUnlocked && nightUnlocked) {
            priceDisplay.run(SKAction.fadeIn(withDuration: 0.3))
        }
        
        levelText = text(lvText, fontSize: self.size.width/15, fontName: "DolceVita", fontColor: SKColor.white)
        levelText.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.15)
        levelText.alpha = 0
        levelText.zPosition = 20
        levelText.verticalAlignmentMode = .center
        self.addChild(levelText)
        levelText.run(SKAction.fadeAlpha(to: 1, duration: 0.3))
        
        
        //MARK: JUST BEAT A LEVEL
        if swipeTutorialNeeded {
            var fader: iiFaderForAvAudioPlayer
            switch currentLevel {
            case 1:
                fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
            case 2:
                fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            case 3:
                fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer3!)
            default:
                fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
            }
            
            fader.fade(fromVolume: 1.0, toVolume: 0.6, duration: 0.3, velocity: 1, onFinished:  { finished in
                let wait = SKAction.wait(forDuration: 1)
                
                let fade = SKAction.run( { fader.fadeIn(0.3, velocity: 2) } )
                
                self.run(SKAction.sequence([wait,fade]))
            })
            
            
            if volumeOn {
                self.run(SKAction.playSoundFileNamed("LevelCompleteSound.aif", waitForCompletion: false))
            }
            
            darkener.run(SKAction.fadeAlpha(to: 0.85, duration: 0.3))
            
            instructionsText1 = text("Swipe left or right or use the arrow", fontSize: self.size.width/18, fontName: "Roboto-Light", fontColor: SKColor.white)
            instructionsText1.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.6)
            instructionsText1.alpha = 0
            instructionsText1.zPosition = 20
            self.addChild(instructionsText1)
            instructionsText1.run(SKAction.fadeIn(withDuration: 0.3))
            
            instructionsText2 = text("buttons to navigate between levels.", fontSize: self.size.width/18, fontName: "Roboto-Light", fontColor: SKColor.white)
            instructionsText2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.56)
            instructionsText2.alpha = 0
            instructionsText2.zPosition = 20
            self.addChild(instructionsText2)
            instructionsText2.run(SKAction.fadeIn(withDuration: 0.3))
            
            instructionsText3 = text("Level 2 unlocked!", fontSize: self.size.width/14, fontName: "Roboto-Regular", fontColor: SKColor.white)
            instructionsText3.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.8)
            instructionsText3.alpha = 0
            instructionsText3.zPosition = 20
            self.addChild(instructionsText3)
            instructionsText3.run(SKAction.fadeIn(withDuration: 0.3))
            
            swipeCircle = SKShapeNode(circleOfRadius: self.size.width * 0.05)
            swipeCircle.fillColor = SKColor.white
            swipeCircle.strokeColor = SKColor.clear
            swipeCircle.position = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.35)
            swipeCircle.zPosition = 20
            swipeCircle.alpha = 0
            self.addChild(swipeCircle)
            swipeCircle.run(SKAction.fadeAlpha(to: 0.7, duration: 0.3))
            
            let moveLeft = SKAction.moveBy(x: -(self.size.width * 0.6), y: 0, duration: 1)
            moveLeft.timingMode = .easeInEaseOut
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            
            let moveRight = SKAction.moveBy(x: self.size.width * 0.6, y: 0, duration: 0)
            
            let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.3)
            
            let wait = SKAction.wait(forDuration: 0.5)
            
            let sequence = SKAction.sequence([moveLeft, fadeOut, wait, moveRight, fadeIn])
            swipeCircle.run(SKAction.repeatForever(sequence))
            
            confetti = SKEmitterNode(fileNamed: "Confetti1.sks")
            confetti?.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.7)
            confetti?.zPosition = 20
            self.addChild(confetti!)
            let wait1 = SKAction.wait(forDuration: 2.8)
            confetti?.run(SKAction.sequence([wait1, SKAction.removeFromParent()]))

        }
        
        if level3TutorialNeeded {
            
            var fader: iiFaderForAvAudioPlayer
            switch currentLevel {
            case 1:
                fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
            case 2:
                fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer2!)
            case 3:
                fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer3!)
            default:
                fader = iiFaderForAvAudioPlayer(player: backgroundMusicPlayer!)
            }
            
            fader.fade(fromVolume: 1.0, toVolume: 0.6, duration: 0.3, velocity: 1, onFinished:  { finished in
                let wait = SKAction.wait(forDuration: 1)
                
                let fade = SKAction.run( { fader.fadeIn(0.3, velocity: 2) } )
                
                self.run(SKAction.sequence([wait,fade]))
            })
            
            
            if volumeOn {
                self.run(SKAction.playSoundFileNamed("LevelCompleteSound.aif", waitForCompletion: false))
            }
            
            
            darkener.run(SKAction.fadeAlpha(to: 0.85, duration: 0.3))
            
            instructionsText1 = text("Great job! Swipe or use the arrow", fontSize: self.size.width/18, fontName: "Roboto-Light", fontColor: SKColor.white)
            instructionsText1.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.6)
            instructionsText1.alpha = 0
            instructionsText1.zPosition = 20
            self.addChild(instructionsText1)
            instructionsText1.run(SKAction.fadeIn(withDuration: 0.3))
            
            instructionsText2 = text("buttons to navigate to level 3.", fontSize: self.size.width/18, fontName: "Roboto-Light", fontColor: SKColor.white)
            instructionsText2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.56)
            instructionsText2.alpha = 0
            instructionsText2.zPosition = 20
            self.addChild(instructionsText2)
            instructionsText2.run(SKAction.fadeIn(withDuration: 0.3))
            
            instructionsText3 = text("Level 3 unlocked!", fontSize: self.size.width/14, fontName: "Roboto-Regular", fontColor: SKColor.white)
            instructionsText3.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.8)
            instructionsText3.alpha = 0
            instructionsText3.zPosition = 20
            self.addChild(instructionsText3)
            instructionsText3.run(SKAction.fadeIn(withDuration: 0.3))
            
            swipeCircle = SKShapeNode(circleOfRadius: self.size.width * 0.05)
            swipeCircle.fillColor = SKColor.white
            swipeCircle.strokeColor = SKColor.clear
            swipeCircle.position = CGPoint(x: self.size.width * 0.8, y: self.size.height * 0.35)
            swipeCircle.zPosition = 20
            swipeCircle.alpha = 0
            self.addChild(swipeCircle)
            swipeCircle.run(SKAction.fadeAlpha(to: 0.7, duration: 0.3))
            
            let moveLeft = SKAction.moveBy(x: -(self.size.width * 0.6), y: 0, duration: 1)
            moveLeft.timingMode = .easeInEaseOut
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            
            let moveRight = SKAction.moveBy(x: self.size.width * 0.6, y: 0, duration: 0)
            
            let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.3)
            
            let wait = SKAction.wait(forDuration: 0.5)
            
            let sequence = SKAction.sequence([moveLeft, fadeOut, wait, moveRight, fadeIn])
            swipeCircle.run(SKAction.repeatForever(sequence))
            
            confetti = SKEmitterNode(fileNamed: "Confetti1.sks")
            confetti?.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.7)
            confetti?.zPosition = 20
            self.addChild(confetti!)
            let wait1 = SKAction.wait(forDuration: 2.8)
            confetti?.run(SKAction.sequence([wait1, SKAction.removeFromParent()]))
            
        }
        
        //MARK: DAILY BEST
        
        if dailyBestAchievedDusk || dailyBestAchievedDawn || dailyBestAchievedNight {
            
            dailyBestLabel = text("Daily Best!", fontSize: self.size.width/20, fontName: "Roboto-Bold", fontColor: SKColor.white)
            dailyBestLabel.position = CGPoint(x: self.size.width/2, y: scoreLabel.position.y - self.size.height * 0.04)
            dailyBestLabel.zPosition = 18
            dailyBestLabel.alpha = 0
            self.addChild(dailyBestLabel)

            if currentLevel == 1 && dailyBestAchievedDusk {
                dailyBestLabel.run(SKAction.fadeIn(withDuration: 0.5))
            }
            if currentLevel == 2 && dailyBestAchievedNight {
                dailyBestLabel.run(SKAction.fadeIn(withDuration: 0.5))
            }
            if currentLevel == 3 && dailyBestAchievedDawn {
                dailyBestLabel.run(SKAction.fadeIn(withDuration: 0.5))
            }

        }
        
        
        if lastScene == "shop" || lastScene == "settings" || lastScene == "dailyChallenge" {
            reloadTimer()
        }
        
    }
    
    //MARK: END OF DID MOVE TO VIEW ------------------------
    
    func text(_ text: String, fontSize: CGFloat, fontName: String, fontColor: UIColor) -> SKLabelNode {
        
        let text1 = SKLabelNode(text: text)
        text1.fontSize = fontSize
        text1.fontName = fontName
        text1.fontColor = fontColor
        
        return text1
        
    }
    
    var timerTouched = false

    
    //MARK: TOUCHES BEGAN
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        
        numTaps += 1
        
        if gameStarted && !dead {
            isHolding = true
            if volumeOn && !gamePaused {
                self.run(SKAction.playSoundFileNamed("WhooshSound.aif", waitForCompletion: false))
            }
        
            player.removeAllActions()
            
            if movingRight {
                moveLeftFast()
                movingRight = false
            } else {
                moveRightFast()
                movingRight = true
            }
        }
        
  
    }
    
    //MARK: TOUCHES ENDED
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard !swipeTutorialNeeded && !level3TutorialNeeded else {
            return
        }
        
        
        guard !didSwipe else {
            didSwipe = false
            return
        }
                if gameStarted && !dead {
                    isHolding = false
                    if movingRight {
                        moveRight()
                    } else {
                        moveLeft()
                    }
                } else if !gameStarted {
                    if (tutorialNeeded == true && currentLevel == 2 && nightUnlocked) || (tutorialNeeded == true && currentLevel == 3 && dawnUnlocked) || (currentLevel == 1 && tutorialNeeded == true) {
                        tutorial()
                        gameStarted = true
                    } else if (currentLevel == 2 && nightUnlocked) || (currentLevel == 3 && dawnUnlocked) || currentLevel == 1 {
                        startGame()
                        gameStarted = true
                    } else if (currentLevel == 2 && !nightUnlocked) || (currentLevel == 3 && !dawnUnlocked) {
                        lock.run(SKAction.sequence([SKAction.scale(by: 1.1, duration: 0.15), SKAction.scale(by: 1/1.1, duration: 0.15)]))
                        lock.run(SKAction.sequence([SKAction.colorize(withColorBlendFactor: 1.0, duration: 0.15), SKAction.colorize(withColorBlendFactor: 0, duration: 0.15)]))
                        if volumeOn {
                            self.run(SKAction.playSoundFileNamed("ErrorSound.aif", waitForCompletion: false))
                        }
                    }
                }
    }
    

    
    //MARK: MOVE CHARACTER
    func moveRight() {
        
        let dx = player.position.x - center.x
        let dy = player.position.y - center.y
        
        let rad = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: rad, endAngle: rad + CGFloat(4 * M_PI), clockwise: true)
        
        let moveRight = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: speedRotate)
        player.run(SKAction.repeatForever(moveRight).reversed())
    }
    
    func moveLeft() {
        
        let dx = player.position.x - center.x
        let dy = player.position.y - center.y
        
        let rad = atan2(dy, dx)
                
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: rad, endAngle: rad + CGFloat(4 * M_PI), clockwise: true)
        
        let moveLeft = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: speedRotate)
        player.run(SKAction.repeatForever(moveLeft))
        
    }
    
    func moveRightFast() {
        
        let dx = player.position.x - center.x
        let dy = player.position.y - center.y
        
        let rad = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: rad, endAngle: rad + CGFloat(4 * M_PI), clockwise: true)
        
        let moveRight = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: speedRotate * 2)
        player.run(SKAction.repeatForever(moveRight).reversed())
        
    }
    
    func moveLeftFast() {
        
        let dx = player.position.x - center.x
        let dy = player.position.y - center.y
        
        let rad = atan2(dy, dx)
        
        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: rad, endAngle: rad + CGFloat(4 * M_PI), clockwise: true)
        
        let moveRight = SKAction.follow(path.cgPath, asOffset: false, orientToPath: false, speed: speedRotate * 2)
        player.run(SKAction.repeatForever(moveRight))
        
    }
    
    var didDoTutorial = false
    
    //MARK: REMOVE STUFF
    func removeStuff() {
        
        print("removing stuff")
        
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let getRidOfUI = SKAction.sequence([fadeOut, SKAction.removeFromParent()])
        
        let fadeOutFast = SKAction.fadeAlpha(to: 0, duration: 0.4)
        let getRidOfUIFast = SKAction.sequence([fadeOutFast, SKAction.removeFromParent()])
        
        leftTouch.removeFromParent()
        rightTouch.removeFromParent()
        
        title.run(getRidOfUI)
        touchToStart.run(getRidOfUIFast)
        shopButton.run(getRidOfUIFast)
        settingsButton.run(getRidOfUIFast)
        leaderboardButton.run(getRidOfUIFast)
        removeAdsButton.run(getRidOfUIFast)
        rateButton.run(getRidOfUIFast)
        leftArrow.run(getRidOfUIFast)
        rightArrow.run(getRidOfUIFast)
        //bestText.runAction(getRidOfUIFast)
        levelText.run(getRidOfUIFast)
        scoreMarker.run(getRidOfUIFast)
        scoreLabel.run(getRidOfUIFast)
        bestMarker.run(getRidOfUIFast)
        bestLabel.run(getRidOfUIFast)
        giftButton.run(getRidOfUIFast)
        shareButtonCircle.run(getRidOfUIFast)
        likeButton.run(getRidOfUIFast)
        coinIcon.run(getRidOfUIFast)
        coinDisplay.run(getRidOfUIFast)

        if didCollectGift {
            print("removing new coins display, lastScene is \(lastScene)")
            newCoinsDisplay.run(getRidOfUIFast)
            newCoinsIcon.run(getRidOfUIFast)
            didCollectGift = false
        }
        
        if dailyBestAchievedDawn || dailyBestAchievedDusk || dailyBestAchievedNight {
            print("here")
            dailyBestLabel.run(getRidOfUIFast)
        }
        
        shopButton2.run(getRidOfUIFast)
        settingsButton2.run(getRidOfUIFast)
        leaderboardButton2.run(getRidOfUIFast)
        removeAdsButton2.run(getRidOfUIFast)
        rateButton2.run(getRidOfUIFast)
        leftArrow2.run(getRidOfUIFast)
        rightArrow2.run(getRidOfUIFast)
        giftButton2.run(getRidOfUIFast)
        shareButtonCircle2.run(getRidOfUIFast)
        likeButton2.run(getRidOfUIFast)
        scoreMarker2.run(getRidOfUIFast)
        bestMarker2.run(getRidOfUIFast)

        
        shopButton3.run(getRidOfUIFast)
        settingsButton3.run(getRidOfUIFast)
        leaderboardButton3.run(getRidOfUIFast)
        removeAdsButton3.run(getRidOfUIFast)
        rateButton3.run(getRidOfUIFast)
        leftArrow3.run(getRidOfUIFast)
        rightArrow3.run(getRidOfUIFast)
        giftButton3.run(getRidOfUIFast)
        shareButtonCircle3.run(getRidOfUIFast)
        likeButton3.run(getRidOfUIFast)
        scoreMarker3.run(getRidOfUIFast)
        bestMarker3.run(getRidOfUIFast)
        
        priceDisplay.run(getRidOfUIFast)

    }
    
    //MARK: TUTORIAL
    func tutorial() {
        let gradientUp = SKAction.moveTo(y: self.size.height, duration: 0.5)
        gradientUp.timingMode = .easeOut
        let dawnDown = SKAction.moveTo(y: -self.size.height, duration: 0.5)
        
        
        gradient.run(gradientUp)
        nightGradient.run(gradientUp)
        dawnGradient.run(dawnDown)
        
        didDoTutorial = true
        
        
        removeStuff()
        lastScene = "game"
        
        
        let instructions = SKLabelNode(text: "Welcome to Dusk.")
        instructions.fontColor = SKColor.white
        instructions.fontName = "Roboto-Regular"
        instructions.fontSize = self.size.width/16
        instructions.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.65)
        instructions.alpha = 0
        self.addChild(instructions)
        instructions.run(SKAction.fadeAlpha(to: 1, duration: 1))
        
        /*
        let hand = SKSpriteNode(imageNamed: "touch")
        hand.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        hand.alpha = 0
        hand.setScale(0.4)
        self.addChild(hand)
        
        let hand2 = SKSpriteNode(imageNamed: "hold")
        hand2.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        hand2.alpha = 0
        hand2.setScale(0.4)
        self.addChild(hand2)
        
        let handUp = SKAction.moveByX(0, y: self.size.height * 0.02, duration: 0.3)
        let handDown = SKAction.moveByX(0, y: -(self.size.height * 0.02), duration: 0.3)
        let waitHand = SKAction.waitForDuration(0.5)
        let waitHand2 = SKAction.waitForDuration(1)
        let handSeq = SKAction.repeatActionForever(SKAction.sequence([handUp, handDown, waitHand]))
        let handSeq2 = SKAction.repeatActionForever(SKAction.sequence([handUp, waitHand, handDown]))

        hand.runAction(handSeq)
        hand2.runAction(handSeq2)*/
       
        let waitLong = SKAction.wait(forDuration: 5)
        let waitMedium = SKAction.wait(forDuration: 4)
        let waitShort = SKAction.wait(forDuration: 2)
        
        let change1 = SKAction.run({
            instructions.text = "Tap to change the circle's direction."
        })
        
        //let handIn = SKAction.fadeInWithDuration(0.3)
        //let handOut = SKAction.fadeOutWithDuration(0.3)
        
        let change2 = SKAction.run({
            instructions.text = "Tap and hold to speed up."
        })
        
        let change3 = SKAction.run({
            instructions.text = "Avoid all obstacles."
        })
        
        let change4 = SKAction.run({
            instructions.text = "Reach 100 to unlock the next level."
        })
        
        let change5 = SKAction.run({
            instructions.text = "Have fun!"
        })
        
        let away = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let remove = SKAction.removeFromParent()
        
        let start = SKAction.run({
            self.startGame()
            tutorialNeeded = false
            GameData.sharedInstance.tutorialNeeded = false
            GameData.sharedInstance.save()
        })
        
        let changes: [SKAction] = [waitMedium, change1, waitLong, change2, waitLong, change3, waitMedium, change4, waitMedium, change5, waitShort, away, remove, start]
        
        //let hand1Changes = [waitMedium, handIn, waitLong, handOut]
        //let hand2Changes = [waitMedium, waitLong, waitHand, handIn, waitLong, handOut]
        
        instructions.run(SKAction.sequence(changes))
        //hand.runAction(SKAction.sequence(hand1Changes))
        //hand2.runAction(SKAction.sequence(hand2Changes))

    }

    
    
    //MARK: START GAME
    func startGame() {
        
        score = 0
        numTaps = 0
        
        pauseButton.setTexture("pauseButton\(currentLevel)")
        playButton.setTexture("playButton\(currentLevel)")
        homeButton.setTexture("homeButton\(currentLevel)")
        pauseButton.run(SKAction.fadeIn(withDuration: 0.8))

        
        dailyGamesPlayed += 1
        GameData.sharedInstance.dailyGamesPlayed = dailyGamesPlayed
        if currentLevel == 1 {
            dailyGamesPlayedDusk += 1
            GameData.sharedInstance.dailyGamesPlayedDusk = dailyGamesPlayedDusk
        } else if currentLevel == 2 {
            dailyGamesPlayedNight += 1
            GameData.sharedInstance.dailyGamesPlayedNight = dailyGamesPlayedNight
        } else if currentLevel == 3{
            dailyGamesPlayedDawn += 1
            GameData.sharedInstance.dailyGamesPlayedDawn = dailyGamesPlayedDawn
        }
        
        totalGamesPlayed += 1
        GameData.sharedInstance.totalGamesPlayed = totalGamesPlayed
        
        GameData.sharedInstance.save()
        
        checkGamesPlayedChallenges()
        
        if !didDoTutorial {
            
            let gradientUp = SKAction.moveTo(y: self.size.height, duration: 0.5)
            gradientUp.timingMode = .easeOut
            let gradientDown = SKAction.moveTo(y: 0, duration: 70)
            let dawnDown = SKAction.moveTo(y: -self.size.height, duration: 0.5)
            let dawnUp = SKAction.moveTo(y: 0, duration: 70)
            
            
            gradient.run(SKAction.sequence([gradientUp, gradientDown]))
            nightGradient.run(SKAction.sequence([gradientUp, gradientDown]))
            dawnGradient.run(SKAction.sequence([dawnDown, dawnUp]))
            
            removeStuff()
            lastScene = "game"
            
            
            
        } else {
            let gradientDown = SKAction.moveTo(y: 0, duration: 70)
            gradient.run(gradientDown)
            nightGradient.run(gradientDown)
            dawnGradient.run(gradientDown)
        }
        
        let scoreBoardDown = SKAction.moveTo(y: self.size.height * 0.88, duration: 0.9)
        scoreBoardDown.timingMode = .easeOut
        
        scoreBoard.run(SKAction.moveTo(y: self.size.height * 0.88, duration: 0.9))
        scoreBoard.run(SKAction.fadeIn(withDuration: 1.0))
        
        if currentLevel == 1 {
            dailyBestAchievedDusk = false
        }
        if currentLevel == 2 {
            dailyBestAchievedNight = false
        }
        if currentLevel == 3 {
            dailyBestAchievedDawn = false
        }
        
        let increaseScore = SKAction.run({
            
            if !self.dead {
                score += 1
                self.scoreBoard.text = "\(score)"
                
                switch currentLevel {
                case 1:
                    if score == dailyBestDusk + 1 {
                        self.highScoreImage = SKSpriteNode(imageNamed: "dailyBest1")
                        self.highScoreImage.position = CGPoint(x: self.center.x, y: self.center.y)
                        self.highScoreImage.zPosition = -2
                        self.highScoreImage.alpha = 0
                        self.highScoreImage.size = CGSize(width: self.radius * 1.98, height: self.radius * 1.98)
                        self.world.addChild(self.highScoreImage)
                        self.highScoreImage.run(SKAction.fadeAlpha(to: 0.3, duration: 0.5))
                        if volumeOn {
                            self.run(SKAction.playSoundFileNamed("FreeGiftSound.aif", waitForCompletion: false))
                        }
                    }
                case 2:
                    if score == dailyBestNight + 1 {
                        self.highScoreImage = SKSpriteNode(imageNamed: "dailyBest2")
                        self.highScoreImage.position = CGPoint(x: self.center.x, y: self.center.y)
                        self.highScoreImage.zPosition = -2
                        self.highScoreImage.alpha = 0
                        self.highScoreImage.size = CGSize(width: self.radius * 1.98, height: self.radius * 1.98)
                        self.world.addChild(self.highScoreImage)
                        self.highScoreImage.run(SKAction.fadeAlpha(to: 0.3, duration: 0.5))
                        if volumeOn {
                            self.run(SKAction.playSoundFileNamed("FreeGiftSound.aif", waitForCompletion: false))
                        }
                    }
                case 3:
                    if score == dailyBestDawn + 1 {
                        self.highScoreImage = SKSpriteNode(imageNamed: "dailyBest3")
                        self.highScoreImage.position = CGPoint(x: self.center.x, y: self.center.y)
                        self.highScoreImage.zPosition = -2
                        self.highScoreImage.alpha = 0
                        self.highScoreImage.size = CGSize(width: self.radius * 1.98, height: self.radius * 1.98)
                        self.world.addChild(self.highScoreImage)
                        self.highScoreImage.run(SKAction.fadeAlpha(to: 0.3, duration: 0.5))
                        if volumeOn {
                            self.run(SKAction.playSoundFileNamed("FreeGiftSound.aif", waitForCompletion: false))
                        }
                    }
                default:
                    break
                }
            }
            
        })
        
        if currentLevel == 1 {
            numberOfLevels = 40
            numberOfEasyLevels = 9
            numberOfMediumLevels = 6
            startLevel = 1
        } else if currentLevel == 2 {
            numberOfLevels = 32
            numberOfEasyLevels = 32
            numberOfMediumLevels = 0
            startLevel = 41
        } else if currentLevel == 3 {
            numberOfLevels = 31
            numberOfEasyLevels = 31
            numberOfMediumLevels = 0
            startLevel = 73
        }
        
        let wait = SKAction.wait(forDuration: 0.7)
        
        let sequence = SKAction.sequence([wait, increaseScore])
        
        world.run(SKAction.repeatForever(sequence), withKey: "scoreUp")
        
        
        let numOfSegments = Int(ceil(self.size.height/(segmentHeight/2)))
        for i in 0..<numOfSegments {
            startSegment(i)
        }
        
        justOpenedApp = false
    }
    
    
    
    //MARK: CREATE SEGMENTS
    func startSegment(_ segmentNumber:Int) {
        
        
        let otherNum = Int(ceil(self.size.height/segmentHeight)) //on iphone6, 2 on ipad, 2 -- NUM OF SEGMENTS NEEDED TO COVER SCREEN
        let spawnHeight = CGFloat(otherNum * Int(segmentHeight)) // on iphon6, 800 on ipad, 1200 -- SPACE TAKEN UP BY SEGMENTS NEEDED ""
        var fileName: String
        
        if segmentNumber > 1 { //MEDIUM
            let random = arc4random_uniform(UInt32(numberOfEasyLevels + numberOfMediumLevels)) + UInt32(startLevel)
            //random = 90
            fileName = "Level\(random)"
        } else { //EASY
            let random = arc4random_uniform(UInt32(numberOfEasyLevels)) + UInt32(startLevel)
            //random = 90
            fileName = "Level\(random)"
        }
        
        //fileName = "Level56"
        
        let segment = SKNode.unarchiveFromFile(fileName)
        
        let coinRand = arc4random_uniform(8)
        print("coin rand is \(coinRand)")
        if coinRand == 0 {
            let coin2 = segment?.childNode(withName: "coin2")
            coin2?.removeFromParent()
        } else if coinRand == 1 {
            let coin1 = segment?.childNode(withName: "coin1")
            coin1?.removeFromParent()
        } else {
            let coin1 = segment?.childNode(withName: "coin1")
            let coin2 = segment?.childNode(withName: "coin2")
            coin1?.removeFromParent()
            coin2?.removeFromParent()
        }

      
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            segment?.setScale(iPadScale)
        default: break
        }
        
        segment?.zPosition = 1
        segment?.position = CGPoint(x: (self.size.width - segmentWidth)/2, y: spawnHeight + CGFloat(Int(segmentHeight) * segmentNumber))
        segment?.name = "segment"
        
        world.addChild(segment!)

        let move1 = SKAction.moveTo(y: -segmentHeight, duration: speedGame * Double(((segment?.position.y)! - (-segmentHeight))/segmentHeight))

        
        let comment = SKAction.run( {print("reached bottom for start segment \(segmentNumber)")})
        let spawnNew = SKAction.run( { self.generateSegment() } )
        let remove = SKAction.removeFromParent()
        
        let moves1 = SKAction.sequence([move1, /*moveDown, */comment, spawnNew, remove])

        segment?.run(moves1)
    }
    
    func generateSegment() {
        let numOfSegments = Int(ceil(self.size.height/(segmentHeight/2))) //on iphon6, 4
        let spawnHeight = CGFloat((numOfSegments - 1) * Int(segmentHeight)) //on iphone6, 1200
        
        
        func genRandom() -> Int {
                //ALL LEVELS AVAILABLE EXCEPT EASY
            
                let random = arc4random_uniform(UInt32(numberOfLevels - numberOfEasyLevels)) + UInt32(numberOfEasyLevels + 1)
                return Int(random)
        }
        
        func genRandom2() -> Int {
            //ALL LEVELS AVAILABLE EXCEPT EASY
            
            let random = arc4random_uniform(UInt32(numberOfLevels)) + UInt32(startLevel)
            
            return Int(random)
        }
        
        var randomSeg: Int
        if currentLevel == 1 {
            randomSeg = genRandom()
        } else if currentLevel == 2 || currentLevel == 3 {
            randomSeg = genRandom2()
        } else {
            randomSeg = genRandom()
        }
        //print("level number is \(randomSeg)")
        last = randomSeg
        
        //randomSeg = 91
        
        let fileName: String = "Level\(randomSeg)"
        let segment = SKNode.unarchiveFromFile(fileName)
        
        let coinRand = arc4random_uniform(8)
        print("coin rand is \(coinRand)")
        if coinRand == 0 {
            let coin2 = segment?.childNode(withName: "coin2")
            coin2?.removeFromParent()
        } else if coinRand == 1 {
            let coin1 = segment?.childNode(withName: "coin1")
            coin1?.removeFromParent()
        } else {
            let coin1 = segment?.childNode(withName: "coin1")
            let coin2 = segment?.childNode(withName: "coin2")
            coin1?.removeFromParent()
            coin2?.removeFromParent()
        }
        
        segment?.zPosition = 1
        segment?.position = CGPoint(x: (self.size.width - segmentWidth)/2, y: spawnHeight)
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            segment?.setScale(iPadScale)
        default: break
        }
        
        segment?.name = "segment"

        world.addChild(segment!)
        moveSegment(segment!)
        
        
    }
    
    func moveSegment(_ segment: SKNode) {
        
        let move1 = SKAction.moveTo(y: -segmentHeight, duration: speedGame * Double(((segment.position.y) - (-segmentHeight))/segmentHeight))
        
        let spawnNew = SKAction.run( { self.generateSegment() } )
        //let comment = SKAction.runBlock({print("normal segment reached bottom")})
        let remove = SKAction.removeFromParent()
        
        segment.run(SKAction.sequence([move1, spawnNew, remove]))
        
        
    }
    
    //MARK: SETUP AUDIO
    
    func setupAudio() {
        if currentLevel == 1 {
            if backgroundMusicPlayer == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "DuskMusic2", withExtension: "m4a")
                backgroundMusicPlayer = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer!.numberOfLoops = -1
            }
            if backgroundMusicPlayer!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer!.play()
            }
        } else if currentLevel == 2 {
            if backgroundMusicPlayer2 == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "NightMusic", withExtension: "m4a")
                backgroundMusicPlayer2 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer2!.numberOfLoops = -1
            }
            if backgroundMusicPlayer2!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer2!.play()
            }
        } else if currentLevel == 3 {
            if backgroundMusicPlayer3 == nil {
                let backgroundMusicURL = Bundle.main.url(forResource: "DawnMusic", withExtension: "m4a")
                backgroundMusicPlayer3 = try! AVAudioPlayer(contentsOf: backgroundMusicURL!)
                backgroundMusicPlayer3!.numberOfLoops = -1
            }
            if backgroundMusicPlayer3!.isPlaying == false && volumeOn && !musicSilenced {
                backgroundMusicPlayer3!.play()
            }
        }
    }
    
    //MARK: ------------------------------------------------------------------------------------
    //MARK: DIE DIE DIE DIE DIE
    
    func returnToHome() -> Void {
        
        gamePaused = false
        
        darkener.run(SKAction.fadeOut(withDuration: 0.3))
        playButton.run(SKAction.fadeOut(withDuration: 0.3))
        homeButton.run(SKAction.fadeOut(withDuration: 0.3))
        
        world.isPaused = false
        gradient.isPaused = false
        dawnGradient.isPaused = false
        nightGradient.isPaused = false
        
        world.removeAction(forKey: "scoreUp")
        
        totalPoints += score
        GameData.sharedInstance.totalPoints = totalPoints
        
        dailyPointsScored += score
        GameData.sharedInstance.dailyPointsScored = dailyPointsScored
        
        lastScores.append(score)
        GameData.sharedInstance.lastScores = lastScores
        
        GameData.sharedInstance.save()
        
        if gameCenterEnabled {
            reportNumberToGameCenter(totalPoints, leaderboardId: "com.quantumcat.dusk.totalPoints")
        }
        
        gradient.removeAllActions()
        nightGradient.removeAllActions()
        dawnGradient.removeAllActions()
        player.removeAllActions()
        
        if currentLevel == 1 {
            lastScoresDusk.append(score)
            GameData.sharedInstance.lastScoresDusk = lastScoresDusk
            
            dailyPointsScoredDusk += score
            GameData.sharedInstance.dailyPointsScoredDusk = dailyPointsScoredDusk
            GameData.sharedInstance.save()
            if score > highScore {
                
                if dailyChallengeCurrent == 12 || dailyChallengeCurrent == 31 {
                    completeChallenge()
                }
                
                highScore = score
                GameData.sharedInstance.highScoreDusk = highScore
                GameData.sharedInstance.save()
                
            }
            if score > dailyBestDusk {
                highScoreImage.run(SKAction.fadeOut(withDuration: 0.5))
                dailyBestAchievedDusk = true
                dailyBestDusk = score
                GameData.sharedInstance.dailyBestDusk = dailyBestDusk
                GameData.sharedInstance.save()
                
                if dailyChallengeCurrent == 13 {
                    completeChallenge()
                }
                
            }
            lastDusk = score
            if score >= 100 && !nightUnlocked {
                nightUnlocked = true
                GameData.sharedInstance.level2Unlocked = true
                GameData.sharedInstance.save()
                swipeTutorialNeeded = true
                
            }
            checkScoreChallengesDusk()
            checkTotalScoreChallengesDusk()
            
            if gameCenterEnabled {
                reportAchievementToGameCenter("com.quantumcat.dusk.30PointsDusk", numberAchieved: score, totalRequired: 30)
                reportAchievementToGameCenter("com.quantumcat.dusk.50PointsDusk", numberAchieved: score, totalRequired: 50)
                reportAchievementToGameCenter("com.quantumcat.dusk.100PointsDusk", numberAchieved: score, totalRequired: 100)
                reportAchievementToGameCenter("com.quantumcat.dusk.200PointsDusk", numberAchieved: score, totalRequired: 200)
            }
            
            
        }
        if currentLevel == 2 {
            lastScoresNight.append(score)
            GameData.sharedInstance.lastScoresNight = lastScoresNight
            
            dailyPointsScoredNight += score
            GameData.sharedInstance.dailyPointsScoredNight = dailyPointsScoredNight
            GameData.sharedInstance.save()
            if score > highScoreNight {
                
                if dailyChallengeCurrent == 12 || dailyChallengeCurrent == 56 {
                    completeChallenge()
                }
                
                highScoreNight = score
                GameData.sharedInstance.highScoreNight = highScoreNight
                GameData.sharedInstance.save()
                
                
            }
            if score > dailyBestNight {
                highScoreImage.run(SKAction.fadeOut(withDuration: 0.5))
                dailyBestAchievedNight = true
                
                if dailyChallengeCurrent == 13 {
                    completeChallenge()
                }
                
                
                dailyBestNight = score
                GameData.sharedInstance.dailyBestNight = dailyBestNight
                GameData.sharedInstance.save()
                
            }
            lastNight = score
            if score >= 100 && !dawnUnlocked {
                dawnUnlocked = true
                GameData.sharedInstance.level3Unlocked = true
                GameData.sharedInstance.save()
                level3TutorialNeeded = true
                
            }
            
            checkScoreChallengesNight()
            checkTotalScoreChallengesNight()
            
            if gameCenterEnabled {
                reportAchievementToGameCenter("com.quantumcat.dusk.30PointsNight", numberAchieved: score, totalRequired: 30)
                reportAchievementToGameCenter("com.quantumcat.dusk.50PointsNight", numberAchieved: score, totalRequired: 50)
                reportAchievementToGameCenter("com.quantumcat.dusk.100PointsNight", numberAchieved: score, totalRequired: 100)
                reportAchievementToGameCenter("com.quantumcat.dusk.200PointsNight", numberAchieved: score, totalRequired: 200)
            }
        }
        if currentLevel == 3 {
            lastScoresDawn.append(score)
            GameData.sharedInstance.lastScoresDawn = lastScoresDawn
            
            dailyPointsScoredDawn += score
            GameData.sharedInstance.dailyPointsScoredDawn = dailyPointsScoredDawn
            GameData.sharedInstance.save()
            if score > highScoreDawn {
                
                if dailyChallengeCurrent == 12 || dailyChallengeCurrent == 78 {
                    completeChallenge()
                }
                
                highScoreDawn = score
                GameData.sharedInstance.highScoreDawn = highScoreDawn
                GameData.sharedInstance.save()
                
                
            }
            if score > dailyBestDawn {
                highScoreImage.run(SKAction.fadeOut(withDuration: 0.5))
                dailyBestAchievedDawn = true
                
                if dailyChallengeCurrent == 13 {
                    completeChallenge()
                }
                
                dailyBestDawn = score
                GameData.sharedInstance.dailyBestDawn = dailyBestDawn
                GameData.sharedInstance.save()
            }
            lastDawn = score
            
            checkScoreChallengesDawn()
            checkTotalScoreChallengesDawn()
            
            if gameCenterEnabled {
                reportAchievementToGameCenter("com.quantumcat.dusk.30PointsDawn", numberAchieved: score, totalRequired: 30)
                reportAchievementToGameCenter("com.quantumcat.dusk.50PointsDawn", numberAchieved: score, totalRequired: 50)
                reportAchievementToGameCenter("com.quantumcat.dusk.100PointsDawn", numberAchieved: score, totalRequired: 100)
                reportAchievementToGameCenter("com.quantumcat.dusk.200PointsDawn", numberAchieved: score, totalRequired: 200)
            }
        }


        checkScoreStreakChallenges()
        checkTapChallenges()
        checkScoreChallenges()
        checkTotalScoreChallenges()
        
        let fade = SKAction.fadeOut(withDuration: 0.5)
        
        world.enumerateChildNodes(withName: "segment", using: {
            node, stop in
            node.removeAllActions()
            node.run(fade)

        })
        
        guideCircle.run(fade)
        player.run(fade)
        
        let gradDown = SKAction.moveTo(y: 0, duration: 0.5)
        gradDown.timingMode = .easeOut
        
        gradient.run(gradDown)
        nightGradient.run(gradDown)
        dawnGradient.run(gradDown)
        
        var scoreBoardLocation: CGPoint
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            scoreBoardLocation = CGPoint(x: self.size.width/2, y: self.size.height * 0.62)
        default:
            scoreBoardLocation = CGPoint(x: self.size.width/2, y: self.size.height * 0.643)
        }
        
        let boardDown = SKAction.move(to: scoreBoardLocation, duration: 0.5)
        boardDown.timingMode = .easeOut
        scoreBoard.run(boardDown)
        scoreBoard.run(SKAction.scale(to: 1.0, duration: 0.5))
        
        timer.invalidate()
        
        let scene = GameScene(size: view!.bounds.size)
        // Configure the view.
        let skView = self.view! as SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        
        let present = SKAction.run({ skView.presentScene(scene) })
        let wait1 = SKAction.wait(forDuration: 0.5)
        self.run(SKAction.sequence([wait1, present]))

        trail.particleBirthRate = 0.0
        trail.alpha = 0.0
        
        if currentLevel == 2 {
            trail2.alpha = 0.0
            trail2.particleBirthRate = 0.0
        } else if currentLevel == 3 {
            trail3.alpha = 0.0
            trail3.particleBirthRate = 0.0
        }

        
    }
    
    func die() {
        
        totalPoints += score
        GameData.sharedInstance.totalPoints = totalPoints
        
        dailyPointsScored += score
        GameData.sharedInstance.dailyPointsScored = dailyPointsScored
        
        lastScores.append(score)
        GameData.sharedInstance.lastScores = lastScores
        
        GameData.sharedInstance.save()
        
        if gameCenterEnabled {
            reportNumberToGameCenter(totalPoints, leaderboardId: "com.quantumcat.dusk.totalPoints")
        }
        
        gradient.removeAllActions()
        nightGradient.removeAllActions()
        dawnGradient.removeAllActions()
        player.removeAllActions()
        
        if currentLevel == 1 {
            lastScoresDusk.append(score)
            GameData.sharedInstance.lastScoresDusk = lastScoresDusk
            
            dailyPointsScoredDusk += score
            GameData.sharedInstance.dailyPointsScoredDusk = dailyPointsScoredDusk
            GameData.sharedInstance.save()
            if score > highScore {
                
                highScore = score
                GameData.sharedInstance.highScoreDusk = highScore
                GameData.sharedInstance.save()
                
                if dailyChallengeCurrent == 12 || dailyChallengeCurrent == 31 {
                    completeChallenge()
                }
                

            }
            if score > dailyBestDusk {
                highScoreImage.run(SKAction.fadeOut(withDuration: 1.5))
                dailyBestAchievedDusk = true
                dailyBestDusk = score
                GameData.sharedInstance.dailyBestDusk = dailyBestDusk
                GameData.sharedInstance.save()
                
                if dailyChallengeCurrent == 13 {
                    completeChallenge()
                }

            }
            lastDusk = score
            if score >= 100 && !nightUnlocked {
                nightUnlocked = true
                GameData.sharedInstance.level2Unlocked = true
                GameData.sharedInstance.save()
                swipeTutorialNeeded = true
                
            }
            checkScoreChallengesDusk()
            checkTotalScoreChallengesDusk()
            
            
            if gameCenterEnabled {
            reportAchievementToGameCenter("com.quantumcat.dusk.30PointsDusk", numberAchieved: score, totalRequired: 30)
            reportAchievementToGameCenter("com.quantumcat.dusk.50PointsDusk", numberAchieved: score, totalRequired: 50)
            reportAchievementToGameCenter("com.quantumcat.dusk.100PointsDusk", numberAchieved: score, totalRequired: 100)
            reportAchievementToGameCenter("com.quantumcat.dusk.200PointsDusk", numberAchieved: score, totalRequired: 200)
            }


        }
        if currentLevel == 2 {
            lastScoresNight.append(score)
            GameData.sharedInstance.lastScoresNight = lastScoresNight
            
            dailyPointsScoredNight += score
            GameData.sharedInstance.dailyPointsScoredNight = dailyPointsScoredNight
            GameData.sharedInstance.save()
            if score > highScoreNight {
                
                highScoreNight = score
                GameData.sharedInstance.highScoreNight = highScoreNight
                GameData.sharedInstance.save()
                
                if dailyChallengeCurrent == 12 || dailyChallengeCurrent == 56 {
                    completeChallenge()
                }
                

            }
            if score > dailyBestNight {
                highScoreImage.run(SKAction.fadeOut(withDuration: 1.5))
                dailyBestAchievedNight = true

                
                dailyBestNight = score
                GameData.sharedInstance.dailyBestNight = dailyBestNight
                GameData.sharedInstance.save()
                
                if dailyChallengeCurrent == 13 {
                    completeChallenge()
                }
                
            }
            lastNight = score
            if score >= 100 && !dawnUnlocked {
                dawnUnlocked = true
                GameData.sharedInstance.level3Unlocked = true
                GameData.sharedInstance.save()
                level3TutorialNeeded = true
                
            }
            
            checkScoreChallengesNight()
            checkTotalScoreChallengesNight()
            
            if gameCenterEnabled {
            reportAchievementToGameCenter("com.quantumcat.dusk.30PointsNight", numberAchieved: score, totalRequired: 30)
            reportAchievementToGameCenter("com.quantumcat.dusk.50PointsNight", numberAchieved: score, totalRequired: 50)
            reportAchievementToGameCenter("com.quantumcat.dusk.100PointsNight", numberAchieved: score, totalRequired: 100)
            reportAchievementToGameCenter("com.quantumcat.dusk.200PointsNight", numberAchieved: score, totalRequired: 200)
            }
        }
        if currentLevel == 3 {
            lastScoresDawn.append(score)
            GameData.sharedInstance.lastScoresDawn = lastScoresDawn
            
            dailyPointsScoredDawn += score
            GameData.sharedInstance.dailyPointsScoredDawn = dailyPointsScoredDawn
            GameData.sharedInstance.save()
            if score > highScoreDawn {
                
                highScoreDawn = score
                GameData.sharedInstance.highScoreDawn = highScoreDawn
                GameData.sharedInstance.save()
                
                if dailyChallengeCurrent == 12 || dailyChallengeCurrent == 78 {
                    completeChallenge()
                }
                

            }
            if score > dailyBestDawn {
                highScoreImage.run(SKAction.fadeOut(withDuration: 1.5))
                dailyBestAchievedDawn = true

                if dailyChallengeCurrent == 13 {
                    completeChallenge()
                }
                
                dailyBestDawn = score
                GameData.sharedInstance.dailyBestDawn = dailyBestDawn
                GameData.sharedInstance.save()
            }
            lastDawn = score
            
            checkScoreChallengesDawn()
            checkTotalScoreChallengesDawn()
            
            if gameCenterEnabled {
            reportAchievementToGameCenter("com.quantumcat.dusk.30PointsDawn", numberAchieved: score, totalRequired: 30)
            reportAchievementToGameCenter("com.quantumcat.dusk.50PointsDawn", numberAchieved: score, totalRequired: 50)
            reportAchievementToGameCenter("com.quantumcat.dusk.100PointsDawn", numberAchieved: score, totalRequired: 100)
            reportAchievementToGameCenter("com.quantumcat.dusk.200PointsDawn", numberAchieved: score, totalRequired: 200)
            }
        }
        
        //gems += score
        //GameData.sharedInstance.gems = gems
        //GameData.sharedInstance.save()
        
        if volumeOn {
            let smack = SKAction.playSoundFileNamed("SmackSound.aif", waitForCompletion: false)
            self.run(smack)
        }
        
        checkScoreStreakChallenges()
        checkTapChallenges()
        checkScoreChallenges()
        checkTotalScoreChallenges()
        
        let wait = SKAction.wait(forDuration: 1.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let fadeRemove = SKAction.sequence([wait, fade])
        
        world.enumerateChildNodes(withName: "segment", using: {
            node, stop in
            node.removeAllActions()
            node.run(fadeRemove)
            let moveDown = SKAction.moveBy(x: 0, y: -40, duration: 1.0)
            moveDown.timingMode = .easeOut
            node.run(moveDown)
        })
        
        guideCircle.run(fadeRemove)
        
        let gradDown = SKAction.moveTo(y: 0, duration: 1.0)
        gradDown.timingMode = .easeOut
        
        gradient.run(gradDown)
        nightGradient.run(gradDown)
        dawnGradient.run(gradDown)
        
        var scoreBoardLocation: CGPoint
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            scoreBoardLocation = CGPoint(x: self.size.width/2, y: self.size.height * 0.62)
        default:
            scoreBoardLocation = CGPoint(x: self.size.width/2, y: self.size.height * 0.643)
        }
        
        let boardDown = SKAction.move(to: scoreBoardLocation, duration: 2.0)
        boardDown.timingMode = .easeOut
        scoreBoard.run(boardDown)
        scoreBoard.run(SKAction.scale(to: 1.0, duration: 2.0))
        
        let random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        //print("random is \(random)")
        //print("player size is \(player.size)")
        
        let rotation = random * CGFloat(M_PI) * 2.0
        var deathFile: String
        
        if currentLevel == 1 {
            deathFile = "Death"

        } else if currentLevel == 2 {
            deathFile = "Death2"

        } else if currentLevel == 3 {
            deathFile = "Death3"
            
        } else {
            deathFile = "Death"

        }
        
        let death = SKNode.unarchiveFromFile(deathFile)!
        death.zRotation = rotation
        death.position = player.position
        death.setScale(self.player.size.width/100.0)
        death.zPosition = 1000
        world.addChild(death)
        
        world.run(SKAction.shake(0.5, amplitudeX: 20, amplitudeY: 12))
        
        timer.invalidate()
        
        let scene = GameScene(size: view!.bounds.size)
        // Configure the view.
        let skView = self.view! as SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        
        
        let present = SKAction.run({ skView.presentScene(scene) })
        let wait1 = SKAction.wait(forDuration: 1.5)
        let fadeDeath = SKAction.fadeAlpha(to: 0, duration: 0.5)
        
        death.run(SKAction.sequence([wait1, fadeDeath, present]))
        
        
        player.alpha = 0.0
        trail.particleBirthRate = 0.0
        trail.alpha = 0.0
        
        if currentLevel == 2 {
            trail2.alpha = 0.0
            trail2.particleBirthRate = 0.0
            player2.alpha = 0.0
        } else if currentLevel == 3 {
            trail3.alpha = 0.0
            trail3.particleBirthRate = 0.0
            player3.alpha = 0.0
        }
    }
    
    //MARK: COLLISION HANDLING
    func playerDidCollideWithEnemy() {
        //print("collision")
        dead = true
        die()
    }
    
    func collectCoin() {
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {

         if (contact.bodyA.categoryBitMask != contact.bodyB.categoryBitMask) && !dead {
            if contact.bodyA.categoryBitMask == 3 {
                gems += 50
                GameData.sharedInstance.gems = gems
                GameData.sharedInstance.save()
                
                let position = contact.contactPoint
                
                let coin = contact.bodyA.node
                let segment = coin?.parent
                
                let coinParticle = SKEmitterNode(fileNamed: "MiniCoinExplosion.sks")
                coinParticle?.zPosition = 16
                coinParticle?.position = self.convert(position, to: segment!)
                //coinParticle?.position = position
                segment!.addChild(coinParticle!)
                
                
                let number = text("+50", fontSize: self.size.width/15, fontName: "Roboto-Light", fontColor: SKColor.white)
                number.zPosition = 16.5
                number.position = self.convert(position, to: segment!)
                //number.position = position
                segment!.addChild(number)
                
                coin?.removeFromParent()
            
                let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 1.2)
                let fadeOut = SKAction.fadeOut(withDuration: 1.2)
                number.run(SKAction.group([moveUp, fadeOut]))
                
                let wait = SKAction.wait(forDuration: 2)
                let remove = SKAction.removeFromParent()
                coinParticle?.run(SKAction.sequence([wait, remove]))
                
                self.run(SKAction.playSoundFileNamed("CoinCollectSound.aif", waitForCompletion: false))

                
            } else if contact.bodyB.categoryBitMask == 3 {
                gems += 50
                GameData.sharedInstance.gems = gems
                GameData.sharedInstance.save()
                
                let position = contact.contactPoint
                
                let coin = contact.bodyB.node
                let segment = coin?.parent

                let coinParticle = SKEmitterNode(fileNamed: "MiniCoinExplosion.sks")
                coinParticle?.zPosition = 16
                coinParticle?.position = self.convert(position, to: segment!)
                //coinParticle?.position = position
                segment!.addChild(coinParticle!)
                
                
                let number = text("+50", fontSize: self.size.width/20, fontName: "Roboto-Light", fontColor: SKColor.white)
                number.zPosition = 16.5
                number.position = self.convert(position, to: segment!)
                //number.position = position
                segment!.addChild(number)
                
                coin?.removeFromParent()
        
                let moveUp = SKAction.moveBy(x: 0, y: 40, duration: 1.2)
                let fadeOut = SKAction.fadeOut(withDuration: 1.2)
                number.run(SKAction.group([moveUp, fadeOut]))
                
                let wait = SKAction.wait(forDuration: 2)
                let remove = SKAction.removeFromParent()
                coinParticle?.run(SKAction.sequence([wait, remove]))
            } else {
                playerDidCollideWithEnemy()
            }
        }
        
        
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    //MARK: GAME CENTER
    
    func reportNumberToGameCenter(_ amount:Int, leaderboardId: String) {
        
        let scoreReporter = GKScore(leaderboardIdentifier: leaderboardId)
        
        scoreReporter.value = Int64(amount) //score variable here (same as above)
        
        let scoreArray: [GKScore] = [scoreReporter]
        
        GKScore.report(scoreArray, withCompletionHandler: {
            
            error -> Void in
            if error != nil {
                print("error")
            } else {
                //print("posted score")
            }
            
            }
        )
        
        //}
        
    }
    
    func reportAchievementToGameCenter(_ achievementId: String, numberAchieved: Int, totalRequired: Int) {
        
        let achievement = GKAchievement(identifier: achievementId)
        achievement.percentComplete = Double(numberAchieved/totalRequired) * 100
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement], withCompletionHandler: nil)
    }
    
    //MARK: CHECK CHALLENGES -------------------
    
    func checkScoreStreakChallenges() {
        
        //daily challenges that depend on getting scores a certain number of times in a row
        let numScoresDusk = lastScoresDusk.count
        let numScoresNight = lastScoresNight.count
        let numScoresDawn = lastScoresDawn.count
        let numScores = lastScores.count
        
        switch dailyChallengeCurrent {
        case 16:
            if lastScoresDusk[numScoresDusk - 1] >= 35 && lastScoresDusk[numScoresDusk - 2] >= 35 && lastScoresDusk[numScoresDusk - 3] >= 35 {
                completeChallenge()
            }
        case 6:
            if lastScores[numScores - 1] >= 30 && lastScores[numScores - 2] >= 30 && lastScores[numScores - 3] >= 30 {
                completeChallenge()
            }
        case 17:
            if lastScores[numScores - 1] >= 40 && lastScores[numScores - 2] >= 30 {
                completeChallenge()
            }
        case 29:
            if lastScoresDusk[numScoresDusk - 1] >= 40 && lastScoresDusk[numScoresDusk - 2] >= 40 && lastScoresDusk[numScoresDusk - 3] >= 40 {
                completeChallenge()
            }
        case 32:
            if lastScores[numScores - 1] >= 25 && lastScores[numScores - 2] >= 25 && lastScores[numScores - 3] >= 25 && lastScores[numScores - 4] >= 25 {
                completeChallenge()
            }
        case 38:
            if lastScoresDusk[numScoresDusk - 1] >= 50 && lastScoresDusk[numScoresDusk - 2] >= 50 {
                completeChallenge()
            }
        case 41:
            var numAch = 0
            for score in lastScoresDusk {
                if score >= 40 {
                    numAch += 1
                }
            }
            if numAch >= 3 {
                completeChallenge()
            }
        case 42:
            var numAch = 0
            for score in lastScores {
                if score >= 30 {
                    numAch += 1
                }
            }
            if numAch >= 5 {
                completeChallenge()
            }
        case 44:
            var numAch = 0
            for score in lastScoresDusk {
                if score >= 50 {
                    numAch += 1
                }
            }
            if numAch >= 2 {
                completeChallenge()
            }
        case 0:
            var numAch = 0
            for score in lastScoresDusk {
                if score >= 40 {
                    numAch += 1
                }
            }
            if numAch >= 4 {
                completeChallenge()
            }
        case 51:
            if lastScoresNight[numScoresNight - 1] >= 35 && lastScoresNight[numScoresNight - 2] >= 35 && lastScoresNight[numScoresNight - 3] >= 35 {
                completeChallenge()
            }
        case 54:
            if lastScoresNight[numScoresNight - 1] >= 40 && lastScoresNight[numScoresNight - 2] >= 40 && lastScoresNight[numScoresNight - 3] >= 40 {
                completeChallenge()
            }
        case 61:
            if lastScoresNight[numScoresNight - 1] >= 50 && lastScoresNight[numScoresNight - 2] >= 50 {
                completeChallenge()
            }
        case 62:
            var numAch = 0
            for score in lastScoresNight {
                if score >= 40 {
                    numAch += 1
                }
            }
            if numAch >= 3 {
                completeChallenge()
            }
        case 64:
            var numAch = 0
            for score in lastScoresNight {
                if score >= 50 {
                    numAch += 1
                }
            }
            if numAch >= 2 {
                completeChallenge()
            }
        case 73:
            if lastScoresDawn[numScoresDawn - 1] >= 35 && lastScoresDawn[numScoresDawn - 2] >= 35 && lastScoresDawn[numScoresDawn - 3] >= 35 {
                completeChallenge()
            }
        case 76:
            if lastScoresDawn[numScoresDawn - 1] >= 40 && lastScoresDawn[numScoresDawn - 2] >= 40 && lastScoresDawn[numScoresDawn - 3] >= 40 {
                completeChallenge()
            }
        case 83:
            if lastScoresDawn[numScoresDawn - 1] >= 45 && lastScoresDawn[numScoresDawn - 2] >= 45 {
                completeChallenge()
            }
        case 84:
            var numAch = 0
            for score in lastScoresDawn {
                if score >= 40 {
                    numAch += 1
                }
            }
            if numAch >= 3 {
                completeChallenge()
            }
        case 86:
            var numAch = 0
            for score in lastScoresDawn {
                if score >= 50 {
                    numAch += 1
                }
            }
            if numAch >= 2 {
                completeChallenge()
            }
        case 92:
            var numAch = 0
            for score in lastScoresDawn {
                if score >= 30 {
                    numAch += 1
                }
            }
            if numAch >= 4 {
                completeChallenge()
            }
        default:
            break
        }

        
    }
    
    func checkScoreChallenges() {
        switch dailyChallengeCurrent {
        case 19:
            if score == 42 {
                completeChallenge()
            }
        case 20:
            if score >= 40 && score <= 60 {
                completeChallenge()
            }
        case 28:
            if score >= 60 {
                completeChallenge()
            }
        default:
            break
        }
        
    }
    
    func checkScoreChallengesDusk() {
        
        print("score is \(score) and daily challenge number is \(dailyChallengeCurrent)")
        switch dailyChallengeCurrent {
        case 1:
            if score >= 20 {
                print("complete")
                completeChallenge()
            }
        case 2:
            if score >= 40 {
                completeChallenge()
            }
        case 5:
            if score >= 5 && score <= 10 {
                completeChallenge()
            }
        case 11:
            if score >= 20 && score <= 40 {
                completeChallenge()
            }
        case 15:
            if score >= 50 {
                completeChallenge()
            }
        case 33:
            if score >= 60 {
                completeChallenge()
            }
        case 35:
            if score >= 40 && score <= 50 {
                completeChallenge()
            }
        case 36:
            if score >= 55 && score <= 60 {
                completeChallenge()
            }
        case 65:
            if score >= 75 {
                completeChallenge()
            }
        case 66:
            if score >= 65 {
                completeChallenge()
            }
        case 89:
            if score >= 100 {
                completeChallenge()
            }
        default:
            break
            
        }
        
    }
    
    func checkScoreChallengesNight() {
        
        switch dailyChallengeCurrent {
        case 45:
            if score >= 20 {
                completeChallenge()
            }
        case 46:
            if score >= 40 {
                completeChallenge()
            }
        case 48:
            if score >= 10 && score <= 20 {
                completeChallenge()
            }
        case 49:
            if score >= 20 && score <= 40 {
                completeChallenge()
            }
        case 50:
            if score >= 50 {
                completeChallenge()
            }
        case 57:
            if score >= 60 {
                completeChallenge()
            }
        case 58:
            if score >= 40 && score <= 50 {
                completeChallenge()
            }
        case 59:
            if score >= 55 && score <= 60 {
                completeChallenge()
            }
        case 87:
            if score >= 75 {
                completeChallenge()
            }
        case 88:
            if score >= 65 {
                completeChallenge()
            }
        default:
            break
        }
        
    }
    
    func checkScoreChallengesDawn() {
        //print("checking score challenges dawn")
        switch dailyChallengeCurrent {
            
        case 68:
            if score >= 40 {
                completeChallenge()
            }
        case 70:
            if score == 15 {
                completeChallenge()
            }
        case 71:
            if score >= 20 && score <= 40 {
                completeChallenge()
            }
        case 72:
            if score >= 45 {
                completeChallenge()
            }
        case 79:
            if score >= 50 {
                completeChallenge()
            }
        case 80:
            if score >= 40 && score <= 50 {
                completeChallenge()
            }
        case 81:
            if score >= 50 && score <= 55 {
                completeChallenge()
            }
        case 91:
            if score >= 20 {
                print("completing challenge")
                completeChallenge()
            }
        default:
            break
        }
    }
    
    func checkTapChallenges() {
        
        switch dailyChallengeCurrent {
        case 18:
            if numTaps >= 100 {
                completeChallenge()
            }
        case 25:
            if numTaps >= 30 && numTaps <= 40 {
                completeChallenge()
            }
        case 43:
            if numTaps >= 50 && numTaps <= 60 {
                completeChallenge()
            }
        case 63:
            if numTaps >= 60 && numTaps <= 70 {
                completeChallenge()
            }
        case 85:
            if numTaps >= 90 && numTaps <= 100 {
                completeChallenge()
            }
        default:
            break
        }
        
    }
    
    func checkTotalScoreChallenges() {
        
        switch dailyChallengeCurrent {
        case 21:
            if dailyPointsScored >= 200 {
                completeChallenge()
            }
        case 22:
            if dailyPointsScored >= 400 {
                completeChallenge()
            }
        case 34:
            if Double(dailyPointsScored) * 0.7 >= 300 {
                completeChallenge()
            }
        case 39:
            if Double(dailyPointsScored) * 0.7 >= 180 {
                completeChallenge()
            }
        case 40:
            if Double(dailyPointsScored) * 0.7 >= 420 {
                completeChallenge()
            }
        default:
            break
        }
        
    }
    
    func checkTotalScoreChallengesDusk() {
        
        switch dailyChallengeCurrent {
        case 23:
            if dailyPointsScoredDusk >= 250 {
                completeChallenge()
            }
        case 24:
            if dailyPointsScoredDusk >= 350 {
                completeChallenge()
            }
        default:
            break
        }
        
    }
    
    func checkTotalScoreChallengesNight() {
        
        switch dailyChallengeCurrent {
        case 52:
            if dailyPointsScoredNight >= 250 {
                completeChallenge()
            }
        case 53:
            if dailyPointsScoredNight >= 350 {
                completeChallenge()
            }
        default:
            break
        }
        
    }
    
    func checkTotalScoreChallengesDawn() {
        switch dailyChallengeCurrent {
        case 74:
            if dailyPointsScoredDawn >= 200 {
                completeChallenge()
            }
        case 75:
            if dailyPointsScoredDawn >= 300 {
                completeChallenge()
            }
        default:
            break
        }
    }
    
    func checkGamesPlayedChallenges() {
        switch dailyChallengeCurrent {
        case 3:
            if dailyGamesPlayedDusk == 5 {
                completeChallenge()
            }
        case 4:
            if dailyGamesPlayed == 5 {
                completeChallenge()
            }
        case 27:
            if dailyGamesPlayed == 10 {
                completeChallenge()
            }
        case 30:
            if dailyGamesPlayedDusk == 10 {
                completeChallenge()
            }
        case 37:
            if dailyGamesPlayedDusk == 15 {
                completeChallenge()
            }
        case 47:
            if dailyGamesPlayedNight == 5 {
                completeChallenge()
            }
        case 55:
            if dailyGamesPlayedNight == 10 {
                completeChallenge()
            }
        case 60:
            if dailyGamesPlayedNight == 15 {
                completeChallenge()
            }
        case 69:
            if dailyGamesPlayedDawn == 5 {
                completeChallenge()
            }
        case 77:
            if dailyGamesPlayedDawn == 10 {
                completeChallenge()
            }
        case 82:
            if dailyGamesPlayedDawn == 15 {
                completeChallenge()
            }
        default:
            break
            
        }
    }
    
    //MARK: IN APP PURCHASE
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
        
        lockedText1.run(SKAction.fadeOut(withDuration: 0.4))
        lockedText2.run(SKAction.fadeOut(withDuration: 0.4))
        lock.run(SKAction.fadeOut(withDuration: 0.4))
        unlockNightButton.run(SKAction.fadeOut(withDuration: 0.2))
        priceDisplay.run(SKAction.fadeOut(withDuration: 0.2))

        
        unlockDawnButton = SKButton(buttonImage: "unlockNowDawn", buttonAction: unlockDawn)
        unlockDawnButton.position = CGPoint(x: self.size.width/2, y: center.y + (radius/2.3))
        unlockDawnButton.alpha = 0
        unlockDawnButton.zPosition = 17
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            unlockDawnButton.setScale(1.5)
        default:
            break
        }
        self.addChild(unlockDawnButton)

        
        let alert = UIAlertController(title: "Success", message: "Level 2: Night unlocked.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
        }))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func unlockDawnNow() {
        dawnUnlocked = true
        GameData.sharedInstance.level3Unlocked = true
        GameData.sharedInstance.save()
        
        lockedText1.run(SKAction.fadeOut(withDuration: 0.4))
        lockedText2.run(SKAction.fadeOut(withDuration: 0.4))
        lock.run(SKAction.fadeOut(withDuration: 0.4))
        unlockDawnButton.run(SKAction.fadeOut(withDuration: 0.2))
        priceDisplay.run(SKAction.fadeOut(withDuration: 0.2))

        
        let alert = UIAlertController(title: "Success", message: "Level 3: Dawn unlocked.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) in
        }))
        self.view?.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        let myProduct = response.products
        for product in myProduct {
            
            let productId = product.productIdentifier
            if productId == "com.quantumcat.dusk.unlockDawn" {
                price = product.localizedPrice()
                //print("price is \(price)")
            }
            
            list.append(product as SKProduct)
        }
        
        iapAvailable = true
        
    }
    
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        print("add payment")
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
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
                    print("unlock level 2 night now")
                    unlockNightNow()
                    queue.finishTransaction(trans)
                case "com.quantumcat.dusk.unlockDawn":
                    print("unlock level 3 night now")
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
            switch prodId {
            case "com.quantumcat.dusk.removeAds":
                print("removing ads")
                remove()
                queue.finishTransaction(transaction)
            case "com.quantumcat.dusk.unlockNight":
                print("unlock level 2 night now")
                unlockNightNow()
                queue.finishTransaction(transaction)
            case "com.quantumcat.dusk.unlockDawn":
                print("unlock level 3 night now")
                unlockDawnNow()
                queue.finishTransaction(transaction)
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



