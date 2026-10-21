# Stage 1: download the model once at build time
FROM curlimages/curl:latest AS model
ARG MODEL_URL=https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf
RUN curl -L --fail -o /tmp/model.gguf "$MODEL_URL"

# Stage 2: llama.cpp server
FROM ghcr.io/ggml-org/llama.cpp:server
COPY --from=model /tmp/model.gguf /models/model.gguf

ENV LLAMA_ARG_MODEL=/models/model.gguf \
    LLAMA_ARG_HOST=0.0.0.0 \
    LLAMA_ARG_CTX_SIZE=2048 \
    LLAMA_ARG_THREADS=2

# Render injects PORT; llama-server reads LLAMA_ARG_PORT, so map it at start
ENTRYPOINT ["/bin/sh", "-c", "LLAMA_ARG_PORT=${PORT:-10000} exec /app/llama-server"]
