import streamlit as st
import json
import faiss
import numpy as np
import yaml
from sentence_transformers import SentenceTransformer
from llama_cpp import Llama

# Cargar modelos e índice
@st.cache_resource
# def load_models():
    index = faiss.read_index("/app/dataset_index.faiss")
    with open("/app/qa.json", "r", encoding="utf-8") as f:
        db = json.load(f)

    with open('config.yaml', 'r', encoding='utf-8') as f:
        config = yaml.safe_load(f)
    embedder_model_name = config['models']['embeddings']['model_name']
    llama_model_path = config['models']['generation']['llama_cpp_model_path']
    max_tokens = config['models']['generation']['max_tokens']

    embedder = SentenceTransformer(embedder_model_name)
    llm = Llama(model_path=llama_model_path, n_ctx=2048)

    return index, db, embedder, llm, max_tokens

def buscar_contexto(pregunta, index, db, embedder):
    emb = embedder.encode([pregunta])
    _, I = index.search(np.array(emb).astype(np.float32), 1)
    return db["questions"][I[0][0]], db["answers"][I[0][0]]

st.title("🤖 Asistente (RAG local)")

index, db, embedder, llm, max_tokens = load_models()
user_input = st.text_input("Escribí tu pregunta", "")

if user_input:
    pregunta_similar, respuesta_contexto = buscar_contexto(user_input, index, db, embedder)
    prompt = f"""[INST] Eres un asistente. Un usuario pregunta: "{user_input}".
Basándote en este conocimiento previo:
Pregunta previa: "{pregunta_similar}"
Respuesta: "{respuesta_contexto}"
Responde en español de forma clara y precisa. [/INST]"""
    with st.spinner("Pensando..."):
        output = llm(prompt, max_tokens=max_tokens)
        respuesta = output["choices"][0]["text"].strip()
        st.markdown("**LocalBot:** " + respuesta)
