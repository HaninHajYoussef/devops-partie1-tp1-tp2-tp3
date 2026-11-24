# REPORT – TP3 : CI/CD avec GitHub Actions et Render

**Dépôt GitHub :** https://github.com/HaninHajYoussef/cicd-lab
**Production Render :** https://<TON-SERVICE>.onrender.com   (à remplacer)

## Le pipeline en mes mots
Chaque changement part d'une branche `feature/...` puis d'une pull request vers `main`. GitHub Actions exécute le job **Verify** (installation avec `npm ci`, puis `npm run verify` = typecheck + tests + build). Un ruleset « Protect main » interdit de fusionner tant que Verify n'est pas vert. Render ne déploie `main` qu'après la réussite des vérifications (« After CI Checks Pass »). Les pull requests ont en plus une preview temporaire avec sa propre URL, supprimée à la fusion.

## Comparaison avec le TP2 (webhook Coolify vs GitHub Actions + Render)
| | TP2 : Forgejo + Coolify | TP3 : GitHub Actions + Render |
|---|---|---|
| Hébergement | Auto-hébergé (VM locale) | Services cloud (SaaS) |
| Déclencheur | Webhook sur chaque push | Push/PR + vérification CI |
| Tests avant déploiement | Non (build uniquement) | Oui (Verify obligatoire) |
| Protection de la branche | Aucune | Ruleset : PR + check requis |
| Preview | Non (bonus) | Oui, par pull request |
| Contrôle / coût | Total, mais à maintenir | Simple, limites du plan gratuit |

## Difficultés rencontrées
- (Node 24 absent sur la VM : installé avec nvm)
- (ajoute les tiennes : nom du check Verify dans le ruleset, délai du premier déploiement Render, etc.)
