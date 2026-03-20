# Build and Test GitHub Actions

Reusable [composite GitHub Actions](https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-composite-action) for building and testing Java/Gradle microservice projects with Kubernetes integration testing.

## Actions

This repository provides two composite actions:

- **`build-and-test`** — Sets up JDK and Gradle, and builds the project
- **`k8s-test`** — Deploys to a Kind cluster, runs integration tests, and collects diagnostics

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

## Example

See [example-service-with-componentized-deployment-pipeline](https://github.com/cer/example-service-with-componentized-deployment-pipeline/) for a project that uses these actions.

## License

Apache License 2.0 — see [LICENSE.md](LICENSE.md).
