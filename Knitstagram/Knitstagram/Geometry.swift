//
//  Geometry.swift
//  Knitstagram
//
//  Created by Arthur Guibert on 09/01/2017.
//  Copyright © 2017 Arthur Guibert. All rights reserved.
//

import GLKit

struct TextureSize {
    var width: Int = 0
    var height: Int = 0
}

struct SquareObject {
    let vertex: [GLfloat] = [
        -1, -1,
        1, -1,
        1, 1,
        -1, 1,
        ]
    
    let coord: [GLfloat]
    
    let index: [GLint] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    init(size: TextureSize) {
        coord = [
            GLfloat(size.height) / GLfloat(size.width), 1.0,
            GLfloat(size.height) / GLfloat(size.width), 0.0,
            0.0, 0.0,
            0.0, 1.0,
        ]
    }
}
