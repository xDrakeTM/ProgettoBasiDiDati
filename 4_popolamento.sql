USE Progetto_Carinci_DiFabrizio;

-- SET FOREIGN_KEY_CHECKS = 0;

-- TRUNCATE TABLE AREAGEOGRAFICA;
INSERT INTO AREAGEOGRAFICA(Nome) 
VALUES ('Amatrice'), ('Perugia'), 
       ('Terni'), ('Pescara'), ('Reggio Calabria');

-- TRUNCATE TABLE RISCHIO;
INSERT RISCHIO(Tipologia, Timestamp, CoefficienteDiRischio, AreaGeografica_ID)
VALUES ('Sismico', '2020-01-22 02:34:23', RAND()*10, 2), ('Idrico', '2022-07-12 10:22:59', RAND()*10, 1), 
       ('Frana', '2018-12-01 23:56:01', RAND()*10, 1), ('Sismico', '2017-10-10 04:10:11', RAND()*10, 3), ('Ghiaccio', '2021-01-04 09:23:24', RAND()*10, 5); 

-- TRUNCATE TABLE CALAMITA;
INSERT CALAMITA(Timestamp, Tipo, Intensita, Longitudine, Latitudine)
VALUES ('2017-10-22 22:28:01', 'Sismico', RAND()*50, RAND()*100, RAND()*100);

-- TRUNCATE TABLE EDIFICIO;
INSERT INTO EDIFICIO(Tipologia, Latitudine, Longitudine, AreaGeografica_ID)
VALUES ('Residenziale', RAND()*100, RAND()*100, 3), ('Residenziale', RAND()*100, RAND()*100, 1), ('Residenziale', RAND()*100, RAND()*100, 2);

-- TRUNCATE TABLE PIANO;
INSERT INTO PIANO(Numero, Edificio_ID)
VALUES (0, 1), (0, 2),
       (1, 1), (1, 2),
       (2, 1), (2, 2),
       (3, 1), (3, 2);
-- TRUNCATE TABLE VANO;
INSERT INTO VANO(Funzione, AltezzaMax, Larghezza, Lunghezza, Piano_Numero, Edificio_ID)
VALUES ('Bagno', RAND()*10, RAND()*10, RAND()*10, 0, 1),
       ('Cucina', RAND()*10, RAND()*10, RAND()*10, 1, 1),
       ('Camera da Letto', RAND()*10, RAND()*10, RAND()*10, 2, 1),
       ('Bagno', RAND()*10, RAND()*10, RAND()*10, 0, 2),
       ('Cucina', RAND()*10, RAND()*10, RAND()*10, 1, 2),
       ('Camera da Letto', RAND()*10, RAND()*10, RAND()*10, 2, 2);

-- TRUNCATE TABLE MURO;
INSERT INTO MURO(Xo, Yo, Xf, Yf)
VALUES (0, 0, 3, 0), (3, 0, 3, 3), (3, 3, 3, 5), (3, 5, 0, 5), (0, 5, 0, 0), -- CUCINA
       (5, 3, 5, 5), (5, 5, 3, 5), -- BAGNO
       (5, 0, 8, 0), (8, 0, 8, 5), (8, 5, 5, 5); -- CAMERA DA LETTO

-- TRUNCATE TABLE PERIMETRO;
INSERT INTO PERIMETRO(Muro_ID, Vano_ID)
VALUES (1, 1), (6, 2), (8, 3);

-- TRUNCATE TABLE APERTURA;
INSERT INTO APERTURA(x, y, PuntoCardinale, AltezzaTerra, Lunghezza, Altezza, Tipologia, Muro_ID)
VALUES (1.2, 2.2, 'S', 0, 1.5, 2.3, 'Porta', 1), (1.1, 2.1, 'N', 0, 1.5, 2.3, 'Porta', 6),
       (1.2, 2.2, 'O', 0, 1.5, 2.3, 'Porta', 8);

-- TRUNCATE TABLE SENSORE;
INSERT INTO SENSORE(Tipologia, Soglia, x, y, z, Vano_ID)
VALUES ('Accelerometro', 2.5, 1, 1.5, 0, 1), ('Accelerometro', 2.5, 1, 6.5, 0, 1), 
       ('Accelerometro', 2.5, 1, 1.5, 0, 2), ('Accelerometro', 2.5, 1, 6.5, 0, 2), 
       ('Estensimetro', 10, 1.5, 0, 0, 2), ('Estensimetro', 10, 6.5, 0, 0, 2),
       ('Pluviometro', 10, 6.5, 0, 0, 3);

-- TRUNCATE TABLE MISURA;
INSERT INTO MISURA(Timestamp, xOppureUnico, y, z, Sensore_ID)
VALUES ('2020-09-02 04:09:09', 9.3, 5.2, 0, 1), 
       ('2021-11-12 07:10:19', 2.1, 3.4, 0, 2),
       ('2020-09-02 04:09:10', 7.9, 9.45, 0, 3), 
       ('2021-11-12 07:10:13', 2.34, 4.4, 0, 4),  
       ('2022-02-08 11:34:09', 2.34, 0, 0, 5);

-- TRUNCATE TABLE ALERT;
INSERT INTO ALERT(Misura_Timestamp, Misura_Sensore_ID)
VALUES ('2020-09-02 04:09:09', 1),
       ('2020-09-02 04:09:10', 3);

-- TRUNCATE TABLE PROGETTOEDILIZIO;
INSERT INTO PROGETTOEDILIZIO(StimaDataFine, Tipo, DataInizio, DataApprovazione, DataPresentazione, CostoLavori, Edificio_ID)
VALUES ('2020-08-27', 'Manutenzione', '2020-01-03', '2019-12-01', '2019-12-12', 567986, 1),
       ('2011-02-22', 'Manutenzione', '2010-11-13', '2010-10-03', '2010-10-10', 59663, 2);

-- TRUNCATE TABLE AVANZAMENTO;
INSERT INTO AVANZAMENTO(DataInizio, StimaDataFine, DataFineEffettiva, ProgettoEdilizio_ID)
VALUES ('2020-01-03', '2020-01-21', '2020-01-22', 1),
       ('2010-11-13', '2011-02-22', '2011-02-23', 2);

-- TRUNCATE TABLE SUPERVISORE;
INSERT INTO SUPERVISORE(CodiceFiscale, Cognome, Nome, PagaOraria, MaxOperai)
VALUES ('XXRXXX92M02G865F', 'Grigi', 'Antonio', 12.45, 4),
       ('XXXDXH92M02G865F', 'Tonno', 'Gianni', 12.45, 4);

-- TRUNCATE TABLE LAVORO;
INSERT INTO LAVORO(Tipo, MaxOperai, DataInizio, DataFine, Avanzamento_ID, Supervisore_ID)
VALUES ('Rivestimenti Bagno', 2, '2020-01-03', '2020-01-04', 1, 'XXRXXX92M02G865F'),
       ('Rinforzo Solaio', 2, '2010-11-13', '2010-11-20', 2, 'XXXDXH92M02G865F');

-- TRUNCATE TABLE OPERAIO;
INSERT INTO OPERAIO(CodiceFiscale, Cognome, Nome, PagaOraria)
VALUES ('XXXXXX92M02G865F', 'Rossi', 'Mario', 7.45),
       ('XXXXXH92M02G865F', 'Verdi', 'Luigi', 8),
       ('XXXDXX92M02G865F', 'Bianchi', 'Orlando', 7.55),
       ('XXDXXX92M02G865F', 'Baresi', 'Franco', 9);

-- TRUNCATE TABLE IMPIEGOOPERAIO;
INSERT INTO IMPIEGOOPERAIO(InizioImpiego, FineImpiego, Lavoro_ID, Operaio_CodiceFiscale)
VALUES ('2020-01-03 09:00:00', '2020-01-03 18:00:00', 1, 'XXXXXX92M02G865F'),
       ('2020-01-03 09:00:00', '2020-01-03 18:00:00', 1, 'XXXXXH92M02G865F'),
       ('2010-11-13 09:00:00', '2010-11-13 18:00:00', 2, 'XXXDXX92M02G865F'),
       ('2010-11-13 09:00:00', '2010-11-13 18:00:00', 2, 'XXDXXX92M02G865F');

-- TRUNCATE TABLE IMPIEGOSUPERVISORE;
INSERT INTO IMPIEGOSUPERVISORE(InizioImpiego, FineImpiego, Lavoro_ID, Supervisore_CodiceFiscale)
VALUES ('2020-01-03 09:00:00', '2020-01-03 18:00:00', 1, 'XXRXXX92M02G865F'),
       ('2010-11-13 09:00:00', '2010-11-13 18:00:00', 2, 'XXXDXH92M02G865F');

-- TRUNCATE TABLE MATERIALE;
INSERT INTO MATERIALE(CodiceLotto, Fornitore, CostoUnitario, UnitaMisura, QuantitaAcquistata, DataAcquisto)
VALUES (456123789, 'EsinCalce', 13.21, 'KG', 20, concat(year(CURRENT_DATE) - FLOOR(1 + RAND()*(10-1)),'-', FLOOR(1 + RAND()*(13-1)),'-', FLOOR(1 + RAND()*(29-1)))),
       (753965412, 'IBL SPA', 0.90, 'KG', 1000, concat(year(CURRENT_DATE) - FLOOR(1 + RAND()*(10-1)),'-', FLOOR(1 + RAND()*(13-1)),'-', FLOOR(1 + RAND()*(29-1)))),
       (727895524, 'Polis SPA', 0.20, 'KG', 2000, concat(year(CURRENT_DATE) - FLOOR(1 + RAND()*(10-1)),'-', FLOOR(1 + RAND()*(13-1)),'-', FLOOR(1 + RAND()*(29-1)))),
       (234569874, 'Cereser', 150, 'MQ', 100, concat(year(CURRENT_DATE) - FLOOR(1 + RAND()*(10-1)),'-', FLOOR(1 + RAND()*(13-1)),'-', FLOOR(1 + RAND()*(29-1)))),
       (125478961, 'Armony Floor', 50, 'MQ', 125, concat(year(CURRENT_DATE) - FLOOR(1 + RAND()*(10-1)),'-', FLOOR(1 + RAND()*(13-1)),'-', FLOOR(1 + RAND()*(29-1)))),
       (785214638, 'Lavesan SRL', 3.50, 'MQ', 100, concat(year(CURRENT_DATE) - FLOOR(1 + RAND()*(10-1)),'-', FLOOR(1 + RAND()*(13-1)),'-', FLOOR(1 + RAND()*(29-1))));

-- TRUNCATE TABLE UTILIZZOMATERIALE;
INSERT INTO UTILIZZOMATERIALE(Quantita, Lavoro_ID, Materiale_CodiceLotto, Materiale_Fornitore)
VALUES (10, 1, 727895524, 'Polis SPA'), (9, 1, 234569874, 'Cereser'), (40, 2, 753965412, 'IBL SPA');

-- TRUNCATE TABLE PIASTRELLA;
INSERT INTO PIASTRELLA(Composizione, Lunghezza, Larghezza, Tipo, NumeroLati, Disegno, Fuga, Materiale_CodiceLotto, Materiale_Fornitore)
VALUES ('Argilla, Feldspati, Caolini, Quarzi, Additivi Chimici e Acqua', 20, 20, 'Argilla Bianca', 4, null, 0.2, 727895524, 'Polis SPA');

-- TRUNCATE TABLE MATTONE;
INSERT INTO MATTONE(Larghezza, Lunghezza, Altezza, Composizione, Alveolatura, Materiale_CodiceLotto, Materiale_Fornitore)
VALUES (25, 12, 6, 'Argilla, Sabbia e Ossidi Vari', 15, 753965412, 'IBL SPA');

-- TRUNCATE TABLE INTONACO;
INSERT INTO INTONACO(Tipo, Colore, Materiale_CodiceLotto, Materiale_Fornitore)
VALUES ('Intonaco per ripristino del cemento armato', 'Bianco', 456123789, 'EsinCalce');

-- TRUNCATE TABLE PIETRA;
INSERT INTO PIETRA(Tipo, SuperficieMedia, PesoMedio, Disposizione, Materiale_CodiceLotto, Materiale_Fornitore)
VALUES ('Marmo', 100, 2500, 'Regolare', 234569874, 'Cereser');

-- TRUNCATE TABLE PARQUET;
INSERT INTO PARQUET(TipoLegno, Materiale_CodiceLotto, Materiale_Fornitore)
VALUES ('Larice', 125478961, 'Armony Floor');

-- TRUNCATE TABLE ALTRIMATERIALI;
INSERT INTO ALTRIMATERIALI(Descrizione, Funzione, Altezza, Lunghezza, Larghezza, Materiale_CodiceLotto, Materiale_Fornitore)
VALUES ('Fibra di Vetro', 'Rinforzo degli Edifici', null, 70, null, 785214638, 'Lavesan SRL');