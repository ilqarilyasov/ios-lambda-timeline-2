//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController, CommentTableViewCellDelegate, AVAudioPlayerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        performSegue(withIdentifier: "AddCommentSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else { fatalError("CommentTableViewCell couldn't be found") }
        
        let comment = post?.comments[indexPath.row + 1]
        
        if let text = comment?.text {
            cell.commentLabel.text = text
            cell.authorLabel.text = comment?.author.displayName
            cell.playButton.isHidden = true
        } else if (comment?.audioURL) != nil {
            cell.commentLabel.text = "Audio comment"
            cell.authorLabel.text = comment?.author.displayName
            cell.playButton.isHidden = false
        }
        cell.delegate = self
        
        return cell
    }
    
    func playButtonTapped(on cell: CommentTableViewCell) {
        defer { updateTitle(for: cell.playButton) }
        guard !isPlaying else {
            player?.pause()
            return
        }
        
        if player != nil && !isPlaying {
            player?.play()
            return
        }
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let comment = post.comments[indexPath.row + 1]
        guard let audioURL = comment.audioURL else { return }

        do {
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.delegate = self
            player?.play()
        } catch {
            NSLog("Unable to play audio: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCommentSegue" {
            let destVC = segue.destination as! AddCommentViewController
            destVC.post = post
            destVC.postController = postController
        }
    }
    
    func updateTitle(for button: UIButton) {
        let playing = isPlaying ? "Stop" : "Play"
        button.setTitle(playing, for: .normal)
    }

    var post: Post!
    var postController: PostController!
    var imageData: Data?
    private var player: AVAudioPlayer?
    
    private var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
