//
//  InfiniteScrollView.swift
//  Cosmos
//
//  Created by Lee Danatech on 2021/5/21.
//

import UIKit

public class InfiniteScrollView : UIScrollView {

    public override func layoutSubviews() {
        super.layoutSubviews()
        var offset = contentOffset
        if offset.x < 0 {
            offset.x = contentSize.width - frame.width
        } else if offset.x >= contentSize.width - frame.width {
            offset.x = 0
        }

        if offset.y < 0 {
            offset.y = contentSize.height - frame.height
        } else if offset.y >= contentSize.height - frame.height {
            offset.y = 0
        }
        contentOffset = offset
    }
}
