load data 
characterset AL32UTF8
infile 'Product_Categories.csv' "str '\r\n'"
append
into table PRODUCT_CATEGORIES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( CATEGORYID,
             CATEGORYNAME CHAR(100),
             DESCRIPTION CHAR(4000)
           )
