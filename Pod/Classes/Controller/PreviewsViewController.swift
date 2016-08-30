//
//  PreviewsViewController.swift
//  Pods
//
//  Created by Koomrhythm Sajjapipat on 8/30/16.
//
//

import UIKit

class PreviewsViewController: UIViewController {
    var imageView = UIImageView()
    
    weak var dataSource: PreviewsViewControllerDataSource?
    var selectedIndex: Int = 0
    var isSelected = false
    
    lazy var pageController: UIPageViewController = {
        let pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        return pageController
    }()
    
    convenience init(dataSource: PreviewsViewControllerDataSource, selectedIndex: Int) {
        self.init(nibName: nil, bundle: nil)
        
        self.dataSource = dataSource
        self.selectedIndex = selectedIndex
        
        pageController.view.frame = view.bounds
        pageController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(pageController.view)
        pageController.setViewControllers([createPreviewViewController(selectedIndex)],
                                          direction: .Forward,
                                          animated: true,
                                          completion: nil)
        
        pageController.view.hidden = true
        updateSelectButton(selectedIndex)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        imageView.frame = view.bounds
        imageView.contentMode = .ScaleAspectFit
        imageView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateSelectButton(index: Int) {
        let isSelect = dataSource?.previewsViewController(self, isSelectedAt: index)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: (isSelect == true) ? "Deselect" : "Select", style: .Plain, target: self, action: #selector(PreviewsViewController.selectImage))
        isSelected = (isSelect == true)
    }
    
    func selectImage() {
        dataSource?.previewsViewController(self, didSelect: selectedIndex, isSelect: !isSelected)
        updateSelectButton(selectedIndex)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        imageView.hidden = true
        pageController.view.hidden = false
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
