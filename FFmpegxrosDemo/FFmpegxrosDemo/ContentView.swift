//
//  ContentView.swift
//  FFmpegxrosDemo
//
//  Created by alimysoyang on 2025-05-02.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State private var manager: AppManager = AppManager()
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView(value: manager.progress, label: {
                Text("\(manager.showStatus)")
            })
            .progressViewStyle(.linear)
            .padding()
            
            Button("h265 mp4 extract audio(aac)") {
                Task.detached {
                    let inputFile: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("test.mp4").path
                    let outputFile: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("output/test_A_265.m4a").path
                    await manager.extractAudio(inputFile, outputFile: outputFile)
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(height: 44)
            
            
            Button("mp4 to wav") {
                let inputFile: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("test.mp4").path
                let outputFile: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("output/ff_h265.wav").path
                manager.PCMWav(inputFile, outputFile: outputFile)
            }
            .buttonStyle(.borderedProminent)
            .frame(height: 44)
                   
            Button("Test ffprobe") {
                manager.testFFprobe()
            }
            .buttonStyle(.borderedProminent)
            .frame(height: 44)
            
            Button("Split Big File") {
                let inputFile: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("test.wav").path
                let outputDir: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path
                manager.splitBigFile(inputFile, outputDir: outputDir)
            }
            .buttonStyle(.borderedProminent)
            .frame(height: 44)
        }
        .padding()
    }
}

