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

-- Database upgrade script for MYSQL
-- v2.10 - v2.20

CREATE TABLE TAXCUSTCATEGORIES (
    ID VARCHAR(255) NOT NULL,
    NAME VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX TAXCUSTCAT_NAME_INX ON TAXCUSTCATEGORIES(NAME);

CREATE TABLE TAXCATEGORIES (
    ID VARCHAR(255) NOT NULL,
    NAME VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX TAXCAT_NAME_INX ON TAXCATEGORIES(NAME);
INSERT INTO TAXCATEGORIES(ID, NAME) VALUES ('000', 'Tax Exempt');
INSERT INTO TAXCATEGORIES(ID, NAME) VALUES ('001', 'Tax Standard');
INSERT INTO TAXCATEGORIES (ID, NAME) SELECT ID, NAME FROM TAXES;

ALTER TABLE TAXES ADD COLUMN CATEGORY VARCHAR(255);
ALTER TABLE TAXES ADD COLUMN CUSTCATEGORY VARCHAR(255);
ALTER TABLE TAXES ADD COLUMN PARENTID VARCHAR(255);
ALTER TABLE TAXES ADD COLUMN RATECASCADE BOOLEAN;
ALTER TABLE TAXES ADD COLUMN RATEORDER INTEGER;
ALTER TABLE TAXES ADD CONSTRAINT TAXES_CAT_FK FOREIGN KEY (CATEGORY) REFERENCES TAXCATEGORIES(ID);
ALTER TABLE TAXES ADD CONSTRAINT TAXES_CUSTCAT_FK FOREIGN KEY (CUSTCATEGORY) REFERENCES TAXCUSTCATEGORIES(ID);
ALTER TABLE TAXES ADD CONSTRAINT TAXES_TAXES_FK FOREIGN KEY (PARENTID) REFERENCES TAXES(ID);
UPDATE TAXES SET CATEGORY = ID, RATECASCADE = FALSE;
ALTER TABLE TAXES MODIFY COLUMN CATEGORY VARCHAR(255) NOT NULL;
ALTER TABLE TAXES MODIFY COLUMN RATECASCADE BOOLEAN NOT NULL;

ALTER TABLE PRODUCTS ADD COLUMN TAXCAT VARCHAR(255);
ALTER TABLE PRODUCTS ADD CONSTRAINT PRODUCTS_TAXCAT_FK FOREIGN KEY (TAXCAT) REFERENCES TAXCATEGORIES(ID);
UPDATE PRODUCTS SET TAXCAT = TAX;
ALTER TABLE PRODUCTS MODIFY COLUMN TAXCAT VARCHAR(255) NULL;
ALTER TABLE PRODUCTS DROP FOREIGN KEY PRODUCTS_FK_2;
ALTER TABLE PRODUCTS DROP COLUMN TAX;

ALTER TABLE CUSTOMERS ADD COLUMN SEARCHKEY VARCHAR(255);
UPDATE CUSTOMERS SET SEARCHKEY = ID;
ALTER TABLE CUSTOMERS MODIFY COLUMN SEARCHKEY VARCHAR(255) NOT NULL;
CREATE UNIQUE INDEX CUSTOMERS_SKEY_INX ON CUSTOMERS(SEARCHKEY);

ALTER TABLE CUSTOMERS ADD COLUMN ADDRESS2 VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN POSTAL VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN CITY VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN REGION VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN COUNTRY VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN FIRSTNAME VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN LASTNAME VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN EMAIL VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN PHONE VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN PHONE2 VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN FAX VARCHAR(255);
ALTER TABLE CUSTOMERS ADD COLUMN TAXCATEGORY VARCHAR(255);
ALTER TABLE CUSTOMERS ADD CONSTRAINT CUSTOMERS_TAXCAT FOREIGN KEY (TAXCATEGORY) REFERENCES TAXCUSTCATEGORIES(ID);

ALTER TABLE CLOSEDCASH ADD COLUMN HOSTSEQUENCE INTEGER;  
UPDATE CLOSEDCASH SET HOSTSEQUENCE = 0;
ALTER TABLE CLOSEDCASH MODIFY COLUMN HOSTSEQUENCE INTEGER NOT NULL;
CREATE INDEX CLOSEDCASH_SEQINX ON CLOSEDCASH(HOST, HOSTSEQUENCE);

ALTER TABLE RECEIPTS ADD COLUMN ATTRIBUTES MEDIUMBLOB;

ALTER TABLE TICKETLINES DROP COLUMN NAME;
ALTER TABLE TICKETLINES DROP COLUMN ISCOM;

CREATE TABLE TAXLINES (
    ID VARCHAR(255) NOT NULL,
    RECEIPT VARCHAR(255) NOT NULL,
    TAXID VARCHAR(255) NOT NULL, 
    BASE DOUBLE NOT NULL, 
    AMOUNT DOUBLE NOT NULL,
    PRIMARY KEY (ID),
    CONSTRAINT TAXLINES_TAX FOREIGN KEY (TAXID) REFERENCES TAXES(ID)
);

UPDATE PEOPLE SET CARD = NULL WHERE CARD = '';

-- v2.20 - v2.30

-- final script

DELETE FROM SHAREDTICKETS;

UPDATE APPLICATIONS SET NAME = $APP_NAME{}, VERSION = $APP_VERSION{} WHERE ID = $APP_ID{};
