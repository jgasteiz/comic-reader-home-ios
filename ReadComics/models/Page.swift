//
//  Page.swift
//  ReadComics
//
//  Created by Javi Manzano on 26/01/2018.
//  Copyright © 2018 Javi Manzano. All rights reserved.
//

import Foundation

class Page {
    let src: String
    let hasNextPage: Bool
    let hasPreviousPage: Bool
    
    init (src: String, hasNextPage: Bool, hasPreviousPage: Bool) {
        self.src = src
        self.hasNextPage = hasNextPage
        self.hasPreviousPage = hasPreviousPage
    }
}
