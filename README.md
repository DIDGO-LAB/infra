# DIDGO Infra Workspace

## Structure

- This repository provides the local integration environment.
- Sibling repositories expected by `docker-compose.yml`:
  - `../api-gateway`
  - `../user-service`
  - `../training-service`

## Request Flow

```text
Client
  -> Nginx edge proxy
  -> api-gateway
  -> user-service / training-service
```

## Database Layout

- `user_db`: account, profile, disability data
- `training_db`: training sessions, scores, feedback, summaries, outbox, and module tables

## Source Of Truth

- `user_db` bootstrap tables: `mysql/init/02-create-tables.sql`
- `training_db` schema: `../training-service/src/main/resources/db/migration`

`training_db` is intentionally owned by `training-service` Flyway migrations so the integration environment does not drift from service code.

## Local Ports

- `80` -> Nginx edge proxy HTTP redirect
- `443` -> Nginx edge proxy HTTPS
- `3307` -> MySQL container `3306`
- `6380` -> Redis container `6379`
- `8082` -> training-service container `8080`

Backend application containers continue talking over the internal Docker network.

## Run

```powershell
docker compose up -d --build
```

## HTTPS

`edge-proxy` terminates TLS and forwards requests to `api-gateway`.

- Local development: if `nginx/certs/fullchain.pem` and `nginx/certs/privkey.pem` are missing, the container generates a self-signed `localhost` certificate.
- Production/staging: put the issued certificate files at `nginx/certs/fullchain.pem` and `nginx/certs/privkey.pem` before starting the stack.
- Browser clients should call the gateway through `https://localhost` locally, or the deployed HTTPS domain in real environments.

## Check

```powershell
docker compose ps
docker compose logs api-gateway
docker compose logs user-service
docker compose logs training-service
```

## MySQL

```powershell
docker exec -it didgo-mysql mysql -uroot -prootpassword
```

## Notes

- Plain-text credentials are only for local development.
- `training-service` runs Flyway on startup and should be treated as the authoritative owner of `training_db`.
