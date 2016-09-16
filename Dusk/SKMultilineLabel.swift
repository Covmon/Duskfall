//
//  SKMultilineLabel.swift
//  Dusk
//
//  Created by Noah Covey on 7/2/16.
//  Copyright © 2016 Quantum Cat Games. All rights reserved.
//

import SpriteKit

class SKMultilineLabel: SKNode {
    //props
    var labelWidth:CGFloat {didSet {update()}}
    var labelHeight:CGFloat = 0
    var text:String {didSet {update()}}
    var fontName:String {didSet {update()}}
    var fontSize:CGFloat {didSet {update()}}
    var pos:CGPoint {didSet {update()}}
    var fontColor:SKColor {didSet {update()}}
    var leading:CGFloat {didSet {update()}}
    var alignment:SKLabelHorizontalAlignmentMode {didSet {update()}}
    var dontUpdate = false
    var shouldShowBorder:Bool = false {didSet {update()}}
    //display objects
    var rect:SKShapeNode?
    var labels:[SKLabelNode] = []
    
    init(text:String, labelWidth:CGFloat, pos:CGPoint, fontName:String="Roboto-Light",fontSize:CGFloat=10,fontColor:SKColor=SKColor.white,leading:CGFloat=10, alignment:SKLabelHorizontalAlignmentMode = .center, shouldShowBorder:Bool = false)
    {
        self.text = text
        self.labelWidth = labelWidth
        self.pos = pos
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.leading = leading
        self.shouldShowBorder = shouldShowBorder
        self.alignment = alignment
        
        super.init()
        
        self.update()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //if you want to change properties without updating the text field,
    //  set dontUpdate to false and call the update method manually.
    func update() {
        if (dontUpdate) {return}
        if (labels.count>0) {
            for label in labels {
                label.removeFromParent()
            }
            labels = []
        }
        let separators = CharacterSet.whitespacesAndNewlines
        let words = text.components(separatedBy: separators)
        
        var finalLine = false
        var wordCount = -1
        var lineCount = 0
        while (!finalLine) {
            lineCount += 1
            var lineLength = CGFloat(0)
            var lineString = ""
            var lineStringBeforeAddingWord = ""
            
            // creation of the SKLabelNode itself
            let label = SKLabelNode(fontNamed: fontName)
            // name each label node so you can animate it if u wish
            label.name = "line\(lineCount)"
            label.horizontalAlignmentMode = alignment
            label.fontSize = fontSize
            label.fontColor = SKColor.white
            
            while lineLength < CGFloat(labelWidth)
            {
                wordCount += 1
                if wordCount > words.count-1
                {
                    //label.text = "\(lineString) \(words[wordCount])"
                    finalLine = true
                    break
                }
                else
                {
                    lineStringBeforeAddingWord = lineString
                    lineString = "\(lineString) \(words[wordCount])"
                    label.text = lineString
                    lineLength = label.frame.size.width
                }
            }
            if lineLength > 0 {
                wordCount -= 1
                if (!finalLine) {
                    if lineStringBeforeAddingWord == "" {
                        print("Words don't fit! Decrease the font size of increase the labelWidth (\"\(lineString)\")")
                        break
                    }
                    lineString = lineStringBeforeAddingWord
                }
                label.text = lineString
                var linePos = pos
                if (alignment == .left) {
                    linePos.x -= CGFloat(labelWidth / 2)
                } else if (alignment == .right) {
                    linePos.x += CGFloat(labelWidth / 2)
                }
                linePos.y += CGFloat(-leading * CGFloat(lineCount))
                label.position = CGPoint( x: linePos.x , y: linePos.y )
                self.addChild(label)
                labels.append(label)
                //print("was \(lineLength), now \(label.frame.size.width)")
            }
            
        }
        labelHeight = CGFloat(lineCount) * leading
        showBorder()
    }
    
    func showBorder() {
        if (!shouldShowBorder) {return}
        if let rect = self.rect {
            self.removeChildren(in: [rect])
        }
        self.rect = SKShapeNode(rectOf: CGSize(width: labelWidth, height: labelHeight))
        if let rect = self.rect {
            rect.strokeColor = SKColor.white
            rect.lineWidth = 1
            rect.position = CGPoint(x: pos.x, y: pos.y - (CGFloat(labelHeight) / 2.0))
            self.addChild(rect)
        }
    }
}
/*
class SKAttributedLabelNode: SKSpriteNode {
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init(size: CGSize) {
        super.init(texture: nil, color: .clearColor(), size: size)
        
    }
    
    var attributedString: NSAttributedString! {
        didSet {
            draw()
        }
    }
    
    func draw() {
        guard let attrStr = attributedString else {
            texture = nil
            return
        }
        
        let scaleFactor = UIScreen.mainScreen().scale
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.PremultipliedLast.rawValue
        guard let context = CGBitmapContextCreate(nil, Int(size.width * scaleFactor), Int(size.height * scaleFactor), 8, Int(size.width * scaleFactor) * 4, colorSpace, bitmapInfo) else {
            return
        }
        
        CGContextScaleCTM(context, scaleFactor, scaleFactor)
        CGContextConcatCTM(context, CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        
        let strHeight = attrStr.boundingRectWithSize(size, options: .UsesLineFragmentOrigin, context: nil).height
        let yOffset = (size.height - strHeight)/2
        
        if let imageRef = CGBitmapContextCreateImage(context) {
            texture = SKTexture(CGImage: imageRef)
        } else {
            texture = nil
        }
        
        UIGraphicsPopContext()
        
    }
    
    
    
    
} */





