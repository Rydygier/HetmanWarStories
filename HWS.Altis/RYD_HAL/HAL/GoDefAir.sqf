_SCRname = "GoDefAir";

_i = "";

_unitG = _this select 0;
_Spot = _this select 1;
_HQ = _this select 2;
_StartPos = getPosATL (vehicle (leader _unitG));

_unitvar = str _unitG;
_busy = false;
_busy = _unitG getvariable ("Busy" + _unitvar);

if (isNil ("_busy")) then {_busy = false};

_alive = true;

if (_busy) then 
	{
	_unitG setVariable ["RydHQ_MIA",true];
	_ct = time;
	
	waitUntil
		{
		sleep 0.1;
		
		switch (true) do
			{
			case (isNull (_unitG)) : {_alive = false};
			case (({alive _x} count (units _unitG)) < 1) : {_alive = false};
			case ((time - _ct) > 300) : {_alive = false};
			};
			
		_MIApass = false;
		if (_alive) then
			{
			_MIAPass = not (_unitG getVariable ["RydHQ_MIA",false]);
			};
			
		(not (_alive) or (_MIApass))	
		}
	};
			
[_unitG] call RYD_WPdel;

_unitG setVariable [("Deployed" + (str _unitG)),false];
_unitG setVariable [("Capt" + (str _unitG)),false];
_unitG setVariable [("Busy" + _unitvar), true];
_unitG setVariable ["Defending", true];

if ((isPlayer (leader _unitG)) and (RydxHQ_GPauseActive)) then {hintC "New orders from HQ!";setAccTime 1};

_UL = leader _unitG;
_plane = vehicle _UL;
 
if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdConf,"OrdConf"] call RYD_AIChatter}};

_endThis = false;
_alive = true;

while {not (_endThis)} do
	{
	_DefPos = [((getPosATL _Spot) select 0) + (random 1000) - 500,((getPosATL _Spot) select 1) + (random 1000) - 500];
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
		_i = [_DefPos,_unitG,"markDef","ColorBrown","ICON","mil_dot","Air " + _signum," - DEFEND AREA"] call RYD_Mark
		};

	_task = [(leader _unitG),["Provide air cover.", "SAD", ""],_DefPos] call RYD_AddTask;

	_wp = [_unitG,_DefPos,"SAD","AWARE","YELLOW","NORMAL"] call RYD_WPadd;

	if (_unitG in (_HQ getVariable ["RydHQ_BAirG",[]])) then 
		{
		_chosen = GrpNull;
		_dstM = 5000;

		_chosen = ([_Spot,(_HQ getVariable ["RydHQ_KnEnemiesG",[]]),0] call RYD_CloseEnemyB) select 2;

		if not (isNull _chosen) then
			{
			_Trg = vehicle (leader _chosen);
			_eSide = side _unitG;
			_wp waypointAttachVehicle _Trg;_wp setWaypointType "DESTROY";
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

				while {(not (isNull _Trg) and not (isNull _lasT) and not (isNull _VL) and (_ct < 50))} do
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
			}
		};

	_cause = [_unitG,6,true,0,24,[],false] call RYD_Wait;

	if ((isPlayer (leader _unitG)) and not (isMultiplayer)) then {(leader _unitG) removeSimpleTask _task};

	if ((isNull _unitG) or (isNull _HQ)) exitWith {_alive = false};
	if not (_unitG getVariable "Defending") exitWith {};
	if (({alive _x} count (units _unitG)) < 1) exitWith {_alive = false};
	if (isNull _plane) exitWith {};
	if not (alive _plane) exitWith {};
	};

if not (_alive) exitWith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		deleteMarker ("markDef" + _unitVar);
		deleteMarker ("markWatch" + _unitVar);
		};
		
	_AirInDef = _HQ getVariable ["RydHQ_AirInDef",[]];
	_AirInDef = _AirInDef - [_unitG];
	_HQ setVariable ["RydHQ_AirInDef",_AirInDef]
	};

_task = [(leader _unitG),["Return to the landing site.", "Move", ""],_StartPos] call RYD_AddTask;

_wp = [_unitG,_StartPos,"MOVE","AWARE","GREEN","NORMAL",["true", "{(vehicle _x) land 'LAND'} foreach (units (group this)); deletewaypoint [(group this), 0]"]] call RYD_WPadd;

_cause = [_unitG,6,true,0,24,[],false] call RYD_Wait;
_alive = _cause select 1;

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		deleteMarker ("markDef" + (str _unitG))
		};
		
	_AirInDef = _HQ getVariable ["RydHQ_AirInDef",[]];
	_AirInDef = _AirInDef - [_unitG];
	_HQ setVariable ["RydHQ_AirInDef",_AirInDef]
	};

if ((isPlayer (leader _unitG)) and not (isMultiplayer)) then {(leader _unitG) removeSimpleTask _task};

sleep 30;

if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markDef" + (str _unitG))};

_AirInDef = _HQ getVariable ["RydHQ_AirInDef",[]];
_AirInDef = _AirInDef - [_unitG];
_HQ setVariable ["RydHQ_AirInDef",_AirInDef];

_unitG setVariable [("Busy" + _unitvar), false];

_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdEnd,"OrdEnd"] call RYD_AIChatter}};