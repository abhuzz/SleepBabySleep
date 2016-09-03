//
//  PlaylistCollectionViewLayout.swift
//  SleepBabySleep
//
//  Created by Stefan Mehnert on 02/09/16.
//  Copyright © 2016 Stefan Mehnert. All rights reserved.
//

import Foundation
import UIKit

class PlaylistCollectionViewLayout : UICollectionViewFlowLayout {
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let layoutAttributes = super.layoutAttributesForElementsInRect(rect) else { return nil }
        
        for attributes in layoutAttributes {
            let frame = attributes.frame
            attributes.transform = CGAffineTransformMakeRotation(degreesToRadians(-10))
            attributes.frame = CGRectInset(frame, 0, 0)
        }
        
        return layoutAttributes

    }
    
    override func prepareLayout() {
        
        super.prepareLayout()
        
        if let collectionView = self.collectionView {
            
            var resizedItem = itemSize

            resizedItem.width = collectionView.bounds.size.width
            
            itemSize = resizedItem
        }
    }
}