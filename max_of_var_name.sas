/***************************************************************************************************/
/* Sample 46471: Return the variable name that contains the max or min value across an observation */
/* resource from SAS 		*/
/****************************************************************************************************/


/** Sample data set **/
data one;                                                                                                                               
input a b c d e;                                                                                                                        
cards;                                                                                                                                  
1 3 12 6 15                                                                                                                             
34 583 294 493 2                                                                                                                        
;                                                                                                                                       



/*	doblin_survey */
 
%macro test(dsn,vars,func);                                                                                                             
data new;                                                                                                                  
 set &dsn;                                                                                                                              
  array list(*) &vars;                                                                                                                  
  &func = vname(list[whichn(&func(of list[*]), of list[*])]);                                                                          
run;                                                                                                                                    
%mend test; 
 
/** retrieve maximum value from a b and c **/                                                                                                                                    
%test(one,a b c,max)                                                                                                                    
                                                                                                                                        
proc print;                                                                                                                             
run;                                                                                                                                    

/** retrieve maximum value from all numeric variables **/                                                                                                                                        
%test(one,_numeric_,max)                                                                                                                
                                                                                                                                        
proc print;                                                                                                                             
run; 