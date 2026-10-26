# Bitstream image filtree

`affichage.sof` contient l'image `brom24b.mif` et le filtre 3x3.
Il a ete genere avec Quartus Prime Lite 17.1.0 Build 590 le 19 octobre 2026.
La compilation complete se termine avec 0 erreur et 8 avertissements.

Programmer ce fichier avec Quartus Programmer, USB-Blaster II, mode JTAG.
Mettre SW0 a 0 pendant la programmation, puis a 1 pour demarrer.
Apres une recompilation locale, utiliser `output_files/affichage.sof`.
Voir `build-info.txt` pour la provenance et l'empreinte.
Affichage du lapin confirme par l'utilisateur sur DE10-Nano le 19 octobre 2026.
SW0 ON = marche ; SW0 OFF = reset et ecran noir.
