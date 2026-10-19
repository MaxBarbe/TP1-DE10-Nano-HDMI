# TP1 â€” Traitement dâ€™image sur DE10-Nano

Application VHDL pour **Terasic DE10-Nano**, FPGA **Cyclone V 5CSEBA6U23I7**.
Une image de lapin (420 Ã— 280, ROM RGB 24 bits) est traitÃ©e puis affichÃ©e sur HDMI
au sein dâ€™une trame 640 Ã— 480. Projet testÃ© sur la carte et lâ€™Ã©cran de lâ€™utilisateur
le 19 octobre 2026 : SW0 ON affiche le lapin ; SW0 OFF donne un Ã©cran noir.

## Installation et dÃ©marrage depuis un clone

PrÃ©requis : **Quartus Prime Lite 17.1.0 Build 590**, support **Cyclone V** et pilote
**USB-Blaster II** installÃ©s. Le pilote est nÃ©cessaire si le matÃ©riel nâ€™apparaÃ®t pas
dans Programmer. Aucun fichier image ni module VHDL supplÃ©mentaire nâ€™est Ã  tÃ©lÃ©charger.

1. Cloner ce dÃ©pÃ´t, puis ouvrir **affichage.qpf** dans Quartus avec File â†’ Open Project.
   Ne pas ouvrir uniquement un fichier VHDL. La rÃ©vision est `affichage`,
   lâ€™entitÃ© supÃ©rieure `HDMI_image` ; les broches sont dÃ©jÃ  affectÃ©es.
2. Lancer **Processing â†’ Start Compilation**. Attendre la rÃ©ussite de la compilation.
   Le fichier produit est **output_files/affichage.sof**.
   Pour utiliser directement la version testÃ©e, le dÃ©pÃ´t fournit aussi
   **bitstream/affichage.sof** : dans ce cas la compilation est facultative.
3. Alimenter la carte par **DC 5 V**, brancher son port **USB-Blaster II** au PC,
   relier la sortie HDMI Ã  lâ€™Ã©cran et sÃ©lectionner cette entrÃ©e sur lâ€™Ã©cran.
4. Dans **Tools â†’ Programmer**, choisir **Hardware Setup**, puis le matÃ©riel
   USB-Blaster II / DE-SoC dÃ©tectÃ©. Choisir le mode **JTAG**.
5. Charger **output_files/affichage.sof** aprÃ¨s compilation, ou
   **bitstream/affichage.sof** pour la version fournie. Dans la chaÃ®ne JTAG,
   affecter le SOF au FPGA **5CSEBA6U23**, pas Ã  SOCVHPS.
   Si nÃ©cessaire, utiliser Auto Detect puis Change File sur la ligne FPGA.
6. Cocher **Program/Configure** sur cette ligne, puis **Start**.
   Attendre **100% (Successful)**.
7. Mettre **SW0 sur ON / 1** : le lapin apparaÃ®t. SW0 est le dernier du groupe
   de quatre interrupteurs SW3, SW2, SW1, SW0, Ã  cÃ´tÃ© de KEY4.
   **SW0 OFF / 0 maintient le circuit en rÃ©initialisation : Ã©cran noir.**
   Ne pas confondre SW0 avec le bloc de six commutateurs SW10/MSEL.

La programmation SOF est volatile : aprÃ¨s une coupure dâ€™alimentation, refaire
la programmation JTAG. Ce dÃ©pÃ´t ne remplace pas le contenu de dÃ©marrage de la carte.

## VÃ©rifications si lâ€™image nâ€™apparaÃ®t pas

- VÃ©rifier SW0 ON, lâ€™entrÃ©e de lâ€™Ã©cran, le cÃ¢ble HDMI et le fichier SOF sÃ©lectionnÃ©.
- Le logo DE10-Nano correspond Ã  lâ€™affichage de dÃ©marrage, pas au lapin du projet.
- AprÃ¨s un changement de sources, recompiler et sÃ©lectionner le nouveau fichier
  dans `output_files`, car `bitstream/affichage.sof` est la version publiÃ©e.
- Le [diagnostic LED](diagnostic/README.md) permet de vÃ©rifier programmation,
  horloge et SW0 indÃ©pendamment du HDMI. Recharger ensuite le SOF principal.
- LED0 indique la fin de configuration I2C ; elle ne constitue pas Ã  elle seule
  une preuve de rÃ©ception HDMI.

## Exercice 3 : mesure sur plateforme

Lâ€™Ã©noncÃ© demande une application complÃ¨te de traitement dâ€™image, une mesure
sur FPGA et le calcul de lâ€™Ã©nergie par image. Voir [lâ€™Ã©noncÃ©](TP1_M2_2026.pdf).
Lâ€™affichage du lapin a Ã©tÃ© confirmÃ© par lâ€™utilisateur sur son matÃ©riel.

Mesure : **PC USB â†’ RUI DENG UM25C â†’ cÃ¢ble vers DC 5 V de la DE10-Nano**.
Le testeur mesure la puissance Ã  lâ€™entrÃ©e du cÃ¢ble dâ€™alimentation : elle comprend
la plateforme et les pertes du cÃ¢ble en aval du testeur, pas uniquement le filtre.
Le dÃ©bit nominal vaut `25 000 000 / (800 Ã— 525) = 59,5238 images/s`.

| RelevÃ© | SW0 | Tension (V) | Courant (A) | Puissance U Ã— I (W) |
|---|---|---:|---:|---:|
| IMG_0568 | ON | 4,997 | 0,6293 | 3,144612 |
| IMG_0566 | OFF | 4,996 | 0,6240 | 3,117504 |
| IMG_0572 | ON | 5,004 | 0,6301 | 3,153020 |
| IMG_0573 | OFF | 5,005 | 0,6238 | 3,122119 |

Les Ã©tats ont Ã©tÃ© confirmÃ©s par lâ€™utilisateur. Moyennes de deux instantanÃ©s par Ã©tat :
**P_ON = 3,148816 W**, **P_OFF = 3,119811 W**, **Ã©cart = 29,006 mW**.

**Epf = P_ON / fps â‰ˆ 0,052900 J/image = 52,9 mJ/image.**

Lâ€™Ã©cart ramenÃ© au dÃ©bit vaut environ **0,487 mJ/image**. Câ€™est une diffÃ©rence
entre fonctionnement et rÃ©initialisation, qui inclut vidÃ©o et HDMI ; elle ne mesure
pas isolÃ©ment lâ€™Ã©nergie du filtre. Deux instantanÃ©s par Ã©tat ne permettent pas
une estimation statistique robuste de ce petit Ã©cart. Le dÃ©bit provient des
compteurs et de lâ€™horloge nominale, sans mesure instrumentale de frÃ©quence.
Les photos utilisÃ©es et les donnÃ©es sont dans [resultat](resultat/README.md).

## Sources et architecture

- `HDMI_image_student.vhd` : entitÃ© supÃ©rieure HDMI_image, reset automatique de 10 ms.
- `affichage_image_filtre.vhd` : balayage et filtre 3 Ã— 3 avec deux buffers de ligne.
- `vga_rom3.vhd` et `brom24b.mif` : ROM et 117600 pixels du lapin, inclus dans le dÃ©pÃ´t.
- `I2C.vhd`, `i2c_hdmi_config.vhd` : configuration ADV7513, reprise sur NACK,
  rafraÃ®chissement de configuration environ une fois par seconde.
- `affichage.qsf`, `affichage.sdc` : broches et contraintes dâ€™horloge.
- `tests` : simulations, Ã  ne pas ajouter aux sources du projet Quartus.

AdaptÃ© du code de MASSE NoÃ© et PASSOLUNGHI Alec (UNICE), fourni par lâ€™utilisateur.
Le noyau est `[1,1,1; 1,2,1; 1,1,1] / 10`. Les deux premiÃ¨res lignes et colonnes
restent non filtrÃ©es. La fenÃªtre causale dÃ©cale le centre du rÃ©sultat dâ€™un pixel.

## Validation et limites

La version fournie a Ã©tÃ© compilÃ©e sous Quartus Lite 17.1 : 0 erreur,
8 avertissements. Voir [la provenance du SOF](bitstream/build-info.txt).
543 ALM, 351 blocs RAM, 1 DSP. Marges internes contraintes : setup â‰¥ 5,925 ns,
hold â‰¥ 0,113 ns. Les dÃ©lais externes des interfaces ne sont pas intÃ©gralement
contraints ; ces rÃ©sultats ne constituent pas une validation temporelle complÃ¨te.

Les avertissements concernent le nombre de processeurs, lâ€™Ã©mulation du comportement
des RAM, une option LogicLock indisponible dans Lite et les rÃ©glages Ã©lectriques
par dÃ©faut de certaines sorties. La rÃ©ussite sur le matÃ©riel de lâ€™utilisateur
ne garantit pas des rÃ©glages identiques sur tout autre Ã©quipement.

Pour les simulations avec GHDL installÃ© :

```powershell
.\tests\run.ps1
# Ou : .\tests\run.ps1 -Ghdl C:\outils\ghdl\bin\ghdl.exe
```

Les trois bancs vÃ©rifient une trame complÃ¨te (ROM, filtre, synchronisations),
la configuration I2C (NACK et rÃ©pÃ©tition) et le dÃ©marrage automatique.
Pour compiler en ligne de commande depuis le dossier du projet :

```powershell
& 'C:\intelFPGA_lite\17.1\quartus\bin64\quartus_sh.exe' --flow compile affichage
```

RÃ©fÃ©rences : [manuel DE10-Nano](https://fpgacademy.org/Downloads/DE10_Nano_User_Manual.pdf),
[guide ADV7513](https://www.analog.com/media/en/technical-documentation/user-guides/ADV7513_Programming_Guide.pdf).
