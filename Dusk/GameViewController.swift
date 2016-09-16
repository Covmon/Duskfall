//
//  GameViewController.swift
//  Dusk
//
//  Created by Noah Covey on 3/11/16.
//  Copyright (c) 2016 Quantum Cat Games. All rights reserved.
//

import UIKit
import SpriteKit
import AVFoundation
import GameKit


//GLOBAL VARIABLES

var volumeOn: Bool = true
var musicSilenced: Bool = false

var justLaunched: Bool = true

var tutorialNeeded: Bool = true //TODO: CHANGE TO TRUE
var swipeTutorialNeeded: Bool = false
var level3TutorialNeeded: Bool = false

var highScore: Int = 0
var highScoreNight: Int = 0
var highScoreDawn: Int = 0
var totalPoints: Int = 0
var totalGamesPlayed: Int = 0

var dailyBestDusk: Int = 0
var dailyBestNight: Int = 0
var dailyBestDawn: Int = 0
var dailyBestDate: Date = Date()

var rewardAlreadyCollected: Bool = false
var dailyChallengeCompleted: Bool = false
var dailyChallengeCurrent: Int = 1

let numChallengesDusk = 45
let numChallengesNight = 23
let numChallengesDawn = 25

var dailyGamesPlayed: Int = 0
var dailyGamesPlayedDusk: Int = 0
var dailyGamesPlayedNight: Int = 0
var dailyGamesPlayedDawn: Int = 0

var dailyPointsScored: Int = 0
var dailyPointsScoredDusk: Int = 0
var dailyPointsScoredNight: Int = 0
var dailyPointsScoredDawn: Int = 0

var lastScoresDusk: [Int] = [0, 0, 0, 0]
var lastScoresNight: [Int] = [0, 0, 0, 0]
var lastScoresDawn: [Int] = [0, 0, 0, 0]
var lastScores: [Int] = [0, 0, 0, 0]

var dailyBestAchievedDusk: Bool = false
var dailyBestAchievedNight: Bool = false
var dailyBestAchievedDawn: Bool = false

var hasDayPassed: Bool = false
var hasSeenChallenge: Bool = false

var nightUnlocked: Bool = true //TODO: CHANGE TO FALSE
var dawnUnlocked: Bool = true

var gems: Int = 500

var hasRemovedAds: Bool = false

var giftAvailable: Bool = false
var giftDate: Date = Date()
var hasChosenNotifications: Bool = false
var allowsNotifications: Bool = true

var currentLevel = 1

var gameCenterEnabled: Bool = true

var character: String = "player"
var numUnlockedCharacters = 0
var unlockedCharacters: [String] = ["player"]
var allCharacters: [String] = ["player", "face", /* cost 1,000 -> */ "peace", "sun", "vampire","coin", "angry", "clock", "tire", "heart", "infinity", "microphone", "bee", "cat",/* cost 3,000 -> */ "penguin","candy", "baseball", "basketball", "eye", "alien", "bowling", "pizza", "disco", "yingYang", "volleyball", "panda","soccer", "stars", "lifesaver", "compass",  "paw", "pirate",/* cost 5,000 -> */ "flyingSaucer", "dna", "snowflake", "planetA", "atom", "rocket", "donut", "8ball", "earth","planetB", "nuke", "moon", "pi", "driving", "planetC", "skull", "fist", "lightning", "robot", "globe", "pacman", "owl"]
let num1000Characters = 12
let num3000Characters = 18
let num5000Characters = 22

var justOpenedApp = true
var lastScene = "game"

class GameViewController: UIViewController, GKGameCenterControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("number of characters is \(allCharacters.count)")
        
        volumeOn = GameData.sharedInstance.volumeOn
        musicSilenced = AVAudioSession.sharedInstance().secondaryAudioShouldBeSilencedHint
        do {
            try AVAudioSession.sharedInstance().setCategory("AVAudioSessionCategoryAmbient")
        } catch {
            print(error)
        }
        print("music silenced is \(musicSilenced)")
        
        tutorialNeeded = GameData.sharedInstance.tutorialNeeded //TODO: CHANGE TO TRUE

        highScore = GameData.sharedInstance.highScoreDusk

        highScoreNight = GameData.sharedInstance.highScoreNight

        highScoreDawn = GameData.sharedInstance.highScoreDawn
        
        totalGamesPlayed = GameData.sharedInstance.totalGamesPlayed
        
        totalPoints = GameData.sharedInstance.totalPoints
        
        hasRemovedAds = GameData.sharedInstance.hasRemovedAds
        
        nightUnlocked = GameData.sharedInstance.level2Unlocked //TODO: CHANGE TO FALSE
        dawnUnlocked = GameData.sharedInstance.level3Unlocked
        
        lastScores = GameData.sharedInstance.lastScores
        lastScoresDusk = GameData.sharedInstance.lastScoresDusk
        lastScoresNight = GameData.sharedInstance.lastScoresNight
        lastScoresDawn = GameData.sharedInstance.lastScoresDawn
        
        dailyBestDusk = GameData.sharedInstance.dailyBestDusk
        dailyBestNight = GameData.sharedInstance.dailyBestNight
        dailyBestDawn = GameData.sharedInstance.dailyBestDawn
        dailyBestDate = GameData.sharedInstance.dailyBestDate as Date
        
        dailyGamesPlayed = GameData.sharedInstance.dailyGamesPlayed
        dailyGamesPlayedDusk = GameData.sharedInstance.dailyGamesPlayedDusk
        dailyGamesPlayedNight = GameData.sharedInstance.dailyGamesPlayedNight
        dailyGamesPlayedDawn = GameData.sharedInstance.dailyGamesPlayedDawn

        dailyPointsScored = GameData.sharedInstance.dailyPointsScored
        dailyPointsScoredDusk = GameData.sharedInstance.dailyPointsScoredDusk
        dailyPointsScoredDawn = GameData.sharedInstance.dailyPointsScoredDawn
        dailyPointsScoredNight = GameData.sharedInstance.dailyPointsScoredNight
        
        dailyChallengeCompleted = GameData.sharedInstance.dailyChallengeCompleted
        rewardAlreadyCollected = GameData.sharedInstance.rewardAlreadyCollected
        dailyChallengeCurrent = GameData.sharedInstance.dailyChallengeCurrent
        
        gems = GameData.sharedInstance.gems
        
        character = GameData.sharedInstance.currentCharacter
        unlockedCharacters = GameData.sharedInstance.unlockedCharacters
        numUnlockedCharacters = unlockedCharacters.count
        
        hasChosenNotifications = GameData.sharedInstance.hasChosenNotifications
        giftDate = GameData.sharedInstance.giftDate as Date
        print("saved giftdate is \(GameData.sharedInstance.giftDate)")
        allowsNotifications = GameData.sharedInstance.allowsNotifications
        
        if hasChosenNotifications {
            let settings: UIUserNotificationSettings = UIApplication.shared.currentUserNotificationSettings!
            if settings.types != UIUserNotificationType() {
                allowsNotifications = true
                print("already chose notifications, and allows notifications is \(allowsNotifications)")
            } else {
                allowsNotifications = false
            }
        }
        
        if !hasRemovedAds {
            
            //TODO: ADD BANNER AD HERE
            
        }

        authenticateLocalPlayer()

        
        let currentDate = Date()
        print("giftDate is \(giftDate)")
        print("currentDate is \(currentDate)")
        
        switch currentDate.compare(giftDate) {
        case .orderedAscending:
            print("gift not available")
            giftAvailable = false
            timeCount = giftDate.timeIntervalSince(currentDate)
            print("timeCount is \(timeCount)")
        case .orderedDescending:
            print("gift available")
            giftAvailable = true
        case .orderedSame:
            print("dates are same, gift available")
            giftAvailable = true

        }
        
        switch currentDate.compare(dailyBestDate) {
        case .orderedAscending:
            hasDayPassed = false
        case .orderedDescending:
            hasDayPassed = true
            resetDay()
        case .orderedSame:
            hasDayPassed = false
        }
        
        let scene = SplashScreenScene(size: view.bounds.size)
            // Configure the view.
            let skView = self.view as! SKView
            skView.showsFPS = false
            skView.showsNodeCount = false
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            skView.presentScene(scene)
        
    }

    override var shouldAutorotate : Bool {
        return true
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    func authenticateLocalPlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        localPlayer.authenticateHandler =
            {(viewController, error) -> Void in
                if viewController != nil
                {
                    self.present(viewController!, animated:true, completion: nil)
                }
                else
                {
                    if localPlayer.isAuthenticated
                    {
                        gameCenterEnabled = true
                        print("enable game center, player authenticated")
                    }
                    else
                    {
                        print("not able to authenticate fail")
                        gameCenterEnabled = false
                        
                        if (error != nil)
                        {
                            print("\(error!.description)")
                        }
                        else
                        {
                            print("error is nil")
                        }
                    }
                }
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

}

func resetDay() {
    
    print("RESET DAY")
    
    let currentDate = Date()
    let newDate = currentDate.addingTimeInterval(86400)
    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
    let dailyBestReset = cal.startOfDay(for: newDate)
    
    dailyBestDate = dailyBestReset
    GameData.sharedInstance.dailyBestDate = dailyBestDate
    GameData.sharedInstance.save()
    
    dailyBestDawn = 0
    dailyBestNight = 0
    dailyBestDusk = 0
    GameData.sharedInstance.dailyBestDusk = 0
    GameData.sharedInstance.dailyBestDawn = 0
    GameData.sharedInstance.dailyBestNight = 0
    
    dailyChallengeCompleted = false
    rewardAlreadyCollected = false
    
    let prev = dailyChallengeCurrent
    
    if !nightUnlocked {
        dailyChallengeCurrent = Int(arc4random_uniform(UInt32(numChallengesDusk)))
        if dailyChallengeCurrent == prev {
            dailyChallengeCurrent = Int(arc4random_uniform(UInt32(numChallengesDusk)))
        }
    } else if !dawnUnlocked {
        dailyChallengeCurrent = Int(arc4random_uniform(UInt32(numChallengesDusk + numChallengesNight)))
        if dailyChallengeCurrent == prev {
            dailyChallengeCurrent = Int(arc4random_uniform(UInt32(numChallengesDusk + numChallengesNight)))
        }
    } else {
        dailyChallengeCurrent = Int(arc4random_uniform(UInt32(numChallengesDusk + numChallengesNight + numChallengesDawn)))
        if dailyChallengeCurrent == prev {
            dailyChallengeCurrent = Int(arc4random_uniform(UInt32(numChallengesDusk + numChallengesNight + numChallengesDawn)))
        }
    }
    
    
    if tutorialNeeded {
        dailyChallengeCurrent = 1
    }
    
    dailyGamesPlayed = 0
    dailyGamesPlayedNight = 0
    dailyGamesPlayedDawn = 0
    dailyGamesPlayedDusk = 0
    GameData.sharedInstance.dailyGamesPlayed = 0
    GameData.sharedInstance.dailyGamesPlayedDusk = 0
    GameData.sharedInstance.dailyGamesPlayedDawn = 0
    GameData.sharedInstance.dailyGamesPlayedNight = 0
    
    dailyPointsScored = 0
    dailyPointsScoredDawn = 0
    dailyPointsScoredNight = 0
    dailyPointsScoredDusk = 0
    GameData.sharedInstance.dailyPointsScored = 0
    GameData.sharedInstance.dailyPointsScoredNight = 0
    GameData.sharedInstance.dailyPointsScoredDawn = 0
    GameData.sharedInstance.dailyPointsScoredDusk = 0
    
    numTaps = 0

    lastScoresDusk = [0, 0, 0, 0]
    lastScoresNight = [0, 0, 0, 0]
    lastScoresDawn = [0, 0, 0, 0]
    lastScores = [0, 0, 0, 0]
    GameData.sharedInstance.lastScoresDusk = [0,0,0,0]
    GameData.sharedInstance.lastScores = [0,0,0,0]
    GameData.sharedInstance.lastScoresDawn = [0,0,0,0]
    GameData.sharedInstance.lastScoresNight = [0,0,0,0]

    
    hasSeenChallenge = false
    dailyBestAchievedDawn = false
    dailyBestAchievedDusk = false
    dailyBestAchievedNight = false
    
    GameData.sharedInstance.dailyChallengeCurrent = dailyChallengeCurrent
    GameData.sharedInstance.rewardAlreadyCollected = false
    GameData.sharedInstance.dailyChallengeCompleted = false
    
    GameData.sharedInstance.save()

    
}

func completeChallenge() {
    dailyChallengeCompleted = true
    GameData.sharedInstance.dailyChallengeCompleted = true
    GameData.sharedInstance.save()
}




