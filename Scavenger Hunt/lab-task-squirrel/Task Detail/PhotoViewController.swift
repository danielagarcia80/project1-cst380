//
//  PhotoViewController.swift
//  lab-task-squirrel
//
//  Created by Daniela Garcia on 2/4/25.
//

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.image = task.image
    }
}

