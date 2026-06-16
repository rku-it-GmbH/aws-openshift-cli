FROM alpine:3.24

RUN apk --no-cache --update add python py-pip groff less mailcap \
    && pip install --upgrade awscli s3cmd python-magic \
    && apk --purge -v del py-pip

# Add glibc as required for OpenShift CLI (oc)
RUN apk --no-cache add ca-certificates wget \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.30-r0/glibc-2.30-r0.apk \
    && apk add glibc-2.30-r0.apk

# Install kubectl and oc
RUN apk --no-cache add openssl \
	&& wget -q -O kubectl https://storage.googleapis.com/kubernetes-release/release/v1.17.0/bin/linux/amd64/kubectl \
	&& chmod +x kubectl && mv kubectl /usr/local/bin \
	&& wget -q https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz -O - | tar -xz \
	&& chmod +x openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc && mv openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit/oc /usr/local/bin \
	&& rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit

WORKDIR /tmp

VOLUME /root/.aws
VOLUME /project
ENTRYPOINT ["aws"]
