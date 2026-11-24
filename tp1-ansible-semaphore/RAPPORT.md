# RAPPORT – TP1 : Portfolio Next.js avec Ansible et Semaphore UI

## Ce qui a été fait
- Partie A : playbook Ansible structuré en 4 rôles (common, nodejs, app, nginx). Application Next.js lancée avec PM2 (port 3100), Nginx en reverse proxy (port 80). Variables centralisées dans `group_vars/all.yml`. Handlers : redémarrage de l'application seulement si le code change, rechargement de Nginx via handler.
- Idempotence : la 2e exécution affiche `changed=0` (capture `captures/idempotence.png`).
- Partie B : Semaphore UI (Docker, port 3010) avec projet, clé SSH, dépôt Git, inventaire, groupe de variables, template « Deploy Portfolio » et variable de sondage `app_version`.

## Résultat
Portfolio accessible sur http://192.168.56.101. Après un push, relancer la tâche Semaphore met le site à jour ; les logs montrent le redémarrage conditionnel de l'application.

## Difficultés rencontrées
- Pas assez d'espace disque pour une VM cible supplémentaire : la VM devops sert à la fois de poste de contrôle et de serveur cible.
- Ports 3000 déjà pris (Backstage) : Semaphore sur 3010, application sur 3100.
- (ajoute ici tes autres difficultés : clé SSH dans Semaphore, chemin du playbook, etc.)
