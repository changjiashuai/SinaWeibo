//
//  EmoticonLayout.swift
//  Weibo
//
//  Created by CJS on 16/9/25.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

class EmoticonLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        itemSize = collectionView.bounds.size
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
    }
}
