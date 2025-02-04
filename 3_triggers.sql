USE Progetto_Carinci_DiFabrizio;

/*
    Trigger 1 - Vincolo DataAcquisto di Materiale
*/

DROP TRIGGER IF EXISTS chk_DataAcquisto;
DELIMITER $$

CREATE TRIGGER chk_DataAcquisto
BEFORE INSERT ON Materiale FOR EACH ROW
BEGIN
    IF (NEW.DataAcquisto > CURRENT_DATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La DataAcquist del Materiale è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 2 - Vincolo DataInizio di ProgettoEdilizio
*/

DROP TRIGGER IF EXISTS chk_DataInizio;
DELIMITER $$

CREATE TRIGGER chk_DataInizio
BEFORE INSERT ON ProgettoEdilizio FOR EACH ROW
BEGIN
    IF (NEW.DataInizio > CURRENT_DATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La DataInizio del ProgettoEdilizio è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 3 - Vincolo DataApprovazione di ProgettoEdilizio
*/

DROP TRIGGER IF EXISTS chk_DataApprovazione;
DELIMITER $$

CREATE TRIGGER chk_DataApprovazione
BEFORE INSERT ON ProgettoEdilizio FOR EACH ROW
BEGIN
    IF (NEW.DataApprovazione > CURRENT_DATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La DataApprovazione del ProgettoEdilizio è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 4 - Vincolo DataPresentazione di ProgettoEdilizio
*/

DROP TRIGGER IF EXISTS chk_DataPresentazione;
DELIMITER $$

CREATE TRIGGER chk_DataPresentazione
BEFORE INSERT ON ProgettoEdilizio FOR EACH ROW
BEGIN
    IF (NEW.DataPresentazione > CURRENT_DATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La DataPresentazione del ProgettoEdilizio è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 5 - Vincolo DataInizio di Avanzamento
*/

DROP TRIGGER IF EXISTS chk_DataInizio2;
DELIMITER $$

CREATE TRIGGER chk_DataInizio2
BEFORE INSERT ON Avanzamento FOR EACH ROW
BEGIN
    IF (NEW.DataInizio > CURRENT_DATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La DataInizio di Avanzamento è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 6 - Vincolo DataInizio di Lavoro
*/

DROP TRIGGER IF EXISTS chk_DataInizio3;
DELIMITER $$

CREATE TRIGGER chk_DataInizio3
BEFORE INSERT ON Lavoro FOR EACH ROW
BEGIN
    IF (NEW.DataInizio > CURRENT_DATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La DataInizio di Lavoro è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 7 - Vincolo InizioImpiego di ImpiegoOperaio
*/

DROP TRIGGER IF EXISTS chk_InizioImpiego;
DELIMITER $$

CREATE TRIGGER chk_InizioImpiego
BEFORE INSERT ON ImpiegoOperaio FOR EACH ROW
BEGIN
    IF (NEW.InizioImpiego > NOW()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La InizioImpiego di ImpiegoOperaio è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 8 - Vincolo InizioImpiego di ImpiegoSupervisore
*/

DROP TRIGGER IF EXISTS chk_InizioImpiego2;
DELIMITER $$

CREATE TRIGGER chk_InizioImpiego2
BEFORE INSERT ON ImpiegoSupervisore FOR EACH ROW
BEGIN
    IF (NEW.InizioImpiego > NOW()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La InizioImpiego di ImpiegoSupervisore è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 9 - Vincolo Timestamp di Misura
*/

DROP TRIGGER IF EXISTS chk_Timestamp;
DELIMITER $$

CREATE TRIGGER chk_Timestamp
BEFORE INSERT ON Misura FOR EACH ROW
BEGIN
    IF (NEW.Timestamp > NOW()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il Timestamp di Misura è > della data attuale.';
    END IF;
END $$
DELIMITER ;


/*
    Trigger 10 - Vincolo Timestamp di Rischio
*/

DROP TRIGGER IF EXISTS chk_Timestamp2;
DELIMITER $$

CREATE TRIGGER chk_Timestamp2
BEFORE INSERT ON Rischio FOR EACH ROW
BEGIN
    IF (NEW.Timestamp > NOW()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il Timestamp di Rischio è > della data attuale.';
    END IF;
END $$
DELIMITER ;

/*
    Trigger 11 - Vincolo Timestamp di Calamità
*/

DROP TRIGGER IF EXISTS chk_Timestamp3;
DELIMITER $$

CREATE TRIGGER chk_Timestamp3
BEFORE INSERT ON Calamita FOR EACH ROW
BEGIN
    IF (NEW.Timestamp > NOW()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Il Timestamp di Calamità è > della data attuale.';
    END IF;
END $$
DELIMITER ;



