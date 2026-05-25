# FastNote

A fast, minimal text editor for macOS. Write first, decide later.

![macOS](https://img.shields.io/badge/macOS-13%2B-black) ![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![License](https://img.shields.io/badge/license-MIT-blue)

## Features

- Native SwiftUI + AppKit — no Electron, no web views
- Find & Replace with incremental search
- Font customization via native macOS Font Panel
- Zoom in/out independently of font size
- Word wrap toggle in the status bar
- Go to Line, Insert Date & Time
- Screen color picker — insert hex values at cursor
- Print & Page Setup
- Drag & drop to open, `.txt` file association
- Fully localized in 13 languages

## Requirements

- macOS 13 Ventura or later
- Apple Silicon or Intel

## Download

Download the latest release from the [Releases](../../releases) page.

## Build from Source

```bash
git clone https://github.com/mrterdemr/fastnote.git
cd fastnote
./build.sh
open FastNote.app
```

Requires Xcode command line tools: `xcode-select --install`

## License

MIT
