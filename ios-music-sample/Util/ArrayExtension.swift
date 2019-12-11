//
//  ArrayExtension.swift
//  ios-music-sample
//
//  Created by owen on 2019/12/11.
//  Copyright © 2019 nekowen. All rights reserved.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Array where Iterator.Element: Equatable {
    func nextItem(_ element: Element) -> Element? {
        guard let index = self.firstIndex(where: { $0 == element}) else {
            return nil
        }
        return self[safe: index + 1]
    }
    
    func prevItem(_ element: Element) -> Element? {
        guard let index = self.firstIndex(where: { $0 == element}) else {
            return nil
        }
        return self[safe: index - 1]
    }
}
