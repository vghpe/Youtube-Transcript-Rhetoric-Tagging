# YouTube Transcriber & Tagger

This project downloads audio from a YouTube video, transcribes it using Whisper, and then tags the transcript with inline labels using OpenAI. Each video's files are organized into a dedicated folder (named after the video's title) to help you manage outputs easily—even if the same video is processed more than once.

## Features

- **Audio Extraction:** Uses `yt-dlp` to download audio from a YouTube video.
- **Transcription:** Leverages Whisper to transcribe the audio.
- **Tagging:** Processes the transcript through OpenAI to insert inline tags for:
  - [FC] Factual Claim – Objective, verifiable statements.
  - [OP] Opinion – Subjective assertions.
  - [EL] Emotional Language – Language evoking emotions.
  - [RT] Rhetorical Technique – Sarcasm, irony, or rhetorical flourish.
  - [SP] Speculation – Uncertainty, guesswork, or predictions.
- **Configurable:** A separate `config.yaml` holds settings for the OpenAI model, temperature, and prompt details.
- **Organized Output:** Automatically creates a folder under `transcripts/` based on the video title.

## Usage

1. **Download and Transcribe a Video**

   Run the bash script with a YouTube video ID. This command will:
   - Download audio from the video.
   - Transcribe the audio using Whisper.
   - Save the transcript in a subfolder under `transcripts/` named after the video's title.

   Example usage:
   `./transcribe_and_tag.sh YFtHjV4c4uw`

2. **Tag the Transcript (Optional)**

   After transcription, the script will prompt:

   Would you like to tag the transcript using OpenAI? (y/N):

   - If you answer `y`, the script sends the transcript to the OpenAI API, generates a tagged transcript, and saves it as `tagged_transcript.txt` in the same folder.
   - If you answer `n`, the tagging step is skipped.

3. **Highlight and Filter Tagged Text**

  Use the provided HTML tool (`index.html`) to view your tagged transcript:
  - Open `index.html` in a browser.
  - Open the file `tagged_transcript.txt` in a text editor and copy its entire contents.
  - Paste this content into the "Paste Tagged Text" textarea on the webpage.
  - Click **Highlight** to render the inline tags with color-coding.
  - Use the checkboxes to show or hide specific tag types (Factual Claim, Speculation, etc.).




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

