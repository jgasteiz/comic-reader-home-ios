//
//  Comic.swift
//  ReadComics
//
//  Created by Javi Manzano on 25/01/2018.
//  Copyright © 2018 Javi Manzano. All rights reserved.
//

import Foundation

class Comic {
    let title: String
    let path: String
    let parentDirectory: Directory?
    // TODO: make this properly
    var numPages: Int = 1000
    
    init (title: String, path: String, parentDirectory: Directory?) {
        self.title = title
        self.path = path
        self.parentDirectory = parentDirectory
    }
}
