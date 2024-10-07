_SCRname = "GoAttAir";

_i = "";

_unitG = _this select 0;
_Trg = _this select 1;
_HQ = _this select 2;

_PosObj1 = getPosATL _Trg;
_unitvar = str (_unitG);

_UL = leader _unitG;
_PosLand = getPosATL (vehicle _UL);

[_unitG] call RYD_WPdel;

_unitG setVariable [("Deployed" + (str _unitG)),false];_unitG setVariable [("Capt" + (str _unitG)),false];

_nothing = true;

_dX = (_PosObj1 select 0) - ((getPosATL (leader _HQ)) select 0);
_dY = (_PosObj1 select 1) - ((getPosATL (leader _HQ)) select 1);

_angle = _dX atan2 _dY;

_distance = (leader _HQ) distance _PosObj1;
_distance2 = 0;

_dXc = _distance2 * (cos _angle);
_dYc = _distance2 * (sin _angle);

_dXb = _distance * (sin _angle);
_dYb = _distance * (cos _angle);

_posX = ((getPosATL (leader _HQ)) select 0) + _dXb;
_posY = ((getPosATL (leader _HQ)) select 1) + _dYb;

if ((isPlayer (leader _unitG)) and (RydxHQ_GPauseActive)) then {hintC "New orders from HQ!";setAccTime 1};

_UL = leader _unitG;
 
if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdConf,"OrdConf"] call RYD_AIChatter}};

if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
	{
	_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
	_i = [[_posX,_posY],_unitG,"markAttack","ColorRed","ICON","mil_dot","Air " + _signum," - ATTACK"] call RYD_Mark
	};

_task = [(leader _unitG),["Search and destroy enemy.", "SAD", ""],[_posX,_posY]] call RYD_AddTask;

_wp = [_unitG,[_posX,_posY],"SAD","COMBAT","RED","NORMAL",["true", "deletewaypoint [(group this), 0]"],true,0.001] call RYD_WPadd;

_lasT = ObjNull;

if (_unitG in (_HQ getVariable ["RydHQ_BAirG",[]])) then 
	{
	_eSide = side _unitG;
	_wp waypointAttachVehicle _Trg;
	_wp setWaypointType "DESTROY";
	_tgt = "LaserTargetWStatic";
	if (_eSide == east) then {_tgt = "LaserTargetEStatic"};

	_tPos = getPosATL _Trg;
	_tX = (_tPos select 0) + (random 60) - 30;
	_tY = (_tPos select 1) + (random 60) - 30;

	_lasT = createVehicle [_tgt, [_tX,_tY,0], [], 0, "CAN_COLLIDE"]; 

	_code =
		{
		_Trg = _this select 0;
		_lasT = _this select 1;
		_unitG = _this select 2;

		_VL = vehicle (leader _unitG);
		_ct = 0;

		while {(not (isNull _Trg) and not (isNull _lasT) and not (isNull _VL) and (_ct < 100))} do
			{
			if not (alive _Trg) exitWith {};
			if not (alive _VL) exitWith {};
			if (({alive _x} count (units _unitG)) < 1) exitWith {};
			_isBusy = _unitG getVariable [("Busy" + (str _unitG)),false];
			if not (_isBusy) exitWith {};
			if (_HQ getVariable ["RydHQ_KIA",false]) exitWith {};

			_tPos = getPosATL _Trg;
			_tX = (_tPos select 0) + (random 60) - 30;
			_tY = (_tPos select 1) + (random 60) - 30;

			_lasT setPos [_tX,_tY,0];

			sleep 15;
			_ct = _ct + 1
			};

		deleteVehicle _lasT
		};
		
	[[_Trg,_lasT,_unitG],_code] call RYD_Spawn
	};

_cause = [_unitG,6,true,0,24,[],false] call RYD_Wait;
_timer = _cause select 0;
_alive = _cause select 1;

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};
	if not (isNull _lasT) then {deleteVehicle _lasT};
	[_Trg,"AirAttacked"] call RYD_VarReductor
	};

if (_timer > 24) then {deleteWaypoint _wp};

if (isPlayer (leader _unitG)) then
	{
	if not (isMultiplayer) then
		{
		_task setSimpleTaskDestination _Posland;
		_task setSimpleTaskDescription ["Return to the landing site.", "Move", ""]
		}
	else
		{
		[_task,(leader _unitG),["Return to the landing site.", "Move", ""],_Posland,"ASSIGNED",0,false,true] call BIS_fnc_SetTask;
		 
		}
	};

if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {_i setMarkerColor "ColorBlue"};
if (_unitG in (_HQ getVariable ["RydHQ_BAirG",[]])) then {deleteVehicle _lasT};

_wp = [_unitG,_Posland,"MOVE","AWARE","GREEN","NORMAL",["true", "{(vehicle _x) land 'LAND'} foreach (units (group this)); deletewaypoint [(group this), 0]"],true,0.001] call RYD_WPadd;

_cause = [_unitG,6,true,0,24,[],false] call RYD_Wait;
_timer = _cause select 0;
_alive = _cause select 1;

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};
	[_Trg,"AirAttacked"] call RYD_VarReductor
	};
if (_timer > 24) then {deleteWaypoint _wp};

sleep 30;

if ((isPlayer (leader _unitG)) and not (isMultiplayer)) then {(leader _unitG) removeSimpleTask _task};

if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAttack" + str (_unitG))};

_attAv = _HQ getVariable ["RydHQ_AttackAv",[]];
_attAv set [(count _attAv),_unitG];
_HQ setVariable ["RydHQ_AttackAv",_attAv];
 
_unitG setVariable [("Busy" + (str _unitG)),false];

[_Trg,"AirAttacked"] call RYD_VarReductor;

_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdEnd,"OrdEnd"] call RYD_AIChatter}};