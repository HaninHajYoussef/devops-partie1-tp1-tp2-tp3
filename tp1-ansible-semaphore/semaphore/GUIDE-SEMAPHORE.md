# TP1 – Partie B : Semaphore UI (≈ 15 min)

## 1. Lancer Semaphore
**[VM]** terminal SSH, dossier du projet :
```bash
cd ~/devops-partie1-tp1-tp2-tp3/tp1-ansible-semaphore/semaphore
echo "SEMAPHORE_KEY=$(head -c32 /dev/urandom | base64)" > .env
docker compose up -d
docker ps | grep semaphore      # doit être "Up"
```
**[PC]** navigateur : http://192.168.56.101:3010  → login `admin` / `ChangeMe-2026`

## 2. Préparer ce qu'il faut copier
**[VM]** :
```bash
cat ~/.ssh/id_ed25519                # clé PRIVÉE (si erreur : essaie ~/.ssh/id_rsa) → à copier en entier, de BEGIN à END
cat ~/devops-partie1-tp1-tp2-tp3/tp1-ansible-semaphore/portfolio-deploy/inventory/hosts.ini   # contenu de l'inventaire
```

## 3. Configurer Semaphore (**[PC]** navigateur)
| # | Menu | À remplir |
|---|------|-----------|
| 1 | New Project | Nom : `portfolio-deploy` |
| 2 | Key Store → New Key | Nom `ssh-vm`, type **SSH Key**, Username `hanin`, Private key = clé copiée à l'étape 2 |
| 2b | Key Store → New Key | Nom `none`, type **None** (dépôt public → pas besoin de token) |
| 3 | Repositories → New | Nom `devops-tps`, URL `https://github.com/HaninHajYoussef/devops-partie1-tp1-tp2-tp3.git`, Branch `main`, Access key `none` |
| 4 | Inventory → New | Nom `vm-devops`, type **Static**, User credentials `ssh-vm`, contenu = ton `hosts.ini` (si c'est `localhost`/`127.0.0.1`, remplace par `192.168.56.101` + `ansible_user=hanin`, car le conteneur ne se voit pas lui-même comme la VM) |
| 5 | Variable Groups (ou « Environment ») → New | Nom `portfolio-vars` ; Extra variables : `{"server_name":"portfolio.local","app_port":3100}` ; Environment variables : `{"ANSIBLE_HOST_KEY_CHECKING":"False"}` |
| 6 | Task Templates → New Template → **Ansible Playbook** | Nom `Deploy Portfolio` ; Playbook filename : `tp1-ansible-semaphore/portfolio-deploy/site.yml` ; Inventory `vm-devops` ; Repository `devops-tps` ; Variable group `portfolio-vars` |
| 7 | Dans le template → **Survey Variable** → Add | Name `app_version`, Title `Branche ou tag`, Type String, Default `main` |

📸 **captures/semaphore-template.png** : l'écran du template configuré.

## 4. Exécuter
1. Task Templates → `Deploy Portfolio` → **Run** → laisse `app_version = main` → suis les logs.
2. 📸 **captures/semaphore-run.png** (logs en succès, PLAY RECAP).
3. **[PC]** http://192.168.56.101 → 📸 **captures/portfolio.png**.
4. **[VM]** modifier le portfolio puis pousser (dépôt de l'appli, comme au TP1) :
```bash
cd ~/portfolio-nextjs          # adapte si ton dossier a un autre nom : ls ~
# modifie un titre dans l'appli (nano app/page.tsx ou src/... selon ton projet)
git add . && git commit -m "Mise à jour du titre" && git push
```
5. Relance `Deploy Portfolio` dans Semaphore → dans les logs, la tâche git est `changed` et le handler « restart app » s'exécute. Recharge le site.
6. 📸 **captures/idempotence.png** : si tu ne l'as pas déjà, relance **[VM]** `cd ~/devops-partie1-tp1-tp2-tp3/tp1-ansible-semaphore/portfolio-deploy && ansible-playbook -i inventory/hosts.ini site.yml` (2e run sans changement → `changed=0`).

## Dépannage express
- `Permission denied (publickey)` : mauvaise clé collée (il faut la privée, complète, avec la ligne finale vide) ; vérifie que la clé publique est dans `~/.ssh/authorized_keys` de la VM.
- `sudo: a password is required` : ajoute `become: true` dans site.yml ou vérifie le sudo sans mot de passe.
- Le playbook ne trouve pas les rôles : le chemin du playbook doit partir de la racine du dépôt (voir étape 6).
