#!/bin/bash
# Verifies that games a host app does not reference are not compiled into its release build.
#
# For every game (a folder in lib/src/game/) it creates an app that only uses that game,
# builds it for the web with the compiler's --dump-info and checks from that report which
# game libraries are in the output: it must be that game only.
#
# Usage: tool/check_tree_shaking.sh [game folder ...]   (FLUTTER="fvm flutter" on CI)
# With game folders only the apps of those games are built (faster while developing a game).
# CI runs it without arguments.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
FLUTTER=${FLUTTER:-flutter}
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

dirs=()
classes=()
for dir in "$ROOT"/lib/src/game/*/; do
  name=$(basename "$dir")
  if [ "$#" -gt 0 ] && ! printf '%s\n' "$@" | grep -qx "$name"; then continue; fi
  dirs+=("$name")
  classes+=("$(grep -rho 'class [A-Za-z0-9]* extends FlutterMiniGameBuilder' "$dir" | awk '{print $2}')")
done
echo "Games: ${dirs[*]}"

$FLUTTER create --platforms web --project-name tree_shaking_app "$WORK/app" >/dev/null
cd "$WORK/app"
$FLUTTER pub add flutter_mini_games --path "$ROOT" >/dev/null

failed=0
for i in "${!dirs[@]}"; do
  cat > lib/main.dart <<EOF
import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';

void main() => runApp(MaterialApp(home: Builder(builder: const ${classes[$i]}().build)));
EOF
  $FLUTTER build web --release --no-wasm-dry-run --dump-info >/dev/null
  # Game folders that have code in the build, from the compiler's report
  included=$(python3 - build/web/main.dart.js.info.json <<'EOF'
import json, sys
libraries = json.load(open(sys.argv[1]))['elements']['library'].values()
uris = (library.get('canonicalUri', '') for library in libraries)
print(' '.join(sorted({uri.split('/src/game/')[1].split('/')[0] for uri in uris if '/src/game/' in uri})))
EOF
)
  if [ "$included" = "${dirs[$i]}" ]; then
    echo "✓ ${dirs[$i]}: no other game is compiled in"
  else
    echo "✗ ${dirs[$i]}: the build contains the games [$included]"
    failed=1
  fi
done

exit $failed
