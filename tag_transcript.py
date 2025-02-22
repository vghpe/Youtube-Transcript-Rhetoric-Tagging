import json
import yaml
import argparse
import os
from openai import OpenAI

# Load config
def load_config():
    """Load the YAML configuration file."""
    with open("config.yaml", "r", encoding="utf-8") as file:
        return yaml.safe_load(file)

# Function to call OpenAI API
def tag_transcript(input_file, output_file):
    config = load_config()

    # Check API key
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("ERROR: OpenAI API key not set. Export it with:")
        print('export OPENAI_API_KEY="your-api-key-here"')
        exit(1)

    client = OpenAI(api_key=api_key)

    # Load transcript
    with open(input_file, "r") as f:
        transcript = f.read().strip()

    if not transcript:
        print(f"ERROR: Transcript file {input_file} is empty.")
        exit(1)

    # Format prompt
    prompt_text = config["prompt"].replace("{transcript}", transcript)

    print("\n=== Sending Request to OpenAI ===")
    print(f"Model: {config['model']}")
    print(f"Temperature: {config['temperature']}")
    print("=================================")

    # Use only 'user' role for all models
    messages = [{"role": "user", "content": prompt_text}]

    # Make OpenAI API call
    try:
        completion = client.chat.completions.create(
            model=config["model"],
            messages=messages,
            temperature=config["temperature"]
        )

        # Extract the response
        tagged_transcript = completion.choices[0].message.content

        # Save tagged transcript
        with open(output_file, "w") as f:
            f.write(tagged_transcript)

        print(f"Tagged transcript saved to: {output_file}")

    except Exception as e:
        print(f"ERROR: Failed to process transcript with OpenAI: {e}")
        exit(1)

# Main entry point
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Tag a transcript using OpenAI.")
    parser.add_argument("--input", required=True, help="Input transcript file")
    parser.add_argument("--output", required=True, help="Output tagged transcript file")
    args = parser.parse_args()

    tag_transcript(args.input, args.output)
