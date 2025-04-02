#!/bin/bash

set -e

# ==== ARGUMENT PARSING ====
VERBOSE=false
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --workspace-id) WORKSPACE_ID="$2"; shift ;;
    --repo-slug) REPO_SLUG="$2"; shift ;;
    --env-file) ENV_FILE="$2"; shift ;;
    --username) USERNAME="$2"; shift ;;
    --password) PASSWORD="$2"; shift ;;
    --prefix) PREFIX="$2"; shift ;;
    --verbose) VERBOSE=true ;;
    *) echo "❌ Unknown parameter: $1"; exit 1 ;;
  esac
  shift
done

# ==== VALIDATION ====
if [[ -z "$WORKSPACE_ID" || -z "$REPO_SLUG" || -z "$ENV_FILE" || -z "$USERNAME" || -z "$PASSWORD" ]]; then
  echo "❌ Missing required arguments."
  echo "Usage:"
  echo "  $0 --workspace-id <id> --repo-slug <slug> --env-file <path> --username <user> --password <pass> [--prefix <optional>] [--verbose]"
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Env file '$ENV_FILE' not found!"
  exit 1
fi

log() {
  if [ "$VERBOSE" = true ]; then
    echo -e "🔍 $1"
  fi
}

# ==== GET UUID WITH PAGINATION ====
get_variable_uuid() {
  local key="$1"
  local url="https://api.bitbucket.org/2.0/repositories/$WORKSPACE_ID/$REPO_SLUG/pipelines_config/variables/"

  while [[ -n "$url" ]]; do
    response=$(curl -s -u "$USERNAME:$PASSWORD" "$url")
    uuid=$(echo "$response" | jq -r ".values[] | select(.key == \"$key\") | .uuid" | tr -d '{}"')

    if [[ -n "$uuid" ]]; then
      echo "$uuid"
      return
    fi

    url=$(echo "$response" | jq -r '.next // empty')
  done
}

# ==== CREATE OR UPDATE VAR ====
create_or_update_var() {
  local raw_key="$1"
  local value="$2"
  local key="${PREFIX}${raw_key}"
  echo "🔄 Processing: $key"

  uuid=$(get_variable_uuid "$key")
  log "Fetched UUID for $key: ${uuid:-<not found>}"

  local payload="{\"key\": \"$key\", \"value\": \"$value\", \"secured\": true}"

  if [[ -z "$uuid" ]]; then
    echo "➕ Creating: $key"
    local url="https://api.bitbucket.org/2.0/repositories/$WORKSPACE_ID/$REPO_SLUG/pipelines_config/variables/"

    response=$(curl -sS -w "\n%{http_code}" -o /tmp/resp.json -X POST -u "$USERNAME:$PASSWORD" \
      "$url" -H "Content-Type: application/json" -d "$payload" || echo "curl_error")

    if [[ "$response" == "curl_error" ]]; then
      echo "❌ curl failed while creating $key"
      return
    fi

    code=$(tail -n1 <<< "$response")
    body=$(cat /tmp/resp.json)

    echo "📬 POST Status: $code"
    echo "📄 Response: $body"

  else
    # Only attempt if UUID is valid format
    if ! [[ "$uuid" =~ ^[0-9a-fA-F-]+$ ]]; then
      echo "⚠️  Invalid UUID format for $key: $uuid"
      return
    fi

    echo "🔁 Updating: $key"
    local url="https://api.bitbucket.org/2.0/repositories/$WORKSPACE_ID/$REPO_SLUG/pipelines_config/variables/$uuid"

    response=$(curl -sS -w "\n%{http_code}" -o /tmp/resp.json -X PUT -u "$USERNAME:$PASSWORD" \
      "$url" -H "Content-Type: application/json" -d "$payload" || echo "curl_error")

    if [[ "$response" == "curl_error" ]]; then
      echo "❌ curl failed while updating $key"
      return
    fi

    code=$(tail -n1 <<< "$response")
    body=$(cat /tmp/resp.json)

    echo "📬 PUT Status: $code"
    echo "📄 Response: $body"
  fi
}

# ==== READ .env FILE ====
echo "📄 Reading .env file: $ENV_FILE"
while IFS= read -r line || [[ -n "$line" ]]; do
  line=$(echo "$line" | xargs)
  [[ -z "$line" || "$line" =~ ^# ]] && continue

  key="${line%%=*}"
  value="${line#*=}"
  key=$(echo "$key" | xargs)
  value=$(echo "$value" | xargs)

  if [[ -z "$key" ]]; then
    echo "⚠️  Skipping invalid line: $line"
    continue
  fi

  create_or_update_var "$key" "$value"
done < "$ENV_FILE"

echo "✅ Done."
