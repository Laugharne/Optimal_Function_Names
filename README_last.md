# Optimisation sur Ethereum : Faites la différence avec les noms de fonctions

<!-- TOC -->

- [Optimisation sur Ethereum : Faites la différence avec les noms de fonctions](#optimisation-sur-ethereum--faites-la-diff%C3%A9rence-avec-les-noms-de-fonctions)
  - [Points clés](#points-cl%C3%A9s)
  - [Introduction](#introduction)
  - [Présentation du "function dispatcher"](#pr%C3%A9sentation-du-function-dispatcher)
  - [Fonctionnement](#fonctionnement)
  <!-- pourquoi majuscule à Signature -->
  - [Empreintes et Signatures des fonctions](#empreintes-et-signatures-des-fonctions)
    - [En Solidity](#en-solidity)
      <!-- ...des fonctions en Solidity -->
      - [Rappel sur les visibilités des fonctions Solidity](#rappel-sur-les-visibilit%C3%A9s-des-fonctions-solidity)
      - [À la compilation](#%C3%A0-la-compilation)
        - [Code généré](#code-g%C3%A9n%C3%A9r%C3%A9)
        - [Diagramme](#diagramme)
        - [Ordre d'évaluation](#ordre-d%C3%A9valuation)
        <!-- soit majuscule à chaque point soit non => Getter -->
        - [getter automatique](#getter-automatique)
    - [En Yul](#en-yul)
  - [Une complexité croissante !](#une-complexit%C3%A9-croissante-)
    <!-- soit majuscule à chaque point soit non => Influence (pour moi minuscule  en preview) -->
    - [Influence du niveau de runs](#influence-du-niveau-de-runs)
    - [Onze fonctions et mille runs](#onze-fonctions-et-mille-runs)
    - [Pseudo-code](#pseudo-code)
    - [Calcul des coûts en gas](#calcul-des-co%C3%BBts-en-gas)
    - [Statistiques de consommation](#statistiques-de-consommation)
  - [Algorithmes et ordre de traitement](#algorithmes-et-ordre-de-traitement)
    - [Recherche linéaire runs = 200](#recherche-lin%C3%A9aire-runs--200)
    - [Recherche fractionnée runs = 1000](#recherche-fractionn%C3%A9e-runs--1000)
  - [Les optimisations](#les-optimisations)
    - [Optimisation à l'exécution](#optimisation-%C3%A0-lex%C3%A9cution)
    - [Optimisation à la transaction](#optimisation-%C3%A0-la-transaction)
    - [Select0r](#select0r)
  - [Conclusions](#conclusions)
  - [Ressources additionnelles](#ressources-additionnelles)

<!-- Organisation chapitre à valider :
* Si garde cette forme :
=> pas logique 'en solidity, rappel dur les visibilités.., ' soient des sous chapitres de 'Empreintes...'
devraient être sous chapitre de fonctionnement
=> et dans ce cas, me gêne dans le sens de compréhension de voir les empreintes et signatures après 'Fonctionnement'

* idée intemrédiaire :
=> remonter 'Empereintes et signatures' avant 'Présentation du dispatcher' et mettre les sous chapitres 'En solidity'... ds fonctionnement

* ma proposition initiale  pour rappel :
=> remonter 'Empreintes et signatures' en premier
=> fondre 'présentation du dispatcher' avec 'Fonctionnement'
=> Faire de 'Algo et ordre ..' un sous chapitre de 'une complexité croissante' à la suite de 'statistiques'...
=> Effacer optimisation à l'execution (mettre le contenue dejà quasiment dit) en conclusion du gros chapitre 'une complexité croissante'
=> 'Optimisations' deviendrait : 'Optimisation à la transaction que tu pourrais renommer pour mettre en avant que l'opti vient du point de vue de l'appelant (gas en tant qu'argument)

=> ça pour bien scinder la partie dispatcher et lecture d'argument
Et mettre en valeur Selector
-->

<!-- /TOC -->

<!-- CORRECTION SUR LES DOCS :
* 1er dessin => supprimer le 1er bloc ? -> revert (me semble-t-il)
* 2eme dessin : idem
* tableau d etest en couleur :
 -soit préciser : Le tableau suivant (qui résulte de ces tests) nous montre le nombre de fractions de séquences de tests en affichant le nombre de recherches linéaires.
 -le préciser pour les résultats dans la légende -->

 <!-- LIENS CLIQUABLES :
 * Plan : tout est ok
 * ensemble du texte ok
 * ressources additionnelles : je n'ai pas recliqué (déjà test avant) sur tout mais environ un tiers: ok pour ce tiers 
 mais :
 valeur de runs dans le sous chapitre 'calcul des coûts en gas' renvoie sur le plan au lieu de renvoyer sur le chapitre 'algorithme (..)'-->

## Points clés

<!-- typo : cruciale -->

1. L'optimisation des coûts en gas est crucial pour les contrats intelligents sur Ethereum.
<!-- checker par sûre du pluriel pour EVM -->
2. Le "_function dispatcher_" gère l'exécution des fonctions dans les smart contracts pour les EVMs.
   <!-- amélioration : (...) , alors qu'en Yul il doit (...) -->
   <!-- typo : être codé -->
3. Le compilateur Solidity génère le "_function dispatcher_" des fonctions exposées publiquement, en Yul cela doit être coder.
<!-- typo : déterminés => hash est masculin -->
4. Les signatures, hashs et empreintes des fonctions sont déterminées par leurs noms et types de paramètres.
5. Le réglage d'optimisation du compilateur et le nombre de fonctions impactent l'algorithme de sélection des fonctions.
clarification : l'ordre de sélection (pas d'exécution) /
<!-- (REVENIR ICI) reformuler ? : Le renommage stratégique des fonctions permet d'optimiser leurs empreintes et ainsi réduire le coût en gas, en rendant leur sélection plus efficiente et en reduisant le côut de lecture de ces selecteurs -->
6. Le renommage stratégique des fonctions optimise les coûts en gas et l'ordre d'exécution, de par les valeurs des empreintes.

## Introduction

<!-- (...) Ethereum, chaque opération étant payante (ou ayant un coût) / Là : 'à un coût en gas, qui est payant, ça passe pas -->

L'optimisation des coûts en gas est un enjeu clé dans le développement de contrats intelligents sur la
blockchain Ethereum. Chaque opération effectuée sur Ethereum a un coût en gas, qui est payant.

**Rappel :**

- Le **bytecode** représente un smart contract sur la blockchain sous forme d'une séquence d'hexadécimaux.
- La machine virtuelle Ethereum (**EVM**) exécute les instructions en lisant ce bytecode lors de l'interaction avec le contrat.
- Chaque instruction élémentaire, codée sur un octet, est appelée **opcode** et a un coût en gas qui reflète les ressources nécessaires à son exécution.
- Un compilateur traduit ce code source en bytecode exécutable par l'EVM et fournit des éléments tels que l'ABI (interface binaire d'application).
- Une **ABI** définit comment les fonctions d'un contrat doivent être appelées et les données échangées, en spécifiant les types de données des arguments et la signature des fonctions.

Dans cet article, nous allons explorer comment le simple fait de nommer vos fonctions peut influencer les coûts en gas associés à votre contrat.

Nous discuterons également de diverses stratégies d'optimisation, de l'ordre des hash de signatures aux astuces de renommage des fonctions, afin de réduire les coûts associés aux interactions avec vos contrats.

**Précisions :**

Cette article se base sur :

1. Du code **solidity** (0.8.13, 0.8.17, 08.20, 0.8.22)
2. Compilé avec le compilateur `solc`
3. Pour des **EVMs** sur **Ethereum**

Les concepts suivants seront abordés :

- Le "_function dispatcher_" : le mécanisme de sélection d'une fonction dans un contrat.
<!-- (REVENIR ICI) function selecotr ... si dispatcher au dessus (noms officiles au mêm endroit) -->
- L'empreinte : l'identitifiant d'une fonction au sein de l'EVM.
- Et le nom de fonction en tant qu'argument (du côté de l'appelant).

## Présentation du "function dispatcher"

Le "_function dispatcher_" (ou gestionnaire de fonctions) dans les smart contracts (contrats intelligents) écrits pour les **EVMs** est un élément du contrat qui permet de déterminer quelle fonction doit être exécutée lorsque quelqu'un interagit avec le contrat au travers d'une ABI.

En résumé, le "_function dispatcher_" est comme un chef d'orchestre lors des appels aux fonctions d'un contrat intelligent. Il garantit que les bonnes fonctions sont appelées lorsque vous effectuez les bonnes actions sur le contrat.

## Fonctionnement

<!-- pourquoi en utilisant une application ou une transaction (c'est de toute façon une tx) : ? supprimer 'en utilisant(...) une transaction ? -->

Lorsque vous interagissez avec un contrat intelligent en utilisant une application ou une transaction, vous spécifiez quelle fonction vous souhaitez exécuter. Le "_function dispatcher_" fait donc le lien entre la commande et la fonction spécifique qui sera appelée et exécutée.

<!-- dans le calldata de quoi ? => au moment de ou de l'appel ? ... -->

L'empreinte de la fonction est récupérée dans le `calldata`, un `revert` se produit si l'appel ne peut être mis en relation avec une fonction du contrat.

<!-- utilité ? : tel qu'on le trouve dans de nobreux (...) -->

Le mécanisme de sélection est similaire, à un celui d'une structure `switch/case` ou d'un ensemble de `if/else` tel qu'on le trouve dans de nombreux autres langages de programmation.

<!-- typo : signatures -->

## Empreintes et Signatures des fonctions

<!-- un doute : fonction telle qu'employée  -->

La **signature** d'une fonction tel qu'employée avec les **EVMs** (Solidity) consiste en la concaténation de son nom et de ses types de paramètres (sans type de retour ni espaces)

<!-- (*selector* ... : function selector , uitlité de 'dans les publications anglo saxonnes' ?) -->
<!-- (identifiable, dans le cas de Solidity ..)=> identifiable. Dans le cas de Solidity -->

L'**empreinte** ("selector" dans les publications anglo-saxonnes) est l'empreinte même de la fonction qui la rend "unique" et identifiable, dans le cas de Solidity, il s'agit des 4 octets de poids fort (32 bits) du résultat du hachage de la signature de la fonction avec l'algorithme [**Keccak-256**](https://www.geeksforgeeks.org/difference-between-sha-256-and-keccak-256/) (🇬🇧).

Cela selon les [**spécifications de l'ABI en Solidity**](https://docs.soliditylang.org/en/develop/abi-spec.html#function-selector) (🇬🇧).

Je précise à nouveau que je parle de l'empreinte pour le compilateur **solc** pour **Solidity**, ce n'est pas forcément le cas avec d'autres langages comme **Rust** qui fonctionne sur un tout autre paradigme.

Si les types des paramètres sont pris en compte, c'est pour différencier les fonctions qui auraient le même nom, mais des paramètres différents, comme pour la méthode `safeTransferFrom` des tokens [**ERC721**](https://eips.ethereum.org/EIPS/eip-721) (🇬🇧).

<!-- la virgule après risque rare = ? (doute) -->

Cependant, le fait que l'on ne garde que **quatre octets** pour l'empreinte, implique de potentiels **risques de collisions de hash** entre deux fonctions, risque rare, mais existant malgré plus de 4 milliards de possibilités (2^32).

Comme en atteste le site [**Ethereum Signature Database**](https://www.4byte.directory/signatures/?bytes4_signature=0xcae9ca51) (🇬🇧) avec l'exemple suivant :

| Empreintes   | Signatures                                                   |
| ------------ | ------------------------------------------------------------ |
| `0xcae9ca51` | `onHintFinanceFlashloan(address,address,uint256,bool,bytes)` |
| `0xcae9ca51` | `approveAndCall(address,uint256,bytes)`                      |

Un simple contrat Solidity doté de ces deux fonctions ne se compile heureusement pas.

```
TypeError: Function signature hash collision for approveAndCall(address,uint256,bytes)
  --> contracts/HashCollision.sol:10:1:
   |
10 | contract HashCollision {
   | ^ (Relevant source part starts here and spans across multiple lines).
```

<!-- Mais cela n'en demeure -->

Mais n'en demeure pas moins problématique : Voir le challenge [**Hint-finance**](https://github.com/paradigmxyz/paradigm-ctf-2022/tree/main/hint-finance), au [**Web3 Hacking: Paradigm CTF 2022**](https://medium.com/amber-group/web3-hacking-paradigm-ctf-2022-writeup-3102944fd6f5) (🇬🇧)

### En Solidity

En mettant en application ce qui a été dit plus haut, on obtient, pour la fonction suivante :

```solidity
function square(uint32 num) public pure returns (uint32) {
    return num * num;
}
```

<!-- typo: suivants (hash masculin) -->

Les signature, hash et empreinte suivantes :

| Fonction  | square(uint32 num) public pure returns (uint32)                    |
| --------- | ------------------------------------------------------------------ |
| Signature | `square(uint32)` (_1_)                                             |
| Hash      | `d27b38416d4826614087db58e4ea90ac7199f7f89cb752950d00e21eb615e049` |
| Identité  | `d27b3841`                                                         |

(_1_) : _Keccak-256 online calculator : [`square(uint32)`](<https://emn178.github.io/online-tools/keccak_256.html?input_type=utf-8&input=square(uint32)>)_

En Solidity, le "_function dispatcher_" est généré par le compilateur, inutile donc de se charger du codage de cette tâche complexe.

Il ne concerne que les fonctions d'un contrat ayant un accès depuis l'extérieur de celui-ci, ayant donc un attribut d'accès external et public

#### Rappel sur les visibilités des fonctions Solidity

1. **External** : Les fonctions externes sont conçues pour être appelées depuis l'**extérieur du contrat**, généralement par d'autres contrats ou des comptes externes. C'est la visibilité pour exposer une interface publique à votre contrat.

2. **Public** : Les fonctions publiques sont accessibles depuis l'**extérieur et l'intérieur du contrat**.

3. **Internal** et **private** : Les fonctions internes et private ne peuvent être appelées que depuis l'**intérieur du contrat** (et les contrants héritant de celui-ci dans le cas d'internal).

**Exemple #1** :

```solidity
pragma solidity 0.8.13;

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

#### À la compilation

<!-- typo : empreintes -->

Si nous reprenons le précédent code utilisé en exemple, nous obtenons les signatures et Empreintes suivantes :

| Fonctions                                              | Signatures                  | Keccak            | Empreintes     |
| ------------------------------------------------------ | --------------------------- | ----------------- | -------------- |
| **`setValue(uint256 _newValue) external`**             | `setValue(uint256)`         | `55241077...ecbd` | **`55241077`** |
| **`getValue() public view returns (uint256)`**         | `getValue()`                | `20965255...ad96` | **`20965255`** |
| **`setInternalValue(uint256 _newValue) internal`**     | `setInternalValue(uint256)` | `6115694f...7ce1` | **`6115694f`** |
| **`getInternalValue() public view returns (uint256)`** | `getInternalValue()`        | `e778ddc1...c094` | **`e778ddc1`** |

(_Les hashs issus du Keccak ont été tronqués volontairement_)

<!-- typo : apparaît / manque des points en fin de phrases sur l'ensemble des ligne en fait -->

Si on examine l'ABI généré lors de la compilation, la fonction `setInternalValue()` n'apparait pas, ce qui est normal, sa visibilité étant `internal` (voir plus haut)

On notera dans les données de l'ABI, la référence à la donnée du storage `value` qui est `public` (on y reviendra plus loin)

##### Code généré

<!-- Voici, en extrait, le code  -->
<!-- typo : Solidity -->

Voici en extrait le code du "_function dispatcher_" généré par le compilateur `solc` (version de solidity : 0.8.13)

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

##### Diagramme

Sous forme de diagramme, on comprend mieux le mécanisme de sélection similaire à un celui d'une structure `switch/case` ou d'un ensemble de `if/else`.

![](functions_dispatcher_diagram.png)

<!-- ![](functions_dispatcher_diagram.svg) -->

##### Ordre d'évaluation

**Important** : L'ordre d'évaluation des fonctions n'est pas le même que celui de déclaration dans le code !

| Ordre d'évaluation | Ordre dans le code | Empreintes | Signatures                     |
| ------------------ | ------------------ | ---------- | ------------------------------ |
| 1                  | **3**              | `20965255` | `getValue()`                   |
| 2                  | **1**              | `3FA4F245` | `value` (_getter automatique_) |
| 3                  | **2**              | `55241077` | `setValue(uint256)`            |
| 4                  | **4**              | `E778DDC1` | `getInternalValue()`           |

<!-- empreintes -->

En effet, les évaluations des Empreintes de fonctions sont ordonnées par un tri ascendant sur leurs valeurs.

`20965255` < `3FA4F245` < `55241077` < `E778DDC1`

<!-- Getter  -->

##### getter() automatique

La fonction d'empreinte `3FA4F245` est en fait un **getter** automatique de la donnée publique `value`, elle est générée par le compilateur. En solidty, le compilateur fournit automatiquement un getter public à toute variable de storage publique.

```solidity
  uint256 public value;
```

Nous retrouvons d'ailleurs dans les opcodes, l'empreinte de sélection (`3FA4F245`) et la fonction (à l'adresse `tag 4`) du getter automatique pour cette variable.

**Sélecteur** :

```yul
  DUP1
  PUSH 3FA4F245
  EQ
  PUSH [tag] 4
  JUMPI
```

**Fonction** :

```yul
tag 4
  JUMPDEST
  PUSH [tag] 11
  PUSH [tag] 12
  JUMP [in]
tag 11
  JUMPDEST
  PUSH 40
  MLOAD
  PUSH [tag] 13
  SWAP2
  SWAP1
  PUSH [tag] abi_encode_tuple_t_uint256__to_t_uint256__fromStack_reversed_0
  JUMP [in]
tag 13
  JUMPDEST
  PUSH 40
  MLOAD
  DUP1
  SWAP2
  SUB
  SWAP1
  RETURN
```

`getter` ayant d'ailleurs un code identique à celui de la fonction `getValue()`

```yul
tag getValue_0
  JUMPDEST
  PUSH [tag] getValue_1
  PUSH [tag] getValue_3
  JUMP [in]
tag getValue_1
  JUMPDEST
  PUSH 40
  MLOAD
  PUSH [tag] getValue_2
  SWAP2
  SWAP1
  PUSH [tag] abi_encode_tuple_t_uint256__to_t_uint256__fromStack_reversed_0
  JUMP [in]
tag getValue_2
  JUMPDEST
  PUSH 40
  MLOAD
  DUP1
  SWAP2
  SUB
  SWAP1
  RETURN
```

<!-- ',' avant mais également -->

Démontrant ainsi l'inutilité d'avoir la variable `value` avec l'attribut `public` de concert avec la fonction `getValue()` mais également une faiblesse du compilateur de Solidity `solc` qui ne peut fusionner le code des deux fonctions.

<!-- supprimer : 'Dont on peut résumer le contenu en quatre points' -->

Voici d'ailleurs un lien, pour ceux qui voudraient aller plus loin, [**un article détaillé**](https://medium.com/coinmonks/soliditys-cheap-public-face-b4e972e3924d) (🇬🇧) sur les `automatic storage getters` en Solidity. Dont on peut résumé le contenu en quatre points essentiels.

### En Yul

Voici un extrait d'un exemple de [**contrat ERC20**](https://docs.soliditylang.org/en/develop/yul.html#complete-erc20-example) (🇬🇧) entièrement écrit en **Yul**.

<!-- '.' -->

Si **Solidity** apporte abstraction et lisibilité, **Yul** langage de plus bas niveau, proche de l'assembleur, permet d'avoir un bien meilleur contrôle de l'exécution

```yul
object "runtime" {
    code {
        // Protection against sending Ether
        require(iszero(callvalue()))

        // Dispatcher
        switch selector()
        case 0x70a08231 /* "balanceOf(address)" */ {
            returnUint(balanceOf(decodeAsAddress(0)))
        }
        case 0x18160ddd /* "totalSupply()" */ {
            returnUint(totalSupply())
        }
        case 0xa9059cbb /* "transfer(address,uint256)" */ {
            transfer(decodeAsAddress(0), decodeAsUint(1))
            returnTrue()
        }
        case 0x23b872dd /* "transferFrom(address,address,uint256)" */ {
            transferFrom(decodeAsAddress(0), decodeAsAddress(1), decodeAsUint(2))
            returnTrue()
        }
        case 0x095ea7b3 /* "approve(address,uint256)" */ {
            approve(decodeAsAddress(0), decodeAsUint(1))
            returnTrue()
        }
        case 0xdd62ed3e /* "allowance(address,address)" */ {
            returnUint(allowance(decodeAsAddress(0), decodeAsAddress(1)))
        }
        case 0x40c10f19 /* "mint(address,uint256)" */ {
            mint(decodeAsAddress(0), decodeAsUint(1))
            returnTrue()
        }
        default {
            revert(0, 0)
        }

        /* ---------- calldata decoding functions ----------- */
        function selector() -> s {
            s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
        }

  ...

```

On y retrouve la suite de structure de `if/else` en cascade, identique au diagramme précédent.

Réaliser un contrat **100% en Yul**, oblige à coder soi-même le "_function dispatcher_", ce qui implique que l'on peut choisir l'ordre de traitement des empreintes, ainsi qu'utiliser d'autres algorithmes qu'une simple suite de tests en cascade.

## Une complexité croissante !

Maintenant, voici un tout autre exemple pour illustrer le fait que les choses sont plus complexes en réalité !

Car en fonction du **nombre de fonctions** et du **niveau d'optimisation** (voir : `--optimize-runs`) le compilateur Solidity n'a pas le même comportement !

**Exemple #2** :

```solidity
// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.17;

contract Storage {

    uint256 numberA;
    uint256 numberB;
    uint256 numberC;
    uint256 numberD;
    uint256 numberE;


    // selector : C534BE7A
    function storeA(uint256 num) public {
        numberA = num;
    }

    // selector : 9AE4B7D0
    function storeB(uint256 num) public {
        numberB = num;
    }

    // selector : 4CF56E0C
    function storeC(uint256 num) public {
        numberC = num;
    }

    // selector : B87C712B
    function storeD(uint256 num) public {
        numberD = num;
    }

    // selector : E45F4CF5
    function storeE(uint256 num) public {
        numberE = num;
    }

    // selector : 2E64CEC1
    function retrieve() public view returns (uint256) {
        return Multiply( numberA, numberB, numberC, numberD);
    }

}
```

<!-- ..si ds papier anglais en italique : storage et internal en italique -->
<!-- typo : Solidity -->

Ici les variables de storage sont internal (attribut par défaut en solidity) aucun getter automatique ne sera donc ajouté par le compilateur.

<!-- typo : leurs empreintes -->

Et nous avons bien 6 fonctions présentes dans le JSON de l'ABI. Les **6 fonctions `public`** suivantes avec leur empreintes dédiées :

| Fonctions                                      | Signatures        | Empreintes     |
| ---------------------------------------------- | ----------------- | -------------- |
| **`storeA(uint256 num) public`**               | `storeA(uint256)` | **`C534BE7A`** |
| **`storeB(uint256 num) public`**               | `storeB(uint256)` | **`9AE4B7D0`** |
| **`storeC(uint256 num) public`**               | `storeC(uint256)` | **`4CF56E0C`** |
| **`storeD(uint256 num) public`**               | `storeD(uint256)` | **`B87C712B`** |
| **`storeE(uint256 num) public`**               | `storeE(uint256)` | **`E45F4CF5`** |
| **`retrieve() public view returns (uint256)`** | `retrieve()`      | **`2E64CEC1`** |

Suivant le [**niveau d'optimisation**](https://docs.soliditylang.org/en/develop/internals/optimizer.html) (🇬🇧) du compilateur, nous obtenons un code différent pour le "_function dispatcher_".

Avec un niveau à **200** (`--optimize-runs 200`) nous obtenons le type de code précédemment généré, avec ses `if/else` en cascade.

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
  PUSH 2E64CEC1
  EQ
  PUSH [tag] retrieve_0
  JUMPI
  DUP1
  PUSH 4CF56E0C
  EQ
  PUSH [tag] storeC_uint256_0
  JUMPI
  DUP1
  PUSH 9AE4B7D0
  EQ
  PUSH [tag] storeB_uint256_0
  JUMPI
  DUP1
  PUSH B87C712B
  EQ
  PUSH [tag] storeD_uint256_0
  JUMPI
  DUP1
  PUSH C534BE7A
  EQ
  PUSH [tag] storeA_uint256_0
  JUMPI
  DUP1
  PUSH E45F4CF5
  EQ
  PUSH [tag] storeE_uint256_0
  JUMPI
  PUSH 0
  DUP1
  REVERT
```

Par contre, avec un niveau de `runs` plus élevé (`--optimize-runs 300`)

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
  PUSH B87C712B
  GT
  PUSH [tag] 9
  JUMPI
  DUP1
  PUSH B87C712B
  EQ
  PUSH [tag] storeD_uint256_0
  JUMPI
  DUP1
  PUSH C534BE7A
  EQ
  PUSH [tag] storeA_uint256_0
  JUMPI
  DUP1
  PUSH E45F4CF5
  EQ
  PUSH [tag] storeE_uint256_0
  JUMPI
  PUSH 0
  DUP1
  REVERT
tag 9
  JUMPDEST
  DUP1
  PUSH 2E64CEC1
  EQ
  PUSH [tag] retrieve_0
  JUMPI
  DUP1
  PUSH 4CF56E0C
  EQ
  PUSH [tag] storeC_uint256_0
  JUMPI
  DUP1
  PUSH 9AE4B7D0
  EQ
  PUSH [tag] storeB_uint256_0
  JUMPI
tag 2
  JUMPDEST
  PUSH 0
  DUP1
  REVERT
```

Les opcodes et le flux d'exécution avec `--optimize-runs 300`, ne sont plus les mêmes, comme montré dans le diagramme suivant.

![](functions_split_dispatcher_diagram.png)

<!-- pas de point : '.' -> , diminuant -->

On voit que les tests sont "découpés" en deux recherches linéaires autour d'une valeur pivot `B87C712B`. Diminuant ainsi la consommation pour les cas les moins favorables `storeB(uint256)` et `storeE(uint256)`.

### Influence du niveau de runs

<!-- amelioration : ',' respectivement ',' -->

Seulement **4 tests** pour les fonctions `storeB(uint256)` et `storeE(uint256)`, au lieu de respectivement **3 tests** et **6 tests** avec le précédent algorithme.

<!-- amelioration : tu parles des regles après, donc ici mettre 'est un peu délicat, **par exemple** le seuil' -->

La détermination du déclenchement de ce type d'optimisation est un peu délicat, le seuil du nombre de fonctions se trouve être 6 pour le déclencher avec `--optimize-runs 284`, donnant **deux tranches** de 3 séries de tests linéaires.

Lorsque le nombre de fonctions est inférieur à 4, le processus de sélection se fait par une recherche linéaire.

<!-- supprimer la ligne vide, les deux paragraphes sont liés -->

En revanche, à partir de cinq fonctions, le compilateur fractionne le traitement en fonction de son paramètre d'optimisation.

Des [tests sur des contrats basiques](https://github.com/Laugharne/solc_runs_dispatcher) comportant de 4 à 15 fonctions, avec des optimisations de 200 à 1000 exécutions, ont démontré ces seuils.

<!-- plus claire si dit ou ajoute nombre de recherches linéaires , moi je vois ce que tu veux dire mais pas sûre que tout le monde saisisse-->

Le tableau suivant (qui résulte de ces tests) nous montre le nombre de fractions de séquences de tests.

![](func_runs.png)

(_F : Nbr functions / R : Runs level_)

Ces seuils (liés à des valeurs de `runs`) sont-t-il susceptibles d'évoluer au fil des versions du compilateur `solc` ?

### Onze fonctions et mille runs

Détaillons un exemple pour le cas d'un contrat avec 11 fonctions pour visualiser l'impact sur la consommation en gas.

<!-- encore une fois préciser : tranche de quoi ? -->

Avec **11 fonctions** éligibles, et un niveau de `runs` supérieur `--optimize-runs 1000` on passe de **deux tranches** (une de 6 + une de 5) à **4 tranches** (trois tranches de 3 + une de 2)

### Pseudo-code

<!-- typo: reproduis -->

Cette fois-ci, je ne reproduit pas les opcodes et le diagramme associé, afin de clarifier l'explication, voici le flux d'exécution sous forme de _pseudo-code_, semblable à du code en langage **C**.

```c
// [tag 1]
// 1 gas (JUMPDEST)
if( selector >= 0x799EBD70) {  // 22 = (3+3+3+3+10) gas
  if( selector >= 0xB9E9C35C) {  // 22 = (3+3+3+3+10) gas
    if( selector == 0xB9E9C35C) { goto storeF }  // 22 = (3+3+3+3+10) gas
    if( selector == 0xC534BE7A) { goto storeA }  // 22 = (3+3+3+3+10) gas
    if( selector == 0xE45F4CF5) { goto storeE }  // 22 = (3+3+3+3+10) gas
    revert()
  }
  // [tag 15]
  // 1 gas (JUMPDEST)
  if( selector == 0x799EBD70) { goto storeG }  // 22 = (3+3+3+3+10) gas
  if( selector == 0x9AE4B7D0) { goto storeB }  // 22 = (3+3+3+3+10) gas
  if( selector == 0xB87C712B) { goto storeD }  // 22 = (3+3+3+3+10) gas
  revert()
} else {
  // [tag 14]
  // 1 gas (JUMPDEST)
  if( selector >= 0x4CF56E0C) { // 22 = (3+3+3+3+10) gas
    if( selector == 0x4CF56E0C) { goto storeC }  // 22 = (3+3+3+3+10) gas
    if( selector == 0x6EC51CF6) { goto storeJ }  // 22 = (3+3+3+3+10) gas
    if( selector == 0x75A64B6D) { goto storeH }  // 22 = (3+3+3+3+10) gas
    revert()
  }
  // [tag 16]
  // 1 gas (JUMPDEST)
  if( selector == 0x183301E7) { goto storeI }    // 22 = (3+3+3+3+10) gas
  if( selector == 0x2E64CEC1) { goto retrieve }  // 22 = (3+3+3+3+10) gas
  revert()
}
```

On distingue mieux les articulations autour des différentes valeurs "pivots" :

<!-- question sur l'emphase de seuil primaire/secondaire, est ce utile? les voir en gras, on s'attend à ce que ce soit une terminologie officielle liée au dispatcher -->

- Avec `799EBD70` en valeur de **seuil primaire**.
- Puis `0x4CF56E0C` & `0xB9E9C35C` en tant que valeurs de **seuils secondaires**.

### Calcul des coûts en gas

J'ai pris pour référence toujours le code d'un contrat Solidity avec **11 fonctions éligibles** au "_function dispatcher_", afin d'estimer le coût en gas de la sélection, selon que l'on ait une recherche linéaire ou fractionnée.

C'est uniquement le **coût de la sélection** dans le "_function dispatcher_" et non l'exécution des fonctions qui est estimé. Nous ne nous préoccupons pas de ce que fait la fonction elle-même ni de ce qu'elle consomme comme gas, ni du code qui extrait l'empreinte de la fonction an allant chercher la donnée dans la zone `calldata`.

<!-- typo : a été réalisée -->

L'estimation des coûts en gas des opcodes utilisés ont été réalisés en m'aidant des sites suivants :

- [**Ethereum Yellow Paper**](https://ethereum.github.io/yellowpaper/paper.pdf) (Berlin version, 🇬🇧)
- [**EVM Codes - An Ethereum Virtual Machine Opcodes Interactive Reference**](https://www.evm.codes/?fork=shanghai) (🇬🇧)

Les **opcodes** en jeu pour ce qui nous concerne sont les suivants :

| Mnemonic           | Gas | Description                             |
| ------------------ | --- | --------------------------------------- |
| `JUMPDEST`         | 1   | Mark valid jump destination.            |
| `DUP1`             | 3   | Clone 1st value on stack                |
| `PUSH4 0xXXXXXXXX` | 3   | Push 4-byte value onto stack.           |
| `GT`               | 3   | Greater-than comparison.                |
| `EQ`               | 3   | Equality comparison.                    |
| `PUSH [tag]`       | 3   | Push 2-byte value onto stack.           |
| `JUMPI`            | 10  | Conditionally alter the program counter |

<!-- typo : permis -->
<!-- améiortion : 'estimer les coûts de recherche pour chaue fonction' -->
<!-- amélioration : 200 runs et fractionné -->

Ce qui m'a permit d'estimer les coûts de recherche en gas pour chaque fonction, pour les [valeur de runs](#seuils) `200` et `1000` amenant ainsi un traitement différent, séquentiel pour `200 runs` et "fraction" pour `1000 runs`.

| Signatures        | Empreintes       | Gas (linear)    | Gas (splited)   |
| ----------------- | ---------------- | --------------- | --------------- |
| `storeI(uint256)` | `183301E7`       | **22 (_min_)**  | 69              |
| `retrieve()`      | `2E64CEC1`       | 44              | 91              |
| `storeC(uint256)` | `4CF56E0C` (_2_) | 66              | 69              |
| `storeJ(uint256)` | `6EC51CF6`       | 88              | 90              |
| `storeH(uint256)` | `75A64B6D`       | 110             | **112 (_max_)** |
| `storeG(uint256)` | `799EBD70` (_1_) | 132             | 68              |
| `storeB(uint256)` | `9AE4B7D0`       | 154             | 90              |
| `storeD(uint256)` | `B87C712B`       | 176             | **112 (_max_)** |
| `storeF(uint256)` | `B9E9C35C` (_2_) | 198             | **67 (_min_)**  |
| `storeA(uint256)` | `C534BE7A`       | 220             | 89              |
| `storeE(uint256)` | `E45F4CF5`       | **242 (_max_)** | 111             |

<!-- ? je ne trouve pas les légendes claires,même si je sais de quoi tu parles :
proposition : premier seuil de fractionnement (?) -->

- (_1_) : _seuil primaire pour 1000 runs_
- (_2_) : _seuils secondaires pour 1000 runs_

### Statistiques de consommation

Si on regarde d'un peu plus près le résultat de certaines **statistiques** sur les deux types de recherche.

| \          | Linear | Splited   |
| ---------- | ------ | --------- |
| Min        | **22** | 67        |
| Max        | 242    | **112**   |
| Moyenne    | 132    | **88**    |
| Ecart-type | 72,97  | **18,06** |

On constate des différences notables. En l'occurrence, une **moyenne** plus basse (-33%) avec une [**dispersion**](https://fr.wikipedia.org/wiki/%C3%89cart_type) des consommations considérablement plus faible (4 fois moins) en faveur du traitement par fractions.

## Algorithmes et ordre de traitement

Suivant l'algorithme utilisé par le compilateur Solidity pour générer le "_function dispatcher_", l'ordre de traitement des fonctions sera différent, aussi bien de l'ordre de déclaration dans le code source que de l'ordre alphabétique.

### Recherche linéaire (runs = 200)

| #      | Signatures        | Empreintes |
| ------ | ----------------- | ---------- |
| **1**  | `storeI(uint256)` | `183301E7` |
| **2**  | `retrieve()`      | `2E64CEC1` |
| **3**  | `storeC(uint256)` | `4CF56E0C` |
| **4**  | `storeJ(uint256)` | `6EC51CF6` |
| **5**  | `storeH(uint256)` | `75A64B6D` |
| **6**  | `storeG(uint256)` | `799EBD70` |
| **7**  | `storeB(uint256)` | `9AE4B7D0` |
| **8**  | `storeD(uint256)` | `B87C712B` |
| **9**  | `storeF(uint256)` | `B9E9C35C` |
| **10** | `storeA(uint256)` | `C534BE7A` |
| **11** | `storeE(uint256)` | `E45F4CF5` |

<!-- correction : sont proportionnels -->

Le nombre de tests et la complexité du processus est proportionnelle au nombre de fonctions, en [**O(n)**](https://fr.wikipedia.org/wiki/Complexit%C3%A9_en_temps#Liste_de_complexit%C3%A9s_en_temps_classiques).

### Recherche fractionnée (runs = 1000)

| #      | Signatures        | Empreintes |
| ------ | ----------------- | ---------- |
| **1**  | `storeF(uint256)` | `B9E9C35C` |
| **2**  | `storeG(uint256)` | `799EBD70` |
| **3**  | `storeI(uint256)` | `183301E7` |
| **4**  | `storeC(uint256)` | `4CF56E0C` |
| **5**  | `storeA(uint256)` | `C534BE7A` |
| **6**  | `storeJ(uint256)` | `6EC51CF6` |
| **7**  | `storeB(uint256)` | `9AE4B7D0` |
| **8**  | `retrieve()`      | `2E64CEC1` |
| **9**  | `storeE(uint256)` | `E45F4CF5` |
| **10** | `storeH(uint256)` | `75A64B6D` |
| **11** | `storeD(uint256)` | `B87C712B` |

Il ne s'agit pas d'une [**recherche dichotomique**](https://fr.wikipedia.org/wiki/Recherche_dichotomique) au sens strict du terme, mais plutôt d'un découpage en groupes de tests séquentiels autour de valeurs pivots. Mais au final, la complexité est identique, en [**O(log n)**](https://fr.wikipedia.org/wiki/Complexit%C3%A9_en_temps#Liste_de_complexit%C3%A9s_en_temps_classiques).

<!-- VOIR plan-introduction : j'ai expliqué mon point de vu sur ce chapitre
ça case la lecture de selecteur ds un sous chapitre, et ça ne met pas en valeur selectOr-->

## Les optimisations

<!-- typo : fréquence -->
<!-- typo : 'd'utilisation), celles-ci' (virgule, mais pas certain) -->
<!-- typo : virgules : ',lors de leurs appels, ' -->

Si on part sur le principe que les fonctions sont appelées de manière équitable (à la même fréquance d'utilisation) celles-ci lors de leurs appels ne coûteront pas la même chose en fonction de leurs signatures (et par là même de leurs noms). On voit clairement que tel quel le coût de la sélection d'un appel vers ces fonctions, quel que soit l'algorithme, est très hétérogène et s'il peut être estimé, il ne peut être imposé.

<!-- correction : 'en ajoutant des suffixes par exemple' -->
<!-- CHIPOTAGE : toujours pas ok avec la notion de tx, surtout ds ce chapitre :
fin de phrase : lors de l'appel... mais aussi lors des transactions
clairement, ici qd tu parles de l'appel de fonction : il faudrait mettre : lors de la sélection de la fonction dans l'EVM, mais aussi (..) au niveau de l'appel de fonction -->

Cependant, en renommant stratégiquement les fonctions, en ajoutant des suffixes, vous pouvez influencer le résultat des signatures de fonctions et, par conséquent, les coûts de gaz associés à ces fonctions. Cette pratique peut permettre d'optimiser la consommation de gaz dans votre contrat intelligent, lors de l'appel de la fonction dans l'EVM, mais aussi, comme nous le verrons plus loin, lors des transactions.

### Optimisation à l'exécution

Pour illustrer la chose, la signature de la fonction `square(uint32)` modifiée ainsi `square_low(uint32)` aura pour empreinte `bde6cad1` au lieu de `d27b3841`.

La valeur inférieure de la nouvelle empreinte obtenue fera ainsi remonter en priorité le traitement de l'appel de cette fonction.

Cette optimisation peut être importante pour les contrats intelligents très complexes, car elle permet de réduire le temps nécessaire pour rechercher et sélectionner la bonne fonction à appeler, ce qui se traduit par des économies de gaz et des performances améliorées sur la blockchain Ethereum.

<!-- typo : dans le sens où -->

Le fait que la recherche soit fractionnée au lieu de linéaire, complique un peu les choses, dans le sens ou en fonction du nombre de fonctions et du niveau d'optimisation du compilateur, les valeurs seuils sont plus délicates à déterminer pour choisir les nouvelles signatures en fonction de l'ordre désiré.

<!-- CHIPOTAGE, pas ok sur la notion de TX (la selection de fonction necessite aussi une tx), il s'agit plutôt de lecture de data (le selecteur de fonction lu dans le calldata) -->

### Optimisation à la transaction

<!-- correction : vous pouvez inclure (effacer généralement)
ou alors : vous incluez des données pour specifier quelle fonction-->

Lorsque vous envoyez une transaction sur la blockchain Ethereum, vous incluez généralement des données qui spécifient quelle fonction du contrat intelligent vous souhaitez appeler et quels sont les arguments de cette fonction. Or le coût en gaz d'une transaction dépend en partie du nombre d'octets à zéro dans les données de cette transaction.

Comme précisé dans l'[**Ethereum Yellow Paper**](https://ethereum.github.io/yellowpaper/paper.pdf) (Berlin version, 🇬🇧)

![](g_tx_data.png)

- `Gtxdatazero` coûte **4 gas** pour chaque octet nul en transaction.
- `Gtxdatanonzero` coûte **16 gas** pour chaque octet non-nul, soit **4 fois plus cher**.

Ainsi, chaque fois qu'un octet est à zéro (`00`) est utilisé dans `msg.data` en lieu et place d'un octet non-nul, il économise **12 gas**.

Cette particularité des EVMs a également un impact sur la consommation d'autres opcodes comme `Gsset` et `Gsreset`.

Pour illustrer la chose, la signature de la fonction `square(uint32)` modifiée ainsi `square_Y7i(uint32)` aura pour empreinte `00001878` au lieu de `d27b3841`.

<!-- pas d'accord : "lors de la transaction" => lors de la lecture du selecteur (ou de l'extraction ...) -->

Les deux octets de poids forts de l'empreinte (`0000`) feront non seulement remonter en priorité le **traitement de l'appel** de cette fonction comme vu plus haut, mais permettra également de consommer **moins de gas** lors de la transaction (**40** au lieu de **64**).

En voici d'autres exemples :

| Signatures (optimal)   | Empreintes (optimal) | Signatures         | Empreintes |
| ---------------------- | -------------------- | ------------------ | ---------- |
| `deposit_ps2(uint256)` | 0000fee6             | `deposit(uint256)` | b6b55f25   |
| `mint_540(uint256)`    | 00009d1c             | `mint(uint256)`    | a0712d68   |
| `b_1Y()`               | 00008e0c             | `b()`              | 4df7e3d0   |

Utiliser des empreintes avec **trois octets** de poids forts à zéro, permet ainsi de ne consommer que **28 gas**.

Comme par exemple [**`deposit278591A(uint)`**](<https://emn178.github.io/online-tools/keccak_256.html?input_type=utf-8&input=deposit278591A(uint)>) et [**`deposit_3VXa0(uint256)`**](<https://emn178.github.io/online-tools/keccak_256.html?input_type=utf-8&input=deposit_3VXa0(uint256)>) dont les empreintes respectives, sont **`00000070`** et **`0000007e`**.

<!-- correction : ne permettant de consommer => permettant de ne consommer que -->
<!-- correction 'avec ...' => ',avec pour illustration la signature (...)' -->

Par contre, il ne peut y avoir qu'une seule fonction éligible par contrat qui puisse avoir comme empreinte **`00000000`** ne permettant de consommer que **16 gas** avec pour illustration, la signature suivante : [**`execute_44g58pv()`**](<https://emn178.github.io/online-tools/keccak_256.html?input_type=utf-8&input=execute_44g58pv()>).

### Select0r

<!-- typo : réalisé -->
<!-- je bloque sur : J'ai ainsi réalisé...=> ? J'ai réalisé ? -->
<!-- sans détailler ce serait bien d'en dire un peu plus en une ou deux lignes. Pour préciser par exemple que l'optimisation se fera en cherchant un nombre spécifié de leading zéro ce qui influence l'ordre de selection ainsi que le coût de lecture -->

J'ai ainsi réaliser **Select0r**, un outil écrit en **Rust** qui permettra à votre guise de renommer vos fonctions afin d'en optimiser les appels.

[**GitHub - Laugharne/select0r**](https://github.com/Laugharne/select0r/tree/main)

## Conclusions

- L'optimisation des coûts en gas est un aspect essentiel de la conception de contrats intelligents efficaces sur Ethereum.

- En faisant attention aux détails tels que l'ordre des signatures de fonction, le nombre de zéros en début de hash, l'ordre de traitement des fonctions, et le renommage des fonctions, vous pouvez réduire de manière significative les coûts associés à votre contrat.

<!-- typo (pas sûre) : toutefois, -->

- **Attention** toutefois la convivialité et la lisibilité de votre code peut en être réduite.

- L'optimisation pour l'exécution n'est pas forcément nécessaire pour les fonctions dites d'administration, ou celles trop peu fréquement appelées.
<!-- je pense que les deux paragraphes devraient être liés -->
- Par contre, c'est à prioriser pour les fonctions supposément les plus fréquemment appelées (à déterminer manuellement ou statistiquement lors de tests pratiques).

En fin de compte, ces optimisations peuvent faire la différence entre un contrat économique et un contrat coûteux en gas.

---

Crédits : **Franck Maussand franck@maussand.net**

_Merci à [**Igor Bournazel**](https://github.com/ibourn) pour ses suggestions et la relecture de cet article._

---

## Ressources additionnelles

<!-- Ajouter des ':' pour 'Fonction de hashage','Keccak',....
il manque une ligne vide pour 'Divers' -->

- Fonction de hachage

  - 🇫🇷 [Fonction de hachage — Wikipédia](https://fr.wikipedia.org/wiki/Fonction_de_hachage)
  - 🇬🇧 [Hash function - Wikipedia](https://en.wikipedia.org/wiki/Hash_function)

- Keccak

  - 🇫🇷 [SHA-3 — Wikipédia](https://fr.wikipedia.org/wiki/SHA-3)
  - 🇬🇧 [SHA-3 - Wikipedia](https://en.wikipedia.org/wiki/SHA-3)
  - 🇬🇧 [Difference Between SHA-256 and Keccak-256 - GeeksforGeeks](https://www.geeksforgeeks.org/difference-between-sha-256-and-keccak-256/)

- Recherche dichotomique

  - 🇫🇷 [Recherche dichotomique — Wikipédia](https://fr.wikipedia.org/wiki/Recherche_dichotomique)
  - 🇬🇧 [Binary search algorithm - Wikipedia](https://en.wikipedia.org/wiki/Binary_search_algorithm)
  - 🇫🇷 [Calculer la performance d'un algorithme avec la notation Big-O](https://buzut.net/cours/computer-science/time-complexity)
  - 🇬🇧 [Big O notation - Wikipedia](https://en.wikipedia.org/wiki/Big_O_notation)

- Reférences

  - 🇬🇧 [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)
  - 🇬🇧 [Opcodes for the EVM](https://ethereum.org/en/developers/docs/evm/opcodes/)
  - 🇬🇧 [EVM Codes - An Ethereum Virtual Machine Opcodes Interactive Reference](https://www.evm.codes/?fork=shanghai)
  - 🇬🇧 [Operations with dynamic Gas costs](https://github.com/wolflo/evm-opcodes/blob/main/gas.md)
  - 🇬🇧 [Contract ABI Specification — Solidity 0.8.22 documentation](https://docs.soliditylang.org/en/develop/abi-spec.html#function-selector)
  - 🇬🇧 [Yul — Solidity 0.8.22 documentation](https://docs.soliditylang.org/en/latest/yul.html)
  - 🇬🇧 [Yul — Complete ERC20 Example](https://docs.soliditylang.org/en/develop/yul.html#complete-erc20-example)
  - 🇬🇧 [Using the Compiler — Solidity 0.8.22 documentation](https://docs.soliditylang.org/en/latest/using-the-compiler.html)
  - 🇬🇧 [The Optimizer — Solidity 0.8.22 documentation](https://docs.soliditylang.org/en/develop/internals/optimizer.html)

- Outils

  - 🇬🇧 [GitHub - Laugharne/select0r](https://github.com/Laugharne/select0r/tree/main)
  - 🇬🇧 [Keccak-256 Online](http://emn178.github.io/online-tools/keccak_256.html)
  - 🇬🇧 [Compiler Explorer](https://godbolt.org/)
  - 🇬🇧 [Solidity Optimize Name](https://emn178.github.io/solidity-optimize-name/)
  - 🇬🇧 [Ethereum Signature Database](https://www.4byte.directory/)
  - 🇬🇧 [GitHub - shazow/whatsabi: Extract the ABI (and other metadata) from Ethereum bytecode, even without source code.](https://github.com/shazow/whatsabi)

- Divers
  - 🇬🇧 [Function Dispatching | Huff Language](https://docs.huff.sh/tutorial/function-dispatching/#linear-dispatching)
  - 🇬🇧 [Solidity’s Cheap Public Face](https://medium.com/coinmonks/soliditys-cheap-public-face-b4e972e3924d)
  - 🇬🇧 [Web3 Hacking: Paradigm CTF 2022 Writeup](https://medium.com/amber-group/web3-hacking-paradigm-ctf-2022-writeup-3102944fd6f5)
  - 🇬🇧 [paradigm-ctf-2022/hint-finance at main · paradigmxyz/paradigm-ctf-2022 · GitHub](https://github.com/paradigmxyz/paradigm-ctf-2022/tree/main/hint-finance)
  - 🇬🇧 [GitHub - Laugharne/solc_runs_dispatcher](https://github.com/Laugharne/solc_runs_dispatcher)
  - 🇬🇧 [WhatsABI? with Shazow - YouTube](https://www.youtube.com/watch?v=sfgassm8SKw)
