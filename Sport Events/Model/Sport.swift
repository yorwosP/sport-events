//
//  Event.swift
//  Sport Events
//
//  holds the Sport(s) and Event(s) data (Events encapsulated in Sport)
//  also used to decode JSON from API
//  Created by Yorwos Pallikaropoulos on 2/5/22.
//

import Foundation


struct Event:Codable{
    var eventID: String
    var sportID: String
    var eventName: String
    var eventNameShort: String
    var eventStartDate: Int
    var isStarred: Bool = false  // this one used only by Model (not API)
    // map API's values to our properties
    enum CodingKeys:String, CodingKey{
        case eventID = "i"
        case sportID = "si"
        case eventName = "d"
        case eventNameShort = "sh" // is this optional? (was missing in documentation)
        case eventStartDate = "tt"
    }
    
    
    
}


struct Sport:Codable{
    var sportID: String
    var sportName: String
    var events: [Event]
    var isSelected: Bool = false // this one used only by Model (not API)
    // map API's values to our properties
    enum CodingKeys:String, CodingKey{
        case sportID = "i"
        case sportName = "d"
        case events = "e"
    }
    

}

extension Event:Equatable{
    static func == (lhs: Event, rhs: Event) -> Bool{
        return lhs.eventID == rhs.eventID
    }
}
