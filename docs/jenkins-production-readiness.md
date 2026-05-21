# Jenkins production readiness checklist

## Jenkins credentials

Create these credentials in **Manage Jenkins -> Credentials**:

| ID | Kind | Purpose |
| --- | --- | --- |
| `dockerhub-credentials` | Username with password/token | `docker login`, `docker push` |
| `staging-ssh-key` | SSH username with private key | SSH deploy to staging |
| `production-ssh-key` | SSH username with private key | SSH deploy to production |
| `discord-webhook-url` | Secret text | Optional Discord build notification |

Do not put passwords, tokens, SSH keys, or webhook URLs in `Jenkinsfile.windows`.

## Jenkins tools

Configure these in **Manage Jenkins -> Tools**:

| Tool | Jenkins name |
| --- | --- |
| JDK 21 | `JDK21` |
| Maven 3.9.11 | `Maven-3.9.11` |
| Git | Valid `git.exe` installation |
| NodeJS | Optional if NodeJS plugin is installed; otherwise keep Node in PATH |

## Branch rules

| Branch | Behavior |
| --- | --- |
| `feature/*` | Test + artifact only |
| `develop` | Test + artifact + Docker build + Docker push |
| `main` | Test + artifact + Docker build + Docker push + staging deploy |

Production deploy only runs on `main` when `DEPLOY_PRODUCTION=true`, and it requires manual approval.

## Docker image tags

Images are tagged by Git commit SHA:

```text
phuongdaithang/jenkins-demo-backend:<git-sha>
phuongdaithang/jenkins-demo-frontend:<git-sha>
```

Set `DOCKER_NAMESPACE` if the Docker Hub namespace is different.

## Staging server prerequisites

The staging server must have:

- Docker and Docker Compose.
- A deploy directory, for example `/opt/jenkins-demo`.
- A `docker-compose.yml` that reads `BACKEND_IMAGE` and `FRONTEND_IMAGE`.
- Docker registry access if the images are private.

Set these Jenkins parameters for staging smoke/deploy:

```text
STAGING_HOST
STAGING_USER
STAGING_DEPLOY_DIR
STAGING_SMOKE_URL
```

## Quality and security gates

Always-on checks:

- Backend Checkstyle.
- Backend tests with JaCoCo report.
- Frontend TypeScript lint.
- Frontend tests.
- Frontend build.

Optional security checks with `RUN_SECURITY_SCAN=true`:

- `npm audit --audit-level=high`
- OWASP Maven Dependency-Check, fail on CVSS >= 7
- Trivy Docker image scan for HIGH/CRITICAL vulnerabilities
