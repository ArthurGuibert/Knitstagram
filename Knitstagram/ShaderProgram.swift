//
//  ShaderLoader.swift
//  Knitstagram
//
//  Created by Arthur Guibert on 04/01/2017.
//  Copyright © 2017 Arthur Guibert. All rights reserved.
//

import Foundation
import GLKit

class ShaderProgram {
    var program: GLuint = 0
    var uniforms: [Int32] = []
    
    func load(name: String) -> Bool {
        program = glCreateProgram()
        var vertexShader: GLuint = 0
        var fragmentShader: GLuint = 0
        
        // Vertex shader loading
        if let shaderPath = Bundle.main.path(forResource: name, ofType: "vsh") {
            if !compile(type: GLenum(GL_VERTEX_SHADER), shader: &vertexShader, filename: shaderPath) {
                return false
            }
        } else {
            return false
        }
        
        // Fragment shader loading
        if let shaderPath = Bundle.main.path(forResource: name, ofType: "fsh") {
            if !compile(type: GLenum(GL_FRAGMENT_SHADER), shader: &fragmentShader, filename: shaderPath) {
                return false
            }
        } else {
            return false
        }
        
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.position.rawValue), "u_position");
        glBindAttribLocation(program, GLuint(GLKVertexAttrib.texCoord0.rawValue), "u_tex_coord");
        
        if !link(program: program) {
            print("Failed to link program: \(program)")
            
            if vertexShader != 0 {
                glDeleteShader(vertexShader)
                vertexShader = 0
            }
            
            if fragmentShader != 0 {
                glDeleteShader(fragmentShader)
                fragmentShader = 0
            }
            
            if program != 0 {
                glDeleteProgram(program)
                program = 0
            }
            
            return false
        }
        
        // Setup uniforms
        uniforms.append(glGetUniformLocation(program, "u_texture"))
        uniforms.append(glGetUniformLocation(program, "u_texture2"))
        uniforms.append(glGetUniformLocation(program, "u_texture3"))
        
        // Release vertex and fragment shaders.
        if vertexShader != 0 {
            glDetachShader(program, vertexShader);
            glDeleteShader(vertexShader);
        }
        
        if fragmentShader != 0 {
            glDetachShader(program, fragmentShader);
            glDeleteShader(fragmentShader);
        }
        
        finalize()
        
        return true
    }
    
    func finalize() {
        glUseProgram(program);
        
        for i in 0..<uniforms.count {
            glUniform1i(uniforms[i], GLint(i));
        }
    }
    
    func tearDown() {
        if program != 0 {
            glDeleteProgram(program)
            program = 0
        }
    }
    
    func compile(type: GLenum, shader: inout GLuint, filename: String) -> Bool {
        shader = glCreateShader(type)
        
        var source: UnsafePointer<Int8>
        do {
            source = try NSString(contentsOfFile: filename, encoding: String.Encoding.utf8.rawValue).utf8String!
        } catch {
            print("Failed to load shader")
            return false
        }
        var castSource:UnsafePointer<GLchar>? = UnsafePointer<GLchar>(source)
        
        glShaderSource(shader, GLsizei(1), &castSource, nil)
        glCompileShader(shader)
        
        if let e = error(for: shader) {
            print("Shader error:\n\(e)")
            glDeleteShader(shader)
        }
        
        return true
    }
    
    func error(for shader: GLuint) -> String? {
        var status: GLint = 0
        glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &status)
        
        if status == 0 {
            var errorLength: GLint = 0;
            glGetShaderiv(shader, GLenum(GL_INFO_LOG_LENGTH), &errorLength);
            
            var errorTrace = [GLchar](repeating: 0, count: Int(errorLength))
            glGetShaderInfoLog(shader, errorLength, &errorLength, &errorTrace);
    
            return String(cString: errorTrace)
        }

        return nil
    }
    
    func link(program: GLuint) -> Bool {
        var status: GLint = 0
        glLinkProgram(program)
        
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &status);
        if (status == 0) {
            return false
        }
        
        return true;
    }
    
    func setUniform(name: String, value: GLfloat) {
        let uniform = glGetUniformLocation(program, UnsafePointer<GLchar>(name))
        
        if uniform != -1 {
            glUniform1f(uniform, value)
        }
    }
    
    func setUniform(name: String, value: GLKVector2) {
        let uniform = glGetUniformLocation(program, UnsafePointer<GLchar>(name))
        
        if uniform != -1 {
            glUniform2f(uniform, value.x, value.y)
        }
    }
}
