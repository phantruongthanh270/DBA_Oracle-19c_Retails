load data 
characterset AL32UTF8
infile 'Sale_Channels.csv' "str '\r\n'"
append
into table SALE_CHANNELS
fields terminated by ','
OPTIONALLY ENCLOSED BY '"' AND '"'
trailing nullcols
           ( CHANNELID,
             CHANNELNAME CHAR(100),
             DESCRIPTION CHAR(4000)
           )
