//
//  NoteViewController.swift
//  QuNotes
//
//  Created by Alexander Guschin on 29.06.17.
//  Copyright © 2017 Alexander Guschin. All rights reserved.
//

import UIKit
import CocoaMarkdown

protocol NoteViewControllerHandler: class {
    func didChangeContent(newContent: String)
    func onBackButtonClick()
}

class NoteViewController: UIViewController {

    func inject(handler: NoteViewControllerHandler) {
        self.handler = handler
    }

    func render(withViewModel viewModel: NoteViewModel) {
        self.viewModel = viewModel
        noteTextView?.text = viewModel.content
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewModel = self.viewModel {
            render(withViewModel: viewModel)
        }
        setupBackButton()
    }

    fileprivate weak var handler: NoteViewControllerHandler?
    fileprivate var viewModel: NoteViewModel?
    @IBOutlet fileprivate weak var noteTextView: UITextView?
    @IBOutlet fileprivate weak var noteLabel: UILabel?

    func onBackButtonClick() {
        handler?.onBackButtonClick()
    }

    private func setupBackButton() {
        self.navigationItem.hidesBackButton = true
        let backButton = UIBarButtonItem(title: "Back",
                                         style: .plain,
                                         target: self,
                                         action: #selector(NoteViewController.onBackButtonClick))
        self.navigationItem.leftBarButtonItem = backButton
    }
}

extension NoteViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        handler?.didChangeContent(newContent: textView.text)
        let document = CMDocument(data: textView.text.data(using: .utf8))
//        let document = CMDocument(contentsOfFile: path, options: nil)
        let renderer = CMAttributedStringRenderer(document: document, attributes: CMTextAttributes())
        noteLabel?.attributedText = renderer?.render()
    }
}
