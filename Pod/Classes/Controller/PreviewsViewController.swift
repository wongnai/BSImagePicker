//
//  PreviewsViewController.swift
//  Pods
//
//  Created by Koomrhythm Sajjapipat on 8/30/16.
//
//

import UIKit

class PreviewsViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    weak var dataSource: PreviewsViewControllerDataSource?
    weak var delegate: PreviewsViewControllerDelegate?
    var selectedIndex: Int = 0
    var isSelected = false
    
    lazy var pageController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        return pageController
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageController.view.frame = containerView.bounds
        pageController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        containerView.addSubview(pageController.view)
        pageController.setViewControllers([createPreviewViewController(selectedIndex)],
                                          direction: .Forward,
                                          animated: true,
                                          completion: nil)
        
        updateSelectButton(selectedIndex)
        
        closeButton.setImage(UIImage(named: "photo-full-screen-close-button", inBundle: BSImagePickerViewController.bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        closeButton.addTarget(self, action: #selector(clese(_:)), forControlEvents: .TouchUpInside)
        selectButton.setImage(UIImage(named: "check-box-inactive", inBundle: BSImagePickerViewController.bundle, compatibleWithTraitCollection: nil), forState: .Normal)
        selectButton.setImage(UIImage(named: "check-box-active", inBundle: BSImagePickerViewController.bundle, compatibleWithTraitCollection: nil), forState: .Selected)
        selectButton.addTarget(self, action: #selector(selectImage(_:)), forControlEvents: .TouchUpInside)
    }
    
    func clese(sender: UIButton) {
        delegate?.dismiss(self)
    }
    
    func updateSelectButton(index: Int) {
        let isSelect = dataSource?.previewsViewController(self, isSelectedAt: index)
        selectButton.selected = isSelect!
    }
    
    func selectImage(sender: UIButton) {
        dataSource?.previewsViewController(self, didSelect: selectedIndex, isSelect: !isSelected)
        updateSelectButton(selectedIndex)
    }
    
    func createPreviewViewController(index: Int) -> PreviewViewController {
        let previewViewController = PreviewViewController(nibName: nil, bundle: nil)
        previewViewController.index = index
        dataSource?.previewsViewController(self, index: previewViewController.index, imageView: previewViewController.imageView)
        return previewViewController
    }
}

extension PreviewsViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let previewViewController = viewController as? PreviewViewController else {
            return nil
        }
        
        let numberOfPhotos = dataSource?.numberOfPagesWith(self)
        
        let previousIndex = previewViewController.index - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard numberOfPhotos > previousIndex else {
            return nil
        }
        
        return createPreviewViewController(previousIndex)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let previewViewController = viewController as? PreviewViewController else {
            return nil
        }
        
        let numberOfPhotos = dataSource?.numberOfPagesWith(self)
        
        let nextIndex = previewViewController.index + 1
        
        guard numberOfPhotos != nextIndex else {
            return nil
        }
        
        guard numberOfPhotos > nextIndex else {
            return nil
        }
        
        return createPreviewViewController(nextIndex)
    }
}

extension PreviewsViewController: UIPageViewControllerDelegate {
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let viewController = pageViewController.viewControllers?.last as! PreviewViewController
        let index = viewController.index
        selectedIndex = index
        updateSelectButton(index)
    }
}

protocol PreviewsViewControllerDataSource: class {
    func numberOfPagesWith(previewsViewController: PreviewsViewController) -> Int
    func previewsViewController(previewsViewController: PreviewsViewController, index: Int, imageView: UIImageView)
    func previewsViewController(previewsViewController: PreviewsViewController, isSelectedAt index: Int) -> Bool
    func previewsViewController(previewsViewController: PreviewsViewController, didSelect index: Int, isSelect: Bool)
}

protocol PreviewsViewControllerDelegate: class {
    func dismiss(previewsViewController: PreviewsViewController)
}
