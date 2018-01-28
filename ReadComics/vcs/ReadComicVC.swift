//
//  ReadComicVC.swift
//  ReadComics
//
//  Created by Javi Manzano on 25/01/2018.
//  Copyright © 2018 Javi Manzano. All rights reserved.
//

import UIKit
import AlamofireImage

class ReadComicVC: UIViewController {

    let apiClient = ReadComicsApiClient.sharedInstance
    
    @IBOutlet weak var imageView: UIImageView!
    
    var comic: Comic?
    var currentPage: Page?
    var currentPageNum: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadCurrentPage()
    }

    @IBAction func exit(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func loadCurrentPage() {
        guard let comic = comic else {
            print("No comic to load")
            return
        }
        
        apiClient.getPageImage(
            comicPath: comic.path,
            pageNum: self.currentPageNum,
            onPageFetched: {(page) in
                self.currentPage = page
                guard let pageUrlString = page.src.stringByAddingPercentEncodingForRFC3986() else {
                    print("Could not build a url from page.src")
                    return
                }
                self.setPageImage(currentPageURL: URL(string: pageUrlString))
            },
            onError: {
                print("An error occurred fetching the page")
            }
        )
    }
    
    private func setPageImage(currentPageURL: URL?) {
        guard let currentPageURL = currentPageURL else {
            print("setPageImage didn't get a proper URL")
            return
        }
        imageView.af_setImage(withURL: currentPageURL)
    }
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    }
}

