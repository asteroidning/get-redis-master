FROM redis:5.0.6

WORKDIR /
RUN  sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list  && \
     sed -i 's/security.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list  && \
     apt-get update && \
     apt-get install curl -y && \
     rm -rf /var/lib/apt/lists/*

ENV KUBECTL_VERSION 1.18.14
#ENV KUBECTL_SHA256 6e0aaaffe5507a44ec6b1b8a0fb585285813b78cc045f8804e70a6aac9d1cb4c
ENV KUBECTL_URI https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl

RUN curl -SL ${KUBECTL_URI} -o kubectl && chmod +x kubectl && mv /kubectl /usr/bin/kubectl 

#RUN echo "${KUBECTL_SHA256}  kubectl" | sha256sum -c - || exit 10
#ENV PATH="/:${PATH}"

COPY entrypoint.sh /
USER root
ENTRYPOINT ["/entrypoint.sh"]
