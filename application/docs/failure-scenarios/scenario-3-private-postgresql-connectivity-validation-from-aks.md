# Scenario 3 - Private PostgreSQL connectivity validation from AKS

## Symptom

The cloud database is provisioned, but connectivity from the AKS runtime path is still unproven or appears to fail.

## Impact

The application team cannot safely assume that:

- private DNS resolution works
- AKS can reach the private PostgreSQL server
- PostgreSQL credentials are valid from the governed cloud path

## Detection

Use an in-cluster debug pod instead of a laptop `psql` session.

From the repository root:

```bash
set -a
source .env
set +a
```

Refresh AKS credentials if needed:

```bash
az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME" \
  --overwrite-existing
```

Start a temporary PostgreSQL client pod:

```bash
kubectl run pg-debug-1 \
  --rm -it \
  --image=postgres:16 \
  --restart=Never \
  --env="PGPASSWORD=$POSTGRES_ADMIN_PASSWORD" \
  --env="POSTGRES_SERVER_NAME=$POSTGRES_SERVER_NAME" \
  --env="POSTGRES_ADMIN_USERNAME=$POSTGRES_ADMIN_USERNAME" \
  --env="POSTGRES_DATABASE_NAME=$POSTGRES_DATABASE_NAME" \
  -- bash
```

Inside the pod, validate the environment first:

```bash
echo "$POSTGRES_SERVER_NAME"
echo "$POSTGRES_ADMIN_USERNAME"
echo "$POSTGRES_DATABASE_NAME"
```

Validate private DNS resolution:

```bash
getent hosts "$POSTGRES_SERVER_NAME.postgres.database.azure.com"
```

Validate PostgreSQL login:

```bash
psql \
  -h "$POSTGRES_SERVER_NAME.postgres.database.azure.com" \
  -U "$POSTGRES_ADMIN_USERNAME" \
  -d "$POSTGRES_DATABASE_NAME" \
  -c "select current_database(), current_user;"
```

Optional readiness check:

```bash
pg_isready \
  -h "$POSTGRES_SERVER_NAME.postgres.database.azure.com" \
  -U "$POSTGRES_ADMIN_USERNAME" \
  -d "$POSTGRES_DATABASE_NAME"
```

## Common mistakes

### Reusing a stale debug pod name

Symptoms:

- `Error from server (AlreadyExists): pods "pg-debug" already exists`

Fix:

```bash
kubectl delete pod pg-debug
```

Or use a unique name such as `pg-debug-1`, `pg-debug-2`, and so on.

### Passing only `PGPASSWORD` into the pod

If the pod only receives:

- `PGPASSWORD`

then `POSTGRES_SERVER_NAME`, `POSTGRES_ADMIN_USERNAME`, and `POSTGRES_DATABASE_NAME` are empty inside the pod.

Symptoms:

- a hostname like `.postgres.database.azure.com`
- `could not translate host name`

Fix:

- pass `POSTGRES_SERVER_NAME`
- pass `POSTGRES_ADMIN_USERNAME`
- pass `POSTGRES_DATABASE_NAME`

### Typo in the PostgreSQL hostname

Incorrect:

- `postgres.databases.azure.com`

Correct:

- `postgres.database.azure.com`

### Typo in `kubectl run --env`

Incorrect:

- `--env"POSTGRES_ADMIN_USERNAME=..."`

Correct:

- `--env="POSTGRES_ADMIN_USERNAME=..."`

## Root cause

The cloud database is private by design, so laptop-based connectivity checks are not the normal validation path. The intended validation path is from inside AKS.

## Fix

Validate the database from an in-cluster debug pod and confirm:

- the hostname resolves to a private IP
- PostgreSQL accepts connections
- the expected database and user are returned

## Validation

- `getent hosts` resolves the PostgreSQL hostname to a private address
- `psql` succeeds and returns the expected database and user
- `pg_isready` reports `accepting connections`
