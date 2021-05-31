//
//  ViewController.swift
//  GapTaskSchedulerDemo
//
//  Created by Cheng Zhang on 1/13/18.
//  Copyright © 2018 Cheng Zhang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
//    lazy var gapTaskSchedulerTester: GapTaskSchedulerTester = {
//        return GapTaskSchedulerTester()
//    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // gapTaskSchedulerTester.testTasksInComplexCombinedGaps()
      
      let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
      label.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(label)
      
      var html = """
      <html>
      <body>
      <h1><li>Hello, world!</li></h1>
      </body>
      </html>
      """

      //html += <style>body{font-family: '%@'; font-size:8px;}</style>"
      html += "<style>body{font-size:18px;}</style>"
      
      let attributedString = try? NSAttributedString(
        data: html.data(using: .utf8)!,
        options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
        documentAttributes: nil)
      label.attributedText = attributedString
    }
}

