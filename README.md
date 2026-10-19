# Affichage HDMI — DE10-Nano

Projet Quartus Prime Lite 17.1 pour le FPGA Cyclone V **5CSEBA6U23I7**.
Affichage attendu : moitié gauche rouge, moitié droite verte en 640 × 480.

## Fichiers

- `HDMI_image_student.vhd` : balayage vidéo, division 50 MHz → 25 MHz et raccordement I²C.
- `i2c_hdmi_config.vhd` : séquenceur de configuration et table de registres du TP, avec corrections du reset et de la plage du compteur.
- `I2C.vhd` : contrôleur d’écriture I²C adapté à l’interface attendue par le séquenceur ; acquittement et nouvelle tentative en cas de NACK.
- `affichage.qpf`, `affichage.qsf`, `affichage.sdc` : projet, broches et contraintes d’horloge.
- `bitstream/affichage.sof` : résultat de compilation, prêt à sélectionner dans Quartus Programmer.

## Compiler

Ouvrir `affichage.qpf`, puis **Processing → Start Compilation**.
Les broches sont déjà affectées. Ne pas ajouter d’autres versions des entités.

Compilation complète effectuée dans Quartus 17.1 : **0 erreur, 20 avertissements**.
Les contraintes temporelles sont incomplètes, notamment pour l’horloge interne I²C
et les interfaces externes. Le fonctionnement sur carte n’a pas encore été vérifié.

## Programmer

1. Alimenter la carte en 5 V, brancher l’écran HDMI et le port USB-Blaster II.
2. Mettre SW0 à 0.
3. Dans Tools → Programmer : sélectionner USB-Blaster II, mode JTAG.
4. Charger `bitstream/affichage.sof`, cocher Program/Configure et cliquer Start.
5. Mettre SW0 à 1. LED0 indique la fin des écritures I²C acquittées.

Sur Docker Desktop pour Mac, le programmateur USB n’est pas transmis automatiquement.
Utiliser un PC avec Quartus Programmer ou configurer un accès USB/IP adapté.

## Consommation

Fréquence d’image : 25 000 000 / (800 × 525) = **59,5238 images/s**.
Énergie par image : **Epf = P / 59,5238**, en joules si P est en watts.
Une mesure à l’alimentation concerne toute la carte.
Cette mire est un premier essai d’affichage ; le traitement d’image de l’exercice reste à ajouter.

Broches : [manuel Terasic DE10-Nano](https://fpgacademy.org/Downloads/DE10_Nano_User_Manual.pdf), tableaux 3-6, 3-8 et 3-13.
