---
paths:
  - "**/compose.yml"
  - "**/compose.yaml"
  - "**/docker-compose.yml"
  - "**/docker-compose.yaml"
---

# Docker Naming Convention

Every Docker resource (service, volume, network) for a project must be prefixed by the application name so `docker ps`,
`docker volume ls`, and `docker network ls` group all of an app's resources together. For development, add a `dev-`
prefix on top of the application prefix.

- Service: `{app}-{service}` (dev: `dev-{app}-{service}`)
- Application data volume: `{app}-data` (dev: `dev-{app}-data`)
- Application config volume: `{app}-config` (dev: `dev-{app}-config`)
- Network: `{app}-private` (dev: `dev-{app}-private`)

When a stack contains a sub-service with its own data store (e.g. a secrets manager bundled inside a `backup` stack
and needing its own Postgres), order the name segments so the sub-service segment comes BEFORE the resource type
segment. That way the data volume sorts adjacent to its parent service in alphabetical listings.

- Right: `dev-backup-vault` and `dev-backup-vault-postgres` (sort together)
- Wrong: `dev-backup-vault` and `dev-backup-postgres-vault` (the second sorts under `postgres-`, away from its parent)

In Compose files this means the volume `name:` field, the volume YAML key, the service name, the network name, and every
internal reference (`depends_on`, env-var hostnames in connection URLs) must all use the prefixed form.
