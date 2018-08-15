FROM stefz/docker-elasticsearch:6.2.3

# Based on pires/docker-elasticsearch-kubernetes
# https://github.com/pires/docker-elasticsearch-kubernetes

MAINTAINER stefanobaldo@gmail.com

# Override config, otherwise plug-in install will fail
ADD config /elasticsearch/config

# Set environment
ENV DISCOVERY_SERVICE elasticsearch-discovery

# Kubernetes requires swap is turned off, so memory lock is redundant
ENV MEMORY_LOCK false

COPY build/gcs.client.default.credentials_file /tmp

# Create keystore and set GCS service account
# busybox bug: "mktemp: Invalid argument" - remove ES_TMPDIR env when fixed
RUN ES_TMPDIR=$(mktemp -d -t elasticsearch.XXXXXX) /elasticsearch/bin/elasticsearch-keystore create \
    && cat /tmp/gcs.client.default.credentials_file | ES_TMPDIR=$(mktemp -d -t elasticsearch.XXXXXX) /elasticsearch/bin/elasticsearch-keystore add --stdin gcs.client.default.credentials_file \
    && rm -f /tmp/gcs.client.default.credentials_file
