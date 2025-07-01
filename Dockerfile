FROM debian:bullseye

# Variables
ENV PYTHON_VERSION=3.10.13
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 🧱 Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    cmake \
    ninja-build \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libffi-dev \
    liblzma-dev \
    xz-utils \
    ca-certificates \
    libncursesw5-dev \
    libgdbm-dev \
    tk-dev \
    uuid-dev \
    && rm -rf /var/lib/apt/lists/*

# 🐍 Instalar Python desde fuente
RUN wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j$(nproc) && \
    make altinstall && \
    cd .. && rm -rf Python-${PYTHON_VERSION}*

# Crear symlink para que python3 y pip funcionen
RUN ln -s /usr/local/bin/python3.10 /usr/bin/python3 && \
    ln -s /usr/local/bin/pip3.10 /usr/bin/pip3


# Instalar dependencias Python
COPY requirements.txt ./
RUN pip3 install --upgrade pip && pip3 install --no-cache-dir --prefer-binary -r requirements.txt

# Copiar código
COPY . .

# Puerto
EXPOSE 8501

# CMD
CMD ["streamlit", "run", "app.py", "--server.port=8501", "--server.address=0.0.0.0"]

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
ENTRYPOINT ["/app/entrypoint.sh"]

