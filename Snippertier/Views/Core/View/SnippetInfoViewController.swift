//
//  SnippetInfoViewController.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Cocoa
import SwiftUI

protocol SnippetDelegate: AnyObject {
    var snippet: Snippet? { get set }
}

class SnippetInfoViewController: NSViewController,SnippetDelegate {
    
    @IBOutlet private var containerView: NSView!
    
    private let snippetView: SnippetView = SnippetView()
        
    weak var snippet: Snippet? {
        didSet {
            snippetView.snippetHolder.snippet = snippet
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    convenience init() {
        self.init(nibName: NSNib.Name.init(String.init(describing: Self.self)), bundle: nil)
    }
}

// MARK: Helper func's

private extension SnippetInfoViewController {
    
    func configureView() {
        createAndEmbedSnippetView()
    }
    
    func createAndEmbedSnippetView() {
        let hostingView = NSHostingView(rootView: snippetView)
        containerView.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
}
