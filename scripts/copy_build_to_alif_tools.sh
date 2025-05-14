#!/usr/bin/env bash

# Copy the freshly-built Zephyr binary together with its flashing
# configuration into an Alif “flash-tools” checkout.
#
# Usage:
#   ./scripts/copy_build_to_flash_tools.sh <path-to-alif_tools_dir>
#
# This script:
#   1. Verifies the Zephyr image was built (build/zephyr/zephyr.bin).
#   2. Copies the image to <tools>/build/images/mandalay.bin.
#   3. Copies mandalay_alif_flash_cfg.json into <tools>/build/config/.
#   4. Prints the commands that need to be executed to actually flash
#      the board.
#
# Exit immediately if anything goes wrong and treat unset variables as
# an error.  Fail on errors in piped commands as well.
set -euo pipefail

usage() {
  cat <<EOF >&2
Usage: $0 <alif_tools_dir>

Copy build/zephyr/zephyr.bin along with its flasher configuration
into an Alif flash-tools checkout.

Positional arguments:
  alif_tools_dir   Path to the root of the flash-tools repository that
                   contains app-gen-toc and app-write-mram.
EOF
  exit 1
}

# --- argument parsing -------------------------------------------------------
[ "$#" -eq 1 ] || usage

TOOLS_DIR="$1"

# Make TOOLS_DIR absolute for safety.
TOOLS_DIR="$(realpath "$TOOLS_DIR")"

# Validate tools directory.
if [[ ! -d "$TOOLS_DIR" ]]; then
  echo "Error: directory not found: $TOOLS_DIR" >&2
  exit 1
fi

# Paths inside the project ---------------------------------------------------
# Directory of this script -> project root one level up
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"

BIN_SRC="$PROJECT_ROOT/build/zephyr/zephyr.bin"
CFG_SRC="$PROJECT_ROOT/mandalay_alif_flash_cfg.json"

# Ensure the binary exists ----------------------------------------------------
if [[ ! -f "$BIN_SRC" ]]; then
  echo "Error: $BIN_SRC not found. Build the project first (e.g. make)." >&2
  exit 1
fi

# Ensure the configuration file exists ---------------------------------------
if [[ ! -f "$CFG_SRC" ]]; then
  echo "Error: configuration file missing: $CFG_SRC" >&2
  exit 1
fi

# Destination paths inside tools directory -----------------------------------
IMAGES_DIR="$TOOLS_DIR/build/images"
CONFIG_DIR="$TOOLS_DIR/build/config"

mkdir -p "$IMAGES_DIR" "$CONFIG_DIR"

BIN_DST="$IMAGES_DIR/mandalay.bin"
CFG_DST="$CONFIG_DIR/$(basename "$CFG_SRC")"

# Perform the copies ---------------------------------------------------------
cp "$BIN_SRC" "$BIN_DST"
cp "$CFG_SRC" "$CFG_DST"

echo "Copied:"
echo "  $BIN_SRC -> $BIN_DST"
echo "  $CFG_SRC -> $CFG_DST"

cat <<EOF

Next steps:

  cd $TOOLS_DIR
  ./app-gen-toc -f build/config/$(basename "$CFG_SRC")
  ./app-write-mram -p -v

EOF
