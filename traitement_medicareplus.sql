USE MediCarePlus;
-- Partie 1 Diagnostic et Données de Base
-- 1.1 Taille des tables


SELECT 'clients' AS MedicCarePlus,COUNT(*) AS total
FROM clients
UNION ALL SELECT'produtis', COUNT(*)
FROM produits
UNION ALL SELECT 'commandes', COUNT(*)
FROM commandes
UNION ALL SELECT 'lignes_commande', COUNT(*)
FROM lignes_commande;

-- Ici, nous disons pour les tables clients, produits, commandes et lignes_commande, de la base de données MediCarePlus,
-- comptent les lignes puis affiches les dans la colonne total avec le nom de la table dans la colonne MedicCarePlus.
-- 1.2 Valeurs manquantes
SELECT
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 end)
as sans_email,
    SUM(CASE WHEN telephone IS NULL THEN 1 ELSE 0 end)
as sans_telephone,
    SUM(CASE WHEN code_postal IS NULL THEN 1 ELSE 0 end)
as sans_code_postal
FROM clients;
-- Cette requete dit compte le nombre de valeurs nulles dans les colonnes email, telephone et code_postal de la table clients
-- et affiche les resultats dans les colonnes sans_email, sans_telephone et sans_code_postal.

-- 1.3 Dpublons simples(email)

SELECT email, COUNT(*) AS doublons
FROM clients
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 2;
-- cette requete dit pour la table clients, groupe les enregistrements par email (en ignorant les valeurs nulles),
-- compte le nombre d'occurrences de chaque email et affiche ceux qui apparaissent plus de deux fois avec le nombre d'occurrences dans la colonne doublons.

-- 1.4 Clients sans commande
SELECT c.id_client, c.nom_complet, c.prenom
FROM clients c
LEFT JOIN commandes co ON c.id_client = co.id_client
WHERE co.id_commande IS NULL;
-- Cette requete dit pour la table clients (alias c), effectue une jointure gauche avec la table commandes (alias co)
-- en utilisant id_client comme clé de jointure. Elle sélectionne les clients qui n'ont pas de commande associée
-- (c'est-à-dire où id_commande est NULL dans la table commandes) et affiche leurs id_client, nom_complet et prenom.

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
-- Cette requete dit pour la table commandes (alias co), effectue une jointure avec la table lignes_commande (alias l)
-- en utilisant id_commande comme clé de jointure. Elle groupe les résultats par id_commande et montant_total,
-- calcule la somme des prix_ligne pour chaque commande, et affiche celles où le montant_total ne correspond pas à la somme des prix_ligne,
-- en montrant l'écart dans la colonne ecart.

-- Partie 2 : Nettoyage des Données

-- 2.1 Normalisation des emails
SELECT email
FROM clients;
UPDATE clients
SET email = LOWER(TRIM(RTRIM(email)))
WHERE email IS NOT NULL;
-- Cette requete met à jour la table clients en normalisant les adresses email.
-- Elle convertit toutes les adresses email en minuscules et supprime les espaces inutiles avant et après l'adresse email
-- pour toutes les entrées où l'email n'est pas NULL.
SELECT email
FROM clients;
-- 2.2 Normalisation des codes postaux
SELECT code_postal
FROM clients;
UPDATE clients
SET code_postal = LPAD(REPLACE(REPLACE(code_postal, 'O', '0'), ' ', ''),5,'0')
WHERE code_postal IS NOT NULL;
-- Cette requete met à jour la table clients en normalisant les codes postaux.
-- Elle remplace les lettres 'O' par des zéros '0', supprime les espaces, et s'assure que chaque code postal fait exactement 5 caractères en ajoutant des zéros au début si nécessaire,
-- pour toutes les entrées où le code_postal n'est pas NULL.
SELECT code_postal
FROM clients;
-- 2.3 Suppression des doublons emails

SELECT* FROM clients;
DELETE FROM clients
WHERE id_client not in (
    SELECT MIN(id_client)
    FROM clients
    WHERE email IS NOT NULL
    GROUP BY email
) AND email IS NOT NULL;
-- Cette requete supprime les doublons dans la table clients en conservant uniquement l'enregistrement avec le plus petit id_client pour chaque adresse email non nulle.
SELECT* FROM clients;
-- Partie 3 Normalisation des Données

-- 3.1 Création et alimentation d'une table de contact nettoyée

CREATE Table client_contact(
    id_client INT PRIMARY KEY,
    email_clean VARCHAR(255),
    telephone_clean VARCHAR(20),
    code_postal_clean VARCHAR(5)
);
-- -- Création d'une nouvelle table client_contact pour stocker les informations de contact nettoyées.
-- Inséretion des données nettoyées
INSERT INTO client_contact (id_client, email_clean, telephone_clean, code_postal_clean)
SELECT
    id_client,
    LOWER(TRIM(RTRIM(email))),
    REPLACE(REPLACE(telephone, ' ', ''), '-', ''),
    LPAD(REPLACE(REPLACE(code_postal, 'O', '0'), ' ', ''),5,'0')
FROM clients;
-- Cette requete insère dans la table client_contact les données nettoyées provenant de la table clients.
-- Elle normalise les adresses email, nettoie les numéros de téléphone en supprimant les espaces et les tirets,
-- et normalise les codes postaux en remplaçant les 'O' par des '0', en supprimant les espaces, et en s'assurant qu'ils font 5 caractères.
SELECT * FROM client_contact;
