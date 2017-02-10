//
//  Uniformizable.swift
//  Knitstagram
//
//  Created by Adrien Coye de Brunélis on 10/02/2017.
//  Copyright © 2017 Adrien Coye de Brunélis. All rights reserved.
//

import Foundation
import GLKit

protocol Uniformizable {
    func setUniformAtLocation(localtion:GLint)
}

//MARK: - 64bit (swift literals) -
extension Double: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform1f(localtion, GLfloat(self))
    }
}

extension Int: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform1i(localtion, GLint(self))
    }
}

extension UInt: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform1ui(localtion, GLuint(self))
    }
}

//MARK: - 32bit -
extension GLfloat: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform1f(localtion, self)
    }
}

extension GLint: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform1i(localtion, self)
    }
}

extension GLuint: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform1ui(localtion, self)
    }
}

//MARK: - vectors -
extension GLKVector2: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform2f(localtion, self.x, self.y)
    }
}

extension GLKVector3: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform3f(localtion, self.x, self.y, self.z)
    }
}

extension GLKVector4: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        glUniform4f(localtion, self.x, self.y, self.z, self.w)
    }
}

//MARK: - misc -
extension UIColor: Uniformizable {
    func setUniformAtLocation(localtion :GLint) {
        
        var red : CGFloat = 0
        var green : CGFloat = 0
        var blue : CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red,
                    green: &green,
                    blue: &blue,
                    alpha: &alpha)
        glUniform4f(localtion, GLfloat(red), GLfloat(green), GLfloat(blue), GLfloat(alpha))
    }
}
