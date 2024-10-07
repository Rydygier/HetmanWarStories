_SCRname = "GoAttInf";

_i = "";

_unitG = _this select 0;

_HQ = _this select 2;

_Spos = _unitG getvariable ("START" + (str _unitG));
if (isNil ("_Spos")) then {_unitG setVariable [("START" + (str _unitG)),(getPosATL (vehicle (leader _unitG)))];_Spos = _unitG getVariable ("START" + (str _unitG))};
 
_Trg = _this select 1;

_isAttacked = (group _Trg) getvariable ("InfAttacked" + (str (group _Trg)));
if (isNil ("_isAttacked")) then {_isAttacked = 0};

_PosObj1 = getPosATL _Trg;
_unitvar = str (_unitG);

//if (_isAttacked > 2) exitwith {};

[_unitG] call RYD_WPdel;

_unitG setVariable [("Deployed" + (str _unitG)),false];_unitG setVariable [("Capt" + (str _unitG)),false];

_UL = leader _unitG;
_nothing = true;

_dX = (_PosObj1 select 0) - ((getPosATL (leader _HQ)) select 0);
_dY = (_PosObj1 select 1) - ((getPosATL (leader _HQ)) select 1);

_angle = _dX atan2 _dY;

_distance = (leader _HQ) distance _PosObj1;
_distance2 = 350;

_Armor = (_HQ getVariable ["RydHQ_LArmorG",[]]) + (_HQ getVariable ["RydHQ_HArmorG",[]]);

if (_unitG in _Armor) then {_distance2 = 500};
if (_unitG in (_HQ getVariable ["RydHQ_AirG",[]])) then {_distance2 = 750};

_dXc = _distance2 * (cos _angle);
_dYc = _distance2 * (sin _angle);

if (_isAttacked == 2) then {(group _Trg) setvariable [("InfAttacked" + (str (group _Trg))),3];_dYc = - _dYc};
if (_isAttacked == 1) then {(group _Trg) setvariable [("InfAttacked" + (str (group _Trg))),2];_dXc = - _dXc};
if (_isAttacked < 1) then {(group _Trg) setvariable [("InfAttacked" + (str (group _Trg))),1];_distance = _distance - _distance2;_dXc = 0;_dYc = 0};
if (_isAttacked > 2) then {_distance = _distance - _distance2;_dXc = 0;_dYc = 0};

_dXb = _distance * (sin _angle);
_dYb = _distance * (cos _angle);

_posX = ((getPosATL (leader _HQ)) select 0) + _dXb + _dXc + (random 200) - 100;
_posY = ((getPosATL (leader _HQ)) select 1) + _dYb + _dYc + (random 200) - 100;

_isWater = surfaceIsWater [_posX,_posY];

while {((_isWater) and (([_posX,_posY] distance _PosObj1) >= 50))} do
	{
	_posX = _posX - _dXc/20;
	_posY = _posY - _dYc/20;
	_isWater = surfaceIsWater [_posX,_posY];
	};

_isWater = surfaceIsWater [_posX,_posY];

if (_isWater) exitwith 
	{
	_attAv = _HQ getVariable ["RydHQ_AttackAv",[]];
	_attAv set [(count _attAv),_unitG];
	_HQ setVariable ["RydHQ_AttackAv",_attAv];
	_unitG setVariable [("Busy" + (str _unitG)),false];
	[_Trg,"InfAttacked"] call RYD_VarReductor
	};

if ((isPlayer (leader _unitG)) and (RydxHQ_GPauseActive)) then {hintC "New orders from HQ!";setAccTime 1};

_UL = leader _unitG;
 
if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdConf,"OrdConf"] call RYD_AIChatter}};

if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
	{
	_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
	_i = [[_posX,_posY],_unitG,"markAttack","ColorRed","ICON","mil_dot","Inf " + _signum," - ATTACK"] call RYD_Mark
	};

_alive = true;
_CargoCheck = _unitG getvariable ("CC" + _unitvar);
if (isNil ("_CargoCheck")) then {_unitG setVariable [("CC" + _unitvar), false]};
_AV = assignedVehicle _UL;
if (((_HQ getVariable ["RydHQ_CargoFind",0]) > 0) and (isNull _AV) and (([_posX,_posY] distance (vehicle _UL)) > 1000)) then 
	{
	//[_unitG,_HQ,[_posX,_posY]] spawn HAL_SCargo
	[[_unitG,_HQ,[_posX,_posY]],HAL_SCargo] call RYD_Spawn;
	} 
else 
	{
	_unitG setVariable [("CC" + _unitvar), true]
	};
	
if ((_HQ getVariable ["RydHQ_CargoFind",0]) > 0) then 
	{	
	waituntil 
		{
		sleep 0.05;
		switch (true) do
			{
			case (isNull _unitG) : {_alive = false};
			case (({alive _x} count (units _unitG)) < 1) : {_alive = false};
			case ((_this select 0) getVariable ["RydHQ_MIA",false]) : {_alive = false;(_this select 0) setVariable ["RydHQ_MIA",nil]}
			};
			
		_cc = false;
		if (_alive) then
			{
			_cc = (_unitG getvariable ("CC" + _unitvar))
			};
			
		(not (_alive) or (_cc))
		};
		
	if not (isNull _unitG) then {_unitG setVariable [("CC" + _unitvar), false]};
	};

if not (_alive) exitWith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};
	[_Trg,"InfAttacked"] call RYD_VarReductor
	};

_AV = assignedVehicle _UL;
_DAV = assigneddriver _AV;
_GDV = group _DAV;

_task = taskNull;
_timer = 0;

[_unitG] call RYD_WPdel;

if (not (isNull _AV) and ((_HQ getVariable ["RydHQ_CargoFind",0]) > 0)) then
	{
	//_task = [(leader _unitG),["Wait and get into vehicle.", "GET IN", ""],(getPosATL (leader _unitG))] call RYD_AddTask;

	_wp = [_unitG,_AV,"GETIN"] call RYD_WPadd;
	_wp waypointAttachVehicle _AV;

	_cause = [_unitG,1,false,0,900,[],true,false,true,false,false,false] call RYD_Wait;
	if (_HQ getVariable ["RydHQ_LZ",false]) then {deleteVehicle (_AV getVariable ["TempLZ",objNull])};
	_timer = _cause select 0;
	};

if ((isPlayer (leader _unitG)) and not (isMultiplayer)) then {(leader _unitG) removeSimpleTask _task};
if ((isNull (leader (_this select 0))) or (_timer > 900)) exitwith {[_Trg,"InfAttacked"] call RYD_VarReductor;if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};if not (isNull _GDV) then {[_GDV, (currentWaypoint _GDV)] setWaypointPosition [getPosATL (vehicle (leader _GDV)), 0];_GDV setVariable [("Busy" + _unitvar), false];}};

_AV = assignedVehicle _UL;
_DAV = assigneddriver _AV;
_GDV = group _DAV;
_wp0 = [];_wp = [];
_nW = 1;

_LX1 = _posX;
_LY1 = _posY;
_EnNearTrg = false;
_NeNMode = false;
_halfway = false;
_mpl = 1;

_eClose1 = [[_posX,_posY],(_HQ getVariable ["RydHQ_KnEnemiesG",[]]),400] call RYD_CloseEnemyB;

_tooC1 = _eClose1 select 0;
_dstEM1 = _eClose1 select 1;
_NeN = _eClose1 select 2;

if not (isNull _NeN) then
	{
	_eClose2 = [_UL,(_HQ getVariable ["RydHQ_KnEnemiesG",[]]),400] call RYD_CloseEnemyB;
	_tooC2 = _eClose2 select 0;
	_dstEM2 = _eClose2 select 1;
	_eClose3 = [(leader _HQ),(_HQ getVariable ["RydHQ_KnEnemiesG",[]]),400] call RYD_CloseEnemyB;
	_tooC3 = _eClose3 select 0;

	if ((_tooC1) or (_tooC2) or (_tooC3) or (((_UL distance [_posX,_posY]) - _dstEM2) > _dstEM1)) then {_EnNearTrg = true}
	};

if (_EnNearTrg) then {_NeNMode = true};
if (not (isNull _GDV) and (_GDV in ((_HQ getVariable ["RydHQ_NCCargoG",[]]) + (_HQ getVariable ["RydHQ_AirG",[]]))) and (_NeNMode) and not (isPlayer (leader _GDV))) then {_LX1 = (getPosATL _UL) select 0;_LY1 = (getPosATL _UL) select 1;_halfway = true};

if ((isNull _AV) and (([_posX,_posY] distance _UL) > 1500) and not (isPlayer (leader _unitG))) then
	{
	_LX = (getPosATL _UL) select 0;
	_LY = (getPosATL _UL) select 1;

	_beh = "SAFE";
	_spd = "LIMITED";
	_TO = [0,0,0];
	if (_NeNMode) then {_spd = "NORMAL";_TO = [40, 45, 50];_beh = "AWARE"};

	_wp0 = [_unitG,[(_posX + _LX)/2,(_posY + _LY)/2],"MOVE",_beh,"YELLOW",_spd,["true","deletewaypoint [(group this), 0];"],true,0,_TO] call RYD_WPadd;
	_nW = 2;
	};

_task = [(leader _unitG),["Search and destroy enemy.", "SAD", ""],[_posX,_posY]] call RYD_AddTask;

_Ctask = taskNull;

if ((isPlayer (leader _GDV)) and not ((leader _GDV) == (leader _unitG))) then
	{
	_Ctask = [(leader _GDV),["Disembark group at designated position.", "Move", ""],[(_posX + _LX1)/2,(_posY + _LY1)/2]] call RYD_AddTask;
	};

_gp = _unitG;
if not (isNull _AV) then {_gp = _GDV;_posX = (_posX + _LX1)/2;_posY = (_posY + _LY1)/2};
_pos = [_posX,_posY];
_tp = "MOVE";
//if (not (isNull _AV) and (_unitG in (_HQ getVariable ["RydHQ_NCrewInfG",[]])) and not ((_GDV == _unitG) or (_GDV in (_HQ getVariable ["RydHQ_AirG",[]])))) then {_tp = "UNLOAD"};
_beh = "AWARE";
_lz = objNull;
if (not (isNull _AV) and (_GDV in (_HQ getVariable ["RydHQ_AirG",[]]))) then 
	{
	_beh = "CARELESS";
	if (_HQ getVariable ["RydHQ_LZ",false]) then
		{
		_lz = [[_posX,_posY]] call RYD_LZ;
		if not (isNull _lz) then
			{
			_pos = getPosATL _lz;
			_posX = _pos select 0;
			_posY = _pos select 1
			}
		}
	};

_spd = "NORMAL";
if ((isNull _AV) and (([_posX,_posY] distance _UL) > 1000) and not (_NeNMode)) then {_spd = "LIMITED";_beh = "SAFE"};
_TO = [0,0,0];
if ((isNull _AV) and (([_posX,_posY] distance _UL) <= 1000) or ((_NeNMode) and (isNull _AV))) then {_TO = [40, 45, 50]};
_crr = false;
if ((_nW == 1) and (isNull _AV)) then {_crr = true};
if not (isNull _AV) then {_crr = true};
_sts = ["true","deletewaypoint [(group this), 0];"];
if (((group (assigneddriver _AV)) in (_HQ getVariable ["RydHQ_AirG",[]])) and (_unitG in (_HQ getVariable ["RydHQ_NCrewInfG",[]]))) then {_sts = ["true","(vehicle this) land 'GET OUT';deletewaypoint [(group this), 0]"]};

_EDPos = _GDV getVariable "RydHQ_EDPos";
_earlyD = false;

if not (isNil "_EDPos") then
	{
	_earlyD = true;
	_EDPos = +_EDPos;
	_GDV setVariable ["RydHQ_EDPos",nil];
	
	if not (_halfway) then
		{
		_pos = _EDPos select 1
		}
	else
		{
		for "_i" from 100 to 600 step 100 do
			{
			_nR = _pos nearRoads _i;
			
			if ((count _nR) > 0) exitWith
				{
				_cR = [_pos,_nR] call RYD_FindClosest;
				
				_pos = getPosATL _cR;
				_ct = 0;
				
				while {(isOnRoad _pos)} do
					{
					_pos = [_pos,30] call RYD_RandomAround;
					_ct = _ct + 1;
					if (_ct > 50) exitWith {}
					}
				}
			}		
		}
	};

_wp = [_gp,_pos,_tp,_beh,"YELLOW",_spd,_sts,_crr,0,_TO] call RYD_WPadd;

if ((RydxHQ_SynchroAttack) and not (_halfway)) then
	{
	[_wp,_Trg] call RYD_WPSync;
	 
	 
	};

_DAV = assigneddriver _AV;
_OtherGroup = false;
_GDV = group _DAV;
_alive = false;
_enemy = false;
_timer = 0;

if not (((group _DAV) == (group _UL)) or (isNull (group _DAV))) then 
	{
	_OtherGroup = true;

	_cause = [_GDV,6,true,400,30,[(_HQ getVariable ["RydHQ_AirG",[]]),(_HQ getVariable ["RydHQ_KnEnemiesG",[]])],false] call RYD_Wait;
	_timer = _cause select 0;
	_alive = _cause select 1;
	_enemy = _cause select 2
	}
else 
	{
	_cause = [_unitG,6,true,400,30,[(_HQ getVariable ["RydHQ_AirG",[]]),(_HQ getVariable ["RydHQ_KnEnemiesG",[]])],false] call RYD_Wait;
	_timer = _cause select 0;
	_alive = _cause select 1;
	_enemy = _cause select 2
	};

_DAV = assigneddriver _AV;
if (((_timer > 30) or (_enemy)) and (_OtherGroup)) then {if not (isNull _GDV) then {[_GDV, (currentWaypoint _GDV)] setWaypointPosition [getPosATL (vehicle (leader _GDV)), 0]}};
if (((_timer > 30) or (_enemy)) and not (_OtherGroup)) then {[_unitG, (currentWaypoint _unitG)] setWaypointPosition [getPosATL (vehicle _UL), 0]};
if (not (_alive) and not (_OtherGroup)) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};
	[_Trg,"InfAttacked"] call RYD_VarReductor
	};

if (isNull (leader (_this select 0))) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};
	if not (isNull _GDV) then {[_GDV, (currentWaypoint _GDV)] setWaypointPosition [getPosATL (vehicle (leader _GDV)), 0];_GDV setVariable [("Busy" + _unitvar), false];};
	[_Trg,"InfAttacked"] call RYD_VarReductor
	};

_UL = leader _unitG;if not (isPlayer _UL) then {if (not (_halfway) and (_timer <= 30) and not (_enemy)) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdFinal,"OrdFinal"] call RYD_AIChatter}}};

_AV = assignedVehicle _UL;
_pass = assignedCargo _AV;
_allowed = true;
if not ((_GDV == _unitG) or (isNull _GDV)) then 
	{
	//{unassignVehicle _x} foreach (units _unitG);
	_pass orderGetIn false;
	_allowed = false;
	(units _unitG) allowGetIn false;//if (player in (units _unitG)) then {diag_log "NOT ALLOW attinf"};
	}
else
	{
	//if (_unitG in (_HQ getVariable ["RydHQ_NCrewInfG",[]])) then {_pass orderGetIn false};
	};

_DAV = assigneddriver _AV;
_GDV = group _DAV;

if (not (isNull _AV) and ((_HQ getVariable ["RydHQ_CargoFind",0]) > 0) and (_unitG in (_HQ getVariable ["RydHQ_NCrewInfG",[]]))) then
	{
	_cause = [_unitG,1,false,0,240,[],true,true,false,false,false,false,false,_pass] call RYD_Wait;
	_timer = _cause select 0
	};

if not ((_GDV == _unitG) or (isNull _GDV)) then 
	{
	{unassignVehicle _x} foreach (units _unitG);
	};

if not (_allowed) then {(units _unitG) allowGetIn true};

if (_HQ getVariable ["RydHQ_LZ",false]) then {deleteVehicle _lz};

if ((isPlayer (leader _GDV)) and not (isMultiplayer)) then {(leader _GDV) removeSimpleTask _Ctask};

_unitvar = str _GDV;

if ((isNull (leader (_this select 0))) or (_timer > 240)) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};
	if not (isNull _GDV) then {[_GDV, (currentWaypoint _GDV)] setWaypointPosition [getPosATL (vehicle (leader _GDV)), 0];_GDV setVariable [("Busy" + _unitvar), false]};//;_pass orderGetIn true};
	[_Trg,"InfAttacked"] call RYD_VarReductor
	};

if (not (isNull _GDV) and (_GDV in (_HQ getVariable ["RydHQ_AirG",[]])) and not (isPlayer (leader _GDV))) then
	{
	_wp = [_GDV,[((getPosATL _AV) select 0) + (random 200) - 100,((getPosATL _AV) select 1) + (random 200) - 100,1000],"MOVE","CARELESS","YELLOW","NORMAL"] call RYD_WPadd;

	_cause = [_GDV,3,true,0,8,[],false] call RYD_Wait;
	_timer = _cause select 0;
	if (_timer > 8) then {[_GDV, (currentWaypoint _GDV)] setWaypointPosition [getPosATL (vehicle (leader _GDV)), 0]};
	};

_GDV setVariable [("CargoM" + _unitvar), false];
_alive = true;
if ((_halfway) or (_earlyD)) then
	{
	_frm = formation _unitG;
	if not (isPlayer (leader _unitG)) then {_frm = "STAG COLUMN"};

	_wp = [_unitG,[_posX,_posY],"MOVE","AWARE","YELLOW","NORMAL",["true","deletewaypoint [(group this), 0];"],true,0,[0,0,0],_frm] call RYD_WPadd;

	if (RydxHQ_SynchroAttack) then
		{
		[_wp,_Trg] call RYD_WPSync;
		 
		 
		};

	_cause = [_unitG,6,true,0,30,[],false] call RYD_Wait;
	_timer = _cause select 0;
	_alive = _cause select 1;

	if not (_alive) exitwith 
		{
		if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};
		};

	if (_timer > 30) then {[_unitG, (currentWaypoint _unitG)] setWaypointPosition [getPosATL (vehicle _UL), 0]};
	};

if not (_alive) exitwith {[_Trg,"InfAttacked"] call RYD_VarReductor};

if (isPlayer (leader _unitG)) then
	{
	if not (isMultiplayer) then
		{
		_task setSimpleTaskDescription ["Search and destroy enemy.", "SAD", ""];
		_task setSimpleTaskDestination (getPosATL _Trg)
		}
	else
		{
		 
		[_task,(leader _unitG),["Search and destroy enemy.", "SAD", ""],(getPosATL _Trg),"ASSIGNED",0,false,true] call BIS_fnc_SetTask;
		}
	};

_beh = "AWARE";
_spd = "NORMAL";
if (not (_enemy) and not (_halfway) and (((vehicle (leader _unitG)) distance _Trg) > 1000) and not (_NeNMode)) then {_spd = "LIMITED";_beh = "SAFE"};
_frm = formation _unitG;
if not (isPlayer (leader _unitG)) then {_frm = "WEDGE"};
_cur = true;
if (RydxHQ_SynchroAttack) then {_cur = false};

_UL = leader _unitG;if not (isPlayer _UL) then {if ((_halfway) and (_timer <= 30)) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdFinal,"OrdFinal"] call RYD_AIChatter}}};

 _wp = [_unitG,_Trg,"SAD",_beh,"YELLOW",_spd,["true","deletewaypoint [(group this), 0];"],_cur,0,[0,0,0],_frm] call RYD_WPadd;

_cause = [_unitG,6,true,0,30,[],false] call RYD_Wait;
_timer = _cause select 0;
_alive = _cause select 1;

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};
	[_Trg,"InfAttacked"] call RYD_VarReductor
	};

if (_timer > 30) then {[_unitG, (currentWaypoint _unitG)] setWaypointPosition [getPosATL (vehicle _UL), 0]};

if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {_i setMarkerColor "ColorBlue"};

if (_unitG in (_HQ getVariable ["RydHQ_Garrison",[]])) then
	{
	if (isPlayer (leader _unitG)) then
		{
		if not (isMultiplayer) then
			{
			_task setSimpleTaskDescription ["Return.", "Move", ""];
			_task setSimpleTaskDestination _Spos
			}
		else
			{
			[_task,(leader _unitG),["Return.", "Move", ""],_Spos,"ASSIGNED",0,false,true] call BIS_fnc_SetTask;
			 
			}
		};
	
	_wp = [_unitG,_Spos,"MOVE","AWARE","YELLOW","NORMAL",["true","deletewaypoint [(group this), 0];"],true,5] call RYD_WPadd;

	_cause = [_unitG,6,true,0,30,[],false] call RYD_Wait;
	_timer = _cause select 0;
	_alive = _cause select 1;

	if not (_alive) exitwith {if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))}};
	if (_timer > 30) then {[_unitG, (currentWaypoint _unitG)] setWaypointPosition [getPosATL (vehicle _UL), 0]};
	_unitG setVariable ["Garrisoned" + (str _unitG),false];
	};

sleep 60;

if ((isPlayer (leader _unitG)) and not (isMultiplayer)) then {(leader _unitG) removeSimpleTask _task};

if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};

//_pass orderGetIn true;

_attAv = _HQ getVariable ["RydHQ_AttackAv",[]];
_attAv set [(count _attAv),_unitG];
_HQ setVariable ["RydHQ_AttackAv",_attAv];

_unitG setVariable [("Busy" + (str _unitG)),false];

[_Trg,"InfAttacked"] call RYD_VarReductor;

_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdEnd,"OrdEnd"] call RYD_AIChatter}};