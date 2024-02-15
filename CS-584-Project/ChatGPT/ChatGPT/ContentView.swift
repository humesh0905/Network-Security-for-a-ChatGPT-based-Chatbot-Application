//
//  ContentView.swift
//  ChatGPT
//
//  Created by Pratyay Kumar on 3/29/23.
//

import SwiftUI
import OpenAISwift
import CryptoKit


final class ViewModel: ObservableObject {
    // Input
    init() {}
    // Create the clients
    private var client: OpenAISwift?
    // Please enter the API key generated from openai website.
    func setup() {
        client = OpenAISwift(authToken: "")
    }
    // Send our request to api
    func send(text: String, completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text,
                               completionHandler: {result in
            switch result {
                case .success(let model):
                    if let output = model.choices?.first?.text {
                        completion(output)
                    }
                case .failure:
                    break
                }
            })
    }
}

struct ChatBubble: View {
    let text: String
    let isMyMessage: Bool
    
    var body: some View {
        HStack {
            if isMyMessage {
                Spacer()
                Text(text)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            } else {
                let message = text.trimmingCharacters(in: .whitespaces)
                Text(message)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(8)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var messages = [String]()
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(messages, id: \.self) { message in
                        ChatBubble(text: message, isMyMessage: message.hasPrefix("Me:"))
                    }
                }
            }
            .frame(maxHeight: .infinity)
            HStack {
                TextField("Type here ...", text: $text)
                Button(action: send) {
                    Text("Send")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                        .frame(minWidth: 80)
                }
            }
            .padding(.horizontal)
        }

        .onAppear {
            viewModel.setup()
        }
        .padding()
        .background(Color.white)
    }
    
    func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        messages.append("Me: \(text)")
        viewModel.send(text: text) { response in
            DispatchQueue.main.async {
                let trimmedResponse = response.trimmingCharacters(in: .whitespaces)
                self.messages.append("BoT: \(trimmedResponse)")
                self.text = ""
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
