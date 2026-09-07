ARG SJP_VERSION=0.1.1
ARG SJP_SHA256=30d9424df1eddb73912b0e2ad5375fa2c876c8e30906bec91952dfb75dcf220b

FROM ubuntu:26.04

RUN apt update && apt install -y --no-install-recommends python3 python3-pip python3-venv && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/StaticJinjaPlus

ARG SJP_VERSION
ARG SJP_SHA256
ADD --checksum=sha256:${SJP_SHA256} https://codeload.github.com/MrDave/StaticJinjaPlus/tar.gz/refs/tags/${SJP_VERSION} /tmp/sjp.tar.gz

RUN tar -xzf /tmp/sjp.tar.gz --strip-components=1 && rm /tmp/sjp.tar.gz && python3 -m venv /opt/venv && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

CMD [ "/opt/venv/bin/python", "main.py" ]