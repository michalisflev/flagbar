# FlagBar

A tiny macOS menu bar app that shows a flag for your current keyboard language (🇬🇷, 🇬🇧, …) instead of Apple's grey letter codes.

## Requirements

- macOS 13 or newer
- Xcode Command Line Tools: `xcode-select --install`

## Install

```bash
git clone https://github.com/<your-username>/FlagBar.git
cd FlagBar
chmod +x build.sh && ./build.sh
mv FlagBar.app /Applications/
open /Applications/FlagBar.app
```

Then:

1. Click the flag → **Open at Login**, so FlagBar starts automatically after every restart.
   Then check System Settings → General → Login Items: FlagBar should be listed under **Open at Login**. If it appears under **Allow in the Background**, turn it on. If it isn't listed, click **+** under **Open at Login** and add FlagBar from Applications.
2. Optional: hide Apple's own indicator in System Settings → Keyboard → Input Sources → Edit… → turn off **Show Input menu in menu bar**.
