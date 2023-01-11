//
//  APICaller.swift
//  ChatGPT
//
//  Created by Mukesh Shama on 2022-12-20.
//
import OpenAISwift
import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private var client: OpenAISwift?
    @frozen enum Constants {
        static let key = ""
    }
    private init() {}
    
    public func setup() {
        self.client = OpenAISwift(authToken: Constants.key)
    }
    
    public func getResponse(input: String, completion: @escaping (Result<OpenAI, Error>) -> Void) {
        client?.sendCompletion(with: input,maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model
                completion(.success(output))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}
