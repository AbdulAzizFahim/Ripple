set lines 256
set trimout on
set tab off

clear screen;
set serveroutput on;
set verify off;


clear screen
drop table ACCOUNT;
drop table dummy;
Create Table Account(ACno NUMBER, name VARCHAR(20), pin VARCHAR(20), location VARCHAR(20), balance VARCHAR(20));

Create Table dummy(id NUMBER,acc NUMBER);

INSERT into Account values(1, 'fahim','3241','DHK','612');
INSERT into Account values(2, 'rifat','6251','DHK','1022');
INSERT into Account values(3, 'pabon','9859','DHK','6533');
INSERT into Account values(4, 'saief','6996','DHK','8956');
INSERT into Account values(5, 'pritul','2112','DHK','7126');



CREATE or REPLACE TRIGGER Complete
AFTER UPDATE 
on Account
DECLARE
	BEGIN 
		DBMS_OUTPUT.PUT_LINE('Your Update is successfully Done');
	END;
/








create or REPLACE PACKAGE gate as 

	glob NUMBER;
	
	PROCEDURE ready;
	
	
	FUNCTION strEnc(string in VARCHAR)
	return VARCHAR;
	FUNCTION strDec(string in VARCHAR)
	return VARCHAR;
	
	FUNCTION numEnc(num NUMBER)
	return VARCHAR;
	FUNCTION numDec(string VARCHAR)
	return NUMBER;
	
	
	PROCEDURE login(acc in NUMBER, pass in varchar);
	FUNCTION showBalance(id in NUMBER)
	return NUMBER;
	PROCEDURE sendMoney(acc in number, amount in NUMBER);
	PROCEDURE changePin(acc in number , newPin VARCHAR);
end gate;
/

create or REPLACE PACKAGE body gate as 

	glob NUMBER:=0;
	FUNCTION strEnc(string in VARCHAR)
	return VARCHAR is 
	sz NUMBER:= LENGTH(string);
	op VARCHAR(20);
	mp NUMBER;
	begin 
	for i in 1..sz loop 
	mp := ASCII(SUBSTR(string,i,1));
	mp:= mp+1;
	
	if(mp = 123) then 
		mp:= 97;
	end if;
	
	
	op:= CONCAT(op,CHR(mp));
	end loop;

	return op;
	end strEnc;
-----------------------------------------------------------------	
	
	FUNCTION strDec(string in VARCHAR)
	return VARCHAR is 
	sz NUMBER:= LENGTH(string);
	op VARCHAR(20);
	mp NUMBER;
	begin 
	for i in 1..sz loop 
	mp := ASCII(SUBSTR(string,i,1));

	mp:= mp-1;
	
	if(mp = 96) then 
		mp:= 122;
	end if;
	
	op:= CONCAT(op,CHR(mp));
	end loop;
	
	return op;
	end strDec;
-----------------------------------------------------------------	
	FUNCTION numEnc(num in NUMBER)
	return VARCHAR is 
	string VARCHAR(20):= TO_CHAR(num);
	sz NUMBER:= LENGTH(string);
	op VARCHAR(20);
	mp NUMBER;
	begin 
	for i in 1..sz loop 
	mp := ASCII(SUBSTR(string,i,1));
	mp:= mp+49;
	op:= CONCAT(op,CHR(mp));
	end loop;
	
	return op;
	end numEnc;
-----------------------------------------------------------------
	FUNCTION numDec(string in VARCHAR)
	return NUMBER is 
	sz NUMBER:= LENGTH(string);
	op VARCHAR(20);
	mp NUMBER;
	begin 
	for i in 1..sz loop 
	mp := ASCII(SUBSTR(string,i,1));
	mp:= mp-49;
	op:= CONCAT(op,CHR(mp));
	end loop;
	
	return TO_NUMBER(op);
	end numDec;
-----------------------------------------------------------------	


	PROCEDURE ready is 
	nm VARCHAR(20);
	pn VARCHAR(20);
	bl VARCHAR(20);
	begin 
	for i in (select * from Account) loop 
		nm:= strEnc(i.name);
		pn:= numEnc(TO_NUMBER(i.pin));
		bl:= numEnc(i.balance);
		
	update account
	set name = nm,pin = pn, balance = bl
	where ACno = i.acno;
		commit;
	end loop;
	for i in (select * from Account@durerPC) loop 
		nm:= strEnc(i.name);
		pn:= numEnc(TO_NUMBER(i.pin));
		bl:= numEnc(i.balance);
		
	update account@durerPC
	set name = nm,pin = pn, balance = bl
	where ACno = i.acno;
	commit;
	end loop;
	end ready;
	
	
	
	
	
-----------------------------------------------------------------
	PROCEDURE login(acc in NUMBER, pass in varchar) IS
	
	cnt NUMBER:=0;
	num VARCHAR(20) := gate.numEnc(TO_NUMBER(pass));
	nm VARCHAR(20);
	begin 
	
		select count(*) into cnt from ACCOUNT where ACNO =  acc and pin = num;
	
		if(cnt = 1) then 
			select name into nm from ACCOUNT where ACNO =  acc and pin = num;
			
			nm:= gate.strDec(nm);
			
			dbms_output.put_line('Hello ' || nm || ' , Welcome to Ripple');
			insert into dummy values (1,acc);
			return;
		end if;

		select count(*) into cnt from ACCOUNT@durerpc where ACNO =  acc and pin = num;
		if(cnt = 1) then 
			select name into nm from ACCOUNT@durerpc where ACNO =  acc and pin = num;
			nm:= gate.strDec(nm);
				for i in 1..5 loop 
				DBMS_OUTPUT.PUT_LINE(' ');
				end loop;
			dbms_output.put_line('Hello ' || nm || ' , Welcome to Ripple');
			insert into dummy values (1,acc);
			return;
		end if;
		
		if (cnt = 0) then 
				for i in 1..5 loop 
				DBMS_OUTPUT.PUT_LINE(' ');
				end loop;
			dbms_output.put_line('Incorrect Account Number or Password');
			insert into dummy values (1,99);
		end if;
		
	end login;
-----------------------------------------------------------------	
	
	FUNCTION showBalance(id in NUMBER)
	return NUMBER IS
	
	bl VARCHAR(20);
	cnt NUMBER:=0;
	
	begin
	select count(*) into cnt from account where acno = id;
	
	if(cnt = 1) then 
	select balance into bl from Account where acno = id;
	return numDec(bl);
	end if;
	
	select count(*) into cnt from account@durerpc where acno = id;
	
	if(cnt = 1) then 
	select balance into bl from Account@durerpc where acno = id;
	return numDec(bl);
	end if;
	
	
	return -99;
	END ShowBalance;
-----------------------------------------------------------------		
	PROCEDURE sendMoney(acc in number, amount in NUMBER) is 
	
	cnt number:=0;
	bl NUMBER;
	bal VARCHAR(20);
	
	begin 
	
	select count(*) into cnt from account where acno = acc;
	if(cnt = 1) then 
	select balance into bal from account where acno = acc;
	bl:= numDec(bal) + amount;
	bal := gate.numEnc(bl);
	update account
	set balance = bal
	where acno = acc;
	commit;
	dbms_output.put_line('Money Sent');
	return;
	end if;
	
	select count(*) into cnt from account@durerPC where acno = acc;
	if(cnt = 1) then 
	select balance into bal from account@durerPC where acno = acc;
	bl:= numDec(bal) + amount;
	bal := gate.numEnc(bl);
	update account
	set balance = bal
	where acno = acc;
	commit;
		for i in 1..5 loop 
	DBMS_OUTPUT.PUT_LINE(' ');
	end loop;
	dbms_output.put_line('Money Sent');
	return;
	end if;
		for i in 1..5 loop 
	DBMS_OUTPUT.PUT_LINE(' ');
	end loop;
	
	dbms_output.put_line('INVALID ID');
	insert into dummy values(2,22);
	end sendMoney;
	
	
	
	
	
-----------------------------------------------------------------		
	
	PROCEDURE changePin(acc in number , newPin VARCHAR) IS
	
	cnt number:=0;
	np VARCHAR(20);
	
	begin 
	select count(*) into cnt from account where acno = acc;
	if(cnt = 1) then 
		
				

		cnt:=TO_NUMBER(newPin);
		
		np:=numEnc(cnt);
		
		
		update ACCOUNT
		set pin = np
		where acno = acc;
		commit;
			for i in 1..5 loop 
	DBMS_OUTPUT.PUT_LINE(' ');
	end loop;
		dbms_output.put_line('PIN Changed Successfully');
		return;
	
	end if;
	select count(*) into cnt from account@durerPC where acno = acc;
	if(cnt = 1) then 
		
		cnt:=TO_NUMBER(newPin);
		
		np:=numEnc(cnt);
		
		
		update ACCOUNT@durerPC
		set pin = np
		where acno = acc;
		commit;
			for i in 1..5 loop 
	DBMS_OUTPUT.PUT_LINE(' ');
	end loop;
		dbms_output.put_line('PIN Changed Successfully');
	return;
	end if;
		for i in 1..5 loop 
	DBMS_OUTPUT.PUT_LINE(' ');
	end loop;
	dbms_output.put_line('INVALID ID');
	
	
	end changePin;
end gate;
/

	


  CREATE or replace VIEW beforeENC AS
  SELECT acno,name,pin,location,balance
  FROM account
  union
  SELECT acno,name,pin,location,balance
  FROM account@durerPC;
  
  begin 
  dbms_output.put_line('Before Encryption:');
  dbms_output.put_line('Accout no	Name		PIN 		Location 	Balance  ');
  for i in (select * from beforeENC) loop 
	dbms_output.put_line(i.acno || '		' || i.name || '		' ||i.pin || '		'  ||i.location || '		' ||i.balance);
  end loop; 
  end;
  /
  










begin 
	gate.ready;
end;
/

 CREATE or replace VIEW afterENC AS
  SELECT acno,name,pin,location,balance
  FROM account
  union
  SELECT acno,name,pin,location,balance
  FROM account@durerPC;
  
 begin 
  dbms_output.put_line('After Encryption:');
  dbms_output.put_line('Accout no	Name		PIN 		Location 	Balance  ');
  for i in (select * from beforeENC) loop 
	dbms_output.put_line(i.acno || '		' || i.name || '		' ||i.pin || '		'  ||i.location || '		' ||i.balance);
  end loop; 
	
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
  	DBMS_OUTPUT.PUT_LINE('********LOGIN WINDOW*********');
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
  
  end;
  /





accept x NUMBER prompt 'enter account number:'
accept y CHAR prompt 'enter pin:'

declare 
	pn VARCHAR(20):='&y';
	acc NUMBER:=&x;
	negative EXCEPTION;

begin 
	if(acc<1) then 
			RAISE negative;
	end if;
	gate.login(acc,pn);
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE('********SHOW BALANCE WINDOW*********');
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
	
	EXCEPTION
			WHEN negative THEN
				DBMS_OUTPUT.PUT_LINE('Enter a positive account Number');
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('Something is wrong');
	
end;
/

accept x NUMBER prompt 'To show balance enter 1:'


declare 
	num NUMBER:=&x;
	

begin 
	if(num = 1) then 
	select acc into num from dummy where id = 1;
	num:=gate.showBalance(num);
	if(num = -99) then 
		dbms_output.put_line('INVALID ID');
	else 
		dbms_output.put_line('your balance is ' || num);
	end if;
	end if;
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE('********CHANGE PIN WINDOW*********');
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
end;
/




accept x char prompt 'Enter the new pin:'

declare 
	pn VARCHAR(20):='&x';
	cnt number;

begin 
	select count(*) into cnt from dummy;
	if(cnt = 1) then 
	select acc into cnt from dummy where id = 1;
	gate.changePin(cnt,pn);
	end if;
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE('********SEND MONEY WINDOW*********');
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
end;
/


accept x NUMBER prompt 'Enter the receivers account number:'
accept y NUMBER prompt 'Enter Amount:'
declare 
	acnum NUMBER:=&x;
	amount NUMBER:=&y;
	myac NUMBER;
	bal VARCHAR(20);
	cnt NUMBER;

begin
	select count(*) into cnt from dummy;
	if(cnt = 1) then
	
	select acc into myac from dummy where id = 1;
	select count(*) into cnt from account where acno = myac;
	if(cnt = 1) then 
		select balance into bal from account where acno = myac;
		cnt := gate.numDec(bal);
		if(cnt>=TO_NUMBER(amount)) then 
			
			gate.sendMoney(acnum,amount);
		else 
			dbms_output.put_line('\nInsufficient Balance\n' );
		
		end if;
	else 
		select count(*) into cnt from account@durerPC where acno = myac;
		if(cnt = 1) then 
		select balance into bal from account@durerPC where acno = myac;
		cnt := gate.numDec(bal);
		if(cnt>=TO_NUMBER(amount)) then 
			
			gate.sendMoney(acnum,amount);
		else 
			dbms_output.put_line('Insufficient Balance' );
		
		end if;
		else 
			dbms_output.put_line('Invalid ID' );
		end if;
	end if;
	end if;
	DBMS_OUTPUT.PUT_LINE(chr(10));
	DBMS_OUTPUT.PUT_LINE(chr(10));
	
	
end;
/

