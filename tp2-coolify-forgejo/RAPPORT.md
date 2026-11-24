# RAPPORT – TP2 : Coolify + Forgejo

## Comparatif (Partie E)
| Critère | TP1 : Ansible + Semaphore (IaC) | TP2 : Coolify (PaaS) |
|---|---|---|
| Approche | Déclarative : on décrit l'état du serveur (rôles, tâches) | Interface web : build, déploiement, proxy gérés par la plateforme |
| Mise en place | Plus longue (playbook, rôles, variables) | Rapide (install + quelques clics) |
| Contrôle / personnalisation | Total (paquets, Nginx, utilisateurs, PM2…) | Limité à ce que Coolify expose |
| Idempotence / reproductibilité | Forte (`changed=0`, code versionné dans Git) | Dépend de la configuration dans l'interface (moins versionnée) |
| Déclenchement | Manuel ou planifié (Semaphore) | Automatique à chaque `git push` (webhook) |
| Rollback | À écrire (version/tag) | Intégré (onglet Deployments) |
| Courbe d'apprentissage | YAML, Jinja2, modules Ansible | Concepts Docker/Nixpacks, réseau |
| Ressources | Léger (Nginx + PM2) | Lourd (Docker, Traefik, base Coolify) |

## Ce qui a été fait
Installation de Coolify et de Forgejo dans la VM (192.168.56.101), dépôt `portfolio` sur Forgejo, déploiement sur http://portfolio.coolify.local, webhook Forgejo → Coolify (déploiement auto à chaque push), test de rollback.

## Difficultés rencontrées
- Port 80 déjà utilisé par Nginx (TP1) : arrêt de Nginx avant Coolify.
- Port 3000 pris par Backstage : Forgejo sur 3001.
- Espace disque limité sur la VM.
- (ajoute les tiennes : webhook refusé sans `ALLOWED_HOST_LIST`, `http://` oublié dans Domains, etc.)
