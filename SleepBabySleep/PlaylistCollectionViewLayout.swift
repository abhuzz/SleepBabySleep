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
    
    var collectionViewWidthWithoutInsets: CGFloat {
        get {
            guard let collectionView = self.collectionView else { return 0 }
            let collectionViewSize = collectionView.bounds.size
            let widthWithoutInsets = collectionViewSize.width
                - self.sectionInset.left - self.sectionInset.right
                - collectionView.contentInset.left - collectionView.contentInset.right
            return widthWithoutInsets
        }
    }
    
    let cellAspectRatio: CGFloat = 3/1
    
    override func prepareLayout() {

        let itemWidth = collectionViewWidthWithoutInsets
        self.itemSize = CGSize(width: itemWidth, height: itemWidth/cellAspectRatio)
        
        super.prepareLayout()
    }
    
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

}