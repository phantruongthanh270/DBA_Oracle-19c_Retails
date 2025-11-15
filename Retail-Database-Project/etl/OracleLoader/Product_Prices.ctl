load data 
characterset AL32UTF8
infile 'Product_Prices.csv' "str '\r\n'"
append
into table PRODUCT_PRICES
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( PRICEID,
             PRODUCTID,
             PRICE,
             EFFECTIVEDATE DATE "YYYY-MM-DD",
             EXPIRYDATE DATE "YYYY-MM-DD"
           )
