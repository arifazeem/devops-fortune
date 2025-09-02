import json, sys, openai

with open(sys.argv[1]) as f:
    data = json.load(f)

total_cost = data["totalMonthlyCost"]

# Build prompt for RAG
prompt = f"""
You are a FinOps assistant. Here is the Terraform plan cost impact:
{json.dumps(data, indent=2)}

Summarize in simple words:
- What resources were added/changed
- Cost increase/decrease
- Business impact in plain English
"""

resp = openai.ChatCompletion.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": prompt}]
)

print(resp["choices"][0]["message"]["content"])
