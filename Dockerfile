FROM quay.io/openshift/origin-cli:4.22 AS openshift_cli

FROM public.ecr.aws/aws-cli/aws-cli:2.35.5

COPY --from=openshift_cli /usr/bin/oc /usr/local/bin/oc
COPY --from=openshift_cli /usr/bin/kubectl /usr/local/bin/kubectl

WORKDIR /tmp

VOLUME /root/.aws
VOLUME /project
ENTRYPOINT ["aws"]
