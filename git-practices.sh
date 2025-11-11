#!/usr/bin/env bash
set -euo pipefail

# Git Practice Playground
# This script creates a local repo with branches and a local bare remote so you can practice:
# revert, reset, merge, rebase, cherry-pick, stash, push, pull, and fetch

LAB_DIR="${PWD}/git-lab"
REMOTE_DIR="${PWD}/git-lab-remote.git"

if [[ -d "$LAB_DIR" || -d "$REMOTE_DIR" ]]; then
  echo "Error: ${LAB_DIR} or ${REMOTE_DIR} already exists. Move or remove them, or run in a clean folder."
  exit 1
fi

mkdir -p "$LAB_DIR"
cd "$LAB_DIR"
git init -q

# user identity (override if you like)
git config user.name "Git Student"
git config user.email "student@example.com"

# --- main branch base ---
echo "# Git Lab" > README.md
echo "Welcome to the Git lab." >> README.md
echo "v1" > app.txt
echo "alpha" > data.txt
git add .
git commit -qm "init: README, app.txt v1, data.txt alpha"

# Make a second commit on main
echo "main: setup section" >> README.md
git commit -am "docs: add setup section to README" -q

# Create a local bare remote and set as origin
cd ..
git init --bare -q "$REMOTE_DIR"
cd "$LAB_DIR"
git remote add origin "$REMOTE_DIR"
git branch -M main
git push -u origin main -q

# --- feature/typo-fix ---
git switch -q -c feature/typo-fix
sed -i.bak 's/Welcome/We1come/' README.md || perl -0777 -pe 's/Welcome/We1come/g' -i README.md
rm -f README.md.bak 2>/dev/null || true
git commit -am "docs(typo): introduce an intentional typo in README (We1come)" -q

# --- feature/landing ---
git switch -q main
git switch -q -c feature/landing
mkdir -p web
cat > web/landing.html <<'HTML'
<!doctype html>
<html>
  <head><title>Landing</title></head>
  <body><h1>Landing v1</h1></body>
</html>
HTML
git add web/landing.html
git commit -qm "feat(web): add landing page v1"

echo "console.log('landing v2');" > web/landing.js
git add web/landing.js
git commit -qm "feat(web): add landing script v2"

# --- bugfix/config ---
git switch -q main
git switch -q -c bugfix/config
cat > config.json <<'JSON'
{"env":"dev","featureX":false}
JSON
git add config.json
git commit -qm "fix(config): add basic config.json (dev env)"

# --- experiment/rebase ---
git switch -q main
OLD_BASE=$(git rev-parse HEAD~1)
git switch -q -c experiment/rebase "$OLD_BASE"
echo "v2-experimental" >> app.txt
git commit -am "exp(app): bump app.txt to v2-experimental on old base" -q

printf "\nconflict-line: experiment branch edit\n" >> app.txt
git commit -am "exp(app): add conflict line on experiment" -q

git switch -q main
printf "\nconflict-line: main branch edit\n" >> app.txt
git commit -am "main(app): add conflicting line on main" -q

git push -u origin feature/typo-fix -q
git push -u origin feature/landing -q
git push -u origin bugfix/config -q
git push -u origin experiment/rebase -q

echo
echo "✅ Git Lab ready!"
echo "Repo: $LAB_DIR"
echo "Remote: $REMOTE_DIR (local bare)"
echo
echo "Try:  cd \"$LAB_DIR\""
echo "Then run 'git log --oneline --graph --decorate --all' to view the setup."

