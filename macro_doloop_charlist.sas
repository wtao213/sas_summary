/*************************************************/
/* macro plus do loop */
/***************************/

%macro brand_scatter_lookv3(mylist,data=,y=);

   %let n = %sysfunc(countw(&mylist));
   %do I=1 %to &n;
   %let val = %scan(&mylist,&I);

      data LCL_Data_Pull_AC_CON1_&val;
         set &data;
         where Subcategory = "&val";
      run;


	proc rank data=LCL_Data_Pull_AC_CON1_&val out=new groups=10;
	var &y;
	ranks rank_of_y;
	run;

	
	data new1;
	set new;
	format brand_outlier $32.;

	if   rank_of_y =9 	then brand_outlier = Brand_name;
	else					 brand_outlier = "";

	run;

	proc sgplot data=new1;
	where Brand_name ~="All" and &y>0;
	scatter x=Brand_name y=&y/datalabel= brand_outlier;
	title "Brand for category &val";
	xaxis display=none;
	yaxis label="sales for certain brand" ;
	footnote "AC Conv";
	run;

	ods select ExtremeObs;
	proc univariate data=LCL_Data_Pull_AC_CON1_&val nextrobs=11;/* difference between nextrobs he nextrval */
	where &y>0;
   	var &y;
   	id Brand_name;  /*show the name of category */
	run;
   %end;
%mend brand_scatter_lookv3;

%brand_scatter_lookv3(%str(HOSIERY,INNERWEAR,PURGE),data=LCL_Data_Pull_AC_CON1,y=Sales_Dollars)


/**************************************/
/* make list to get a list of variables */
/******************************************/
%let dsid = %sysfunc( open( &data ) );
%if &dsid = 0 %then %do;
   
%end;

%let nobs = %sysfunc( attrn( &dsid, NOBS ) );
%let nvars = %sysfunc( attrn( &dsid, NVARS ) );
 
/*You can use ATTRN to find out many other attributes.  There’s also an ATTRC function.
 
To get at the variable names, use do loop and the VARNAME function.
To find out if a variable is character or numeric use the VARTYPE function.*/
 
%do I = 1 %to nvars;
%let var = %sysfunc( varname( &dsid, &I ) );
    
             
%end;
 
%let dsid = %sysfunc( close( &dsid ) ); 