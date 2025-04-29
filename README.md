# HVAC Agent Design, Eval, and Implementation

This repo outlines the design, evaluation, and implementation of a ComfortAI agent for HVAC systems. The goal is to create an intelligent agent that can understand and respond to natural language requests related to HVAC control.

The narrative below describes ISE's Hypervelocity Engineering process for using GitHub Copilot and similar tools to rapidly generate a working POC.

## HVE Narrative

### Creating an architecture diagram

  _Copilot prompt:_

    Create a Mermaid 'graph' style architecture diagram in `docs/arch.md`. Use backticks to designate the markdown text as a mermaid diagram.

    The system architecture contains two subgraphs... an evaluation subsystem, and a runtime subsystem. 

    The main component of the evaluation subsystem is Azure AI Foundry. The primary users of Foundry are developers and data scientists using VS Code. 

    The main components of the runtime subsystem are:
    - a web-based UI for HVAC interaction
    - Azure AI Foundry Agent Service to respond to requests from the UI
    - a REST API backend configured as a tool for AI Foundry agents to process natural language requests
    - an HVAC controller used by the REST API to implement HVAC behaviors

### Generating natural language intents from envisioning notes

  _Copilot prompt:_

    From the envisioning notes, identify 25 key natural language examples that represent the desired functionality, and write those to `docs/intents.txt`. Be creative with the examples, but ensure they are realistic and relevant to the HVAC system.
    
    Write only the natural language phrases, one per line, expressed as imperative commands. Do not use quotes or other text elements.

### Generating an API spec

  _Copilot prompt:_

    Use the intents in `docs/intents.txt` as a guide and generate an OpenAPI 3.0 spec that implements the behaviors. 
    
    Parameterize rooms and locations, temperature, time ranges, etc. Prefer PUT over POST when updating values.
    
    Write the spec to `docs/api.json`.

### Generating an eval dataset

  _Copilot prompt:_

    Create a file `docs/dataset.jsonl`. For each line in `docs/intents.txt` add a line to `docs/dataset.jsonl`.
    
    Each new line in `docs/dataset.jsonl` should be JSON content conforming to `docs/dataset_template.json` and containing the original intent text and the endpoint details (names, argument values, etc.) needed to fulfill the intent against the spec in `docs/api.json`.

### Start Azure AI Foundry eval run

  _(run [eval](./src/evals/eval.ipynb) notebook)_

### Review eval results

  _(view results in Azure AI Foundry)_

### Generating REST API code

  _Copilot prompt:_
    
    Generate a Python Flask REST API and dependent code and configuration based on the OpenAPI 3.0 spec in `docs/api.json`. Use only the existing modules in `src/api/requirements.txt`.
    
    Create a simple `src/api/app.py` entrypoint and `src/api/controllers.py` with an implementation of the endpoint behaviors that maintains system state in-memory. Keep all generated code in these files, don't create additional folders or code files.
    
    Ensure SwaggerUI support is configured. The generated code should be a complete, working implementation of the OpenAPI spec. Ensure the code will work with the existing Dockerfile.

### Local API testing

  _(run API in local Docker container and use SwaggerUI to debug)_

### Deploy REST API to Azure

```bash
build_and_deploy.sh \
  --image-name pwc-hve-api \
  --image-tag latest \
  --subscription-id YOUR_SUBSCRIPTION_ID \
  --resource-group YOUR_RESOURCE_GROUP \
  --location eastus \
  --environment pwc-hve-env \
  --name pwc-hve-api \
  --cpu 0.5 \
  --memory 1Gi \
  --min-replicas 1 \
  --max-replicas 3 \
  --port 8000
```

### Test ComfortAI Agent in Azure AI Foundry

  _(run Python code above to create ComfortAI agent in Azure AI Foundry Agent Service, then use agent service portal to interact with agent and issue natural language intents)_
