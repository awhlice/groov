//
//  Message.swift
//  groov
//
//  Created by Alice Wu on 3/31/21.
//

import UIKit
import Firebase
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String = ""
    var sentDate: Date
    var kind: MessageKind
}
