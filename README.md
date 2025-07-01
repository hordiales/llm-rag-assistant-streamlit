Summary
===============================

llm-rag-assistant is a fully local, retrieval-augmented chatbot powered by llama-cpp-python, designed to answer questions in Spanish using your own Q&A dataset. It uses semantic search via FAISS + multilingual sentence-transformers to retrieve relevant answers, and combines it with a local instruction-tuned LLM (e.g., Mistral-7B-Instruct in GGUF format) for contextual response generation.

## 🚀 Features
-	🔍 Semantic Search with multilingual embeddings (sentence-transformers)
-	🧠 Local LLM inference without a GPU using optimized GGUF models + llama-cpp-python
--	💻 Runs on standard laptops and desktops — no CUDA, no GPU, no special hardware required
--	🔒 No API keys, no cloud dependency — fully private and offline
--	🌐 Instant web interface with Streamlit
--	🐳 Docker & Docker Compose ready for easy deployment
--	🗂️ Plug-and-play with any Q&A dataset in JSON format

RAG Local - Instructions
===============================

This package lets you run a console chatbot with semantic retrieval (RAG) on your machine, with no need for a GPU or external connection.

This version works in the console. For a UI version, see the streamlit version.

Requirements:
-------------
1. Python 3.9+
2. Install dependencies:
   pip install llama-cpp-python faiss-cpu sentence-transformers

Tested with python-3.13.5, specific versions in environment.yml
    # On macOS, if build fails try
    conda install -c conda-forge llama-cpp-python
    pip install faiss-cpu sentence-transformers

3. Download the GGUF model:

For example
```bash
   wget https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/mistral-7b-instruct-v0.1.Q4_K_M.gguf -O mistral-7b-instruct.Q4_K_M.gguf
```

4. Build a question and answer dataset

Important: Save it in the file qa_dataset.json

It should have the following structure (example)
```json
[
  {
    "pregunta": "¿Cuál es el horario de atención?",
    "respuesta": "Nuestro horario de atención es de lunes a viernes de 9:00 a 18:00 horas y sábados de 9:00 a 14:00."
  },
  {
    "pregunta": "¿Cómo puedo contactar con soporte técnico?",
    "respuesta": "Puede contactar con soporte técnico a través del email soporte@empresa.com, llamando al 900-123-456 o mediante el chat en vivo de nuestra web."
  },
  ...
]
```

5. Create the config.yaml file for RAG System configuration

For example

```yaml
models:
  embeddings:
    model_name: "sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2"
  generation:
    llama_cpp_model_path: "models/mistral-7b-instruct.Q4_K_M.gguf"
    model_choice: "spanish"
    models:
      spanish:
        max_tokens: 256
```

*Note:* To work with this type of Q&A dataset, you need an instruction-tuned model.

TODO:
-----
* Add temperature configuration

Included files:
-------------------
- prepare_embeddings.py → generates scibot_index.faiss and qa.json from your dataset
- app.py  → runs the streamlit app
- qa_dataset.json → your knowledge base

Steps:
------

Use docker compose (see below) or run manually:

1. Run: python prepare_embeddings.py
2. Run: streamlit run app.py
3. Chat with your knowledge base using a Spanish bot :)

Requirements:
-----------
- 8GB RAM minimum (16GB recommended)
- ~5GB of space for the models


# Build and run with docker compose

```bash
docker-compose build

docker-compose up -d

docker-compose down

docker-compose logs -f
```

# Access to aplication 

Open your browser at: http://localhost:8501

## 🐳 Extra docker commands

```bash

# Rebuild from scratch
docker-compose build --no-cachedocker-compose build --no-cache

# Execute inside the container
docker-compose exec rag-app python compute_embeddings.py
```