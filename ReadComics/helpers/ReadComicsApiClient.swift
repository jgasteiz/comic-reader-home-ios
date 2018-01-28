//
//  ReadComicsApiClient.swift
//  ReadComics
//
//  Created by Javi Manzano on 25/01/2018.
//  Copyright © 2018 Javi Manzano. All rights reserved.
//

import Alamofire
import Foundation

class ReadComicsApiClient {
    static let sharedInstance = ReadComicsApiClient()
    
    let localMode = false
    
    let readerUrl: String
    let directoryApiUrl: String
    let comicApiUrl: String
    
    init() {
        if (self.localMode) {
            readerUrl = "http://192.168.0.19:8000"
        } else {
            readerUrl = "http://reader.local"
        }
        
        directoryApiUrl = "\(readerUrl)/api/directory/"
        comicApiUrl = "\(readerUrl)/api/comic/"
    }
    
    func getDirectoryContents(
        directory: Directory?,
        onItemsFetched: @escaping ([Comic], [Directory]) -> Void,
        onError: @escaping () -> Void) {
        
        let url: String
        if (directory != nil) {
            url = "\(directoryApiUrl)\(directory!.path)/"
        } else {
            url = directoryApiUrl
        }
        
        Alamofire
            .request(
                url,
                method: .get,
                encoding: JSONEncoding.default
            )
            .responseJSON{ response in
                switch response.result {
                case .success:
                    let jsonResponse = response.result.value as? NSDictionary
                    let comics = self.getComicsFromJson(jsonResponse: jsonResponse, parentDirectory: directory)
                    let directories = self.getDirectoriesFromJson(jsonResponse: jsonResponse, parentDirectory: directory)
                    onItemsFetched(comics, directories)
                case .failure(let error):
                    debugPrint(error)
                    onError()
                }
        }
    }
    
    func getPageImage (
        comicPath: String,
        pageNum: Int,
        onPageFetched: @escaping (Page) -> Void,
        onError: @escaping () -> Void) {
        
        let url = "\(comicApiUrl)\(comicPath)/\(pageNum)/"
        
        Alamofire
            .request(
                url,
                method: .get,
                encoding: JSONEncoding.default
            )
            .responseJSON{ response in
                switch response.result {
                case .success:
                    guard let jsonResponse = response.result.value as? NSDictionary else {
                        print("No json found in api response - getPageImage")
                        return
                    }
                    let page = Page(
                        src: "\(self.readerUrl)\(jsonResponse["page_src"] as! String)",
                        hasNextPage: jsonResponse["has_next_page"] as! Bool,
                        hasPreviousPage: jsonResponse["has_previous_page"] as! Bool
                    )
                    onPageFetched(page)
                case .failure(let error):
                    debugPrint(error)
                    onError()
                }
        }
    }
    
    // MARK: - Private functions
    
    private func getDirectoriesFromJson(jsonResponse: NSDictionary?, parentDirectory: Directory?) -> [Directory] {
        var directoryList: [Directory] = []
        
        if let jsonResponse = jsonResponse,
            let pathContents = jsonResponse["path_contents"] as! NSDictionary?,
            let directoryListJson = pathContents["directories"] as! [NSDictionary]?
        {
            // Add the fetched directories to the array
            for directoryJSON in directoryListJson {
                directoryList.append(Directory(
                    title: directoryJSON["name"] as! String,
                    path: directoryJSON["path"] as! String,
                    parentDirectory: parentDirectory
                ))
            }
        }
        
        return directoryList
    }
    
    private func getComicsFromJson(jsonResponse: NSDictionary?, parentDirectory: Directory?) -> [Comic] {
        var comicList: [Comic] = []
        
        if let jsonResponse = jsonResponse,
            let pathContents = jsonResponse["path_contents"] as! NSDictionary?,
            let comicListJson = pathContents["comics"] as! [NSDictionary]?
        {
            // Add the fetched comics to the array
            for comicJSON in comicListJson {
                comicList.append(Comic(
                    title: comicJSON["name"] as! String,
                    path: comicJSON["path"] as! String,
                    parentDirectory: parentDirectory
                ))
            }
        }
        
        return comicList
    }
}
