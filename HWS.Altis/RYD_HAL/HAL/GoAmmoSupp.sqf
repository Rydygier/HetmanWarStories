_SCRname = "GoAmmoSupp";

_i = "";

_unit = _this select 0;
_Trg = _this select 1;
_Hollow = _this select 2;
_soldiers = _this select 3;
_drop = _this select 4;
_HQ = _this select 6;

_AmmoPoints = _HQ getVariable ["RydHQ_AmmoPoints",[]];

_AmmoPoints set [(count _AmmoPoints),_Trg];

_startpos = position _unit;

_unitG = group (assigneddriver _unit);

if (_unit in _soldiers) then {_unitG = group _unit};

_mtr = _unit;

_mtr disableAI "TARGET";_mtr disableAI "AUTOTARGET";

[_unitG] call RYD_WPdel;

(group (assigneddriver _unit)) setVariable [("Deployed" + (str (group (assigneddriver _unit)))),false];
_unitvar = str (_unitG);
_unitG setVariable [("Busy" + _unitvar), true];

_posX = ((position _Trg) select 0) + (random 100) - 50;
_posY = ((position _Trg) select 1) + (random 100) - 50;

_isWater = surfaceIsWater [_posX,_posY];

_cnt = 0;

while {((_isWater) and (_cnt <= 20))} do
	{
	_posX = _posX + (random 200) - 100;
	_posY = _posY + (random 200) - 100;
	_isWater = surfaceIsWater [_posX,_posY];
	_cnt = _cnt + 1;
	};

if ((isPlayer (leader _unitG)) and (RydxHQ_GPauseActive)) then {hintC "New orders from HQ!";setAccTime 1};

_UL = leader _unitG;

if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdConf,"OrdConf"] call RYD_AIChatter}};

_alive = false;
if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
	{
	_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
	_i = [[_posX,_posY],_unitG,"markAmmoSupp","ColorKhaki","ICON","mil_end"," Reammo " + _signum," - AMMO SUPPORT",[0.6,0.6],270] call RYD_Mark
	};

_task = [(leader _unitG),["Deliver ammunition.", "Support", ""],(position _Trg)] call RYD_AddTask;

if (_drop) then
	{
	_dst = _unit distance _Trg;
	if (_dst > 100) then
		{
		if (_unit isKindOf "Air") then
			{
			_ammoBox = _this select 5;
			_abPos = getPosATL _ammoBox;
			_ammoBox setPos [0,0,2000];
			_pos = _Trg;
			_ang = [(getPosATL _unit),(getPosATL _Trg),5] call RYD_AngTowards;
			_nextPos1 = [(getPosATL _unit),_ang,(_unit distance _Trg) + 200] call RYD_PosTowards2D;

			_tp = "MOVE";

			(group _Trg) setVariable ["ForBoxing",_pos];

			_wp = [_unitG,_pos,_tp,"STEALTH","BLUE","FULL",["true","deletewaypoint [(group this), 0]"]] call RYD_WPadd;

			_wp waypointAttachVehicle _Trg;

			_unit flyInHeight 150;
			//[_unit,100] spawn RYD_KeepAlt;

			_cause = [_unitG,6,true,0,24,[],true,true,true,true] call RYD_Wait;
			_timer = _cause select 0;
			_alive = _cause select 1;

			if not (_alive) exitwith {if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
				{
				deleteVehicle _ammoBox;
				deleteMarker ("markAmmoSupp" + str (_unitG))};
				_AmmoPoints = _AmmoPoints - [_Trg];
				_HQ setVariable ["RydHQ_AmmoPoints",_AmmoPoints];
				_unitG setVariable [("Busy" + _unitvar), false];
				};
				
			if (_timer > 24) then 
				{
				[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0];
				_ammoBox setPos _abPos
				}
			else
				{
				_UL = leader _unitG;if not (isPlayer _UL) then {if (_timer <= 24) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdFinal,"OrdFinal"] call RYD_AIChatter}}};
				//[_unit,_ammoBox,(group _Trg)] spawn RYD_AmmoDrop;
				[[_unit,_ammoBox,(group _Trg)],RYD_AmmoDrop] call RYD_Spawn;
				_boxed = (_HQ getVariable ["RydHQ_Boxed",[]]);
				_boxed set [(count _boxed),(group _Trg)];
				_HQ setVariable ["RydHQ_Boxed",_boxed];
				};

			_wp = [_unitG,_nextPos1,_tp,"STEALTH","BLUE","FULL",["true","deletewaypoint [(group this), 0]"]] call RYD_WPadd;

			_cause = [_unitG,6,true,0,24,[],true,true,true,true] call RYD_Wait;
			_timer = _cause select 0;
			_alive = _cause select 1;

			//_unit setVariable ["KeepAlt",false];

			if not (_alive) exitwith 
				{
				if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
					{
					deleteMarker ("markAmmoSupp" + str (_unitG))
					};
					
				_AmmoPoints = _AmmoPoints - [_Trg];
				_HQ setVariable ["RydHQ_AmmoPoints",_AmmoPoints];
				_unitG setVariable [("Busy" + _unitvar), false];
				};
					
			if (_timer > 24) then 
				{
				[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0]
				}
			}
		}
	else
		{
		_sPos = _unit modelToWorld [(random 20) - 10,-10,0];
		_sPos = [_sPos select 0,_sPos select 1,0];

		_type = typeOf _ammoBox;
		deleteVehicle _ammoBox;

		_ammoBox = createVehicle [_type, _sPos, [], 0, "NONE"];

		_ammoBox setPos _sPos;
		_boxed = (_HQ getVariable ["RydHQ_Boxed",[]]);
		_boxed set [(count _boxed),(group _Trg)];
		_HQ setVariable ["RydHQ_Boxed",_boxed];
		(group _Trg) setVariable ["isBoxed",_ammoBox]
		}
	}
else
	{
	_counter = 0;

	while {(_counter <= 3)} do
		{
		[_unitG] call RYD_WPdel;

		if not (_counter == 0) then 
			{
			_posX = ((position _unit) select 0) + (random 100) -  50;
			_posY = ((position _unit) select 1) + (random 100) -  50;

			_isWater = surfaceIsWater [_posX,_posY];

			_cnt = 0;

			while {((_isWater) and (_cnt <= 20))} do
				{
				_posX = _posX + (random 200) -  100;
				_posY = _posY + (random 200) -  100;
				_isWater = surfaceIsWater [_posX,_posY];
				_cnt = _cnt + 1;
				};

			if (isPlayer (leader _unitG)) then 
				{
				if not (isMultiplayer) then
					{
					_task setSimpleTaskDestination [_posX,_posY]
					}
				else
					{
					[_task,(leader _unitG),["Provide support to nearby units. Stay in this area.", "Support", ""],[_posX,_posY],"ASSIGNED",0,false,true] call BIS_fnc_SetTask;
					}
				}
			};

		_pos = [_posX,_posY];
		if (_counter == 0) then {_pos = _Trg};
		_tp = "MOVE";
		if (_HQ getVariable ["RydHQ_SupportWP",false]) then {_tp = "SUPPORT"};

		_wp = [_unitG,_pos,_tp,"SAFE","BLUE","FULL",["true","(vehicle this) land 'GET IN';deletewaypoint [(group this), 0]"]] call RYD_WPadd;
		if (_counter == 0) then {_wp waypointAttachVehicle _Trg};

		_cause = [_unitG,6,true,0,24,[],true,true,true,true] call RYD_Wait;
		_timer = _cause select 0;
		_alive = _cause select 1;

		if not (_alive) exitwith 
			{
			if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
				{
				deleteMarker ("markAmmoSupp" + str (_unitG))
				};
				
			_AmmoPoints = _AmmoPoints - [_Trg];
			_HQ setVariable ["RydHQ_AmmoPoints",_AmmoPoints];
			_unitG setVariable [("Busy" + _unitvar), false];
			};
			
		if (_timer > 24) then {_counter = _counter + 1;[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0]} else {_counter = _counter + 1}; 

		_UL = leader _unitG;if not (isPlayer _UL) then {if ((_timer <= 24) and (_counter == 1)) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdFinal,"OrdFinal"] call RYD_AIChatter}}};

		if ((damage _Trg) >= 0.9) then {_Hollow = _Hollow - [_Trg]};
		}
	};

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		deleteMarker ("markAmmoSupp" + str (_unitG))
		};
		
	_AmmoPoints = _AmmoPoints - [_Trg];
	_HQ setVariable ["RydHQ_AmmoPoints",_AmmoPoints];
	_unitG setVariable [("Busy" + _unitvar), false];
	};
	
[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0];

_tp = "MOVE";
if ((_HQ getVariable ["RydHQ_SupportWP",false]) and not (_drop)) then {_tp = "SUPPORT"};
_pos = [_posX,_posY];

if (_drop) then 
	{
	_AmmoPoints = _AmmoPoints - [_Trg];
	_pos = _startpos;
	if (isPlayer (leader _unitG)) then
		{
		if not (isMultiplayer) then
			{
			_task setSimpleTaskDescription ["Return.", "Move", ""];
			_task setSimpleTaskDestination _pos
			}
		else
			{
			[_task,(leader _unitG),["Return.", "Move", ""],_pos,"ASSIGNED",0,false,true] call BIS_fnc_SetTask;
			 
			}
		}
	};

_beh = "SAFE";
if (_drop) then {_beh = "STEALTH"};

_wp = [_unitG,_pos,_tp,_beh,"BLUE","FULL",["true","{(vehicle _x) land 'LAND'} foreach (units (group this));deletewaypoint [(group this), 0]"]] call RYD_WPadd;

_cause = [_unitG,6,true,0,24,[],true,true,true,true] call RYD_Wait;
_timer = _cause select 0;
_alive = _cause select 1;

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		deleteMarker ("markAmmoSupp" + str (_unitG))
		};
		
	_AmmoPoints = _AmmoPoints - [_Trg];
	_HQ setVariable ["RydHQ_AmmoPoints",_AmmoPoints];
	_unitG setVariable [("Busy" + _unitvar), false];
	};
	
if (_timer > 24) then {[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0]}; 

_AmmoPoints = _AmmoPoints - [_Trg];
_HQ setVariable ["RydHQ_AmmoPoints",_AmmoPoints];
if ((isPlayer (leader _unitG)) and not (isMultiplayer)) then {(leader _unitG) removeSimpleTask _task};

_mtr enableAI "TARGET";_mtr enableAI "AUTOTARGET";
_unitG setVariable [("Busy" + _unitvar), false];

if ((damage _Trg) >= 0.9) then {_Hollow = _Hollow - [_Trg]};
if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markAmmoSupp" + str (_unitG))};
_lastOne = true;

	{
	if (((group (assigneddriver _x)) == (group (assigneddriver _Trg))) and not (_x == _Trg)) exitwith {_lastOne = false};
	if (((group _x) == (group _Trg)) and not (_x == _Trg)) exitwith {_lastOne = false};
	}
foreach _Hollow;

if (_lastOne) then 
	{
	_aSupp = _HQ getVariable ["RydHQ_ASupportedG",[]];
	_aSupp = _aSupp - [(group _Trg)];
	_HQ setVariable ["RydHQ_ASupportedG",_aSupp]
	};

_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdEnd,"OrdEnd"] call RYD_AIChatter}};