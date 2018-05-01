data test;
	set new;

	array market_banner {*} A7_15_Loblaws_freq A7_17_Zehrs_freq A7_10_Your_Independent_freq 'A7_11_T&T_freq'n 'A7_18_Valu-Mart_freq'n
					A7_24_Provigo_freq A7_26_Atlantic_Superstore_freq A7_27_Dominion_freq A7_19_Fortinos_freq A7_47_City_Market_freq;
	
	min_freq = min(A7_15_Loblaws_freq,A7_17_Zehrs_freq,A7_10_Your_Independent_freq ,'A7_11_T&T_freq'n ,'A7_18_Valu-Mart_freq'n,
					A7_24_Provigo_freq, A7_26_Atlantic_Superstore_freq, A7_27_Dominion_freq, A7_19_Fortinos_freq ,A7_47_City_Market_freq);
	count =0;/* and you have to set count =0, if not, then will keep adding up on every record */

	do i=1 to dim(market_banner);

	/*count = 0; don't set count =0, other wise every time reset count =0 */
	if market_banner{i}= min_freq then count  +1; /* don't necessary for a else statment */
	end;

	drop i;

run;

proc freq data=test ;
 tables count/missing;
run;