# Optimisation des noms de fonctions avec les EVMs


## TL;DR

- Le "function dispatcher" est une interface d'accès au smart contract, c'est la porte d'entrée de l'extérieur vers le contrat.
- Ne concerne que les fonctions ayant un accès vers l'extérieur du contrat.
- Pourrait s'appeler "external access dispatcher, car concerne aussi les données publiques.


## Présentation

Le "function dispatcher" (ou gestionnaire de fonctions) dans les contrats intelligents (*smart contracts*) écrits pour les **EVMs** est un élément du contrat qui permet de déterminer quelle fonction doit être exécutée lorsque quelqu'un interagit avec le contrat au travers d'une API.

Si on imagine un contrat intelligent comme une boîte noir avec des fonctions à l'intérieur.  Ces fonctions peuvent être comme des commandes que vous pouvez donner à la boîte pour lui faire faire différentes choses.

Le "function dispatcher" écoute les commandes et dirige chaque commande vers la fonction appropriée à l'intérieur de la boîte.

Lorsque vous interagissez avec un contrat intelligent en utilisant une application ou une transaction, vous spécifiez quelle fonction vous souhaitez exécuter. Le "function dispatcher" fait donc le lien entre la commande et la fonction spécifique qui sera appelée et exécutée.

En résumé, le "function dispatcher" est comme un chef d'orchestre lors des appels aux fonctions d'un contrat intelligent. Il garantit que les bonnes fonctions sont appelées lorsque vous effectuez les bonnes actions sur le contrat.


## Fonctionnement

TODO

Schéma switch/case
https://excalidraw.com/#json=InELTut-1p4WQ5S_9yQbJ,19njz8QgTR6FqUUurtHA7Q


## Empreintes et Signatures des fonctions

La **signature** d'une fonction tel que employée avec les **EVMs** (Solidity) consiste en son nom et de ses paramètres (sans noms de paramètre, sans type de retour et sans espace)

L'**empreinte** (selector dans certaines publications anglo-saxonnes) est l'identité même de la fonction qui la rend "unique" et identifiable, dans le cas de Solidity, il s'agit des 4 octets de poid fort (32 bits) du résultat du hachage de la signature de la fonction avec l'algorithme [**Keccak-256**](https://www.geeksforgeeks.org/difference-between-sha-256-and-keccak-256/). Cela selmon les [**spécifications de l'ABI en Solidity**](https://docs.soliditylang.org/en/develop/abi-spec.html#function-selector).

Je précise bien que je perle de l'empreinte pour **Solidity**, ce n'est pas forcément le cas avec d'autres langages comme **Rust** qui fonctionne sur un tout autre paradigme.

Si les types des paramètres sont pris en compte, c'est pour différencier les fonctions qui auraient le même nom, mais des paramètres différents, comme par exemple la méthode `safeTransferFrom` des tokens  [**ERC721**](https://eips.ethereum.org/EIPS/eip-721)

Cependant, le fait que l'on ne garde que **quatre octets** pour l'empreinte, implique de potentiels **risques de collisions de hash** entre deux fonctions, risque rare mais existant malgré plus de 4 milliards de possibilités, comme en atteste le site [**Ethereum Signature Database**](https://www.4byte.directory/signatures/?bytes4_signature=0xcae9ca51) avec `onHintFinanceFlashloan(address,address,uint256,bool,bytes)` et `approveAndCall(address,uint256,bytes)` !


## Solidity

En mettant en application ce qui a été dit plus haut, on obtient, pour la fonction suivante :

```solidity
function square(uint32 num) public pure returns (uint32) {
    return num * num;
}
```

Les signatures, hash et empreinte suivantes :

|           |                                                                    |
| --------- | ------------------------------------------------------------------ |
| Signature | `square(uint32)`                                                   |
| Hash      | `d27b38416d4826614087db58e4ea90ac7199f7f89cb752950d00e21eb615e049` |
| Empreinte | `d27b3841`                                                         |


En Solidity, le "function dispatcher" est généré par le compilateur, inutile donc de se charger de cette tâche complexe. 

Il ne concerne que les fonctions d'un contrat ayant un accès vers l'extérieur de celui-ci, en l'occurence les fonctions ayant pour attribut d'accès external et public


### Pour rappel

1. **External** : Les fonctions externes sont conçues pour être appelées depuis l'**extérieur du contrat**, généralement par d'autres contrats ou des comptes externes. C'est le niveau de visibilité que vous utilisez lorsque vous souhaitez exposer une interface publique à votre contrat.

2. **Public** : Les fonctions publiques sont similaires aux fonctions externes, mais elles offrent également une méthode de lecture de données qui ne consomme pas de gaz. Les fonctions publiques sont accessibles depuis l'**extérieur du contrat**.

3. **Internal** : Les fonctions internes peuvent être appelées à l'**intérieur du contrat**, ainsi que depuis d'autres **contrats héritant** du contrat actuel. Elles ne sont pas accessibles depuis l'extérieur du contrat via une transaction directe.

Exemple :

```solidity
pragma solidity 0.8.20;

contract MyContract {
    uint256 public value;
    uint256 internalValue;

    function setValue(uint256 _newValue) external {
        value = _newValue;
    }

    function getValue() public view returns (uint256) {
        return value;
    }

    function setInternalValue(uint256 _newValue) internal {
        internalValue = _newValue;
    }

    function getInternalValue() public view returns (uint256) {
        return internalValue;
    }
}
```

Dans cet exemple, la fonction `setValue` est marquée comme "*external*" car elle modifie l'état du contrat et doit être appelée depuis l'extérieur.

La fonction `getValue` est marquée comme étant "*public*", elle permet ainsi de lire la valeur sans en modifier l'état.

La fonction `setInternalValue` peut être appelée à partir de l'intérieur du contrat lui-même ou par **d'autres contrats** qui héritent de `MyContract`.

La fonction `getInternalValue` est publique et permet de lire la valeur de `internalValue`.


### A la compilation

Si nous reprenons le précédent code utilisé en exemple, nous obtenons les signatures et empreintes suivantes :

| Fonctions                                              | Signatures                  | Keccak            | Empreintes     |
| ------------------------------------------------------ | --------------------------- | ----------------- | -------------- |
| **`setValue(uint256 _newValue) external`**             | `setValue(uint256)`         | `55241077...ecbd` | **`55241077`** |
| **`getValue() public view returns (uint256)`**         | `getValue()`                | `20965255...ad96` | **`20965255`** |
| **`setInternalValue(uint256 _newValue) internal`**     | `setInternalValue(uint256)` | `6115694f...7ce1` | **`6115694f`** |
| **`getInternalValue() public view returns (uint256)`** | `getInternalValue()`        | `e778ddc1...c094` | **`e778ddc1`** |

(*Les hash issus du Keccak ont été tronqués volontairement*)

Si on examine l'ABI généré lors de la compilation, la fonction `setInternalValue()` n'apparait pas, ce qui est normal sa visibilité étant `internal` (voir plus haut)

On notera dans les données de l'ABI, la réference à la donnée du storage `value` qui est `public` (on y reviendra plus loin)


```yul
tag 1
  JUMPDEST 
  POP 
  PUSH 4
  CALLDATASIZE 
  LT 
  PUSH [tag] 2
  JUMPI 
  PUSH 0
  CALLDATALOAD 
  PUSH E0
  SHR 
  DUP1 
  PUSH 20965255
  EQ 
  PUSH [tag] getValue_0
  JUMPI 
  DUP1 
  PUSH 3FA4F245  
  EQ 
  PUSH [tag] 4
  JUMPI 
  DUP1 
  PUSH 55241077
  EQ 
  PUSH [tag] setValue_uint256_0
  JUMPI 
  DUP1 
  PUSH E778DDC1
  EQ 
  PUSH [tag] getInternalValue_0
  JUMPI 
tag 2
  JUMPDEST 
  PUSH 0
  DUP1 
  REVERT
```
![](functions_dispatcher_diagram.png)

## Yul


## Huff

TO DO


## Un exemple simple


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

Le "function dispatcher" est ainsi le reflet de l'ABI.

L'optimisation pour l'exécution, n'est pas nécessaire pour les fonctions dites d'administration. 
Par contre c'est à prioriser pour les fonctions supposément les plus fréquement appelées (à déterminer manuellement ou après évaluation automatique lors de tests pratiques)

Merci à [**Igor Bournazel**](https://github.com/ibourn) pour la relecture technique de cet article.


## Liens

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
  - [en] [Difference Between SHA-256 and Keccak-256 - GeeksforGeeks](https://www.geeksforgeeks.org/difference-between-sha-256-and-keccak-256/)

- Outils
  - [en] [Keccak-256 Online](http://emn178.github.io/online-tools/keccak_256.html)
  - [en] [Compiler Explorer](https://godbolt.org/)
  - [en] [Ethereum Signature Database](https://www.4byte.directory/)

- Divers
  - [en] [Function Dispatching | Huff Language](https://docs.huff.sh/tutorial/function-dispatching/#linear-dispatching)


