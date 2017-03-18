//
//  FileSave.swift
//  Dusk
//
//  Created by Noah Covey on 3/11/16.
//  Copyright (c) 2016 Quantum Cat Games. All rights reserved.
//

import Foundation

public extension String {
    var NS: NSString {
        return self as NSString
    }
}

/*class GameData : NSObject, NSCoding {
 
    
    
    /// Data to save
    var gems : Int = 500
    var level2Unlocked : Bool = false
    var level3Unlocked : Bool = false
    
    var unlockedCharacters: [String] = ["player"]
    
    var currentCharacter: String = "player"
    
    var hasRemovedAds: Bool = false
    
    var highScoreDusk: Int = 0
    var highScoreDawn: Int = 0
    var highScoreNight: Int = 0
    
    var totalPoints: Int = 0
    var totalGamesPlayed: Int = 0
    
    var lastScores: [Int] = [0,0,0,0]
    var lastScoresDusk: [Int] = [0,0,0,0]
    var lastScoresDawn: [Int] = [0,0,0,0]
    var lastScoresNight: [Int] = [0,0,0,0]
    
    var volumeOn: Bool = true
    var tutorialNeeded: Bool = true
    
    var giftDate: Date = Date(timeIntervalSince1970: 0.0)
    var hasChosenNotifications: Bool = false
    var allowsNotifications: Bool = false
    
    var dailyBestDusk: Int = 0
    var dailyBestNight: Int = 0
    var dailyBestDawn: Int = 0
    
    var dailyBestDate: Date = Date(timeIntervalSince1970: 0.0)
    
    var rewardAlreadyCollected: Bool = false
    var dailyChallengeCompleted: Bool = false
    var dailyChallengeCurrent: Int = 1
    
    var dailyGamesPlayed: Int = 0
    var dailyGamesPlayedDusk: Int = 0
    var dailyGamesPlayedNight: Int = 0
    var dailyGamesPlayedDawn: Int = 0
    
    var dailyPointsScored: Int = 0
    var dailyPointsScoredDusk: Int = 0
    var dailyPointsScoredNight: Int = 0
    var dailyPointsScoredDawn: Int = 0

    /// Create of shared instance
    
    
    
    class var sharedInstance: GameData {
        struct Static {
            static var instance: GameData?
            static var token: Int = 0
        }
        
        var once: () = {
        let gamedata = GameData()
        
        if let savedData = GameData.loadGame() {
            gamedata.gems = savedData.gems
            gamedata.level2Unlocked = savedData.level2Unlocked
            gamedata.level3Unlocked = savedData.level3Unlocked
            gamedata.unlockedCharacters = savedData.unlockedCharacters
            gamedata.currentCharacter = savedData.currentCharacter
            gamedata.highScoreDusk = savedData.highScoreDusk
            gamedata.highScoreNight = savedData.highScoreNight
            gamedata.highScoreDawn = savedData.highScoreDawn
            gamedata.volumeOn = savedData.volumeOn
            gamedata.tutorialNeeded = savedData.tutorialNeeded
            gamedata.giftDate = savedData.giftDate
            gamedata.hasChosenNotifications = savedData.hasChosenNotifications
            gamedata.allowsNotifications = savedData.allowsNotifications
            gamedata.totalPoints = savedData.totalPoints
            gamedata.hasRemovedAds = savedData.hasRemovedAds
            gamedata.dailyBestDate = savedData.dailyBestDate
            gamedata.dailyBestDawn = savedData.dailyBestDawn
            gamedata.dailyBestDusk = savedData.dailyBestDusk
            gamedata.dailyBestNight = savedData.dailyBestNight
            gamedata.dailyChallengeCompleted = savedData.dailyChallengeCompleted
            gamedata.dailyChallengeCurrent = savedData.dailyChallengeCurrent
            gamedata.rewardAlreadyCollected = savedData.rewardAlreadyCollected
            gamedata.dailyGamesPlayed = savedData.dailyGamesPlayed
            gamedata.dailyGamesPlayedDusk = savedData.dailyGamesPlayedDusk
            gamedata.dailyGamesPlayedNight = savedData.dailyGamesPlayedNight
            gamedata.dailyGamesPlayedDawn = savedData.dailyGamesPlayedDawn
            gamedata.totalGamesPlayed = savedData.totalGamesPlayed
            gamedata.dailyPointsScored = savedData.dailyPointsScored
            gamedata.dailyPointsScoredDusk = savedData.dailyPointsScoredDusk
            gamedata.dailyPointsScoredNight = savedData.dailyPointsScoredNight
            gamedata.dailyPointsScoredDawn = savedData.dailyPointsScoredDawn
            gamedata.lastScores = savedData.lastScores
            gamedata.lastScoresDusk = savedData.lastScoresDusk
            gamedata.lastScoresNight = savedData.lastScoresNight
            gamedata.lastScoresDawn = savedData.lastScoresDawn
        }
        Static.instance = gamedata
        }()
        
        //_ = GameData.__once
        return Static.instance!
    }
    
    override init() {
        
        print("override init")
        
        super.init()

    }
    
    required init(coder: NSCoder) {
        
        print("requried init")
        
        //super.init()
        
        self.gems = coder.decodeInteger(forKey: "gems")
        self.level2Unlocked = coder.decodeBool(forKey: "level2Unlocked")
        self.level3Unlocked = coder.decodeBool(forKey: "level3Unlocked")
        self.unlockedCharacters = coder.decodeObject(forKey: "unlockedCharacters") as! [String]
        self.currentCharacter = coder.decodeObject(forKey: "currentCharacter") as! String
        self.highScoreDusk = coder.decodeInteger(forKey: "highScoreDusk")
        self.highScoreNight = coder.decodeInteger(forKey: "highScoreNight")
        self.highScoreDawn = coder.decodeInteger(forKey: "highScoreDawn")
        self.volumeOn = coder.decodeBool(forKey: "volumeOn")
        self.tutorialNeeded = coder.decodeBool(forKey: "tutorialNeeded")
        self.giftDate = coder.decodeObject(forKey: "giftDate") as! Date
        self.hasChosenNotifications = coder.decodeBool(forKey: "hasChosenNotifications")
        self.allowsNotifications = coder.decodeBool(forKey: "allowsNotifications")
        self.totalPoints = coder.decodeInteger(forKey: "totalPoints")
        self.hasRemovedAds = coder.decodeBool(forKey: "hasRemovedAds")
        self.dailyBestNight = coder.decodeInteger(forKey: "dailyBestNight")
        self.dailyBestDawn = coder.decodeInteger(forKey: "dailyBestDawn")
        self.dailyBestDusk = coder.decodeInteger(forKey: "dailyBestDusk")
        self.dailyBestDate = coder.decodeObject(forKey: "dailyBestDate") as! Date
        self.dailyChallengeCompleted = coder.decodeBool(forKey: "dailyChallengeCompleted")
        self.dailyChallengeCurrent = coder.decodeInteger(forKey: "dailyChallengeCurrent")
        self.rewardAlreadyCollected = coder.decodeBool(forKey: "rewardAlreadyCollected")
        self.dailyGamesPlayed = coder.decodeInteger(forKey: "dailyGamesPlayed")
        self.dailyGamesPlayedDawn = coder.decodeInteger(forKey: "dailyGamesPlayedDawn")
        self.dailyGamesPlayedDusk = coder.decodeInteger(forKey: "dailyGamesPlayedDusk")
        self.dailyGamesPlayedNight = coder.decodeInteger(forKey: "dailyGamesPlayedNight")
        self.totalGamesPlayed = coder.decodeInteger(forKey: "totalGamesPlayed")
        self.dailyPointsScored = coder.decodeInteger(forKey: "dailyPointsScored")
        self.dailyPointsScoredDawn = coder.decodeInteger(forKey: "dailyPointsScoredDawn")
        self.dailyPointsScoredNight = coder.decodeInteger(forKey: "dailyPointsScoredNight")
        self.dailyPointsScoredDusk = coder.decodeInteger(forKey: "dailyPointsScoredDusk")
        self.lastScores = coder.decodeObject(forKey: "lastScores") as! [Int]
        self.lastScoresDawn = coder.decodeObject(forKey: "lastScoresDawn") as! [Int]
        self.lastScoresDusk = coder.decodeObject(forKey: "lastScoresDusk") as! [Int]
        self.lastScoresNight = coder.decodeObject(forKey: "lastScoresNight") as! [Int]

    }
    
    func encode(with coder: NSCoder) {
        
        //print("encode with coder")
        
        coder.encodeCInt(Int32(GameData.sharedInstance.gems), forKey: "gems")
        coder.encode(GameData.sharedInstance.level2Unlocked, forKey: "level2Unlocked")
        coder.encode(GameData.sharedInstance.level3Unlocked, forKey: "level3Unlocked")
        coder.encode(GameData.sharedInstance.unlockedCharacters, forKey: "unlockedCharacters")
        coder.encode(GameData.sharedInstance.currentCharacter, forKey: "currentCharacter")
        coder.encodeCInt(Int32(GameData.sharedInstance.highScoreDusk), forKey: "highScoreDusk")
        coder.encodeCInt(Int32(GameData.sharedInstance.highScoreNight), forKey: "highScoreNight")
        coder.encodeCInt(Int32(GameData.sharedInstance.highScoreDawn), forKey: "highScoreDawn")
        coder.encode(GameData.sharedInstance.volumeOn, forKey: "volumeOn")
        coder.encode(GameData.sharedInstance.tutorialNeeded, forKey: "tutorialNeeded")
        coder.encode(GameData.sharedInstance.giftDate, forKey: "giftDate")
        coder.encode(GameData.sharedInstance.hasChosenNotifications, forKey: "hasChosenNotifications")
        coder.encode(GameData.sharedInstance.allowsNotifications, forKey: "allowsNotifications")
        coder.encodeCInt(Int32(GameData.sharedInstance.totalPoints), forKey: "totalPoints")
        coder.encode(GameData.sharedInstance.hasRemovedAds, forKey: "hasRemovedAds")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyBestNight), forKey: "dailyBestNight")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyBestDusk), forKey: "dailyBestDusk")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyBestDawn), forKey: "dailyBestDawn")
        coder.encode(GameData.sharedInstance.dailyBestDate, forKey: "dailyBestDate")
        coder.encode(GameData.sharedInstance.dailyChallengeCompleted, forKey: "dailyChallengeCompleted")
        coder.encode(GameData.sharedInstance.rewardAlreadyCollected, forKey: "rewardAlreadyCollected")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyChallengeCurrent), forKey: "dailyChallengeCurrent")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyGamesPlayed), forKey: "dailyGamesPlayed")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyGamesPlayedNight), forKey: "dailyGamesPlayedNight")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyGamesPlayedDawn), forKey: "dailyGamesPlayedDawn")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyGamesPlayedDusk), forKey: "dailyGamesPlayedDusk")
        coder.encodeCInt(Int32(GameData.sharedInstance.totalGamesPlayed), forKey: "totalGamesPlayed")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyPointsScored), forKey: "dailyPointsScored")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyPointsScoredDusk), forKey: "dailyPointsScoredDusk")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyPointsScoredDawn), forKey: "dailyPointsScoredDawn")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyPointsScoredNight), forKey: "dailyPointsScoredNight")
        coder.encode(GameData.sharedInstance.lastScores, forKey: "lastScores")
        coder.encode(GameData.sharedInstance.lastScoresDusk, forKey: "lastScoresDusk")
        coder.encode(GameData.sharedInstance.lastScoresDawn, forKey: "lastScoresDawn")
        coder.encode(GameData.sharedInstance.lastScoresNight, forKey: "lastScoresNight")




    }
    
    /// Loading and saving courtesy of:
    /// http://www.thinkingswiftly.com/saving-spritekit-game-data-swift-easy-nscoder/
    
    class func loadGame() -> GameData? {
        // load existing high scores or set up an empty array
        print("loading game data")
        
        
        var sourcePath: String? {
            guard let path = Bundle.main.path(forResource: "DefaultGameData", ofType: "plist") else {return .none }
            return path
        }
        
        var destPath: String? {
            guard sourcePath != .none else { return .none }
            let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            //print("dir is \(dir)")
            return (dir as NSString).appendingPathComponent("GameData.plist")
        }
        
        
        let fileManager = FileManager.default
        guard let destination = destPath else { return nil } //DESTINATION IS GAMEDATA.PLIST
        guard let source = sourcePath else { return nil } //SOURCE IS DEFAULTGAMEDATA.PLIST, IN XCODE
        guard fileManager.fileExists(atPath: source) else { return nil }
        
        
        // check if file exists
        if !fileManager.fileExists(atPath: destination) {
            
            // create an empty file if it doesn't exist
            print("file at path doesn't exist, so create a new one \n")

                do {
                    try fileManager.copyItem(atPath: source, toPath: destination)
                } catch {
                    print("ERROR: \n")
                    print(error)
                    return nil
                }

        } else {
            print("file at path already exists")
        }
        if fileManager.fileExists(atPath: destPath!) {
            guard let rawData = try? Data(contentsOf: URL(fileURLWithPath: destPath!)) else { return .none }
            print("raw data is \(rawData) \n")
            // do we get serialized data back from the attempted path?
            // if so, unarchive it into an AnyObject, and then convert to an array of HighScores, if possible
            guard let data = NSKeyedUnarchiver.unarchiveObject(with: rawData) as? GameData else {
                print("data not unarchived")
                return .none
            }
            return data
        }
        return nil
    }
    func save() {
        // find the save directory our app has permission to use, and save the serialized version of self.scores - the HighScores array.
        let saveData = NSKeyedArchiver.archivedData(withRootObject: GameData.sharedInstance);
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray;
        let documentsDirectory = paths.object(at: 0) as! NSString;
        let path = documentsDirectory.appendingPathComponent("GameData.plist");
        
        try? saveData.write(to: URL(fileURLWithPath: path), options: [.atomic]);
        
        //print("saving data")
    }
}*/



import SpriteKit

class GameData : NSObject, NSCoding {
    
    /// Data to save
    var gems : Int = 500
    var level2Unlocked : Bool = false
    var level3Unlocked : Bool = false
    
    var unlockedCharacters: [String] = ["player"]
    
    var currentCharacter: String = "player"
    
    var hasRemovedAds: Bool = false
    
    var highScoreDusk: Int = 0
    var highScoreDawn: Int = 0
    var highScoreNight: Int = 0
    
    var totalPoints: Int = 0
    var totalGamesPlayed: Int = 0
    
    var lastScores: [Int] = [0,0,0,0]
    var lastScoresDusk: [Int] = [0,0,0,0]
    var lastScoresDawn: [Int] = [0,0,0,0]
    var lastScoresNight: [Int] = [0,0,0,0]
    
    var volumeOn: Bool = true
    var tutorialNeeded: Bool = true
    
    var giftDate: Date = Date(timeIntervalSince1970: 0.0)
    var hasChosenNotifications: Bool = false
    var allowsNotifications: Bool = false
    
    var dailyBestDusk: Int = 0
    var dailyBestNight: Int = 0
    var dailyBestDawn: Int = 0
    
    var dailyBestDate: Date = Date(timeIntervalSince1970: 0.0)
    
    var rewardAlreadyCollected: Bool = false
    var dailyChallengeCompleted: Bool = false
    var dailyChallengeCurrent: Int = 1
    
    var dailyGamesPlayed: Int = 0
    var dailyGamesPlayedDusk: Int = 0
    var dailyGamesPlayedNight: Int = 0
    var dailyGamesPlayedDawn: Int = 0
    
    var dailyPointsScored: Int = 0
    var dailyPointsScoredDusk: Int = 0
    var dailyPointsScoredNight: Int = 0
    var dailyPointsScoredDawn: Int = 0
    
    /// Create of shared instance
    internal static let sharedInstance = GameData()
    
    // MARK: Init
    
    override init() {
        super.init()
        
    }
    
    required init?(coder: NSCoder) {
        super.init()
        
        print("requried init coder")
        
        self.gems = coder.decodeInteger(forKey: "gems")
        self.level2Unlocked = coder.decodeBool(forKey: "level2Unlocked")
        self.level3Unlocked = coder.decodeBool(forKey: "level3Unlocked")
        self.unlockedCharacters = coder.decodeObject(forKey: "unlockedCharacters") as! [String]
        self.currentCharacter = coder.decodeObject(forKey: "currentCharacter") as! String
        self.highScoreDusk = coder.decodeInteger(forKey: "highScoreDusk")
        self.highScoreNight = coder.decodeInteger(forKey: "highScoreNight")
        self.highScoreDawn = coder.decodeInteger(forKey: "highScoreDawn")
        self.volumeOn = coder.decodeBool(forKey: "volumeOn")
        self.tutorialNeeded = coder.decodeBool(forKey: "tutorialNeeded")
        self.giftDate = coder.decodeObject(forKey: "giftDate") as! Date
        self.hasChosenNotifications = coder.decodeBool(forKey: "hasChosenNotifications")
        self.allowsNotifications = coder.decodeBool(forKey: "allowsNotifications")
        self.totalPoints = coder.decodeInteger(forKey: "totalPoints")
        self.hasRemovedAds = coder.decodeBool(forKey: "hasRemovedAds")
        self.dailyBestNight = coder.decodeInteger(forKey: "dailyBestNight")
        self.dailyBestDawn = coder.decodeInteger(forKey: "dailyBestDawn")
        self.dailyBestDusk = coder.decodeInteger(forKey: "dailyBestDusk")
        self.dailyBestDate = coder.decodeObject(forKey: "dailyBestDate") as! Date
        self.dailyChallengeCompleted = coder.decodeBool(forKey: "dailyChallengeCompleted")
        self.dailyChallengeCurrent = coder.decodeInteger(forKey: "dailyChallengeCurrent")
        self.rewardAlreadyCollected = coder.decodeBool(forKey: "rewardAlreadyCollected")
        self.dailyGamesPlayed = coder.decodeInteger(forKey: "dailyGamesPlayed")
        self.dailyGamesPlayedDawn = coder.decodeInteger(forKey: "dailyGamesPlayedDawn")
        self.dailyGamesPlayedDusk = coder.decodeInteger(forKey: "dailyGamesPlayedDusk")
        self.dailyGamesPlayedNight = coder.decodeInteger(forKey: "dailyGamesPlayedNight")
        self.totalGamesPlayed = coder.decodeInteger(forKey: "totalGamesPlayed")
        self.dailyPointsScored = coder.decodeInteger(forKey: "dailyPointsScored")
        self.dailyPointsScoredDawn = coder.decodeInteger(forKey: "dailyPointsScoredDawn")
        self.dailyPointsScoredNight = coder.decodeInteger(forKey: "dailyPointsScoredNight")
        self.dailyPointsScoredDusk = coder.decodeInteger(forKey: "dailyPointsScoredDusk")
        self.lastScores = coder.decodeObject(forKey: "lastScores") as! [Int]
        self.lastScoresDawn = coder.decodeObject(forKey: "lastScoresDawn") as! [Int]
        self.lastScoresDusk = coder.decodeObject(forKey: "lastScoresDusk") as! [Int]
        self.lastScoresNight = coder.decodeObject(forKey: "lastScoresNight") as! [Int]

        
    }
    
    func encode(with coder: NSCoder) {
        
        print("encode with coder")
        coder.encodeCInt(Int32(GameData.sharedInstance.gems), forKey: "gems")
        coder.encode(GameData.sharedInstance.level2Unlocked, forKey: "level2Unlocked")
        coder.encode(GameData.sharedInstance.level3Unlocked, forKey: "level3Unlocked")
        coder.encode(GameData.sharedInstance.unlockedCharacters, forKey: "unlockedCharacters")
        coder.encode(GameData.sharedInstance.currentCharacter, forKey: "currentCharacter")
        coder.encodeCInt(Int32(GameData.sharedInstance.highScoreDusk), forKey: "highScoreDusk")
        coder.encodeCInt(Int32(GameData.sharedInstance.highScoreNight), forKey: "highScoreNight")
        coder.encodeCInt(Int32(GameData.sharedInstance.highScoreDawn), forKey: "highScoreDawn")
        coder.encode(GameData.sharedInstance.volumeOn, forKey: "volumeOn")
        coder.encode(GameData.sharedInstance.tutorialNeeded, forKey: "tutorialNeeded")
        coder.encode(GameData.sharedInstance.giftDate, forKey: "giftDate")
        coder.encode(GameData.sharedInstance.hasChosenNotifications, forKey: "hasChosenNotifications")
        coder.encode(GameData.sharedInstance.allowsNotifications, forKey: "allowsNotifications")
        coder.encodeCInt(Int32(GameData.sharedInstance.totalPoints), forKey: "totalPoints")
        coder.encode(GameData.sharedInstance.hasRemovedAds, forKey: "hasRemovedAds")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyBestNight), forKey: "dailyBestNight")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyBestDusk), forKey: "dailyBestDusk")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyBestDawn), forKey: "dailyBestDawn")
        coder.encode(GameData.sharedInstance.dailyBestDate, forKey: "dailyBestDate")
        coder.encode(GameData.sharedInstance.dailyChallengeCompleted, forKey: "dailyChallengeCompleted")
        coder.encode(GameData.sharedInstance.rewardAlreadyCollected, forKey: "rewardAlreadyCollected")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyChallengeCurrent), forKey: "dailyChallengeCurrent")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyGamesPlayed), forKey: "dailyGamesPlayed")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyGamesPlayedNight), forKey: "dailyGamesPlayedNight")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyGamesPlayedDawn), forKey: "dailyGamesPlayedDawn")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyGamesPlayedDusk), forKey: "dailyGamesPlayedDusk")
        coder.encodeCInt(Int32(GameData.sharedInstance.totalGamesPlayed), forKey: "totalGamesPlayed")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyPointsScored), forKey: "dailyPointsScored")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyPointsScoredDusk), forKey: "dailyPointsScoredDusk")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyPointsScoredDawn), forKey: "dailyPointsScoredDawn")
        coder.encodeCInt(Int32(GameData.sharedInstance.dailyPointsScoredNight), forKey: "dailyPointsScoredNight")
        coder.encode(GameData.sharedInstance.lastScores, forKey: "lastScores")
        coder.encode(GameData.sharedInstance.lastScoresDusk, forKey: "lastScoresDusk")
        coder.encode(GameData.sharedInstance.lastScoresDawn, forKey: "lastScoresDawn")
        coder.encode(GameData.sharedInstance.lastScoresNight, forKey: "lastScoresNight")

        
    }
    
    /*func resetData() {
        self.bank = 200
        self.food = 0
        self.variableA = "AString"
        self.levelData = LevelData()
        
        /// Even though same static instance of GameData, this flag controls which save file we're dealing with
        self.currentSaveFile = nil
    }*/
    
    // MARK: Loading and saving
    
    /// This loads an existing game, or starts a new slot for a new game.
    func loadGame(saveFile:String) -> Bool {
        
        print("load game")
        /// Make sure we're not holding on to past game data
        //self.resetData()
        
        
        /// If save file exists already, load it in and assign variables
        if let savedData = self.loadGameData(file:saveFile) {
            self.gems = savedData.gems
            self.level2Unlocked = savedData.level2Unlocked
            self.level3Unlocked = savedData.level3Unlocked
            self.unlockedCharacters = savedData.unlockedCharacters
            self.currentCharacter = savedData.currentCharacter
            self.highScoreDusk = savedData.highScoreDusk
            self.highScoreNight = savedData.highScoreNight
            self.highScoreDawn = savedData.highScoreDawn
            self.volumeOn = savedData.volumeOn
            self.tutorialNeeded = savedData.tutorialNeeded
            self.giftDate = savedData.giftDate
            self.hasChosenNotifications = savedData.hasChosenNotifications
            self.allowsNotifications = savedData.allowsNotifications
            self.totalPoints = savedData.totalPoints
            self.hasRemovedAds = savedData.hasRemovedAds
            self.dailyBestDate = savedData.dailyBestDate
            self.dailyBestDawn = savedData.dailyBestDawn
            self.dailyBestDusk = savedData.dailyBestDusk
            self.dailyBestNight = savedData.dailyBestNight
            self.dailyChallengeCompleted = savedData.dailyChallengeCompleted
            self.dailyChallengeCurrent = savedData.dailyChallengeCurrent
            self.rewardAlreadyCollected = savedData.rewardAlreadyCollected
            self.dailyGamesPlayed = savedData.dailyGamesPlayed
            self.dailyGamesPlayedDusk = savedData.dailyGamesPlayedDusk
            self.dailyGamesPlayedNight = savedData.dailyGamesPlayedNight
            self.dailyGamesPlayedDawn = savedData.dailyGamesPlayedDawn
            self.totalGamesPlayed = savedData.totalGamesPlayed
            self.dailyPointsScored = savedData.dailyPointsScored
            self.dailyPointsScoredDusk = savedData.dailyPointsScoredDusk
            self.dailyPointsScoredNight = savedData.dailyPointsScoredNight
            self.dailyPointsScoredDawn = savedData.dailyPointsScoredDawn
            self.lastScores = savedData.lastScores
            self.lastScoresDusk = savedData.lastScoresDusk
            self.lastScoresNight = savedData.lastScoresNight
            self.lastScoresDawn = savedData.lastScoresDawn
            
            return true
        }
        return false
    }
    
    /// Internal method to actual load the file
    private func loadGameData(file:String) -> GameData? {
        print("load game data")
        
        /// load existing high scores or set up an empty array
        let path = GameData.getFilePath(name:file)
        
        /// Only attempt to decode if file already existed
        if GameData.fileExistsAtPath(path:path, create: true) {
            
            if let rawData = NSData(contentsOfFile: path) {
                /// do we get serialized data back from the attempted path?
                /// if so, unarchive it into an AnyObject, and then convert to a GameData object
                if let data = NSKeyedUnarchiver.unarchiveObject(with: rawData as Data) as? GameData {
                    return data
                }
            }
            
        }
        
        return nil
    }
    
    func save() {
        /*
        let saveData = NSKeyedArchiver.archivedData(withRootObject: GameData.sharedInstance);
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths.object(at: 0) as! NSString
        let path = documentsDirectory.appendingPathComponent("GameData.plist")
        
        try? saveData.write(to: URL(fileURLWithPath: path), options: [.atomic])
        
        /// If we're working with an active save file, attempt to save it
        let saveFile = "GameData.plist"*/
            
            //DispatchQueue.global(attributes: .qosBackground).async {
                
                /// find the save directory our app has permission to use, and save the serialized version of self.scores - the HighScores array.
        
        print("save")
                let saveData = NSKeyedArchiver.archivedData(withRootObject: GameData.sharedInstance)
                let path = GameData.getFilePath(name: "GameData.plist")
                
                do {
                    let location = URL(fileURLWithPath: path)
                    try saveData.write(to:location, options: .atomicWrite)
                } catch _ {
                    print("unable to save file")
                }
    }
    
    // MARK: Files
    
    /// This would create a file in the documents directory of GameDataOne.plist
    class func getFilePath(name:String) -> String {
        print("get file path")
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let fileName = "GameData"
        let path = documentsDirectory + "\(fileName).plist"
        return path
    }
    
    /// Check if a file exists. Pass in create = true to create the file if it doesn't exist.
    /// Requires DefaultFile.plist to be an empty plist in your project directory
    class func fileExistsAtPath(path:String, create:Bool = false) -> Bool {
        print("file exists at path")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            // create an empty file if it doesn't exist and create is true
            if(create) {
                if let bundle = Bundle.main.path(forResource: "DefaultGameData", ofType: "plist") {
                    do {
                        try fileManager.copyItem(atPath: bundle, toPath: path)
                    } catch _ {
                        print("Unable to create base save file")
                    }
                }
                else {
                    print("DefaultGameData.plist not found")
                }
            }
            return false
        }
        return true
    }
    
    /// Delete a save file. Requires you to path in proper path by calling getFilePath first
    class func deleteFileAtPath(path:String) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch _ {
        }
    }
    
}






