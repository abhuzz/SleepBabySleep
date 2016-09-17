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
    
    let cellAspectRatio: CGFloat = 3/1
    
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
    
    override func prepare() {

        let itemWidth = collectionViewWidthWithoutInsets
        
        self.itemSize = CGSize(width: itemWidth, height: itemWidth/cellAspectRatio)
        
        super.prepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        let copiedLayoutAttribtes: [UICollectionViewLayoutAttributes] =
            layoutAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        
        copiedLayoutAttribtes.forEach { attributes in
            attributes.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }
        
        return copiedLayoutAttribtes
    }
}
