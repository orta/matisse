//
//  ViewController.swift
//  SampleApp
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import UIKit
import Matisse


class MainViewController: UICollectionViewController {
    
    private let itemSize: CGFloat = 150.0
    
    private let imageURLs = [
        NSURL(string: "https://artseer.files.wordpress.com/2014/04/050rt_1.jpg")!,
        NSURL(string: "https://worldonaforkdotcom.files.wordpress.com/2013/10/untitled-126.jpg")!,
        NSURL(string: "https://bellaremyphotography.files.wordpress.com/2015/02/bma7feb15-01118.jpg")!,
    ]
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInset.top = 40.0
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let itemsPerRow = floor(view.bounds.width / itemSize)
        let exactItemSize = floor(view.bounds.width / itemsPerRow)
        
        (collectionViewLayout as! UICollectionViewFlowLayout).itemSize = CGSize(width: exactItemSize, height: exactItemSize)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImageCell
        let url = imageURLs[indexPath.row % imageURLs.count]
        
        Matisse.load(url)
            .resizeTo(width: itemSize, height: itemSize, contentMode: .ScaleAspectFill)
            .showIn(cell.imageView)
        
        return cell
    }
}

