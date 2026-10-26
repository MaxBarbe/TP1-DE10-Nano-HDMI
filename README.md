# TP1 — Architecture et consommation sur FPGA

Exercices du Master 2 ESTel, sur **Cyclone V 5CSEBA6U23I7**.

| Dossier | Contenu |
|---|---|
| [exo1](exo1/README.md) | Opérateurs arithmétiques : additionneur 32 bits, banc de simulation et projet Quartus de multiplication. |
| [exo2](exo2/README.md) | Filtre vidéo 3 × 3 et brouillon conservé séparément. |
| [exo3](exo3/README.md) | Application HDMI avec image filtrée, projets Quartus, tests, bitstreams et mesures sur DE10-Nano. |
| [docs](docs/TP1_M2_2026.pdf) | Énoncé du TP. |

## Ouvrir les projets

- Multiplication de l'exercice 1 : `exo1/multiplication/TP1.qpf`.
- Affichage HDMI de l'exercice 3 : **`exo3/affichage.qpf`**.
- Diagnostic LED : `exo3/diagnostic/led_check.qpf`.

Les chemins internes des projets sont relatifs à leurs dossiers : conserver ces dossiers ensemble.
Pour programmer directement la carte, télécharger [le SOF de l'exercice 3](exo3/bitstream/affichage.sof).

## Résultats de l'exercice 3

L'image filtrée du lapin a été affichée sur la carte. Les relevés donnent une puissance
moyenne de **3,149 W** en fonctionnement, soit environ **52,9 mJ/image** au débit nominal
de **59,52 images/s**. Ces valeurs concernent la plateforme et les pertes du câble en aval
du testeur. Voir [les mesures et leurs limites](exo3/README.md#exercice-3--mesure-sur-plateforme).

La réorganisation conserve les sources et les bitstreams existants. Elle n'ajoute pas
les architectures pipeline, flottantes ou parallèles manquantes de l'exercice 1.
