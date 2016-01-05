//
//  Utility.swift
//  EHire
//
//  Created by Pavithra G. Jayanna on 05/01/16.
//  Copyright © 2016 Exilant Technologies. All rights reserved.
//

import Cocoa

class Utility: NSObject {
    
    class func alertPopup(data:String,informativeText:String){
        let alert:NSAlert = NSAlert()
        alert.messageText = data
        
        alert.informativeText = informativeText
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        alert.alertStyle = NSAlertStyle.CriticalAlertStyle
        let res = alert.runModal()
        if res == NSAlertFirstButtonReturn {
//            if inTag == 1{
//                deleteItem()
//            }
        }
    }
}
