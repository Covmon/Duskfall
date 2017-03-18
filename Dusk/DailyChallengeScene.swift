//
//  DailyChallengeScene.swift
//  Dusk
//
//  Created by Noah Covey on 7/2/16.
//  Copyright © 2016 Quantum Cat Games. All rights reserved.
//

import SpriteKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DailyChallengeScene: SKScene {
    
    var backButton: SKButton!
    var title: SKLabelNode!
    var coinIcon: SKSpriteNode!
    var coinDisplay: SKLabelNode!
    var headerText: SKMultilineLabel!
    var challengeText: SKMultilineLabel!
    var rewardText: SKLabelNode!
    var rewardCoinIcon: SKSpriteNode!
    var line: SKSpriteNode!
    
    var newCoinsIcon: SKSpriteNode!
    var newCoinsDisplay: SKLabelNode!
    
    var collectRewardButton: SKButton!
    
    var justCollected = false
    
    var progressBarOutline: SKShapeNode!
    var progressBarFill: SKShapeNode!
    var progressText: SKLabelNode!
    
    var progressComplete: CGFloat!
    var progressTotalNeeded: CGFloat!
    var progressMaximum: Double = Double.infinity
    
    var dailyChallengeWords: String = ""
    var dailyChallengeRewardAmount: Int = 0
    
    override func didMove(to view: SKView) {
        
        lastScene = "dailyChallenge"
        hasSeenChallenge = true
        
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
        
        var fillColor: UIColor
        
        if currentLevel == 1 {
            self.backgroundColor = UIColor(red: 248/255, green: 177/255, blue: 149/255, alpha: 1)
           fillColor = UIColor(red: 192/255, green: 108/255, blue: 132/255, alpha: 1)
        } else if currentLevel == 2 {
            self.backgroundColor = UIColor(red: 53/255, green: 92/255, blue: 125/255, alpha: 1)
           fillColor = UIColor(red: 13/255, green: 33/255, blue: 71/255, alpha: 1)
        } else if currentLevel == 3 {
            self.backgroundColor = UIColor(red: 102/255, green: 205/255, blue: 212/255, alpha: 1)
           fillColor = UIColor(red: 24/255, green: 200/255, blue: 165/255, alpha: 1)
        } else {
           fillColor = UIColor.blue
        }
        
        let gradient = SKSpriteNode(imageNamed: gradName)
        gradient.size = self.size
        gradient.anchorPoint = CGPoint(x: 0.5, y: 0)
        gradient.position = CGPoint(x: self.size.width/2, y: 0)
        gradient.zPosition = -100
        self.addChild(gradient)

        
        //MARK: BUTTON ACTIONS
        func goBack() -> Void {
            presentGame()
        }
        
        func collectReward() -> Void {
            if dailyChallengeCompleted {
                
                justCollected = true
                
                gems += dailyChallengeRewardAmount
                GameData.sharedInstance.gems = gems
                
                func updateLabel(_ node: SKNode!, t: CGFloat) {
                    
                    let coinToAdd = ceil(Double(dailyChallengeRewardAmount) * Double(t)) + Double(gems - dailyChallengeRewardAmount)
                    coinDisplay.text = "\(Int(coinToAdd))"
                }
                
                self.run(SKAction.customAction(withDuration: 1, actionBlock: updateLabel))
                
                let coinBig = SKAction.scale(by: 1.2, duration: 0.1)
                let coinSmall = SKAction.scale(by: 1/1.2, duration: 0.1)
                
                let coinPulse = SKAction.repeat(SKAction.sequence([coinBig, coinSmall]), count: 5)
                coinIcon.run(coinPulse)
                coinDisplay.run(coinPulse)
                
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
                
                newCoinsDisplay = text("+\(dailyChallengeRewardAmount)", fontSize: self.size.width/15, fontName: "Roboto-Light", fontColor: SKColor.white)
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
                
                let explosion = SKEmitterNode(fileNamed: "CoinExplosion.sks")
                explosion?.position = collectRewardButton.position
                explosion?.zPosition = 19
                self.addChild(explosion!)
                let wait = SKAction.wait(forDuration: 2.8)
                explosion?.run(SKAction.sequence([wait, SKAction.removeFromParent()]))
                
                rewardAlreadyCollected = true
                GameData.sharedInstance.rewardAlreadyCollected = true
                
                GameData.sharedInstance.save()
                
                challengeText.text = "Reward collected! Come back tomorrow for a new challenge."
                
                self.run(SKAction.playSoundFileNamed("FreeGiftSound.aif", waitForCompletion: false))
                
                collectRewardButton.run(SKAction.fadeOut(withDuration: 0.3))
                //collectRewardButton.removeFromParent()
                
                rewardText.run(SKAction.fadeOut(withDuration: 0.3))
                //rewardText.removeFromParent()
                rewardCoinIcon.run(SKAction.fadeOut(withDuration: 0.3))
                
                progressBarFill.run(SKAction.fadeOut(withDuration: 0.3))
                progressBarOutline.run(SKAction.fadeOut(withDuration: 0.3))
                progressText.run(SKAction.fadeOut(withDuration: 0.3))
                //rewardCoinIcon.removeFromParent()
                
            } else {
                presentGame()
            }
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
        title = text("DAILY CHALLENGE", fontSize: self.size.width/7, fontName: "DolceVitaLight", fontColor: SKColor.white)
        title.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.83)
        title.alpha = 0
        title.zPosition = 6
        title.verticalAlignmentMode = .center
        self.addChild(title)
        title.run(SKAction.fadeAlpha(to: 1, duration: 0.5))
        
        let fadeIn = SKAction.fadeAlpha(to: 1, duration: 0.8)
        
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
        
        //MARK: CHALLENGE HEADER
        headerText = SKMultilineLabel(text: "Come back every 24H to get a new daily challenge!", labelWidth: self.size.width * 0.7, pos: CGPoint(x: self.size.width/2, y: self.size.height * 0.75), fontName: "Roboto-Light", fontSize: self.size.width/20, fontColor: SKColor.white, leading: self.size.width/20, alignment: SKLabelHorizontalAlignmentMode.center, shouldShowBorder: false)
        headerText.alpha = 0
        self.addChild(headerText)
        headerText.run(fadeIn)
        
        line = SKSpriteNode(color: SKColor.white, size: CGSize(width: self.size.width * 0.8, height: 1))
        line.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.64)
        line.alpha = 0
        self.addChild(line)
        line.run(fadeIn)
        
        //MARK: MARK: DETERMINE TEXT OF DAILY CHALLENGE
        
        let numScoresDusk = lastScoresDusk.count
        let numScoresNight = lastScoresNight.count
        let numScoresDawn = lastScoresDawn.count
        let numScores = lastScores.count
        
        enum challengeType {
            case scoreAtLeast
            case playGames
            case scoreBetween
            case scoreStreak
            case scoreMultipleTimes
            case totalScore
            case unlockCharacter
            case collectGift
            case getHighScore
            case getDailyBest
            case changeDirection
            case changeDirectionBetween
            case playMinutes
        }
        
        func determineDailyChallenge(_ type: challengeType, numberRequired: Int, numberMaximum: Int = 0, onLevel: Int, reward: Int, numberOnEachStreak: Int = 0) {
            
            var levelName: String
            var playGamesString: String
            var scoreInQuestion: Int
            var gamesPlayedInQuestion: Int
            var lastScoresInQuestion: [Int]
            var numScoresInQuestion: Int
            var numberRequiredString: String
            var streakLevelName: String
            var pointsScoredInQuestion: Int
            
            switch onLevel {
            case 1:
                levelName = "Level 1: Dusk"
                scoreInQuestion = lastDusk
                playGamesString = "on Level 1: Dusk"
                gamesPlayedInQuestion = dailyGamesPlayedDusk
                lastScoresInQuestion = lastScoresDusk
                numScoresInQuestion = numScoresDusk
                streakLevelName = " on Level 1: Dusk"
                pointsScoredInQuestion = dailyPointsScoredDusk
            case 2:
                levelName = "Level 2: Night"
                scoreInQuestion = lastNight
                playGamesString = "on Level 2: Night"
                gamesPlayedInQuestion = dailyGamesPlayedNight
                lastScoresInQuestion = lastScoresNight
                numScoresInQuestion = numScoresNight
                streakLevelName = " on Level 2: Night"
                pointsScoredInQuestion = dailyPointsScoredNight

            case 3:
                levelName = "Level 3: Dawn"
                scoreInQuestion = lastDawn
                playGamesString = "on Level 3: Dawn"
                gamesPlayedInQuestion = dailyGamesPlayedDawn
                lastScoresInQuestion = lastScoresDawn
                numScoresInQuestion = numScoresDawn
                streakLevelName = " on Level 3: Dawn"
                pointsScoredInQuestion = dailyPointsScoredDawn

            default:
                levelName = "any level"
                scoreInQuestion = score
                playGamesString = "total"
                gamesPlayedInQuestion = dailyGamesPlayed
                lastScoresInQuestion = lastScores
                numScoresInQuestion = numScores
                streakLevelName = ""
                pointsScoredInQuestion = dailyPointsScored

            }
            
            switch numberRequired {
            case 2:
                numberRequiredString = "twice"
            case 3:
                numberRequiredString = "three times"
            case 4:
                numberRequiredString = "four times"
            case 5:
                numberRequiredString = "five times"
            default:
                numberRequiredString = "too many times"
            }
            
            dailyChallengeRewardAmount = reward
            progressTotalNeeded = CGFloat(numberRequired)
            if numberMaximum != 0 {
                progressMaximum = Double(numberMaximum)
            }
            
            switch type {
                
            case .scoreAtLeast:
                dailyChallengeWords = "Score at least \(numberRequired) on \(levelName)."
                progressComplete = CGFloat(scoreInQuestion)
            case .playGames:
                dailyChallengeWords = "Play \(numberRequired) games \(playGamesString)."
                progressComplete = CGFloat(gamesPlayedInQuestion)
            case .scoreBetween:
                dailyChallengeWords = "Score between \(numberRequired) and \(numberMaximum) points on \(levelName)."
                if numberRequired == numberMaximum {
                    dailyChallengeWords = "Score exactly \(numberRequired) points on \(levelName)."
                }
                progressComplete = CGFloat(scoreInQuestion)
            case .scoreStreak:
                dailyChallengeWords = "Score at least \(numberOnEachStreak) \(numberRequiredString) in a row\(streakLevelName)."
                
                if numberRequired == 3 {
                    
                    if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 2] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 3] >= numberOnEachStreak {
                        progressComplete = 3
                    } else if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 2] >= numberOnEachStreak {
                        progressComplete = 2
                    } else if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak {
                        progressComplete = 1
                    } else {
                        progressComplete = 0
                    }

                    
                } else if numberRequired == 2 {
                    
                    if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 2] >= numberOnEachStreak {
                        progressComplete = 2
                    } else if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak {
                        progressComplete = 1
                    } else {
                        progressComplete = 0
                    }
                } else if numberRequired == 4 {
                    
                    if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 2] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 3] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 4] >= numberOnEachStreak {
                        progressComplete = 4
                    } else if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 2] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 3] >= numberOnEachStreak {
                        progressComplete = 3
                    } else if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak && lastScoresInQuestion[numScoresInQuestion - 2] >= numberOnEachStreak {
                        progressComplete = 2
                    } else if lastScoresInQuestion[numScoresInQuestion - 1] >= numberOnEachStreak {
                        progressComplete = 1
                    } else {
                        progressComplete = 0
                    }
                    
                }
                
            case .scoreMultipleTimes:
                dailyChallengeWords = "Score at least \(numberOnEachStreak) \(numberRequiredString)\(streakLevelName)."
                var numAch = 0
                for score in lastScoresInQuestion {
                    if score >= numberOnEachStreak && numAch < numberRequired {
                        numAch += 1
                    }
                }
                progressComplete = CGFloat(numAch)
            case .totalScore:
                dailyChallengeWords = "Score \(numberRequired) points total\(streakLevelName)."
                progressComplete = CGFloat(pointsScoredInQuestion)
            case .unlockCharacter:
                switch numberRequired {
                case 0:
                    dailyChallengeWords = "Unlock any character in the shop."
                case 3000:
                    dailyChallengeWords = "Unlock a character that costs 3000 gems or more."
                case 5000:
                    dailyChallengeWords = "Unlock a character that costs 5000 gems."
                default:
                    dailyChallengeWords = "Unlock a character that costs some wrong number of gems."
                }
                if dailyChallengeCompleted {
                    progressComplete = 1
                } else {
                    progressComplete = 0
                }
                progressTotalNeeded = 1
            case .collectGift:
                dailyChallengeWords = "Collect a free gift."
                if dailyChallengeCompleted {
                    progressComplete = 1
                }
            case .getHighScore:
                dailyChallengeWords = "Get a new high score on \(levelName)."
                progressComplete = CGFloat(scoreInQuestion)
                if onLevel == 1 {
                    progressTotalNeeded = CGFloat(highScore + 1)
                } else if onLevel == 2 {
                    progressTotalNeeded = CGFloat(highScoreNight + 1)
                } else if onLevel == 3 {
                    progressTotalNeeded = CGFloat(highScoreDawn + 1)
                }
            case .getDailyBest:
                dailyChallengeWords = "Beat your daily best on any level."
                progressComplete = CGFloat(scoreInQuestion)
                if onLevel == 1 {
                    progressTotalNeeded = CGFloat(dailyBestDusk)
                } else if onLevel == 2 {
                    progressTotalNeeded = CGFloat(dailyBestNight)
                } else if onLevel == 3 {
                    progressTotalNeeded = CGFloat(dailyBestDawn)
                }
            case .changeDirection:
                dailyChallengeWords = "Change your circle's direction at least \(numberRequired) times in one game."
                progressComplete = CGFloat(numTaps)
            case .changeDirectionBetween:
                dailyChallengeWords = "Change your circle's direction between \(numberRequired) and \(numberMaximum) times in one game."
                progressComplete = CGFloat(numTaps)
            case .playMinutes:
                dailyChallengeWords = "Play for a total of \(numberRequired) minutes."
                let seconds:Double = Double(dailyPointsScored) * 0.7
                progressComplete = CGFloat(floor(seconds/Double(numberRequired * 60) * Double(numberRequired)))
            }
            
        }

        
        
        switch dailyChallengeCurrent {
        case 0:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 4, onLevel: 1, reward: 300, numberOnEachStreak: 40)
        case 1:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 20, onLevel: 1, reward: 100)
        case 2:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 40, onLevel: 1, reward: 150)
        case 3:
            determineDailyChallenge(.playGames, numberRequired: 5, onLevel: 1, reward: 100)
        case 4:
            determineDailyChallenge(.playGames, numberRequired: 5, onLevel: 0, reward: 100)
        case 5:
            determineDailyChallenge(.scoreBetween, numberRequired: 5, numberMaximum: 10, onLevel: 1, reward: 150)
        case 6:
            determineDailyChallenge(.scoreStreak, numberRequired: 3, onLevel: 0, reward: 300, numberOnEachStreak: 30)
        case 7:
            determineDailyChallenge(.unlockCharacter, numberRequired: 0, onLevel: 0, reward: 400)
        case 8:
            determineDailyChallenge(.unlockCharacter, numberRequired: 3000, onLevel: 0, reward: 600)
        case 9:
            determineDailyChallenge(.unlockCharacter, numberRequired: 5000, onLevel: 0, reward: 1000)
        case 10:
            determineDailyChallenge(.collectGift, numberRequired: 1, onLevel: 0, reward: 100)
        case 11:
            determineDailyChallenge(.scoreBetween, numberRequired: 20, numberMaximum: 40, onLevel: 1, reward: 150)
        case 12:
            determineDailyChallenge(.getHighScore, numberRequired: 1, onLevel: 0, reward: 200)
        case 13:
            determineDailyChallenge(.getDailyBest, numberRequired: 1, onLevel: 0, reward: 150)
        case 14:
            determineDailyChallenge(.unlockCharacter, numberRequired: 0, onLevel: 0, reward: 400)
        case 15:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 50, onLevel: 1, reward: 200)
        case 16:
            determineDailyChallenge(.scoreStreak, numberRequired: 3, onLevel: 1, reward: 300, numberOnEachStreak: 35)
        case 17:
            determineDailyChallenge(.scoreStreak, numberRequired: 2, onLevel: 0, reward: 300, numberOnEachStreak: 40)
        case 18:
            determineDailyChallenge(.changeDirection, numberRequired: 100, onLevel: 0, reward: 150)
        case 19:
            determineDailyChallenge(.scoreBetween, numberRequired: 42, numberMaximum: 42, onLevel: 0, reward: 200)
        case 20:
            determineDailyChallenge(.scoreBetween, numberRequired: 40, numberMaximum: 60, onLevel: 0, reward: 150)
        case 21:
            determineDailyChallenge(.totalScore, numberRequired: 200, onLevel: 0, reward: 150)
        case 22:
            determineDailyChallenge(.totalScore, numberRequired: 400, onLevel: 0, reward: 350)
        case 23:
            determineDailyChallenge(.totalScore, numberRequired: 250, onLevel: 1, reward: 200)
        case 24:
            determineDailyChallenge(.totalScore, numberRequired: 350, onLevel: 1, reward: 350)
        case 25:
            determineDailyChallenge(.changeDirectionBetween, numberRequired: 30, numberMaximum: 40, onLevel: 0, reward: 100)
        case 26:
            determineDailyChallenge(.unlockCharacter, numberRequired: 3000, onLevel: 0, reward: 600)
        case 27:
            determineDailyChallenge(.playGames, numberRequired: 10, onLevel: 0, reward: 300)
        case 28:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 60, onLevel: 0, reward: 300)
        case 29:
            determineDailyChallenge(.scoreStreak, numberRequired: 3, onLevel: 1, reward: 400, numberOnEachStreak: 40)
        case 30:
            determineDailyChallenge(.playGames, numberRequired: 10, onLevel: 1, reward: 300)
        case 31:
            determineDailyChallenge(.getHighScore, numberRequired: 1, onLevel: 1, reward: 200)
        case 32:
            determineDailyChallenge(.scoreStreak, numberRequired: 4, onLevel: 0, reward: 300, numberOnEachStreak: 25)
        case 33:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 60, onLevel: 1, reward: 300)
        case 34:
            determineDailyChallenge(.playMinutes, numberRequired: 5, onLevel: 0, reward: 350)
        case 35:
            determineDailyChallenge(.scoreBetween, numberRequired: 40, numberMaximum: 50, onLevel: 1, reward: 250)
        case 36:
            determineDailyChallenge(.scoreBetween, numberRequired: 55, numberMaximum: 60, onLevel: 1, reward: 350)
        case 37:
            determineDailyChallenge(.playGames, numberRequired: 15, onLevel: 1, reward: 450)
        case 38:
            determineDailyChallenge(.scoreStreak, numberRequired: 2, onLevel: 1, reward: 350, numberOnEachStreak: 50)
        case 39:
            determineDailyChallenge(.playMinutes, numberRequired: 3, onLevel: 0, reward: 250)
        case 40:
            determineDailyChallenge(.playMinutes, numberRequired: 7, onLevel: 0, reward: 550)
        case 41:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 3, onLevel: 1, reward: 300, numberOnEachStreak: 40)
        case 42:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 5, onLevel: 0, reward: 250, numberOnEachStreak: 30)
        case 43:
            determineDailyChallenge(.changeDirectionBetween, numberRequired: 50, numberMaximum: 60, onLevel: 0, reward: 150)
        case 44:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 2, onLevel: 1, reward: 250, numberOnEachStreak: 50)
        case 45:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 20, onLevel: 2, reward: 150)
        case 46:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 40, onLevel: 2, reward: 200)
        case 47:
            determineDailyChallenge(.playGames, numberRequired: 5, onLevel: 2, reward: 150)
        case 48:
            determineDailyChallenge(.scoreBetween, numberRequired: 10, numberMaximum: 20, onLevel: 2, reward: 100)
        case 49:
            determineDailyChallenge(.scoreBetween, numberRequired: 20, numberMaximum: 40, onLevel: 2, reward: 150)
        case 50:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 50, onLevel: 2, reward: 300)
        case 51:
            determineDailyChallenge(.scoreStreak, numberRequired: 3, onLevel: 2, reward: 400, numberOnEachStreak: 35)
        case 52:
            determineDailyChallenge(.totalScore, numberRequired: 250, onLevel: 2, reward: 300)
        case 53:
            determineDailyChallenge(.totalScore, numberRequired: 350, onLevel: 2, reward: 400)
        case 54:
            determineDailyChallenge(.scoreStreak, numberRequired: 3, onLevel: 2, reward: 550, numberOnEachStreak: 40)
        case 55:
            determineDailyChallenge(.playGames, numberRequired: 10, onLevel: 2, reward: 350)
        case 56:
            determineDailyChallenge(.getHighScore, numberRequired: 1, onLevel: 2, reward: 300)
        case 57:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 60, onLevel: 2, reward: 450)
        case 58:
            determineDailyChallenge(.scoreBetween, numberRequired: 40, numberMaximum: 50, onLevel: 2, reward: 350)
        case 59:
            determineDailyChallenge(.scoreBetween, numberRequired: 55, numberMaximum: 60, onLevel: 2, reward: 500)
        case 60:
            determineDailyChallenge(.playGames, numberRequired: 15, onLevel: 2, reward: 500)
        case 61:
            determineDailyChallenge(.scoreStreak, numberRequired: 2, onLevel: 2, reward: 550, numberOnEachStreak: 50)
        case 62:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 3, onLevel: 2, reward: 400, numberOnEachStreak: 40)
        case 63:
            determineDailyChallenge(.changeDirectionBetween, numberRequired: 60, numberMaximum: 70, onLevel: 0, reward: 200)
        case 64:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 2, onLevel: 2, reward: 350, numberOnEachStreak: 50)
        case 65:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 75, onLevel: 1, reward: 450)
        case 66:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 65, onLevel: 1, reward: 400)
        case 67:
            determineDailyChallenge(.unlockCharacter, numberRequired: 5000, onLevel: 0, reward: 400)
        case 68:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 40, onLevel: 3, reward: 250)
        case 69:
            determineDailyChallenge(.playGames, numberRequired: 5, onLevel: 3, reward: 200)
        case 70:
            determineDailyChallenge(.scoreBetween, numberRequired: 15, numberMaximum: 15, onLevel: 3, reward: 200)
        case 71:
            determineDailyChallenge(.scoreBetween, numberRequired: 20, numberMaximum: 40, onLevel: 3, reward: 200)
        case 72:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 45, onLevel: 3, reward: 500)
        case 73:
            determineDailyChallenge(.scoreStreak, numberRequired: 3, onLevel: 3, reward: 450, numberOnEachStreak: 35)
        case 74:
            determineDailyChallenge(.totalScore, numberRequired: 200, onLevel: 3, reward: 350)
        case 75:
            determineDailyChallenge(.totalScore, numberRequired: 300, onLevel: 3, reward: 450)
        case 76:
            determineDailyChallenge(.scoreStreak, numberRequired: 3, onLevel: 3, reward: 600, numberOnEachStreak: 40)
        case 77:
            determineDailyChallenge(.playGames, numberRequired: 10, onLevel: 3, reward: 400)
        case 78:
            determineDailyChallenge(.getHighScore, numberRequired: 1, onLevel: 3, reward: 350)
        case 79:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 50, onLevel: 3, reward: 700)
        case 80:
            determineDailyChallenge(.scoreBetween, numberRequired: 40, numberMaximum: 50, onLevel: 3, reward: 400)
        case 81:
            determineDailyChallenge(.scoreBetween, numberRequired: 50, numberMaximum: 55, onLevel: 3, reward: 550)
        case 82:
            determineDailyChallenge(.playGames, numberRequired: 15, onLevel: 3, reward: 550)
        case 83:
            determineDailyChallenge(.scoreStreak, numberRequired: 2, onLevel: 3, reward: 600, numberOnEachStreak: 45)
        case 84:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 3, onLevel: 3, reward: 450, numberOnEachStreak: 40)
        case 85:
            determineDailyChallenge(.changeDirectionBetween, numberRequired: 90, numberMaximum: 100, onLevel: 0, reward: 250)
        case 86:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 2, onLevel: 3, reward: 400, numberOnEachStreak: 50)
        case 87:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 75, onLevel: 2, reward: 600)
        case 88:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 65, onLevel: 2, reward: 500)
        case 89:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 100, onLevel: 1, reward: 500)
        case 90:
            determineDailyChallenge(.unlockCharacter, numberRequired: 5000, onLevel: 0, reward: 1000)
        case 91:
            determineDailyChallenge(.scoreAtLeast, numberRequired: 20, onLevel: 3, reward: 200)
        case 92:
            determineDailyChallenge(.scoreMultipleTimes, numberRequired: 4, onLevel: 3, reward: 400, numberOnEachStreak: 30)
        default:
            dailyChallengeWords = "No challenge available."
            dailyChallengeRewardAmount = 0
            progressComplete = 0
            progressTotalNeeded = 1
            print("challenge not available")
        }
        
        //MARK: CHALLENGE TEXT
        
        var challengeTextWords: String
        if dailyChallengeCompleted && !rewardAlreadyCollected {
            challengeTextWords = "Challenge completed: \(dailyChallengeWords) Collect your reward now."
        } else if rewardAlreadyCollected {
            challengeTextWords = "Challenge completed! Come back tomorrow for a new challenge."

        } else {
            challengeTextWords = "Today's Challenge: \(dailyChallengeWords)"
        }
        
        challengeText = SKMultilineLabel(text: challengeTextWords, labelWidth: self.size.width * 0.9, pos: CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.62), fontName: "Roboto-Light", fontSize: self.size.width/17, fontColor: SKColor.white, leading: self.size.width/17, alignment: .center, shouldShowBorder: false)
        challengeText.alpha = 0
        self.addChild(challengeText)
        challengeText.run(fadeIn)
        
        //MARK: PROGRESS BAR
        
        var completed = false
        var wentOver = false
        
        if (progressComplete > progressTotalNeeded && Double(progressComplete) <= progressMaximum) || dailyChallengeCompleted {
            progressComplete = progressTotalNeeded

            completed = true
        }
        if Double(progressComplete) > progressMaximum {
            wentOver = true
        }
        
        var height:CGFloat
        var width: CGFloat
        var stroke: CGFloat
        
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            height = self.size.height * 0.05
            width = 200
            stroke = 1
        case .pad:
            height = self.size.height * 0.05
            width = 400
            stroke = 2
        default:
            height = self.size.height * 0.05
            width = 200
            stroke = 1
        }
        
        progressBarOutline = SKShapeNode(rect: CGRect(x: -(width/2), y: 0, width: width, height: height), cornerRadius: 5)
        progressBarOutline.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        progressBarOutline.fillColor = SKColor.clear
        progressBarOutline.strokeColor = SKColor.white
        progressBarOutline.alpha = 0
        progressBarOutline.lineWidth = stroke
        progressBarOutline.zPosition = 10
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            progressBarOutline.position.y = self.size.height * 0.37
        default:
            break
        }
        
        self.addChild(progressBarOutline)
        if !rewardAlreadyCollected {
            progressBarOutline.run(fadeIn)
        }
        
        progressBarFill = SKShapeNode(rect: CGRect(x: 0, y: 0, width: width, height: height), cornerRadius: 5)
        progressBarFill.position = CGPoint(x: self.size.width/2 - (width/2), y: self.size.height * 0.4)
        progressBarFill.fillColor = fillColor
        progressBarFill.strokeColor = SKColor.clear
        progressBarFill.zPosition = 9
        progressBarFill.xScale = 0
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            progressBarFill.position.y = self.size.height * 0.37
        default:
            break
        }
        
        progressBarFill.alpha = 0
        self.addChild(progressBarFill)
        
        var fillNumber = progressComplete/progressTotalNeeded
        if wentOver {
            fillNumber = 0
        }

        let fill = SKAction.scaleX(to: fillNumber, duration: 0.5)
        fill.timingMode = .easeOut
        
        if !rewardAlreadyCollected && completed {
            /*
            let sound = SKAction.playSoundFileNamed("ChallengeCompleteSound.aif", waitForCompletion: false)
            let fadeOut = SKAction.runBlock({
            
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
                    let wait = SKAction.waitForDuration(0.3)
                    
                    let fade = SKAction.runBlock( { fader.fadeIn(0.3, velocity: 2) } )
                    
                    self.runAction(SKAction.sequence([wait,fade]))
                })
            
            
            })
            
            let group = SKAction.group([fadeOut, sound])*/

            progressBarFill.run(fill)
            progressBarFill.run(fadeIn)
        } else if !rewardAlreadyCollected {
            progressBarFill.run(fill)
            progressBarFill.run(fadeIn)
        }
        
        progressText = text("\(Int(progressComplete))/\(Int(progressTotalNeeded))", fontSize: self.size.width/20, fontName: "Roboto-Bold", fontColor: SKColor.white)
        progressText.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.46)
        progressText.alpha = 0
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            progressText.position.y = self.size.height * 0.43
        default:
            break
        }
        self.addChild(progressText)
        if !rewardAlreadyCollected {
            progressText.run(fadeIn)
        }
        
        
        //MARK: REWARD LABEL
        rewardText = text("Reward: \(dailyChallengeRewardAmount)", fontSize: self.size.width/13, fontName: "Roboto-Light", fontColor: SKColor.white)
        rewardText.position = CGPoint(x: self.size.width * 0.48, y: self.size.height * 0.35)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            rewardText.position.y = self.size.height * 0.33
            rewardText.fontSize = self.size.width/14
        default:
            break
        }
        rewardText.verticalAlignmentMode = .center
        rewardText.alpha = 0
        if !rewardAlreadyCollected {
            self.addChild(rewardText)
            rewardText.run(fadeIn)
        }
        
        rewardCoinIcon = SKSpriteNode(imageNamed: "coin")
        rewardCoinIcon.position = CGPoint(x: self.size.width * 0.48 + (rewardText.frame.size.width / 1.6), y: self.size.height * 0.35)
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            rewardCoinIcon.setScale(0.8)
            rewardCoinIcon.position.y = self.size.height * 0.33
        default:
            rewardCoinIcon.setScale(0.5)
        }
        rewardCoinIcon.alpha = 0
        if !rewardAlreadyCollected {
            self.addChild(rewardCoinIcon)
            rewardCoinIcon.run(fadeIn)
        }
        
        //MARK: COLLECT REWARD BUTTON
        var collectButtonName: String = ""
        
        if !dailyChallengeCompleted {
            collectButtonName = "goButton\(currentLevel)"
        }
        else {
            collectButtonName = "collectRewardButton\(currentLevel)"
        }
        collectRewardButton = SKButton(buttonImage: collectButtonName, buttonAction: collectReward)
        collectRewardButton.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.22)
        collectRewardButton.setScale(scale * 1.4)
        collectRewardButton.zPosition = 100
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            collectRewardButton.position.y = self.size.height * 0.21
            collectRewardButton.setScale(scale * 1.55)
        default:
            break
        }
        
        collectRewardButton.alpha = 0
        if !rewardAlreadyCollected {
            self.addChild(collectRewardButton)
        }
        collectRewardButton.run(SKAction.fadeAlpha(to: 0.9, duration: 0.8))
        if completed {
            let bigger = SKAction.scale(by: 1.1, duration: 0.3)
            bigger.timingMode = .easeInEaseOut
            
            let smaller = SKAction.scale(by: 1/1.1, duration: 0.5)
            smaller.timingMode = .easeInEaseOut
            
            let pulse = SKAction.repeatForever(SKAction.sequence([bigger, smaller]))
            
            collectRewardButton.run(pulse)
        }

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
            headerText.run(getRidOfUI)
            line.run(getRidOfUI)
            challengeText.run(getRidOfUI)
            progressText.run(getRidOfUI)
            progressBarOutline.run(getRidOfUI)
            progressBarFill.run(getRidOfUI)
            
            if justCollected {
                justCollected = false
                newCoinsDisplay.run(getRidOfUI)
                newCoinsIcon.run(getRidOfUI)
            }
            
            if !rewardAlreadyCollected {
                collectRewardButton.run(getRidOfUI)
                rewardCoinIcon.run(getRidOfUI)
                rewardText.run(getRidOfUI)
            }
            
            let present = SKAction.run({ skView.presentScene(scene) })
            backButton.run(SKAction.sequence([getRidOfUI, present]))
        }

    }
    
    func text(_ text: String, fontSize: CGFloat, fontName: String, fontColor: UIColor) -> SKLabelNode {
        
        let text1 = SKLabelNode(text: text)
        text1.fontSize = fontSize
        text1.fontName = fontName
        text1.fontColor = fontColor
        
        return text1
        
    }

    
}
