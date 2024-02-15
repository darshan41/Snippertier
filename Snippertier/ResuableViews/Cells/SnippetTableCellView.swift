//
//  SnippetTableCellView.swift
//  Snippertier
//
//  Created by Darshan Shrikant on 12/02/24.
//  Copyright © 2024 Darshan Shrikant. All rights reserved.
//


import Cocoa

class SnippetTableCellView: NSTableCellView {
    
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var descriptionLabel: NSTextField!
    @IBOutlet private weak var dateLabel: NSTextField!
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    func configure(_ snippet: Snippet) {
        let date = snippet.date
        let trigger = (snippet.trigger ?? "xUnknown").dropFirst()
        titleLabel.stringValue = String(trigger)
        descriptionLabel.stringValue = snippet.content ?? "None"
        dateLabel.stringValue = "Created At: \(dateFormatter.string(from: date))"
    }
}

// MARK: Helper func's

private extension SnippetTableCellView {
    
    func setupUI() {
        titleLabel.clipsToBounds = true
        descriptionLabel.clipsToBounds = true
        dateLabel.clipsToBounds = true
    }
}
