--    Openbravo POS is a point of sales application designed for touch screens.
--    Copyright (C) 2007-2008 Openbravo, S.L.
--    http://sourceforge.net/projects/openbravopos
--
--    This program is free software; you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation; either version 2 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program; if not, write to the Free Software
--    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

-- Database upgrade script for POSTGRESQL
-- v2.00 - v2.10

ALTER TABLE PEOPLE ADD COLUMN CARD VARCHAR;  
CREATE INDEX PEOPLE_CARD_INX ON PEOPLE(CARD);

ALTER TABLE CUSTOMERS ADD COLUMN TAXID VARCHAR;  
ALTER TABLE CUSTOMERS ADD COLUMN CARD VARCHAR;  
ALTER TABLE CUSTOMERS ADD COLUMN MAXDEBT DOUBLE PRECISION DEFAULT 0 NOT NULL;
ALTER TABLE CUSTOMERS ADD COLUMN CURDATE TIMESTAMP;
ALTER TABLE CUSTOMERS ADD COLUMN CURDEBT DOUBLE PRECISION;
CREATE INDEX CUSTOMERS_TAXID_INX ON CUSTOMERS(TAXID);
CREATE INDEX CUSTOMERS_CARD_INX ON CUSTOMERS(CARD);

ALTER TABLE PRODUCTS ADD COLUMN ATTRIBUTES BYTEA;

ALTER TABLE TICKETS ADD COLUMN CUSTOMER VARCHAR;
ALTER TABLE TICKETS ADD CONSTRAINT TICKETS_CUSTOMERS_FK FOREIGN KEY (CUSTOMER) REFERENCES CUSTOMERS(ID);
CREATE INDEX TICKETS_TICKETID ON TICKETS(TICKETID);

ALTER TABLE TICKETLINES ADD COLUMN ATTRIBUTES BYTEA;

ALTER TABLE RECEIPTS ADD COLUMN DATENEW TIMESTAMP;
CREATE INDEX RECEIPTS_INX_1 ON RECEIPTS(DATENEW);
UPDATE RECEIPTS SET DATENEW = (SELECT DATENEW FROM TICKETS WHERE TICKETS.ID = RECEIPTS.ID);
ALTER TABLE RECEIPTS ALTER COLUMN DATENEW SET NOT NULL;

DROP INDEX TICKETS_INX_1;
ALTER TABLE TICKETS DROP COLUMN DATENEW;

INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('14', 'Menu.Root', 0, $FILE{/com/openbravo/pos/templates/Menu.Root.txt});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('15', 'Printer.CustomerPaid', 0, $FILE{/com/openbravo/pos/templates/Printer.CustomerPaid.xml});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('16', 'Printer.CustomerPaid2', 0, $FILE{/com/openbravo/pos/templates/Printer.CustomerPaid2.xml});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('17', 'payment.cash', 0, $FILE{/com/openbravo/pos/templates/payment.cash.txt});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('18', 'banknote.50euro', 1, $FILE{/com/openbravo/pos/templates/banknote.50euro.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('19', 'banknote.20euro', 1, $FILE{/com/openbravo/pos/templates/banknote.20euro.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('20', 'banknote.10euro', 1, $FILE{/com/openbravo/pos/templates/banknote.10euro.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('21', 'banknote.5euro', 1, $FILE{/com/openbravo/pos/templates/banknote.5euro.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('22', 'coin.2euro', 1, $FILE{/com/openbravo/pos/templates/coin.2euro.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('23', 'coin.1euro', 1, $FILE{/com/openbravo/pos/templates/coin.1euro.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('24', 'coin.50cent', 1, $FILE{/com/openbravo/pos/templates/coin.50cent.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('25', 'coin.20cent', 1, $FILE{/com/openbravo/pos/templates/coin.20cent.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('26', 'coin.10cent', 1, $FILE{/com/openbravo/pos/templates/coin.10cent.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('27', 'coin.5cent', 1, $FILE{/com/openbravo/pos/templates/coin.5cent.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('28', 'coin.2cent', 1, $FILE{/com/openbravo/pos/templates/coin.2cent.png});
INSERT INTO RESOURCES(ID, NAME, RESTYPE, CONTENT) VALUES('29', 'coin.1cent', 1, $FILE{/com/openbravo/pos/templates/coin.1cent.png});

-- v2.10 - v2.20

CREATE TABLE TAXCUSTCATEGORIES (
    ID VARCHAR NOT NULL,
    NAME VARCHAR NOT NULL,
    PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX TAXCUSTCAT_NAME_INX ON TAXCUSTCATEGORIES(NAME);

CREATE TABLE TAXCATEGORIES (
    ID VARCHAR NOT NULL,
    NAME VARCHAR NOT NULL,
    PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX TAXCAT_NAME_INX ON TAXCATEGORIES(NAME);
INSERT INTO TAXCATEGORIES(ID, NAME) VALUES ('000', 'Tax Exempt');
INSERT INTO TAXCATEGORIES(ID, NAME) VALUES ('001', 'Tax Standard');
INSERT INTO TAXCATEGORIES (ID, NAME) SELECT ID, NAME FROM TAXES;

ALTER TABLE TAXES ADD COLUMN CATEGORY VARCHAR;
ALTER TABLE TAXES ADD COLUMN CUSTCATEGORY VARCHAR;
ALTER TABLE TAXES ADD COLUMN PARENTID VARCHAR;
ALTER TABLE TAXES ADD COLUMN RATECASCADE BOOLEAN;
ALTER TABLE TAXES ADD COLUMN RATEORDER INTEGER;
ALTER TABLE TAXES ADD CONSTRAINT TAXES_CAT_FK FOREIGN KEY (CATEGORY) REFERENCES TAXCATEGORIES(ID);
ALTER TABLE TAXES ADD CONSTRAINT TAXES_CUSTCAT_FK FOREIGN KEY (CUSTCATEGORY) REFERENCES TAXCUSTCATEGORIES(ID);
ALTER TABLE TAXES ADD CONSTRAINT TAXES_TAXES_FK FOREIGN KEY (PARENTID) REFERENCES TAXES(ID);
UPDATE TAXES SET CATEGORY = ID, RATECASCADE = FALSE;
ALTER TABLE TAXES ALTER COLUMN CATEGORY SET NOT NULL;
ALTER TABLE TAXES ALTER COLUMN RATECASCADE SET NOT NULL;

ALTER TABLE PRODUCTS ADD COLUMN TAXCAT VARCHAR;
ALTER TABLE PRODUCTS ADD CONSTRAINT PRODUCTS_TAXCAT_FK FOREIGN KEY (TAXCAT) REFERENCES TAXCATEGORIES(ID);
UPDATE PRODUCTS SET TAXCAT = TAX;
ALTER TABLE PRODUCTS ALTER COLUMN TAXCAT SET NOT NULL;
ALTER TABLE PRODUCTS DROP CONSTRAINT PRODUCTS_FK_2;
ALTER TABLE PRODUCTS DROP COLUMN TAX;

ALTER TABLE CUSTOMERS ADD COLUMN SEARCHKEY VARCHAR;
UPDATE CUSTOMERS SET SEARCHKEY = ID;
ALTER TABLE CUSTOMERS ALTER COLUMN SEARCHKEY SET NOT NULL;
CREATE UNIQUE INDEX CUSTOMERS_SKEY_INX ON CUSTOMERS(SEARCHKEY);

ALTER TABLE CUSTOMERS ADD COLUMN ADDRESS2 VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN POSTAL VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN CITY VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN REGION VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN COUNTRY VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN FIRSTNAME VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN LASTNAME VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN EMAIL VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN PHONE VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN PHONE2 VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN FAX VARCHAR;
ALTER TABLE CUSTOMERS ADD COLUMN TAXCATEGORY VARCHAR;
ALTER TABLE CUSTOMERS ADD CONSTRAINT CUSTOMERS_TAXCAT FOREIGN KEY (TAXCATEGORY) REFERENCES TAXCUSTCATEGORIES(ID);

ALTER TABLE CLOSEDCASH ADD COLUMN HOSTSEQUENCE INTEGER;  
UPDATE CLOSEDCASH SET HOSTSEQUENCE = 0;
ALTER TABLE CLOSEDCASH ALTER COLUMN HOSTSEQUENCE SET NOT NULL;
CREATE INDEX CLOSEDCASH_SEQINX ON CLOSEDCASH(HOST, HOSTSEQUENCE);

ALTER TABLE RECEIPTS ADD COLUMN ATTRIBUTES BYTEA;

ALTER TABLE TICKETLINES DROP COLUMN NAME;
ALTER TABLE TICKETLINES DROP COLUMN ISCOM;

CREATE TABLE TAXLINES (
    ID VARCHAR NOT NULL,
    RECEIPT VARCHAR NOT NULL,
    TAXID VARCHAR NOT NULL, 
    BASE DOUBLE PRECISION NOT NULL, 
    AMOUNT DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (ID),
    CONSTRAINT TAXLINES_TAX FOREIGN KEY (TAXID) REFERENCES TAXES(ID)
);

UPDATE PEOPLE SET CARD = NULL WHERE CARD = '';

-- v2.20 - v2.30

-- final script

DELETE FROM SHAREDTICKETS;

UPDATE APPLICATIONS SET NAME = $APP_NAME{}, VERSION = $APP_VERSION{} WHERE ID = $APP_ID{};
