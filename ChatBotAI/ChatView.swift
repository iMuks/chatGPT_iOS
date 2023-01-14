//
//  ChatView.swift
//  ChatGPT
//
//  Created by Mukesh Shama on 2022-12-20.
//

import SwiftUI
import Speech


struct ChatView: View {
    @ObservedObject var model = ChatModel()
    @FocusState private var isFocused: Bool
    @FocusState private var isKeyboardOpen: Bool
    @EnvironmentObject var swiftUISpeech:SwiftUISpeech
    let height: CGFloat = 33
    
    @State var isPressed:Bool = false
    @State var actionPop:Bool = false
    
    @State var currentText: String = ""
    
    var body: some View {
        NavigationView(content: {
            VStack(spacing: 0) {
                chatContentView()
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .background(Color("toolbar"))
                toolBarView()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                        VStack {
                            Text("Chat-GPT3").font(.headline)
                            Text("Online").font(.footnote)
                                .padding(.trailing)
                                .fontWeight(.light)
                        }
                    }
                }
            }
            .background(Color("toolbar"))
            .onAppear(perform: {
            })
            .onTapGesture {
                isFocused = false
            }

        })
        
        
    }
    
}

extension ChatView {
    
    fileprivate func showNavigation() -> NavigationView<some View> {
        return NavigationView(content: {
            chatContentView()
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Image(systemName:"brain.head.profile")
                        VStack {
                            Text("Chat GPT3").font(.headline)
                            if #available(iOS 16.0, *) {
                                Text("Online").font(.footnote)
                                    .padding(.trailing)
                                    .fontWeight(.light)
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button("Add 1") {}
                }
            }
        })
    }

    
    func chatContentView() -> some View {
        GeometryReader { geo in
            VStack() {
                //MARK:- ScrollView
                ChatScrollView(scrollToEnd: true) {
                    LazyVStack {
                        ForEach(0..<model.arrayOfMessages.count, id:\.self) { index in
                            HStack(alignment: .bottom, spacing: 15) {
                                ChatBubble(position: model.arrayOfPositions[index], color: model.arrayOfPositions[index] == ChatBubblePosition.right ? Color("outputColor") : Color("inputColor")) {
                                    Text(model.arrayOfMessages[index])
                                }
                            }
                        }
                    }
                }.padding(.top)
            }
            .foregroundColor(Color("toolbar"))
            .background(Color("toolbar"))
            .padding(.top, -15)
        }
    }
    
    func headerView() -> some View {
        ZStack() {
            HStack() {
                Spacer()
                Image(systemName: "person.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color(.black))
                VStack(spacing: 0) {
                    Text("Chat - GPT")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(.black))
                        .multilineTextAlignment(.leading)
                        .transition(.opacity)
                    
                    Text("Online")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 0)
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 5)
        
        
    }
    
    func toolBarView() -> some View {
        VStack {
            let height: CGFloat = 39
            HStack {
                // record speech
//                recordButton()
                TextField(swiftUISpeech.isRecording ? "Start Recording..." : "Start typing here...", text: $currentText ,
                          onEditingChanged: { (isBegin) in

                    if isBegin {
                        print("Begins editing")
                        
                    } else {
                        isFocused = false
                        print("Finishes editing")
                    }
                },
                    onCommit: {
                    print("commit")
                    isFocused = false

                }).padding(.horizontal, 10)
                .frame(height: height)
                .foregroundColor(.white)
                .background(
                    self.swiftUISpeech.isRecording ? .clear : Color("toolbar")
                )
                .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(.white, lineWidth: 2))
                .focused($isFocused)
                    sendButton()
            }
            .frame(height: height)
        }.padding(.vertical)
            .padding(.horizontal)
    }
    
    func recordButton() -> some View {
        Button(action: {
            if(self.swiftUISpeech.getSpeechStatus() == "Denied - Close the App"){// checks status of auth if no auth pop up error
                self.actionPop.toggle()
            } else {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.3, blendDuration: 0.3)){self.swiftUISpeech.isRecording.toggle()}// button animation
                if self.swiftUISpeech.isRecording {
                    self.swiftUISpeech.startRecording()
                } else {
                    self.currentText = self.swiftUISpeech.outputText
                    callGPT(self.currentText)
                    self.swiftUISpeech.stopRecording()
                    self.currentText = ""
                }
            }
        }) {
            Image(systemName: "mic.fill")
                .foregroundColor(.white)
                .frame(width: height, height: height)
                .background(
                    swiftUISpeech.isRecording ?
                    Circle()
                        .foregroundColor(Color(.white)) : Circle().foregroundColor(Color(.white))
                )
        }
    }
    
    func sendButton() -> some View {
        Button(action: {
            callGPT(currentText)
            self.currentText = ""
            isFocused = false
        }) {
            Image(systemName: "paperplane.fill")
                .foregroundColor(.white)
                .frame(width: height, height: height)
                .background(
                    !currentText.isEmpty ? Circle().foregroundColor(Color(.black)) : Circle().foregroundColor(Color(.black).opacity(0.5))
                )
        }
    }
    
    func callGPT(_ text: String) {
        if text == "" {
            return
        }
        model.text = text
        model.position = ChatBubblePosition.right
        model.arrayOfPositions.append(model.position)
        model.arrayOfMessages.append(model.text)
        APICaller.shared.getResponse(input: model.text) { result in
            model.text = ""
            isFocused = false
            switch result {
            case .success(let output):
                DispatchQueue.main.async {
                    model.position = ChatBubblePosition.left
                    model.arrayOfPositions.append(model.position)
                    for text in output.choices {
                        model.arrayOfMessages.append(text.text)
                    }
                }
            case .failure(let failure):
                print("Error -\(failure)")
            }
        }
    }
    
}
