//
//  CustomScrollView.swift
//  PanicPass
//
//  Created by Zhao on 2025/11/25.
//

import UIKit

class CustomScrollView: UIScrollView {
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        // 对于UIButton，不取消触摸事件
        if view is UIButton {
            return false
        }
        return super.touchesShouldCancel(in: view)
    }
    
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        // 如果是按钮，允许触摸开始
        if view is UIButton {
            return true
        }
        return super.touchesShouldBegin(touches, with: event, in: view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
    }
    
    func setupScrollView() {
        // 确保立即响应按钮点击
        delaysContentTouches = false
        // 允许滚动时取消内容触摸（这样才能滚动）
        canCancelContentTouches = true
    }
}

