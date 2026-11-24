# TP2 – Coolify + Forgejo (VM devops, IP 192.168.56.101)

⚠️ Coolify a besoin de ~2 Go de RAM libre, ~3 Go d'images Docker + de la place pour le build, et des ports 80 / 8000. Lance d'abord la pré-vérification.

## 0. Pré-vérification  — **[VM]**
```bash
cd ~/devops-partie1-tp1-tp2-tp3/tp2-coolify-forgejo
bash preflight.sh
sudo systemctl stop nginx        # libère le port 80 (Nginx du TP1 ; tu pourras le relancer après : sudo systemctl start nginx)
```
Si l'espace libre est < 6 Go : libère de la place (`docker image prune -a` supprime seulement les images inutilisées) ou agrandis le disque de la VM dans VirtualBox. Sinon ça échouera en plein build.

## A. Installer Coolify — **[VM]** (≈ 5-10 min, laisse tourner dans un 2e terminal SSH)
```bash
curl -fsSL https://cdn.coollabs.io/coolify/install.sh | sudo bash
docker --version && docker ps
```
**[PC]** http://192.168.56.101:8000 → crée **tout de suite** le compte admin → assistant → serveur `localhost`.
Vérifie : Servers → localhost = **Reachable**, Proxy = **Running**.
📸 `captures/coolify-dashboard.png`

## B. Forgejo — **[VM]**
```bash
cd ~/devops-partie1-tp1-tp2-tp3/tp2-coolify-forgejo/forgejo
docker compose up -d
docker ps | grep forgejo
```
**[PC]** http://192.168.56.101:3001 → assistant : base **SQLite3**, domaine du serveur `192.168.56.101`, URL de base `http://192.168.56.101:3001/`, crée le compte admin (nom, mot de passe, e-mail fictif).
Dans Forgejo : **Nouveau dépôt** → nom `portfolio`, **public**.

Pousser le portfolio — **[VM]** (dossier du portfolio du TP1 ; ici je clone depuis GitHub) :
```bash
cd ~
git clone https://github.com/HaninHajYoussef/portfolio-nextjs.git portfolio-forgejo
cd portfolio-forgejo
git branch --show-current          # doit afficher main (sinon : git branch -M main)
git remote add forgejo http://192.168.56.101:3001/<TON_UTILISATEUR_FORGEJO>/portfolio.git
git push -u forgejo main           # identifiants Forgejo
```
📸 `captures/forgejo-repo.png` (code visible dans Forgejo)

## C. Déployer — 
**[PC Windows]** ajoute le nom d'hôte : ouvre le Bloc-notes **en administrateur** → Fichier > Ouvrir → `C:\Windows\System32\drivers\etc\hosts` (filtre « Tous les fichiers ») → ajoute en bas :
```
192.168.56.101  portfolio.coolify.local
```
Enregistre. Test **[PC PowerShell]** : `ping portfolio.coolify.local`

**[PC]** Coolify (http://192.168.56.101:8000) :
1. Projects → Add → `portfolio` (env `production`)
2. + New Resource → **Public Repository**
3. URL : `http://192.168.56.101:3001/<TON_UTILISATEUR_FORGEJO>/portfolio.git` (l'IP, pas un nom)
4. Branch `main`, Build Pack **Nixpacks** (ou Dockerfile si ton projet en a un)
5. Ports Exposes : `3000`
6. Domains : `http://portfolio.coolify.local` (le `http://` est obligatoire)
7. **Deploy** → suis les logs.

Vérifie : **[PC]** http://portfolio.coolify.local · **[VM]** `curl -I http://portfolio.coolify.local` (200) · `docker ps`
📸 `captures/coolify-config.png`, `captures/coolify-deploy.png`, `captures/portfolio.png`
(Plan B si pas de fichier hosts : onglet Ports Mappings `3000:3000` puis http://192.168.56.101:3000 — attention, 3000 est pris par Backstage : mets plutôt `3200:3000`.)

## D. Webhook Forgejo → Coolify
**[PC]** Coolify → ton application → **Webhooks** → Manual Git Webhooks → section **Gitea** : secret ≥ 16 caractères (ex. `MonSecretTP2-2026!`), Save, **copie l'URL**. Puis Advanced → Deployment → Auto deploy : **Deploy on push (webhooks)**.
**[PC]** Forgejo → dépôt portfolio → Paramètres → Webhooks → Ajouter → **Forgejo** (ou Gitea) : URL copiée, type `application/json`, même secret, événement **Push**, branche `main` → Enregistrer → **Tester la livraison** (doit donner 2xx).
📸 `captures/forgejo-webhook.png`

Vérifier — **[VM]** :
```bash
cd ~/portfolio-forgejo
# modifie un titre : nano (ex. app/page.tsx), puis :
git add . && git commit -m "Mise à jour du titre" && git push forgejo main
```
**[PC]** Coolify → Deployments : un nouveau déploiement démarre seul. 📸 `captures/coolify-autodeploy.png`

## D.4 Rollback
**[VM]** casse volontairement le build :
```bash
cd ~/portfolio-forgejo
echo "const x: number = 'erreur';" >> app/page.tsx      # adapte le fichier (ls app ou ls src)
git add . && git commit -m "Erreur volontaire" && git push forgejo main
```
Coolify : le déploiement échoue → onglet Deployments → **Rollback** sur la version précédente. 📸 `captures/coolify-rollback.png`
Puis corrige : `git revert HEAD --no-edit && git push forgejo main`.
Supervision — **[VM]** `docker stats --no-stream` + logs dans le dashboard.

## À la fin — **[VM]**
`sudo systemctl start nginx` si tu veux retrouver le portfolio du TP1 sur le port 80 (mais Coolify/Traefik utilise 80 : arrête-le d'abord avec `docker stop coolify-proxy` si besoin).
