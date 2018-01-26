



/********************************************************************/
/* 		macro ploting scatter plot with density plotings 			*/
/********************************************************************/
%macro scartter_density(data=,CHANNEL=,x=,y=);

proc template; *STARTS PROC TEMPLATE;
define statgraph scatdens4; *DEFINES A GRAPH TO BE CALL SCATDENS;
	begingraph; *BEGIN DEFINING THE GRAPH;
		entrytitle "&x  vs. &y Scatter plot with density plots"; *CREATE A TITLE;
			layout lattice/columns = 2 rows = 2 columnweights = (.8 .2) rowweights = (.8 .2)
			columndatarange= union rowdatarange = union;
			/*LAYOUT LATTICE/COLUMNS = 2 ROWS = 2 SETS UP A GRID, OR LATTICE, OF GRAPHS*/
			/*COLUMNWEIGHTS AND ROWWEIGHTS SETS THE RELATIVE SIZE OF THE INDIVIDUAL COLUMNS AND ROWS*/
			columnaxes;
			columnaxis /label = "&x  (%)" griddisplay = on linearopts=(tickvaluelist=(0 .2 .4 .6 .8 1.0)); /* label under first column*/

			columnaxis /label = "" griddisplay = on; /* label under the second column */
			endcolumnaxes;
			*COLUMNAXES SETS THE CHARACTERISTICS OF COLUMNS;
			/*THE SECOND ONE HAS NO LABEL (NONE WOULD FIT)*/
			rowaxes;
			rowaxis /label = "&y(%)" griddisplay = on linearopts=(tickvaluelist=(0 .2 .4 .6 .8 1.0)) ;
			rowaxis /label = "" griddisplay = on;
			endrowaxes;


				layout overlay/xaxisopts=(griddisplay=on linearopts=(viewmax=1 viewmin=0 tickvaluelist= (0 .2 .4 .6 .8 1.0)))           /* list of tick values to      */
				yaxisopts=(griddisplay=on linearopts=(viewmax=1 viewmin=0 tickvaluelist=(0 .2 .4 .6 .8 1.0)))  ; /*STARTS THE ACTUAL GRAPHING OF DOTS AND SUCH*/
				scatterplot x = &x  y = &y/ datalabel=LEVEL_OF_PLANNING group=GROUPS  ; *GRAPHS THE DOTS;
				title "&x  vs. &y";
				footnote &CHANNEL;
				/*loessplot x =PLANNED y = IMPULSE/smooth = 1 nomarkers;*/
				ellipse x = &x y = &y/ type = predicted alpha=0.1;
			endlayout;

				densityplot &y/group=GROUPS  orient = horizontal;
				densityplot &x /group=GROUPS ;
			endlayout;
		endgraph;
	end;
run;

ods graphics on/width=9in height=8in;
proc sgrender data = &data template = scatdens4;
	where CHANNEL= &CHANNEL;
run;
ods graphics off;

%mend scartter_density;

%scartter_density(data=neilson_scatter1,CHANNEL="ALL CHANNEL",x=ENGAGED,y=AUTOPILOT)
%scartter_density(data=neilson_scatter1,CHANNEL="ALL CHANNEL",x=PLANNED,y=unplanned)
%scartter_density(data=neilson_scatter1,CHANNEL="ALL CHANNEL",x=Price_Not_Consider,y=Price_Consider)
%scartter_density(data=neilson_scatter1,CHANNEL="ALL CHANNEL",x=AUTOPILOT,y=PLANNED )
%scartter_density(data=neilson_scatter1,CHANNEL="ALL CHANNEL",x=AUTOPILOT,y=Price_Not_Consider )
%scartter_density(data=neilson_scatter1,CHANNEL="ALL CHANNEL",x=PLANNED,y=Price_Not_Consider)


/***************************************************/
/*	 densityplot in sas   */
/**************************/
%macro densityplot(data=,CHANNEL=,value=);
proc sgplot data=&data;
  where CHANNEL = &CHANNEL;
  title "&value Distribution By Category Types";
  density &value/group=GROUPS scale= percent;
  xaxis values=(0 to 1 by 0.2) TICKVALUEFORMAT= percent10.;
  yaxis label="Percentage Of Category" ;
  keylegend / location=inside position=topright;
  footnote &CHANNEL;
run;

proc sgplot data=&data;
	where CHANNEL = &CHANNEL;
	title "Total categories' &value Distribution";
	histogram &value;
	density &value/scale= count;
  xaxis values=(0 to 1 by 0.2) TICKVALUEFORMAT= percent10.;/* use tickvalueformat to decide the format */
  yaxis label="Count Of Category";
run;

title 'Extreme &value Observations';
ods select ExtremeObs;
proc univariate data=&data nextrval=10;
	where CHANNEL = &CHANNEL;
   var &value;
   id LEVEL_OF_PLANNING;  /*show the name of category */
run;

%mend densityplot;

%densityplot(data=neilson_scatter1,CHANNEL="ALL CHANNEL",value=PLANNED)
%densityplot(data=neilson_scatter1,CHANNEL="ALL CHANNEL",value=AUTOPILOT)
%densityplot(data=neilson_scatter1,CHANNEL="ALL CHANNEL",value=Price_Not_Consider)



/***************************************************/
/* macro scatter plot  with label only on outliers */
/***************************************************/

%macro scartter(data=,CHANNEL=,x=,y=);

proc rank data=&data out=new groups=20;
	where CHANNEL=&CHANNEL;
	var &x;
	ranks rank_of_x;
run;

proc rank data=new out=new1 groups=20;
	var &y;
	ranks rank_of_y;
run;

data new2;
	set new1;
	format category_outlier $32.;

	if  0< rank_of_y <19 and 0< rank_of_x <19	then category_outlier = "";
	else											 category_outlier = LEVEL_OF_PLANNING;

run;

ods graphics on//*width=9in height=8in*/;
proc sgplot data=new2;
	scatter x=&x y=&y /datalabel=category_outlier group=GROUPS;
	xaxis values= (0 to 1 by 0.2);
	yaxis values= (0 to 1 by 0.2);
	title "Relation Between &x and &y";
	footnote &CHANNEL;
	ellipse x=&x y=&y ;
run;
ods graphics off;

%mend scartter;

%scartter(data=neilson_different_channels2,CHANNEL="ALL CHANNEL",x=AUTOPILOT,y=PLANNED )
%scartter(data=neilson_different_channels2,CHANNEL="ALL CHANNEL",x=AUTOPILOT,y=Price_Not_Consider )
%scartter(data=neilson_different_channels2,CHANNEL="ALL CHANNEL",x=PLANNED,y=Price_Not_Consider)
