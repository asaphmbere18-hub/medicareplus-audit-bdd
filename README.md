# Audit et Normalisation de Base de Données — MediCarePlus

## Contexte
Diagnostic qualité et nettoyage d'une base de données pharmaceutique 
simulant le système de gestion d'une chaîne de pharmacies.

## Structure de la Base
| Table | Lignes |
|---|---|
| clients | 24 |
| produits | 20 |
| commandes | 21 |
| lignes_commande | 44 |

## Anomalies Détectées et Corrigées

### Clients
- 3 emails NULL, 3 téléphones NULL
- Emails non normalisés (majuscules, espaces) → normalisés via LOWER + TRIM
- 1 doublon identifié (Marie Dupont — id 10004/10005) → supprimé
- Codes postaux corrompus : lettres 'O' à la place de '0', longueur incorrecte
  → corrigés via REPLACE + LPAD
- 2 dates de naissance incohérentes : client né en 2021 (mineur) 
  et client né en 1867

### Produits
- 2 prix aberrants : Morphine 10mg à 0.01€ | Doliprane Enfant à 125.00€
- 2 stocks négatifs : Ciprofloxacine (-5) | Loratadine (-12)
- 2 produits périmés en base active : Pénicilline V (2019) | 
  Pommade Cicatrisante (2024)

### Intégrité Référentielle
- 1 commande orpheline : id_client 99999 inexistant
- 1 ligne de commande orpheline : id_produit 9999 inexistant
- 9 commandes avec écart entre montant_total et somme des lignes

## Actions de Nettoyage
- Normalisation emails, téléphones, codes postaux
- Suppression doublons par conservation du MIN(id_client)
- Création table `client_contact` avec données nettoyées
- Détection des incohérences de montants par jointure agrégée

## Stack Technique
SQL | PostgreSQL | pgAdmin 4
