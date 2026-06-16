# aws-openshift-cli

[![Docker Image Build](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-image.yml/badge.svg)](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-image.yml)
[![Docker Publish](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-publish.yml)

Container image with AWS CLI, kubectl, and OpenShift CLI (oc) for CI jobs and OpenShift automation.



## Overview

This repository provides a maintained CLI image for teams that need AWS + Kubernetes + OpenShift tooling in one runtime. The main use case for this is the automated updating of pull secrets for images in private AWS ECR registries

## Features

- `aws`, `kubectl` and `oc` shipped in the same image
- GitHub Actions workflows for image test/build/publish
- Example OpenShift CronJob (`cron.yaml`) for ECR pull-secret refresh



Handle secrets via your platform secret store; do not commit real credentials.

## CI and tests

The CI pipeline focuses on core validations: it builds the image, verifies `aws`, `kubectl`, and `oc`, and publishes/signs the image when checks pass. See [docker-image.yml](./.github/workflows/docker-image.yml) and [docker-publish.yml](./.github/workflows/docker-publish.yml) for full pipeline details.

Run the important checks locally:

```bash
docker build -t aws-openshift-cli:test .
docker run --rm aws-openshift-cli:test --version
docker run --rm --entrypoint kubectl aws-openshift-cli:test version --client
docker run --rm --entrypoint oc aws-openshift-cli:test version
```

## Image details and maintenance

- Current image sources are defined in `Dockerfile`:
  - `public.ecr.aws/aws-cli/aws-cli:x.xx.x`
  - `quay.io/openshift/origin-cli:x.xx`
- Tags are generated in CI (branch, SHA, semver tags).

### Why this image was forked

The original upstream image ([bk203/aws-openshift-cli](https://github.com/bk203/aws-openshift-cli)) has not received updates since 2020, and recent automated scans flagged security vulnerabilities in its dependencies. Because those issues were not being addressed upstream, and the image is used in our CI/builds, we created and maintain a forked image with updated dependencies and security fixes. This fork enables timely updates, faster remediation of scanner findings, and lifecycle control for our security and compliance requirements.


## Contributing

1. Create a branch and open a PR against `main`.
2. Run local checks from [CI and tests](#ci-and-tests) before requesting review.
3. Keep changes focused and include usage updates in this README when behavior changes.

