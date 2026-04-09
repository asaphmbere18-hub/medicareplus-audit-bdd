-- =====================================================
-- BASE DE DONN�ES : M�diCare+ (avec anomalies int�gr�es)
-- Examen : Qualit� et Nettoyage de Donn�es SQL
-- Version PostgreSQL
-- =====================================================

-- Suppression des tables si elles existent (avec CASCADE pour les contraintes)
DROP TABLE IF EXISTS lignes_commande CASCADE;
DROP TABLE IF EXISTS commandes CASCADE;
DROP TABLE IF EXISTS produits CASCADE;
DROP TABLE IF EXISTS clients CASCADE;

-- =====================================================
-- TABLE : clients
-- =====================================================
CREATE TABLE clients (
    id_client INTEGER PRIMARY KEY,
    nom_complet VARCHAR(100),
    prenom VARCHAR(50),
    telephone VARCHAR(20),
    email VARCHAR(100),
    date_naissance DATE,
    date_inscription DATE,
    ville VARCHAR(50),
    code_postal VARCHAR(10)
);

INSERT INTO clients VALUES
-- Clients normaux
(10001, 'Martin', 'Sophie', '0612345678', 'sophie.martin@gmail.com', '1985-03-15', '2022-01-10', 'Paris', '75015'),
(10002, 'Bernard', 'Lucas', '06 23 45 67 89', 'lucas.bernard@yahoo.fr', '1990-07-22', '2022-02-15', 'Lyon', '69002'),
(10003, 'Dubois', 'Emma', '0634567890', 'emma.dubois@hotmail.com', '1978-11-30', '2022-03-20', 'Marseille', '13001'),
(10004, 'Dupont', 'Marie', '0645678901', 'marie.dupont@gmail.com', '1992-05-18', '2022-04-05', 'Paris', '75015'),
(10005, 'DUPONT', 'MARIE', '06 45 67 89 01', 'Marie@Gmail.com', '1992-05-18', '2022-04-05', 'Paris', '750015'),
(10006, 'Dupont', 'Marie', '0656789012', 'marie.dupont69@gmail.com', '1988-09-25', '2022-05-10', 'Lyon', '69002'),
(10007, 'Petit', 'Antoine', '+33667890123', 'antoine.petit@free.fr', '1995-12-08', '2022-06-12', 'Toulouse', '31000'),
(10008, 'Roux', 'Claire', '06-78-90-12-34', 'claire.roux@orange.fr', '1982-02-14', '2022-07-18', 'Nice', '06000'),
(10009, 'Moreau', 'Thomas', '0689012345', ' thomas.moreau@gmail.com', '1987-08-20', '2022-08-22', 'Nantes', '44000'),
(10010, 'Simon', 'Julie', '0690123456', 'Julie.Simon@Gmail.Com ', '1993-04-12', '2022-09-25', 'Strasbourg', '67000'),
(10011, 'Laurent', 'Pierre', '0601234567', NULL, '1980-06-05', '2022-10-15', 'Bordeaux', '33000'),
(10012, 'Michel', 'Isabelle', NULL, 'isabelle.michel@wanadoo.fr', '1975-01-28', '2022-11-20', 'Lille', '59000'),
(10013, 'Leroy', 'Alexandre', '0612345679', NULL, '1991-10-10', '2022-12-05', 'Rennes', '35000'),
(10014, 'Garcia', 'Camille', '0623456780', 'camille.garcia@gmail.com', '1989-03-17', '2023-01-08', 'Montpellier', '34OOO'),
(10015, 'Rodriguez', 'Nathan', '0634567891', 'nathan.rodriguez@yahoo.fr', '1994-07-30', '2023-02-12', 'Lyon', '69OO2'),
(10016, 'Fontaine', 'Louise', '0645678902', 'louise.fontaine@hotmail.fr', '2021-05-15', '2023-03-10', 'Paris', '75008'),
(10017, 'Chevalier', 'Robert', '0656789013', 'robert.chevalier@orange.fr', '1867-12-25', '2023-03-15', 'Marseille', '13008'),
(10018, 'Blanc Jean-Pierre', NULL, '0667890124', 'jp.blanc@free.fr', '1983-09-08', '2023-04-01', 'Grenoble', '38000'),
(10019, 'Girard Sophie-Anne', NULL, '0678901235', 'sophie.girard@gmail.com', '1986-11-22', '2023-04-15', 'Dijon', '21000'),
(10247, 'Fabre', 'Julien', '0689012346', 'julien.fabre@yahoo.fr', '1990-02-18', '2023-06-15', 'Reims', '51100'),
(10020, 'Muller', 'L�a', '0690123457', 'lea.muller@gmail.com', '1992-06-14', '2023-05-01', 'Angers', '49000'),
(10021, 'Lefebvre', 'Hugo', '0601234568', 'hugo.lefebvre@hotmail.com', '1988-08-25', '2023-05-10', 'Caen', '14000'),
(10022, 'Lambert', 'Chlo�', '0612345680', NULL, '1995-12-30', '2023-05-20', 'Tours', '37000'),
(10023, 'Bonnet', 'Maxime', '0623456781', 'maxime.bonnet@free.fr', '1984-04-08', '2023-06-01', 'Clermont-Ferrand', '63000'),
(10024, 'Francois', 'Sarah', '0634567892', 'sarah.francois@orange.fr', '1991-09-12', '2023-06-10', 'Limoges', '87000');

-- =====================================================
-- TABLE : produits
-- =====================================================
CREATE TABLE produits (
    id_produit INTEGER PRIMARY KEY,
    nom_produit VARCHAR(100),
    prix_unitaire NUMERIC(10,2),
    categorie VARCHAR(50),
    stock_disponible INTEGER,
    date_peremption DATE
);

INSERT INTO produits VALUES
-- Cat�gorie : Antidouleurs (prix normaux entre 5-15�)
(1001, 'Parac�tamol 1g', 8.50, 'Antidouleurs', 250, '2026-12-31'),
(1002, 'Ibuprof�ne 400mg', 12.00, 'Antidouleurs', 180, '2026-08-15'),
(1003, 'Aspirine 500mg', 6.75, 'Antidouleurs', 320, '2025-10-20'),
(1004, 'Morphine 10mg', 0.01, 'Antidouleurs', 45, '2026-03-10'),
(1005, 'Doliprane Enfant', 125.00, 'Antidouleurs', 90, '2026-05-18'),

-- Cat�gorie : Antibiotiques (prix normaux entre 15-35�)
(2001, 'Amoxicilline 1g', 22.50, 'Antibiotiques', 120, '2026-11-30'),
(2002, 'Azithromycine 500mg', 28.00, 'Antibiotiques', 85, '2026-07-25'),
(2003, 'Ciprofloxacine 500mg', 31.50, 'Antibiotiques', -5, '2026-09-12'),
(2004, 'P�nicilline V', 18.75, 'Antibiotiques', 30, '2019-06-15'),

-- Cat�gorie : Vitamines (prix normaux entre 8-20�)
(3001, 'Vitamine C 1000mg', 12.90, 'Vitamines', 200, '2027-01-31'),
(3002, 'Vitamine D 2000UI', 15.50, 'Vitamines', 150, '2026-12-15'),
(3003, 'Multivitamines', 2.10, 'Vitamines', 180, '2026-08-20'),

-- Cat�gorie : Antihistaminiques (prix normaux entre 10-18�)
(4001, 'C�tirizine 10mg', 14.20, 'Antihistaminiques', 140, '2026-10-30'),
(4002, 'Loratadine 10mg', 11.80, 'Antihistaminiques', -12, '2026-06-18'),

-- Cat�gorie : Dermatologie (prix normaux entre 12-25�)
(5001, 'Cr�me Hydratante', 18.50, 'Dermatologie', 95, '2025-12-31'),
(5002, 'Pommade Cicatrisante', 21.00, 'Dermatologie', 40, '2024-03-15'),

-- Produits normaux 
(6001, 'Sirop Toux S�che', 13.75, 'Respiratoire', 110, '2026-09-30'),
(6002, 'Spray Nasal', 16.20, 'Respiratoire', 88, '2026-11-20'),
(7001, 'Compresses St�riles', 8.90, 'Mat�riel', 300, '2028-12-31'),
(7002, 'Bandages �lastiques', 11.50, 'Mat�riel', 220, '2028-06-30');

-- =====================================================
-- TABLE : commandes
-- =====================================================
CREATE TABLE commandes (
    id_commande INTEGER PRIMARY KEY,
    id_client INTEGER,
    date_commande DATE,
    montant_total NUMERIC(10,2),
    statut VARCHAR(20),
    pharmacie_origine VARCHAR(50)
);

INSERT INTO commandes VALUES
(50001, 10001, '2023-02-15', 25.50, 'Valid�e', 'Pharmacie Centre'),
(50002, 10002, '2023-03-20', 42.00, 'Valid�e', 'Pharmacie Nord'),
(50003, 10003, '2023-04-12', 18.75, 'Valid�e', 'Pharmacie Sud'),
(50004, 10247, '2023-04-10', 65.25, 'Valid�e', 'Pharmacie Centre'),
(50005, 10004, '2023-05-08', 31.50, 'Valid�e', 'Pharmacie Centre'),
(50006, 10005, '2023-05-15', 22.00, 'Valid�e', 'Pharmacie Centre'),
(50007, 10006, '2023-06-01', 48.90, 'Valid�e', 'Pharmacie Nord'),
(50008, 10007, '2023-06-18', 55.75, 'Valid�e', 'Pharmacie Sud'),
(50009, 10008, '2023-07-22', 28.40, 'Valid�e', 'Pharmacie Centre'),
(50010, 10009, '2023-08-30', 73.20, 'Valid�e', 'Pharmacie Nord'),
(50011, 10010, '2023-09-12', 95.00, 'Valid�e', 'Pharmacie Sud'),
(50012, 10011, '2023-10-05', 44.50, 'Valid�e', 'Pharmacie Centre'),
(50013, 10013, '2023-11-18', 32.80, 'Valid�e', 'Pharmacie Nord'),
(50014, 10014, '2024-11-20', 38.75, 'Valid�e', 'Pharmacie Sud'),
(50015, 10015, '2023-12-10', 51.60, 'Valid�e', 'Pharmacie Centre'),
(50016, 10020, '2024-01-15', 29.30, 'Valid�e', 'Pharmacie Nord'),
(50017, 10021, '2024-02-20', 67.85, 'Valid�e', 'Pharmacie Sud'),
(50018, 10023, '2024-03-25', 41.20, 'Valid�e', 'Pharmacie Centre'),
(50019, 99999, '2024-04-10', 25.00, 'Valid�e', 'Pharmacie Nord'),
(50020, 10024, '2024-05-05', 19.90, 'En attente', 'Pharmacie Sud'),
(50021, 10022, '2024-06-12', 88.50, 'Annul�e', 'Pharmacie Centre');

-- =====================================================
-- TABLE : lignes_commande
-- =====================================================
CREATE TABLE lignes_commande (
    id_ligne INTEGER PRIMARY KEY,
    id_commande INTEGER,
    id_produit INTEGER,
    quantite INTEGER,
    prix_ligne NUMERIC(10,2)
);

INSERT INTO lignes_commande VALUES
(70001, 50001, 1001, 2, 17.00),
(70002, 50001, 1003, 1, 8.50),
(70003, 50002, 2001, 1, 22.50),
(70004, 50002, 3001, 1, 12.90),
(70005, 50002, 1001, 1, 6.60),
(70006, 50003, 2004, 1, 18.75),
(70007, 50004, 2001, 2, 45.00),
(70008, 50004, 4001, 1, 14.20),
(70009, 50004, 1003, 1, 6.05),
(70010, 50005, 2003, 1, 31.50),
(70011, 50006, 3002, 1, 15.50),
(70012, 50006, 1003, 1, 6.50),
(70013, 50007, 5001, 2, 37.00),
(70014, 50007, 3001, 1, 11.90),
(70015, 50008, 2002, 2, 56.00),
(70016, 50008, 1002, 0, -0.25),
(70017, 50009, 4001, 2, 28.40),
(70018, 50010, 2001, 2, 45.00),
(70019, 50010, 3002, 1, 15.50),
(70020, 50010, 1002, 1, 12.70),
(70021, 50011, 5001, 3, 55.50),
(70022, 50011, 3001, 2, 25.80),
(70023, 50011, 1001, 1, 7.95),
(70024, 50012, 2002, 1, 28.00),
(70025, 50012, 3002, 1, 16.50),
(70026, 50013, 4001, 2, 28.40),
(70027, 50013, 1003, 1, 4.40),
(70028, 50014, 2004, 2, 37.50),
(70029, 50014, 1001, 1, 1.25),
(70030, 50015, 6001, 3, 41.25),
(70031, 50015, 1002, 1, 10.35),
(70032, 50016, 3001, 2, 25.80),
(70033, 50016, 1003, 1, 3.50),
(70034, 50017, 2001, 2, 45.00),
(70035, 50017, 5001, 1, 18.50),
(70036, 50017, 1003, 1, 4.35),
(70037, 50018, 6002, 2, 32.40),
(70038, 50018, 1001, 1, 8.80),
(70039, 50019, 9999, 1, 25.00),
(70040, 50020, 7001, 2, 17.80),
(70041, 50020, 1003, 1, 2.10),
(70042, 50021, 2002, 2, 56.00),
(70043, 50021, 3002, 2, 31.00),
(70044, 50021, 1001, 1, 1.50);

-- =====================================================
-- V�RIFICATIONS RAPIDES
-- =====================================================
-- D�commentez ces requ�tes pour v�rifier les donn�es

-- SELECT COUNT(*) AS total_clients FROM clients;
-- SELECT COUNT(*) AS total_produits FROM produits;
-- SELECT COUNT(*) AS total_commandes FROM commandes;
-- SELECT COUNT(*) AS total_lignes FROM lignes_commande;

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================
