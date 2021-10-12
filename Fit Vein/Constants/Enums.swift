//
//  Enums.swift
//  Fit Vein
//
//  Created by Łukasz Janiszewski on 12/10/2021.
//

import Foundation

public enum Country: String, CaseIterable, Identifiable {
    case poland
    
    public var id: String { self.rawValue }
}

public enum City: String, CaseIterable, Identifiable {
    case łódź
    case warszawa
    case krakow
    case wroclaw
    case lublin
    case gdansk
    case gdynia
    case warka
    case żywiec
    case sopot
    
    public var id: String { self.rawValue }
}

public enum Language: String, CaseIterable, Identifiable {
    case english
    case polish
    
    public var id: String { self.rawValue }
}
