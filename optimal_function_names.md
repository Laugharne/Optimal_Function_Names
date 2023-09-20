# Noms de fonctions optimals en Solidity

## Présentation

Gestionnaire d'accès, porte d'entrée de l'extérieur vers le contrat
Il est commun de penser que ...

Ne concerne que les fonctions d'un contrat ayant un accès vers l'extérieur de celui-ci (external, view)

## Signatures des fonctions

Signature d'une fonction en Solidity

keccak
Le hash (signature numérique)
nom + paramètres
4 octets de poid fort -> 32 bits -> 2 ^ 32 = 4294967296 (plus de **4 milliards** de possibilités)

## L'ordre de traitement
- Ordre des fonctions dans le code source
- Ordonnancé par la valeur de hash

## Faire le lien

### Recherche linéaire

### Recherche par dichotomie

## Optimisations

### Optimisation au déploiement

### optimisation à l'exécution

Seuil(s) pivot

Cette opération requiert un temps en **O(log(n))** dans le cas moyen, mais **O(n)** dans le cas critique où l'arbre est complètement déséquilibré et ressemble à une liste chaînée. Ce problème est écarté si l'arbre est équilibré par rotation au fur et à mesure des insertions pouvant créer des listes trop longues. 
[Wikipédia](https://fr.wikipedia.org/wiki/Arbre_binaire_de_recherche#Recherche)

## Conclusions

L'optimisation pour l'exécution, n'est pas nécessaire pour les fonctions dites d'administration. 
Par contre c'est à prioriser pour les fonctions supposément les plus fréquement appelées (à déterminer manuellement ou après évaluation automatique lors de tests pratiques)

Merci à [**Igor Bournazel**](https://github.com/ibourn) pour la relecture de cet article.


## Liens

- Ressources
  - [en] [Keccak-256 Online](http://emn178.github.io/online-tools/keccak_256.html)
  - [en] [Function Dispatching | Huff Language](https://docs.huff.sh/tutorial/function-dispatching/#linear-dispatching)
  
- Recherche dichotomique
  - [fr] [Recherche dichotomique — Wikipédia](https://fr.wikipedia.org/wiki/Recherche_dichotomique)
  - [en] [Binary search algorithm - Wikipedia](https://en.wikipedia.org/wiki/Binary_search_algorithm)
  
- Arbre binaire de recherche
  - [fr] [Arbre binaire de recherche — Wikipédia](https://fr.wikipedia.org/wiki/Arbre_binaire_de_recherche)
  - [en] [Binary search tree - Wikipedia](https://en.wikipedia.org/wiki/Binary_search_tree)
  
- Rotation d'un arbre binaire de recherche
  - [fr] [Rotation d'un arbre binaire de recherche — Wikipédia](https://fr.wikipedia.org/wiki/Rotation_d%27un_arbre_binaire_de_recherche)
  - [en] [Tree rotation - Wikipedia](https://en.wikipedia.org/wiki/Tree_rotation)
  - [en] [Self-balancing binary search tree - Wikipedia](https://en.wikipedia.org/wiki/Self-balancing_binary_search_tree)

- Keccak
  - [fr] [SHA-3 — Wikipédia](https://fr.wikipedia.org/wiki/SHA-3)
  - [en] [SHA-3 - Wikipedia](https://en.wikipedia.org/wiki/SHA-3)

- Fonction de hachage
  - [fr] [Fonction de hachage — Wikipédia](https://fr.wikipedia.org/wiki/Fonction_de_hachage)
  - [en] [Hash function - Wikipedia](https://en.wikipedia.org/wiki/Hash_function)


