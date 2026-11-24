#!/usr/bin/env bash
# À lancer sur la VM : bash tp3-setup.sh   → prépare ~/cicd-lab (clone, Git neuf, script verify, 1er commit)
set -euo pipefail
cd ~
if [ -d cicd-lab ]; then echo "~/cicd-lab existe déjà, je m'arrête."; exit 1; fi

# Node 24 via nvm (installation dans ton utilisateur, ne touche pas au Node du système)
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
. "$NVM_DIR/nvm.sh"
nvm install 24 && nvm use 24
node --version

git config --get user.name  >/dev/null || git config --global user.name "Hanin Haj Youssef"
git config --get user.email >/dev/null || git config --global user.email "haninhajyoussef1@gmail.com"

git clone https://github.com/wahid007/cicd-lab-starter.git cicd-lab
cd cicd-lab
rm -rf .git
git init -b main
npm ci
npm pkg set scripts.verify="npm run typecheck && npm test && npm run build"
npm run verify
git add .
git commit -m "feat: add starter app with local verification"
echo
echo "OK. Suite : crée le dépôt GitHub vide 'cicd-lab' (public), puis :"
echo "  cd ~/cicd-lab && git remote add origin https://github.com/HaninHajYoussef/cicd-lab.git && git push -u origin main"
