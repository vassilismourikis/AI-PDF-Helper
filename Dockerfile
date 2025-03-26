FROM python:3.12-slim

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y curl

# Install Python dependencies
RUN pip install --no-cache-dir streamlit \
    langchain_core \
    langchain_community \
    langchain_ollama \
    pdfplumber \
    sentence_transformers \
    faiss_cpu \
    pypdf

# Copy application files
COPY . /app

# Download and install Ollama
RUN curl -fsSL https://ollama.com/install.sh | sh

# Pull the Ollama model at build time (so it’s cached in the image)
RUN nohup ollama serve > ollama_output.log 2>&1 & sleep 5 && ollama pull deepseek-r1:1.5b

# Expose port for Streamlit
EXPOSE 8501

# Start everything at runtime
CMD /bin/sh -c "nohup ollama serve > ollama_output.log 2>&1 & sleep 5 && ollama run deepseek-r1:1.5b && streamlit run app.py --server.port=8501 --server.address=0.0.0.0"
