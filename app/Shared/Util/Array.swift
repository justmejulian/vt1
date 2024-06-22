//
//  Array.swift
//
//  Created by Paul Hudson
//  https://www.hackingwithswift.com/example-code/language/how-to-split-an-array-into-chunks


import Foundation

// todo replace with alogorithms
// https://www.hackingwithswift.com/articles/243/write-better-code-with-swift-algorithms
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
