ARG SJP_REF=refs/tags/0.1.1
ARG SJP_SHA256=30d9424df1eddb73912b0e2ad5375fa2c876c8e30906bec91952dfb75dcf220b

FROM ubuntu:26.04

RUN apt update && apt install -y --no-install-recommends python3 python3-pip python3-venv && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/StaticJinjaPlus

ARG SJP_REF
ARG SJP_SHA256
ADD https://codeload.github.com/MrDave/StaticJinjaPlus/tar.gz/${SJP_REF} /tmp/sjp.tar.gz

RUN [ "$SJP_SHA256" = "none" ] || echo "$SJP_SHA256  /tmp/sjp.tar.gz" | sha256sum -c - && tar -xzf /tmp/sjp.tar.gz --strip-components=1 && rm /tmp/sjp.tar.gz && python3 -m venv /opt/venv && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

CMD [ "/opt/venv/bin/python", "main.py" ]