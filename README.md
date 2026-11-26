# 👻 YT GHOST-SHELL




### A YouTube toolkit for your terminal

Download videos and audio, collect subtitles and metadata, and manage playlists from an interactive menu powered by **yt-dlp**.

**Version 0.01** · **Termux** · **Debian / Ubuntu Linux**

---

## ✨ Features

- **Video:** best available quality, 1080p, 720p, 480p, and container options.
- **Audio:** MP3, FLAC, M4A, Opus, and playlist audio extraction.
- **Subtitles:** download available subtitles, including an auto-generated subtitle option.
- **Information:** save JSON metadata, descriptions, comments, tags, and thumbnails.
- **Playlists & channels:** archive a channel, download a playlist, select the latest five items, or filter by date.
- **Extra tools:** SponsorBlock removal, chapter splitting, live stream option, cookies, and format listing.

Available formats, resolutions, subtitles, and other features depend on the video, YouTube, and the installed yt-dlp version. FLAC conversion cannot restore quality already lost in the source audio.

---

## 🚀 Quick Install

Open **Termux** or a **Debian/Ubuntu terminal** and run:

```bash
curl -fL https://raw.githubusercontent.com/yeaminuli7/YT_GHOST-SHELL/main/ghost-setup.sh -o ghost-setup.sh && bash ghost-setup.sh
```

The installer downloads to `ghost-setup.sh` in the current directory and then runs interactively. If a file with that name already exists, the download **overwrites it**.

> **Security note:** This command downloads and runs code from the repository's `main` branch, which can change. If you prefer to inspect it first, download it with the `curl` command above, open `ghost-setup.sh` in a text editor, and then run `bash ghost-setup.sh` yourself.

If `curl` or `bash` is missing, install them first:


```bash
# Termux
pkg update && pkg install curl bash
# Termux Proot
apt update && apt install curl bash
# Debian / Ubuntu
sudo apt update && sudo apt install curl bash
```

Use `apt` directly instead of `sudo apt` if you are already root.

### Termux storage access

The original application saves files to `/sdcard/Download/YT`. In Termux, grant storage permission before downloading:

```bash
termux-setup-storage
```

Accept the Android permission prompt. Internet access is needed to install missing packages and download media.

---

## ⚙️ Setup Process

1. The installer detects Termux or Debian/Ubuntu Linux.
2. Enter the command name you want to use. Press **Enter** to use the default, `d`.
3. If a command with that name already exists, the installer warns you before continuing. Choose a different name if you want to keep the existing command.
4. The installer checks for `yt-dlp`, `ffmpeg`, `aria2c`, Python, and pip, and installs missing packages using the platform package manager.
5. It installs the embedded original script and a launcher.

Termux does not require root. On Linux, a regular user can install the launcher in their home directory, but installing missing system packages may require `sudo` or an administrator.

---

## ▶️ Usage

Run the command name you chose during installation. For the default name:

```bash
d
```

Select an option from the menu, enter the requested YouTube URL, and follow any additional prompts. Use `h` for the built-in guide and `q` to quit.

### Default download folder

```text
/sdcard/Download/YT
```

This path is hard-coded in the original application. It is intended for Android; on ordinary Linux it may not exist or be writable. To use a different location, edit the `ROOT` value in the installed application script.

---

## 📁 Installation Locations

| Environment | Launcher | Application script |
|---|---|---|
| Termux | `$PREFIX/bin/<name>` | `$PREFIX/share/ghost-shell/d-2.sh` |
| Linux, regular user | `~/.local/bin/<name>` | `~/.local/share/ghost-shell/d-2.sh` |
| Linux, root | `/usr/local/bin/<name>` | `/usr/local/lib/ghost-shell/d-2.sh` |

Replace `<name>` with the command name you selected. On Linux, if `~/.local/bin` is not in your `PATH`, the installer prints instructions for adding it; alternatively, invoke the launcher by its full path.

---

## 🛠️ Troubleshooting

**Command not found**  
Check the chosen name and the launcher location above. On Linux, ensure `~/.local/bin` is in your `PATH` and restart your shell after changing your shell profile.

**Cannot write to the download folder**  
In Termux, run `termux-setup-storage` and grant permission. On Linux, edit the installed script's `ROOT` to a writable directory.

**Package installation fails**  
Read the package manager error and check your internet connection and repositories. On Linux, install missing dependencies with administrator assistance if `sudo` is unavailable.

**A video or option fails**  
YouTube availability and yt-dlp support can change. The application's original `0` menu option runs `pip install --pre -U yt-dlp`; this may fail on distribution-managed Python installations. Use your environment's supported package-management method when updating instead.

**The menu says “Done” after an error**  
The original script prints that message even if the downloader fails. Check the preceding yt-dlp output and confirm the file exists before assuming success.

**Cookies**  
The cookies option accepts a local cookies file. Treat it like a password and only use credentials you are authorized to use.

---

## 📌 Responsible Use

Download only content you have permission to download, and comply with applicable laws and platform terms. The tool does not guarantee access to restricted or protected content.

---
