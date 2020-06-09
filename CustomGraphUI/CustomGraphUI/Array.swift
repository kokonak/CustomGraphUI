//
//  Array.swift
//  CustomGraphUI
//
//  Created by kokonak on 2020/06/09.
//  Copyright © 2020 kokonak. All rights reserved.
//

extension Array {
    subscript(item index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
