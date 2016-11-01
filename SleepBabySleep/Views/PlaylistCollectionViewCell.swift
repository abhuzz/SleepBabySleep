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
    
    private var cellSelected = false
    
    private var lastSwipeOffset: CGFloat = 0
    
    private var parallaxOffset: CGFloat = 0 {
        didSet {
            playListImageViewYCenterConstraint.constant = parallaxOffset
        }
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
    
    var soundFile: SoundFile? {
        didSet {
            guard let soundFile = soundFile else { return }
            
            playlistTitle.text = soundFile.Name
            playlistImage.image = soundFile.Image
            
            DispatchQueue.global().async {
                
                var optimalTextColor = UIColor.black
                
                if soundFile.Image.averageColor().getBrightnessDifference(UIColor.black) < 140 {
                    optimalTextColor = UIColor.white
                }
                
                DispatchQueue.main.async {
                    self.playlistTitle.textColor = optimalTextColor
                }
            }
        }
    }
    
    override var isSelected: Bool {
        get {
            return super.isSelected;
        }
        
        set {
            guard (super.isSelected != newValue) else { return }
            
            super.isSelected = newValue
            
            if super.isSelected {
                animateIsSelected()
            } else {
                animateIsNotSelected()
            }
        }
    }
    
    
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistTitle: UILabel!
    @IBOutlet weak var playListImageViewYCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    
    func updateParallaxOffset(collectionViewBounds bounds: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offsetFromCenter = CGPoint(x: center.x - self.center.x, y: center.y - self.center.y)
        let maxVerticalOffset = (bounds.height / 2) + (self.bounds.height / 2)
        let scaleFactor = 40 / maxVerticalOffset
        
        parallaxOffset = -offsetFromCenter.y * scaleFactor
    }
    
    func swipeRight(animateInView: UIView?) {
        
        NSLog("PlayListCollectionViewCell.swipeRight()")
        
        swipeHorizontally(animateInView: animateInView, offset: swipeOffset)
    }
    
    func swipeLeft(animateInView: UIView?) {
        
        NSLog("PlayListCollectionViewCell.swipeLeft()")
        
        swipeHorizontally(animateInView: animateInView, offset: swipeOffset * -1)
    }
    
    func undoSwipe(animateInView: UIView?) {
        
        NSLog("PlayListCollectionViewCell.undoSwipe()")
        
        swipeHorizontally(animateInView: animateInView, offset: lastSwipeOffset * -1)
    }
    
    func disappear(animateInView: UIView, animationCompleted: @escaping () -> ()) {
        
        NSLog("PlaylistCollectionViewCell.disappear()")
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 0.0
            self.undoSwipe(animateInView: animateInView)
            }, completion: {
                (bool: Bool) in animationCompleted()
        })
    }
    
    
    private func animateIsSelected() {
        
        NSLog("PlaylistCollectionViewCell.animateIsPlaying()")
        
        animateScaleCell(scaleX: 1.0, scaleY: 1.15)
    }
    
    private func animateIsNotSelected() {
        
        NSLog("PlaylistCollectionViewCell.animateIsNotPlaying()")
        
        animateScaleCell(scaleX: 0.97, scaleY: 0.97)
    }
    
    private func animateScaleCell(scaleX: CGFloat, scaleY: CGFloat) {
        
        UIView.animate(withDuration: 0.44, delay: 0, options: .curveEaseOut, animations: {
            
            self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    private func swipeHorizontally(animateInView: UIView?, offset: CGFloat) {
        
        guard  let view = animateInView else { return }
        
        leadingConstraint.constant += offset
        trailingConstraint.constant -= offset
        
        lastSwipeOffset = offset
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
            view.layoutIfNeeded()
            }, completion: nil)
    }
}
