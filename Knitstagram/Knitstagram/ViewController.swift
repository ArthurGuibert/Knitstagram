//
//  ViewController.swift
//  Knitstagram
//
//  Created by Arthur Guibert on 04/01/2017.
//  Copyright © 2017 Arthur Guibert. All rights reserved.
//

import UIKit
import GLKit
import AVFoundation

class ViewController: GLKViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var context: EAGLContext?
    var program: ShaderProgram!
    var capture: CaptureSession!
    
    var textureSize: TextureSize = TextureSize(width: 0, height: 0)
    var texture: CVOpenGLESTexture?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = EAGLContext.init(api: .openGLES2)
        
        let glkView: GLKView = self.view as! GLKView
        glkView.context = context!
        preferredFramesPerSecond = 60
        
        setupGL()
        
        capture = CaptureSession()
        if !capture.setup(context: context!, useFrontCamera: false, outputDelegate: self) {
            print("Error starting the video capture session")
        }
    }
    
    func setupGL() {
        EAGLContext.setCurrent(context!)
        program = ShaderProgram()
        if !program.load(name: "Shader") {
            print("Error loading the shader")
        } else {
            print("Success loading the shader")
        }
        
        TextureLoader.load(name: "texture", slot: GLenum(GL_TEXTURE1))
        TextureLoader.load(name: "noise", slot: GLenum(GL_TEXTURE2))
        
        program.setUniform(name: "u_knot_size", value: 1.5)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputSampleBuffer sampleBuffer: CMSampleBuffer!,
                       from connection: AVCaptureConnection!) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer!);
        let height = CVPixelBufferGetHeight(pixelBuffer!);
        
        guard capture.textureCache != nil else {
            print("The video texture cache should not be nil")
            return;
        }
        
        // Lazy init of the VBO
        if textureSize.height != height || textureSize.width != width {
            textureSize = TextureSize(width: width, height: height)
            setupBuffers()
        }
        
        cleanupTexture()
        
        glActiveTexture(GLenum(GL_TEXTURE0));
        let result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           capture.textureCache!,
                                                           pixelBuffer!,
                                                           nil,
                                                           GLenum(GL_TEXTURE_2D),
                                                           GL_RGBA,
                                                           GLsizei(textureSize.width),
                                                           GLsizei(textureSize.height),
                                                           GLenum(GL_BGRA),
                                                           GLenum(GL_UNSIGNED_BYTE),
                                                           0,
                                                           &texture);
        
        guard result == kCVReturnSuccess else {
            print("Error creating the texture from the camera buffer")
            return;
        }
        
        glActiveTexture(GLenum(GL_TEXTURE0))
        glBindTexture(CVOpenGLESTextureGetTarget(texture!), CVOpenGLESTextureGetName(texture!));
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE));
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE));
    }
    
    func setupBuffers() {
        var positionVBO: GLuint = 0
        var texcoordVBO: GLuint = 0
        var indexVBO: GLuint = 0
        let square = SquareObject(size: textureSize)
        
        glGenBuffers(1, &indexVBO);
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexVBO);
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), 6 * MemoryLayout<GLint>.size, UnsafeRawPointer(square.index), GLenum(GL_STATIC_DRAW));
        
        glGenBuffers(1, &positionVBO);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), positionVBO);
        glBufferData(GLenum(GL_ARRAY_BUFFER), 8 * MemoryLayout<GLfloat>.size, UnsafeRawPointer(square.vertex), GLenum(GL_STATIC_DRAW));
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue));
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(2 * MemoryLayout<GLfloat>.size), nil);
        
        glGenBuffers(1, &texcoordVBO);
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), texcoordVBO);
        glBufferData(GLenum(GL_ARRAY_BUFFER), 8 * MemoryLayout<GLfloat>.size, UnsafeRawPointer(square.coord), GLenum(GL_DYNAMIC_DRAW));
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue));
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(2 * MemoryLayout<GLfloat>.size), nil);
    }
    
    func cleanupTexture() {
        texture = nil
        CVOpenGLESTextureCacheFlush(capture.textureCache!, 0);
    }
    
    override func glkView(_ view: GLKView, drawIn rect: CGRect) {
        if textureSize.height != 0 {
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT));
            glDrawElements(GLenum(GL_TRIANGLE_STRIP), 12, GLenum(GL_UNSIGNED_SHORT), nil)
        }
    }
}

