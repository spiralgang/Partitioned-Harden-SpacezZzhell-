#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
GRADLE_VERSION="${GRADLE_VERSION:-8.2}"
DIST_URL="https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"
PROPERTIES_FILE="$ROOT_DIR/gradle/wrapper/gradle-wrapper.properties"

mkdir -p "$(dirname "$PROPERTIES_FILE")"

update_properties_file() {
  local file="$1"
  python - "$file" "$DIST_URL" <<'PY'
import pathlib
import sys

properties_path = pathlib.Path(sys.argv[1])
dist_url = sys.argv[2]
lines = []
found = False
if properties_path.exists():
    with properties_path.open("r", encoding="utf-8") as fh:
        for line in fh:
            if line.startswith("distributionUrl="):
                if line.strip() != f"distributionUrl={dist_url}":
                    lines.append(f"distributionUrl={dist_url}\n")
                else:
                    lines.append(line)
                found = True
            else:
                lines.append(line if line.endswith("\n") else f"{line}\n")
else:
    properties_path.parent.mkdir(parents=True, exist_ok=True)

if not found:
    lines.append(f"distributionUrl={dist_url}\n")

if not any(line.startswith("distributionBase=") for line in lines):
    lines.insert(0, "distributionBase=GRADLE_USER_HOME\n")
if not any(line.startswith("distributionPath=") for line in lines):
    lines.insert(1, "distributionPath=wrapper/dists\n")
if not any(line.startswith("zipStoreBase=") for line in lines):
    lines.append("zipStoreBase=GRADLE_USER_HOME\n")
if not any(line.startswith("zipStorePath=") for line in lines):
    lines.append("zipStorePath=wrapper/dists\n")

with properties_path.open("w", encoding="utf-8") as fh:
    fh.writelines(lines)
PY
}

update_properties_file "$PROPERTIES_FILE"

if [[ -d "$ROOT_DIR/app" ]]; then
  while IFS= read -r -d '' module_props; do
    update_properties_file "$module_props"
  done < <(find "$ROOT_DIR/app" -name gradle-wrapper.properties -type f -print0)
fi

if [[ -f "$ROOT_DIR/gradlew" ]]; then
  chmod +x "$ROOT_DIR/gradlew"
fi

normalize_newlines() {
  local file="$1"
  [[ -f "$file" ]] || return 0
  python - "$file" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
text = path.read_text(encoding="utf-8")
text = text.replace("\r\n", "\n").rstrip("\n") + "\n"
path.write_text(text, encoding="utf-8")
PY
}

normalize_newlines "$ROOT_DIR/build.gradle"
normalize_newlines "$ROOT_DIR/settings.gradle"
normalize_newlines "$ROOT_DIR/app/build.gradle"

printf 'Android configuration aligned to Gradle %s\n' "$GRADLE_VERSION"
