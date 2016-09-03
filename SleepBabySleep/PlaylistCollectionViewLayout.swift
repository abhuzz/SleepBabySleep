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
        
        let copiedLayoutAttribtes: [UICollectionViewLayoutAttributes] =
            layoutAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        for attributes in copiedLayoutAttribtes {
            let frame = attributes.frame
            attributes.transform = CGAffineTransformMakeRotation(degreesToRadians(-7))
            attributes.frame = CGRectInset(frame, 0, 0)
            
            attributes.size.width = collectionView!.bounds.size.width
        }
        
        return copiedLayoutAttribtes

    }
    
    override func prepareLayout() {
        
        super.prepareLayout()
        
        /*if let collectionView = self.collectionView {
            
            var resizedItem = itemSize

            resizedItem.width = collectionView.bounds.size.width
            resizedItem.height = 180
            
            itemSize = resizedItem
        }*/
    }
}