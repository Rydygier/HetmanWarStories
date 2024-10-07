_SCRname = "Boss";

private 
	[
	"_cntr","_lng","_nmbr","_sectors","_markers","_mark","_secpos","_sPosX","_sPosY","_sUrban","_sForest","_sHills","_sFlat","_sSea","_samplePos","_topArr","_sRoads","_bbCycle",
	"_text","_nbr","_sum","_alpha","_count","_strArea","_loc10","_loc5","_loc2","_loc1","_locHill","_topArr","_frstV","_nmbr","_posGrpX","_sGr","_BBHQs","_BBSide","_urgent",
	"_posGrpY","_posGrp","_valGrp","_armyPos","_ct","_change","_mainPos","_taken","_posStr","_valStr","_posStrX","_posStrY","_amDist","_mDist","_aDist","_gDst","_actDist","_BBStr",
	"_attackAxis","_color","_k","_j","_fAr","_fPnt","_fVal","_fTkn","_fX","_fY","_sAr","_sPnt","_sVal","_sTkn","_sX","_sY","_ForcesRep","_ownGroups","_hostileGroups","_BBHQGrps",
	"_isCiv","_civF","_enemyClose","_allCount","_resCount","_actCount","_flankCount","_centerCount","_BBHQs","_resArr","_chsn","_resDst","_dst","_centerArr","_centerDst","_allAreTaken",
	"_isLeft","_where","_isFlank","_isRear","_leftSectors","_rightSectors","_frontSectors","_leftAn","_leftInf","_leftVeh","_rightAn","_rightInf","_rightVeh","_frontAn","_BBSAL",
	"_frontInf","_frontVeh","_leftSANmbr","_rightSANmbr","_frontSANmbr","_leftSA","_rightSA","_frontSA","_leftSANmbr","_rightSANmbr","_frontSANmbr","_leftSpace","_rightSpace","_ctWait",
	"_frontSpace","_LmaxSpace","_RmaxSpace","_FmaxSpace","_LmaxSA","_RmaxSA","_FmaxSA","_LmaxVeh","_RmaxVeh","_FmaxVeh","_lFlank","_rFlank","_cFront","_flSMaxStr","_flSpace","_pathDone",
	"_flSAMaxStr","_flSA","_fl","_spaceF","_SAF","_flVMaxStr","_flVeh","_vehF","_vehAll","_ldrRep","_forceChar","_vehPerc","_vehAll","_vehAv","_moreVehHQ","_numAll","_forceNum",
	"_numAv","_moreNumHQ","_goingLeft","_goingRight","_goingAhead","_goingReserve","_restHQ","_ldr","_rndF","_leftNotTaken","_tkn","_rightNotTaken","_frontNotTaken","_fPos","_takenPoints",
	"_chosenT","_indx","_cPos","_cVal","_cTaken","_dstFC","_tempMax","_actT","_front","_tObj1","_tObj2","_tObj3","_tObj4","_areas","_sctrs","_pathRep","_tgtsAround","_HQpos","_HQPoints",
	"_acT","_points","_tempAct","_secsAround","_notTaken","_indx","_in","_check","_checkPos","_actPos","_losses","_currentNumber","_ownVal","_enemyVal","_enemyFactor","_lossesFactor","_actRep",
	"_nilStance","_stance","_inert","_knEnemy","_ownVal","_perDirPos","_dpX","_dpY","_dirAdd","_angle","_perPos","_perX","_perY","_BBalive","_HQ","_BBUnit","_leftFlankName",
	"_rightFlankName","_leftName","_rightName","_frontName","_isLeftName","_isFlankName","_isRearName","_centerFrontName","_xPr","_yPr","_objCount","_QH","_initD","_aliveHQ","_objRad",
	"_goingReserve0","_lastGLeft","_lastGRight","_lastGAhead","_aliveHQ","_newL","_lastGLeftN","_lastGRightN","_lastGAheadN","_fixedInitStatus","_pos","_enAr","_eA","_eP","_eT","_sA","_sP",
	"_strArea0","_k","_j","_flankOne","_goingOne","_flankTwo","_goingTwo","_resCand","_ctVal","_mapSize"
	];

_BBHQs = (_this select 0) select 0;
_BBSide = (_this select 0) select 1;
_BBHQGrps = _this select 1;

if ((_BBSide == "B") and ((count RydBBa_HQs) > 0)) then 
	{
	waitUntil
		{
		sleep 5;
		(RydBBa_Init)
		}
	};

if (RydBB_Debug) then
	{
	RydBBa_SAL globalChat format ["Big Boss %1 awakes (time: %2)",_BBSide,time];
	diag_log format ["Big Boss %1 awakes (time: %2)",_BBSide,time]
	};

	{
	waitUntil
		{
		sleep 0.1;
		_ready = _x getVariable ["RydHQ_readyForBB",false];
		(_ready)
		};
	}
foreach _BBHQGrps;

_sectors = RydBB_Sectors;

_strArea = switch (_BBSide) do
	{
	case ("A") : {missionNameSpace getVariable ["A_SAreas",[]]};
	case ("B") : {missionNameSpace getVariable ["B_SAreas",[]]};
	};
	
_BBStr = [];

if (_BBSide == "A") then {if not (isNil "RydBBa_Str") then {_BBStr = RydBBa_Str}};
if (_BBSide == "B") then {if not (isNil "RydBBb_Str") then {_BBStr = RydBBb_Str}};

_fixedInitStatus = [];

	{
	_pos = _x select 0;
	_pos = (_pos select 0) + (_pos select 1);

	_fixedInitStatus pushBack _pos
	}
foreach _BBStr;

_BBSAL = RydBBa_SAL;
if (_BBSide == "B") then {_BBSAL = RydBBb_SAL};

	{
	_BBStr pushBack [(position _x),_x getVariable "AreaValue",false]
	}
foreach (synchronizedObjects _BBSAL);

_strArea = _strArea + _BBStr;

if (RydBB_CustomObjOnly) then {_strArea = _BBStr};
////////////////////////////////////////////////////////////////////

_bbCycle = 0;
_leftSA = [];
_rightSA = [];
_frontSA = [];
_stance = "";

_leftFlankName = "LeftFlank";
_rightFlankName = "RightFlank";
_centerFrontName = "CenterFront";
_leftName = "A_Left";
_rightName = "A_Right";
_frontName = "A_Front";
_isLeftName = "A_isLeft";
_isFlankName = "A_isFlank";
_isRearName = "A_isRear";

if (_BBSide == "B") then 
	{
	_leftFlankName = "LeftFlankB";
	_rightFlankName = "RightFlankB";
	_centerFrontName = "CenterFrontB";
	_leftName = "B_Left";
	_rightName = "B_Right";
	_frontName = "B_Front";
	_isLeftName = "B_isLeft";
	_isFlankName = "B_isFlank";
	_isrearName = "B_isRear";
	};

_cntr = RydBB_MapC;
_mainPos = _cntr;
_BBalive = true;
_allAreTaken = true;

while {(RydBB_Active)} do
	{
	if not (_BBalive) exitWith 
		{
		if (RydBB_Debug) then
			{
			RydBBa_SAL globalChat format ["Big Boss %1 has no army!",_BBSide];
			diag_log format ["Big Boss %1 has no army!",_BBSide]
			};
		};
/*
	waitUntil 
		{
		sleep 5;
*/
		_allAreTaken = true;

			{
			if not (_x select 2) exitWith {_allAreTaken = false}
			}
		foreach _strArea;

		//not (_allAreTaken)
		//};

	_bbCycle = _bbCycle + 1;

	if (_bbCycle == 1) then
		{
		_code =
			{
			_SCRName = "BossC1";
			
			private ["_HQg","_side","_HQg0"];

			_HQg = _this select 0;
			_side = _this select 1;	

			_HQg0 = +_HQg;

			while {(RydBB_Active)} do
				{
					{
					if (isNull (group _x)) then
						{
						_HQg = _HQg - [_x]
						}
					else 
						{
						if (({(alive _x)} count (units (group _x))) == 0) then
							{
							_HQg = _HQg - [_x]
							}
						}
					}
				foreach _HQg0;

				if ((count _HQg) == 0) exitWith 
					{
					if (RydBB_Debug) then
						{
						RydBBa_SAL globalChat format ["Big Boss %1 has no army!",_side];
						diag_log format ["Big Boss %1 has no army!",_side]
						};
					};

				sleep 10;
				};
			};
			
		[[_BBHQs,_BBSide],_code] call RYD_Spawn
		};

	_BBHQs = [];

		{
		if not (isNull _x) then 
			{
			if (({(alive _x)} count (units _x)) > 0) then
				{
				_BBHQs set [(count _BBHQs),(leader _x)]
				}
			};
		}
	foreach _BBHQGrps;

	if ((count _BBHQs) == 0) exitWith 
		{
		if (RydBB_Debug) then
			{
			RydBBa_SAL globalChat format ["Big Boss %1 has no army!",_BBSide];
			diag_log format ["Big Boss %1 has no army!",_BBSide]
			};
		};

	if (RydBB_Debug) then
		{
		RydBBa_SAL globalChat format ["Big Boss %1 is analyzing forces...",_BBSide];
		diag_log format ["Big Boss %1 is analyzing forces...",_BBSide]
		};

	_ForcesRep = [_BBHQGrps] call RYD_ForceAnalyze;

	_ownGroups = (_ForcesRep select 0) select ((count (_ForcesRep select 0)) - 1);
	_hostileGroups = (_ForcesRep select 1) select ((count (_ForcesRep select 1)) - 1);

	if (_BBCycle == 1) then
		{
		if (RydBB_Debug) then
			{
			RydBBa_SAL globalChat format ["Big Boss %1 is checking own forces placement...",_BBSide];
			diag_log format ["Big Boss %1 is checking own forces placement...",_BBSide]
			};

		_nmbr = 0;
		_posGrpX = 0;
		_posGrpY = 0;

			{
			_posGrp = position (vehicle (leader _x));
			_valGrp = count (units _x);

			//_mark = "GrpPos" + (str (random 1000));
			//_mark = [_mark,_posGrp,"ColorGreen","ICON",[_valGrp/10,_valGrp/10],0,0.5,"DOT",(str _valGrp)] call RYD_Marker;

			for "_j" from 1 to _valGrp do
				{
				_posGrpX = _posGrpX + (_posGrp select 0);
				_posGrpY = _posGrpY + (_posGrp select 1);
				};

			_nmbr = _nmbr + _valGrp
			}
		foreach _ownGroups;

		_armyPos = _cntr;

		if (_nmbr > 0) then {_armyPos = [_posGrpX/_nmbr,_posGrpY/_nmbr,0]};

		//_mark = "Army" + (str (random 1000));
		//_mark = [_mark,_ArmyPos,"ColorGreen","ICON",[1,1],0,1,"mil_triangle",""] call RYD_Marker;


		_ct = 0;
		_change = true;

		_enAr = missionNameSpace getVariable ["B_SAreas",[]];
		if (_BBSide == "B") then {_enAr = missionNameSpace getVariable ["A_SAreas",[]]};

		while {(_change)} do
			{
			_nmbr = 0;
			_posStrX = 0;
			_posStrY = 0;

				{
				_taken = _x select 2;

				if not (_taken) then 
					{
					_posStr = _x select 0;
					_valStr = _x select 1;

					for "_j" from 1 to _valStr do
						{
						_posStrX = _posStrX + (_posStr select 0);
						_posStrY = _posStrY + (_posStr select 1);
						};

					_nmbr = _nmbr + (_x select 1)
					}
				}
			foreach _strArea;

			if (_nmbr > 0) then {_mainPos = [_posStrX/_nmbr,_posStrY/_nmbr,0]};

			_amDist = _armyPos distance _mainPos;

			_change = false;

			_civF = ["CIV_F","CIV","CIV_RU","BIS_TK_CIV","BIS_CIV_special"];
			if not (isNil ("RydBB_CivF")) then {_civF = RydBB_CivF};

				{
				_posStr = _x select 0;
				_valStr = _x select 1;
				_taken = _x select 2;

				_mDist = _posStr distance _mainPos;
				_aDist = _posStr distance _ArmyPos;

				_enemyClose = false;

					{
					if (((side _x) getFriend (side (_ownGroups select 0))) < 0.6) then
						{
						_isCiv = false;
						if ((faction (leader _x)) in _civF) then {_isCiv = true};
						if not (_isCiv) then
							{
							if (((vehicle (leader _x)) distance _posStr) < 500) exitwith {_enemyClose = true}
							}
						};

					if (_enemyClose) exitwith {}
					}
				foreach (Allgroups - _ownGroups);

				_gDst = 1000000;
				
					{
					_actDist = (vehicle (leader _x)) distance _posStr;
					if (_actDist < _gDst) then {_gDst = _actDist}
					}
				foreach _ownGroups;

				if ((((_mDist > _amDist) and (_mDist > _aDist) and (_amDist > _aDist) and (_aDist < 5000)) or (_gDst < 500) or (_aDist < 1000)) and not (_enemyClose)) then 
					{
					if not (_taken) then {_change = true};
					_pos = _x select 0;
					_pos = (_pos select 0) + (_pos select 1);
					if not (_pos in _fixedInitStatus) then {_x set [2,true]};
					}
				else
					{
					if (_taken) then {_change = true};
					_pos = _x select 0;
					_pos = (_pos select 0) + (_pos select 1);
					if not (_pos in _fixedInitStatus) then {_x set [2,false]};
					}
				}
			foreach _strArea;

			_ct = _ct + 1;

			if (_ct > 10) then {_change = false}
			};

		if ((count _enAr) > 0) then
			{
				{
				_eA = _x;
				_eP = _eA select 0;
				_eT = _eA select 2;

					{
					_sA = _x;
					_sP = _sA select 0;

					if ((_sP distance _eP) < 100) then
						{
						if (_eT) then
							{
							_sA set [2,false];
							}
						}
					}
				foreach _strArea
				}
			foreach _enAr
			};


		//_mark = "Main" + (str (random 1000));
		//_mark = [_mark,_mainPos,"ColorRed","ICON",[1,1],0,1,"mil_triangle",""] call RYD_Marker;

		_attackAxis = [_ArmyPos,_mainPos,10] call RYD_AngTowards;

		//if (RydBB_Debug) then
		if (_BBSide == "A") then
			{
			[[_strArea,_BBSide,RydBBb_Str],RYD_ObjMark] call RYD_Spawn;
			}
		else
			{
				{
				if not (_x select 2) then
					{
					RYD_WS_ObjToTakeB = RYD_WS_ObjToTakeB + 1;
					}
				}
			foreach _strArea;
			};
			
		if (RydBB_Debug) then
			{
			RydBBa_SAL globalChat format ["Big Boss %1 orients the flanks.",_BBSide];
			diag_log format ["Big Boss %1 orients the flanks.",_BBSide]
			};

			{
			_isLeft = ([(getPosATL (vehicle (leader _x))),_ArmyPos,_attackAxis] call RYD_WhereIs) select 0;
			_x setVariable ["isLeft",_isLeft]
			}
		foreach _BBHQGrps;

			{
			_isLeft = ([(_x select 0),_ArmyPos,_attackAxis] call RYD_WhereIs) select 0;
			_x set [3,_isLeft]
			}
		foreach _strArea;



		_leftSectors = [];
		_rightSectors = [];
		_frontSectors = [];

			{
			_where = [(position _x),_ArmyPos,_attackAxis] call RYD_WhereIs;
			_isLeft = _where select 0;
			_isFlank = _where select 1;
			_isRear = _where select 2;

			if (_isLeft) then 
				{
				_leftSectors set [(count _leftSectors),_x]
				} 
			else 
				{
				_rightSectors set [(count _rightSectors),_x]
				};

			if not (_isFlank) then 
				{
				_frontSectors set [(count _frontSectors),_x]
				};

			_x setVariable [_isLeftName,_isLeft];
			_x setVariable [_isFlankName,_isFlank];
			_x setVariable [_isRearName,_isRear];
			}
		foreach _sectors;

		if (RydBB_Debug) then
			{
			RydBBa_SAL globalChat format ["Big Boss %1 assigns front sections to divisions.",_BBSide];
			diag_log format ["Big Boss %1 assigns front sections to divisions.",_BBSide]
			};

		_leftAn = [_leftSectors] call RYD_TopoAnalize;

		_leftSectors = _leftAn select 0;
		_leftInf = _leftAn select 1;
		_leftVeh = _leftAn select 2;

		_rightAn = [_rightSectors] call RYD_TopoAnalize;

		_rightSectors = _rightAn select 0;
		_rightInf = _rightAn select 1;
		_rightVeh = _rightAn select 2;

		_frontAn = [_frontSectors] call RYD_TopoAnalize;

		_frontSectors = _frontAn select 0;
		_frontInf = _frontAn select 1;
		_frontVeh = _frontAn select 2;

		_leftSANmbr = 0;
		_rightSANmbr = 0;
		_frontSANmbr = 0;
		_leftSA = [];
		_rightSA = [];
		_frontSA = [];

			{
			_where = [(_x select 0),_ArmyPos,_attackAxis] call RYD_WhereIs;
			_isLeft = _where select 0;
			_isFlank = _where select 1;
			_isRear = _where select 2;

			if (_isFlank) then
				{
				if (_isLeft) then 
					{
					_x set [3,_leftName];
					_leftSA set [(count _leftSA),_x];
					_leftSANmbr = _leftSANmbr + 1
					} 
				else 
					{
					_x set [3,_rightName];
					_rightSA set [(count _rightSA),_x];
					_rightSANmbr = _rightSANmbr + 1
					}
				}
			else
				{
				_x set [3,_frontName];
				_frontSA set [(count _frontSA),_x];
				_frontSANmbr = _frontSANmbr + 1
				}
			}
		foreach _strArea;

		_leftSpace = count _leftSectors;
		_rightSpace = count _rightSectors;
		_frontSpace = count _frontSectors;

		_LmaxSpace = false;
		_RmaxSpace = false;
		_FmaxSpace = false;

		_LmaxSA = false;
		_RmaxSA = false;
		_FmaxSA = false;

		_LmaxVeh = false;
		_RmaxVeh = false;
		_FmaxVeh = false;

		switch (true) do
			{
			case ((_leftSpace >= _rightSpace) and (_leftSpace >= _frontSpace)) : {_LmaxSpace = true};
			case ((_rightSpace >= _leftSpace) and (_rightSpace >= _frontSpace)) : {_RmaxSpace = true};
			case ((_frontSpace >= _leftSpace) and (_frontSpace >= _rightSpace)) : {_FmaxSpace = true};
			};

		switch (true) do
			{
			case (((count _leftSA) >= (count _rightSA)) and ((count _leftSA) >= (count _frontSA))) : {_LmaxSA = true};
			case (((count _rightSA) >= (count _leftSA)) and ((count _rightSA) >= (count _frontSA))) : {_RmaxSA = true};
			case (((count _frontSA) >= (count _leftSA)) and ((count _frontSA) >= (count _rightSA))) : {_FmaxSA = true};
			};

		switch (true) do
			{
			case ((_leftVeh >= _rightVeh) and (_leftVeh >= _frontVeh)) : {_LmaxVeh = true};
			case ((_rightVeh >= _leftVeh) and (_rightVeh >= _frontVeh)) : {_RmaxVeh = true};
			case ((_frontVeh >= _leftVeh) and (_frontVeh >= _rightVeh)) : {_FmaxVeh = true};
			};

		missionNamespace setVariable [_leftFlankName,[_leftSectors,_LmaxSpace,_LmaxSA,_LmaxVeh,_leftSpace,_leftSA,_leftInf,_leftVeh]];
		missionNamespace setVariable [_rightFlankName,[_rightSectors,_RmaxSpace,_RmaxSA,_RmaxVeh,_rightSpace,_rightSA,_rightInf,_rightVeh]];
		missionNamespace setVariable [_centerFrontName,[_frontSectors,_FmaxSpace,_FmaxSA,_FmaxVeh,_frontSpace,_frontSA,_frontInf,_frontVeh]];

		_lFlank = missionNamespace getVariable _leftFlankName;
		_rFlank = missionNamespace getVariable _rightFlankName;
		_cFront = missionNamespace getVariable _centerFrontName;

		_flSMaxStr = _leftFlankName;
		_flSpace = (missionNamespace getVariable _leftFlankName) select 1;

		if not (_flSpace) then
			{
				{
				_fl = missionNamespace getVariable _x;
				_spaceF = _fl select 1;
				if (_spaceF) exitWith {_flSMaxStr = _x}
				}
			foreach [_rightFlankName,_centerFrontName];
			};

		_flSAMaxStr = _leftFlankName;
		_flSA = (missionNamespace getVariable _leftFlankName) select 2;

		if not (_flSA) then
			{
				{
				_fl = missionNamespace getVariable _x;
				_SAF = _fl select 2;
				if (_SAF) exitWith {_flSAMaxStr = _x}
				}
			foreach [_rightFlankName,_centerFrontName];
			};

		_flVMaxStr = _leftFlankName;
		_flVeh = (missionNamespace getVariable _leftFlankName) select 3;

		if not (_flVeh) then
			{
				{
				_fl = missionNamespace getVariable _x;
				_vehF = _fl select 3;
				if (_vehF) exitWith {_flVMaxStr = _x}
				}
			foreach [_rightFlankName,_centerFrontName];
			};



		_vehAll = 0;

			{
			_ldrRep = (_x getVariable "ForceRep") select 0;
			_forceChar = _ldrRep select 5;
			_vehPerc = (_forceChar select 1) + (_forceChar select 2) + (_forceChar select 3);

			_vehAll = _vehAll + _vehPerc
			}
		foreach _BBHQGrps;

		_vehAv = _vehAll/(count _BBHQGrps);

		_moreVehHQ = [];

			{
			_ldrRep = (_x getVariable "ForceRep") select 0;
			_forceChar = _ldrRep select 5;
			_vehPerc = (_forceChar select 1) + (_forceChar select 2) + (_forceChar select 3);

			if (_vehPerc >= _vehAv) then 
				{
				_moreVehHQ set [(count _moreVehHQ),_x];
				_x setVariable ["ForceProfile","V"]
				}
			else
				{
				_x setVariable ["ForceProfile","I"]
				}
			}
		foreach _BBHQGrps;

		_numAll = 0;

			{
			_ldrRep = (_x getVariable "ForceRep") select 0;
			_forceNum = _ldrRep select 1;

			_numAll = _numAll + _forceNum
			}
		foreach _BBHQGrps;

		_numAv = _numAll/(count _BBHQGrps);

		_moreNumHQ = [];

			{
			_ldrRep = (_x getVariable "ForceRep") select 0;
			_forceNum = _ldrRep select 1;

			if (_forceNum >= _numAv) then 
				{
				_moreNumHQ set [(count _moreNumHQ),_x];
				_x setVariable ["NumProfile","A"]
				}
			else
				{
				_x setVariable ["NumProfile","B"]
				}

			}
		foreach _BBHQGrps;

		_goingLeft = [];
		_goingRight = [];
		_goingAhead = [];

		_allCount = count _BBHQGrps;
		_resCount = floor ((count _BBHQGrps)/3);

		_actCount = _allCount - _resCount;

		_flankCount = floor (2 * (_actCount/3));

		_centerCount = _actCount - _flankCount;

		_restHQ = _BBHQGrps - (_moreVehHQ + _moreNumHQ);

		_goingReserve = [];
		
		_resCand = [];

			{
			if ((_x getVariable ["ForceProfile","V"]) == "I") then {_resCand set [(count _resCand),_x]}
			}
		foreach _moreNumHQ;
		
		while {(_resCount > 0)} do
			{

			if (((count _resCand) > 0) and ((random 100) < 90)) then
				{
				_ldr = _resCand select (floor (random (count _resCand)));

				_goingReserve set [(count _goingReserve),_ldr];
				_moreVehHQ = _moreVehHQ - [_ldr];
				_moreNumHQ = _moreNumHQ - [_ldr];
				_resCand = _resCand - [_ldr];
				_resCount = _resCount - 1;

				};

			if (_resCount <= 0) exitWith {};

			_ldr = (_BBHQGrps - _goingReserve) select (floor (random (count (_BBHQGrps - _goingReserve))));

			_goingReserve set [(count _goingReserve),_ldr];
			_moreVehHQ = _moreVehHQ - [_ldr];
			_moreNumHQ = _moreNumHQ - [_ldr];
			_resCand = _resCand - [_ldr];
			_resCount = _resCount - 1;
			};
	
		if not (_allAreTaken) then
			{
			if ((count _BBHQGrps) > 1) then
				{
				if (((count _moreVehHQ) > 0) and ((random 100) < 90)) then
					{
					_ldr = _moreVehHQ select (floor (random (count _moreVehHQ)));
					switch (_flVMaxStr) do
						{
						case (_leftFlankName) : 
							{
							_goingLeft set [(count _goingLeft),_ldr];
							_moreVehHQ = _moreVehHQ - [_ldr];
							_moreNumHQ = _moreNumHQ - [_ldr];
							_flankCount = _flankCount - 1;
							};

						case (_rightFlankName) : 
							{
							_goingRight set [(count _goingRight),_ldr];
							_moreVehHQ = _moreVehHQ - [_ldr];
							_moreNumHQ = _moreNumHQ - [_ldr];
							_flankCount = _flankCount - 1
							};

						case (_centerFrontName) : 
							{
							_goingAhead set [(count _goingAhead),_ldr];
							_moreVehHQ = _moreVehHQ - [_ldr];
							_moreNumHQ = _moreNumHQ - [_ldr];
							_centerCount = _centerCount - 1
							};
						};
					};

				if (((count _moreNumHQ) > 0) and ((random 100) < 90)) then
					{
					_ldr = _moreNumHQ select (floor (random (count _moreNumHQ)));
					switch (_flSAMaxStr) do
						{
						case (_leftFlankName) : 
							{
							_goingLeft set [(count _goingLeft),_ldr];
							_moreVehHQ = _moreVehHQ - [_ldr];
							_moreNumHQ = _moreNumHQ - [_ldr];
							_flankCount = _flankCount - 1;
							};

						case (_rightFlankName) : 
							{
							_goingRight set [(count _goingRight),_ldr];
							_moreVehHQ = _moreVehHQ - [_ldr];
							_moreNumHQ = _moreNumHQ - [_ldr];
							_flankCount = _flankCount - 1
							};

						case (_centerFrontName) : 
							{
							_goingAhead set [(count _goingAhead),_ldr];
							_moreVehHQ = _moreVehHQ - [_ldr];
							_moreNumHQ = _moreNumHQ - [_ldr];
							_centerCount = _centerCount - 1
							};
						};
					};

				_allFree = +(_BBHQGrps - (_goingReserve + _goingLeft + _goingRight + _goingAhead));

					{
					_ldr = _x;
					_rndF = random 100;

					_flankOne = _leftFlankName;
					_goingOne = _goingLeft;
					_flankTwo = _rightFlankName;
					_goingTwo = _goingRight;

					if ((random 100) >= 50) then 
						{
						_flankOne = _rightFlankName;
						_goingOne = _goingRight;
						_flankTwo = _leftFlankName;
						_goingTwo = _goingLeft;
						};

					switch (true) do
						{
						case ((_ldr in _moreVehHQ) and (_ldr in _moreNumHQ) and (_rndF < 90)) : 
							{
							switch (true) do
								{
								case ((((_flVMaxStr == _flankOne) and (((count _goingOne) <= (count _goingTwo)) or ((random 100) < 10))) or (((count _goingOne) == 0) and ((count _goingTwo) > 0) and ((random 100) > 75))) and (_flankCount > 0)) : 
									{
									_goingOne set [(count _goingOne),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1;
									};

								case ((((_flVMaxStr == _flankTwo) and (((count _goingTwo) <= (count _goingOne)) or ((random 100) < 10))) or (((count _goingTwo) == 0) and ((count _goingOne) > 0) and ((random 100) > 75))) and (_flankCount > 0)) : 
									{
									_goingTwo set [(count _goingTwo),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1
									};

								case ((_centerCount > 0) and ((count _moreNumHQ) == 0)) : 
									{
									_goingAhead set [(count _goingAhead),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_centerCount = _centerCount - 1
									};

								case ((((_flSAMaxStr == _flankOne) and (((count _goingOne) <= (count _goingTwo)) or ((random 100) < 10))) or (((count _goingOne) == 0) and ((count _goingTwo) > 0) and ((random 100) > 75))) and (_flankCount > 0)) : 
									{
									_goingOne set [(count _goingOne),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1;
									};

								case ((((_flSAMaxStr == _flankTwo) and (((count _goingTwo) <= (count _goingOne)) or ((random 100) < 10))) or (((count _goingTwo) == 0) and ((count _goingOne) > 0) and ((random 100) > 75))) and (_flankCount > 0)) : 
									{
									_goingTwo set [(count _goingTwo),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1
									};

								case (_centerCount > 0) : 
									{
									_goingAhead set [(count _goingAhead),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_centerCount = _centerCount - 1
									};

								default 
									{
									_rndF = random 100;

									if (_rndF < 50) then
										{
										_goingLeft set [(count _goingLeft),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_flankCount = _flankCount - 1;
										}
									else
										{
										_goingRight set [(count _goingRight),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_flankCount = _flankCount - 1
										}
									};
								};
							};

						case ((_ldr in _moreVehHQ) and (_rndF < 90)) : 
							{

							switch (true) do
								{
								case ((((_flVMaxStr == _flankOne) and (((count _goingOne) <= (count _goingTwo)) or ((random 100) < 10))) or (((count _goingOne) == 0) and ((count _goingTwo) > 0) and ((random 100) > 75))) and (_flankCount > 0)) : 
									{
									_goingOne set [(count _goingOne),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1;
									};

								case ((((_flVMaxStr == _flankTwo) and (((count _goingTwo) <= (count _goingOne)) or ((random 100) < 10))) or (((count _goingTwo) == 0) and ((count _goingOne) > 0) and ((random 100) > 75))) and (_flankCount > 0)) : 
									{
									_goingTwo set [(count _goingTwo),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1
									};

								case (_centerCount > 0) : 
									{
									_goingAhead set [(count _goingAhead),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_centerCount = _centerCount - 1
									};

								default 
									{
									_rndF = random 100;

									if (_rndF < 50) then
										{
										_goingLeft set [(count _goingLeft),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_flankCount = _flankCount - 1;
										}
									else
										{
										_goingRight set [(count _goingRight),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_flankCount = _flankCount - 1
										}
									};
								};
							};

						case ((_ldr in _moreNumHQ) and (_rndF < 90)) : 
							{

							switch (true) do
								{
								case ((((_flSAMaxStr == _flankOne) and (((count _goingOne) <= (count _goingTwo)) or ((random 100) < 10))) or (((count _goingOne) == 0) and ((count _goingTwo) > 0) and ((random 100) > 75))) and (_flankCount > 0)) : 
									{
									_goingOne set [(count _goingOne),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1;
									};

								case ((((_flSAMaxStr == _flankTwo) and (((count _goingTwo) <= (count _goingOne)) or ((random 100) < 10))) or (((count _goingTwo) == 0) and ((count _goingOne) > 0) and ((random 100) > 75))) and (_flankCount > 0)) : 
									{
									_goingTwo set [(count _goingTwo),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1
									};

								case (_centerCount > 0) : 
									{
									_goingAhead set [(count _goingAhead),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_centerCount = _centerCount - 1
									};

								default 
									{
									_rndF = random 100;

									if (_rndF < 50) then
										{
										_goingLeft set [(count _goingLeft),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_flankCount = _flankCount - 1;
										}
									else
										{
										_goingRight set [(count _goingRight),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_flankCount = _flankCount - 1
										}
									};
								};
							};

						default 
							{
							if ((({((_x in _moreVehHQ) or (_x in _moreNumHQ))} count (_BBHQGrps - _goingReserve)) < (_flankCount + _centerCount)) or (_rndF >= 90)) then
								{
								_rndF = random 100;

								switch (true) do
									{
									case (_rndF < 33) :
										{
										_goingLeft set [(count _goingLeft),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_flankCount = _flankCount - 1;
										};

									case (_rndF < 66) :
										{ 
										_goingRight set [(count _goingRight),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_flankCount = _flankCount - 1
										};

									default 
										{
										_goingAhead set [(count _goingAhead),_ldr];
										_moreVehHQ = _moreVehHQ - [_ldr];
										_moreNumHQ = _moreNumHQ - [_ldr];
										_centerCount = _centerCount - 1
										};
									}
								}
							};
						};
					}
				foreach _allFree;

				if ((count (_BBHQGrps - (_goingReserve + _goingLeft + _goingRight + _goingAhead))) > 0) then 
					{

						{
						_ldr = _x;
						if (_flankCount > 0) then 
							{
							_rndF = random 100;

							switch (true) do
								{
								case (_rndF < 50) :
									{
									_goingLeft set [(count _goingLeft),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1;
									};

								case (_rndF >= 50) :
									{ 
									_goingRight set [(count _goingRight),_ldr];
									_moreVehHQ = _moreVehHQ - [_ldr];
									_moreNumHQ = _moreNumHQ - [_ldr];
									_flankCount = _flankCount - 1
									};
								}
							}
						else
							{
							_goingAhead set [(count _goingAhead),_ldr];
							_moreVehHQ = _moreVehHQ - [_ldr];
							_moreNumHQ = _moreNumHQ - [_ldr];
							_centerCount = _centerCount - 1
							}
						}
					foreach (_BBHQGrps - (_goingReserve + _goingLeft + _goingRight + _goingAhead))
					}
				}
			else
				{
				_goingAhead set [(count _goingAhead),(_BBHQGrps select 0)];
				_centerCount = _centerCount - 1
				}
			}
		else
			{
			for "_i" from 0 to (_actCount - 1) do
				{
				_ldr = _BBHQGrps select _i;
				_goingAhead set [(count _goingAhead),_ldr]
				}
			};

		if (RydBB_Debug) then
			{
			RydBBa_SAL globalChat format ["Assignment of Big Boss %5 : Left: %1 Right: %2 Front: %3 Reserve: %4",_goingLeft,_goingRight,_goingAhead,_goingReserve,_BBSide];
			diag_log format ["Assignment of Big Boss %5 : Left: %1 Right: %2 Front: %3 Reserve: %4",_goingLeft,_goingRight,_goingAhead,_goingReserve,_BBSide];
			};

		if (((RydBBa_SimpleDebug) and (_BBSide == "A")) or ((RydBBb_SimpleDebug) and (_BBSide == "B"))) then 
			{
			//[_BBHQGrps,_BBSide] spawn RYD_BBSimpleD
			[[_BBHQGrps,_BBSide],RYD_BBSimpleD] call RYD_Spawn
			};
		};

	if (RydBB_Debug) then
		{
		RydBBa_SAL globalChat format ["Big Boss %1 issues orders.",_BBSide];
		diag_log format ["Big Boss %1 issues orders.",_BBSide];
		};

	_goingReserve0 = _goingReserve;

		{
		_aliveHQ = true;
		switch (true) do
			{
			case (isNull _x) : {_aliveHQ = false};
			case (({alive _x} count (units _x)) < 1) : {_aliveHQ = false};
			};
			
		if not (_aliveHQ) then {_goingReserve = _goingReserve - [_x]};
		}
	foreach _goingReserve0;

	if ((count _goingReserve) > 0) then
		{
		_lastGLeft = _goingLeft;
		_lastGRight = _goingRight;
		_lastGAhead = _goingAhead;

		_lastGLeftN = count _goingLeft;
		_lastGRightN = count _goingRight;
		_lastGAheadN = count _goingAhead;

			{
			_aliveHQ = true;
			switch (true) do
				{
				case (isNull _x) : {_aliveHQ = false};
				case (({alive _x} count (units _x)) < 1) : {_aliveHQ = false};
				};
			if not (_aliveHQ) then {_goingAhead = _goingAhead - [_x]};
			}
		foreach _lastGAhead;

		if ((count _goingAhead) < _lastGAheadN) then
			{
			if ((count _goingReserve) > 0) then 
				{
				_newL = _goingReserve select 0;
				_goingReserve = _goingReserve - [_newL];
				_goingAhead set [(count _goingAhead),_newL];
				}
			};

			{
			_aliveHQ = true;
			switch (true) do
				{
				case (isNull _x) : {_aliveHQ = false};
				case (({alive _x} count (units _x)) < 1) : {_aliveHQ = false};
				};
				
			if not (_aliveHQ) then {_goingLeft = _goingLeft - [_x]};
			}
		foreach _lastGLeft;

		if ((count _goingLeft) <  _lastGLeftN) then
			{
			if ((count _goingReserve) > 0) then 
				{
				_newL = _goingReserve select 0;
				_goingReserve = _goingReserve - [_newL];
				_goingLeft set [(count _goingLeft),_newL];
				}
			};

			{
			_aliveHQ = true;
			switch (true) do
				{
				case (isNull _x) : {_aliveHQ = false};
				case (({alive _x} count (units _x)) < 1) : {_aliveHQ = false};
				};
				
			if not (_aliveHQ) then {_goingRight = _goingRight - [_x]};
			}
		foreach _lastGRight;

		if ((count _goingRight) < _lastGRightN) then
			{
			if ((count _goingReserve) > 0) then 
				{
				_newL = _goingReserve select 0;
				_goingReserve = _goingReserve - [_newL];
				_goingRight set [(count _goingRight),_newL];
				}
			};
		};

	if (_stance == "") then {_stance = "O"};

	_losses = 0;
	_currentNumber = 0;
	_ownVal = 0;

	for "_i" from 0 to ((count (_ForcesRep select 0)) - 2) do
		{
		_actRep = (_ForcesRep select 0) select _i;
		_losses = _losses - (_actRep select 2);
		_currentNumber = _currentNumber + (_actRep select 1);
		_ownVal = _ownVal + (_actRep select 3)
		};

	_enemyVal = 0;

	for "_i" from 0 to ((count (_ForcesRep select 1)) - 2) do
		{
		_actRep = (_ForcesRep select 1) select _i;
		_enemyVal = _enemyVal + (_actRep select 1)
		};

	_inert = 1;

	if (_stance == "D") then {_inert = 1.2};
	//if (_stance == "O") then {_inert = 0.8};
	_enemyFactor = _ownVal/((_enemyVal + 1) * _inert);

	_lossesFactor = (_losses/(_currentNumber + 1)) * _inert;


	if (RydBB_Debug) then
		{
		RydBBa_SAL globalChat format ["Side: %7 - Losses: %1 Number: %2 Value: %3 enValue: %4 enFactor: %5 lossFactor: %6",_losses,_currentNumber,_ownVal,_enemyVal,_enemyFactor,_lossesFactor,_BBSide];
		diag_log format ["Side: %7 - Losses: %1 Number: %2 Value: %3 enValue: %4 enFactor: %5 lossFactor: %6",_losses,_currentNumber,_ownVal,_enemyVal,_enemyFactor,_lossesFactor,_BBSide];
		};

	if ((_enemyFactor < (0.5 + (random 0.25))) or (_lossesFactor > (0.4 + (random 0.4))) or (_allAreTaken)) then
		{
		_stance = "D";

			{
			_aliveHQ = true;
			switch (true) do
				{
				case (isNull _x) : {_aliveHQ = false};
				case (({alive _x} count (units _x)) < 1) : {_aliveHQ = false};
				};

			if (_aliveHQ) then
				{
				_HQ = _x;
				_front = _HQ getVariable ["RydHQ_Front",locationNull];
				_tObj1 = _HQ getVariable ["RydHQ_Obj1",objNull];
				_tObj2 = _HQ getVariable ["RydHQ_Obj2",objNull];
				_tObj3 = _HQ getVariable ["RydHQ_Obj3",objNull];
				_tObj4 = _HQ getVariable ["RydHQ_Obj4",objNull];
				_knEnemy = _HQ getVariable ["RydHQ_KnEnPos",[]];
				_HQ setVariable ["RydHQ_Order","DEFEND"];
				_HQ setVariable ["RydHQ_NObj",5];

				_perDirPos = _mainPos;
				_actT = _x getVariable "ActualTarget";
				if not (isNil "_actT") then {_perDirPos = _actT select 0};
				if not ((count _knEnemy) == 0) then
					{
					_dpX = 0;
					_dpY = 0;

						{
						_dpX = _dpX + (_x select 0);
						_dpY = _dpY + (_x select 1)
						}
					foreach _knEnemy;

					_dpX = _dpX/(count _knEnemy);
					_dpY = _dpY/(count _knEnemy);

					_perDirPos = [_dpX,_dpY,0];
					};

				_HQPos = getPosATL (vehicle (leader _HQ));

				_dirAdd = -60;

					{
					_angle = [_HQPos,_perDirPos,10] call RYD_AngTowards;
					_angle = _angle + _dirAdd;

					_dirAdd = _dirAdd + 40;

					_perPos = [_HQPos,_angle,(350 + (random 100))] call RYD_PosTowards2D;

					_perX = _perPos select 0;
					_perY = _perPos select 1;

					_x setPosATL [_perX,_perY,0];

					//_mark = [(str (random 1000)),[_perX,_perY,0],"ColorPink","ICON",[0.5,0.5],0,1,"DOT",(str _HQ)] call RYD_Marker;
					}
				foreach [_tObj1,_tObj2,_tObj3,_tObj4];

				[_front,_HQPos,_perDirPos,1500] call RYD_LocLineTransform;
				}
			}
		foreach (_goingLeft + _goingRight + _goingAhead)
		}
	else
		{
		_stance = "O";
		_leftNotTaken = [];

			{
			_tkn = _x select 2;
			if not (_tkn) then {_leftNotTaken set [(count _leftNotTaken),_x]}
			}
		foreach _leftSA;

		_rightNotTaken = [];

			{
			_tkn = _x select 2;
			if not (_tkn) then {_rightNotTaken set [(count _rightNotTaken),_x]}
			}
		foreach _rightSA;

		_frontNotTaken = [];

			{
			_tkn = _x select 2;
			if not (_tkn) then {_frontNotTaken set [(count _frontNotTaken),_x]}
			}
		foreach _frontSA;

			{
			_notTaken = _leftNotTaken;
			if ((count _notTaken) == 0) then {_notTaken = _frontNotTaken};
			if ((count _notTaken) == 0) then {_notTaken = _rightNotTaken};

			_fPos = getPosATL (vehicle (leader _x));

			if ((count _notTaken) == 0) exitWith {_x setVariable ["ActualTarget",[_fPos,1,false,"Zero"]]};

			_chosenT = _notTaken select 0;
			_indx = 0;
			_cPos = _chosenT select 0;
			_cVal = _chosenT select 1;
			_cTaken = _chosenT select 2;
			_dstFC = _fPos distance _cPos;
			_tempMax = 0;
			if (_dstFC > 0) then {_tempMax = _cVal/((_dstFC/1000) * (_dstFC/1000))};

			for "_i" from 1 to ((count _notTaken) - 1) do
				{
				_actT = _notTaken select _i;

				_cPos = _actT select 0;
				_cVal = _actT select 1;
				_cTaken = _actT select 2;
				_dstFC = _fPos distance _cPos;
				_tempAct = 0;
				if (_dstFC > 0) then {_tempAct = (_cVal/((_dstFC/1000) * (_dstFC/1000))) * (0.5 + (random 0.5) + (random 0.5))};

				if (_tempAct > _tempMax) then {_chosenT = _actT;_tempMax = _tempAct;_indx = _i};
				};

			_x setVariable ["ActualTarget",_chosenT];

			if ((count _leftNotTaken) > 0) then 
				{
				_leftNotTaken set [_indx,"ToDelete"]; 
				_leftNotTaken = _leftNotTaken - ["ToDelete"]
				}
			else
				{
				if ((count _frontNotTaken) > 0) then 
					{
					_frontNotTaken set [_indx,"ToDelete"]; 
					_frontNotTaken = _frontNotTaken - ["ToDelete"]
					}
				else
					{
					if ((count _rightNotTaken) > 0) then 
						{
						_rightNotTaken set [_indx,"ToDelete"]; 
						_rightNotTaken = _rightNotTaken - ["ToDelete"]
						}
					}
				}
			}
		foreach _goingLeft;

			{
			_notTaken = _rightNotTaken;
			if ((count _notTaken) == 0) then {_notTaken = _frontNotTaken};
			if ((count _notTaken) == 0) then {_notTaken = _leftNotTaken};

			_fPos = getPosATL (vehicle (leader _x));

			if ((count _notTaken) == 0) exitWith {_x setVariable ["ActualTarget",[_fPos,1,false,"Zero"]]};

			_chosenT = _notTaken select 0;
			_indx = 0;
			_cPos = _chosenT select 0;
			_cVal = _chosenT select 1;
			_cTaken = _chosenT select 2;
			_dstFC = _fPos distance _cPos;
			_tempMax = 0;
			if (_dstFC > 0) then {_tempMax = _cVal/((_dstFC/1000) * (_dstFC/1000))};

			for "_i" from 1 to ((count _notTaken) - 1) do
				{
				_actT = _notTaken select _i;

				_cPos = _actT select 0;
				_cVal = _actT select 1;
				_cTaken = _actT select 2;
				_dstFC = _fPos distance _cPos;
				_tempAct = 0;
				if (_dstFC > 0) then {_tempAct = (_cVal/((_dstFC/1000) * (_dstFC/1000))) * (0.5 + (random 0.5) + (random 0.5))};

				if (_tempAct > _tempMax) then {_chosenT = _actT;_tempMax = _tempAct;_indx = _i};
				};

			_x setVariable ["ActualTarget",_chosenT];

			if ((count _rightNotTaken) > 0) then 
				{
				_rightNotTaken set [_indx,"ToDelete"]; 
				_rightNotTaken = _rightNotTaken - ["ToDelete"]
				}
			else
				{
				if ((count _frontNotTaken) > 0) then 
					{
					_frontNotTaken set [_indx,"ToDelete"]; 
					_frontNotTaken = _frontNotTaken - ["ToDelete"]
					}
				else
					{
					if ((count _leftNotTaken) > 0) then 
						{
						_leftNotTaken set [_indx,"ToDelete"]; 
						_leftNotTaken = _leftNotTaken - ["ToDelete"]
						}
					}
				}
			}
		foreach _goingRight;

			{
			_notTaken = _frontNotTaken;
			if ((count _notTaken) == 0) then {_notTaken = _leftNotTaken};
			if ((count _notTaken) == 0) then {_notTaken = _rightNotTaken};
			_fPos = getPosATL (vehicle (leader _x));

			if ((count _notTaken) == 0) exitWith {_x setVariable ["ActualTarget",[_fPos,1,false,"Zero"]]};

			_chosenT = _notTaken select 0;

			_indx = 0;
			_cPos = _chosenT select 0;
			_cVal = _chosenT select 1;
			_cTaken = _chosenT select 2;
			_dstFC = _fPos distance _cPos;
			_tempMax = 0;
			if (_dstFC > 0) then {_tempMax = _cVal/((_dstFC/1000) * (_dstFC/1000))};


			for "_i" from 1 to ((count _notTaken) - 1) do
				{
				_actT = _notTaken select _i;

				_cPos = _actT select 0;
				_cVal = _actT select 1;
				_cTaken = _actT select 2;
				_dstFC = _fPos distance _cPos;
				_tempAct = 0;
				if (_dstFC > 0) then {_tempAct = (_cVal/((_dstFC/1000) * (_dstFC/1000))) * (0.5 + (random 0.5) + (random 0.5))};

				if (_tempAct > _tempMax) then {_chosenT = _actT;_tempMax = _tempAct;_indx = _i};
				};

			_x setVariable ["ActualTarget",_chosenT];

			if ((count _frontNotTaken) > 0) then 
				{
				_frontNotTaken set [_indx,"ToDelete"]; 
				_frontNotTaken = _frontNotTaken - ["ToDelete"]
				}
			else
				{
				if ((count _leftNotTaken) > 0) then 
					{
					_leftNotTaken set [_indx,"ToDelete"]; 
					_leftNotTaken = _leftNotTaken - ["ToDelete"]
					}
				else
					{
					if ((count _rightNotTaken) > 0) then 
						{
						_rightNotTaken set [_indx,"ToDelete"]; 
						_rightNotTaken = _rightNotTaken - ["ToDelete"]
						}
					}
				}
			}
		foreach _goingAhead;

			{
				{
				_aliveHQ = true;
				switch (true) do
					{
					case (isNull _x) : {_aliveHQ = false};
					case (({alive _x} count (units _x)) < 1) : {_aliveHQ = false};
					};

				if (_aliveHQ) then
					{
					_pathDone = _x getVariable "PathDone";
					if (isNil "_pathDone") then {_pathDone = true};		
					
					if (_pathDone) then
						{
						_HQ = _x;
						_front = _HQ getVariable ["RydHQ_Front",locationNull];
						_tObj1 = _HQ getVariable ["RydHQ_Obj1",objNull];
						_tObj2 = _HQ getVariable ["RydHQ_Obj2",objNull];
						_tObj3 = _HQ getVariable ["RydHQ_Obj3",objNull];
						_tObj4 = _HQ getVariable ["RydHQ_Obj4",objNull];
						_HQ setVariable ["RydHQ_Order","ATTACK"];

						_areas = _leftNotTaken; 
						_sctrs = _leftSectors;

						switch (true) do
							{
							case (_x in _goingRight) : {_areas = _rightNotTaken;_sctrs = _rightSectors};
							case (_x in _goingAhead) : {_areas = _frontNotTaken;_sctrs = _frontSectors};
							};

						if ((count _areas) == 0) then {_areas = (_leftNotTaken + _rightNotTaken + _frontNotTaken)};

						_acT = _x getVariable "ActualTarget";

						_areas = _areas + [_acT];

						_acT = _acT select 0;

						_HQpos = getPosATL (vehicle (leader _x));

						_pathRep = [_sctrs,_areas,_HQpos,_acT,_BBSide] call RYD_Itinerary;

						_secsAround = _pathRep select 0;
						_tgtsAround = _pathRep select 1;

						_points = [];

							{
							_points set [(count _points),_x select 0]
							}
						foreach _tgtsAround;

							{
							_points set [(count _points),_x]
							}
						foreach [_HQpos,_acT];
					
						[_front,+_points,1200] call RYD_LocMultiTransform;

						//[_x,_tgtsAround,_tObj1,_tObj2,_tObj3,_tObj4,_BBHQGrps,_HQpos,_front,_secsAround,_goingReserve,_BBSide] spawn RYD_ExecutePath;

						[[_x,_tgtsAround,_tObj1,_tObj2,_tObj3,_tObj4,_BBHQGrps,_HQpos,_front,_secsAround,_goingReserve,_BBSide],RYD_ExecutePath] call RYD_Spawn;

						waitUntil
							{
							sleep 0.01;
							_initD = _x getVariable "ObjInit";
							if (isNil "_initD") then {_initD = false};
							(_initD)
							};
						}
					}
				}
			foreach _x
			}
		foreach [_goingLeft,_goingRight,_goingAhead]
		};

	_points = [];

		{
		_tkn = _x select 2;
		if (_tkn) then {_points set [(count _points),_x]}
		}
	foreach _strArea;

	_HQpoints = [];

		{
		_HQpoints set [(count _HQpoints),getPosATL (vehicle (leader _x))]
		}
	foreach _BBHQGrps;
	
	_takenPoints = _points;

	_points = [];

		{
		_points set [(count _points),(_x select 0)]
		}
	foreach _takenPoints;

	_points = _points + _HQpoints;

		{
		_aliveHQ = true;
		switch (true) do
			{
			case (isNull _x) : {_aliveHQ = false};
			case (({alive _x} count (units _x)) < 1) : {_aliveHQ = false};
			};

		if (_aliveHQ) then
			{
			_HQ = _x;
			_front = _HQ getVariable ["RydHQ_Front",locationNull];
			_tObj1 = _HQ getVariable ["RydHQ_Obj1",objNull];
			_tObj2 = _HQ getVariable ["RydHQ_Obj2",objNull];
			_tObj3 = _HQ getVariable ["RydHQ_Obj3",objNull];
			_tObj4 = _HQ getVariable ["RydHQ_Obj4",objNull];

	/*
				{
				_mark = [(str (random 1000)),_x,"ColorOrange","ICON",[0.5,0.5],0,1,"DOT","R"] call RYD_Marker;
				}
			foreach _points;
	*/
			[_front,+_points,1000] call RYD_LocMultiTransform;

			//[_x,_goingAhead,_tObj1,_tObj2,_tObj3,_tObj4,_BBHQs,_front,_takenPoints,_hostileGroups,_BBSide] spawn RYD_ReserveExecuting;

			[[_x,_goingAhead,_tObj1,_tObj2,_tObj3,_tObj4,_BBHQs,_front,_takenPoints,_hostileGroups,_BBSide],RYD_ReserveExecuting] call RYD_Spawn;

			waitUntil
				{
				sleep 0.01;
				_initD = _x getVariable "ObjInit";
				if (isNil "_initD") then {_initD = false};
				(_initD)
				};
			}
		}
	foreach _goingReserve;

	if (_BBcycle == 1) then
		{
		if (_BBSide == "A") then {RydBBa_InitDone = true} else {RydBBb_InitDone = true}
		};

	if (_BBSide == "A") then {RydBBa_Urgent = false} else {RydBBb_Urgent = false};

	if (_BBCycle == 1) then 
		{
		//[_strArea,_BBSide,(_BBHQGrps select 0),_BBHQGrps] spawn RYD_ObjectivesMon
		[[_strArea,_BBSide,(_BBHQGrps select 0),_BBHQGrps],RYD_ObjectivesMon] call RYD_Spawn;
		};

	if ((_BBSide == "A") and (_BBCycle == 1)) then {RydBBa_Init = true};

	if (RydBB_Debug) then
		{
		RydBBa_SAL globalChat format ["For Big Boss %3 cycle is completed: %1 (mission time: %2)",_BBCycle,time,_BBSide];
		diag_log format ["For Big Boss %3 cycle is completed: %1 (mission time: %2)",_BBCycle,time,_BBSide]
		};

	_ctWait = time;
	_ctVal = 20;
	if not (isNil "RydBB_MainInterval") then {_ctVal = RydBB_MainInterval};

	if (RydBB_Debug) then
		{
		RydBBa_SAL globalChat format ["Big Boss %1 will now take a moment to ash his cigar.",_BBSide];
		diag_log format ["Big Boss %1 will now take a moment to ash his cigar.",_BBSide];
		};

	waitUntil
		{
		sleep 60;

		if (_BBSide == "A") then 
			{
			if (RydBBa_Urgent) then 
				{
				_ctVal = 0
				}
			}
		else 
			{
			if (RydBBb_Urgent) then 
				{
				_ctVal = 0
				}
			};

		if not (RydBB_Active) then {_ctVal = 0};

		((time - _ctWait) >= (_ctVal * 60))
		};
		
	if not (RydBB_Active) exitWith {};
		
	_urgent = RydBBa_Urgent;
	if (_BBSide == "B") then {_urgent = RydBBb_Urgent};

	if (RydBB_Debug) then
		{
		if (_urgent) then
			{
			RydBBa_SAL globalChat format ["Situation on the frontline forces Big Boss %1 to react quickly.",_BBSide];
			diag_log format ["Situation on the frontline forces Big Boss %1 to react quickly.",_BBSide];
			}
		else
			{
			RydBBa_SAL globalChat format ["For Big Boss %1 it is time to a routine review the situation.",_BBSide];
			diag_log format ["For Big Boss %1 it is time to a routine review the situation.",_BBSide];
			}
		};

	if (_urgent) then
		{
			{
			if not (isNull (group _x)) then {(group _x) setVariable ["PathDone",true]};
			}
		foreach _BBHQs
		};

	_BBalive = true;

	if (RydBB_BBOnMap) then
		{
		_BBUnit = RydBBaHQ;
		if (_BBSide == "B") then {_BBUnit = RydBBbHQ};

		if (isNull _BBUnit) exitWith {_BBalive = false};
		if not (alive _BBUnit) exitWith {_BBalive = false};
		if (captive _BBUnit) then {_BBalive = false}
		};

	if not (_BBalive) then 
		{
		if (_BBSide == "A") then {RydBBa_HQs = []} else {RydBBb_HQs = []}
		};

	if not (_BBalive) exitWith 
		{
		if (RydBB_Debug) then
			{
			RydBBa_SAL globalChat format ["Big Boss %1 is dead!",_BBSide];
			diag_log format ["Big Boss %1 is dead!",_BBSide];
			}
		};
	};