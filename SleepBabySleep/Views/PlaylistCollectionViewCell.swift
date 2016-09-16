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
    @IBOutlet weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var cellHeightConstraint: NSLayoutConstraint!
    
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
                
                if soundFile.Image.averageColor().getBrightnessDifference(UIColor.black) < 125 {
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        //playlistImage.transform = CGAffineTransform(rotationAngle: degreesToRadians(7))
    }
    
    func updateParallaxOffset(collectionViewBounds bounds: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offsetFromCenter = CGPoint(x: center.x - self.center.x, y: center.y - self.center.y)
        let maxVerticalOffset = (bounds.height / 2) + (self.bounds.height / 2)
        let scaleFactor = 40 / maxVerticalOffset
        
        parallaxOffset = -offsetFromCenter.y * scaleFactor
    }
    
    func currentlySelected(view: UIView) {
        
        guard cellSelected == false else { return }
        
        cellSelected = true
        
        setOptimizedTextColor()
        
        animateIsPlaying(animateInView: view)
    }
    
    func notSelected(view: UIView) {
        
        guard cellSelected == true else { return }
        
        cellSelected = false
        
        setOptimizedTextColor()
        
        animateIsNotPlaying(animateInView: view)
    }
    
    private var swipeOffset: CGFloat {
        get {
            let maxHorizontalOffset = (bounds.width / 2) + (self.bounds.width / 2)
            let scaleFactor = 40 / maxHorizontalOffset
            return 1500.0 * scaleFactor
        }
    }
    
    private var trackPlayingOffset: CGFloat {
        get {
            let maxHorizontalOffset = (bounds.width / 2) + (self.bounds.width / 2)
            let scaleFactor = 40 / maxHorizontalOffset
            return 500.0 * scaleFactor
        }
    }
    
    func animateIsPlaying(animateInView: UIView?) {
        
        /*let offset = trackPlayingOffset
        
        leadingConstraint.constant += offset
        trailingConstraint.constant -= offset
        titleLeadingConstraint.constant += offset
        titleTrailingConstraint.constant -= offset*/
        
        cellHeightConstraint.constant = 300
        
        guard let view = animateInView else { return }
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
            view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func animateIsNotPlaying(animateInView: UIView?) {
        
        let offset = trackPlayingOffset
        
        /*leadingConstraint.constant -= offset
        trailingConstraint.constant += offset
        titleLeadingConstraint.constant -= offset
        titleTrailingConstraint.constant += offset
        
        guard let view = animateInView else { return }
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
            view.layoutIfNeeded()
            }, completion: nil)*/
    }
    
    func swipeRight(animateInView: UIView?) {
        
        let offset = swipeOffset
        
        leadingConstraint.constant += offset
        trailingConstraint.constant -= offset
        titleLeadingConstraint.constant += offset
        titleTrailingConstraint.constant -= offset
        
        guard let view = animateInView else { return }
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
                view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func undoSwipe(animateInView: UIView?) {
        
        let offset = self.swipeOffset
        
        leadingConstraint.constant -= offset
        trailingConstraint.constant += offset
        titleLeadingConstraint.constant -= offset
        titleTrailingConstraint.constant += offset
        
        guard let view = animateInView else { return }
        
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseOut, animations: {
            view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func disappear(animateInView: UIView, animationCompleted: @escaping () -> ()) {
        
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
                self.alpha = 0.0
                self.undoSwipe(animateInView: nil)
            }, completion: {
                (bool: Bool) in animationCompleted()
        })
    }
    
    private func setOptimizedTextColor() {
        
        if cellSelected {
            playlistTitle.textColor = UIColor.lightGray
            return
        }
        
        playlistTitle.textColor = optimalTextColor
        playlistFile.textColor = optimalTextColor
    }
}
