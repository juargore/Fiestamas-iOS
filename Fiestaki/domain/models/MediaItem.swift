//
//  MediaItem.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import UIKit

struct MediaItemService: Hashable {
    let url: String
    let isVideo: Bool
    let thumbnail: UIImage?
}

struct ListMediaItemService {
    let list: [MediaItemService]
}
