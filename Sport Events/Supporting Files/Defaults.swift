//
//  Defaults.swift
//  Sport Events
//
//  Constants used in app
//  Created by Yorwos Pallikaropoulos on 2/5/22.
//

import Foundation
import UIKit // needed to be able to use CGFloat, UIColor etc

// API related constants
enum API{
    static let url = URL(string: "https://618d3aa7fe09aa001744060a.mockapi.io/api/sports")!
    static let method = "GET"
    
    static let header = "application/json"
    static let httpContentType = "Content-Type"
    static let httpAccept = "Accept"
}


// UI related constants
enum UI{
    
    static let sportIcons = ["FOOT":"⚽️",
                             "BASK":"🏀",
                             "TENN":"🎾",
                             "TABL":"🏓",
                             "VOLL":"🏐",
                             "ESPS":"🎮",
                             "ICEH":"🏒",
                             "HAND":"🥅",
                             "BCHV":"🏐",
                             "SNOO":"🎱",
                             "BADM":"🏸"
                             ]
    
    static let defaultIcon = "🎽"
    
    
    static let expandedHeight: CGFloat = 125
    static let collapsedHeight: CGFloat = 2
    static let expandedIcon = "∧"
    static let collapsedIcon = "∨"
    static let estimatedRowHeight:CGFloat = 180
    
    static let collectionViewStandardItemSize = CGSize(width: 115, height: 115)
    static let standardAnimationDuration: Double = 0.25
    

}

