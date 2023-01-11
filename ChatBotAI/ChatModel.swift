//
//  ChatModel.swift
//  ChatGPT
//
//  Created by Mukesh Shama on 2022-12-20.
//

import Foundation
class ChatModel: ObservableObject {
    var text = ""
    @Published var arrayOfMessages : [String] = []
    @Published var arrayOfPositions : [ChatBubblePosition] = []
    @Published var position = ChatBubblePosition.right
}
