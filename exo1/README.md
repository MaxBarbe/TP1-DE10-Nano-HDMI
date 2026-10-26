# Exercice 1 — Opérateurs, parallélisme et consommation

Sources retrouvées dans le projet local `TP1` :

- `addition/add32.v` : additionneur 32 bits avec une sortie enregistrée.
- `addition/testbench.v` : simulation à 100 MHz, génération de `waveform.vcd`.
- `multiplication/TP1.qpf` : projet Quartus utilisant le schéma `TP1.bdf` et le bloc `LPM_MULT`.
- `multiplication/TP1.sdc`, `Waveform.vwf` : contrainte d'horloge et stimuli du projet existant.

Ouvrir `multiplication/TP1.qpf` dans Quartus. Pour l'addition, les sources et le banc de
simulation sont fournis sans nouveau projet Quartus.

Ces fichiers ont été classés sans changer leur logique. Aucune nouvelle compilation
n'a été effectuée lors de la réorganisation. Les comparaisons demandées dans
[l'énoncé](../docs/TP1_M2_2026.pdf) (pipeline, flottants, parallélisme, DSP/LE)
et les tableaux de consommation restent à compléter selon les variantes disponibles.
