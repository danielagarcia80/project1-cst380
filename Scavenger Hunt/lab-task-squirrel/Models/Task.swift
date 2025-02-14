//
//  Task.swift
//  lab-task-squirrel
//
//  Created by Charlie Hieger on 11/15/22.
//

import UIKit
import CoreLocation

class Task {
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    func set(_ image: UIImage, with location: CLLocation?) { // ✅ Accepts nil
        self.image = image
        self.imageLocation = location
    }

}

extension Task {
    static var mockedTasks: [Task] {
        return [
            Task(title: "Your favourite hiking spot 🥾",
                 description: "Where do you go to be one with nature?"),
            Task(title: "Your favourite local cafe ☕",
                 description: "Where is the coffee shop that serves the best coffee?"),
            Task(title: "Your go-to brunch spot 🥞",
                 description: "Where do you get breakfast on the weekends?"),
            Task(title: "Your favorite local restaurant 🍽",
                 description: " Where do you usually eat in the area?"),
        ]
    }
}
