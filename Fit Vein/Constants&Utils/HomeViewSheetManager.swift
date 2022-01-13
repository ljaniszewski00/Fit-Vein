//
//  HomeViewSheetManager.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 08/01/2022.
//

import Foundation

class SheetManager: ObservableObject {
    enum Sheet {
        case addView
        case editView
    }
    
    var postID: String?
    var postText: String?
    var commentID: String?
    var commentText: String?
    @Published var showSheet = false
    @Published var whichSheet: Sheet? = nil
}
