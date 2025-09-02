import sys
import json
import os
import google.generativeai as genai

def main():
    # Check input args
    if len(sys.argv) < 2:
        print("Usage: python rag_summary.py <infracost.json>")
        sys.exit(1)

    input_file = sys.argv[1]

    # Load Infracost JSON
    try:
        with open(input_file, "r") as f:
            infracost_data = json.load(f)
    except Exception as e:
        print(f"❌ Error reading {input_file}: {e}")
        sys.exit(1)

    # Configure Gemini
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        print("❌ GEMINI_API_KEY environment variable is not set.")
        sys.exit(1)

    genai.configure(api_key=api_key)

    # Prepare prompt
    prompt = f"""
    You are a DevOps assistant reviewing Terraform cost estimates.
    Based on the Infracost report below, summarize:

    - Total monthly cost estimate
    - Resources with the highest costs
    - Significant cost changes (if available)
    - Any recommendations to optimize costs

    Infracost JSON report:
    {json.dumps(infracost_data, indent=2)}
    """

    # Generate summary using Gemini
    model = genai.GenerativeModel("gemini-2.0-flash")
    response = model.generate_content(prompt)

    # Print result to stdout (so GitHub Actions can redirect to comment.md)
    print(response.text)


if __name__ == "__main__":
    main()
