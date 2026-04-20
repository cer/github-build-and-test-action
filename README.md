# Build, Test, and Publish GitHub Actions

Reusable [composite GitHub Actions](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action) for building, testing, and publishing Java/Gradle microservice projects with Kubernetes integration testing.

## Actions

This repository provides three composite actions:

- **`build-and-test`** — Sets up JDK and Gradle, and builds the project
- **`k8s-test`** — Deploys to a Kind cluster, runs integration tests, and collects diagnostics
- **`k8s-publish`** — Pushes Docker images and publishes Helm charts

### `build-and-test`

Sets up JDK 17 (Temurin) and Gradle, then builds the project with build caching enabled.

**Usage:**

```yaml
steps:
  - uses: your-org/github-build-and-test-action/build-and-test@main
```

**What it does:**

1. Sets up JDK 17 (Temurin distribution)
2. Configures Gradle with read/write caching
3. Runs `./gradlew build --build-cache`

### `k8s-test`

Deploys the application to a [Kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker) cluster and runs integration tests, including Kafka and service-level tests. Collects diagnostics and logs on completion.

**Inputs:**

| Name           | Required | Description                                  |
|----------------|----------|----------------------------------------------|
| `github-token` | Yes      | GitHub token for Docker registry (ghcr.io) authentication |

**Usage:**

```yaml
steps:
  - uses: your-org/github-build-and-test-action/k8s-test@main
    with:
      github-token: ${{ secrets.GITHUB_TOKEN }}
```

**What it does:**

1. Installs Kubernetes tools
2. Validates K8s manifests
3. Creates a Kind cluster with ghcr.io Docker registry credentials
4. Installs infrastructure services (including Kafka)
5. Runs integration tests (Kafka, JWT, service tests)
6. Collects pod logs and container logs (always, even on failure)
7. Uploads test reports and container logs as artifacts
8. Tears down services and deletes the Kind cluster

**Artifacts produced:**

- `test-reports` — Gradle build reports and test results
- `container-logs` — Kubernetes container logs

### `k8s-publish`

Pushes Docker images and publishes Helm charts with a timestamped version.

**Inputs:**

| Name             | Required | Default | Description                                      |
|------------------|----------|---------|--------------------------------------------------|
| `github-token`   | Yes      |         | GitHub token for Docker registry and Helm chart publishing |
| `service-name`   | Yes      |         | Name of the service to publish                   |
| `version-prefix` | No       | `0.1.0` | Version prefix (e.g. `0.1.0`)                   |

**Usage:**

```yaml
steps:
  - uses: your-org/github-build-and-test-action/k8s-publish@main
    with:
      github-token: ${{ secrets.GH_TOKEN }}
      service-name: customer-service
```

**What it does:**

1. Generates a timestamped version (`<version-prefix>-BUILD.<timestamp>`)
2. Pushes Docker images via `./manage/push-images.sh`
3. Publishes Helm charts via `./manage/publish-helm-chart.sh`

## Example

See [example-service-with-componentized-deployment-pipeline](https://github.com/cer/example-service-with-componentized-deployment-pipeline/) for a project that uses these actions.

## License

Apache License 2.0 — see [LICENSE.md](LICENSE.md).
