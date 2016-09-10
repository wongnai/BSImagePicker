// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos

/**
Gives UICollectionViewDataSource functionality with a given data source and cell factory
*/
final class PhotoCollectionViewDataSource : NSObject, UICollectionViewDataSource {
    var selections = [PHAsset]()
    var fetchResult: PHFetchResult
    
    weak var dataSource: PhotoCollectionViewDataSourceDataSource?
    
    private let photoCellIdentifier = "photoCellIdentifier"
    private let photosManager = PHCachingImageManager.defaultManager()
    private let imageContentMode: PHImageContentMode = .AspectFill
    
    var imageSize: CGSize = CGSizeZero
    
  init(fetchResult: PHFetchResult, selections: PHFetchResult? = nil) {
        self.fetchResult = fetchResult
        if let selections = selections {
            var selectionsArray = [PHAsset]()
            selections.enumerateObjectsUsingBlock { (asset, idx, stop) -> Void in
                if let asset = asset as? PHAsset {
                    selectionsArray.append(asset)
                }
            }
            self.selections = selectionsArray
        }
    
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        UIView.setAnimationsEnabled(false)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoCellIdentifier, forIndexPath: indexPath) as! PhotoCell
        cell.dataSource = self
        
        // Cancel any pending image requests
        if cell.tag != 0 {
            photosManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        if let asset = fetchResult[indexPath.row] as? PHAsset {
            cell.asset = asset
            
            // Request image
            cell.tag = Int(photosManager.requestImageForAsset(asset, targetSize: imageSize, contentMode: imageContentMode, options: nil) { (result, _) in
                cell.imageView.image = result
            })
            
            // Set selection number
            if let asset = fetchResult[indexPath.row] as? PHAsset, let index = selections.indexOf(asset) {
                cell.selectionSeq = index + 1
                
                cell.selected = true
            } else {
                cell.selected = false
            }
        }
        
        UIView.setAnimationsEnabled(true)
        
        return cell
    }
    
    func registerCellIdentifiersForCollectionView(collectionView: UICollectionView?) {
        collectionView?.registerNib(UINib(nibName: "PhotoCell", bundle: BSImagePickerViewController.bundle), forCellWithReuseIdentifier: photoCellIdentifier)
    }
}

extension PhotoCollectionViewDataSource: PhotoCellDataSource {
    
    func photoCell(photoCell: PhotoCell, overlayViewForSelectedPhoto sequenceNumber: Int, size: CGSize) -> UIView? {
        return dataSource?.photoCollectionViewDataSource(self, overlayViewForSelectedPhoto: sequenceNumber, size: size)
    }
}

protocol PhotoCollectionViewDataSourceDataSource: class {
    func photoCollectionViewDataSource(photoCollectionViewDataSource: PhotoCollectionViewDataSource, overlayViewForSelectedPhoto sequenceNumber: Int, size: CGSize) -> UIView?
}