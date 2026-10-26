# Exercice 2 — Filtre vidéo

`filtre_video.vhd` contient l'entité **TP1** : neuf pixels d'entrée sur 8 bits,
une somme pondérée avec un poids 2 pour le pixel central, puis une division par 10.

Masque : `[1,1,1; 1,2,1; 1,1,1] / 10`.

Ajouter ce fichier dans un projet Quartus avec `TP1` comme entité supérieure.
Les mesures de temps de réponse, de puissance et d'énergie par image restent à renseigner.
Voir [l'énoncé](../docs/TP1_M2_2026.pdf).

Le fichier `brouillons/TP1.vhd` est conservé pour garder le travail d'origine.
Il contient un filtre de moyenne et une incohérence entre `entity A` et `end TP1` :
ne pas l'ajouter aux sources du projet actif. Sa correction n'entre pas dans cette réorganisation.

L'application complète avec buffers de ligne et affichage se trouve dans [exo3](../exo3/README.md).
