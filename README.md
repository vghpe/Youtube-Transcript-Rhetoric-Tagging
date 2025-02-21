# YouTube Transcriber & Tagger

This project downloads audio from a YouTube video, transcribes it using Whisper, and then tags the transcript with inline labels using OpenAI. Each video's files are organized into a dedicated folder (named after the video's title) to help you manage outputs easily—even if the same video is processed more than once.

## Features

- **Audio Extraction:** Uses `yt-dlp` to download audio from a YouTube video.
- **Transcription:** Leverages Whisper to transcribe the audio.
- **Tagging:** Processes the transcript through OpenAI to insert inline tags for:
  - [FC] Factual Claim
  - [SP] Speculation
  - [EL] Emotive Language
  - [PL] Pejorative Language
  - [DS] Dismissive/Snarky
- **Configurable:** A separate `config.json` holds settings for the OpenAI model, temperature, and prompt details.
- **Organized Output:** Automatically creates a folder under `transcripts/` based on the video title.

## Installation

### Dependencies

- **Python 3.7+**
- **yt-dlp:** For downloading YouTube audio  
  _Installation: `brew install yt-dlp` (macOS) or follow instructions on [yt-dlp GitHub](https://github.com/yt-dlp/yt-dlp)._
- **ffmpeg:** Required by yt-dlp for audio conversion  
  _Installation: `brew install ffmpeg` (macOS/Linux) or download from [ffmpeg.org](https://ffmpeg.org/)._
- **Whisper:** For transcribing audio  
  _Installation: `pip install git+https://github.com/openai/whisper.git`_
- **OpenAI Python Library:** For tagging the transcript  
  _Installation: `pip install openai`_

### Virtual Environment (Recommended)

It’s best to use a virtual environment to manage dependencies. For example:

```bash
python3 -m venv venv
source venv/bin/activate      # On macOS/Linux
venv\Scripts\activate         # On Windows
pip install -r requirements.txt
