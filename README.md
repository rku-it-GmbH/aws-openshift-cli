# aws-openshift-cli

[![Docker Image CI](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-image.yml/badge.svg)](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-image.yml)
[![Docker Publish](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-publish.yml)

Container image with AWS CLI, kubectl, and OpenShift CLI (oc) for CI jobs and OpenShift automation.

## Quickstart

```bash
docker pull ghcr.io/rku-it-gmbh/aws-openshift-cli:main
docker run --rm ghcr.io/rku-it-gmbh/aws-openshift-cli:main --version
docker run --rm --entrypoint kubectl ghcr.io/rku-it-gmbh/aws-openshift-cli:main version --client
```

## Table of contents

- [Overview](#overview)
- [Features](#features)
- [Requirements and installation](#requirements-and-installation)
- [Usage examples](#usage-examples)
- [Configuration](#configuration)
- [CI and tests](#ci-and-tests)
- [Image details and maintenance](#image-details-and-maintenance)
- [Security and vulnerabilities](#security-and-vulnerabilities)
- [Contributing](#contributing)
- [Changelog and releases](#changelog-and-releases)
- [License and support](#license-and-support)

## Overview

This repository provides a maintained CLI image for teams that need AWS + Kubernetes + OpenShift tooling in one runtime.

## Features

- AWS CLI as default entrypoint (`aws`)
- `kubectl` and `oc` shipped in the same image
- GitHub Actions workflows for image test/build/publish
- Example OpenShift CronJob (`cron.yaml`) for ECR pull-secret refresh

## Requirements and installation

- Docker (or another OCI-compatible container runtime)
- AWS credentials for AWS commands (for example via mounted `~/.aws`)
- Kubernetes/OpenShift access only when running `kubectl`/`oc` commands

Use a published image:

```bash
docker pull ghcr.io/rku-it-gmbh/aws-openshift-cli:main
```

Or build locally:

```bash
docker build -t aws-openshift-cli:test .
```

## Usage examples

Run AWS CLI command:

```bash
docker run --rm -v "$HOME/.aws:/root/.aws:ro" ghcr.io/rku-it-gmbh/aws-openshift-cli:main sts get-caller-identity
```

Run Kubernetes and OpenShift clients:

```bash
docker run --rm --entrypoint kubectl ghcr.io/rku-it-gmbh/aws-openshift-cli:main version --client
docker run --rm --entrypoint oc ghcr.io/rku-it-gmbh/aws-openshift-cli:main version
```

OpenShift CronJob example:

```bash
# Use least privilege. "edit" is often enough; use a custom role if possible.
oc policy add-role-to-user edit system:serviceaccount:${PROJECT}:default
oc apply -f https://raw.githubusercontent.com/rku-it-GmbH/aws-openshift-cli/main/cron.yaml
oc create job refresh-aws-credentials --from=cronjob/aws-registry-credential-cron
```

## Configuration

- Default entrypoint: `aws`
- Image volumes:
  - `/root/.aws` (credentials/config)
  - `/project` (working data)
- CronJob config values (see `cron.yaml`):
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_ACCOUNT`
  - `AWS_REGION`

Handle secrets via your platform secret store; do not commit real credentials.

## CI and tests

CI is intentionally short: it builds the image, verifies `aws`, `kubectl`, and `oc`, and publishes/signs the image when checks pass. See [docker-image.yml](./.github/workflows/docker-image.yml) and [docker-publish.yml](./.github/workflows/docker-publish.yml) for full pipeline details.

Run the important checks locally:

```bash
docker build -t aws-openshift-cli:test .
docker run --rm aws-openshift-cli:test --version
docker run --rm --entrypoint kubectl aws-openshift-cli:test version --client
docker run --rm --entrypoint oc aws-openshift-cli:test version
```

## Image details and maintenance

- Current image sources are defined in `Dockerfile`:
  - `public.ecr.aws/aws-cli/aws-cli:2.35.5`
  - `quay.io/openshift/origin-cli:4.18`
- Tags are generated in CI (branch, SHA, semver tags).

### Why this image was forked

The original upstream image ([bk203/aws-openshift-cli](https://github.com/bk203/aws-openshift-cli)) has not received updates since 2020 and recent automated scans flagged security vulnerabilities in its dependencies. Because those issues were not being addressed upstream and the image is used in our CI/builds, we created and maintain a forked image with updated dependencies and security fixes. This fork enables us to apply timely updates, fix security issues detected by our scanner, and control the image lifecycle to meet our organization’s security and compliance requirements.

## Security and vulnerabilities

If you find a vulnerability, please open a private security advisory in this repository (preferred). If that is not possible, open an issue with minimal sensitive detail and contact the maintainers through the repository owners.

## Contributing

1. Create a branch and open a PR against `main`.
2. Run local checks from [CI and tests](#ci-and-tests) before requesting review.
3. Keep changes focused and include usage updates in this README when behavior changes.

## Changelog and releases

Release history is available in [GitHub Releases](https://github.com/rku-it-GmbH/aws-openshift-cli/releases).

## License and support

No explicit license file is currently included in this repository. For usage questions or support, open an issue.
