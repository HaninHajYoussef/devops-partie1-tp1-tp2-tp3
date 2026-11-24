# TP3 – CI/CD GitHub Actions + Render (≈ 25 min)

Le projet `cicd-lab` est un dépôt **séparé** (~/cicd-lab sur la VM). Ce dossier-ci ne contient que le script, les snippets, les captures et le REPORT.
Terminal **[VM]** = SSH sur 192.168.56.101. Navigateur **[PC]**. Pour le push GitHub : même méthode qu'au TP1 (identifiant + token).

## 1. Préparer le projet — **[VM]**
```bash
cd ~/devops-partie1-tp1-tp2-tp3/tp3-cicd-github-actions
bash tp3-setup.sh
```
**[PC]** GitHub → New repository : `cicd-lab`, **Public**, sans README/license/gitignore. Puis **[VM]** :
```bash
cd ~/cicd-lab
git remote add origin https://github.com/HaninHajYoussef/cicd-lab.git
git push -u origin main
```
(À chaque nouveau terminal : `source ~/.nvm/nvm.sh && nvm use 24` pour avoir Node 24.)

## 2. Render (premier déploiement) — **[PC]**
render.com → New → Web Service → connecte GitHub → dépôt `cicd-lab` → branche `main`, Root Directory vide, instance **Free**.
- Build Command : `npm ci && npm run build`
- Start Command : `npm start`
- Health Check Path : `/api/health`
- Auto-Deploy : **On Commit**
Attends « Live », ouvre l'URL publique et `/api/health` → `{"status":"ok"}`.
📸 `captures/render-first-deploy.png`

## 3. GitHub Actions — **[VM]**
```bash
cd ~/cicd-lab
git switch -c feature/github-actions-ci
mkdir -p .github/workflows
cp ~/devops-partie1-tp1-tp2-tp3/tp3-cicd-github-actions/snippets/ci.yml .github/workflows/ci.yml
npm ci && npm run verify
git add . && git commit -m "ci: add GitHub Actions verification workflow"
git push -u origin feature/github-actions-ci
```
**[PC]** GitHub → Pull request vers `main` → attends **Verify** vert → 📸 `captures/actions-verify-pass.png` (logs dans l'onglet Actions) → **Create a merge commit** → Delete branch. Puis **[VM]** :
```bash
git switch main && git pull --ff-only && git branch -d feature/github-actions-ci
```
Attends le Verify de `main` (vert).

## 4. Render « After CI Checks Pass » — **[PC]**
Render → ton service → Settings → Auto-Deploy : **After CI Checks Pass**. 📸 `captures/render-auto-deploy.png`

## 5. Ruleset Protect main — **[PC]**
GitHub → dépôt → Settings → Rules → Rulesets → New branch ruleset : nom `Protect main`, Enforcement **Active**, Target **Default branch**, cocher *Require a pull request before merging* (approvals 0), *Require status checks to pass* → ajouter **Verify**, bypass list vide → Create. 📸 `captures/ruleset-protect-main.png`

## 6. Changement normal — **[VM]**
```bash
git switch -c feature/update-homepage
grep -n "<p>" src/app.ts          # repère la page d'accueil
nano src/app.ts                   # ajoute la ligne : <p>Verified by GitHub Actions. Deployed on Render.</p>   (Ctrl+O, Entrée, Ctrl+X)
npm run verify
git add . && git commit -m "feat: update homepage deployment message"
git push -u origin feature/update-homepage
```
**[PC]** PR → Verify vert → merge commit → delete branch. **[VM]** `git switch main && git pull --ff-only && git branch -d feature/update-homepage`.
Attends le déploiement Render → 📸 `captures/homepage-updated.png`

## 7. Test qui échoue — **[VM]**
```bash
git switch -c feature/version-endpoint
cat ~/devops-partie1-tp1-tp2-tp3/tp3-cicd-github-actions/snippets/failing-test.txt >> test/app.test.ts
npm test                          # échec attendu (404)
git add . && git commit -m "test: demonstrate missing version endpoint"
git push -u origin feature/version-endpoint
```
**[PC]** PR → Verify **rouge** + merge bloqué → 📸 `captures/pr-failing-verify.png` (ne ferme pas la PR). Puis **[VM]** correction :
```bash
python3 ~/devops-partie1-tp1-tp2-tp3/tp3-cicd-github-actions/snippets/add_version_route.py
npm run verify
git add . && git commit -m "feat: add version endpoint" && git push
```
**[PC]** Verify repasse au vert → merge commit → delete branch. **[VM]** `git switch main && git pull --ff-only && git branch -d feature/version-endpoint`.
Après déploiement : `https://<ton-url>.onrender.com/api/version` → `{"version":"development"}` → 📸 `captures/api-version.png`

## 8. Preview — **[PC]** puis **[VM]**
**[PC]** Render → service → Previews → Pull Request Previews : **Automatic** → Save.
**[VM]** :
```bash
git switch -c feature/preview-demo
nano src/app.ts                   # ajoute : <p>Preview deployment</p>
npm run verify
git add . && git commit -m "feat: add preview deployment message"
git push -u origin feature/preview-demo
```
**[PC]** PR (titre `Add preview deployment message`), **ne pas merger** tout de suite → attends Verify + preview → ouvre le lien « View deployment » **et** l'URL de production côte à côte → 📸 `captures/preview-vs-production.png`. Puis merge commit, delete branch ; **[VM]** `git switch main && git pull --ff-only && git branch -d feature/preview-demo`.

## 9. Rendu
Remplis `REPORT.md` (liens + difficultés), mets les 8 captures dans `captures/`, puis dans le dépôt de la partie 1 (voir GUIDE-RAPIDE.md).
