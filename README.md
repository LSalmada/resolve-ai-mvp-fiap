# Resolve Aí

MVP Rails 8 (PostgreSQL, Tailwind, importmap, Stimulus) for POSTECH FSDT Fase 5.

## Local setup

Ruby 3.3.7, Docker, and Bundler.

```bash
docker compose up -d db
bin/setup --skip-server
bin/dev
```

`bin/setup` installs gems and prepares the database. `bin/dev` runs Puma + Tailwind.

Postgres runs in Compose (`postgres:16`) on **localhost:5432** (`postgres` / `postgres`). If that port is already taken:

```bash
POSTGRES_PUBLISH_PORT=5433 docker compose up -d db
POSTGRES_PORT=5433 bin/setup --skip-server
POSTGRES_PORT=5433 bin/dev
```

The production-oriented `Dockerfile` is included; the app itself is meant to run on the host during development. To try the containerized app: `docker compose --profile app up`.

local:

```bash
docker compose up -d db
POSTGRES_PORT=5433 bin/setup --skip-server
POSTGRES_PORT=5433 bin/dev
```
