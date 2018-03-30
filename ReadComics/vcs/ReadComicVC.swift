//
//  ReadComicVC.swift
//  ReadComics
//
//  Created by Javi Manzano on 25/01/2018.
//  Copyright © 2018 Javi Manzano. All rights reserved.
//

import UIKit
import AlamofireImage

enum FitMode {
    case width
    case height
}

class ReadComicVC: UIViewController {
    
    // MARK: - Properties
    
    let apiClient = ReadComicsApiClient.sharedInstance
    var comic: Comic?
    var currentPage: Page?
    var currentPageNum: Int = 0
    var fitMode: FitMode = FitMode.height


    // MARK: - IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ReadComicVC.handleTapOnScrollView(_:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        
        screenRotated()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ReadComicVC.screenRotated),
            name: NSNotification.Name.UIDeviceOrientationDidChange,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationBar.isHidden = true
        loadCurrentPage()
    }

    
    // MARK: - IBActions
    
    @IBAction func exit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private functions
    
    private func loadCurrentPage() {
        guard let comic = comic else {
            print("No comic to load")
            return
        }
        
        let pageUrlString = apiClient.getPageImageSrc(
            comicPath: comic.path,
            pageNum: currentPageNum
        )
        setPageImage(currentPageURL: URL(string: pageUrlString))
    }
    
    private func setPageImage(currentPageURL: URL?) {
        guard let currentPageURL = currentPageURL else {
            print("setPageImage didn't get a proper URL")
            return
        }
        imageView.af_setImage(withURL: currentPageURL, completion: { _ in
            self.updateScrollViewZoomScale(size: self.view.bounds.size)
        })
    }
    
    private func _previousPage() {
        if currentPageNum > 0 {
            currentPageNum = currentPageNum - 1
        }
        loadCurrentPage()
    }
    
    private func _nextPage() {
        guard let comic = comic else {
            print("No comic, no next page")
            return
        }
        if currentPageNum < comic.numPages - 1 {
            currentPageNum = currentPageNum + 1
        }
        loadCurrentPage()
    }
}

// MARK: - Extensions
extension ReadComicVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(size: view.bounds.size)
    }
    
    func updateScrollViewZoomScale(size: CGSize) {
        // Update the zoom scale of the page depending on the `fitMode`.
        
        if let image = imageView.image {
            let zoomScale: CGFloat
            if fitMode == FitMode.height {
                zoomScale = scrollView.bounds.size.height / image.size.height
            } else {
                zoomScale = scrollView.bounds.size.width / image.size.width
            }
            
            scrollView.minimumZoomScale = zoomScale
            scrollView.zoomScale = zoomScale
            scrollView.setContentOffset(CGPoint.zero, animated: false)
            updateConstraintsForSize(size: view.bounds.size)
        }
    }
    
    func updateConstraintsForSize(size: CGSize) {
        // Update the top/bottom and leading/trailing constraints.
        // General rule: always stick to top and horizontally centered.
        view.layoutIfNeeded()
        let topBottomOffset = max(0, (size.height - imageView.frame.height) / 2)
        let sideOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewTopConstraint.constant = topBottomOffset
        imageViewBottomConstraint.constant = topBottomOffset
        imageViewLeadingConstraint.constant = sideOffset
        imageViewTrailingConstraint.constant = sideOffset
        view.layoutIfNeeded()
        
    }
    
    @objc func handleTapOnScrollView(_ sender: UITapGestureRecognizer) {
        // Handle a tap on the scroll view. If the left/right side are tapped,
        // navigate to the previous/next page respectivelly.
        // If the center is tapped, show/hide the navigation bar.
        
        let tapLocation = sender.location(in: view)
        // Check if the tap is on the left or on the right.
        let viewWidth = view.frame.width
        let tapXLocation = ((viewWidth - tapLocation.x) / viewWidth) * 100
        // Between 70 and 100, it's a tap left. Between 0 and 30 it's right.
        if tapXLocation < 20 {
            _nextPage()
        } else if tapXLocation > 80 {
            _previousPage()
        }
        else {
            navigationBar.isHidden = !navigationBar.isHidden
        }
    }
    
    @objc func screenRotated() {
        // Change the default fitMode when the screen is rotated.
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            fitMode = FitMode.width
        } else if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            fitMode = FitMode.height
        }
    }
}

extension ReadComicVC: UIGestureRecognizerDelegate {
    
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}
