_SCRname = "GoRepSupp";

_i = "";

_unit = _this select 0;
_Trg = _this select 1;
_damaged = _this select 2;
_HQ = _this select 3;

_RepPoints = _HQ getVariable ["RydHQ_RepPoints",[]];

_RepPoints set [(count _RepPoints),_Trg];

_startpos = position _unit;

_unitG = group (assigneddriver _unit);

_rtr = _unit;

_rtr disableAI "TARGET";_rtr disableAI "AUTOTARGET";

[_unitG] call RYD_WPdel;

(group (assigneddriver _unit)) setVariable [("Deployed" + (str (group (assigneddriver _unit)))),false,true];
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

_alive = false;

if ((isPlayer (leader _unitG)) and (RydxHQ_GPauseActive)) then {hintC "New orders from HQ!";setAccTime 1};

_UL = leader _unitG;

if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdConf,"OrdConf"] call RYD_AIChatter}};

if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
	{
	_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
	_i = [[_posX,_posY],_unitG,"markRepSupp","ColorKhaki","ICON","mil_end"," Repair " + _signum," - REPAIR SUPPORT",[0.6,0.6],180] call RYD_Mark
	};

_task = [(leader _unitG),["Provide a field repair of damaged equipment.", "Support", ""],(position _Trg)] call RYD_AddTask;

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

	if (((_rtr distance _Trg) < 50) and not (CanMove _Trg)) then {_Trg setdamage ((damage _Trg) - 0.1)};
	if not (_alive) exitwith 
		{
		if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
			{
			deleteMarker ("markRepSupp" + str (_unitG))
			};
			
		_RepPoints = _RepPoints - [_Trg];
		_HQ setVariable ["RydHQ_RepPoints",_RepPoints];
		_unitG setVariable [("Busy" + _unitvar), false];
		};
		
	if (_timer > 24) then {_counter = _counter + 1;[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0]} else {_counter = _counter + 1};

	_UL = leader _unitG;if not (isPlayer _UL) then {if ((_timer <= 24) and (_counter == 1)) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdFinal,"OrdFinal"] call RYD_AIChatter}}}; 

	if (((damage _Trg) < 0.1) or ((damage _Trg) >= 0.9) or (isNull (group (assigneddriver (_this select 1))))) then {_damaged = _damaged - [_Trg]};
	};

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		deleteMarker ("markRepSupp" + str (_unitG))
		};
		
	_RepPoints = _RepPoints - [_Trg];
	_HQ setVariable ["RydHQ_RepPoints",_RepPoints];
	_unitG setVariable [("Busy" + _unitvar), false];
	};
	
[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle (leader _unitG)), 0];

_tp = "MOVE";
if (_HQ getVariable ["RydHQ_SupportWP",false]) then {_tp = "SUPPORT"};

_wp = [_unitG,[_posX,_posY],_tp,"SAFE","BLUE","FULL",["true","{(vehicle _x) land 'LAND'} foreach (units (group this));deletewaypoint [(group this), 0]"]] call RYD_WPadd;

_cause = [_unitG,6,true,0,24,[],true,true,true,true] call RYD_Wait;
_timer = _cause select 0;
_alive = _cause select 1;

if (((_rtr distance _Trg) < 50) and not (CanMove _Trg)) then {_Trg setdamage ((damage _Trg) - 0.1)};

if not (_alive) exitwith 
	{
	if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
		{
		deleteMarker ("markRepSupp" + str (_unitG))
		};
		
	_RepPoints = _RepPoints - [_Trg];
	_HQ setVariable ["RydHQ_RepPoints",_RepPoints];
	_unitG setVariable [("Busy" + _unitvar), false];
	};
	
if (_timer > 24) then {[_unitG, (currentWaypoint _unitG)] setWaypointPosition [position (vehicle _UL), 0]}; 

_RepPoints = _RepPoints - [_Trg];
_HQ setVariable ["RydHQ_RepPoints",_RepPoints];
if ((isPlayer (leader _unitG)) and not (isMultiplayer)) then {(leader _unitG) removeSimpleTask _task};

_rtr enableAI "TARGET";_rtr enableAI "AUTOTARGET";
_unitG setVariable [("Busy" + _unitvar), false];

if (((damage _Trg) < 0.1) or ((damage _Trg) >= 0.9) or (isNull (group (assigneddriver (_this select 1))))) then {_damaged = _damaged - [_Trg]};
if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then {deleteMarker ("markRepSupp" + str (_unitG))};
_lastOne = true;

	{
	if (((group (assigneddriver _x)) == (group (assigneddriver _Trg))) and not (_x == _Trg)) exitwith {_lastOne = false};
	}
foreach _damaged;

if (_lastOne) then 
	{
	_rSupp = _HQ getVariable ["RydHQ_RSupportedG",[]];
	_rSupp = _rSupp - [(group _Trg)];
	_HQ setVariable ["RydHQ_RSupportedG",_rSupp]
	};

_UL = leader _unitG;if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdEnd,"OrdEnd"] call RYD_AIChatter}};