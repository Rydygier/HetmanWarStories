_SCRname = "Garrison";

_HQ = _this select 0;
_recArr = _this select 1;
_Garrison = _HQ getVariable ["RydHQ_Garrison",[]];

_posTaken = [];

for [{_a = 0},{_a < (count _Garrison)},{_a = _a + 1}] do
	{
	_unitG = _Garrison select _a;
	_garrisoned = _unitG getVariable ("Garrisoned" + (str _unitG));
	if (isNil "_garrisoned") then {_garrisoned = false};
	
	if not (_garrisoned) then
		{
		[_unitG] call RYD_WPdel;

		_unitG setVariable ["Garrisoned" + (str _unitG),true];

		_pos = getPosATL (vehicle (leader _unitG));
		_units = [];

		_UL = leader _unitG;
		_AV = assignedVehicle _UL;

		if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_OrdConf,"OrdConf"] call RYD_AIChatter}};

		if ((_HQ getVariable ["RydHQ_Debug",false]) or (isPlayer (leader _unitG))) then 
			{
			_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
			_i = [_pos,_unitG,"markGarrison","ColorBrown","ICON","mil_box","Garr " + _signum," - GARRISON",[0.5,0.5]] call RYD_Mark;
			};

		if ((_HQ getVariable ["RydHQ_GarrVehAb",false]) and not (isPlayer (leader _unitG))) then
			{
			//{unassignVehicle _x} foreach (units _unitG);
			(units _unitG) orderGetIn false;
			(units _unitG) allowGetin false;//if (player in (units _unitG)) then {diag_log "NOT ALLOW garr"};
			sleep 5
			};

		if (not (isNull _AV) and not (_HQ getVariable ["RydHQ_GarrVehAb",false])) exitWith
			{
			_frm = "DIAMOND";
			if (isPlayer (leader _unitG)) then {_frm = formation _unitG};
			_wp = [_unitG,position (leader _unitG),"SENTRY","AWARE","YELLOW","NORMAL",["true","deletewaypoint [(group this), 0];"],false,0,[0,0,0],_frm] call RYD_WPadd
			};

		_units = (units _unitG) - [leader _unitG]; 

		if not (isPlayer _UL) then
			{
			_list = _pos nearObjects ["StaticWeapon", 300];
			_staticWeapons = [];

				{
				if ((_x emptyPositions "gunner") > 0) then 
					{
					_staticWeapons = _staticWeapons + [_x];	
					};
				} 
			forEach _list;

				{
				if ((count _units) > 0) then 
					{
					_unit = (_units select ((count _units) - 1));

					if (((random 1) > 0.1) and not ((toLower (typeOf _unit)) in _recArr)) then 
						{
						_unit assignAsGunner _x;
						[_unit] orderGetIn true;
						
						_units resize ((count _units) - 1)
						}
					}
				} 
			forEach _staticWeapons;

			_Bldngs = _pos nearObjects ["House",300];
			_posTaken = missionnamespace getvariable ["PosTaken",[]];
			_posAll = [];
			_posAll0 = [];

				{
				_Bldg = _x;
				if ((_Bldg distance _UL) > 300) then {_Bldg = ObjNull};

				if not (isNull _Bldg) then
					{
					_posAct = _Bldg buildingpos 0;
					_j = 0;	
					while {((_posAct distance [0,0,0]) > 0)} do
						{
						_tkn = false;

							{
							if ((typeName _x) == (typeName [])) then
								{
								if (((_x select 0) + (_x select 1)) == ((_posAct select 0) + (_posAct select 1))) exitWith {_tkn = true}
								}
							}
						foreach _posTaken;

						if not (_tkn) then
							{
							_tkn = false;
							_sum = (_posAct select 0) + (_posAct select 1);

								{
								if ((typeName _x) == (typeName [])) then
									{
									if (((_x select 0) + (_x select 1)) == _sum) exitWith {_tkn = true}
									}
								}
							foreach _posTaken;

							if not (_tkn) then 
								{
								_posAll set [(count _posAll),[_posAct,_Bldg]]
								}
							};
							
						_j = _j + 1;
						_posAct = _Bldg buildingpos _j;
						}
					}
				}
			foreach _Bldngs;

			_posAll0 = +_posAll;

				{
				_ix = 0;
				if not ((count _posAll) == 0) then
					{
					_ix = floor (random (count _posAll));
					_posS = _posAll select _ix;
					_bld = _posS select 1;
					_posS = _posS select 0;
					_ct = 0;

					_posTaken = missionnamespace getVariable ["PosTaken",[]];

					while {((_posS in _posTaken) and (_ct < 20))} do
						{
						_ix = floor (random (count _posAll));
						_posS = _posAll select _ix;
						_ct = _ct + 1
						};

					if not ((_posS distance _pos) > 350) then
						{
						if ((random 100) > 20) then
							{
							_tkn = false;
							_sum = (_posS select 0) + (_posS select 1);

								{
								if ((typeName _x) == (typeName [])) then
									{
									if (((_x select 0) + (_x select 1)) == _sum) exitWith {_tkn = true}
									}
								}
							foreach _posTaken;

							if not (_tkn) then 
								{
								_posAll set [_ix,"Del"];
								_posAll = _posAll - ["Del"];
								_ix  = count _posTaken;
								_posTaken set [(count _posTaken),_posS];
								_posTaken = _posTaken - ["Del"];
								missionnamespace setVariable ["PosTaken",_posTaken];
								//[_x,_posS,_bld,[_posTaken,_ix],_HQ] spawn RYD_GarrS;
								[[_x,_posS,_bld,[_posTaken,_ix],_HQ],RYD_GarrS] call RYD_Spawn;
								_units = _units - [_x]
								}
							}
						}
					}
				}
			foreach _units;

			_patrolPos = [];

				{
				_pA = _x select 0;
				if ((typeName _pA) == (typeName [])) then
					{
					_isGood = true;
					if ((_pA select 2) > 16) then
						{
						_isGood = false
						};
						
					if (_isGood) then
						{								
						for "_i" from 0 to ((count _patrolPos) - 1) do
							{
							_pPos = _patrolPos select _i;
							_dst = _pPos distance _pA;
							if (_dst > 0.1) then
								{
								if (_dst < 16) then 
									{
									_isGood = false
									}
								};
							}
						};
						
					if (_isGood) then
						{
						_patrolPos set [(count _patrolPos),_pA];
						}
					}
				}
			foreach _posAll0;
			
			if ((count _patrolPos) > 1) then 
				{
				//[_unitG,_patrolPos,_HQ] spawn RYD_GarrP
				[[_unitG,_patrolPos,_HQ],RYD_GarrP] call RYD_Spawn;
				}
			else
				{
				_frm = "DIAMOND";
				if (isPlayer (leader _unitG)) then {_frm = formation _unitG};
				_wp = [_unitG,position (leader _unitG),"SENTRY","AWARE","YELLOW","NORMAL",["true","deletewaypoint [(group this), 0];"],false,0,[0,0,0],_frm] call RYD_WPadd;
				}
			}
		}
	};
