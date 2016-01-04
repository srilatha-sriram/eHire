//
//  OnlyDecimalValueFormatter.swift
//  EHire
//
//  Created by Vipin Nambiar on 04/01/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import Cocoa

class OnlyDecimalValueFormatter: NSNumberFormatter {
    override func isPartialStringValid(partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        
        
        if (partialString.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) != nil) {
            NSBeep()
            return false
        }
        
        return true
    }
}
