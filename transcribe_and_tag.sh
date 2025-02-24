#!/usr/bin/env bash

# Usage: ./transcribe_and_tag.sh <YouTube_ID>
# Example: ./transcribe_and_tag.sh dQw4w9WgXcQ

VIDEO_ID="$1"

if [ -z "$VIDEO_ID" ]; then
  echo "Usage: $0 <YouTube_ID>"
  exit 1
fi

# Check dependencies
command -v yt-dlp >/dev/null 2>&1 || { echo >&2 "ERROR: yt-dlp not found. Please install it."; exit 1; }
command -v ffmpeg >/dev/null 2>&1 || { echo >&2 "ERROR: ffmpeg not found. Please install it."; exit 1; }
command -v whisper >/dev/null 2>&1 || { echo >&2 "ERROR: whisper not found. Please install it via pip."; exit 1; }

# Get video title (remove punctuation)
VIDEO_TITLE=$(yt-dlp --get-title "https://www.youtube.com/watch?v=${VIDEO_ID}" | tr -d '[:punct:]')
VIDEO_FOLDER="transcripts/${VIDEO_TITLE}"

mkdir -p "$VIDEO_FOLDER"

AUDIO_FILE="${VIDEO_FOLDER}/audio.m4a"
TRANSCRIPT_FILE="${VIDEO_FOLDER}/transcript.txt"
TAGGED_FILE="${VIDEO_FOLDER}/tagged_transcript.txt"

# ------------------------------------------------------------------------------
# 1) Download/transcribe only if transcript doesn't already exist
# ------------------------------------------------------------------------------
if [ -f "$TRANSCRIPT_FILE" ]; then
  echo "Transcript already exists at: $TRANSCRIPT_FILE"
else
  echo "Transcript not found. Downloading and transcribing..."

  # Download audio
  yt-dlp --extract-audio --audio-format m4a -o "$AUDIO_FILE" "https://www.youtube.com/watch?v=${VIDEO_ID}"
  if [ $? -ne 0 ]; then
    echo "ERROR: Download failed."
    exit 1
  fi

  # Transcribe with Whisper
  whisper "$AUDIO_FILE" --model small --language en --output_format txt --output_dir "$VIDEO_FOLDER"
  if [ $? -ne 0 ]; then
    echo "ERROR: Transcription failed."
    exit 1
  fi

  # Rename transcript if necessary
  if [ ! -f "$TRANSCRIPT_FILE" ]; then
    GENERATED_TRANSCRIPT="${AUDIO_FILE%.m4a}.txt"
    if [ -f "$GENERATED_TRANSCRIPT" ]; then
      mv "$GENERATED_TRANSCRIPT" "$TRANSCRIPT_FILE"
    else
      echo "ERROR: Could not find the expected transcript file."
      exit 1
    fi
  fi

  echo "Transcript saved to: $TRANSCRIPT_FILE"
fi

# ------------------------------------------------------------------------------
# 2) Tag with OpenAI if:
#    - the tagged file doesn't already exist, and
#    - the user explicitly confirms they want to do an API call
# ------------------------------------------------------------------------------
if [ -f "$TAGGED_FILE" ]; then
  echo "Tagged transcript already exists at: $TAGGED_FILE"
else
  read -r -p "Would you like to tag the transcript with OpenAI? (This uses API credits.) [y/N]: " TAG_CONFIRM
  if [[ "$TAG_CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Tagging transcript with OpenAI..."

    python3 tag_transcript.py --input "$TRANSCRIPT_FILE" --output "$TAGGED_FILE"
    if [ $? -ne 0 ]; then
      echo "ERROR: Tagging failed."
      exit 1
    fi

    echo "Tagged transcript saved to: $TAGGED_FILE"
  else
    echo "Skipping tagging step."
  fi
fi

# ------------------------------------------------------------------------------
# 3) Prompt to open the tagged transcript
# ------------------------------------------------------------------------------
if [ -f "$TAGGED_FILE" ]; then
  read -r -p "Would you like to open the tagged transcript now? (y/N): " OPEN_TAGGED
  if [[ "$OPEN_TAGGED" =~ ^[Yy]$ ]]; then
    # Attempt to open in default text application
    xdg-open "$TAGGED_FILE" 2>/dev/null || open "$TAGGED_FILE" 2>/dev/null || start "$TAGGED_FILE" 2>/dev/null
  fi
else
  echo "Tagged transcript not found at: $TAGGED_FILE"
fi

# ------------------------------------------------------------------------------
# 4) Open index.html in the default browser
# ------------------------------------------------------------------------------
echo "Opening index.html..."
xdg-open "./index.html" 2>/dev/null || open "./index.html" 2>/dev/null || start "./index.html" 2>/dev/null

echo "=== Done! ==="
