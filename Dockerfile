# Phase 1: Build phase
FROM alpine:latest AS builder

RUN apk update && \
    apk add --no-cache python3 py3-pip

RUN pip3 install lastversion

RUN NOALBS_VERSION=$(lastversion https://github.com/715209/nginx-obs-automatic-low-bitrate-switching) && \
    apk add --no-cache wget && \
    wget -O /opt/noalbs.tar.gz https://github.com/715209/nginx-obs-automatic-low-bitrate-switching/releases/download/v$NOALBS_VERSION/noalbs-v$NOALBS_VERSION-x86_64-unknown-linux-musl.tar.gz && \
    tar -xzvf /opt/noalbs.tar.gz -C /opt && \
    mv /opt/noalbs-v$NOALBS_VERSION-x86_64-unknown-linux-musl /opt/noalbs && \
    chmod +x /opt/noalbs/noalbs

# Phase 2: Final phase
FROM alpine:latest

# Set environment variables in the second phase
ENV CONFIG_DIR=/opt/noalbs/config

# Create the config directory and mark it as a volume
VOLUME /opt/noalbs/config

COPY --from=builder /opt/noalbs/noalbs /opt/noalbs/noalbs
COPY --from=builder /opt/noalbs/config.json $CONFIG_DIR/config.json

RUN touch /opt/noalbs/.env

# Set the working directory to /opt/noalbs
WORKDIR /opt/noalbs

CMD ["./noalbs"]