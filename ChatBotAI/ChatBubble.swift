//
//  ChatBubble.swift
//  ChatGPT
//
//  Created by Mukesh Shama on 2022-12-20.
//

import SwiftUI

struct ChatBubble<Content>: View where Content: View {
    let position: ChatBubblePosition
    let color : Color
    let content: () -> Content
    init(position: ChatBubblePosition, color: Color, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.color = color
        self.position = position
    }
    
    var body: some View {
        HStack(spacing: 0 ) {
            content()
                .padding(.all, 10)
                .foregroundColor(Color.white)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(
                    Image(systemName: "arrowtriangle.left.fill")
                        .foregroundColor(color)
                        .rotationEffect(Angle(degrees: position == .left ? -50 : -130))
                        .offset(x: position == .left ? -5 : 5)
                    ,alignment: position == .left ? .bottomLeading : .bottomTrailing)
                    }
        .padding(position == .left ? .leading : .trailing , 15)
        .padding(position == .right ? .leading : .trailing , 60)
        .frame(width: UIScreen.main.bounds.width, alignment: position == .left ? .leading : .trailing)
    }
    
    func over() -> some View {
        Image(systemName: "person.circle.fill")
            .font(.largeTitle)
    }
}
