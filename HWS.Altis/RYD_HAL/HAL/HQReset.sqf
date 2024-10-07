_SCRname = "Reset";

private ["_HQ","_Edistance","_LE","_LEvar","_trg","_mLoss","_lastObj","_lost","_AllV20","_Civs20","_AllV2","_Civs20","_Civs2","_NearEnemies","_AllV0","_Civs0","_AllV","_Civs","_NearAllies","_objectives",
	"_captLimit","_enRoute","_captDiff","_isC","_amountC","_reserve","_exhausted","_unitvar","_nominal","_current","_ex","_Aex","_unitvarA","_nominalA","_currentA","_AAO","_taken","_cTaken","_oTaken"];

_HQ = _this select 0;

_AAO = _HQ getVariable ["RydHQ_ChosenAAO",false];
		
_Edistance = false;

	{
	if ((_x distance (_HQ getVariable ["leaderHQ",leader _HQ])) < 2000) exitwith {_Edistance = true};
	}
foreach (_HQ getVariable ["RydHQ_KnEnemies",[]]);
_HQ setVariable ["RydHQ_ReconDone",false];
_HQ setVariable ["RydHQ_ReconStage",1];

if (_Edistance) then
	{
		{
		_LE = (leader _x);
		_LEvar = str _LE;
		_LE setVariable [("Checked" + _LEvar), false]
		}
	foreach ((_HQ getVariable ["RydHQ_Enemies",[]]) - (_HQ getVariable ["RydHQ_KnEnemiesG",[]]))
	};

_HQ setVariable ["RydHQ_DefDone",false];

if (not ((_HQ getVariable ["RydHQ_Order","ATTACK"]) == "DEFEND") or ((random 100) > 95)) then 
	{
		{
		_x setVariable ["Defending", false];
		_x setvariable ["SPRTD",0];
		_x setvariable ["Reinforcing",GrpNull];
		}
	foreach (_HQ getVariable ["RydHQ_Friends",[]])
	};

_trg = _HQ getVariable ["leaderHQ",(leader _HQ)];
_nObj = _HQ getVariable ["RydHQ_NObj",1];

_objectives = [(_HQ getVariable ["RydHQ_Obj1",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj2",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj3",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])];

switch (_nObj) do
	{
	case (1) : {_trg = _HQ getVariable ["RydHQ_Obj1",(leader _HQ)];_HQ setVariable ["RydHQ_Obj",(_HQ getVariable ["RydHQ_Obj1",(leader _HQ)])]};
	case (2) : {_trg = _HQ getVariable ["RydHQ_Obj2",(leader _HQ)];_HQ setVariable ["RydHQ_Obj",(_HQ getVariable ["RydHQ_Obj2",(leader _HQ)])]};
	case (3) : {_trg = _HQ getVariable ["RydHQ_Obj3",(leader _HQ)];_HQ setVariable ["RydHQ_Obj",(_HQ getVariable ["RydHQ_Obj3",(leader _HQ)])]};
	default {_trg = _HQ getVariable ["RydHQ_Obj4",(leader _HQ)];_HQ setVariable ["RydHQ_Obj",(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])]};
	};

_mLoss = 10 * RYD_WS_MoraleObjCoeffL;
if ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in (RydBBa_HQs + RydBBb_HQs)) then {_mLoss = 0};

_lastObj = _HQ getVariable ["RydHQ_NObj",1];

_lost = ObjNull;
_taken = _HQ getVariable ["RydHQ_Taken",[]];
_oTaken = +_taken;
_cTaken = count _taken;

	{
	_AllV20 = _x nearEntities [["AllVehicles"],(_HQ getVariable ["RydHQ_ObjRadius1",300])];
	_Civs20 = _x nearEntities [["Civilian"],(_HQ getVariable ["RydHQ_ObjRadius1",300])];

	_AllV2 = [];

		{
		_AllV2 = _AllV2 + (crew _x)
		}
	foreach _AllV20;

	_Civs20 = _trg nearEntities [["Civilian"],(_HQ getVariable ["RydHQ_ObjRadius2",500])];

	_Civs2 = [];

		{
		_Civs2 = _Civs2 + (crew _x)
		}
	foreach _Civs20;

	_AllV2 = _AllV2 - _Civs2;

	_AllV20 = +_AllV2;

		{
		if not (_x isKindOf "Man") then
			{
			if ((count (crew _x)) == 0) then {_AllV2 = _AllV2 - [_x]}
			}
		}
	foreach _AllV20;

	_NearEnemies = (_HQ getVariable ["leaderHQ",(leader _HQ)]) countenemy _AllV2;
	_AllV0 = _x nearEntities [["AllVehicles"],(_HQ getVariable ["RydHQ_ObjRadius2",500])];
	_Civs0 = _x nearEntities [["Civilian"],(_HQ getVariable ["RydHQ_ObjRadius2",500])];

	_AllV = [];

		{
		_AllV = _AllV + (crew _x)
		}
	foreach _AllV0;

	_Civs = [];

		{
		_Civs = _Civs + (crew _x)
		}
	foreach _Civs0;

	_AllV = _AllV - _Civs;
	_AllV0 = +_AllV;

		{
		if not (_x isKindOf "Man") then
			{
			if ((count (crew _x)) == 0) then {_AllV = _AllV - [_x]}
			}
		}
	foreach _AllV0;

	_NearAllies = (_HQ getVariable ["leaderHQ",(leader _HQ)]) countfriendly _AllV;

	if (_x == _trg) then
		{
		_captLimit = (_HQ getVariable ["RydHQ_CaptLimit",10]) * (1 + ((_HQ getVariable ["RydHQ_Circumspection",0.5])/(2 + (_HQ getVariable ["RydHQ_Recklessness",0.5]))));
		_enRoute = 0;

			{
			if not (isNull _x) then
				{
				if (_x getVariable [("Capt" + (str _x)),false]) then
					{
					_enRoute = _enRoute + (count (units _x))
					}
				}
			}
		foreach (_HQ getVariable ["RydHQ_Friends",[]]);

		_captDiff = _captLimit - _enRoute;

		if (_captDiff > 0) then
			{	
			_isC = _trg getVariable ("Capturing" + (str _trg));if (isNil "_isC") then {_isC = [0,0]};

			_amountC = _isC select 1;
			_isC = _isC select 0;
			if (_isC > 3) then {_isC = 3};
			_trg setVariable [("Capturing" + (str _trg)),[_isC,_amountC - _captDiff]];
			}
		};

	if ((_NearEnemies > _NearAllies) and not (_AAO)) exitwith {_lost = _x};
	if (_NearEnemies > _NearAllies) then {_taken = _taken - [_x]};
	}
foreach _objectives;

if not ((RydBB_Active) and ((leader _HQ) in (RydBBa_HQs + RydBBb_HQs))) then
	{
	_HQ setVariable ["RydHQ_Taken",_taken]; 

	if not (_AAO) then
		{
		if (isNull _lost)	then {_HQ setVariable ["RydHQ_NObj",_lastObj]} else {
			if (_lost == (_HQ getVariable ["RydHQ_Obj1",(leader _HQ)])) then {_HQ setVariable ["RydHQ_NObj",1];{_x setVariable [("Capturing" + (str _x)),[0,0]]}foreach ([(_HQ getVariable ["RydHQ_Obj1",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj2",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj3",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])])} else {
				if ((_lost == (_HQ getVariable ["RydHQ_Obj2",(leader _HQ)])) and ((_HQ getVariable ["RydHQ_NObj",1]) > 2)) then {_HQ setVariable ["RydHQ_NObj",2];{_x setVariable [("Capturing" + (str _x)),[0,0]]}foreach ([(_HQ getVariable ["RydHQ_Obj2",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj3",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])])} else {
					if ((_lost == (_HQ getVariable ["RydHQ_Obj3",(leader _HQ)])) and ((_HQ getVariable ["RydHQ_NObj",1]) > 3)) then {_HQ setVariable ["RydHQ_NObj",3];{_x setVariable [("Capturing" + (str _x)),[0,0]]}foreach ([(_HQ getVariable ["RydHQ_Obj3",(leader _HQ)]),(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])])} else {
						if ((_lost == (_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])) and ((_HQ getVariable ["RydHQ_NObj",1]) >= 4)) then {_HQ setVariable ["RydHQ_NObj",4];{_x setVariable [("Capturing" + (str _x)),[0,0]]}foreach ([(_HQ getVariable ["RydHQ_Obj4",(leader _HQ)])])}}}}};
		
		if ((_HQ getVariable ["RydHQ_NObj",1]) < 1) then {_HQ setVariable ["RydHQ_NObj",1]};
		if ((_HQ getVariable ["RydHQ_NObj",1]) > 5) then {_HQ setVariable ["RydHQ_NObj",5]};

		_HQ setVariable ["RydHQ_Progress",0];
		if (_lastObj > (_HQ getVariable ["RydHQ_NObj",1])) then {_HQ setVariable ["RydHQ_Progress",-1];_HQ setVariable ["RydHQ_Morale",(_HQ getVariable ["RydHQ_Morale",0]) - _mLoss]};	
		if (_lastObj < (_HQ getVariable ["RydHQ_NObj",1])) then {_HQ setVariable ["RydHQ_Progress",1]};	
		}
	else
		{
		_nTaken = count _taken;
		
			{
			if (_x in _oTaken) then
				{
				_x setVariable [("Capturing" + (str _x)),[0,0]]
				}
			}
		foreach (_objectives - _taken);
		
		if (_nTaken < _cTaken) then
			{
			_HQ setVariable ["RydHQ_Morale",(_HQ getVariable ["RydHQ_Morale",0]) - (_mLoss * (_cTaken - _nTaken))]
			}
		}
	};

_reserve = (_HQ getVariable ["RydHQ_Friends",[]]) - ((_HQ getVariable ["RydHQ_ArtG",[]]) + ((_HQ getVariable ["RydHQ_AirG",[]]) - (_HQ getVariable ["RydHQ_SupportG",[]])) + (_HQ getVariable ["RydHQ_NavalG",[]]) + (_HQ getVariable ["RydHQ_StaticG",[]]) + (_HQ getVariable ["RydHQ_CargoOnly",[]]));

	{
	_x setVariable [("Deployed" + (str _x)),false];
	}
foreach _reserve;

	{
	if ((random 100) > 95) then {_x setVariable [("Garrisoned" + (str _x)),false]};
	}
foreach (_HQ getVariable ["RydHQ_Garrison",[]]);

if ((_HQ getVariable ["RydHQ_Combining",false])) then 
	{
	_exhausted = +(_HQ getVariable ["RydHQ_Exhausted",[]]);
	
		{
		if (not (isNull _x) and (({alive _x} count (units _x)) >= 1) and not (_x getVariable [("isCaptive" + (str _x)),false])) then 
			{
			_unitvar = str _x;
			_nominal = _x getVariable ("Nominal" + (str _x));if (isNil "_nominal") then {_x setVariable ["Nominal" + _unitvar,(count (units _x))];_nominal = _x getVariable ("Nominal" + (str _x))};
			if (isNil ("_nominal")) then {_x setVariable [("Nominal" + _unitvar),(count (units _x))];_nominal = _x getVariable ("Nominal" + (str _x))};
			_current = count (units _x);
			if (((_nominal/(_current + 0.1)) > 2) and (isNull (assignedVehicle (leader _x)))) then 
				{
				_ex = ((_HQ getVariable ["RydHQ_Exhausted",[]]) - [_x]);
				for [{_a = 0},{(_a < (count _ex))},{_a = _a + 1}] do
					{
					_Aex = _ex select _a;
					_unitvarA = str _Aex;
					
					if not (_Aex getVariable [("isCaptive" + _unitvarA),false]) then
						{
						_nominalA = _Aex getVariable ("Nominal" + (str _Aex));
						if (isNil ("_nominal")) then {_Aex setVariable [("Nominal" + _unitvarA),(count (units _Aex)),true];_nominalA = _Aex getVariable ("Nominal" + (str _Aex))};
						_currentA = count (units _Aex);
						if (((_nominalA/(_currentA + 0.1)) > 2) and (isNull (assignedVehicle (leader _Aex))) and (((vehicle (leader _x)) distance (vehicle (leader _Aex))) < 200)) then 
							{
							(units _x) joinsilent _Aex;
							sleep 0.05;
							_Aex setVariable [("Nominal" + (str _Aex)),(count (units _Aex)),true];
							}
						};
					};
				};
			}
		else
			{
			_exhausted = _exhausted - [_x]
			};
		}
	foreach (_HQ getVariable ["RydHQ_Exhausted",[]]);
	_HQ setVariable ["RydHQ_Exhausted",_exhausted];
	};
