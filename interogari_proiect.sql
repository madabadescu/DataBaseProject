--CERINTA 11

--SUBCERERE NESINCRONIZATA, 4 tabele in join, NVL, TO_CHAR(date, 'DAY')
--1. Sa se afiseze ora de incepere a finalelor si id-ul premiilor intai, 
--din categoriile unde perechea de pe primul loc a acumulat 27 de puncte.

              
SELECT p.id_premiu, p.id_categorie, TO_CHAR(i.zi, 'DAY') "ZIUA", i.interval_inceput, NVL(c.stil, 'ambele') "STIL"
FROM premiu p JOIN categorii c ON (p.id_categorie = c.id_categorie)
              JOIN perechi pe ON (p.id_categorie = pe.id_categorie)
              JOIN intervaleorare i ON (p.id_categorie = i.id_categorie)
WHERE etapa = 'finala' AND premiu = 'premiul intai' AND pe.id_pereche IN (SELECT id_pereche
                                                                          FROM perechi
                                                                          WHERE punctaj = 27 AND clasificare = 1);
                        
--AVG, WITH CLAUSE
--2. Sa se afiseze o singura data perechile care au cel putin un punctaj above average, impreuna cu numele partenerilor

WITH tabel(avgNota) AS (SELECT AVG(nota) FROM punctaje)
        SELECT DISTINCT p.id_pereche, pe.nume_fata, pe.nume_baiat
        FROM punctaje p JOIN perechi pe ON (p.id_pereche = pe.id_pereche), 
        tabel 
        WHERE p.nota > tabel.avgNota;

--GROUP BY, MAX, UPPER                 
--3. Sa se afiseze, pentru fiecare club, nota maxima pe care a luat-o o pereche antrenata in acel club 

SELECT MAX(nota) "NOTA MAXIMA", UPPER(c.nume) "NUME CLUB"
FROM perechi pe JOIN punctaje pu ON (pe.id_pereche = pu.id_pereche)
                JOIN clubdans c ON (pe.id_clubdans = c.id_clubdans)
GROUP BY c.nume;

--DECODE, CASE, ORDER BY, round(TO DATE('','') - date)
--4. Sa se afiseze despre fiecare contract numele sponsorului, al organizatorului si cat de apropiat,
--comparat cu 10 zile, a fost semnat

SELECT s.nume,
DECODE (id_organizator, 1, 'Balan Miruna',
                        2, 'Bouruc Liviu',
                        3, 'Paun Liviu',
                        4, 'Sorescu Mihai',
                        'Vasilescu Mihai') RESULT,
CASE WHEN round(TO_DATE('2020-06-29', 'YYYY-MM-DD') - data_semnare) = 10 THEN '10 zile'
     WHEN round(TO_DATE('2020-06-29', 'YYYY-MM-DD') - data_semnare) > 10 THEN 'mai mult de 10 zile'
     ELSE 'mai putin de 10 zile'
END AS timp
FROM contract c JOIN sponsor s on (c.id_sponsor = s.id_sponsor)
ORDER BY c.id_sponsor;

--SUBCERERE SINCRONIZATA, SUBSTR()
--5.Sa se afiseze fiecare antrenor (si rolul sau) care a invitat cluburi de dans la competitie,
--alaturi de antrenorii clubului.

SELECT o.nume "NUME ORG", SUBSTR(o.rol,1,3) "ROL", c.nume "NUME CLUB", a.nume "NUME ANTR"
FROM clubdans c JOIN antrenor a ON (c.id_clubDans = a.id_clubDans)
                JOIN organizator o ON (c.id_organizator = o.id_organizator)
WHERE c.id_organizator IN (SELECT id_organizator
                           FROM organizator
                           WHERE id_organizator = c.id_organizator);




--CERINTA 12

--ACTUALIZARE

UPDATE PERECHI
SET punctaj = punctaj + 2
WHERE id_categorie IN (SELECT id_categorie
                       FROM categoriI
                       WHERE stil = 'Latino');

UPDATE CONTRACT
SET scop = 'diverse'
WHERE id_sponsor IN (SELECT id_sponsor
                     FROM sponsor
                     WHERE nume = 'Deloitte');
                     
--INSERARE (PENTRU A FOLOSI ALTA FORMA DE UPDATE)                     
INSERT INTO (SELECT * FROM punctaje WHERE id_punctaj > 1023)
VALUES (1024, 91, 100, 4);

--O ALTA FORMA DE UPDATE
UPDATE (SELECT * FROM punctaje WHERE nota <= 4)
SET nota = nota + 1;

--3 INSERARI NOI (PENTRU A TESTA UN DELETE)
INSERT INTO (SELECT * FROM antrenor WHERE id_antrenor > 606)
VALUES (607, 15, 'Hamilton Florenta', 765432189);
INSERT INTO (SELECT * FROM antrenor WHERE id_antrenor > 607)
VALUES (608, 15, 'Balan Ionela', 765432180);
INSERT INTO (SELECT * FROM antrenor WHERE id_antrenor > 608)
VALUES (609, 14, 'Badescu Sanda', 765432181);

--DELETE
DELETE (SELECT * FROM antrenor WHERE id_antrenor > 606)
WHERE id_clubdans = 15;




--CERINTA 13

--SECVENTA INSERARE

CREATE SEQUENCE add_pereche
                START WITH 112
                MAXVALUE 200 
                NOCACHE;

INSERT INTO perechi VALUES (add_pereche.NEXTVAL, 11, 50, 'Costache Ana', 'Albu George', 3, 20);




--CERINTA 14

--COMPLEX VIEW
CREATE VIEW PUNCTAJE_CATEGORII AS
SELECT c.id_categorie, sum(pe.punctaj) "Total punctaj"
FROM categorii c JOIN perechi pe ON (c.id_categorie = pe.id_categorie)
GROUP BY c.id_categorie;

--exemplu LMD care functioneaza:
SELECT *
FROM punctaje_categorii
WHERE "Total punctaj" >= 50;

--exemplu LMD care nu functioneaza:
UPDATE punctaje_categorii SET id_categorie = 58 WHERE id_categorie = 57;


--CERINTA 15

--INDEX

CREATE INDEX search_pereche
ON perechi(nume_fata, nume_baiat);

SELECT nume_fata, nume_baiat
FROM perechi
WHERE SUBSTR(nume_fata, 1, 1) = SUBSTR(nume_baiat, 1, 1);

--CERINTA 16 - OUTER JOIN

--Sa se afiseze pentru fiecare interval orar echipa care a fost clasificata pe locul intai si id-ul premiului acesteia
--sau null, daca atunci este pauza

SELECT i.id_categorie, i.etapa, pe.id_pereche, pr.id_premiu
FROM categorii c FULL OUTER JOIN intervaleorare i ON (c.id_categorie = i.id_categorie)
                 FULL OUTER JOIN perechi pe ON (c.id_categorie = pe.id_categorie)
                 FULL OUTER JOIN premiu pr ON (c.id_categorie = pr.id_categorie)
WHERE i.etapa = 'pauza' OR (pe.clasificare = 1 AND pr.premiu = 'premiul intai');








