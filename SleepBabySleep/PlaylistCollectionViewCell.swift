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
    
    private var optimalTextColor = UIColor.blackColor()
    
    @IBOutlet weak var playlistFile: UILabel!
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistTitle: UILabel!
    @IBOutlet weak var playListImageViewYCenterConstraint: NSLayoutConstraint!
    
    private var parallaxOffset: CGFloat = 0 {
        didSet {
            playListImageViewYCenterConstraint.constant = parallaxOffset
        }
    }
    
    var soundFile: SoundFile? {
        didSet {
            guard let soundFile = soundFile else { return }
            
            playlistTitle.text = soundFile.Name
            playlistFile.text = soundFile.URL.lastPathComponent ?? "n/a"
            playlistImage.image = soundFile.Image
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                if soundFile.Image.averageColor().getBrightnessDifference(UIColor.blackColor()) < 125 {
                    self.optimalTextColor = UIColor.whiteColor()
                } else {
                    self.optimalTextColor = UIColor.blackColor()
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.setOptimizedTextColor()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = false
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        playlistImage.transform = CGAffineTransformMakeRotation(degreesToRadians(7))
    }
    
    func updateParallaxOffset(collectionViewBounds bounds: CGRect) {
        let center = CGPoint(x: CGRectGetMidX(bounds), y: CGRectGetMidY(bounds))
        let offsetFromCenter = CGPoint(x: center.x - self.center.x, y: center.y - self.center.y)
        let maxVerticalOffset = (CGRectGetHeight(bounds) / 2) + (CGRectGetHeight(self.bounds) / 2)
        let scaleFactor = 40 / maxVerticalOffset
        
        parallaxOffset = -offsetFromCenter.y * scaleFactor
    }
    
    func currentlySelected() {
        
        playlistTitle.textColor = UIColor.redColor()
    }
    
    func notSelected() {
        
        setOptimizedTextColor()
    }
    
    private func setOptimizedTextColor() {
        
        playlistTitle.textColor = optimalTextColor
        playlistFile.textColor = optimalTextColor
    }
}