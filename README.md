# Audit qualité et nettoyage d'une base de données : MediCarePlus

## Contexte
Exercice de qualité de données en SQL sur une base fictive de chaîne de pharmacies.
La base contient des anomalies volontairement insérées. L'objectif est de les détecter,
de nettoyer les contacts clients et de produire une table de contact fiable.

Les données sont fictives et la base est petite (110 lignes) : le projet démontre une méthode,
pas un passage à l'échelle.

## Contenu du dépôt
| Fichier | Rôle |
|---|---|
| `medicareplus.sql` | Crée les 4 tables et insère les données, anomalies comprises |
| `traitement_medicareplus.sql` | Diagnostic, nettoyage et normalisation, avec un commentaire sous chaque requête |

## Structure de la base
| Table | Lignes |
|---|---|
| clients | 25 |
| produits | 20 |
| commandes | 21 |
| lignes_commande | 44 |

## Méthode
Le script `traitement_medicareplus.sql` est en trois parties.

**Partie 1 : diagnostic (12 contrôles, lecture seule)**
Valeurs manquantes, doublons par email et par identité, clients sans commande, écart entre le total
d'une commande et la somme de ses lignes, prix aberrants, dates de naissance impossibles, stocks
négatifs, produits périmés, prix de ligne incohérent, commandes orphelines, lignes orphelines.
La requête 1.13 compte les clients ayant au moins une anomalie.

**Partie 2 : nettoyage des clients, dans une transaction (`BEGIN` / `COMMIT`)**
Emails en minuscules et sans espaces, lettres `O` remplacées par des `0` dans les codes postaux,
fusion du doublon (les commandes sont rattachées au client conservé, puis le doublon est supprimé).

**Partie 3 : table `client_contact`**
Email, téléphone et code postal nettoyés. Le téléphone est ramené au format `0XXXXXXXXX`
(espaces, points et tirets retirés, `+33` remplacé par `0`).

Le script peut être relancé : la première ligne supprime l'ancienne table `client_contact`.

## Résultats

### Clients : 16 sur 25 présentent au moins une anomalie sur la base d’origine
Un client est compté s'il cumule au moins l'un de ces sept défauts :

| Anomalie | Clients concernés |
|---|---|
| Email vide | 10011, 10013, 10022 |
| Email non normalisé (majuscules, espaces) | 10005, 10009, 10010 |
| Téléphone vide | 10012 |
| Téléphone mal formaté (espaces, tirets, +33) | 10002, 10005, 10007, 10008 |
| Code postal invalide | 10005, 10014, 10015 |
| Date de naissance incohérente (2021 ou 1867) | 10016, 10017 |
| Prénom vide (prénom inclus dans le nom) | 10018, 10019 |

Autres constats sur les clients :
- 1 doublon d'identité : Marie Dupont (10004 et 10005). Les deux emails sont différents, donc la recherche
  de doublons par email ne le trouve pas. Il est détecté sur le nom, le prénom et la date de naissance.
- 5 clients sans commande (10012, 10016, 10017, 10018, 10019).

### Produits
- 2 prix aberrants : Morphine 10mg à 0,01 euro et Doliprane Enfant à 125,00 euros
  (seuils choisis : moins de 1 euro ou plus de 100 euros).
- 2 stocks négatifs : Ciprofloxacine 500mg (-5) et Loratadine 10mg (-12).
- 13 produits périmés au 02/11/2026, dont Pénicilline V (2019) et Pommade Cicatrisante (2024).
  Ce chiffre dépend de la date d'exécution (`CURRENT_DATE`).

### Intégrité référentielle et montants
- 1 commande orpheline : 50019, rattachée à un client 99999 qui n'existe pas.
- 1 ligne orpheline : 70039, rattachée à un produit 9999 qui n'existe pas (même commande 50019).
- 1 commande dont le total diffère de la somme de ses lignes : 50011 (95,00 contre 89,25, écart de 5,75).
- 17 lignes de commande dont le prix ne vaut pas quantité x prix unitaire.

### Effet du nettoyage
- 22 emails traités, 2 codes postaux corrigés (34OOO devient 34000, 69OO2 devient 69002).
- Le doublon 10005 est supprimé et sa commande 50006 est rattachée à 10004.
  Sans ce rattachement, la suppression aurait créé une nouvelle commande orpheline.
- `client_contact` contient 24 clients. Les valeurs vides d'origine (3 emails, 1 téléphone) restent vides.

## Limites
- Les produits, commandes et lignes sont diagnostiqués mais pas corrigés : décider du bon prix ou du bon
  stock demande une règle métier ou une source que la base ne fournit pas.
- Le code postal 750015 n'est pas corrigé automatiquement (6 chiffres, on ne devine pas). Il disparaît
  avec la suppression du doublon.
- Les seuils (prix, 16 ans) sont des choix d'analyse, pas des règles officielles.
- Suite possible : clés étrangères et contraintes `CHECK` (prix positif, stock positif, format du code
  postal) pour bloquer ces erreurs à la saisie.

## Utilisation
1. Créer une base PostgreSQL nommée `MediCarePlus` et s'y connecter.
2. Exécuter `medicareplus.sql` (création des tables et des données).
3. Exécuter `traitement_medicareplus.sql`.

## Stack technique
SQL | PostgreSQL

Dernière mise à jour : 02/11/2026
