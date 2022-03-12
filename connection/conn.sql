
drop database link durerPC;

create database link durerPC
 connect to system identified by "fahim"
 using '(DESCRIPTION =
       (ADDRESS_LIST =
         (ADDRESS = (PROTOCOL = TCP)
		 (HOST = 192.168.0.108)
		 (PORT = 1622))
       )
       (CONNECT_DATA =
         (SID = XE)
       )
     )'
;  
