/******************************************************/
/* differenct method to cut dataset from wide to long */
/*******************************************************/

/*方法1： 把每一个category 的 name,sales,units,txn 截出来，然后把十个合并在一起*/
/******************************************/
/* method 1 macro cut */
/***********************/
%macro wtao_transpose(n);


DATA TEMP&n.(rename=(category&n.=category category&n.sales=categorysales
					category&n.units=categoryunits category&n.txn=categorytxn));
	SET basket1(keep=MembershipID Timeframe Salesbetween txngroupnew pocket  hhgroup
						category&n. category&n.sales
					category&n.units category&n.txn);
run;

%mend wtao_transpose;

%wtao_transpose(1); %wtao_transpose(2); %wtao_transpose(3);
%wtao_transpose(4); %wtao_transpose(5); %wtao_transpose(6);
%wtao_transpose(7); %wtao_transpose(8); %wtao_transpose(9);
%wtao_transpose(10);

data basket_full_raw;
	set temp1-temp10;
run;





/*方法2: 把原始数据编号，依次transpose top 10 的 name, units, txn, sales, 然后merge在一起。*/
/********************************************/
/*method 2: set subject to original dataset */
/*********************************************/
data prepare;
	set basket1;
	
	subject +1;
run;

proc transpose data=prepare out=longcat prefix=cat;
	by subject;	
	var Category1 Category2 Category3 Category4 Category5 
		Category6 Category7 Category8 Category9 Category10;
run;
data longcat1;
set longcat;
 membership +1;
run;
proc transpose data=prepare out=longsales prefix=sales;
	by subject;	
	var Category1Sales Category2Sales Category3Sales Category4Sales Category5Sales 
		Category6Sales Category7Sales Category8Sales Category9Sales Category10Sales;
run;

proc transpose data=prepare out=longtxn prefix=txn;
	by subject;	
	var Category1Txn Category2Txn Category3Txn Category4Txn Category5Txn 
		Category6Txn Category7Txn Category8Txn Category9Txn Category10Txn;
run;

proc transpose data=prepare out=longunit prefix=Units;
	by subject;	
	var Category1Units Category2Units Category3Units Category4Units Category5Units 
		Category6Units Category7Units Category8Units Category9Units Category10Units;
run;


/******************************************/
/* combine the info together    */
/********************************/
data long;
	merge longcat(drop=_name_) longsales(drop=_name_) longtxn(drop=_name_) longunit(drop=_name_);
	by subject;
run;

proc sort data=prepare(keep=subject  Timeframe salesBetween MembershipID  
						sales units Txn Range pocket  hhgroup txngroupnew) out=prepare2;
	by subject;
run;

data basket_full_raw;
	merge long prepare2;
	by subject;
run;



/*****************************************************/
/*	method 3: use array,done in a single data step   */
/*****************************************************/

data basket_full_raw;
	set Output_Panel_Detail_name;
	
	array category{10} $27. Category1 - Category10;
	array CategorySales{10}  Category1Sales Category2Sales Category3Sales Category4Sales Category5Sales Category6Sales Category7Sales Category8Sales
 Category9Sales Category10Sales;/* be careful about the name!!!variable sales already in the data set !!*/
 	/*array Categorytxn{10} Category1Txn - Category10Txn;*/ /* is there any suffix variable list? like prefix list txn: ? */

	do i = 1 to 10;
		CA = category{i} ;/* DO NOT USE THE SAME NAME FOR AN ARRAY AS A VARIABLE IN YOUR DATA SET !! */
		Sales = CategorySales{i}; 
		if CA ne missing then output; /* use missing instead of .  , if not sas will convert CA to num variable TT */
		/*if Sales ne missing then output;*/ /*don't need to set every array, as if missing in CA, every will be missing*/
	end;

	keep MBRSHIP_ID Timeframe Range   salesBetween CA Sales;
run;
