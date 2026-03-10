#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./08-init-api.sh <ProjectName> <SolutionName> [ApiName] [TargetDir] [DestRoot]
# Example:
#   ./08-init-api.sh Dino Dino

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
TEMPLATE_ROOT=$(cd -- "${SCRIPT_DIR}/../.." && pwd)

SOURCE_DIR="${TEMPLATE_ROOT}/references/TodoApi"

PROJECT_NAME="${1:-}"
if [[ -z "${PROJECT_NAME}" ]]; then
  read -r -p "Project name (e.g. Dino): " PROJECT_NAME
fi

if [[ -z "${PROJECT_NAME}" ]]; then
  echo "Project name is required."
  exit 1
fi

SOLUTION_NAME="${2:-}"
if [[ -z "${SOLUTION_NAME}" ]]; then
  read -r -p "Solution name (e.g. Dino): " SOLUTION_NAME
fi

if [[ -z "${SOLUTION_NAME}" ]]; then
  echo "Solution name is required."
  exit 1
fi

API_NAME="${3:-}"
if [[ -z "${API_NAME}" ]]; then
  if [[ -t 0 ]]; then
    read -r -p "API name (default: ${PROJECT_NAME}): " API_NAME
  fi
fi

if [[ -z "${API_NAME}" ]]; then
  API_NAME="${PROJECT_NAME}"
fi

TARGET_DIR_OVERRIDE="${4:-}"
DEST_ROOT_OVERRIDE="${5:-}"

DEST_ROOT="${TEMPLATE_ROOT}"
if [[ -n "${DEST_ROOT_OVERRIDE}" ]]; then
  DEST_ROOT="${DEST_ROOT_OVERRIDE}"
fi

SOLUTION_PATH="${DEST_ROOT}/${SOLUTION_NAME}.sln"
if [[ -n "${TARGET_DIR_OVERRIDE}" ]]; then
  if [[ "${TARGET_DIR_OVERRIDE}" = /* ]]; then
    TARGET_DIR="${TARGET_DIR_OVERRIDE}"
  else
    TARGET_DIR="${DEST_ROOT}/${TARGET_DIR_OVERRIDE}"
  fi
else
  TARGET_DIR="${DEST_ROOT}/${PROJECT_NAME}/Api"
fi

if [[ ! -d "${SOURCE_DIR}" ]]; then
  echo "Source project not found at ${SOURCE_DIR}"
  exit 1
fi

if [[ -d "${TARGET_DIR}" ]]; then
  echo "Target project already exists at ${TARGET_DIR}"
  exit 1
fi

if [[ ! -f "${SOLUTION_PATH}" ]]; then
  echo "Solution not found at ${SOLUTION_PATH}, creating it"
  dotnet new sln -n "${SOLUTION_NAME}" -o "${DEST_ROOT}" >/dev/null
fi

echo "Copying ${SOURCE_DIR} -> ${TARGET_DIR}"
if [[ -n "${TARGET_DIR_OVERRIDE}" ]]; then
  mkdir -p "$(dirname "${TARGET_DIR}")"
else
  mkdir -p "${DEST_ROOT}/${PROJECT_NAME}"
fi
cp -R "${SOURCE_DIR}" "${TARGET_DIR}"

rm -rf "${TARGET_DIR}/bin" "${TARGET_DIR}/obj" "${TARGET_DIR}/Migrations"
rm -f "${TARGET_DIR}/todo.db"

if [[ -f "${TARGET_DIR}/TodoApi.csproj" ]]; then
  mv "${TARGET_DIR}/TodoApi.csproj" "${TARGET_DIR}/Api.csproj"
fi

TARGET_DIR="${TARGET_DIR}" PROJECT_NAME="${PROJECT_NAME}" API_NAME="${API_NAME}" python3 - <<'PY'
import os
import pathlib
import re

target = pathlib.Path(os.environ["TARGET_DIR"])
project = os.environ["PROJECT_NAME"]
api_name = os.environ.get("API_NAME", "").strip()
base = api_name or project

def to_pascal(value: str) -> str:
    parts = re.split(r"[^A-Za-z0-9]+", value)
    return "".join([p[:1].upper() + p[1:] for p in parts if p])

def to_slug(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug or "api"

singular_title = to_pascal(base) or "Api"
plural_title = f"{singular_title}s"
singular_lower = to_slug(base)
plural_lower = f"{singular_lower}s"
api_title = f"{singular_title} API"

def replace_content(text: str) -> str:
    text = text.replace("TodoApi", "Api")
    text = text.replace("Todo API", api_title)
    text = text.replace("/todos-try-error", f"/{plural_lower}-try-error")
    text = text.replace("/todos", f"/{plural_lower}")
    text = text.replace("Todos", plural_title)
    text = text.replace("Todo", singular_title)
    text = text.replace("todos", plural_lower)
    text = text.replace("todo", singular_lower)
    return text

for path in target.rglob("*"):
    if path.is_file() and path.suffix in {".cs", ".csproj", ".json"}:
        text = path.read_text(encoding="utf-8")
        text = replace_content(text)
        path.write_text(text, encoding="utf-8")

for path in sorted(target.rglob("*"), key=lambda p: len(str(p)), reverse=True):
    if not path.exists():
        continue
    new_name = path.name
    new_name = new_name.replace("Todos", plural_title)
    new_name = new_name.replace("Todo", singular_title)
    new_name = new_name.replace("todos", plural_lower)
    new_name = new_name.replace("todo", singular_lower)
    if new_name != path.name:
        path.rename(path.with_name(new_name))
PY

dotnet sln "${SOLUTION_PATH}" add "${TARGET_DIR}/Api.csproj" >/dev/null
echo "Added Api.csproj to ${SOLUTION_PATH}"

echo "Api project initialized at ${TARGET_DIR}"
echo "Configuring user secrets"
API_DB_NAME=$(PROJECT_NAME="${PROJECT_NAME}" API_NAME="${API_NAME}" python3 - <<'PY'
import os
import re

project = os.environ["PROJECT_NAME"].strip()
api_name = os.environ.get("API_NAME", "").strip()
base = api_name or project

slug = re.sub(r"[^a-z0-9]+", "-", base.lower()).strip("-")
print(slug or "api")
PY
)

dotnet user-secrets --project "${TARGET_DIR}/Api.csproj" set "ApiKey:Value" "dev-key" >/dev/null
dotnet user-secrets --project "${TARGET_DIR}/Api.csproj" set "ConnectionStrings:Default" "Data Source=${API_DB_NAME}.db" >/dev/null
dotnet user-secrets --project "${TARGET_DIR}/Api.csproj" set "ApiKey:HeaderName" "X-Api-Key" >/dev/null
echo "Next steps:"
echo "- Review/rename generated entities if needed."
echo "- Create migration: dotnet tool run dotnet-ef migrations add InitialCreate --project ${TARGET_DIR}/Api.csproj --startup-project ${TARGET_DIR}/Api.csproj"
echo "- Apply migration: dotnet tool run dotnet-ef database update --project ${TARGET_DIR}/Api.csproj --startup-project ${TARGET_DIR}/Api.csproj"
echo "- Run: dotnet run --project ${TARGET_DIR}/Api.csproj"
