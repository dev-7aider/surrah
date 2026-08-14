//
//  SurrahWidgetBundle.swift
//  SurrahWidget
//
//  Created by 7aiDER H. on 27/07/2026.
//

import WidgetKit
import SwiftUI

@main
struct SurrahWidgetBundle: WidgetBundle {
    var body: some Widget {
        SurrahWidget()
        if #available(iOS 18.0, *) {
            SurrahWidgetControl()
        }
    }
}
