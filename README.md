# aws-openshift-cli

[![Docker Image CI](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-image.yml/badge.svg)](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-image.yml)
[![Docker Publish](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/rku-it-GmbH/aws-openshift-cli/actions/workflows/docker-publish.yml)

Docker image combining the following tools:

* AWS ClI
* Kubernetes CLI (kubectl)
* OpenShift CLI (oc)

## CI/CD Workflows

This repository uses two GitHub Actions workflows to build, test, and publish the Docker image.

### docker-image.yml — Docker Image CI

Triggers on every push to `main` and on pull requests targeting `main`.

**Jobs:**
- **build** – Builds the Docker image using Docker Buildx with GHA layer caching and runs the following tests against the built image:
  - `aws --version` – verifies the AWS CLI is installed
  - `kubectl version --client` – verifies kubectl is installed
  - `oc version` – verifies the OpenShift CLI is installed

The workflow fails if the image cannot be built or if any test command exits with a non-zero status, preventing a broken image from being published.

### docker-publish.yml — Docker Publish

Triggers on push to `main` and on semver tags (`v*.*.*`). Also runs (build-only, no push) on pull requests.

**Jobs:**
- **test** – Same build-and-test steps as `docker-image.yml`. The publish job does not start unless this job succeeds.
- **build** – Builds the image with Docker Buildx, pushes it to [GitHub Container Registry (ghcr.io)](https://ghcr.io) using `GITHUB_TOKEN`, and signs the image with [cosign](https://github.com/sigstore/cosign) for supply-chain integrity. The image is **not** pushed on pull requests.

#### Image tags

`docker/metadata-action` generates the following tags automatically:

| Event | Tags applied |
|-------|-------------|
| Push to `main` | `ghcr.io/<owner>/aws-openshift-cli:main`, `ghcr.io/<owner>/aws-openshift-cli:sha-<short-sha>` |
| Tag `v1.2.3` | `ghcr.io/<owner>/aws-openshift-cli:1.2.3`, `ghcr.io/<owner>/aws-openshift-cli:1.2`, `ghcr.io/<owner>/aws-openshift-cli:1`, `ghcr.io/<owner>/aws-openshift-cli:latest` |
| Pull request | Build only, no push |

#### Required secrets

| Secret | Description |
|--------|-------------|
| `GITHUB_TOKEN` | Automatically provided by GitHub Actions. Used to authenticate with `ghcr.io` and to sign the image with cosign. No manual configuration required. |

#### Required repository permissions

The workflows use `permissions: packages: write` to push packages to GHCR. This is granted automatically via `GITHUB_TOKEN` as long as Actions are enabled for the repository.

#### Making the GHCR package public

By default, packages published to GHCR inherit the repository visibility (private for private repos). To make the published image public:

1. Navigate to the package page: `https://github.com/orgs/<owner>/packages` or `https://github.com/<owner>?tab=packages`.
2. Click the published package (`aws-openshift-cli`).
3. Click **Package settings** (bottom-right).
4. Under **Danger Zone**, click **Change visibility** → select **Public** → confirm.

Alternatively, set the default package visibility to public in the organisation settings under **Packages** → **Default package visibility**.

## Usage within OpenShift

On OpenShift we deploy a [CronJob](https://docs.openshift.com/container-platform/3.11/dev_guide/cron_jobs.html) that will be responsible for renewing the credentials stored within a secret.

```
# Grant privalliages to allow creation of secrets, admin is overpowered still researching
oc policy add-role-to-user admin system:serviceaccount:{$PROJECT}:default

# From GitHub
oc create -f https://raw.githubusercontent.com/bk203/aws-openshift-cli/master/cron.yaml

# From file
oc create -f cron.yaml
```

Next update the created ConfigMap containing your AWS credentials, and your done.

The CronJob will run every [“At every minute past every 8th hour.”](https://crontab.guru/#*_*/8_*_*_*), to manually start the job you can run:

```
oc create job refresh-aws-credentials --from=cronjob/aws-registry-credential-cron
```
