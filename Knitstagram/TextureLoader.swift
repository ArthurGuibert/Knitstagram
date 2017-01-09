//
//  TextureLoader.swift
//  Knitstagram
//
//  Created by Arthur Guibert on 09/01/2017.
//  Copyright © 2017 Arthur Guibert. All rights reserved.
//

import GLKit

class TextureLoader {
    class func load(name: String, slot: GLenum) {
        glActiveTexture(slot)
        if let path = Bundle.main.path(forResource: name, ofType: "png") {
            if let extra = try? GLKTextureLoader.texture(withContentsOfFile: path, options: nil) {
                glBindTexture(extra.target, extra.name);
                glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_REPEAT));
                glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_REPEAT));
            }
        }
    }
}
