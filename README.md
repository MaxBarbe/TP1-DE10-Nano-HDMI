# TP1 — Traitement d’image sur DE10-Nano

Application VHDL pour **Terasic DE10-Nano**, FPGA **Cyclone V 5CSEBA6U23I7**.
Une image de lapin (420 × 280, ROM RGB 24 bits) est traitée puis affichée sur HDMI
au sein d’une trame 640 × 480. Projet testé sur la carte et l’écran de l’utilisateur
le 19 octobre 2026 : SW0 ON affiche le lapin ; SW0 OFF donne un écran noir.

## Installation et démarrage depuis un clone

Prérequis : **Quartus Prime Lite 17.1.0 Build 590**, support **Cyclone V** et pilote
**USB-Blaster II** installés. Le pilote est nécessaire si le matériel n’apparaît pas
dans Programmer. Aucun fichier image ni module VHDL supplémentaire n’est à télécharger.

1. Cloner ce dépôt, puis ouvrir **affichage.qpf** dans Quartus avec File → Open Project.
   Ne pas ouvrir uniquement un fichier VHDL. La révision est `affichage`,
   l’entité supérieure `HDMI_image` ; les broches sont déjà affectées.
2. Lancer **Processing → Start Compilation**. Attendre la réussite de la compilation.
   Le fichier produit est **output_files/affichage.sof**.
   Pour utiliser directement la version testée, le dépôt fournit aussi
   **bitstream/affichage.sof** : dans ce cas la compilation est facultative.
3. Alimenter la carte par **DC 5 V**, brancher son port **USB-Blaster II** au PC,
   relier la sortie HDMI à l’écran et sélectionner cette entrée sur l’écran.
4. Dans **Tools → Programmer**, choisir **Hardware Setup**, puis le matériel
   USB-Blaster II / DE-SoC détecté. Choisir le mode **JTAG**.
5. Charger **output_files/affichage.sof** après compilation, ou
   **bitstream/affichage.sof** pour la version fournie. Dans la chaîne JTAG,
   affecter le SOF au FPGA **5CSEBA6U23**, pas à SOCVHPS.
   Si nécessaire, utiliser Auto Detect puis Change File sur la ligne FPGA.
6. Cocher **Program/Configure** sur cette ligne, puis **Start**.
   Attendre **100% (Successful)**.
7. Mettre **SW0 sur ON / 1** : le lapin apparaît. SW0 est le dernier du groupe
   de quatre interrupteurs SW3, SW2, SW1, SW0, à côté de KEY4.
   **SW0 OFF / 0 maintient le circuit en réinitialisation : écran noir.**
   Ne pas confondre SW0 avec le bloc de six commutateurs SW10/MSEL.

La programmation SOF est volatile : après une coupure d’alimentation, refaire
la programmation JTAG. Ce dépôt ne remplace pas le contenu de démarrage de la carte.

## Vérifications si l’image n’apparaît pas

- Vérifier SW0 ON, l’entrée de l’écran, le câble HDMI et le fichier SOF sélectionné.
- Le logo DE10-Nano correspond à l’affichage de démarrage, pas au lapin du projet.
- Après un changement de sources, recompiler et sélectionner le nouveau fichier
  dans `output_files`, car `bitstream/affichage.sof` est la version publiée.
- Le [diagnostic LED](diagnostic/README.md) permet de vérifier programmation,
  horloge et SW0 indépendamment du HDMI. Recharger ensuite le SOF principal.
- LED0 indique la fin de configuration I2C ; elle ne constitue pas à elle seule
  une preuve de réception HDMI.

## Exercice 3 : mesure sur plateforme

L’énoncé demande une application complète de traitement d’image, une mesure
sur FPGA et le calcul de l’énergie par image. Voir [l’énoncé](TP1_M2_2026.pdf).
L’affichage du lapin a été confirmé par l’utilisateur sur son matériel.

Mesure : **PC USB → RUI DENG UM25C → câble vers DC 5 V de la DE10-Nano**.
Le testeur mesure la puissance à l’entrée du câble d’alimentation : elle comprend
la plateforme et les pertes du câble en aval du testeur, pas uniquement le filtre.
Le débit nominal vaut `25 000 000 / (800 × 525) = 59,5238 images/s`.

| Relevé | SW0 | Tension (V) | Courant (A) | Puissance U × I (W) |
|---|---|---:|---:|---:|
| IMG_0568 | ON | 4,997 | 0,6293 | 3,144612 |
| IMG_0566 | OFF | 4,996 | 0,6240 | 3,117504 |
| IMG_0572 | ON | 5,004 | 0,6301 | 3,153020 |
| IMG_0573 | OFF | 5,005 | 0,6238 | 3,122119 |

Les états ont été confirmés par l’utilisateur. Moyennes de deux instantanés par état :
**P_ON = 3,148816 W**, **P_OFF = 3,119811 W**, **écart = 29,006 mW**.

**Epf = P_ON / fps ≈ 0,052900 J/image = 52,9 mJ/image.**

L’écart ramené au débit vaut environ **0,487 mJ/image**. C’est une différence
entre fonctionnement et réinitialisation, qui inclut vidéo et HDMI ; elle ne mesure
pas isolément l’énergie du filtre. Deux instantanés par état ne permettent pas
une estimation statistique robuste de ce petit écart. Le débit provient des
compteurs et de l’horloge nominale, sans mesure instrumentale de fréquence.
Les photos utilisées et les données sont dans [resultat](resultat/README.md).

## Sources et architecture

- `HDMI_image_student.vhd` : entité supérieure HDMI_image, reset automatique de 10 ms.
- `affichage_image_filtre.vhd` : balayage et filtre 3 × 3 avec deux buffers de ligne.
- `vga_rom3.vhd` et `brom24b.mif` : ROM et 117600 pixels du lapin, inclus dans le dépôt.
- `I2C.vhd`, `i2c_hdmi_config.vhd` : configuration ADV7513, reprise sur NACK,
  rafraîchissement de configuration environ une fois par seconde.
- `affichage.qsf`, `affichage.sdc` : broches et contraintes d’horloge.
- `tests` : simulations, à ne pas ajouter aux sources du projet Quartus.

Adapté du code de MASSE Noé et PASSOLUNGHI Alec (UNICE), fourni par l’utilisateur.
Le noyau est `[1,1,1; 1,2,1; 1,1,1] / 10`. Les deux premières lignes et colonnes
restent non filtrées. La fenêtre causale décale le centre du résultat d’un pixel.

## Validation et limites

La version fournie a été compilée sous Quartus Lite 17.1 : 0 erreur,
8 avertissements. Voir [la provenance du SOF](bitstream/build-info.txt).
543 ALM, 351 blocs RAM, 1 DSP. Marges internes contraintes : setup ≥ 5,925 ns,
hold ≥ 0,113 ns. Les délais externes des interfaces ne sont pas intégralement
contraints ; ces résultats ne constituent pas une validation temporelle complète.

Les avertissements concernent le nombre de processeurs, l’émulation du comportement
des RAM, une option LogicLock indisponible dans Lite et les réglages électriques
par défaut de certaines sorties. La réussite sur le matériel de l’utilisateur
ne garantit pas des réglages identiques sur tout autre équipement.

Recompilation depuis une copie propre le 19 octobre 2026 a 22:16 (Europe/Paris) : **0 erreur, 8 avertissements**. Les trois simulations passent aussi. Le SOF fourni reste celui teste sur la carte.

Pour les simulations avec GHDL installé :

```powershell
.\tests\run.ps1
# Ou : .\tests\run.ps1 -Ghdl C:\outils\ghdl\bin\ghdl.exe
```

Les trois bancs vérifient une trame complète (ROM, filtre, synchronisations),
la configuration I2C (NACK et répétition) et le démarrage automatique.
Pour compiler en ligne de commande depuis le dossier du projet :

```powershell
& 'C:\intelFPGA_lite\17.1\quartus\bin64\quartus_sh.exe' --flow compile affichage
```

Références : [manuel DE10-Nano](https://fpgacademy.org/Downloads/DE10_Nano_User_Manual.pdf),
[guide ADV7513](https://www.analog.com/media/en/technical-documentation/user-guides/ADV7513_Programming_Guide.pdf).
