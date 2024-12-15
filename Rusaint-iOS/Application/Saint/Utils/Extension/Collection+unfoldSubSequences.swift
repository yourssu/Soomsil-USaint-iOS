//
//  Collection + unfoldSubSequences.swift
//  SaintKit
//
//  Created by Gyuni on 2022/06/21.
//

import Foundation

extension Collection {
    func unfoldSubSequences(limitedTo maxLength: Int) -> UnfoldSequence<SubSequence, Index> {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return self[start..<end]
        }
    }
    func subSequences(of num: Int) -> [SubSequence] {
        .init(unfoldSubSequences(limitedTo: num))
    }
}
