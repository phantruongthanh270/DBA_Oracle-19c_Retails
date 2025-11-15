load data 
characterset AL32UTF8
infile 'Products.csv' "str '\r\n'"
append
into table PRODUCTS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( PRODUCTID,
             PRODUCTNAME CHAR(255),
             CATEGORYID,
             UNITID,
             STATUSID,
             DESCRIPTION CHAR(4000),
             CREATEDDATE TIMESTAMP "YYYY-MM-DD HH24:MI:SS"
           )
