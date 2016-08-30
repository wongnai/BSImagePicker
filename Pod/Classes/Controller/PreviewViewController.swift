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

final class PreviewViewController : UIViewController {
    var imageView: UIImageView?
    weak var delegate: PreviewViewControllerDelegate?
    var indexPath: NSIndexPath?
    private var fullscreen = false
    
    var isSelected: Bool = false {
        didSet {
            updateSelectButton()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.backgroundColor = UIColor.whiteColor()
        
        imageView = UIImageView(frame: view.bounds)
        imageView?.contentMode = .ScaleAspectFit
        imageView?.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(imageView!)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.addTarget(self, action: #selector(PreviewViewController.toggleFullscreen))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
        
        updateSelectButton()
    }
    
    func updateSelectButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: (isSelected) ? "Deselect" : "Select", style: .Plain, target: self, action: #selector(PreviewViewController.selectImage))
    }
    
    func selectImage() {
        if let indexPath = indexPath {
            isSelected = !isSelected
            
            updateSelectButton()
            
            delegate?.previewViewController(self, didSelect: isSelected, indexPath: indexPath)
        }
    }
    
    func toggleFullscreen() {
        fullscreen = !fullscreen
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.toggleNavigationBar()
            self.toggleStatusBar()
            self.toggleBackgroundColor()
        })
    }
    
    func toggleNavigationBar() {
        navigationController?.setNavigationBarHidden(fullscreen, animated: true)
    }
    
    func toggleStatusBar() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func toggleBackgroundColor() {
        let aColor: UIColor
        
        if self.fullscreen {
            aColor = UIColor.blackColor()
        } else {
            aColor = UIColor.whiteColor()
        }
        
        self.view.backgroundColor = aColor
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return fullscreen
    }
}

protocol PreviewViewControllerDelegate: class {
    func previewViewController(previewViewController: PreviewViewController, didSelect isSelect: Bool, indexPath: NSIndexPath)
}
