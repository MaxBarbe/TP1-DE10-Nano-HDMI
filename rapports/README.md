# Rapports Architecture multicores

## Livrables du 26 octobre 2026

- [Rapport TP1 (PDF)](TP1_Archi_Rapport_2026-10-26.pdf) : 11 pages, mise à jour le 27 octobre, avec architecture, photographies et calculs de consommation. Les rapports Quartus retrouvés de l’exercice 2 donnent 428,86 mW (75 ALM, 8 registres). Les variantes de l’exercice 1 et la validation temporelle complète restent à compléter.
- [Projet LaTeX TP1](rapport_tp1/main.tex) et [archive Overleaf](TP1_Archi_Rapport_2026-10-26_Overleaf.zip).
- [Description du governor conservative (PDF)](Description_governor_conservative_Maxime_Barbe.pdf), [source LaTeX](governor_conservative/main.tex) et [archive Overleaf](Description_governor_conservative_Maxime_Barbe_Overleaf.zip).

Les deux documents ont été compilés avec Tectonic 0.17.0 et contrôlés visuellement. Importer l’archive ZIP comme nouveau projet dans Overleaf. `main.tex` est le document principal ; les paquets sont compatibles avec pdfLaTeX.

## Article scientifique retenu pour le TP2

Ti Zhou, Haoyu Wang, Xinyi Li et Man Lin, **Profiling and Understanding CPU Power Management in Linux** (2023), 8 pages.

- [PDF fourni sur le site de l’auteur](https://coladog.github.io/assets/papers/UIC2023.pdf)
- [DOI](https://doi.org/10.1109/SWC57546.2023.10449312)

L’article étudie le DVFS sur matériel réel, notamment un Raspberry Pi 4B, et compare Ondemand et Conservative. Il convient à la synthèse individuelle du TP2. Le PDF de l’éditeur/auteur reste accessible à son URL et n’est pas republié dans ce dépôt.

## État des dépôts

État vérifié le 27 octobre 2026 :

- [Rapport TP1 importé sur Overleaf](https://www.overleaf.com/project/6ae0dd21f86e28565cf50b91), compilation sans erreur.
- Article scientifique enregistré sur Moodle, statut **Brouillon (non remis)**.
- Description du governor enregistrée sur Moodle, statut **Brouillon (non remis)**.
- Les deux dépôts restent volontairement en brouillon à la demande de Maxime.
- Le rapport TP1 n’a pas été remis sur Moodle. Il reste à compléter les variantes de l’exercice 1 et les contraintes temporelles/activités représentatives du filtre avant la version finale.

## Résultats retrouvés le 27 octobre

Les sources et rapports originaux du filtre enregistré sont conservés dans [exo2/archive_quartus_2026-09-29](../exo2/archive_quartus_2026-09-29). Power Analyzer : 428,86 mW, confiance Low, sans activité de simulation. Les 72 entrées et 8 sorties ne sont pas contraintes : le délai critique et le débit à 100 MHz ne sont pas validés. Le rapport distingue cette version de la version combinatoire du dépôt.

## Variantes retrouvées dans le cache

Les IP générées existent : addition signée 32 bits avec pipeline 1, 2 et 4 ; addition flottante (exposant 8, mantisse 23, pipeline 14) ; multiplication signée 32×32 vers 64 bits avec pipeline 1, 2 et 4. Voir [les originaux archivés](../exo1/archive_ip_generees/). Les rapports chiffrés propres à chaque variante restent non retrouvés.

Ancien projet Overleaf fourni par Maxime : [M2 TP1 Archi](https://www.overleaf.com/project/6ab3907904aa18e619729093). Son contenu reste à vérifier : Safari affiche une page vide pendant la consultation. Le PDF local inclut la correction sur les variantes ; cette dernière correction n’a pas encore été transférée sur Overleaf.

## Figures Quartus

Deux captures originales du filtre (code VHDL et TimeQuest), présentes dans Documents/Images/Captures_ecran, sont intégrées au PDF. Les schémas des additionneurs et du multiplieur cités dans le main.tex original restent à localiser.
