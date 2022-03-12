clear screen
set lines 256
set trimout on
set tab off
drop table Account;
Create Table Account(ACno NUMBER, name VARCHAR(20), pin VARCHAR(20), location VARCHAR(20), balance VARCHAR(20));


INSERT into Account values(6, 'sadman','8483','CTG','3269');
INSERT into Account values(7, 'arman','5548','CTG','6475');
INSERT into Account values(8, 'annoy','6461','CTG','9324');
INSERT into Account values(9, 'Mak','9631','CTG','9369');
INSERT into Account values(10, 'Ripin','1459','CTG','2253');
commit;