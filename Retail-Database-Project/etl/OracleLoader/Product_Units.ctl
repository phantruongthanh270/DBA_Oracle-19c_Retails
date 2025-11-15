load data 
characterset AL32UTF8
infile 'Product_Units.csv' "str '\r\n'"
append
into table PRODUCT_UNITS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( UNITID,
             UNITNAME CHAR(50),
             CONVERSIONRATE
           )
