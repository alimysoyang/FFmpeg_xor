# FFmpegxrosKit: FFmpeg Wrapper for Apple Vision Pro

This repository provides a **secondary encapsulation of the FFmpeg multimedia framework** specifically designed for use in **Apple Vision Pro (xrOS)** applications. It aims to simplify the integration and execution of common FFmpeg and FFprobe commands within an Apple Vision Pro development environment.

### Notebooklm Audio
[readme.webm](https://github.com/user-attachments/assets/719c0e1f-6b87-4b49-87cd-9364b8b9a083)

###Mind Map
![NotebookLM Mind Map](https://github.com/user-attachments/assets/7aa341f0-3a56-44f4-b32f-ef47ab7c68b8)

## Purpose

The primary purpose of `FFmpegxrosKit` is to abstract the complexities of directly interacting with the FFmpeg command-line tools in an Apple Vision Pro application. By providing an Objective-C/Swift wrapper, it offers a more native and developer-friendly interface for multimedia processing tasks. This encapsulation facilitates tasks that would otherwise require intricate handling of low-level C APIs and command-line arguments.

## Applicable Environment

This framework is specifically engineered and optimized for applications running on **Apple Vision Pro**. The naming convention `FFmpegxrosKit` clearly indicates its target operating system, xrOS, which powers Apple Vision Pro.

## Key Features

The `FFmpegxrosKit` offers a robust set of features to handle various multimedia operations:

*   **Execution of Conventional FFmpeg Commands**: Developers can easily run a wide array of FFmpeg commands using the `FFmpegCmd` class's `runCommand` method. This method takes a `FFmpegCmdFormat` object, which helps in constructing the full command with input, output, and custom `expand` parameters.
*   **Execution of FFprobe Commands**: The `FFmpegCmd` class includes a `probeRun` method that allows for the execution of `ffprobe` commands, enabling detailed analysis of media files.
*   **Specialized Media Analysis (e.g., PCM Detection)**: Beyond standard FFmpeg/FFprobe capabilities, this wrapper extends functionality to include specific business logic, such as determining if a multimedia file is in **PCM (Pulse Code Modulation) format**. The `isPCM` property in `FFmpegCmd` is updated after `probeRun` executes, providing a direct check for PCM files.
*   **Asynchronous Processing with Progress & Completion Handlers**: All FFmpeg commands are executed asynchronously, preventing UI blocking. The framework provides `ProgressHandler` and `CompletionHandler` callbacks to update the application's UI on the task's progress and final status, respectively.
*   **Command Cancellation**: Running FFmpeg tasks can be cancelled gracefully using the `cancel` method, ensuring proper resource management.
*   **Comprehensive Metadata Extraction**: Methods like `metaBasicInfo` and `metaInfo` allow for the extraction of crucial metadata from media files, including `filename`, `nb_streams`, `nb_programs`, `format_name`, `format_long_name`, `duration`, `size`, and `bit_rate`. This metadata is stored in an `NSMutableDictionary` for easy access.
*   **Current Time and Duration Tracking**: The `FFmpegCmd` object tracks the total `duration` of a media file and its `currentTime` during processing, enabling accurate progress calculations.
*   **Examples of Common Use Cases**: The `AppManager` class within the source demonstrates practical applications such as:
    *   **Extracting audio** from video files.
    *   **Converting audio to PCM WAV** format.
    *   **Splitting large media files** into smaller, time-segmented files.

## Problems Solved

This FFmpeg wrapper addresses several key challenges faced when developing multimedia applications for Apple Vision Pro:

*   **Simplifies FFmpeg Integration**: It eliminates the need for developers to directly manage complex command-line arguments and low-level C function calls required by FFmpeg. The wrapper handles the conversion of Objective-C/Swift strings and arrays into the `char **argv` format expected by the underlying FFmpeg libraries.
*   **Enables Seamless Asynchronous Operations**: By wrapping FFmpeg calls in `dispatch_async` blocks with semaphores, the framework ensures that heavy multimedia processing tasks run in the background without freezing the application's user interface. Callbacks provide an efficient way to relay progress and completion status back to the main thread.
*   **Streamlines Media Information Retrieval**: Instead of parsing raw text output from `ffprobe` commands, the wrapper provides structured access to media metadata via `NSMutableDictionary`. It also offers direct properties like `isPCM` for specific analysis needs, simplifying checks like whether a file is in PCM format.
*   **Standardizes Command Construction**: The `FFmpegCmdFormat` class provides a consistent and error-resistant method for building `ffmpeg` commands, abstracting string concatenation and ensuring proper formatting of arguments.
*   **Manages Operational State**: The `FFmpegCmdStatus` enum (Idle, Ready, Running, Cancel, Done) provides clear state management for FFmpeg operations, allowing developers to build more robust and responsive applications.
