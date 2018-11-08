//
//  CommentTableViewCell.swift
//  LambdaTimeline
//
//  Created by Ilgar Ilyasov on 11/7/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate: class {
    func playButtonTapped(on cell: CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {
    
    @IBAction func play(_ sender: Any) {
        delegate?.playButtonTapped(on: self)
    }
    
    weak var delegate: CommentTableViewCellDelegate?
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
}
