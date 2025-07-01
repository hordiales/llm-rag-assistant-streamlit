#!/bin/bash
set -e

if [ ! -f "/app/dataset_index.faiss" ]; then
    echo "🧠 No se encontró el índice. Generando embeddings..."
    python3 prepare_embeddings.py
else
    echo "✅ Índice encontrado. Saltando generación."
fi

echo "🚀 Iniciando Streamlit..."
exec streamlit run app.py --server.port=8501 --server.address=0.0.0.0
