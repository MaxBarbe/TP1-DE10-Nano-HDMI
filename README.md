# Image filtree sur HDMI — DE10-Nano

Projet **Quartus Prime Lite 17.1**, Cyclone V **5CSEBA6U23I7**.
Le code de MASSE Noe et PASSOLUNGHI Alec est adapte a la sortie HDMI de la carte :
image RGB 420 × 280 en haut a gauche d'une trame 640 × 480, reste noir,
filtre de convolution `[1,1,1; 1,2,1; 1,1,1] / 10`.

## Fichiers du projet

- `HDMI_image_student.vhd` : entite superieure `HDMI_image`, reset automatique
  de 10 ms, raccordement video et I2C. Les ports et broches existants sont conserves.
- `affichage_image_filtre.vhd` : balayage 800 × 525 a 25 MHz et filtre causal
  avec deux buffers de ligne. Le generic `FILTER_ENABLE=false` permet de comparer
  avec l'image non filtree, sans changer le balayage.
- `vga_rom3.vhd`, `brom24b.mif` : ROM Altera et image fournis par l'utilisateur.
  La ROM est adaptee au Cyclone V avec un cycle de lecture (adresse enregistree,
  sortie non enregistree). Le MIF contient 117600 pixels RGB sur 24 bits.
- `I2C.vhd`, `i2c_hdmi_config.vhd` : configuration de l'ADV7513 a l'adresse
  d'ecriture `0x72`, reprise sur NACK et reconfiguration environ une seconde
  apres la fin de chaque sequence, pour recuperer un branchement HDMI tardif.
- `affichage.qpf`, `affichage.qsf`, `affichage.sdc` : projet, broches et horloges.
- `tests/` : simulations GHDL. Les modeles de simulation ne sont pas ajoutes au QSF.

## Corrections par rapport aux versions precedentes

Le balayage et DE ne dependent plus de `config_done` : un NACK I2C n'arrete plus
la video. SW0 peut etre deja sur 1 au demarrage : le reset interne est automatique.
LED0 indique la fin de la configuration acquittee ; elle peut s'eteindre brievement
pendant les reconfigurations. Cette LED ne prouve pas que l'ecran recoit une image.

Le code colle contenait `cptv420`, corrige en multiplication pour l'adresse ROM.
Les compteurs utilisent exactement 800 pixels et 525 lignes, HS bas pendant
96 pixels et VS bas pendant 2 lignes. Pixels, DE, HS et VS ont des delais alignes.
Les donnees sont stabilisees un demi-cycle avant le front montant envoye au HDMI.

Les buffers ne copient plus des lignes entieres a chaque pixel et ne lisent plus
de voisins futurs. La fenetre couvre `(x-2..x, y-2..y)` : le resultat correspondant
au centre `(x-1,y-1)` apparait en `(x,y)`, soit un decalage spatial d'un pixel.
Les deux premieres lignes et colonnes restent non filtrees ; les lignes suivantes
ecrasent les buffers avant leur utilisation, sans reset massif des RAM.
L'en-tete MIF a ete corrige en `CONTENT BEGIN`.

Ces corrections traitent des problemes reels dans les sources. La cause exacte
de l'absence d'image sur la carte n'a pas encore ete mesuree.

## Compiler et programmer la carte

1. Conserver tous les fichiers, notamment `brom24b.mif`, dans le dossier du projet.
2. Ouvrir `affichage.qpf` dans Quartus Lite 17.1 et lancer **Start Compilation**.
   L'entite superieure reste `HDMI_image`. Ne pas ajouter de seconde ROM portant
   le meme nom, ni les fichiers `tests/*.vhd` au projet Quartus.
3. Alimenter la DE10-Nano, allumer l'ecran, choisir son entree HDMI et brancher
   le cable HDMI ainsi que le port USB-Blaster II de la carte.
4. Mettre SW0 a 0. Dans **Tools → Programmer**, choisir USB-Blaster II et JTAG,
   charger **`output_files/affichage.sof`**, cocher **Program/Configure** et Start.
5. Mettre SW0 a 1 et attendre la configuration. L'image filtree doit apparaitre.

**Attention : `bitstream/affichage.sof` est l'ancien fichier de la mire rouge/verte.**
Il n'a pas ete regenere avec ces sources. Utiliser la sortie d'une nouvelle compilation.
La programmation JTAG est volatile : apres coupure d'alimentation, la configuration
de demarrage de la carte revient. Ne pas confondre celle-ci avec le nouveau projet.

Si l'ecran reste sur son logo/sans signal, verifier d'abord que le nouveau SOF
a effectivement ete programme et que LED0 finit par s'allumer. Une LED toujours
eteinte indique que les ecritures I2C n'aboutissent pas ; la simulation ne remplace
pas une mesure de SCL/SDA et de l'horloge HDMI sur la carte.

## Validation

Avec GHDL disponible dans le PATH, sous PowerShell :

```powershell
.\tests\run.ps1
# Ou : .\tests\run.ps1 -Ghdl C:\outils\ghdl\bin\ghdl.exe
```

Les tests comparent les pixels a `brom24b.mif` et a une convolution de reference
sur une trame complete, avec et sans filtre. Ils verifient aussi le blanking,
HS/VS/DE, les 31 ecritures I2C, une reprise apres NACK, la reconfiguration periodique
et la video avec SW0 deja a 1 et un NACK permanent.
Le modele `altsyncram` est limite a cette ROM ; il ne remplace pas les bibliotheques
Intel ni les analyses de synthese, placement/routage et timing de Quartus.

Frequence : 25 MHz / (800 × 525) = **59,5238 Hz**. Cette revision reste a compiler
avec Quartus et a tester physiquement. Les contraintes d'entrees/sorties externes
ne sont pas completes ; aucune fermeture temporelle n'est annoncee.

## Documentation

- [Manuel DE10-Nano, table 3-13 (broches HDMI/I2C)](https://fpgacademy.org/Downloads/DE10_Nano_User_Manual.pdf).
- [Guide ADV7513, HPD et remise sous tension, section 4.2.1](https://www.analog.com/media/en/technical-documentation/user-guides/ADV7513_Programming_Guide.pdf).
