#!/usr/bin/env bash
# À lancer sur la VM devops AVANT d'installer Coolify
echo "== RAM =="; free -h | sed -n 1,2p
echo "== Disque (il faut idéalement > 8 Go libres sur /) =="; df -h / | tail -1
echo "== Ports utilisés (80, 8000, 3001, 2222, 6001, 6002) =="
ss -tulpn 2>/dev/null | grep -E ':(80|8000|3001|2222|6001|6002)\s' || echo "aucun conflit"
echo "== Nginx du TP1 =="; systemctl is-active nginx || true
echo
echo "Si le port 80 est pris par Nginx : sudo systemctl stop nginx   (Coolify/Traefik a besoin du port 80)"
