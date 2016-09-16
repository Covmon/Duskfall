//
//  SKScrollView.swift
//  Dusk
//
//  Created by Noah Covey on 6/21/16.
//  Copyright © 2016 Quantum Cat Games. All rights reserved.
//

import SpriteKit

var nodesTouched: [AnyObject] = [] // global

class SKScrollView: UIScrollView {
    
    // MARK: - Static Properties
    
    /// Touches allowed
    static var disabledTouches = false
    
    /// Scroll view
    fileprivate static var scrollView: UIScrollView!
    
    // MARK: - Properties
    
    /// Current scene
    fileprivate var currentScene: SKScene?
    
    /// Moveable node
    fileprivate var moveableNode: SKNode?
    
    // MARK: - Init
    init(frame: CGRect, scene: SKScene, moveableNode: SKNode) {
        print("Scroll View init")
        super.init(frame: frame)
        
        SKScrollView.scrollView = self
        currentScene = scene
        self.moveableNode = moveableNode
        self.frame = frame
        indicatorStyle = .white
        isScrollEnabled = true
        //self.minimumZoomScale = 1
        //self.maximumZoomScale = 3
        canCancelContentTouches = false
        isUserInteractionEnabled = true
        delegate = self
        
        // flip for spritekit (only needed for horizontal)
        //let verticalFlip = CGAffineTransformMakeScale(-1,-1)
        //self.transform = verticalFlip
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Touches
extension SKScrollView {
    
    /// began
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch began scroll view")
        
        guard !SKScrollView.disabledTouches else { return }
        currentScene?.touchesBegan(touches, with: event)
    }
    
    /// moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch moved scroll view")
        
        guard !SKScrollView.disabledTouches else { return }
        currentScene?.touchesMoved(touches, with: event)
    }
    
    /// ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch ended scroll view")
        
        guard !SKScrollView.disabledTouches else { return }
        currentScene?.touchesEnded(touches, with: event)
    }
    
    /// cancelled
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch cancelled scroll view")
        
        guard !SKScrollView.disabledTouches else { return }
        currentScene?.touchesCancelled(touches, with: event)
    }
}

// MARK: - Touch Controls
extension SKScrollView {
    
    /// Disable
    class func disable() {
        //print("Disabled scroll view")
        SKScrollView.scrollView?.isUserInteractionEnabled = false
        SKScrollView.disabledTouches = true
    }
    
    /// Enable
    class func enable() {
        //print("Enabled scroll view")
        SKScrollView.scrollView?.isUserInteractionEnabled = true
        SKScrollView.disabledTouches = false
    }
}

// MARK: - Delegates
extension SKScrollView: UIScrollViewDelegate {
    
    /// did scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("Scroll view did scroll")
        
        //moveableNode!.position.x = scrollView.contentOffset.x // Left/Right
        
        moveableNode!.position.y = scrollView.contentOffset.y // Up/Dowm
    }
}
