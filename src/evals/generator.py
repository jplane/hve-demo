import json
from openai import AzureOpenAI

class FunctionCallGenerator:
    
    def __init__(self, model_config):

        self.model_config = model_config

    def __call__(self, intent: str):

        with open(self.model_config["SWAGGER_PATH"], 'r') as swagger_file:
            swagger_spec = swagger_file.read()

        with open(self.model_config["SYSTEM_PROMPT_PATH"], 'r') as system_prompt_file:
            system_prompt = system_prompt_file.read()

        system_prompt = system_prompt.replace("##swagger_spec##", swagger_spec)

        client = AzureOpenAI(
            azure_endpoint=self.model_config["AZURE_INFERENCE_ENDPOINT"], 
            api_key=self.model_config["AZURE_INFERENCE_KEY"],
            api_version="2024-10-21"
        )

        response = client.chat.completions.create(
            model="gpt-4o",
            temperature=float(self.model_config.get("TEMPERATURE", 0.2)),
            top_p=float(self.model_config.get("TOP_P", 0.1)),
            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": intent}
            ],
            response_format={ "type": "json_object" }
        )

        return { "actual_calls": json.loads(response.choices[0].message.content) }
