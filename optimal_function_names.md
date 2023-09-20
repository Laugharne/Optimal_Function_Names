Gestionnaire d'accès, porte d'entrée de l'extérieur vers le contrat
Il est commun de penser que ...

Ne concerne que les fonctions d'un contrat ayant un accès vers l'extérieur de celui-ci (external, view)

Signature d'une fonction en Solidity
Le hash (signature numérique)
nom + paramètres
4 octets de poid fort -> 32 bits -> 2 ^ 32 =  +4 milliards de possibilités

L'ordre de traitement
Ordre dans le code source
Ordonnancé par la valeur de hash

Recherche linéaire

Recherche par dichotomie

Optimisations

Optimisation au déploiement
optimisation à l'exécution

Conclusions:
Pas forcément pour les fonctions dites d'administration


Merci à [**Igor Bournazel**](https://github.com/ibourn) pour la relecture de cet article.

Liens:
- [Keccak-256 Online](http://emn178.github.io/online-tools/keccak_256.html)
- [Function Dispatching | Huff Language](https://docs.huff.sh/tutorial/function-dispatching/#linear-dispatching)
