FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    AGENT_BIN=/root/.cursor/bin/agent \
    WORKSPACE_DIR=/workspace/repo \
    PORT=8080

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://cursor.com/install | bash

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace
EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
