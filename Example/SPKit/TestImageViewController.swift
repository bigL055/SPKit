//
//  TestImageViewController.swift
//  SPKit_Example
//
//  Created by linhey on 2018/12/15.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import Then
import SPKit
import SnapKit

class TestImageViewController: BaseViewController {
  
  let imageView = UIImageView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    contentView.addSubview(imageView)
    
    imageView.do { (item) in
      item.snp.makeConstraints({ (make) in
        make.top.left.equalToSuperview().offset(8)
        make.bottom.right.equalToSuperview().offset(-8)
      })
    }
    
    items.append(TableElement(title: "复原", subtitle: "") {
      self.imageView.sp.removeSubviews()
      self.imageView.image = nil
    })
    
    items.append(TableElement(title: "从网络上下载图片", subtitle: "imageView.sp.download(from: url,placeholder: image,completionHandler: nil)") {
      let url = URL(string: "https://raw.githubusercontent.com/linhay/SPKit/master/Screenshot/logo.jpg")!
      self.imageView.sp.download(from: url,
                            placeholder: UIImage(named: "loading"),
                            completionHandler: nil)
    })
    
    items.append(TableElement(title: "毛玻璃效果", subtitle: "imageView.sp.blur()") {
      self.imageView.sp.blur()
    })
    
  }
  
}
