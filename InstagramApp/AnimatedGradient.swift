//
//  AnimatedGradient.swift
//  InstagramApp
//
//  Created by Gwinyai on 20/1/2019.
//  Copyright © 2019 Gwinyai Nyatsoka. All rights reserved.
//

import Foundation

import UIKit

class AnimatedGradient: UIView {
    
    let gradient = CAGradientLayer()
    
    var gradientSet = [[CGColor]]()
    
    var currentGradient = 0
    
    let gradientOne = UIColor(red: 48/255, green: 62/255, blue: 103/255, alpha: 1.0).cgColor
    
    let gradientTwo = UIColor(red: 244/255, green: 88/255, blue: 53/255, alpha: 1.0).cgColor
    
    let gradientThree = UIColor(red: 196/255, green: 70/255, blue: 107/255, alpha: 1.0).cgColor
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }
    
    
    func commonInit() {
        
        gradientSet.append([gradientOne, gradientTwo])
        
        gradientSet.append([gradientTwo, gradientThree])
        
        gradientSet.append([gradientThree, gradientOne])
        
        gradient.colors = gradientSet[currentGradient]
        
        gradient.startPoint = CGPoint(x: 0, y: 0)
        
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        gradient.drawsAsynchronously = true
        
        layer.insertSublayer(gradient, at: 0)
        
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradient.frame = bounds
        
    }
    
    func startAnimation() {
        
        var previousGradient: Int!
        
        if currentGradient < gradientSet.count - 1 {
            
            currentGradient += 1
            
            previousGradient = currentGradient - 1
            
        }
        else {
            
            currentGradient = 0
            
            previousGradient = gradientSet.count - 1
            
        }
        
        let gradientChangeAnim = CABasicAnimation(keyPath: "colors")
        
        gradientChangeAnim.duration = 5.0
        
        gradientChangeAnim.fromValue = gradientSet[previousGradient]
        
        gradientChangeAnim.toValue = gradientSet[currentGradient]
        
        gradient.setValue(currentGradient, forKeyPath: "colorChange")
        
        gradientChangeAnim.delegate = self
        
        gradient.add(gradientChangeAnim, forKey: nil)
        
    }
    
    func stopAnimation() {
        
        gradient.removeAllAnimations()
        
    }
    
}

extension AnimatedGradient: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag {
            
            if let colorChange = gradient.value(forKey: "colorChange") as? Int {
                
                gradient.colors = gradientSet[colorChange]
                
                startAnimation()
                
            }
            
        }
        
    }
    
    
}
