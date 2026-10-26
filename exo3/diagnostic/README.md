# Verification FPGA, horloge et SW0

Ce projet separe le diagnostic des entrees/sorties de celui du HDMI.
Il ne contient pas de controleur HDMI et n'envoie pas d'image a l'ecran.
Il ne modifie ni la carte SD ni la configuration persistante de la carte.

Dans Quartus Programmer, remplacer temporairement le SOF selectionne par
`bitstream/led_check.sof`, cocher Program/Configure pour le FPGA, puis Start.
Ne pas eteindre la carte entre ce chargement et l'observation.

Sur la rangee LED[7:0], LED0 est a l'extremite proche du chiffre 0 :

- LED0 suit directement SW0.
- LED1 clignote a 1 Hz, independamment de SW0.
- LED2 affiche l'inverse de LED0.
- LED3 est allumee.
- Les autres LED ne sont pas utilisees par ce diagnostic.

SW0 se trouve dans le groupe des quatre interrupteurs SW3..SW0.
Ne pas utiliser SW10/MSEL pour ce test.

Si LED0/LED2 alternent quand SW0 change et LED1 clignote, la programmation,
les broches SW0/LED et l'horloge 50 MHz sont verifiees sur la carte.
Sinon, verifier d'abord le fichier charge, la bonne carte JTAG, les positions
MSEL et une eventuelle reconfiguration par le systeme de demarrage.
Ne pas attribuer une cause precise avant ces observations.

Pour revenir a l'image, reprogrammer `../bitstream/affichage.sof`.
Pour recompiler le diagnostic, ouvrir `led_check.qpf`.

Compilation Quartus Lite 17.1 reussie : 0 erreur, 4 avertissements.
Diagnostic confirme sur la carte par l’utilisateur : LED1 clignote,
LED0 et LED2 sont complementaires et reagissent a SW0.
