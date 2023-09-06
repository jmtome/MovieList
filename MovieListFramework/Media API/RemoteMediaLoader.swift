//
//  RemoteMediaLoader.swift
//  MovieListFramework
//
//  Created by macbook on 06/09/2023.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}

public final class RemoteMediaLoader {
    private let url: URL
    private let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load() {
        client.get(from: url)
    }
}
