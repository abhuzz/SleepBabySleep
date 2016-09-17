//
//  PlaylistCollectionViewCell.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 02/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit

class PlaylistCollectionViewCell: UICollectionViewCell {
    
    private var optimalTextColor = UIColor.black
    private var cellSelected = false
    
    @IBOutlet weak var playlistFile: UILabel!
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistTitle: UILabel!
    @IBOutlet weak var playListImageViewYCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    private var parallaxOffset: CGFloat = 0 {
        didSet {
            playListImageViewYCenterConstraint.constant = parallaxOffset
        }
    }
    
    var soundFile: SoundFile? {
        didSet {
            guard let soundFile = soundFile else { return }
            
            playlistTitle.text = soundFile.Name
            playlistFile.text = soundFile.URL.lastPathComponent 
            playlistImage.image = soundFile.Image
            
            DispatchQueue.global().async {
                
                if soundFile.Image.averageColor().getBrightnessDifference(UIColor.black) < 140 {
                    self.optimalTextColor = UIColor.white
                } else {
                    self.optimalTextColor = UIColor.black
                }
                
                DispatchQueue.main.async {
                    self.setOptimizedTextColor()
                }
            }
        }
    }
    
    
    func updateParallaxOffset(collectionViewBounds bounds: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offsetFromCenter = CGPoint(x: center.x - self.center.x, y: center.y - self.center.y)
        let maxVerticalOffset = (bounds.height / 2) + (self.bounds.height / 2)
        let scaleFactor = 40 / maxVerticalOffset
        
        parallaxOffset = -offsetFromCenter.y * scaleFactor
    }
    
    func currentlySelected(view: UIView) {
        
        if cellSelected { return }
        
        cellSelected = true
        
        setOptimizedTextColor()
        
        animateIsSelected()
    }
    
    func notSelected(view: UIView) {
        
        if !cellSelected { return }
        
        cellSelected = false
        
        setOptimizedTextColor()
        
        animateIsNotSelected()
    }
    
    private var swipeOffset: CGFloat {
        get {
            let maxHorizontalOffset = (bounds.width / 2) + (self.bounds.width / 2)
            let scaleFactor = 40 / maxHorizontalOffset
            return 500.0 * scaleFactor
        }
    }
    
    private var trackPlayingOffset: CGFloat {
        get {
            let maxHorizontalOffset = (bounds.width / 2) + (self.bounds.width / 2)
            let scaleFactor = 40 / maxHorizontalOffset
            return 500.0 * scaleFactor
        }
    }
    
    private func animateIsSelected() {
        
        NSLog("PlaylistCollectionViewCell.animateIsPlaying")
        
        UIView.animate(withDuration: 0.44, delay: 0, options: .curveEaseOut, animations: {
            
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.15)
            
                self.playlistTitle.transform = CGAffineTransform(rotationAngle: -0.05).scaledBy(x: 1.05, y: 1.05)
            
                self.setNeedsLayout()
                self.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    private func animateIsNotSelected() {
        
        NSLog("PlaylistCollectionViewCell.animateIsNotPlaying")
        
        UIView.animate(withDuration: 0.44, delay: 0, options: .curveEaseOut, animations: {
            
                self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            
            
                self.playlistTitle.transform = CGAffineTransform(rotationAngle: 0)
            
                self.setNeedsLayout()
                self.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    func swipeRight(animateInView: UIView?) {
        
        let offset = swipeOffset
        
        leadingConstraint.constant += offset
        trailingConstraint.constant -= offset
        
        guard let view = animateInView else { return }
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
                view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func undoSwipe(animateInView: UIView?) {
        
        let offset = self.swipeOffset
        
        leadingConstraint.constant -= offset
        trailingConstraint.constant += offset
        
        guard let view = animateInView else { return }
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
            view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func disappear(animateInView: UIView, animationCompleted: @escaping () -> ()) {
        
        NSLog("PlaylistCollectionViewCell.disappear()")
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
                self.alpha = 0.0
                self.undoSwipe(animateInView: nil)
            }, completion: {
                (bool: Bool) in animationCompleted()
        })
    }
    
    private func setOptimizedTextColor() {
        
        playlistTitle.textColor = optimalTextColor
        playlistFile.textColor = optimalTextColor
    }
}
