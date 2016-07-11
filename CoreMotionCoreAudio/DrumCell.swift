//
//  DrumCell.swift
//  CoreMotionCoreAudio
//
//  Created by m.rakhmanov on 09.07.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import Foundation
import UIKit

class DrumCell: UICollectionViewCell {
	@IBOutlet weak var drumLabel: UILabel!
	
	func setActive(active: Bool) {
		drumLabel.text = active ? "1" : "0"
	}
}