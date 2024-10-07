//kto siê nadaje do zwiadu, ataku i wsparcia
//cztery (albo tyle, ile celów) dywizje
//w kazdej recon i atak
//dodatkowo dywizja rezerwowa dla wzmocnienia ataku najbardziej udanego i oskrzydlenia reszty frontu
//wsparcie strategicznie - lotnictwo i artyleria

_SCRname = "Orders";

private ["_HQ","_nObj","_Trg","_vHQ","_landE","_dstMin","_dstAct","_dstMin","_PosObj1","_ReconAv","_onlyL","_unitvar","_busy","_vehready","_solready","_effective","_ammo","_Gdamage",
	"_nominal","_current","_veh","_forRRes","_RRp","_AttackAv","_FlankAv","_exhausted","_inD","_ResC","_stages","_rcheckArr","_gps","_LMCUA","_reserve","_recvar","_resting","_allT",
	"_deployed","_capturing","_reconthreat","_FOthreat","_snipersthreat","_ATinfthreat","_AAinfthreat","_Infthreat","_Artthreat","_HArmorthreat","_LArmorthreat","_Carsthreat","_reconNr",
	"_Airthreat","_Navalthreat","_Staticthreat","_StaticAAthreat","_StaticATthreat","_Supportthreat","_Cargothreat","_Otherthreat","_GE","_GEvar","_checked","_FPool","_constant",
	"_isAttacked","_captCount","_captLimit","_forCapt","_groupCount","_LMCU","_WADone","_WAchance","_armored","_WAAv","_where","_heldBy","_howMuch","_AAO","_toTake","_taken","_objectives"];

_HQ = _this select 0;

_AAO = _HQ getVariable ["RydHQ_ChosenAAO",false];

_HQ setVariable ["RydHQ_DefDone",false];

_distances = [];

_HQ setVariable ["RydHQ_NearestE",ObjNull];

_nObj = _HQ getVariable ["RydHQ_NObj",1];

switch (_nObj) do
	{
	case (1) : {_HQ setVariable ["RydHQ_Obj",(_HQ getVariable ["RydHQ_Obj1",(leader _HQ)])]};
	case (2) : {_HQ setVariable ["RydHQ_Obj",(_HQ getVariable ["RydHQ_Obj2",(leader _HQ)])]};
	case (3) : {_HQ setVariable ["RydHQ_Obj",(_HQ getVariable ["RydHQ_Obj3",(leader _HQ)])]};
	default {_HQ setVariable ["RydHQ_Obj",(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])]};
	};

_Trg = _HQ getVariable ["RydHQ_Obj",(leader _HQ)];

_vHQ = vehicle (leader _HQ);

_landE = (_HQ getVariable ["RydHQ_KnEnemiesG",[]]) - ((_HQ getVariable ["RydHQ_EnNavalG",[]]) + (_HQ getVariable ["RydHQ_EnAirG",[]]));
if ((count _landE) > 0) then 
	{
	_HQ setVariable ["RydHQ_NearestE",_landE select 0];
	_dstMin = (vehicle (leader (_landE select 0))) distance _vHQ;
	
		{
		_dstAct = (vehicle (leader _x)) distance _vHQ;
		if (_dstAct < _dstMin) then
			{
			_dstMin = _dstAct;
			_HQ setVariable ["RydHQ_NearestE",_x];
			}
		
		}
	foreach _landE;

	_Trg = vehicle (leader (_HQ getVariable ["RydHQ_NearestE",grpNull]));
	};

_ReconAv = [];
_onlyL = (_HQ getVariable ["RydHQ_LArmorG",[]]) - (_HQ getVariable ["RydHQ_MArmorG",[]]);

	{
	if not (isNull _x) then
		{
		_unitvar = str _x;
		if (_HQ getVariable ["RydHQ_Orderfirst",true]) then {_x setVariable ["Nominal" + _unitvar,(count (units _x))]};
		_busy = false;
		_busy = _x getVariable ("Busy" + _unitvar);
		if (isNil ("_busy")) then {_busy = false};
		_vehready = true;
		_solready = true;
		_effective = true;
		_ammo = true;
		_Gdamage = 0;
		
		if (([_x,(_HQ getVariable ["RydHQ_NCVeh",[]])] call RYD_AmmoFullCount) < 0.15) then 
			{
			_ammo = false
			}
		else
			{
				{
				_Gdamage = _Gdamage + (damage _x);
				if (((count (magazines _x)) == 0) and (((vehicle _x) == _x) or ((vehicle _x) in (_HQ getVariable ["RydHQ_NCVeh",[]])))) exitWith {_ammo = false};
				if (((damage _x) > 0.5) or not (canStand _x)) exitWith {_effective = false};
				}
			foreach (units _x)
			};
			
		_nominal = _x getVariable ("Nominal" + (str _x));if (isNil "_nominal") then {_x setVariable ["Nominal" + _unitvar,(count (units _x))];_nominal = _x getVariable ("Nominal" + (str _x))};
		_current = count (units _x);
		_Gdamage = _Gdamage + (_nominal - _current);

		if (((_Gdamage/(_current + 0.1)) > (0.4*(((_HQ getVariable ["RydHQ_Recklessness",0.5])/1.2) + 1))) or not (_effective) or not (_ammo)) then 
			{
			_solready = false;
			if not (_ammo) then
				{
				_x setVariable ["LackAmmo",true]
				}
			};

		_ammo = 0;
		_veh = ObjNull;

			{
			_veh = assignedvehicle _x;
			//diag_log format ["isnull: %1 immobilized: %2 no fuel %3 damaged: %4 no ammo: %5 typ: %6",isNull _veh,not (canMove _veh),((fuel _veh) <= 0.1),((damage _veh) > 0.5), (((group _x) in (((_HQ getVariable ["RydHQ_AirG",[]]) - ((_HQ getVariable ["RydHQ_NCAirG",[]]) + (_HQ getVariable ["RydHQ_RAirG",[]]))) + ((_HQ getVariable ["RydHQ_HArmorG",[]]) + (_HQ getVariable ["RydHQ_LArmorG",[]]) + ((_HQ getVariable ["RydHQ_CarsG",[]]) - ((_HQ getVariable ["RydHQ_NCCargoG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]])))))) and ((count (magazines _veh)) == 0)),typeof (vehicle _x)];
			if (not (isNull _veh) and (not (canMove _veh) or ((fuel _veh) <= 0.1) or ((damage _veh) > 0.5) or (((group _x) in (((_HQ getVariable ["RydHQ_AirG",[]]) - ((_HQ getVariable ["RydHQ_NCAirG",[]]) + (_HQ getVariable ["RydHQ_RAirG",[]]))) + ((_HQ getVariable ["RydHQ_HArmorG",[]]) + (_HQ getVariable ["RydHQ_LArmorG",[]]) + ((_HQ getVariable ["RydHQ_CarsG",[]]) - ((_HQ getVariable ["RydHQ_NCCargoG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]])))))) and ((count (magazines _veh)) == 0)))) exitwith {_vehready = false};
			}
		foreach (units _x);

		if (not (_x in (_ReconAv + (_HQ getVariable ["RydHQ_SpecForG",[]]))) and not (_busy) and (_vehready) and ((_solready) or (_x in (_HQ getVariable ["RydHQ_RAirG",[]])))) then {_ReconAv set [(count _ReconAv),_x]};
		}
	}
foreach (((_HQ getVariable ["RydHQ_RAirG",[]]) + (_HQ getVariable ["RydHQ_ReconG",[]]) + (_HQ getVariable ["RydHQ_FOG",[]]) + (_HQ getVariable ["RydHQ_SnipersG",[]]) + (_HQ getVariable ["RydHQ_NCrewInfG",[]]) - ((_HQ getVariable ["RydHQ_SupportG",[]]) + (_HQ getVariable ["RydHQ_NCCargoG",[]])) + _onlyL) - ((_HQ getVariable ["RydHQ_NoRecon",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]])));

_ReconAv = [_ReconAv] call RYD_RandomOrd;

_ReconAv = _ReconAv - (_HQ getVariable ["RydHQ_AOnly",[]]);

if not (_HQ getVariable ["RydHQ_ChosenEBDoctrine",false]) then
	{
	if ((_HQ getVariable ["RydHQ_ReconReserve",0]) > 0) then 
		{
		_forRRes = (_ReconAv - (_HQ getVariable ["RydHQ_RAirG",[]]));
		for [{_b = 0},{_b < (floor ((count _forRRes)*(_HQ getVariable ["RydHQ_ReconReserve",0])))},{_b = _b + 1}] do
			{
			_RRp = _forRRes select _b;
			_ReconAv = _ReconAv - [_RRp];
			}
		}
	};
		
_HQ setVariable ["RydHQ_ReconAv",_ReconAv];

_AttackAv = [];
_FlankAv = [];
_exhausted = _HQ getVariable ["RydHQ_Exhausted",[]];

	{
	if ((typeName _x) in [(typeName grpNull)]) then
		{
		if not (isNull _x) then
			{
			_unitvar = str _x;
			if (_HQ getVariable ["RydHQ_Orderfirst",true]) then {_x setVariable [("Nominal" + _unitvar),(count (units _x))]};
			_busy = false;
			_busy = _x getvariable ("Busy" + _unitvar);
			if (isNil ("_busy")) then {_busy = false};
			_vehready = true;
			_solready = true;
			_effective = true;
			_ammo = true;
			_Gdamage = 0;
			
			if (([_x,(_HQ getVariable ["RydHQ_NCVeh",[]])] call RYD_AmmoFullCount) < 0.15) then 
				{
				diag_log format ["typ: %1 ammo: %2 noc: %3",typeof (vehicle (leader _x)),([_x,(_HQ getVariable ["RydHQ_NCVeh",[]])] call RYD_AmmoFullCount),(toLower (typeof (vehicle (leader _x)))) in (_HQ getVariable ["RydHQ_NCVeh",[]])];
				_ammo = false
				}
			else
				{
					{
					_Gdamage = _Gdamage + (damage _x);
					if (((count (magazines _x)) == 0) and (((vehicle _x) == _x) or ((vehicle _x) in (_HQ getVariable ["RydHQ_NCVeh",[]])))) exitWith {_ammo = false};
					if (((damage _x) > 0.5) or not (canStand _x)) exitWith {_effective = false};
					}
				foreach (units _x)
				};
				
			_nominal = _x getVariable ("Nominal" + (str _x));if (isNil "_nominal") then {_x setVariable ["Nominal" + _unitvar,(count (units _x))];_nominal = _x getVariable ("Nominal" + (str _x))};
			_current = count (units _x);
			_Gdamage = _Gdamage + (_nominal - _current);
			if (((_Gdamage/(_current + 0.1)) > (0.4*(((_HQ getVariable ["RydHQ_Recklessness",0.5])/1.2) + 1))) or not (_effective) or not (_ammo)) then {_solready = false};
			_ammo = 0;

				{
				_veh = assignedvehicle _x;
				//diag_log format ["isnull: %1 immobilized: %2 no fuel %3 damaged: %4 no ammo: %5 typ: %6",isNull _veh,not (canMove _veh),((fuel _veh) <= 0.1),((damage _veh) > 0.5), (((group _x) in (((_HQ getVariable ["RydHQ_AirG",[]]) - ((_HQ getVariable ["RydHQ_NCAirG",[]]) + (_HQ getVariable ["RydHQ_RAirG",[]]))) + ((_HQ getVariable ["RydHQ_HArmorG",[]]) + (_HQ getVariable ["RydHQ_LArmorG",[]]) + ((_HQ getVariable ["RydHQ_CarsG",[]]) - ((_HQ getVariable ["RydHQ_NCCargoG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]])))))) and ((count (magazines _veh)) == 0)),typeof (vehicle _x)];
				if (not (isNull _veh) and (not (canMove _veh) or ((fuel _veh) <= 0.1) or ((damage _veh) > 0.5) or (((group _x) in (((_HQ getVariable ["RydHQ_AirG",[]]) - (_HQ getVariable ["RydHQ_NCAirG",[]])) + ((_HQ getVariable ["RydHQ_HArmorG",[]]) + (_HQ getVariable ["RydHQ_LArmorG",[]]) + ((_HQ getVariable ["RydHQ_CarsG",[]]) - ((_HQ getVariable ["RydHQ_NCCargoG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]])))))) and ((count (magazines _veh)) == 0)))) exitwith {_vehready = false};
				}
			foreach (units _x);
			
			if (not (_x in _AttackAv) and not (_busy) and not (_x in _FlankAv) and (_vehready) and (_solready) and not (_x in ((_HQ getVariable ["RydHQ_StaticG",[]]) + (_HQ getVariable ["RydHQ_ArtG",[]]) + (_HQ getVariable ["RydHQ_NavalG",[]]) + (_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]])))) then {_AttackAv set [(count _AttackAv),_x]};
			if (not (_x in _exhausted) and (not (_vehready) or not (_solready))) then 
				{
				//diag_log format ["exh: %1 vr: %2 sr: %3",typeof (vehicle (leader _x)),_vehready,_solready];
				_exhausted set [count _exhausted,_x];
				};
	 
			if (((_HQ getVariable ["RydHQ_Withdraw",1]) > 0) and not (_x in ((_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_SnipersG",[]])))) then
				{
				_inD = _x getVariable "NearE";
				if (isNil "_inD") then {_inD = 0};
				if (not (_x in _exhausted) and (((random (2 + (_HQ getVariable ["RydHQ_Recklessness",0.5]))) max 0.5) < (_inD * (_HQ getVariable ["RydHQ_Withdraw",1])))) then 
					{
					_recvar = str _x;
					_resting = _x getvariable ("Resting" + _recvar);
					if (isNil ("_resting")) then {_resting = false};
					if not (_resting) then
						{
						diag_log format ["with: %1",typeof (vehicle (leader _x))];
						[[_x,_HQ,true],HAL_GoRest] call RYD_Spawn;
						//_exhausted set [(count _exhausted),_x]
						}
					}; 
				};
			}
		}
	}
foreach (((_HQ getVariable ["RydHQ_Friends",[]]) - ((_HQ getVariable ["RydHQ_reconG",[]]) + (_HQ getVariable ["RydHQ_FOG",[]]) + ((_HQ getVariable ["RydHQ_NCCargoG",[]]) - (_HQ getVariable ["RydHQ_NCrewInfG",[]])) + (_HQ getVariable ["RydHQ_SupportG",[]]))) - (_HQ getVariable ["RydHQ_NoAttack",[]]));
_AttackAv = [_AttackAv] call RYD_RandomOrd;

_AttackAv = _AttackAv - (_HQ getVariable ["RydHQ_ROnly",[]]);

if (_HQ getVariable ["RydHQ_ChosenEBDoctrine",false]) exitWith {[_HQ,_ReconAv,_AttackAv] call HAL_HQOrdersEast};

if ((_HQ getVariable ["RydHQ_AttackReserve",0]) > 0) then 
	{
	for [{_g = 0},{_g < floor ((count _AttackAv)*(_HQ getVariable ["RydHQ_AttackReserve",0.5]))},{_g = _g + 1}] do
		{
		_ResC = _AttackAv select _g;
		if not (_ResC in (_HQ getVariable ["RydHQ_FirstToFight",[]])) then 
			{
			_AttackAv = _AttackAv - [_ResC];
			if not (_HQ getVariable ["RydHQ_FlankingDone",false]) then {if ((random 100 > (30/(0.5 + (_HQ getVariable ["RydHQ_Fineness",0.5])))) and not (_ResC in _FlankAv)) then {_FlankAv set [(count _FlankAv),_ResC]}}
			};
		}
	};
	
_FlankAv = _FlankAv - ((_HQ getVariable ["RydHQ_NoFlank",[]]) + (_HQ getVariable ["RydHQ_AOnly",[]]) + (_HQ getVariable ["RydHQ_ROnly",[]]));
_HQ setVariable ["RydHQ_AttackAv",_AttackAv];
_HQ setVariable ["RydHQ_FlankAv",_FlankAv];
_HQ setVariable ["RydHQ_CombatAv",_FlankAv + _AttackAv];
_HQ setVariable ["RydHQ_Exhausted",_exhausted];
_timeStamp = _HQ getVariable ["RydHQ_FlankingTimeStamp",0];

if not (_HQ getVariable ["RydHQ_FlankingInit",false]) then 
	{
	if not ((_HQ getVariable ["RydHQ_Order","ATTACK"]) == "DEFEND") then
		{
		if (_HQ getVariable ["RydHQ_FlankReady",false]) then
			{
			if ((_HQ getVariable ["RydHQ_FlankingTimeStamp",0]) == 0) then {_HQ setVariable ["RydHQ_FlankingTimeStamp",time]};
			_timeStamp = _HQ getVariable ["RydHQ_FlankingTimeStamp",0];
			if ((count (_HQ getVariable ["RydHQ_KnEnemies",[]])) > 0) then
				{
				if not (_HQ getVariable ["RydHQ_DefDone",false]) then
					{
					_obj = getPosATL (_HQ getVariable ["RydHQ_Obj",(leader _HQ)]);

					if (_AAO) then
						{
						_obj = _HQ getVariable ["RydHQ_EyeOfBattle",getPosATL (vehicle (leader _HQ))]
						};
				
					_gap = (time - _timeStamp) - (60 * (1 + ((vehicle (leader _HQ)) distance _obj)/1000));
					if (_gap > 0) then
						{
						_HQ setVariable ["RydHQ_FlankingInit",true];
						[_HQ] call HAL_Flanking
						}
					}
				}
			}
		}
	};
	
_toRecon = [_HQ getVariable ["RydHQ_Obj",(leader _HQ)]];
_objectives = _HQ getVariable ["RydHQ_Objectives",[vehicle (leader _HQ)]];

_stages = 3;
if ([] call RYD_isNight) then {_stages = 5};

if (_AAO) then
	{
	_taken = _HQ getVariable ["RydHQ_Taken",[]];
	_toRecon = _objectives - _taken;

	if not (_HQ getVariable ["RydHQ_UnlimitedCapt",false]) then
		{
		_allAttackers = 0;
			
			{
			_allAttackers = _allAttackers + (count (units _x))
			}
		foreach _AttackAv;
					
		while {(((_allAttackers/(_HQ getVariable ["RydHQ_CaptLimit",10])) < (count _toRecon)) or ((count _AttackAv) < (((1.5 + _stages) * (count _toRecon)))))} do
			{
			if ((count _toRecon) < 2) exitWith {};
			_toRecon resize ((count _toRecon) - 1)
			}
		}
	};
	
if (_HQ getVariable ["RydHQ_KIA",false]) exitWith {RydxHQ_AllHQ = RydxHQ_AllHQ - [_HQ]};
	
if (((_HQ getVariable ["RydHQ_NoRec",1]) * ((_HQ getVariable ["RydHQ_Recklessness",0.5]) + 0.01)) < (random 100)) then 
	{
	if ((count (_HQ getVariable ["RydHQ_KnEnemiesG",[]])) == 0) then
		{
			{
			_HQ setVariable ["RydHQ_ReconStage2",1];
			_reconNr = [_foreachIndex,_stages];
			_PosObj1 = getPosATL (vehicle _x);
			_rcheckArr = [(_HQ getVariable ["RydHQ_Garrison",[]]),_ReconAv,_FlankAv,(_HQ getVariable ["RydHQ_NoRecon",[]]),_exhausted,(_HQ getVariable ["RydHQ_NCCargoG",[]]),_x,(_HQ getVariable ["RydHQ_NCVeh",[]])];
			if (not ((count (_HQ getVariable ["RydHQ_RAirG",[]])) == 0) and ((count (_HQ getVariable ["RydHQ_ReconAv",[]])) > 0) and not (_HQ getVariable ["RydHQ_ReconDone",false]) and not ((_HQ getVariable ["RydHQ_ReconStage",1]) > (_stages * (count _toRecon)))) then
				{
				_gps = [(_HQ getVariable ["RydHQ_RAirG",[]]),"R",_rcheckArr,20000,true] call RYD_Recon;

					{
					if ((_HQ getVariable ["RydHQ_ReconStage2",1]) > _stages) exitWith {};
					_HQ setVariable ["RydHQ_ReconStage",(_HQ getVariable ["RydHQ_ReconStage",1]) + 1];
					_HQ setVariable ["RydHQ_ReconStage2",(_HQ getVariable ["RydHQ_ReconStage2",1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable ["RydHQ_ReconAv",[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable ["RydHQ_ReconAv",_reconAv];
					[[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,true],HAL_GoRecon] call RYD_Spawn;
					}
				foreach _gps
				};

			if (not ((count (_HQ getVariable ["RydHQ_reconG",[]])) == 0) and ((count (_HQ getVariable ["RydHQ_ReconAv",[]])) > 0) and not (_HQ getVariable ["RydHQ_ReconDone",false]) and not ((_HQ getVariable ["RydHQ_ReconStage",1]) > (_stages * (count _toRecon)))) then
				{
				_gps = [(_HQ getVariable ["RydHQ_ReconG",[]]),"R",_rcheckArr,5000,false] call RYD_Recon;

					{
					if ((_HQ getVariable ["RydHQ_ReconStage2",1]) > _stages) exitWith {};
					_HQ setVariable ["RydHQ_ReconStage",(_HQ getVariable ["RydHQ_ReconStage",1]) + 1];
					_HQ setVariable ["RydHQ_ReconStage2",(_HQ getVariable ["RydHQ_ReconStage2",1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable ["RydHQ_ReconAv",[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable ["RydHQ_ReconAv",_reconAv];
					[[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,true],HAL_GoRecon] call RYD_Spawn;
					}
				foreach _gps
				};

			if (not ((count (_HQ getVariable ["RydHQ_FOG",[]])) == 0) and ((count (_HQ getVariable ["RydHQ_ReconAv",[]])) > 0) and not (_HQ getVariable ["RydHQ_ReconDone",false]) and not ((_HQ getVariable ["RydHQ_ReconStage",1]) > (_stages * (count _toRecon)))) then
				{
				_gps = [(_HQ getVariable ["RydHQ_FOG",[]]),"R",_rcheckArr,5000,false] call RYD_Recon;

					{
					if ((_HQ getVariable ["RydHQ_ReconStage2",1]) > _stages) exitWith {};
					_HQ setVariable ["RydHQ_ReconStage",(_HQ getVariable ["RydHQ_ReconStage",1]) + 1];
					_HQ setVariable ["RydHQ_ReconStage2",(_HQ getVariable ["RydHQ_ReconStage2",1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable ["RydHQ_ReconAv",[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable ["RydHQ_ReconAv",_reconAv];
					[[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,true],HAL_GoRecon] call RYD_Spawn;
					}
				foreach _gps
				};

			if (not ((count (_HQ getVariable ["RydHQ_snipersG",[]])) == 0) and ((count (_HQ getVariable ["RydHQ_ReconAv",[]])) > 0) and not (_HQ getVariable ["RydHQ_ReconDone",false]) and not ((_HQ getVariable ["RydHQ_ReconStage",1]) > (_stages * (count _toRecon)))) then
				{
				_gps = [(_HQ getVariable ["RydHQ_snipersG",[]]),"R",_rcheckArr,5000,false] call RYD_Recon;

					{
					if ((_HQ getVariable ["RydHQ_ReconStage2",1]) > _stages) exitWith {};
					_HQ setVariable ["RydHQ_ReconStage",(_HQ getVariable ["RydHQ_ReconStage",1]) + 1];
					_HQ setVariable ["RydHQ_ReconStage2",(_HQ getVariable ["RydHQ_ReconStage2",1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable ["RydHQ_ReconAv",[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable ["RydHQ_ReconAv",_reconAv];
					[[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,true],HAL_GoRecon] call RYD_Spawn;
					}
				foreach _gps
				};

			_onlyL = (_HQ getVariable ["RydHQ_LArmorG",[]]) - (_HQ getVariable ["RydHQ_MArmorG",[]]);
			if (not ((count _onlyL) == 0) and ((count (_HQ getVariable ["RydHQ_ReconAv",[]])) > 0) and not (_HQ getVariable ["RydHQ_ReconDone",false]) and not ((_HQ getVariable ["RydHQ_ReconStage",1]) > (_stages * (count _toRecon)))) then
				{
				_gps = [_onlyL,"R",_rcheckArr,20000,false] call RYD_Recon;

					{
					if ((_HQ getVariable ["RydHQ_ReconStage2",1]) > _stages) exitWith {};
					_HQ setVariable ["RydHQ_ReconStage",(_HQ getVariable ["RydHQ_ReconStage",1]) + 1];
					_HQ setVariable ["RydHQ_ReconStage2",(_HQ getVariable ["RydHQ_ReconStage2",1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable ["RydHQ_ReconAv",[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable ["RydHQ_ReconAv",_reconAv];
					[[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,true],HAL_GoRecon] call RYD_Spawn;
					}
				foreach _gps
				};

			if (not ((count ((_HQ getVariable ["RydHQ_NCrewInfG",[]]) - (_HQ getVariable ["RydHQ_SpecForG",[]]))) == 0) and ((count (_HQ getVariable ["RydHQ_ReconAv",[]])) > 0) and not (_HQ getVariable ["RydHQ_ReconDone",false]) and not ((_HQ getVariable ["RydHQ_ReconStage",1]) > (_stages * (count _toRecon)))) then
				{
				_gps = [((_HQ getVariable ["RydHQ_NCrewInfG",[]]) - (_HQ getVariable ["RydHQ_SpecForG",[]])),"NR",_rcheckArr,10000,false] call RYD_Recon;

					{
					if ((_HQ getVariable ["RydHQ_ReconStage2",1]) > _stages) exitWith {};
					_HQ setVariable ["RydHQ_ReconStage",(_HQ getVariable ["RydHQ_ReconStage",1]) + 1];
					_HQ setVariable ["RydHQ_ReconStage2",(_HQ getVariable ["RydHQ_ReconStage2",1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable ["RydHQ_ReconAv",[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable ["RydHQ_ReconAv",_reconAv];
					//[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,false] spawn HAL_GoRecon;
					[[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,false],HAL_GoRecon] call RYD_Spawn;
					}
				foreach _gps
				};

			_LMCUA = (_HQ getVariable ["RydHQ_Friends",[]]) - ((_HQ getVariable ["RydHQ_AOnly",[]]) + (_HQ getVariable ["RydHQ_NavalG",[]]) + (_HQ getVariable ["RydHQ_StaticG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]) + (_HQ getVariable ["RydHQ_ArtG",[]]) + (_HQ getVariable ["RydHQ_NoRecon",[]]) + (_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]));
			if (not ((count _LMCUA) == 0) and not (_HQ getVariable ["RydHQ_ReconDone",false]) and not ((_HQ getVariable ["RydHQ_ReconStage",1]) > (_stages * (count _toRecon)))) then
				{
				_gps = [_LMCUA,"NR",_rcheckArr,20000,false] call RYD_Recon;

					{
					if ((_HQ getVariable ["RydHQ_ReconStage2",1]) > _stages) exitWith {};
					_HQ setVariable ["RydHQ_ReconStage",(_HQ getVariable ["RydHQ_ReconStage",1]) + 1];
					_HQ setVariable ["RydHQ_ReconStage2",(_HQ getVariable ["RydHQ_ReconStage2",1]) + 1];
					_x setVariable ["Busy" + (str _x),true];
					_reconAv = _HQ getVariable ["RydHQ_ReconAv",[]];
					_reconAv = _reconAv - [_x];
					_HQ setVariable ["RydHQ_ReconAv",_reconAv];
					//[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,false] spawn HAL_GoRecon;
					[[_x,_PosObj1,(_HQ getVariable ["RydHQ_ReconStage",1]),_HQ,_reconNr,false],HAL_GoRecon] call RYD_Spawn;
					}
				foreach _gps
				}
			}
		foreach _toRecon
		}
	}
else
	{
	_HQ setVariable ["RydHQ_ReconDone",true]
	};
	
_reserve = (_HQ getVariable ["RydHQ_Friends",[]]) - ((_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]) + (_HQ getVariable ["RydHQ_AOnly",[]]) + (_HQ getVariable ["RydHQ_ROnly",[]]) + (_HQ getVariable ["RydHQ_Exhausted",[]]) + (_HQ getVariable ["RydHQ_ArtG",[]]) + (_HQ getVariable ["RydHQ_AirG",[]]) + (_HQ getVariable ["RydHQ_NavalG",[]]) + (_HQ getVariable ["RydHQ_StaticG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]) + ((_HQ getVariable ["RydHQ_NCCargoG",[]]) - ((_HQ getVariable ["RydHQ_NCrewInfG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]))));
if (not ((_HQ getVariable ["RydHQ_ReconDone",false])) and ((count (_HQ getVariable ["RydHQ_KnEnemies",[]])) == 0)) exitwith 
	{
	if (_HQ getVariable ["RydHQ_Orderfirst",true]) then 
		{
		_HQ setVariable ["RydHQ_Orderfirst",false]
		};

		{
		_recvar = str _x;
		_resting = false;
		_resting = _x getvariable ("Resting" + _recvar);
		if (isNil ("_resting")) then {_resting = false};
		if not (_resting) then 
			{
			//[_x,_HQ] spawn HAL_GoRest
			[[_x,_HQ],HAL_GoRest] call RYD_Spawn;
			}
		}
	foreach ((_HQ getVariable ["RydHQ_Exhausted",[]]) - ((_HQ getVariable ["RydHQ_AirG",[]]) + (_HQ getVariable ["RydHQ_StaticG",[]]) + (_HQ getVariable ["RydHQ_ArtG",[]]) + (_HQ getVariable ["RydHQ_NavalG",[]])));

	if (_HQ getVariable ["RydHQ_IdleOrd",true]) then
		{

			{
			_recvar = str _x;
			_busy = false;
			_deployed = false;
			_capturing = false;
			_capturing = _x getVariable ("Capt" + _recvar);
			if (isNil ("_capturing")) then {_capturing = false};
			_deployed = _x getvariable ("Deployed" + _recvar);
			_busy = _x getvariable ("Busy" + _recvar);
			if (isNil ("_busy")) then {_busy = false};
			if (isNil ("_deployed")) then {_deployed = false};
			if (not (_busy) and ((count (waypoints _x)) <= 1) and not (_deployed) and not (_capturing) and (not (_x in (_HQ getVariable ["RydHQ_NCCargoG",[]])) or ((count (units _x)) > 1))) then 
				{
				deleteWaypoint ((waypoints _x) select 0);
				//[_x,_HQ] spawn HAL_GoIdle
				[[_x,_HQ],HAL_GoIdle] call RYD_Spawn;
				}
			}
		foreach _reserve;
		}
	};

_HQ setVariable ["RydHQ_FlankReady",true];

_reconthreat = [];
_FOthreat = [];
_snipersthreat = [];
_ATinfthreat = [];
_AAinfthreat = [];
_Infthreat = [];
_Artthreat = [];
_HArmorthreat = [];
_LArmorthreat = [];
_LArmorATthreat = [];
_Carsthreat = [];
_Airthreat = [];
_Navalthreat = [];
_Staticthreat = [];
_StaticAAthreat = [];
_StaticATthreat = [];
_Supportthreat = [];
_Cargothreat = [];
_Otherthreat = [];

	{
	_GE = (group _x);
	_GEvar = str _GE;
	_checked = _GE getvariable ("Checked" + _GEvar);
	if (isNil ("_checked")) then {_GE setvariable [("Checked" + _GEvar),false]};
	_checked = false;

	if ((_x in (_HQ getVariable ["RydHQ_Enrecon",[]])) and not (_GE in _reconthreat) and not (_checked)) then {_reconthreat set [(count _reconthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnFO",[]])) and not (_GE in _FOthreat) and not (_checked)) then {_FOthreat set [(count _FOthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_Ensnipers",[]])) and not (_GE in _snipersthreat) and not (_checked)) then {_snipersthreat set [(count _snipersthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnATinf",[]])) and not (_GE in _ATinfthreat) and not (_checked)) then {_ATinfthreat set [(count _ATinfthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnAAinf",[]])) and not (_GE in _AAinfthreat) and not (_checked)) then {_AAinfthreat set [(count _AAinfthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnInf",[]])) and not (_GE in _Infthreat) and not (_checked)) then {_Infthreat set [(count _Infthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnArt",[]])) and not (_GE in _Artthreat) and not (_checked)) then {_Artthreat set [(count _Artthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnHArmor",[]])) and not (_GE in _LArmorthreat) and not (_checked)) then {_LArmorthreat set [(count _LArmorthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnLArmor",[]])) and not (_GE in _reconthreat) and not (_checked)) then {_reconthreat set [(count _reconthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnLArmorAT",[]])) and not (_GE in _LArmorATthreat) and not (_checked)) then {_LArmorATthreat set [(count _LArmorATthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnCars",[]])) and not (_GE in _Carsthreat) and not (_checked)) then {_Carsthreat set [(count _Carsthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnAir",[]])) and not (_GE in _Airthreat) and not (_checked)) then {_Airthreat set [(count _Airthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnNaval",[]])) and not (_GE in _Navalthreat) and not (_checked)) then {_Navalthreat set [(count _Navalthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnStatic",[]])) and not (_GE in _Staticthreat) and not (_checked)) then {_Staticthreat set [(count _Staticthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnStaticAA",[]])) and not (_GE in _StaticAAthreat) and not (_checked)) then {_StaticAAthreat set [(count _StaticAAthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnStaticAT",[]])) and not (_GE in _StaticATthreat) and not (_checked)) then {_StaticATthreat set [(count _StaticATthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnSupport",[]])) and not (_GE in _Supportthreat) and not (_checked)) then {_Supportthreat set [(count _Supportthreat),_GE]};
	if ((_x in (_HQ getVariable ["RydHQ_EnCargo",[]])) and not (_GE in _Cargothreat) and not (_checked)) then {_Cargothreat set [(count _Cargothreat),_GE]};

	if ((_x in (_HQ getVariable ["RydHQ_EnInf",[]])) and ((vehicle _x) in (_HQ getVariable ["RydHQ_EnCargo",[]])) and not (_x in (_HQ getVariable ["RydHQ_EnCrew",[]])) and not (_GE in _Infthreat) and not (_checked)) then {_Infthreat set [(count _Infthreat),_GE]};

	if ((isNil ("_checked")) or not (_checked)) then {_GE setVariable [("Checked" + _GEvar), true]};
	}
foreach (_HQ getVariable ["RydHQ_KnEnemies",[]]);

_HQ setVariable ["RydHQ_AAthreat",(_AAinfthreat + _StaticAAthreat)];
_HQ setVariable ["RydHQ_ATthreat",(_ATinfthreat + _StaticATthreat + _HArmorthreat + _LArmorATthreat)];
_HQ setVariable ["RydHQ_Airthreat",_Airthreat];
_reconthreat = _reconthreat - _Airthreat;

_FPool = 
	[
	(_HQ getVariable ["RydHQ_snipersG",[]]),
	(_HQ getVariable ["RydHQ_NCrewInfG",[]]) - (_HQ getVariable ["RydHQ_SpecForG",[]]),
	(_HQ getVariable ["RydHQ_AirG",[]]) - ((_HQ getVariable ["RydHQ_NCAirG",[]]) + (_HQ getVariable ["RydHQ_NCrewInfG",[]])),
	(_HQ getVariable ["RydHQ_LArmorG",[]]),
	(_HQ getVariable ["RydHQ_HArmorG",[]]),
	(_HQ getVariable ["RydHQ_CarsG",[]]) - ((_HQ getVariable ["RydHQ_ATInfG",[]]) + (_HQ getVariable ["RydHQ_AAInfG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]) + (_HQ getVariable ["RydHQ_NCCargoG",[]])),
	(_HQ getVariable ["RydHQ_LArmorATG",[]]),
	(_HQ getVariable ["RydHQ_ATInfG",[]]),
	(_HQ getVariable ["RydHQ_AAInfG",[]]),
	(_HQ getVariable ["RydHQ_Recklessness",0.5]),
	(_HQ getVariable ["RydHQ_AttackAv",[]]),
	(_HQ getVariable ["RydHQ_Garrison",[]]),
	(_HQ getVariable ["RydHQ_GarrR",500]),
	(_HQ getVariable ["RydHQ_FlankAv",[]]),
	(_HQ getVariable ["RydHQ_AirG",[]]),
	(_HQ getVariable ["RydHQ_NCVeh",[]])
	];

_constant = [(_HQ getVariable ["RydHQ_AAthreat",[]]),(_HQ getVariable ["RydHQ_ATthreat",[]]),_HArmorthreat + _LArmorATthreat,_FPool];

if (count (_reconthreat + _FOthreat + _snipersthreat) > 0) then 
	{
	([_reconthreat + _FOthreat + _snipersthreat,"Recon",_HQ,0,0,0] + _constant) call RYD_Dispatcher;
	};

if (count _ATinfthreat > 0) then 
	{
	([_ATinfthreat,"ATInf",_HQ,0,0,85] + _constant) call RYD_Dispatcher;
	};

if (count _Infthreat > 0) then 
	{
	([_Infthreat,"Inf",_HQ,75,80,85] + _constant) call RYD_Dispatcher;
	};

if (count (_LArmorthreat + _HArmorthreat) > 0) then 
	{
	([_LArmorthreat + _HArmorthreat,"Armor",_HQ,50,0,85] + _constant) call RYD_Dispatcher;
	};

if (count _Carsthreat > 0) then 
	{
	([_Carsthreat,"Cars",_HQ,75,80,85] + _constant) call RYD_Dispatcher;
	};

if (count _Artthreat > 0) then 
	{
	([_Artthreat,"Art",_HQ,70,75,75] + _constant) call RYD_Dispatcher;
	};

if (count _Airthreat > 0) then 
	{
	([_Airthreat,"Air",_HQ,0,0,75] + _constant) call RYD_Dispatcher;
	};

if (count (_Staticthreat - _Artthreat) > 0) then 
	{
	([_Staticthreat - _Artthreat,"Static",_HQ,75,80,85] + _constant) call RYD_Dispatcher;
	};

/////////////////////////////////////////
// Capture Objective

_toTake = [_HQ getVariable ["RydHQ_Obj",(leader _HQ)]];

if (_AAO) then
	{
	_taken = _HQ getVariable ["RydHQ_Taken",[]]; 
	_toTake = _objectives - _taken;
	
		{
		if not (_x in _toRecon) then
			{
			_toTake set [_foreachIndex,objNull];
			}
		}
	foreach _toTake;
	
	_toTake = _toTake - [objNull];
		
	_allAttackers = 0;
		
		{
		_allAttackers = _allAttackers + (count (units _x))
		}
	foreach _AttackAv;
				
	while {(((_allAttackers/(_HQ getVariable ["RydHQ_CaptLimit",10])) < (count _toTake)) or ((count _AttackAv) < ((1.5 * (count _toTake)))))} do
		{
		if ((count _toTake) < 2) exitWith {};
		_toTake resize ((count _toTake) - 1)
		}
	};
	
	{
	if (isNil {_x}) then {_toTake set [_foreachIndex,objNull]};
	}
foreach _toTake;

_toTake = _toTake - [objNull];
	
	{
	_Trg = _x;

	if not (_AAO) then
		{
			{
			_x setVariable [("Capturing" + (str _x)),[0,0]]
			}
		foreach (_objectives - [(_HQ getVariable ["RydHQ_Obj",(leader _HQ)])]);
		};

	_isAttacked = _Trg getvariable ("Capturing" + (str _Trg));

	if (isNil ("_isAttacked")) then {_isAttacked = [0,0]};

	_captCount = _isAttacked select 1;
	_isAttacked = _isAttacked select 0;
	_captLimit = (_HQ getVariable ["RydHQ_CaptLimit",10]) * (1 + ((_HQ getVariable ["RydHQ_Circumspection",0.5])/(2 + (_HQ getVariable ["RydHQ_Recklessness",0.5]))));
	if ((_isAttacked <= 3) or (_captCount < _captLimit)) then
		{
		_allT = _HQ getVariable ["RydHQ_NObj",1];
		if (_AAO) then
			{
			_allT = (count _taken) + 1
			};
		
		if ((not (_allT > 4) and ((random 100) > ((count (_HQ getVariable ["RydHQ_KnEnemies",[]]))*(5/(0.5 + (2*(_HQ getVariable ["RydHQ_Recklessness",0.5])))))) and not 
			(_HQ getVariable ["RydHQ_Orderfirst",true]) and 
				((random 100) < ((((count (_HQ getVariable ["RydHQ_Friends",[]]))*(0.5 + (_HQ getVariable ["RydHQ_Recklessness",0.5])))/(5*(0.5 + count (_HQ getVariable ["RydHQ_KnEnemiesG",[]]))))*(((_HQ getVariable ["RydHQ_Cyclecount",1]) - 5)*2*(1 + (_HQ getVariable ["RydHQ_Recklessness",0.5])))))) or
					((((_HQ getVariable ["RydHQ_RapidCapt",10]) * ((_HQ getVariable ["RydHQ_Recklessness",0.5]) + 0.01)) > (random 100)) and ((_HQ getVariable ["RydHQ_NObj",1]) <= 4))) then   
			{
			_checked = [];
			_forCapt = (_HQ getVariable ["RydHQ_NCrewInfG",[]]) - ((_HQ getVariable ["RydHQ_Exhausted",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]) + (_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]) + (_HQ getVariable ["RydHQ_Garrison",[]]));
			_forCapt = _forCapt - ((_HQ getVariable ["RydHQ_AOnly",[]]) + (_HQ getVariable ["RydHQ_ROnly",[]]));
			_forCapt = [_forCapt] call RYD_SizeOrd;

			if (not ((count _forCapt) == 0) and ((count (_HQ getVariable ["RydHQ_AttackAv",[]])) > 0)) then
				{
				for [{_m = 500},{_m <= 5000},{_m = _m + 500}] do
					{
					_isAttacked = _Trg getvariable ("Capturing" + (str _Trg));
					if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
					_captCount = _isAttacked select 1;
					_isAttacked = _isAttacked select 0;

					if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitwith {};

						{
						_isAttacked = _Trg getvariable ("Capturing" + (str _Trg));
						if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
						_captCount = _isAttacked select 1;
						_isAttacked = _isAttacked select 0;

						if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitwith {};

						if (_x in (_HQ getVariable ["RydHQ_AttackAv",[]])) then
							{

							if (((leader _x) distance _Trg) <= _m) then
								{
								if (not (_x in (_HQ getVariable ["RydHQ_NCCargoG",[]])) or ((count (units _x)) > 1)) then 
									{
									_ammo = [_x,(_HQ getVariable ["RydHQ_NCVeh",[]])] call RYD_AmmoCount;

									if (_ammo > 0) then
										{
										_busy = _x getVariable [("Busy" + (str _x)),false];

										if not (_busy) then
											{
											_x setVariable [("Busy" + (str _x)),true];
											_HQ setVariable ["RydHQ_AttackAv",(_HQ getVariable ["RydHQ_AttackAv",[]]) - [_x]];
											_checked set [(count _checked),_x];
											_groupCount = count (units _x);

											switch (_isAttacked) do
												{
												case (4) : {_Trg setvariable [("Capturing" + (str  _Trg)),[5,_captCount + _groupCount]]};
												case (3) : {_Trg setvariable [("Capturing" + (str  _Trg)),[4,_captCount + _groupCount]]};
												case (2) : {_Trg setvariable [("Capturing" + (str  _Trg)),[3,_captCount + _groupCount]]};
												case (1) : {_Trg setvariable [("Capturing" + (str  _Trg)),[2,_captCount + _groupCount]]};
												case (0) : {_Trg setVariable [("Capturing" + (str  _Trg)),[1,_captCount + _groupCount]]};
												};

											//[_x,_isAttacked,_HQ,_Trg] spawn HAL_GoCapture;
											[[_x,_isAttacked,_HQ,_Trg],HAL_GoCapture] call RYD_Spawn;
											}
										}
									}
								}
							}
						}
					foreach _forCapt;
					_forCapt = _forCapt - _checked
					}
				};

			if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitwith {};

			_LMCU = (_HQ getVariable ["RydHQ_Friends",[]]) - ((_HQ getVariable ["RydHQ_Exhausted",[]]) + ((_HQ getVariable ["RydHQ_AirG",[]]) - (_HQ getVariable ["RydHQ_NCrewInfG",[]])) + (_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]) + (_HQ getVariable ["RydHQ_NavalG",[]]) + (_HQ getVariable ["RydHQ_StaticG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]) + (_HQ getVariable ["RydHQ_ArtG",[]]) + (_HQ getVariable ["RydHQ_Garrison",[]]) + ((_HQ getVariable ["RydHQ_NCCargoG",[]]) - ((_HQ getVariable ["RydHQ_NCrewInfG",[]]) - (_HQ getVariable ["RydHQ_SupportG",[]]))));
			_LMCU = _LMCU - ((_HQ getVariable ["RydHQ_AOnly",[]]) + (_HQ getVariable ["RydHQ_ROnly",[]]));
			_LMCU = [_LMCU] call RYD_SizeOrd;
			if (not ((count _LMCU) == 0) and ((count (_HQ getVariable ["RydHQ_AttackAv",[]])) > 0)) then
				{
				for [{_m = 1000},{_m <= 20000},{_m = _m + 1000}] do
					{
					_isAttacked = _Trg getvariable ("Capturing" + (str _Trg));
					if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
					_captCount = _isAttacked select 1;
					_isAttacked = _isAttacked select 0;
					if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitwith {};

						{
						_isAttacked = _Trg getvariable ("Capturing" + (str _Trg));
						if (isNil ("_isAttacked")) then {_isAttacked = [1,0]};
						_captCount = _isAttacked select 1;
						_isAttacked = _isAttacked select 0;

						if ((_isAttacked > 3) and (_captCount >= _captLimit)) exitwith {};
						if (_x in (_HQ getVariable ["RydHQ_AttackAv",[]])) then
							{
							if (((leader _x) distance _Trg) <= _m) then
								{
								_ammo = [_x,(_HQ getVariable ["RydHQ_NCVeh",[]])] call RYD_AmmoCount;
								if (_ammo > 0) then
									{
									_busy = _x getVariable [("Busy" + (str _x)),false];

									if not (_busy) then
										{
										_x setVariable [("Busy" + (str _x)),true];
										_HQ setVariable ["RydHQ_AttackAv",(_HQ getVariable ["RydHQ_AttackAv",[]]) - [_x]];
										_checked set [(count _checked),_x];
										_groupCount = count (units _x);

										switch (_isAttacked) do
											{
											case (4) : {_Trg setvariable [("Capturing" + (str  _Trg)),[5,_captCount + _groupCount]]};
											case (3) : {_Trg setvariable [("Capturing" + (str  _Trg)),[4,_captCount + _groupCount]]};
											case (2) : {_Trg setvariable [("Capturing" + (str  _Trg)),[3,_captCount + _groupCount]]};
											case (1) : {_Trg setvariable [("Capturing" + (str  _Trg)),[2,_captCount + _groupCount]]};
											case (0) : {_Trg setVariable [("Capturing" + (str  _Trg)),[1,_captCount + _groupCount]]};
											};

										//[_x,_isAttacked,_HQ,_Trg] spawn HAL_GoCapture;
										[[_x,_isAttacked,_HQ,_Trg],HAL_GoCapture] call RYD_Spawn;
										}
									}
								}
							}
						}
					foreach _LMCU;
					_LMCU = _LMCU - _checked
					}
				}
			}
		}
	}
foreach _toTake;

/*if (_HQ getVariable ["RydHQ_WA",true]) then
	{
	_WADone = _HQ getVariable ["RydHQ_WADone",0];
	_WAchance = ((1 + (_HQ getVariable ["RydHQ_Activity",0.5]) + (_HQ getVariable ["RydHQ_Recklessness",0.5]))^2)/(10 + (10 * (_WADone^2)));

	if (_WAchance > (random 1)) then
		{
		_armored = (_HQ getVariable ["RydHQ_HArmorG",[]]) + (_HQ getVariable ["RydHQ_LArmorG",[]]);
		_LMCU = (_HQ getVariable ["RydHQ_Friends",[]]) - (((_HQ getVariable ["RydHQ_AirG",[]]) - (_HQ getVariable ["RydHQ_NCrewInfG",[]])) + (_HQ getVariable ["RydHQ_Exhausted",[]]) + (_HQ getVariable ["RydHQ_NoAttack",[]]) + (_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]) + (_HQ getVariable ["RydHQ_NavalG",[]]) + (_HQ getVariable ["RydHQ_StaticG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]) + (_HQ getVariable ["RydHQ_ArtG",[]]) + (_HQ getVariable ["RydHQ_Garrison",[]]) + ((_HQ getVariable ["RydHQ_NCCargoG",[]]) - ((_HQ getVariable ["RydHQ_NCrewInfG",[]]) - (_HQ getVariable ["RydHQ_SupportG",[]]))));
		
		_WAAv = [];
		
			{
			if not (_x getVariable ["Busy" + (str _x),false]) then
				{
				_WAAv set [(count _WAAv),_x]
				}
			}
		foreach _LMCU;
		
		if ((count _WAAv) == 0) exitWith {};
		
		_WAAv = [_WAAv] call RYD_RandomOrd;
		
		_where = [];
		
			{
			_heldBy = _x getVariable ["RydHQ_HeldBy",0];
			if not (_heldBy > ((random 4) * (0.5 + (_HQ getVariable ["RydHQ_Consistency",0.5])))) then
				{
				if (((1 + (_HQ getVariable ["RydHQ_Consistency",0.5]) + (_HQ getVariable ["RydHQ_Fineness",0.5]))/4) > (random 1)) then
					{
					_where set [(count _where),_x]
					}
				}
			}
		foreach [(_HQ getVariable ["RydHQ_Obj1",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj2",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj3",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])];
		
		if ((count _where) == 0) then {_where = [(_HQ getVariable ["RydHQ_Obj",(leader _HQ)])]};
		
		_howMuch = ((_HQ getVariable ["RydHQ_Recklessness",[]]) + (random 0.5))/1.5;
		if (_howMuch > 1) then {_howMuch = 1};
		_howMuch = floor (_howMuch * (count _WAAv));
		
		while {((_howMuch > 0) and ((count _WAAv) > 0))} do
			{
				{
				_gp = _WAAv select 0;
				_code = HAL_GoHoldInf;
				if (_gp in _armored) then {_code = HAL_GoHoldArmor};
				_WAAv = _WAAv - [_gp];
				_gp setVariable ["Busy" + (str _gp),true];
				
				[_gp,_x] spawn _code;
				
				_howMuch = _howMuch - 1;
				
				if ((_howMuch < 1) or ((count _WAAv) < 1)) exitWith {}
				}
			foreach _where
			}
		}
	};*/
		
if (_HQ getVariable ["RydHQ_IdleOrd",true]) then
	{
	_reserve = (_HQ getVariable ["RydHQ_Friends",[]]) - ((_HQ getVariable ["RydHQ_SpecForG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]) + (_HQ getVariable ["RydHQ_NoRecon",[]]) + (_HQ getVariable ["RydHQ_NoAttack",[]]) + (_HQ getVariable ["RydHQ_Exhausted",[]]) + (_HQ getVariable ["RydHQ_ArtG",[]]) + (_HQ getVariable ["RydHQ_AirG",[]]) + (_HQ getVariable ["RydHQ_NavalG",[]]) + (_HQ getVariable ["RydHQ_StaticG",[]]) + ((_HQ getVariable ["RydHQ_NCCargoG",[]]) - ((_HQ getVariable ["RydHQ_NCrewInfG",[]]) + (_HQ getVariable ["RydHQ_SupportG",[]]))));

		{
		_recvar = str _x;
		_busy = false;
		_deployed = false;
		_capturing = false;
		_capturing = _x getVariable ("Capt" + _recvar);
		if (isNil ("_capturing")) then {_capturing = false};
		_deployed = _x getvariable ("Deployed" + _recvar);
		_busy = _x getvariable ("Busy" + _recvar);
		if (isNil ("_busy")) then {_busy = false};
		if (isNil ("_deployed")) then {_deployed = false};
		if (not (_busy) and ((count (waypoints _x)) <= 1) and not (_deployed) and not (_capturing) and (not (_x in (_HQ getVariable ["RydHQ_NCCargoG",[]])) or ((count (units _x)) > 1))) then 
			{
			deleteWaypoint ((waypoints _x) select 0);
			//[_x,_HQ] spawn HAL_GoIdle
			[[_x,_HQ],HAL_GoIdle] call RYD_Spawn;
			};
		}
	foreach _reserve
	};

	{
	_recvar = str _x;
	_resting = false;
	_resting = _x getvariable ("Resting" + _recvar);
	if (isNil ("_resting")) then {_resting = false};
	if not (_resting) then 
		{
		if not (_x in (_HQ getVariable ["RydHQ_Garrison",[]])) then
			{
			//[_x,_HQ] spawn HAL_GoRest
			[[_x,_HQ],HAL_GoRest] call RYD_Spawn;
			}
		}
	}
foreach ((_HQ getVariable ["RydHQ_Exhausted",[]]) - ((_HQ getVariable ["RydHQ_AirG",[]]) + (_HQ getVariable ["RydHQ_StaticG",[]]) + (_HQ getVariable ["RydHQ_ArtG",[]]) + (_HQ getVariable ["RydHQ_NavalG",[]])));

	{
	_GE = (group _x);
	_GEvar = str _GE;
	_GE setvariable [("Checked" + _GEvar),false];
	}
foreach (_HQ getVariable ["RydHQ_KnEnemies",[]]);

if (_HQ getVariable ["RydHQ_Orderfirst",true]) then {_HQ setVariable ["RydHQ_Orderfirst",false]};

