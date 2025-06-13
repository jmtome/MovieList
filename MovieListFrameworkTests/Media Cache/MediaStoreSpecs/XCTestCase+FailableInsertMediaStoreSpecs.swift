//
//  XCTestCase+FailableInsertMediaStoreSpecs.swift
//  MovieListFrameworkTests
//
//  Created by macbook on 18/09/2023.
//

import Foundation

import XCTest
import MovieListFramework

extension FailableInsertMediaStoreSpecs where Self: XCTestCase {
    func assertThatInsertDeliversErrorOnInsertionError(on sut: MediaStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueItems().local, Date()), to: sut)
        
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: MediaStore, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueItems().local, Date()), to: sut)
        
        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
