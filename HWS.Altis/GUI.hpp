#define GUI_GRID_X	(0)
#define GUI_GRID_Y	(0)
#define GUI_GRID_W	(0.025)
#define GUI_GRID_H	(0.04)
#define GUI_GRID_WAbs	(1)
#define GUI_GRID_HAbs	(1)

class HWS_RscText
{
	x = 0;
	y = 0;
	h = 0.037;
	w = 0.3;
	type = 0;
	style = 0;
	shadow = 1;
	font = "PuristaMedium";
	text = "";
	lineSpacing = 1;
	SizeEx = 0.03;
	ColorBackground[] = {0,0,0,0};
	ColorText[] = {1,1,1,1};
	colorShadow[] = {0, 0, 0, 0.5};
};

class HWS_RscButton
{
	access = 0;
	type = 1;
	text = "";
	colorText[] = {0.8784,0.8471,0.651,0.8};
	colorDisabled[] = {0.4,0.4,0.4,0.3};
	colorBackground[] = {0.15, 0.4, 0.65,0.3};//{0.05, 0.5, 0.75,0.5};
	colorBackgroundDisabled[] = {0.95,0.95,0.95,0.3};
	colorBackgroundActive[] = {0.1, 0.3, 0.7,0.3};//{0.05, 0.5, 0.75,0.2};
	colorFocused[] = {0.1, 0.2, 0.6,0.3};//{0.05, 0.5, 0.75};
	colorShadow[] = {0.04,0.04,0.04,0.1};//{0.023529,0,0.0313725,1};
	colorBorder[] = {0.04,0.04,0.04,0.1};//{0.023529,0,0.0313725,1};
	soundEnter[] = {"\A3\ui_f\data\sound\rscbutton\soundenter" ,0.09,1};
	soundPush[] = {"\A3\ui_f\data\sound\rscbutton\soundpush" ,0.09,1};
	soundClick[] = {"\A3\ui_f\data\sound\rscbutton\soundclick" ,0.09,1};
	soundEscape[] = {"\A3\ui_f\data\sound\rscbutton\soundescape" ,0.09,1};
	style = 2;
	x = 0;
	y = 0;
	w = 0.095589;
	h = 0.039216;
	shadow = 2;
	font = "Puristamedium";
	sizeEx = 0.03;
	offsetX = 0.003;
	offsetY = 0.003;
	offsetPressedX = 0.002;
	offsetPressedY = 0.002;
	borderSize = 0;
	};

class HWS_RscFrame
{
	type = 0;
	idc = -1;
	style = 64;
	shadow = 2;
	colorBackground[] = {0,0,0,0};
	colorText[] = {0.1,0.6,1,1};
	font = "Puristamedium";
	sizeEx = 0.03;
	text = "";
};

class ScrollBar 
	{
 	color[] = {1,1,1,0.6};
	colorActive[] = {1,1,1,1};
	colorDisabled[] = {1,1,1,0.3};
	thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
	arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
	arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
	border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
	shadow = 0;
 	};

class HWS_RscCombo
{
	access = 0;
	type = 4;
	style = 0;
	colorSelect[] = {0.023529,0,0.0313725,1};
	colorText[] = {0.023529,0,0.0313725,1};
	colorBackground[] = {0.75,0.75,0.75,0.9};
	colorScrollbar[] = {0.023529,0,0.0313725,0.9};
	colorSelectBackground[] = {0.6,0.6,0.6,0.85};//{0.8784,0.8471,0.651,1}
	soundSelect[] = {"\A3\ui_f\data\sound\rscbutton\soundclick",0.08,1};
	soundExpand[] = {"\A3\ui_f\data\sound\rscbutton\soundenter",1,1};
	soundCollapse[] = {"\A3\ui_f\data\sound\rscbutton\soundenter",1,1};
	maxHistoryDelay = 1;
	class ComboScrollBar : ScrollBar 
		{
	 	color[] = {0.95,0.95,0.95,0.3};
		colorActive[] = {0.95,0.95,0.95,0.3};
		colorDisabled[] = {0.95,0.95,0.95,0.3};
		thumb = "\A3\ui_f\data\gui\cfg\scrollbar\thumb_ca.paa";
		arrowFull = "\A3\ui_f\data\gui\cfg\scrollbar\arrowFull_ca.paa";
		arrowEmpty = "\A3\ui_f\data\gui\cfg\scrollbar\arrowEmpty_ca.paa";
		border = "\A3\ui_f\data\gui\cfg\scrollbar\border_ca.paa";
		shadow = 0;
	 	};
 
	x = 0;
	y = 0;
	w = 0.12;
	h = 0.035;
	shadow = 0;
	arrowEmpty = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_ca.paa";
	arrowFull = "\A3\ui_f\data\GUI\RscCommon\rsccombo\arrow_combo_active_ca.paa";
	wholeHeight = 0.45;
	color[] = {0,0,0,0.6};
	colorActive[] = {0,0,0,1};
	colorDisabled[] = {0,0,0,0.3};
	font = "Puristamedium";
	sizeEx = 0.03921;
};

class RscEdit
{
	access = 0;
	type = 2;
	style = 16;
	x = 0;
	y = 0;
	h = 0.04;
	w = 0.2;
	colorBackground[] = {0,0,0,0.75};
	colorText[] = {1,1,0.8,1};
	colorSelection[] = {0.8,0.8,0.7,0.25};
	colorDisabled[] = {1,1,1,0.5};
	font = "Puristamedium";
	htmlControl = 1;
	sizeEx = 0.04;
	autocomplete = "";
	text = "";
	size[] = {4,4};
	shadow = 0;
};

class HWS_RscPicture
{
	access = 0;
	type = 0;
	idc = -1;
	style = 144;//48
	colorBackground[] = {0,0,0,0};
	colorText[] = {1,1,1,1};
	font = "TahomaB";
	sizeEx = 0;
	lineSpacing = 0;
	text = "";
	fixedWidth = 0;
	shadow = 0;
	x = 0;
	y = 0;
	w = 0.2;
	h = 0.15;
};

class HWS_RscMapControl
{
	widthRailWay = 1;
	deletable = 0;
	fade = 0;
	access = 0;
	type = CT_MAP_MAIN;
	idc = 51;
	style = ST_MULTI + ST_TITLE_BAR;
	colorBackground[] = {0.969,0.957,0.949,1};
	colorOutside[] = {0,0,0,1};
	colorText[] = {0,0,0,1};
	font = "TahomaB";
	sizeEx = 0.04;
	colorSea[] = {0.467,0.631,0.851,0.5};
	colorForest[] = {0.624,0.78,0.388,0.5};
	colorRocks[] = {0,0,0,0.3};
	colorCountlines[] = {0.572,0.354,0.188,0.25};
	colorMainCountlines[] = {0.572,0.354,0.188,0.5};
	colorCountlinesWater[] = {0.491,0.577,0.702,0.3};
	colorMainCountlinesWater[] = {0.491,0.577,0.702,0.6};
	colorForestBorder[] = {0,0,0,0};
	colorRocksBorder[] = {0,0,0,0};
	colorPowerLines[] = {0.1,0.1,0.1,1};
	colorRailWay[] = {0.8,0.2,0,1};
	colorNames[] = {0.1,0.1,0.1,0.9};
	colorInactive[] = {1,1,1,0.5};
	colorLevels[] = {0.286,0.177,0.094,0.5};
	colorTracks[] = {0.84,0.76,0.65,0.15};
	colorRoads[] = {0.7,0.7,0.7,1};
	colorMainRoads[] = {0.9,0.5,0.3,1};
	colorTracksFill[] = {0.84,0.76,0.65,1};
	colorRoadsFill[] = {1,1,1,1};
	colorMainRoadsFill[] = {1,0.6,0.4,1};
	colorGrid[] = {0.1,0.1,0.1,0.6};
	colorGridMap[] = {0.1,0.1,0.1,0.6};
	stickX[] = {0.2,["Gamma",1,1.5]};
	stickY[] = {0.2,["Gamma",1,1.5]};
	class Legend
	{
		colorBackground[] = {1,1,1,0.5};
		color[] = {0,0,0,1};
		x = SafeZoneX + GUI_GRID_W;
		y = SafeZoneY + safezoneH - 4.5 * GUI_GRID_H;
		w = 10 * GUI_GRID_W;
		h = 3.5 * GUI_GRID_H;
		font = "RobotoCondensed";
		sizeEx = GUI_TEXT_SIZE_SMALL;
	};
	class ActiveMarker
	{
		color[] = {0.3,0.1,0.9,1};
		size = 50;
	};
	class Command
	{
		color[] = {1,1,1,1};
		icon = "\a3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
		size = 18;
		importance = 1;
		coefMin = 1;
		coefMax = 1;
	};
	class Task
	{
		taskNone = "#(argb,8,8,3)color(0,0,0,0)";
		taskCreated = "#(argb,8,8,3)color(0,0,0,1)";
		taskAssigned = "#(argb,8,8,3)color(1,1,1,1)";
		taskSucceeded = "#(argb,8,8,3)color(0,1,0,1)";
		taskFailed = "#(argb,8,8,3)color(1,0,0,1)";
		taskCanceled = "#(argb,8,8,3)color(1,0.5,0,1)";
		colorCreated[] = {1,1,1,1};
		colorCanceled[] = {0.7,0.7,0.7,1};
		colorDone[] = {0.7,1,0.3,1};
		colorFailed[] = {1,0.3,0.2,1};
		color[] =
		{
			"(profilenamespace getvariable ['IGUI_TEXT_RGB_R',0])",
			"(profilenamespace getvariable ['IGUI_TEXT_RGB_G',1])",
			"(profilenamespace getvariable ['IGUI_TEXT_RGB_B',1])",
			"(profilenamespace getvariable ['IGUI_TEXT_RGB_A',0.8])"
		};
		icon = "\A3\ui_f\data\map\mapcontrol\taskIcon_CA.paa";
		iconCreated = "\A3\ui_f\data\map\mapcontrol\taskIconCreated_CA.paa";
		iconCanceled = "\A3\ui_f\data\map\mapcontrol\taskIconCanceled_CA.paa";
		iconDone = "\A3\ui_f\data\map\mapcontrol\taskIconDone_CA.paa";
		iconFailed = "\A3\ui_f\data\map\mapcontrol\taskIconFailed_CA.paa";
		size = 27;
		importance = 1;
		coefMin = 1;
		coefMax = 1;
	};
	class CustomMark
	{
		color[] = {1,1,1,1};
		icon = "\a3\ui_f\data\map\mapcontrol\custommark_ca.paa";
		size = 18;
		importance = 1;
		coefMin = 1;
		coefMax = 1;
	};
	class Tree
	{
		color[] = {0.45,0.64,0.33,0.4};
		icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
		size = 12;
		importance = "0.9 * 16 * 0.05";
		coefMin = 0.25;
		coefMax = 4;
	};
	class SmallTree
	{
		color[] = {0.45,0.64,0.33,0.4};
		icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
		size = 12;
		importance = "0.6 * 12 * 0.05";
		coefMin = 0.25;
		coefMax = 4;
	};
	class Bush
	{
		color[] = {0.45,0.64,0.33,0.4};
		icon = "\A3\ui_f\data\map\mapcontrol\bush_ca.paa";
		size = "14/2";
		importance = "0.2 * 14 * 0.05 * 0.05";
		coefMin = 0.25;
		coefMax = 4;
	};
	class Church
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\church_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Chapel
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\Chapel_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Cross
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\Cross_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Rock
	{
		color[] = {0.1,0.1,0.1,0.8};
		icon = "\A3\ui_f\data\map\mapcontrol\rock_ca.paa";
		size = 12;
		importance = "0.5 * 12 * 0.05";
		coefMin = 0.25;
		coefMax = 4;
	};
	class Bunker
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
		size = 14;
		importance = "1.5 * 14 * 0.05";
		coefMin = 0.25;
		coefMax = 4;
	};
	class Fortress
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\bunker_ca.paa";
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.25;
		coefMax = 4;
	};
	class Fountain
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\fountain_ca.paa";
		size = 11;
		importance = "1 * 12 * 0.05";
		coefMin = 0.25;
		coefMax = 4;
	};
	class ViewTower
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\viewtower_ca.paa";
		size = 16;
		importance = "2.5 * 16 * 0.05";
		coefMin = 0.5;
		coefMax = 4;
	};
	class Lighthouse
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\lighthouse_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Quay
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\quay_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Fuelstation
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\fuelstation_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Hospital
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\hospital_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class BusStop
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\busstop_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class LineMarker
	{
		textureComboBoxColor = "#(argb,8,8,3)color(1,1,1,1)";
		lineWidthThin = 0.008;
		lineWidthThick = 0.014;
		lineDistanceMin = 3e-005;
		lineLengthMin = 5;
	};
	class Transmitter
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\transmitter_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Stack
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\stack_ca.paa";
		size = 16;
		importance = "2 * 16 * 0.05";
		coefMin = 0.4;
		coefMax = 2;
	};
	class Ruin
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\ruin_ca.paa";
		size = 16;
		importance = "1.2 * 16 * 0.05";
		coefMin = 1;
		coefMax = 4;
	};
	class Tourism
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\tourism_ca.paa";
		size = 16;
		importance = "1 * 16 * 0.05";
		coefMin = 0.7;
		coefMax = 4;
	};
	class Watertower
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\watertower_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Waypoint
	{
		color[] = {1,1,1,1};
		importance = 1;
		coefMin = 1;
		coefMax = 1;
		icon = "\a3\ui_f\data\map\mapcontrol\waypoint_ca.paa";
		size = 18;
	};
	class WaypointCompleted
	{
		color[] = {1,1,1,1};
		importance = 1;
		coefMin = 1;
		coefMax = 1;
		icon = "\a3\ui_f\data\map\mapcontrol\waypointcompleted_ca.paa";
		size = 18;
	};
	colorTrails[] = {0.84,0.76,0.65,0.15};
	colorTrailsFill[] = {0.84,0.76,0.65,0.65};
	class power
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\power_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class powersolar
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\powersolar_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class powerwave
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\powerwave_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class powerwind
	{
		color[] = {1,1,1,1};
		icon = "\A3\ui_f\data\map\mapcontrol\powerwind_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	class Shipwreck
	{
		color[] = {0,0,0,1};
		icon = "\A3\ui_f\data\map\mapcontrol\Shipwreck_CA.paa";
		size = 24;
		importance = 1;
		coefMin = 0.85;
		coefMax = 1;
	};
	moveOnEdges = 1;
	x = "SafeZoneXAbs";
	y = SafeZoneY + 1.5 * GUI_GRID_H;
	w = "SafeZoneWAbs";
	h = SafeZoneH - 1.5 * GUI_GRID_H;
	shadow = 0;
	ptsPerSquareSea = 5;
	ptsPerSquareTxt = 20;
	ptsPerSquareCLn = 10;
	ptsPerSquareExp = 10;
	ptsPerSquareCost = 10;
	ptsPerSquareFor = 9;
	ptsPerSquareForEdge = 9;
	ptsPerSquareRoad = 6;
	ptsPerSquareObj = 9;
	showCountourInterval = 0;
	scaleMin = 0.001;
	scaleMax = 1;
	scaleDefault = 0.16;
	maxSatelliteAlpha = 0.85;
	alphaFadeStartScale = 2;
	alphaFadeEndScale = 2;
	fontLabel = "RobotoCondensed";
	sizeExLabel = GUI_TEXT_SIZE_SMALL;
	fontGrid = "TahomaB";
	sizeExGrid = 0.02;
	fontUnits = "TahomaB";
	sizeExUnits = GUI_TEXT_SIZE_SMALL;
	fontNames = "EtelkaNarrowMediumPro";
	sizeExNames = GUI_TEXT_SIZE_SMALL * 2;
	fontInfo = "RobotoCondensed";
	sizeExInfo = GUI_TEXT_SIZE_SMALL;
	fontLevel = "TahomaB";
	sizeExLevel = 0.02;
	text = "#(argb,8,8,3)color(1,1,1,1)";
	idcMarkerColor = -1;
	idcMarkerIcon = -1;
	textureComboBoxColor = "#(argb,8,8,3)color(1,1,1,1)";
	showMarkers = 1;
};

class RscCheckBoxes
{
	onLoad = "";

	idc = -1;
	type = 7; // CT_CHECKBOXES
	style = 2; // ST_CENTER

	x = 0.25;
	y = 0.25;
	w = 0.5;
	h = 0.5;

	colorText[] = {0, 1, 0, 1};
	colorTextSelect[] = {1, 0, 0, 1};

	colorBackground[] = {0, 0, 1, 0.3};
	colorSelectedBg[] = {0, 0, 0, 0.2};
	
	font = "RobotoCondensed";
	sizeEx = 0.04;
	
	onCheckBoxesSelChanged = "";
	
	columns = 8;
	rows = 4;

	strings[] = {"0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"};
	checked_strings[] = {"[0]","[1]","[2]","[3]","[4]","[5]","[6]","[7]","[8]","[9]","[10]","[11]","[12]","[13]","[14]","[15]","[16]","[17]","[18]","[19]","[20]","[21]","[22]","[23]","[24]","[25]","[26]","[27]","[28]","[29]","[30]","[31]"};
	values[] = {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};
	tooltips[] = {"tip0","tip1","tip2","tip3","tip4","tip5","tip6","tip7","tip8","tip9","tip10","tip11","tip12","tip13","tip14","tip15","tip16","tip17","tip18","tip19","tip20","tip21","tip22","tip23","tip24","tip25","tip26","tip27","tip28","tip29","tip30","tip31"};	
};

////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Rydygier, v1.063, #Syfezo)
////////////////////////////////////////////////////////
class RscHWS
	{
	IDD = 2500;
	name= "HWS";
	onLoad = "";
	MovingEnable = 0;
	enableSimulation = true;
		
	class controls
		{
		class RscBack: HWS_RscPicture
			{
			idc = 1798;
			x = 5 * GUI_GRID_W + GUI_GRID_X;
			y = -2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 30 * GUI_GRID_W;
			h = 29.5 * GUI_GRID_H;
			text = "#(argb,8,8,3)color(0.01,0.1,0.3,0.25)";			
			};
		
		class RscFrame_HWS: HWS_RscFrame
			{
			idc = 1799;
			text = "HETMAN: WAR STORIES version 1.10";
			x = 5.5 * GUI_GRID_W + GUI_GRID_X;
			y = -2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 29 * GUI_GRID_W;
			h = 29 * GUI_GRID_H;
			sizeEx = 1 * GUI_GRID_H;
			};
				
		class SA_Frame: HWS_RscFrame
			{
			idc = 1800;
			text = "Side A";
			x = 6 * GUI_GRID_W + GUI_GRID_X;
			y = -1 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class SA_Combo: HWS_RscCombo
			{
			idc = 2100;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 0 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Select the side of the first army (player's side)";
			};
			
		class SB_Frame: HWS_RscFrame
			{
			idc = 1801;
			text = "Side B";
			x = 26 * GUI_GRID_W + GUI_GRID_X;
			y = -1 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class SB_Combo: HWS_RscCombo
			{
			idc = 2101;
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 0 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Select the side of the second army";
			};
									
		class FacA_Frame: HWS_RscFrame
			{
			idc = 18000;
			text = "Faction A";
			x = 6 * GUI_GRID_W + GUI_GRID_X;
			y = 2 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};	
			
		class FacA_Combo: HWS_RscCombo
			{
			idc = 21000;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 3 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Select faction of side A";
			};
			
		class Ratio_Frame: HWS_RscFrame
			{
			idc = 1805;
			text = "A:B Ratio";
			x = 16 * GUI_GRID_W + GUI_GRID_X;
			y = 2 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};	
			
		class Ratio_Combo: HWS_RscCombo
			{
			idc = 2105;
			x = 16.5 * GUI_GRID_W + GUI_GRID_X;
			y = 3 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Set ratio of forces (group amount of side A comparing to side B, rough estimation)";
			};
			
			
		class FacB_Frame: HWS_RscFrame
			{
			idc = 18010;
			text = "Faction B";
			x = 26 * GUI_GRID_W + GUI_GRID_X;
			y = 2 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class FacB_Combo: HWS_RscCombo
			{
			idc = 21010;
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 3 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Select faction of side B";
			};
			
		class HSRA_Frame: HWS_RscFrame
			{
			idc = 1807;
			text = "Armor density A";
			x = 6 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class HSRA_Combo: HWS_RscCombo
			{
			idc = 2107;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 6 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Percentage of armored units compared to average amounts for given terrain for side A";
			};
			
		class HSRB_Frame: HWS_RscFrame
			{
			idc = 1808;
			text = "Armor density B";
			x = 26 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class HSRB_Combo: HWS_RscCombo
			{
			idc = 2108;
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 6 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Percentage of armored units compared to average amounts for given terrain for side B";
			};					
			
		class Camp_Frame: HWS_RscFrame
			{
			idc = 1806;
			text = "Campaign";
			x = 16 * GUI_GRID_W + GUI_GRID_X;
			y = 5 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class Camp_Combo: HWS_RscCombo
			{
			idc = 2106;
			x = 16.5 * GUI_GRID_W + GUI_GRID_X;
			y = 6 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Whether include next battle result in the campaign score, exclude it, reset whole progress or play in whole map mode";
			};			
			
						
		class Scale_Frame: HWS_RscFrame
			{
			idc = 1802;
			text = "Scale";
			x = 6 * GUI_GRID_W + GUI_GRID_X;
			y = 8 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
						
			
		class Scale_Combo: HWS_RscCombo
			{
			idc = 2102;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 9 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Select the scale of the battle";
			};
			
		class DT_Frame: HWS_RscFrame
			{
			idc = 1803;
			text = "Daytime";
			x = 16 * GUI_GRID_W + GUI_GRID_X;
			y = 8 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class DT_Combo: HWS_RscCombo
			{
			idc = 2103;
			x = 16.5 * GUI_GRID_W + GUI_GRID_X;
			y = 9 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Select initial daytime";
			};
			
		class OC_Frame: HWS_RscFrame
			{
			idc = 1804;
			text = "Overcast";
			x = 26 * GUI_GRID_W + GUI_GRID_X;
			y = 8 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class OC_Combo: HWS_RscCombo
			{
			idc = 2104;
			x = 26.5 * GUI_GRID_W + GUI_GRID_X;
			y = 9 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Select overcast";
			};
			
		class FSEP_Frame: HWS_RscFrame
			{
			idc = 1809;
			text = "Factions interspace";
			x = 6 * GUI_GRID_W + GUI_GRID_X;
			y = 11 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			};
			
		class FSEP_Combo: HWS_RscCombo
			{
			idc = 2109;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 12 * GUI_GRID_H + GUI_GRID_Y;
			w = 7 * GUI_GRID_W;
			h = 1 * GUI_GRID_H;
			tooltip = "Select interspace between factions, NONE - factions intermixed";
			};
			
		class RscBack2: HWS_RscPicture
			{
			idc = 121;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 15 * GUI_GRID_H + GUI_GRID_Y;
			w = 27 * GUI_GRID_W;
			h = 7 * GUI_GRID_H;
			text = "#(argb,8,8,3)color(0.1,0.1,0.2,0.2)";			
			};
			
		class ED_Frame: HWS_RscFrame
			{
			idc = 1805;
			text = "Advanced setup";
			x = 6 * GUI_GRID_W + GUI_GRID_X;
			y = 14 * GUI_GRID_H + GUI_GRID_Y;
			w = 28 * GUI_GRID_W;
			h = 8.5 * GUI_GRID_H;
			};
			
		class ED_Edit: RscEdit
			{
			idc = 120;
			x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			y = 15 * GUI_GRID_H + GUI_GRID_Y;
			w = 27 * GUI_GRID_W;
			h = 7 * GUI_GRID_H;
			text = "";
			autocomplete = "scripting";
			};
			
		class Fac_A: RscCheckBoxes
			{
			onLoad = "";

			idc = 122;
			style = 2; // ST_CENTER

			x = -6 * GUI_GRID_W + GUI_GRID_X;
			y = -2.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 10 * GUI_GRID_W;
			h = 32 * GUI_GRID_H;
			
			colorText[] = {0.75,0.75,0.75,0.75};
			colorTextSelect[] = {1,1,1,1};
			colorBackground[] = {0,0,0,0.75};
			colorSelectedBg[] = {0,0,0,0.75};
			
			font = "Puristamedium";
			sizeEx = 0.03921;
			
			onCheckBoxesSelChanged = "";
			
			columns = 1;
			rows = 32;

			strings[] = {};//{"0","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31"};
			checked_strings[] = {};//{"[0]","[1]","[2]","[3]","[4]","[5]","[6]","[7]","[8]","[9]","[10]","[11]","[12]","[13]","[14]","[15]","[16]","[17]","[18]","[19]","[20]","[21]","[22]","[23]","[24]","[25]","[26]","[27]","[28]","[29]","[30]","[31]"};
			values[] = {};//{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};
			tooltips[] = {};//{"","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""};
			};
			
		class Fac_B: Fac_A
			{
			idc = 123;

			x = 36 * GUI_GRID_W + GUI_GRID_X;
			};
			
		class Fac_A2: Fac_A
			{
			idc = 124;

			x = -16.5 * GUI_GRID_W + GUI_GRID_X;
			};
			
		class Fac_B2: Fac_A
			{
			idc = 125;

			x = 46.5 * GUI_GRID_W + GUI_GRID_X;
			};
																	
		class RscButton_HWS: HWS_RscButton
			{
			idc = 126;
			text = "TELL ME A STORY";
			x = 13 * GUI_GRID_W + GUI_GRID_X;
			y = 23.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 14 * GUI_GRID_W;
			h = 2.5 * GUI_GRID_H;
			colorText[] = {0.9,0.9,1,1};
			sizeEx = 1 * GUI_GRID_H;
			action = "[] call RYD_WS_TakeValues;";
			};
			
		class RscButton_MC: HWS_RscButton
			{
			idc = 127;
			text = "MANUAL LOCATION";
			x = 16 * GUI_GRID_W + GUI_GRID_X;
			y = -0.625 * GUI_GRID_H + GUI_GRID_Y;
			w = 8 * GUI_GRID_W;
			h = 2 * GUI_GRID_H;
			colorText[] = {0.9,0.9,1,1};
			sizeEx = 0.8 * GUI_GRID_H;
			action = "[] spawn RYD_WS_FreeChoice;";
			};
		};
	};
	
class RscMapControl;	
class RscFreeMap
	{
	IDD = 2501;
	name= "FM";
	onLoad = "";
	MovingEnable = 0;
	enableSimulation = true;

	class controls
		{
		class RscHWS_FM: HWS_RscMapControl
			{
			idc = 3;
			type = 101;
			tooltip = "LMB on the land to choose battle location, alt+LMB to cancel selection, ESC to exit";
			//x = 6.5 * GUI_GRID_W + GUI_GRID_X;
			//y = 12 * GUI_GRID_H + GUI_GRID_Y;
			//w = 27 * GUI_GRID_W;
			//h = 10 * GUI_GRID_H;
			};		
		};
	};