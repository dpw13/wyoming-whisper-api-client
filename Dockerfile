# Had to move from debian-stable:slim to ubuntu due to glibc 2.38 requirement
# by openvino
FROM ubuntu:latest AS build

ARG WHISPER_CPP_VERSION=1.7.6
ARG OPENVINO_VERSION=2025.2.0.19140.c01cd93e24d

ADD https://storage.openvinotoolkit.org/repositories/openvino/packages/2025.2/linux/openvino_toolkit_ubuntu24_2025.2.0.19140.c01cd93e24d_x86_64.tgz /tmp/openvino.tgz
RUN mkdir -p /opt/intel/openvino \
 && tar -zxf /tmp/openvino.tgz -C /opt/intel/openvino --strip-components 1 \
 && cd /opt/intel/openvino && ./install_dependencies/install_openvino_dependencies.sh -y

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential wget git cmake python3-pip bash libtbb12 \
 && rm -rf /var/lib/apt/lists/*

ADD https://github.com/ggml-org/whisper.cpp/archive/refs/tags/v${WHISPER_CPP_VERSION}.tar.gz /tmp/whisper-cpp.tgz
RUN mkdir /whisper.cpp \
 && tar -zxf /tmp/whisper-cpp.tgz -C /whisper.cpp --strip-components 1

# Build whisper.cpp
RUN cd /whisper.cpp \
 && cmake -B build -DWHISPER_OPENVINO=1 -DOpenVINO_DIR=/opt/intel/openvino/runtime/cmake \
 && cmake --build build -j --config Release

FROM ubuntu:latest AS runtime

COPY --from=build /whisper.cpp /whisper.cpp
COPY --from=build /opt/intel/openvino /opt/intel/openvino
ADD . /wyoming-whisper-api-client

RUN apt-get update \
 && apt-get install -y --no-install-recommends libgomp1 python3-pip wget \
 && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --break-system-packages -r wyoming-whisper-api-client/requirements.txt

WORKDIR /wyoming-whisper-api-client/
ADD run.sh ./
RUN chmod +x run.sh

ENTRYPOINT ["/bin/sh", "/wyoming-whisper-api-client/run.sh"]
