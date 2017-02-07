//
//  EmoticonInputView.swift
//  Weibo
//
//  Created by CJS on 16/9/25.
//  Copyright © 2016年 CJS. All rights reserved.
//

import UIKit

let cellId = "cellId"

class EmoticonInputView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: EmoticonToolbar!
    @IBOutlet weak var pageControl: UIPageControl!
    
    fileprivate var selectedEmoticonCallback: ((_ emoticon:Emoticon?)->())?
    
    class func inputView(selectedEmoticon:@escaping (_ emoticon:Emoticon?)->()) -> EmoticonInputView{
        let nib = UINib(nibName: "EmoticonInputView", bundle: nil)
        let v = nib.instantiate(withOwner: self, options: nil)[0] as! EmoticonInputView
        v.selectedEmoticonCallback = selectedEmoticon
        return v
    }

    override func awakeFromNib() {
//        let nib = UINib(nibName: "EmoticonCell", bundle: nil)
//        collectionView.register(nib, forCellWithReuseIdentifier: cellId)
        toolbar.delegate = self
        collectionView.register(EmoticonCell.self, forCellWithReuseIdentifier: cellId)
        
        let bundle = EmoticonManager.shared.bundle
        guard let normalImage = UIImage(named: "compose_keyboard_dot_normal", in: bundle, compatibleWith: nil),
            let selectedImage = UIImage(named: "compose_keyboard_dot_selected", in: bundle, compatibleWith: nil) else {
                return
        }
        
//        pageControl.pageIndicatorTintColor = UIColor(patternImage: normalImage)
//        pageControl.currentPageIndicatorTintColor = UIColor(patternImage: selectedImage)
        
        pageControl.setValue(normalImage, forKey: "_pageImage")
        pageControl.setValue(selectedImage, forKey: "_currentPageImage")
    }
}

extension EmoticonInputView: EmoticonToolbarDelegate {
    func emoticonToolbarDidSelectedItemIndex(toolbar: EmoticonToolbar, index: Int) {
        toolbar.selectedIndex = index
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }
}

extension EmoticonInputView: UICollectionViewDataSource{
 
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return EmoticonManager.shared.packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return EmoticonManager.shared.packages[section].numberOfPages
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! EmoticonCell
        cell.emoticons = EmoticonManager.shared.packages[indexPath.section].emoticon(page: indexPath.item)
        cell.delegate = self
        return cell
    }
}

extension EmoticonInputView: UICollectionViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var center = scrollView.center
        center.x += scrollView.contentOffset.x
        let paths = collectionView.indexPathsForVisibleItems
        var targetIndexPath: IndexPath?
        for indexPath in paths {
            let cell = collectionView.cellForItem(at: indexPath)
            if cell?.frame.contains(center) == true {
                targetIndexPath = indexPath
                break
            }
        }
        
        guard let target = targetIndexPath else { return  }
        toolbar.selectedIndex = target.section
        
        pageControl.numberOfPages = collectionView.numberOfItems(inSection: target.section)
        pageControl.currentPage = target.item
    }
}

// MARK: - EmoticonCellDelegate
extension EmoticonInputView: EmoticonCellDelegate{
    func emoticonCellSelectedEmoticon(cell: EmoticonCell, emoticon: Emoticon?) {
        //
        selectedEmoticonCallback?(emoticon)
        
        guard let emoticon = emoticon else {
            return
        }
        let indexPath = collectionView.indexPathsForVisibleItems[0]
        if indexPath.section == 0 {
            return
        }
        EmoticonManager.shared.recentEmotion(em: emoticon)
        var indexSet = IndexSet()
        indexSet.insert(0)
        collectionView.reloadSections(indexSet)
    }
}
