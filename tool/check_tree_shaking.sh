#!/bin/bash
# Verifies that games a host app does not reference are not compiled into its release build.
#
# For every game it creates an app that only uses that game, builds it for the web and checks
# that the id of every other game (`static const id` in its controller) is absent from the output.
#
# Usage: tool/check_tree_shaking.sh   (FLUTTER="fvm flutter" tool/check_tree_shaking.sh on CI)
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
FLUTTER=${FLUTTER:-flutter}
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

classes=()
markers=()
for dir in "$ROOT"/lib/src/game/*/; do
  classes+=("$(grep -rho 'class [A-Za-z]* extends FlutterMiniGameBuilder' "$dir" | awk '{print $2}')")
  # dart2js emits string literals with double quotes
  markers+=("\"$(grep -rho "static const id = '[^']*'" "$dir" | sed "s/static const id = '\(.*\)'/\1/")\"")
done
echo "Games: ${classes[*]} (markers: ${markers[*]})"

$FLUTTER create --platforms web --project-name tree_shaking_app "$WORK/app" >/dev/null
cd "$WORK/app"
$FLUTTER pub add flutter_mini_games --path "$ROOT" >/dev/null

failed=0
for i in "${!classes[@]}"; do
  cat > lib/main.dart <<EOF
import 'package:flutter/material.dart';
import 'package:flutter_mini_games/flutter_mini_games.dart';

void main() => runApp(MaterialApp(home: Builder(builder: const ${classes[$i]}().build)));
EOF
  $FLUTTER build web --release --no-wasm-dry-run >/dev/null
  for j in "${!classes[@]}"; do
    found=$(grep -c -F "${markers[$j]}" build/web/main.dart.js || true)
    if [ "$i" = "$j" ] && [ "$found" = "0" ]; then
      echo "✗ ${classes[$i]}: own marker not found, the check is not reliable"
      failed=1
    elif [ "$i" != "$j" ] && [ "$found" != "0" ]; then
      echo "✗ ${classes[$i]}: ${classes[$j]} is compiled in although it is not used"
      failed=1
    fi
  done
  [ "$failed" = "0" ] && echo "✓ ${classes[$i]}: other games are tree-shaken"
done

exit $failed
