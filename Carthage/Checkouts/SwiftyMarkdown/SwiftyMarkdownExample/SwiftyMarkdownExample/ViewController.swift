//
//  ViewController.swift
//  SwiftyMarkdownExample
//
//  Created by Simon Fairbairn on 05/03/2016.
//  Copyright © 2016 Voyage Travel Apps. All rights reserved.
//

import UIKit
import SwiftyMarkdown

class ViewController: UIViewController {

	@IBOutlet weak var textView : UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	
		// This is to help debugging.
		reloadText(nil)
	}
	
	@IBAction func reloadText( _ sender : UIButton? ) {
				
		self.textView.dataDetectorTypes = UIDataDetectorTypes.all
		if let url = Bundle.main.url(forResource: "example", withExtension: "md"), let md = SwiftyMarkdown(url: url) {
			md.h2.fontName = "AvenirNextCondensed-Bold"
			md.h2.color = UIColor.red
			md.code.fontName = "CourierNewPSMT"
			
			self.textView.attributedText = md.attributedString()
			
		} else {
			fatalError("Error loading file")
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

