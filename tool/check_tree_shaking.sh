#!/bin/bash
# Verifies that games a host app does not reference are not compiled into its release build,
# and measures how much each game adds to an app.
#
# For every game (a folder in lib/src/game/) it creates an app that only uses that game,
# builds it for the web with the compiler's --dump-info and checks from that report which
# game libraries are in the output: it must be that game only.
#
# Size: the baseline is a typical app screen (Scaffold, AppBar, a ListView and a bottom sheet)
# without the package. Every game app is that same screen with a list item that launches the
# game, so "added" is exactly what the game adds to an existing app; Flutter code that almost
# every app already ships (scrolling, bottom sheets) is not counted. "Added" is the growth of main.dart.js
# (raw and gzipped), "package" the code of flutter_mini_games itself from the compiler report
# (shared core + the game). Web (dart2js) sizes, a good relative measure for native builds too.
#
# Usage: tool/check_tree_shaking.sh [game folder ...]   (FLUTTER="fvm flutter" locally)
# With game folders only the apps of those games are built (faster while developing a game).
# CI runs it without arguments. SIZE_REPORT=<file> also writes the size table as Markdown
# (CI adds it to the job summary).
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
FLUTTER=${FLUTTER:-flutter}
WORK=$(mktemp -d)
if [ -n "${SIZE_REPORT:-}" ] && [[ "$SIZE_REPORT" != /* ]]; then SIZE_REPORT="$PWD/$SIZE_REPORT"; fi
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

build() {
  $FLUTTER build web --release --no-wasm-dry-run --dump-info >/dev/null
}

# Prints "<raw bytes> <gzip bytes> <package bytes> <core bytes> <games>" for the last build
measure() {
  python3 - build/web/main.dart.js build/web/main.dart.js.info.json <<'EOF'
import gzip, json, sys
js = open(sys.argv[1], 'rb').read()
libraries = json.load(open(sys.argv[2]))['elements']['library'].values()
package = core = 0
games = set()
for library in libraries:
    uri = library.get('canonicalUri', '')
    if not uri.startswith('package:flutter_mini_games/'):
        continue
    package += library.get('size', 0)
    if '/src/game/' in uri:
        games.add(uri.split('/src/game/')[1].split('/')[0])
    else:
        core += library.get('size', 0)
print(len(js), len(gzip.compress(js, 9)), package, core, ','.join(sorted(games)))
EOF
}

kb() {
  awk -v bytes="$1" 'BEGIN { printf "%.1f KB", bytes / 1024 }'
}

# Writes the app: a typical screen, with a list item that launches the game when one is given
write_app() {
  local import="" launch="null"
  if [ -n "${1:-}" ]; then
    import="import 'package:flutter_mini_games/flutter_mini_games.dart';"
    launch="() => FlutterMiniGames.launch(context, const $1())"
  fi
  cat > lib/main.dart <<EOF
import 'package:flutter/material.dart';
$import

void main() => runApp(MaterialApp(home: Builder(builder: (context) => Scaffold(
  appBar: AppBar(title: const Text('App')),
  body: ListView(children: [
    ListTile(title: const Text('Play'), onTap: $launch),
    for (var i = 0; i < 20; i++) ListTile(title: Text('Item \$i')),
  ]),
  floatingActionButton: FloatingActionButton(
    onPressed: () => showModalBottomSheet<void>(context: context, builder: (context) => const SingleChildScrollView(child: Text('Sheet'))),
    child: const Icon(Icons.add),
  ),
))));
EOF
}

write_app
build
read -r base_raw base_gzip _ <<<"$(measure)"
echo "Baseline app (Scaffold, AppBar, ListView and bottom sheet): $(kb "$base_raw") ($(kb "$base_gzip") gzipped)"

table="| Game | Added to the app | Added (gzipped) | Package code (core + game) |"$'\n'"|---|---:|---:|---:|"
failed=0
for i in "${!dirs[@]}"; do
  write_app "${classes[$i]}"
  build
  read -r raw gzipped package core included <<<"$(measure)"
  added=$((raw - base_raw))
  added_gzip=$((gzipped - base_gzip))
  game=$((package - core))
  size="+$(kb $added) (+$(kb $added_gzip) gzipped), package $(kb "$package") = core $(kb "$core") + game $(kb $game)"
  if [ "${included//,/ }" = "${dirs[$i]}" ]; then
    echo "✓ ${dirs[$i]}: no other game is compiled in, $size"
  else
    echo "✗ ${dirs[$i]}: the build contains the games [${included//,/ }], $size"
    failed=1
  fi
  table+=$'\n'"| ${dirs[$i]} | $(kb $added) | $(kb $added_gzip) | $(kb "$package") ($(kb "$core") + $(kb $game)) |"
done

echo
echo "$table"
if [ -n "${SIZE_REPORT:-}" ]; then
  {
    echo "### App size per game"
    echo
    echo "Web release build added to a typical app screen with a Scaffold, AppBar, ListView and bottom sheet ($(kb "$base_raw"), $(kb "$base_gzip") gzipped)."
    echo
    echo "$table"
  } >"$SIZE_REPORT"
fi

exit $failed
