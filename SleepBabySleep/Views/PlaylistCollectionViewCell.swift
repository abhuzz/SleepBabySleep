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
        playlistImage.transform = CGAffineTransform(rotationAngle: degreesToRadians(7))
    }
    
    func updateParallaxOffset(collectionViewBounds bounds: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offsetFromCenter = CGPoint(x: center.x - self.center.x, y: center.y - self.center.y)
        let maxVerticalOffset = (bounds.height / 2) + (self.bounds.height / 2)
        let scaleFactor = 40 / maxVerticalOffset
        
        parallaxOffset = -offsetFromCenter.y * scaleFactor
    }
    
    func currentlySelected() {
        
        cellSelected = true
        
        setOptimizedTextColor()
    }
    
    func notSelected() {
        
        cellSelected = false
        
        setOptimizedTextColor()
    }
    
    private var swipeOffset: CGFloat {
        get {
            let maxHorizontalOffset = (bounds.width / 2) + (self.bounds.width / 2)
            let scaleFactor = 40 / maxHorizontalOffset
            return 1500.0 * scaleFactor
        }
    }
    
    func swipeRight() {
        
        leadingConstraint.constant += swipeOffset
        trailingConstraint.constant -= swipeOffset
    }
    
    func undoSwipe() {
        
        leadingConstraint.constant -= swipeOffset
        trailingConstraint.constant += swipeOffset
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
