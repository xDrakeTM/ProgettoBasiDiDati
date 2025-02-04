SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema progetto_carinci_difabrizio
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema progetto_carinci_difabrizio
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `progetto_carinci_difabrizio` DEFAULT CHARACTER SET utf8mb3 ;
USE `progetto_carinci_difabrizio` ;

-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`areageografica`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`areageografica` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Nome` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`edificio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`edificio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Tipologia` VARCHAR(45) NOT NULL,
  `Latitudine` FLOAT NOT NULL,
  `Longitudine` FLOAT NOT NULL,
  `AreaGeografica_ID` INT NOT NULL,
  CONSTRAINT chk_latitudine CHECK ( `Latitudine` between -90 and 90),
  CONSTRAINT chk_longitudine CHECK ( `Longitudine` between -180 and 180),
  PRIMARY KEY (`ID`),
  INDEX `fk_Edificio_AreaGeografica1_idx` (`AreaGeografica_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Edificio_AreaGeografica1`
    FOREIGN KEY (`AreaGeografica_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`areageografica` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`piano`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`piano` (
  `Numero` INT NOT NULL,
  `Edificio_ID` INT NOT NULL,
  PRIMARY KEY (`Numero`, `Edificio_ID`),
  INDEX `fk_Piano_Edificio1_idx` (`Edificio_ID` ASC) VISIBLE,
  CONSTRAINT chk_piano CHECK (`Numero` BETWEEN 0 AND 3),
  CONSTRAINT `fk_Piano_Edificio1`
    FOREIGN KEY (`Edificio_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`edificio` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`vano`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`vano` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Funzione` VARCHAR(45) NOT NULL,
  `AltezzaMax` FLOAT NOT NULL,
  `Larghezza` FLOAT NOT NULL,
  `Lunghezza` FLOAT NOT NULL,
  `Piano_Numero` INT NOT NULL,
  `edificio_ID` INT NOT NULL,
  PRIMARY KEY (`ID`, `Piano_Numero`, `edificio_ID`),
  INDEX `fk_Vano_Piano1_idx` (`Piano_Numero` ASC) VISIBLE,
  INDEX `fk_vano_edificio1_idx` (`edificio_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Vano_Piano1`
    FOREIGN KEY (`Piano_Numero`)
    REFERENCES `progetto_carinci_difabrizio`.`piano` (`Numero`),
  CONSTRAINT `fk_vano_edificio1`
    FOREIGN KEY (`edificio_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`edificio` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`sensore`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`sensore` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Tipologia` VARCHAR(45) NOT NULL,
  `Soglia` FLOAT NOT NULL,
  `x` FLOAT NOT NULL,
  `y` FLOAT NOT NULL,
  `z` FLOAT NOT NULL,
  `Vano_ID` INT NOT NULL,
  PRIMARY KEY (`ID`),
  INDEX `fk_Sensore_Vano1_idx` (`Vano_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Sensore_Vano1`
    FOREIGN KEY (`Vano_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`vano` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`misura`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`misura` (
  `Timestamp` DATETIME NOT NULL,
  `xOppureUnico` FLOAT NOT NULL,
  `y` FLOAT NULL,
  `z` FLOAT NULL,
  `Sensore_ID` INT NOT NULL,
  PRIMARY KEY (`Timestamp`, `Sensore_ID`),
  INDEX `fk_Misura_Sensore1_idx` (`Sensore_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Misura_Sensore1`
    FOREIGN KEY (`Sensore_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`sensore` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`alert`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`alert` (
  `Misura_Timestamp` DATETIME NOT NULL,
  `Misura_Sensore_ID` INT NOT NULL,
  PRIMARY KEY (`Misura_Timestamp`, `Misura_Sensore_ID`),
  INDEX `fk_Alert_Misura1_idx` (`Misura_Timestamp` ASC, `Misura_Sensore_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Alert_Misura1`
    FOREIGN KEY (`Misura_Timestamp` , `Misura_Sensore_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`misura` (`Timestamp` , `Sensore_ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`materiale`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`materiale` (
  `CodiceLotto` INT NOT NULL,
  `Fornitore` VARCHAR(45) NOT NULL,
  `CostoUnitario` FLOAT NOT NULL,
  `UnitaMisura` VARCHAR(4) NOT NULL,
  `QuantitaAcquistata` INT NOT NULL,
  `DataAcquisto` DATE NOT NULL,
  PRIMARY KEY (`CodiceLotto`, `Fornitore`),
  CONSTRAINT chk_materiale CHECK (`QuantitaAcquistata` > 0),
  CONSTRAINT chk_materiale2 CHECK (`CostoUnitario` > 0))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`altrimateriali`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`altrimateriali` (
  `Descrizione` VARCHAR(255) NOT NULL,
  `Funzione` VARCHAR(255) NOT NULL,
  `Altezza` FLOAT,
  `Lunghezza` FLOAT NOT NULL,
  `Larghezza` FLOAT,
  `Materiale_CodiceLotto` INT NOT NULL,
  `Materiale_Fornitore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Materiale_CodiceLotto`, `Materiale_Fornitore`),
  INDEX `fk_AltriMateriali_Materiale1_idx` (`Materiale_CodiceLotto` ASC, `Materiale_Fornitore` ASC) VISIBLE,
  CONSTRAINT `fk_AltriMateriali_Materiale1`
    FOREIGN KEY (`Materiale_CodiceLotto` , `Materiale_Fornitore`)
    REFERENCES `progetto_carinci_difabrizio`.`materiale` (`CodiceLotto` , `Fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`muro`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`muro` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Xo` FLOAT NOT NULL,
  `Yo` FLOAT NOT NULL,
  `Xf` FLOAT NOT NULL,
  `Yf` FLOAT NOT NULL,
  PRIMARY KEY (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`apertura`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`apertura` (
  `NumeroApertura` INT NOT NULL AUTO_INCREMENT,
  `x` FLOAT NOT NULL,
  `y` FLOAT NOT NULL,
  `PuntoCardinale` VARCHAR(2) NOT NULL,
  `AltezzaTerra` FLOAT NOT NULL,
  `Lunghezza` FLOAT NOT NULL,
  `Altezza` FLOAT NOT NULL,
  `Tipologia` VARCHAR(45) NOT NULL,
  `Muro_ID` INT NOT NULL,
  PRIMARY KEY (`NumeroApertura`, `Muro_ID`),
  INDEX `fk_Apertura_Muro_idx` (`Muro_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Apertura_Muro`
    FOREIGN KEY (`Muro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`muro` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`progettoedilizio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`progettoedilizio` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `StimaDataFine` DATE NOT NULL,
  `Tipo` VARCHAR(45) NOT NULL,
  `DataInizio` DATE NOT NULL,
  `DataApprovazione` DATE NOT NULL,
  `DataPresentazione` DATE NOT NULL,
  `CostoLavori` FLOAT NOT NULL,
  `Edificio_ID` INT NOT NULL,
  PRIMARY KEY (`ID`, `Edificio_ID`),
  INDEX `fk_ProgettoEdilizio_Edificio1_idx` (`Edificio_ID` ASC) VISIBLE,
  CONSTRAINT chk_progedilizio1 CHECK (`StimaDataFine` >= `DataInizio`),
  CONSTRAINT chk_progedilizio2 CHECK (`CostoLavori` >= 0),
  CONSTRAINT `fk_ProgettoEdilizio_Edificio1`
    FOREIGN KEY (`Edificio_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`edificio` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`avanzamento`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`avanzamento` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `DataInizio` DATE NOT NULL,
  `StimaDataFine` DATE NOT NULL,
  `DataFineEffettiva` DATE NULL DEFAULT NULL,
  `ProgettoEdilizio_ID` INT NOT NULL,
  PRIMARY KEY (`ID`),
  INDEX `fk_Avanzamento_ProgettoEdilizio1_idx` (`ProgettoEdilizio_ID` ASC) VISIBLE,
  CONSTRAINT chk_avanzamento1 CHECK (`StimaDataFine` >= `DataInizio`),
  CONSTRAINT chk_avanzamento2 CHECK (`DataFineEffettiva` >= `DataInizio`),
  CONSTRAINT `fk_Avanzamento_ProgettoEdilizio1`
    FOREIGN KEY (`ProgettoEdilizio_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`progettoedilizio` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`calamita`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`calamita` (
  `Timestamp` DATETIME NOT NULL,
  `Tipo` VARCHAR(45) NOT NULL,
  `Intensita` VARCHAR(45) NOT NULL,
  `Longitudine` FLOAT NOT NULL,
  `Latitudine` FLOAT NOT NULL,
  CONSTRAINT chk_latitudine2 CHECK ( `Latitudine` between -90 and 90),
  CONSTRAINT chk_longitudine2 CHECK ( `Longitudine` between -180 and 180),
  PRIMARY KEY (`Timestamp`, `Tipo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`dannoarrecato`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`dannoarrecato` (
  `AreaGeografica_ID` INT NOT NULL,
  `Calamita_Timestamp` DATETIME NOT NULL,
  `Calamita_Tipo` VARCHAR(45) NOT NULL,
  INDEX `fk_DannoArrecato_AreaGeografica1_idx` (`AreaGeografica_ID` ASC) VISIBLE,
  INDEX `fk_DannoArrecato_Calamita1_idx` (`Calamita_Timestamp` ASC, `Calamita_Tipo` ASC) VISIBLE,
  CONSTRAINT `fk_DannoArrecato_AreaGeografica1`
    FOREIGN KEY (`AreaGeografica_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`areageografica` (`ID`),
  CONSTRAINT `fk_DannoArrecato_Calamita1`
    FOREIGN KEY (`Calamita_Timestamp` , `Calamita_Tipo`)
    REFERENCES `progetto_carinci_difabrizio`.`calamita` (`Timestamp` , `Tipo`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`supervisore`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`supervisore` (
  `CodiceFiscale` CHAR(16) NOT NULL,
  `Cognome` VARCHAR(255) NOT NULL,
  `Nome` VARCHAR(255) NOT NULL,
  `PagaOraria` FLOAT NOT NULL,
  `MaxOperai` INT NOT NULL,
  PRIMARY KEY (`CodiceFiscale`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`lavoro`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`lavoro` (
  `ID` INT NOT NULL AUTO_INCREMENT,
  `Tipo` VARCHAR(255) NOT NULL,
  `MaxOperai` INT NOT NULL,
  `DataInizio` DATE NOT NULL,
  `DataFine` DATE NOT NULL,
  `Avanzamento_ID` INT NOT NULL,
  `Supervisore_ID` CHAR(16) NOT NULL,
  PRIMARY KEY (`ID`, `Avanzamento_ID`, `Supervisore_ID`),
  INDEX `fk_Lavoro_Avanzamento1_idx` (`Avanzamento_ID` ASC) VISIBLE,
  INDEX `fk_lavoro_supervisore1_idx` (`Supervisore_ID` ASC) VISIBLE,
  CONSTRAINT chk_lavoro CHECK (`DataFine` >= `DataInizio`),
  CONSTRAINT `fk_Lavoro_Avanzamento1`
    FOREIGN KEY (`Avanzamento_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`avanzamento` (`ID`),
  CONSTRAINT `fk_lavoro_supervisore1`
    FOREIGN KEY (`Supervisore_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`supervisore` (`CodiceFiscale`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`operaio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`operaio` (
  `CodiceFiscale` CHAR(16) NOT NULL,
  `Cognome` VARCHAR(255) NOT NULL,
  `Nome` VARCHAR(255) NOT NULL,
  `PagaOraria` FLOAT NOT NULL,
  PRIMARY KEY (`CodiceFiscale`),
  CONSTRAINT chk_operaio CHECK (`PagaOraria` > 0))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`impiegooperaio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`impiegooperaio` (
  `InizioImpiego` DATETIME NOT NULL,
  `FineImpiego` DATETIME NOT NULL,
  `Lavoro_ID` INT NOT NULL,
  `Operaio_CodiceFiscale` CHAR(16) NOT NULL,
  PRIMARY KEY (`InizioImpiego`, `Lavoro_ID`, `Operaio_CodiceFiscale`),
  INDEX `fk_ImpiegoOperaio_Lavoro1_idx` (`Lavoro_ID` ASC) VISIBLE,
  INDEX `fk_ImpiegoOperaio_Operaio1_idx` (`Operaio_CodiceFiscale` ASC) VISIBLE,
  CONSTRAINT chk_impiegop CHECK (DATE(`InizioImpiego`) = DATE(`FineImpiego`) AND SUBTIME(TIME(`FineImpiego`), TIME(`InizioImpiego`)) < "13:00:00"),
  CONSTRAINT `fk_ImpiegoOperaio_Lavoro1`
    FOREIGN KEY (`Lavoro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`lavoro` (`ID`),
  CONSTRAINT `fk_ImpiegoOperaio_Operaio1`
    FOREIGN KEY (`Operaio_CodiceFiscale`)
    REFERENCES `progetto_carinci_difabrizio`.`operaio` (`CodiceFiscale`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`impiegosupervisore`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`impiegosupervisore` (
  `InizioImpiego` DATETIME NOT NULL,
  `FineImpiego` DATETIME NOT NULL,
  `Lavoro_ID` INT NOT NULL,
  `Supervisore_CodiceFiscale` CHAR(16) NOT NULL,
  PRIMARY KEY (`InizioImpiego`, `Lavoro_ID`, `Supervisore_CodiceFiscale`),
  INDEX `fk_ImpiegoSupervisore_Lavoro1_idx` (`Lavoro_ID` ASC) VISIBLE,
  INDEX `fk_ImpiegoSupervisore_Supervisore1_idx` (`Supervisore_CodiceFiscale` ASC) VISIBLE,
  CONSTRAINT chk_impiegos CHECK (DATE(`InizioImpiego`) = DATE(`FineImpiego`) AND SUBTIME(TIME(`FineImpiego`), TIME(`InizioImpiego`)) < "13:00:00"),
  CONSTRAINT `fk_ImpiegoSupervisore_Lavoro1`
    FOREIGN KEY (`Lavoro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`lavoro` (`ID`),
  CONSTRAINT `fk_ImpiegoSupervisore_Supervisore1`
    FOREIGN KEY (`Supervisore_CodiceFiscale`)
    REFERENCES `progetto_carinci_difabrizio`.`supervisore` (`CodiceFiscale`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`intonaco`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`intonaco` (
  `Tipo` VARCHAR(45) NOT NULL,
  `Colore` VARCHAR(45) NOT NULL,
  `Materiale_CodiceLotto` INT NOT NULL,
  `Materiale_Fornitore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Materiale_CodiceLotto`, `Materiale_Fornitore`),
  INDEX `fk_Intonaco_Materiale1_idx` (`Materiale_CodiceLotto` ASC, `Materiale_Fornitore` ASC) VISIBLE,
  CONSTRAINT `fk_Intonaco_Materiale1`
    FOREIGN KEY (`Materiale_CodiceLotto` , `Materiale_Fornitore`)
    REFERENCES `progetto_carinci_difabrizio`.`materiale` (`CodiceLotto` , `Fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`mattone`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`mattone` (
  `Larghezza` FLOAT NOT NULL,
  `Lunghezza` FLOAT NOT NULL,
  `Altezza` FLOAT NOT NULL,
  `Composizione` VARCHAR(255) NOT NULL,
  `Alveolatura` FLOAT NOT NULL,
  `Materiale_CodiceLotto` INT NOT NULL,
  `Materiale_Fornitore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Materiale_CodiceLotto`, `Materiale_Fornitore`),
  INDEX `fk_Mattone_Materiale1_idx` (`Materiale_CodiceLotto` ASC, `Materiale_Fornitore` ASC) VISIBLE,
  CONSTRAINT `fk_Mattone_Materiale1`
    FOREIGN KEY (`Materiale_CodiceLotto` , `Materiale_Fornitore`)
    REFERENCES `progetto_carinci_difabrizio`.`materiale` (`CodiceLotto` , `Fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`parquet`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`parquet` (
  `TipoLegno` VARCHAR(45) NOT NULL,
  `Materiale_CodiceLotto` INT NOT NULL,
  `Materiale_Fornitore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Materiale_CodiceLotto`, `Materiale_Fornitore`),
  INDEX `fk_Parquet_Materiale1_idx` (`Materiale_CodiceLotto` ASC, `Materiale_Fornitore` ASC) VISIBLE,
  CONSTRAINT `fk_Parquet_Materiale1`
    FOREIGN KEY (`Materiale_CodiceLotto` , `Materiale_Fornitore`)
    REFERENCES `progetto_carinci_difabrizio`.`materiale` (`CodiceLotto` , `Fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`perimetro`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`perimetro` (
  `muro_ID` INT NOT NULL,
  `vano_ID` INT NOT NULL,
  PRIMARY KEY (`muro_ID`, `vano_ID`),
  INDEX `fk_perimetro_vano1_idx` (`vano_ID` ASC) VISIBLE,
  CONSTRAINT `fk_perimetro_muro1`
    FOREIGN KEY (`muro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`muro` (`ID`),
  CONSTRAINT `fk_perimetro_vano1`
    FOREIGN KEY (`vano_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`vano` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`piastrella`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`piastrella` (
  `Composizione` VARCHAR(255) NOT NULL,
  `Lunghezza` FLOAT NOT NULL,
  `Larghezza` FLOAT NOT NULL,
  `Tipo` VARCHAR(45) NOT NULL,
  `NumeroLati` INT NOT NULL,
  `Disegno` BLOB NULL DEFAULT NULL,
  `Fuga` FLOAT NOT NULL,
  `Materiale_CodiceLotto` INT NOT NULL,
  `Materiale_Fornitore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Materiale_CodiceLotto`, `Materiale_Fornitore`),
  INDEX `fk_Piastrella_Materiale1_idx` (`Materiale_CodiceLotto` ASC, `Materiale_Fornitore` ASC) VISIBLE,
  CONSTRAINT `fk_Piastrella_Materiale1`
    FOREIGN KEY (`Materiale_CodiceLotto` , `Materiale_Fornitore`)
    REFERENCES `progetto_carinci_difabrizio`.`materiale` (`CodiceLotto` , `Fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`pietra`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`pietra` (
  `Tipo` VARCHAR(45) NOT NULL,
  `SuperficieMedia` FLOAT NOT NULL,
  `PesoMedio` FLOAT NOT NULL,
  `Disposizione` VARCHAR(45) NOT NULL,
  `Materiale_CodiceLotto` INT NOT NULL,
  `Materiale_Fornitore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`Materiale_CodiceLotto`, `Materiale_Fornitore`),
  INDEX `fk_Pietra_Materiale1_idx` (`Materiale_CodiceLotto` ASC, `Materiale_Fornitore` ASC) VISIBLE,
  CONSTRAINT `fk_Pietra_Materiale1`
    FOREIGN KEY (`Materiale_CodiceLotto` , `Materiale_Fornitore`)
    REFERENCES `progetto_carinci_difabrizio`.`materiale` (`CodiceLotto` , `Fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`rischio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`rischio` (
  `Tipologia` VARCHAR(45) NOT NULL,
  `Timestamp` DATETIME NOT NULL,
  `CoefficienteDiRischio` FLOAT NOT NULL,
  `AreaGeografica_ID` INT NOT NULL,
  PRIMARY KEY (`Tipologia`, `Timestamp`, `AreaGeografica_ID`),
  INDEX `fk_Rischio_AreaGeografica1_idx` (`AreaGeografica_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Rischio_AreaGeografica1`
    FOREIGN KEY (`AreaGeografica_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`areageografica` (`ID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`utilizzomateriale`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`utilizzomateriale` (
  `Quantita` INT NOT NULL,
  `Lavoro_ID` INT NOT NULL,
  `Materiale_CodiceLotto` INT NOT NULL,
  `Materiale_Fornitore` VARCHAR(255) NOT NULL,
  INDEX `fk_UtilizzoMateriale_Lavoro1_idx` (`Lavoro_ID` ASC) VISIBLE,
  INDEX `fk_UtilizzoMateriale_Materiale1_idx` (`Materiale_CodiceLotto` ASC, `Materiale_Fornitore` ASC) VISIBLE,
  CONSTRAINT chk_utilizzomateriale CHECK (`Quantita` > 0),
  CONSTRAINT `fk_UtilizzoMateriale_Lavoro1`
    FOREIGN KEY (`Lavoro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`lavoro` (`ID`),
  CONSTRAINT `fk_UtilizzoMateriale_Materiale1`
    FOREIGN KEY (`Materiale_CodiceLotto` , `Materiale_Fornitore`)
    REFERENCES `progetto_carinci_difabrizio`.`materiale` (`CodiceLotto` , `Fornitore`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`operagenerale`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`operagenerale` (
  `lavoro_ID` INT NOT NULL,
  `edificio_ID` INT NOT NULL,
  INDEX `fk_operagenerale_lavoro1_idx` (`lavoro_ID` ASC) VISIBLE,
  INDEX `fk_operagenerale_edificio1_idx` (`edificio_ID` ASC) VISIBLE,
  CONSTRAINT `fk_operagenerale_lavoro1`
    FOREIGN KEY (`lavoro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`lavoro` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_operagenerale_edificio1`
    FOREIGN KEY (`edificio_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`edificio` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`operaimpalcato`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`operaimpalcato` (
  `lavoro_ID` INT NOT NULL,
  `vano_ID` INT NOT NULL,
  INDEX `fk_operaimpalcato_lavoro1_idx` (`lavoro_ID` ASC) VISIBLE,
  INDEX `fk_operaimpalcato_vano1_idx` (`vano_ID` ASC) VISIBLE,
  CONSTRAINT `fk_operaimpalcato_lavoro1`
    FOREIGN KEY (`lavoro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`lavoro` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_operaimpalcato_vano1`
    FOREIGN KEY (`vano_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`vano` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `progetto_carinci_difabrizio`.`operamuraria`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `progetto_carinci_difabrizio`.`operamuraria` (
  `lavoro_ID` INT NOT NULL,
  `muro_ID` INT NOT NULL,
  INDEX `fk_operamuraria_lavoro1_idx` (`lavoro_ID` ASC) VISIBLE,
  INDEX `fk_operamuraria_muro1_idx` (`muro_ID` ASC) VISIBLE,
  CONSTRAINT `fk_operamuraria_lavoro1`
    FOREIGN KEY (`lavoro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`lavoro` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_operamuraria_muro1`
    FOREIGN KEY (`muro_ID`)
    REFERENCES `progetto_carinci_difabrizio`.`muro` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
