#!/bin/sh

if [ ! -f "/models/ggml-${WHISPER_MODEL}.bin" ]; then
    cd /models || { echo "Could not open /models"; exit 1; }
    if ! /whisper.cpp/models/download-ggml-model.sh ${WHISPER_MODEL}; then
        echo "Failed to download ${WHISPER_MODEL} model" >&2
        exit 1
    fi
    mv /whisper.cpp/models/ggml-${WHISPER_MODEL}.bin /models/
    cd /wyoming-whisper-api-client
fi

/whisper.cpp/build/bin/whisper-server -l ${WHISPER_LANG} -bs ${WHISPER_BEAM_SIZE} -m /models/ggml-${WHISPER_MODEL}.bin --host 0.0.0.0 --port 8910 --suppress-nst --prompt "${WHISPER_PROMPT}" &

python3 -m wyoming_whisper_api_client --uri tcp://0.0.0.0:${WYOMING_PORT} --api http://localhost:8910/inference &

wait
exit $?

