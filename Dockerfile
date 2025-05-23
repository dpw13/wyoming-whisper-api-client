FROM debian:stable-slim AS build

ARG WHISPER_CPP_VERSION

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential wget git cmake python3-pip bash \
 && rm -rf /var/lib/apt/lists/*

ADD https://github.com/ggml-org/whisper.cpp/archive/refs/tags/v${WHISPER_CPP_VERSION}.tar.gz /tmp/whisper-cpp.tgz
RUN mkdir /whisper.cpp \
    && tar -zxf /tmp/whisper-cpp.tgz -C /whisper.cpp --strip-components 1

# Build whisper.cpp
RUN cd /whisper.cpp \
    && cmake -B build \
    && cmake --build build --config Release

FROM debian:stable-slim AS runtime

COPY --from=build /whisper.cpp /whisper.cpp
ADD . /wyoming-whisper-api-client

RUN apt-get update \
 && apt-get install -y --no-install-recommends libgomp1 python3-pip wget \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages -r wyoming-whisper-api-client/requirements.txt

WORKDIR /wyoming-whisper-api-client/
ADD run.sh ./
RUN chmod +x run.sh

ENTRYPOINT ["/bin/sh", "/wyoming-whisper-api-client/run.sh"]
