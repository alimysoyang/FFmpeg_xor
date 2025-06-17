//
//  AppManager.swift
//  FFmpegxrosDemo
//
//  Created by alimysoyang on 2025-05-02.
//

import Foundation
import OSLog
import FFmpegxrosKit

@MainActor
@Observable
class AppManager {
    var progress: Float = 0
    
    var showStatus: String = ""
    
    private let ffmpeg: FFmpegCmd = FFmpegCmd.share()
    
    init() {
        self.createDir()
    }
    
    public func extractAudio(_ inputFile: String, outputFile: String) {
        let cmd: FFmpegCmdFormat = FFmpegCmdFormat()
        cmd.inputFile = inputFile
        cmd.expand = "-vn -c:a copy"
        cmd.outputFile = outputFile
        ffmpeg.runCommand(cmd) { [weak self] (progress: Float) in
            Task {@MainActor in
                self?.progress = progress
            }
        } completion: { [weak self] (status: FFmpegCmdStatus) in
            if (status == .cancel) {
                self?.showStatus = "Task Cancel"
            } else if (status == .done) {
                self?.showStatus = "Task Done"
            }
        }
    }
    
    public func PCMWav(_ inputFile: String, outputFile: String) {
        let cmd: FFmpegCmdFormat = FFmpegCmdFormat()
        cmd.inputFile = inputFile
        cmd.expand = "-acodec pcm_s16le -ac 1 -ar 16000"
        cmd.outputFile = outputFile
        ffmpeg.runCommand(cmd) { [weak self] (progress: Float) in
            Task {@MainActor in
                self?.progress = progress
            }
        } completion: { [weak self] (status: FFmpegCmdStatus) in
            if (status == .cancel) {
                self?.showStatus = "Task Cancel"
            } else if (status == .done) {
                self?.showStatus = "Task Done"
            }
        }
    }
    
    public func testFFprobe() {
        var inputFile: String = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("30 Minutes to Learn Daily English Conversations | Improve your SPEAKING and LISTENING Skills.mp3").path
        ffmpeg.probeRun("ffprobe -of json -show_format \(inputFile)")
        if (ffmpeg.isPCM) {
            print("\(inputFile)是PCM文件")
        } else{
            print("\(inputFile)不是PCM文件")
        }

        inputFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("test.wav").path
        ffmpeg.probeRun("ffprobe -of json -show_format \(inputFile)")
        if (ffmpeg.isPCM) {
            print("\(inputFile)是PCM文件")
        } else{
            print("\(inputFile)不是PCM文件")
        }

        inputFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("芳芳BD法语中字_1.mp4").path
        ffmpeg.probeRun("ffprobe -of json -show_format \(inputFile)")
        if (ffmpeg.isPCM) {
            print("\(inputFile)是PCM文件")
        } else{
            print("\(inputFile)不是PCM文件")
        }
    }
    
    public func splitBigFile(_ inputFile: String, segmentime: Int = 2400, outputDir: String) {
        let cmd: FFmpegCmdFormat = FFmpegCmdFormat()
        cmd.inputFile = inputFile
        cmd.outputFile = ""
        let tmpName: String = (URL(fileURLWithPath: inputFile).lastPathComponent as NSString).deletingPathExtension
        let tmp = "\(outputDir)/\(tmpName)_segment_%03d.wav"
        cmd.expand = "-f segment -segment_time \(segmentime) -c:a copy \(tmp)"
        ffmpeg.runCommand(cmd) { [weak self] (progress: Float) in
            Task {@MainActor in
                self?.progress = progress
            }
        } completion: { [weak self] (status: FFmpegCmdStatus) in
            if (status == .cancel) {
                self?.showStatus = "Task Cancel"
            } else if (status == .done) {
                self?.showStatus = "Task Done"
            }
        }
    }
}

extension AppManager {
    private func createDir() {
        do {
            let newDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("output")
            try FileManager.default.createDirectory(at: newDir, withIntermediateDirectories: false)
            Logger().debug("Create Directory created: \(newDir)")
        } catch {
            Logger().debug("Create Directory Failed: \(error)")
        }
    }
}
