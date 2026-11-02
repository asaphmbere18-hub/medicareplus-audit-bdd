-- =====================================================================
-- TRAITEMENT MEDICAREPLUS : audit qualité, nettoyage et normalisation
-- SGBD : PostgreSQL (exécuter dans la base MediCarePlus, après medicareplus.sql)
--
-- Ce que fait le script, en 3 parties :
--   Partie 1 : diagnostic. 12 contrôles en lecture seule (aucune donnée modifiée).
--   Partie 2 : nettoyage des clients, dans une transaction (emails, codes postaux, doublon).
--   Partie 3 : création de la table client_contact avec les contacts nettoyés.
-- Le script peut être relancé plusieurs fois : la première ligne supprime l'ancienne table.
-- =====================================================================

-- Supprime la table client_contact si elle existe, pour pouvoir relancer le script sans erreur.
DROP TABLE IF EXISTS client_contact;

-- ============ PARTIE 1 : DIAGNOSTIC ET DONNÉES DE BASE ============

-- 1.1 Taille des tables
SELECT 'clients' AS MedicCarePlus,COUNT(*) AS total
FROM clients
UNION ALL SELECT'produits', COUNT(*)
FROM produits
UNION ALL SELECT 'commandes', COUNT(*)
FROM commandes
UNION ALL SELECT 'lignes_commande', COUNT(*)
FROM lignes_commande;
-- Ce que fait le script : compte les lignes des 4 tables et les affiche dans un seul tableau.
-- Ligne par ligne :
--   SELECT 'clients' AS MedicCarePlus, COUNT(*) AS total : écrit le nom de la table dans la colonne
--     MedicCarePlus et le nombre de lignes de clients dans la colonne total.
--   UNION ALL SELECT ... : empile un résultat identique pour produits, commandes et lignes_commande.
-- Résultat attendu : clients 25, produits 20, commandes 21, lignes_commande 44.

-- 1.2 Valeurs manquantes
SELECT
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 end)
as sans_email,
    SUM(CASE WHEN telephone IS NULL THEN 1 ELSE 0 end)
as sans_telephone,
    SUM(CASE WHEN code_postal IS NULL THEN 1 ELSE 0 end)
as sans_code_postal
FROM clients;
-- Ce que fait le script : compte les valeurs vides (NULL) dans trois colonnes de clients.
-- Ligne par ligne :
--   CASE WHEN email IS NULL THEN 1 ELSE 0 : donne 1 si l'email est vide, 0 sinon.
--   SUM(...) : additionne ces 1, donc donne le nombre d'emails vides.
--   as sans_email / sans_telephone / sans_code_postal : noms des colonnes du résultat.
-- Résultat attendu : 3 emails vides, 1 téléphone vide, 0 code postal vide.

-- 1.3 Doublons simples (email)
SELECT email, COUNT(*) AS doublons
FROM clients
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
-- Ce que fait le script : cherche les emails qui apparaissent plus d'une fois.
-- Ligne par ligne :
--   WHERE email IS NOT NULL : ignore les emails vides.
--   GROUP BY email : regroupe les clients qui ont le même email.
--   HAVING COUNT(*) > 1 : ne garde que les groupes de plus d'une ligne, donc les doublons.
-- Résultat attendu : aucune ligne. Marie Dupont a deux emails différents, donc cette requête ne
-- la trouve pas. C'est pour cela que la requête suivante cherche sur l'identité.

SELECT LOWER(nom_complet) AS nom, LOWER(prenom) AS prenom, date_naissance, COUNT(*) AS nb,
       MIN(id_client) AS a_garder, MAX(id_client) AS a_supprimer
FROM clients
GROUP BY 1, 2, 3
HAVING COUNT(*) > 1;
-- Ce que fait le script : cherche les doublons sur l'identité (nom, prénom, date de naissance).
-- Ligne par ligne :
--   LOWER(...) : met en minuscules pour que 'DUPONT' et 'Dupont' soient vus comme identiques.
--   GROUP BY 1, 2, 3 : regroupe par nom, prénom et date de naissance (colonnes 1, 2 et 3 du SELECT).
--   HAVING COUNT(*) > 1 : garde les groupes qui ont au moins 2 clients.
--   MIN(id_client) / MAX(id_client) : l'identifiant à garder et celui à supprimer.
-- Résultat attendu : dupont, marie, 1992-05-18, 2 lignes, on garde 10004 et on supprime 10005.

-- 1.4 Clients sans commande
SELECT c.id_client, c.nom_complet, c.prenom
FROM clients c
LEFT JOIN commandes co ON c.id_client = co.id_client
WHERE co.id_commande IS NULL;
-- Ce que fait le script : liste les clients qui n'ont passé aucune commande.
-- Ligne par ligne :
--   FROM clients c : table de départ, avec l'alias c.
--   LEFT JOIN commandes co ON c.id_client = co.id_client : rattache à chaque client ses commandes,
--     et garde le client même s'il n'en a aucune (les colonnes de co sont alors vides).
--   WHERE co.id_commande IS NULL : ne garde que les clients sans commande rattachée.
-- Résultat attendu : 5 clients (10012, 10016, 10017, 10018, 10019).

-- 1.5 Incohérences de montant commande
SELECT
    co.id_commande,
    co.montant_total,
    SUM(l.prix_ligne) as somme_ligne,
    (co.montant_total - SUM(l.prix_ligne)) AS ecart
FROM commandes co
JOIN lignes_commande l ON co.id_commande = l.id_commande
GROUP BY co.id_commande, co.montant_total
HAVING co.montant_total <> SUM(l.prix_ligne);
-- Ce que fait le script : trouve les commandes dont le total ne correspond pas à la somme de leurs lignes.
-- Ligne par ligne :
--   JOIN lignes_commande l ON ... : rattache à chaque commande ses lignes.
--   SUM(l.prix_ligne) : additionne les prix des lignes d'une commande.
--   ecart : montant_total moins cette somme.
--   GROUP BY : une ligne de résultat par commande.
--   HAVING co.montant_total <> SUM(l.prix_ligne) : ne garde que les commandes où les deux diffèrent.
-- Résultat attendu : la commande 50011 (95,00 contre 89,25, écart 5,75).

-- 1.6 Prix aberrants
SELECT id_produit, nom_produit, prix_unitaire
FROM produits
WHERE prix_unitaire < 1 OR prix_unitaire > 100;
-- Ce que fait le script : liste les produits dont le prix est anormalement bas ou haut.
-- Ligne par ligne :
--   WHERE prix_unitaire < 1 OR prix_unitaire > 100 : prix inférieur à 1 euro ou supérieur à 100 euros.
-- Les seuils 1 et 100 sont un choix d'analyse, pas une règle officielle.
-- Résultat attendu : Morphine 10mg à 0,01 et Doliprane Enfant à 125,00.

-- 1.7 Date de naissance
SELECT id_client, nom_complet, prenom, date_naissance
FROM clients
WHERE date_naissance < '1900-01-01' OR date_naissance > date_inscription - INTERVAL '16 years';
-- Ce que fait le script : repère les dates de naissance impossibles ou celles d'un client trop jeune.
-- Ligne par ligne :
--   date_naissance < '1900-01-01' : né avant 1900, donc impossible.
--   date_naissance > date_inscription - INTERVAL '16 years' : né moins de 16 ans avant son inscription.
-- Résultat attendu : 10016 (né en 2021) et 10017 (né en 1867).

-- 1.8 Stocks négatifs
SELECT id_produit, nom_produit, stock_disponible
FROM produits
WHERE stock_disponible < 0;
-- Ce que fait le script : liste les produits dont le stock est négatif, ce qui est impossible.
-- Résultat attendu : Ciprofloxacine 500mg (-5) et Loratadine 10mg (-12).

-- 1.9 Produits périmés
SELECT id_produit, nom_produit, date_peremption
FROM produits
WHERE date_peremption < CURRENT_DATE;
-- Ce que fait le script : liste les produits dont la date de péremption est dépassée.
-- Ligne par ligne :
--   CURRENT_DATE : la date du jour d'exécution. Le résultat change donc chaque jour.
-- Résultat attendu : 13 produits au 02/11/2026 (12 au 30/10/2026, la Cétirizine a expiré le 30/10).

-- 1.10 Commandes avec prix de lignes incohérentes
SELECT l.id_commande, l.id_produit, l.prix_ligne, p.prix_unitaire
FROM lignes_commande AS l
JOIN produits AS p
ON l.id_produit = p.id_produit
WHERE l.prix_ligne <> p.prix_unitaire * l.quantite;
-- Ce que fait le script : trouve les lignes de commande dont le prix ne vaut pas quantité x prix unitaire.
-- Ligne par ligne :
--   JOIN produits AS p ON l.id_produit = p.id_produit : rattache chaque ligne à son produit.
--   WHERE l.prix_ligne <> p.prix_unitaire * l.quantite : garde celles où le prix enregistré diffère
--     du prix calculé.
-- Résultat attendu : 17 lignes.

-- 1.11 Commandes orphelines
SELECT co.id_commande, co.id_client
FROM commandes AS co
LEFT JOIN clients AS c ON co.id_client = c.id_client
WHERE c.id_client IS NULL;
-- Ce que fait le script : trouve les commandes dont le client n'existe pas dans la table clients.
-- Ligne par ligne :
--   LEFT JOIN clients AS c ON ... : tente de rattacher chaque commande à son client.
--   WHERE c.id_client IS NULL : garde les commandes sans client trouvé.
-- Résultat attendu : la commande 50019 (client 99999 inexistant).

-- 1.12 Lignes orphelines
SELECT l.id_commande, l.id_produit, l.id_ligne
FROM lignes_commande AS l
LEFT JOIN produits AS p ON l.id_produit = p.id_produit
WHERE p.id_produit IS NULL;
-- Ce que fait le script : trouve les lignes de commande dont le produit n'existe pas dans produits.
-- Résultat attendu : la ligne 70039 (commande 50019, produit 9999 inexistant).
-- La commande 50019 cumule donc deux anomalies : un client et un produit inexistants.

-- ============ PARTIE 2 : NETTOYAGE DES DONNÉES ============
-- Tout ce qui suit est exécuté dans une transaction : BEGIN ouvre la transaction, COMMIT la valide.
-- Si une instruction échoue, rien n'est enregistré et la base reste dans son état de départ.
BEGIN;

-- 2.1 Normalisation des emails
SELECT email
FROM clients;
UPDATE clients
SET email = LOWER(TRIM(email))
WHERE email IS NOT NULL;
SELECT email
FROM clients;
-- Ce que fait le script : met les emails en minuscules et retire les espaces autour.
-- Ligne par ligne :
--   Le premier SELECT affiche les emails avant, le dernier SELECT les affiche après, pour comparer.
--   SET email = LOWER(TRIM(email)) : TRIM retire les espaces au début et à la fin, LOWER met en minuscules.
--   WHERE email IS NOT NULL : ne touche pas aux emails vides.
-- Résultat attendu : UPDATE 22 (22 emails traités, les 3 vides sont ignorés).

-- 2.2 Normalisation des codes postaux
SELECT code_postal
FROM clients;
UPDATE clients
SET code_postal = REPLACE(code_postal, 'O', '0')
WHERE code_postal IS NOT NULL;

SELECT id_client, code_postal
FROM clients
WHERE code_postal !~ '^[0-9]{5}$';
-- Ce que fait le script : remplace la lettre O par le chiffre 0 dans les codes postaux, puis vérifie le résultat.
-- Ligne par ligne :
--   REPLACE(code_postal, 'O', '0') : remplace chaque lettre O par un zéro (34OOO devient 34000).
--   WHERE code_postal !~ '^[0-9]{5}$' : liste les codes qui ne sont pas exactement 5 chiffres.
--     !~ veut dire "ne correspond pas au motif", ^ et $ marquent le début et la fin du code.
-- Il reste un code invalide : 750015 (client 10005, 6 chiffres). On ne devine pas un code postal.
-- Ce client est le doublon supprimé à l'étape suivante, donc le problème disparaît avec lui.

-- 2.3 Fusion des doublons d'identité
UPDATE commandes co SET id_client = d.id_client
FROM clients c
JOIN clients d ON LOWER(c.nom_complet) = LOWER(d.nom_complet)
 AND LOWER(c.prenom) = LOWER(d.prenom)
 AND c.date_naissance = d.date_naissance
 AND c.id_client > d.id_client
WHERE co.id_client = c.id_client;
-- Ce que fait le script : rattache les commandes du doublon au client conservé.
-- Ligne par ligne :
--   c est le doublon, d est le client à garder (même nom, prénom et naissance, identifiant plus petit).
--   SET id_client = d.id_client : la commande passe au client conservé.
--   WHERE co.id_client = c.id_client : ne concerne que les commandes du doublon.
-- Pourquoi avant le DELETE : sans cela, la commande 50006 resterait rattachée à un client supprimé
-- et deviendrait une commande orpheline. Résultat attendu : UPDATE 1.

DELETE FROM clients c
USING clients d
WHERE LOWER(c.nom_complet) = LOWER(d.nom_complet)
  AND LOWER(c.prenom) = LOWER(d.prenom)
  AND c.date_naissance = d.date_naissance
  AND c.id_client > d.id_client;
-- Ce que fait le script : supprime les doublons en gardant le plus petit id_client pour un même nom,
-- prénom et date de naissance.
-- Ligne par ligne :
--   DELETE FROM clients c USING clients d : compare la table clients avec elle-même (c contre d).
--   WHERE LOWER(c.nom_complet) = LOWER(d.nom_complet) AND ... : même personne, sans tenir compte des majuscules.
--   AND c.id_client > d.id_client : on supprime celui dont l'identifiant est le plus grand.
-- Résultat attendu : DELETE 1 (10005 supprimé, 10004 conservé). Il reste 24 clients.
SELECT* FROM clients;
-- Ce SELECT affiche la table clients après nettoyage pour vérifier le résultat.

-- ============ PARTIE 3 : NORMALISATION DES DONNÉES ============

-- 3.1 Création et alimentation d'une table de contact nettoyée
CREATE TABLE client_contact(
    id_client INT PRIMARY KEY,
    email_clean VARCHAR(255),
    telephone_clean VARCHAR(20),
    code_postal_clean VARCHAR(5)
);
-- Ce que fait le script : crée la table client_contact qui recevra les contacts nettoyés.
-- Ligne par ligne :
--   id_client INT PRIMARY KEY : identifiant du client, unique et obligatoire.
--   email_clean, telephone_clean, code_postal_clean : les trois informations de contact nettoyées.
--   VARCHAR(5) pour le code postal : 5 caractères maximum, ce qui bloque les codes à 6 chiffres.

INSERT INTO client_contact (id_client, email_clean, telephone_clean, code_postal_clean)
SELECT
    id_client,
    email,
    REGEXP_REPLACE(REGEXP_REPLACE(telephone, '[ .-]', '', 'g'), '^\+33', '0'),
    code_postal
FROM clients;
-- Ce que fait le script : remplit client_contact avec les données de clients.
-- Ligne par ligne :
--   INSERT INTO client_contact (...) : indique les colonnes à remplir, dans cet ordre.
--   id_client, email, code_postal : recopiés tels quels, car déjà nettoyés en partie 2.
--   REGEXP_REPLACE(telephone, '[ .-]', '', 'g') : supprime tous les espaces, points et tirets
--     ('g' veut dire "partout dans le texte").
--   REGEXP_REPLACE(..., '^\+33', '0') : si le numéro commence par +33, remplace ce début par 0.
-- Résultat attendu : INSERT 0 24, tous les téléphones au format 0XXXXXXXXX.
-- Les valeurs vides d'origine (3 emails, 1 téléphone) restent vides : elles ne sont pas inventées.
COMMIT;
-- COMMIT valide la transaction ouverte par BEGIN : toutes les modifications des parties 2 et 3 sont enregistrées.

SELECT * FROM client_contact;
-- Ce SELECT affiche la table client_contact finale : 24 clients avec email, téléphone et code postal propres.
