RYD_StatusQuo = 
	{
	_SCRname = "SQ";
	_orderFirst = _HQ getVariable "RydHQ_Orderfirst";
	
	if (isNil ("_orderFirst")) then 
		{
		_HQ setVariable ["RydHQ_Orderfirst",true];
		_HQ setVariable ["RydHQ_FlankReady",false];
		};
	
	if (_cycleC > 1) then
		{
		if not (_HQ getVariable ["RydHQ_ResetOnDemand",false]) then
			{
			if ((time - _lastReset) > (_HQ getVariable ["RydHQ_ResetTime",600])) then
				{
				_lastReset = time;
				[_HQ] call HAL_HQReset
				}
			}
		else 
			{
			_code =
				{
				_HQ = _this select 0;
				
				waitUntil 
					{
					sleep 1; 
					((_HQ getVariable ["RydHQ_ResetNow",false]) or (_HQ getVariable ["RydHQ_KIA",false]))
					};
					
				_HQ setVariable ["RydHQ_ResetNow",false];
				[_HQ] call HAL_HQReset
				};
				
			[[_HQ],_code] call RYD_Spawn;
			};
		
		};
	
	_HQ setVariable ["RydHQ_Friends",[]];
	_HQ setVariable ["RydHQ_Enemies",[]];
	_HQ setVariable ["RydHQ_KnEnemies",[]];
	_HQ setVariable ["RydHQ_KnEnemiesG",[]];
	_HQ setVariable ["RydHQ_FValue",0];
	_HQ setVariable ["RydHQ_EValue",0];
		
	_FValue = 0;
	_EValue = 0;

	if (RydxHQ_AIChatDensity > 0) then
		{
		_varName1 = "HAC_AIChatRep";
		_varName2 = "_West";

		switch ((side _HQ)) do
			{
			case (east) : {_varName2 = "_East"};
			case (resistance) : {_varName2 = "_Guer"};
			};

		missionNamespace setVariable [_varName1 + _varName2,0];

		_varName1 = "HAC_AIChatLT";

		missionNamespace setVariable [_varName1 + _varName2,[0,""]]
		};
			
	_HQ setVariable ["RydHQ_LastSub",_HQ getVariable ["RydHQ_Subordinated",[]]];
	_HQ setVariable ["RydHQ_Subordinated",[]];
	
	_enemies = _HQ getVariable ["RydHQ_Enemies",[]];
	_friends = _HQ getVariable ["RydHQ_Friends",[]];	

		{
		_isCaptive = _x getVariable ("isCaptive" + (str _x));
		if (isNil "_isCaptive") then {_isCaptive = false};

		_isCiv = false;
		if ((faction (leader _x)) in _civF) then {_isCiv = true};
		if not ((isNull ((_HQ getVariable ["leaderHQ",(leader _HQ)]))) and not (isNull _x) and (alive ((_HQ getVariable ["leaderHQ",(leader _HQ)]))) and (alive (leader _x)) and not (_isCaptive)) then
			{
			if (not ((_HQ getVariable ["RydHQ_FrontA",false])) and ((side _x) getFriend (side _HQ) < 0.6) and not (_isCiv)) then 
				{
				if not (_x in _enemies) then 
					{
					_enemies set [(count _enemies), _x]
					}
				};
			
			_front = true;
			_fr = _HQ getvariable ["RydHQ_Front",locationNull];
			if not (isNull _fr) then 
				{
				_front = ((getPosATL (vehicle (leader _x))) in _fr)
				};
				
			if ((_HQ getVariable ["RydHQ_FrontA",false]) and ((side _x) getFriend (side _HQ) < 0.6) and (_front) and not (_isCiv)) then 
				{
				if not (_x in _enemies) then 
					{
					_enemies set [(count _enemies), _x];
					}
				};
				
			if ((_HQ getVariable ["RydHQ_SubAll",true])) then 
				{
				if not ((side _x) getFriend (side _HQ) < 0.6) then 
					{
					if (not (_x in _friends) and not (((leader _x) in (_HQ getVariable ["RydHQ_Excluded",[]])) or (_isCiv))) then 
						{
						_friends set [(count _friends), _x]
						}
					};
				};
			}
		}
	foreach allGroups;
	
	_HQ setVariable ["RydHQ_Enemies",_enemies];

	_excl = [];

		{
		if not ((group _x) in _excl) then 
			{
			_excl set [(count _excl),group _x]
			} 
		}
	foreach (_HQ getVariable ["RydHQ_Excluded",[]]);
	
	_HQ setVariable ["RydHQ_Excl",_excl];
	
	_subOrd = [];

	if (_HQ getVariable ["RydHQ_SubSynchro",false]) then 
		{
			{
			if ((_x in (_HQ getVariable ["RydHQ_LastSub",[]])) and not ((leader _x) in (synchronizedObjects (_HQ getVariable ["leaderHQ",(leader _HQ)]))) and (_HQ getVariable ["RydHQ_SubSynchro",false])) then 
				{
				_subOrd set [(count _subOrd),_x]
				};
				
			if (not (_x in _subOrd) and (({(_x in (synchronizedObjects (_HQ getVariable ["leaderHQ",(leader _HQ)])))} count (units _x)) > 0)) then 
				{
				_subOrd set [(count _subOrd),_x]
				};
			}
		foreach allGroups;
		};

	if (_HQ getVariable ["RydHQ_SubNamed",false]) then 
		{
		_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
		if (_signum in ["A","X"]) then {_signum = ""};
		
			{
			for [{_i = 1},{_i <= (_HQ getVariable ["RydHQ_NameLimit",100])},{_i = _i + 1}] do
				{
				if (not (_x in _subOrd) and ((str (leader _x)) == ("Ryd" + _signum + str (_i)))) then 
					{
					_subOrd set [(count _subOrd),_x]
					};
				};
			}
		foreach allGroups;
		};
		
	_HQ setVariable ["RydHQ_Subordinated",_subOrd];

	_friends = _friends + _subOrd + (_HQ getVariable ["RydHQ_Included",[]]) - ((_HQ getVariable ["RydHQ_ExcludedG",[]]) + _excl + [_HQ]);
	_HQ setVariable ["RydHQ_NoWayD",allGroups - (_HQ getVariable ["RydHQ_LastFriends",[]])];

	_friends = [_friends] call RYD_RandomOrd;
	
	_HQ setVariable ["RydHQ_Friends",_friends];

		{
		[_x] call RYD_WPdel;
		}
	foreach (((_HQ getVariable ["RydHQ_ExcludedG",[]]) + _excl) - (_HQ getVariable ["RydHQ_NoWayD",[]]));
	
	if (_HQ getVariable ["RydHQ_Init",true]) then 
		{
			{
			_cInitial = _cInitial + (count (units _x));
			if (RydHQ_CamV) then 
				{
			
					{
					if (_x in ([player] + (switchableUnits - [player]))) then {[_x,_HQ] call RYD_LiveFeed}
					}
				foreach (units _x)
				}
			}
		foreach (_friends + [_HQ])
		};
		
	_HQ setVariable ["RydHQ_CInitial",_cInitial];

	_HQ setVariable ["RydHQ_CLast",(_HQ getVariable ["RydHQ_CCurrent",0])];
	_CLast = (_HQ getVariable ["RydHQ_CCurrent",0]);
	_CCurrent = 0;
	
		{
		_CCurrent = _CCurrent + (count (units _x))
		}
	foreach (_friends + [_HQ]);
	
	_HQ setVariable ["RydHQ_CCurrent",_CCurrent];

	_Ex = [];

	if (_HQ getVariable ["RydHQ_ExInfo",false]) then 
		{
		_Ex = _excl + (_HQ getVariable ["RydHQ_ExcludedG",[]])
		};
		
	_knownE = [];
	_knownEG = [];

		{
		for [{_a = 0},{_a < count (units _x)},{_a = _a + 1}] do
			{
			_enemyU = vehicle ((units _x) select _a);
			
				{
				if ((_x knowsAbout _enemyU) >= 0.05) exitwith 
					{
					if not (_enemyU in _knownE) then 
						{
						_knownE set [(count _knownE),_enemyU];
						(vehicle _enemyU) setVariable ["RydHQ_MyFO",(leader _x)];
						};

					if not ((group _enemyU) in _knownEG) then 
						{
						_already = missionnameSpace getVariable ["AlreadySpotted",[]];
						_knownEG set [(count _knownEG),(group _enemyU)];
						if not ((group _enemyU) in _already) then
							{
							_UL = (leader _x);if not (isPlayer _UL) then {if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_EnemySpot,"EnemySpot"] call RYD_AIChatter}};
							}
						}
					} 
				}
			foreach (_friends + [_HQ] + _Ex)
			}
		}
	foreach _enemies;
	
	_alwaysKn = ((_HQ getVariable ["RydHQ_AlwaysKnownU",[]]) - (_HQ getVariable ["RydHQ_AlwaysUnKnownU",[]])) - _knownE;
	
	_knownE = (_knownE + _alwaysKn) - (_HQ getVariable ["RydHQ_AlwaysUnKnownU",[]]);

		{
		_gp = group _x;
		if not (_gp in _knownEG) then {_knownEG set [(count _knownEG),_gp]};
		}
	foreach _alwaysKn;
	
	_HQ setVariable ["RydHQ_KnEnemies",_knownE];
	_HQ setVariable ["RydHQ_KnEnemiesG",_knownEG];
	_HQ setVariable ["RydHQ_Ex",_Ex];

	_already = missionnameSpace getVariable ["AlreadySpotted",[]];

		{
		if not (_x in _already) then
			{
			_already set [(count _already),_x]
			}
		}
	foreach _knownEG;

	missionnameSpace setVariable ["AlreadySpotted",_already];

	_lossFinal = _cInitial - _CCurrent;

	if (_lossFinal < 0) then 
		{
		_lossFinal = 0;
		_cInitial = _CCurrent;
		_HQ setVariable ["RydHQ_CInitial",_CCurrent];
		};
		
	_morale = _HQ getVariable ["RydHQ_Morale",0];

	if not (_HQ getVariable ["RydHQ_Init",true]) then 
		{
		_lossP = _lossFinal/_cInitial;
		
		_HQ setVariable ["RydHQ_LTotal",_lossP];
		
		_lostU = _CLast - _CCurrent;
		
		if not (_lostU == 0) then
			{
			_lossArr = _HQ getVariable ["RydHQ_LossArr",[]];
			_lossArr pushBack [_lostU,time];
			
			if ((count _lossArr) > 200) then
				{
				_lossArr set [0,0];
				_lossArr = _lossArr - [0];
				};
			
			_HQ setVariable ["RydHQ_LossArr",_lossArr]
			};
			
		_lossWeight = 0;
			
			{
			_loss = _x select 0;
			_when = _x select 1;
			_age = ((time - _when)/30) max 6;
				
			_lossWeight = _lossWeight + ((_loss/(_age^1.15)) * (0.75 + (random 0.125) + (random 0.125) + (random 0.125) + (random 0.125)))
			}
		foreach (_HQ getVariable ["RydHQ_LossArr",[]]);
		
		_balanceF = (((random 5) + (random 5))/((1 + _lossP)^2)) - ((random 1) + (random 1)) - (((random 1.5) + (random 1.5)) * ((count _knownE)/_CCurrent));
		
		//diag_log format ["balance: %1 lossweight: %2 morale: %3",_balanceF,_lossWeight,_morale];
		
		_morale = _morale + ((_balanceF - _lossWeight)/(_HQ getVariable ["RydHQ_MoraleConst",1]));
		
		if (_lossP > (0.4 + (random 0.2))) then
			{
			_diff = ((-_morale)/50) - _lossP;
			if (_diff > 0) then
				{				
				_morale = _morale - ((random (_diff * 10))/(_HQ getVariable ["RydHQ_MoraleConst",1]))
				}
			};
		
		/*if ((_OLmpl == 0) and ((count _knownE) > 0)) then
			{
			_OLmpl = 0.01;
			_firstMC = _cycleC - 1
			};

		if ((_cycleCap < (50 / (1.01 - _lossP))) and ((count _knownE) == 0) and (_OLmpl == 0.01)) then
			{
			_cycleCap = _cycleCap + 1;
			if ((random 1) < _lossP) then {_firstMC = _firstMC + 1}
			}
		else
			{
			if not ((count _knownE) == 0) then
				{
				_cycleCap = 0;
				}
			};

		
		_lossPerc = _lossP * 100;
		_cycle = _cycleC - _firstMC;

		_OLF = _OLmpl * (((-(_lossPerc^1.6))/(1.5^(_cycle^0.5))) + ((15 + (random 5) + (random 5))/(1 + _lossP)) - (_lossP * 10) + (_cycle ^ ((10 * (1 - _lossP))/_cycle)));
		diag_log format ["olmpl: %1 lossperc: %2 cycle: %3 lossp: %4",_OLmpl,_lossPerc,_cycle,_lossP];
		_mplLU = 1;
				
		_echo = floor ((_HQ getVariable ["RydHQ_LossEcho",0])/4);
		
		_lostU = _echo + _CLast - _CCurrent;
		
		diag_log format ["lostU: %1 echo: %2",_lostU,_echo];
		
		_HQ setVariable ["RydHQ_LossEcho",_lostU];
		
		if (_lostU < 0) then {_lostU = - _lostU;_mplLU = -1};
		
		_lossL = (1 + (_lossP^2)) * _mplLU * ((100 * _lostU/_cInitial)^(1.55 + (random 0.05) + (random 0.05)))/10;
		
		_lossRed = 1;
		
		if ((random 1) < _lossP) then
			{
			_lossRed = sqrt (1 + _lossP)
			};

		_balanceF = ((1 + (random 1.25) + (random 1.25))/(_lossRed)) - ((0.5 + _lossP)^2) - (count _knownE)/_CCurrent;
		
		diag_log format ["%4: %1 (all) - %2 (last) + %3 (balance) = %5",_OLF,_lossL,_balanceF,_HQ getVariable ["RydHQ_CodeSign","X"],((_OLF - _lossL + _balanceF)/(_HQ getVariable ["RydHQ_MoraleConst",1]))];
		
		_morale = _morale + ((_OLF - _lossL + _balanceF)/(_HQ getVariable ["RydHQ_MoraleConst",1]));*/
		};

	if (_morale < -50) then {_morale = -50};
	if (_morale > 0) then {_morale = 0};
	
	_HQ setVariable ["RydHQ_Morale",_morale];
	
	_HQ setVariable ["RydHQ_TotalLossP",(round (((_lossFinal/_cInitial) * 100) * 10)/10)];
	
	if (_HQ getVariable ["RydHQ_Debug",false]) then 
		{
		_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
		_mdbg = format ["Morale %5 (%2): %1 - losses: %3 percent (%4)",_morale,(_HQ getVariable ["RydHQ_Personality","OTHER"]),(round (((_lossFinal/_cInitial) * 100) * 10)/10),_lossFinal,_signum];
		diag_log _mdbg;
		(_HQ getVariable ["leaderHQ",(leader _HQ)]) globalChat _mdbg;

		_cl = "<t color='#007f00'>%4 -> M: %1 - L: %2%3</t>";

		switch (side _HQ) do
			{
			case (west) : {_cl = "<t color='#0d81c4'>%4 -> M: %1 - L: %2%3</t>"};
			case (east) : {_cl = "<t color='#ff0000'>%4 -> M: %1 - L: %2%3</t>"};
			};

		_dbgMon = parseText format [_cl,(round (_morale * 10))/10,(round (((_lossFinal/_cInitial) * 100) * 10)/10),"%",_signum];

		_HQ setVariable ["DbgMon",_dbgMon];
		};

	_HQ setVariable ["RydHQ_Init",false]; 

		{
			{
			_SpecForcheck = false;
			_reconcheck = false;
			_FOcheck = false;
			_sniperscheck = false;
			_ATinfcheck = false;
			_AAinfcheck = false;
			_Infcheck = false;
			_Artcheck = false;
			_HArmorcheck = false;
			_MArmorcheck = false;
			_LArmorcheck = false;
			_LArmorATcheck = false;
			_Carscheck = false;
			_Aircheck = false;
			_BAircheck = false;
			_RAircheck = false;
			_NCAircheck = false;
			_Navalcheck = false;
			_Staticcheck = false;
			_StaticAAcheck = false;
			_StaticATcheck = false;
			_Supportcheck = false;
			_Cargocheck = false;
			_NCCargocheck = false;
			_Othercheck = true;

			_Crewcheck = false;
			_NCrewInfcheck = false;

			_tp = toLower (typeOf _x);
			_grp = group _x;
			_vh = vehicle _x;
			_asV = assignedvehicle _x;
			_grpD = group (assignedDriver _asV);
			_grpG = group (assignedGunner _asV);
			if (isNull _grpD) then {_grpD = _grpG};
			_Tvh = toLower (typeOf _vh);
			_TasV = toLower (typeOf _asV);

				if (((_grp == _grpD) and (_TasV in _specFor_class)) or (_tp in _specFor_class)) then {_SpecForcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _recon_class)) or (_tp in _recon_class)) then {_reconcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _FO_class)) or (_tp in _FO_class)) then {_FOcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _snipers_class)) or (_tp in _snipers_class)) then {_sniperscheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _ATinf_class)) or (_tp in _ATinf_class)) then {_ATinfcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _AAinf_class)) or (_tp in _AAinf_class)) then {_AAinfcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Inf_class)) or (_tp in _Inf_class)) then {_Infcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Art_class)) or (_tp in _Art_class)) then {_Artcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _HArmor_class)) or (_tp in _HArmor_class)) then {_HArmorcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _MArmor_class)) or (_tp in _MArmor_class)) then {_MArmorcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _LArmor_class)) or (_tp in _LArmor_class)) then {_LArmorcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _LArmorAT_class)) or (_tp in _LArmorAT_class)) then {_LArmorATcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Cars_class)) or (_tp in _Cars_class)) then {_Carscheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Air_class)) or (_tp in _Air_class)) then {_Aircheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _BAir_class)) or (_tp in _BAir_class)) then {_BAircheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _RAir_class)) or (_tp in _RAir_class)) then {_RAircheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _NCAir_class)) or (_tp in _NCAir_class)) then {_NCAircheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Naval_class)) or (_tp in _Naval_class)) then {_Navalcheck = true;_Othercheck = false};
				if (((_grp == _grpG) and (_TasV in _Static_class)) or (_tp in _Static_class)) then {_Staticcheck = true;_Othercheck = false};
				if (((_grp == _grpG) and (_TasV in _StaticAA_class)) or (_tp in _StaticAA_class)) then {_StaticAAcheck = true;_Othercheck = false};
				if (((_grp == _grpG) and (_TasV in _StaticAT_class)) or (_tp in _StaticAT_class)) then {_StaticATcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Cargo_class)) or (_tp in _Cargo_class)) then {_Cargocheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _NCCargo_class)) or (_tp in _NCCargo_class)) then {_NCCargocheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Crew_class)) or (_tp in _Crew_class)) then {_Crewcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _NCrewInf_class)) or (_tp in _NCrewInf_class)) then {_NCrewInfcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Support_class)) or (_tp in _Support_class)) then {_Supportcheck = true;_NCrewInfcheck = false;_Othercheck = false};

				if ((_TasV in _NCCargo_class) and (_x == (assignedDriver _asV)) and ((count (units (group _x))) == 1) and not ((_ATinfcheck) or (_AAinfcheck) or (_reconcheck) or (_FOcheck) or (_sniperscheck))) then {_NCrewInfcheck = false;_Othercheck = false};

				if (_SpecForcheck) then {if not (_vh in _SpecFor) then {_SpecFor set [(count _SpecFor),_vh]};if not (_grp in _SpecForG) then {_SpecForG set [(count _SpecForG),_grp]}};
				if (_reconcheck) then {if not (_vh in _recon) then {_recon set [(count _recon),_vh]};if not (_grp in _reconG) then {_reconG set [(count _reconG),_grp]}};
				if (_FOcheck) then {if not (_vh in _FO) then {_FO set [(count _FO),_vh]};if not (_grp in _FOG) then {_FOG set [(count _FOG),_grp]}};
				if (_sniperscheck) then {if not (_vh in _snipers) then {_snipers set [(count _snipers),_vh]};if not (_grp in _snipersG) then {_snipersG set [(count _snipersG),_grp]}};
				if (_ATinfcheck) then {if not (_vh in _ATinf) then {_ATinf set [(count _ATinf),_vh]};if not (_grp in _ATinfG) then {_ATinfG set [(count _ATinfG),_grp]}};
				if (_AAinfcheck) then {if not (_vh in _AAinf) then {_AAinf set [(count _AAinf),_vh]};if not (_grp in _AAinfG) then {_AAinfG set [(count _AAinfG),_grp]}};
				if (_Infcheck) then {if not (_vh in _Inf) then {_FValue = _FValue + 1;_Inf set [(count _Inf),_vh]};if not (_grp in _InfG) then {_InfG set [(count _InfG),_grp]}};
				if (_Artcheck) then {if not (_vh in _Art) then {_FValue = _FValue + 3;_Art set [(count _Art),_vh]};if not (_grp in _ArtG) then {_ArtG set [(count _ArtG),_grp]}};
				if (_HArmorcheck) then {if not (_vh in _HArmor) then {_FValue = _FValue + 10;_HArmor set [(count _HArmor),_vh]};if not (_grp in _HArmorG) then {_HArmorG set [(count _HArmorG),_grp]}};
				if (_MArmorcheck) then {if not (_vh in _MArmor) then {_MArmor set [(count _MArmor),_vh]};if not (_grp in _MArmorG) then {_MArmorG set [(count _MArmorG),_grp]}};
				if (_LArmorcheck) then {if not (_vh in _LArmor) then {_FValue = _FValue + 5;_LArmor set [(count _LArmor),_vh]};if not (_grp in _LArmorG) then {_LArmorG set [(count _LArmorG),_grp]}};
				if (_LArmorATcheck) then {if not (_vh in _LArmorAT) then {_LArmorAT set [(count _LArmorAT),_vh]};if not (_grp in _LArmorATG) then {_LArmorATG set [(count _LArmorATG),_grp]}};
				if (_Carscheck) then {if not (_vh in _Cars) then {_FValue = _FValue + 3;_Cars set [(count _Cars),_vh]};if not (_grp in _CarsG) then {_CarsG set [(count _CarsG),_grp]}};
				if (_Aircheck) then {if not (_vh in _Air) then {_FValue = _FValue + 15;_Air set [(count _Air),_vh]};if not (_grp in _AirG) then {_AirG set [(count _AirG),_grp]}};
				if (_BAircheck) then {if not (_vh in _BAir) then {_BAir set [(count _BAir),_vh]};if not (_grp in _BAirG) then {_BAirG set [(count _BAirG),_grp]}};				
				if (_RAircheck) then {if not (_vh in _RAir) then {_RAir set [(count _RAir),_vh]};if not (_grp in _RAirG) then {_RAirG set [(count _RAirG),_grp]}};				
				if (_NCAircheck) then {if not (_vh in _NCAir) then {_NCAir set [(count _NCAir),_vh]};if not (_grp in _NCAirG) then {_NCAirG set [(count _NCAirG),_grp]}};
				if (_Navalcheck) then {if not (_vh in _Naval) then {_Naval set [(count _Naval),_vh]};if not (_grp in _NavalG) then {_NavalG set [(count _NavalG),_grp]}};
				if (_Staticcheck) then {if not (_vh in _Static) then {_FValue = _FValue + 1;_Static set [(count _Static),_vh]};if not (_grp in _StaticG) then {_StaticG set [(count _StaticG),_grp]}};
				if (_StaticAAcheck) then {if not (_vh in _StaticAA) then {_StaticAA set [(count _StaticAA),_vh]};if not (_grp in _StaticAAG) then {_StaticAAG set [(count _StaticAAG),_grp]}};
				if (_StaticATcheck) then {if not (_vh in _StaticAT) then {_StaticAT set [(count _StaticAT),_vh]};if not (_grp in _StaticATG) then {_StaticATG set [(count _StaticATG),_grp]}};
				if (_Supportcheck) then {if not (_vh in _Support) then {_Support set [(count _Support),_vh]};if not (_grp in _SupportG) then {_SupportG set [(count _SupportG),_grp]}};
				if (_Cargocheck) then {if not (_vh in _Cargo) then {_Cargo set [(count _Cargo),_vh]};if not (_grp in _CargoG) then {_CargoG set [(count _CargoG),_grp]}};
				if (_NCCargocheck) then {if not (_vh in _NCCargo) then {_NCCargo set [(count _NCCargo),_vh]};if not (_grp in _NCCargoG) then {_NCCargoG set [(count _NCCargoG),_grp]}};
				if (_Crewcheck) then {if not (_vh in _Crew) then {_Crew set [(count _Crew),_vh]};if not (_grp in _CrewG) then {_CrewG set [(count _CrewG),_grp]}};
				if (_NCrewInfcheck) then {if not (_vh in _NCrewInf) then {_NCrewInf set [(count _NCrewInf),_vh]};if not (_grp in _NCrewInfG) then {_NCrewInfG set [(count _NCrewInfG),_grp]}};
				
			}
		foreach (units _x)
		}
	foreach _friends;
	
	_HQ setVariable ["RydHQ_FValue",_FValue];

	_HQ setVariable ["RydHQ_SpecFor",_SpecFor];
	_HQ setVariable ["RydHQ_recon",_recon];
	_HQ setVariable ["RydHQ_FO",_FO];
	_HQ setVariable ["RydHQ_snipers",_snipers];
	_HQ setVariable ["RydHQ_ATinf",_ATinf];
	_HQ setVariable ["RydHQ_AAinf",_AAinf];
	_HQ setVariable ["RydHQ_Art",_Art];
	_HQ setVariable ["RydHQ_HArmor",_HArmor];
	_HQ setVariable ["RydHQ_MArmor",_MArmor];
	_HQ setVariable ["RydHQ_LArmor",_LArmor];
	_HQ setVariable ["RydHQ_LArmorAT",_LArmorAT];
	_HQ setVariable ["RydHQ_Cars",_Cars];
	_HQ setVariable ["RydHQ_Air",_Air];
	_HQ setVariable ["RydHQ_BAir",_BAir];
	_HQ setVariable ["RydHQ_RAir",_RAir];
	_HQ setVariable ["RydHQ_NCAir",_NCAir];
	_HQ setVariable ["RydHQ_Naval",_Naval];
	_HQ setVariable ["RydHQ_Static",_Static];
	_HQ setVariable ["RydHQ_StaticAA",_StaticAA];
	_HQ setVariable ["RydHQ_StaticAT",_StaticAT];
	_HQ setVariable ["RydHQ_Support",_Support];
	_HQ setVariable ["RydHQ_Cargo",_Cargo];
	_HQ setVariable ["RydHQ_NCCargo",_NCCargo];
	_HQ setVariable ["RydHQ_Other",_Other];
	_HQ setVariable ["RydHQ_Crew",_Crew];

	_HQ setVariable ["RydHQ_SpecForG",_SpecForG];
	_HQ setVariable ["RydHQ_reconG",_reconG];
	_HQ setVariable ["RydHQ_FOG",_FOG];
	_HQ setVariable ["RydHQ_snipersG",_snipersG];
	_HQ setVariable ["RydHQ_ATinfG",_ATinfG];
	_HQ setVariable ["RydHQ_AAinfG",_AAinfG];
	_HQ setVariable ["RydHQ_ArtG",_ArtG];
	_HQ setVariable ["RydHQ_HArmorG",_HArmorG];
	_HQ setVariable ["RydHQ_MArmorG",_MArmorG];
	_HQ setVariable ["RydHQ_LArmorG",_LArmorG];
	_HQ setVariable ["RydHQ_LArmorATG",_LArmorATG];
	_HQ setVariable ["RydHQ_CarsG",_CarsG];
	_HQ setVariable ["RydHQ_AirG",_AirG];
	_HQ setVariable ["RydHQ_BAirG",_BAirG];
	_HQ setVariable ["RydHQ_RAirG",_RAirG];
	_HQ setVariable ["RydHQ_NCAirG",_NCAirG];
	_HQ setVariable ["RydHQ_NavalG",_NavalG];
	_HQ setVariable ["RydHQ_StaticG",_StaticG];
	_HQ setVariable ["RydHQ_StaticAAG",_StaticAAG];
	_HQ setVariable ["RydHQ_StaticATG",_StaticATG];
	_HQ setVariable ["RydHQ_NCCargoG",_NCCargoG];
	_HQ setVariable ["RydHQ_OtherG",_OtherG];
	_HQ setVariable ["RydHQ_CrewG",_CrewG];

	_NCrewInfG = _NCrewInfG - (_RAirG + _StaticG);
	_NCrewInf = _NCrewInf - (_RAir + _Static);
	_InfG = _InfG - (_RAirG + _StaticG);
	_Inf = _Inf - (_RAir + _Static);

	_CargoAirEx = [];
	_CargoLandEx = [];
	if (_HQ getVariable ["RydHQ_NoAirCargo",false]) then {_CargoAirEx = _AirG};
	if (_HQ getVariable ["RydHQ_NoLandCargo",false]) then {_CargoLandEx = (_CargoG - _AirG)};
	_CargoG = _CargoG - (_CargoAirEx + _CargoLandEx + (_HQ getVariable ["RydHQ_AmmoDrop",[]]));
	_HQ setVariable ["RydHQ_CargoAirEx",_CargoAirEx];
	_HQ setVariable ["RydHQ_CargoLandEx",_CargoLandEx];
	
			
		{
		if not (_x in _SupportG) then
			{
			_SupportG set [(count _SupportG),_x]
			}
		}
	foreach (_HQ getVariable ["RydHQ_AmmoDrop",[]]);
	
	_HQ setVariable ["RydHQ_NCrewInf",_NCrewInf];
	_HQ setVariable ["RydHQ_NCrewInfG",_NCrewInfG];	
	_HQ setVariable ["RydHQ_Inf",_Inf];
	_HQ setVariable ["RydHQ_InfG",_InfG];
	_HQ setVariable ["RydHQ_CargoG",_CargoG];
	_HQ setVariable ["RydHQ_SupportG",_SupportG];
		
		{
			{
			_SpecForcheck = false;
			_reconcheck = false;
			_FOcheck = false;
			_sniperscheck = false;
			_ATinfcheck = false;
			_AAinfcheck = false;
			_Infcheck = false;
			_Artcheck = false;
			_HArmorcheck = false;
			_MArmorcheck = false;
			_LArmorcheck = false;
			_LArmorATcheck = false;
			_Carscheck = false;
			_Aircheck = false;
			_BAircheck = false;
			_RAircheck = false;
			_NCAircheck = false;
			_Navalcheck = false;
			_Staticcheck = false;
			_StaticAAcheck = false;
			_StaticATcheck = false;
			_Supportcheck = false;
			_Cargocheck = false;
			_NCCargocheck = false;
			_Cargocheck = false;
			_NCCargocheck = false;
			_Othercheck = true;

			_Crewcheck = false;
			_NCrewInfcheck = false;

			_tp = toLower (typeOf _x);
			_grp = group _x;
			_vh = vehicle _x;
			_asV = assignedvehicle _x;
			_grpD = group (assignedDriver _asV);
			_grpG = group (assignedGunner _asV);
			if (isNull _grpD) then {_grpD = _grpG};
			_Tvh = toLower (typeOf _vh);
			_TasV = toLower (typeOf _asV);

				if (((_grp == _grpD) and (_TasV in _specFor_class)) or (_tp in _specFor_class)) then {_SpecForcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _recon_class)) or (_tp in _recon_class)) then {_reconcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _FO_class)) or (_tp in _FO_class)) then {_FOcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _snipers_class)) or (_tp in _snipers_class)) then {_sniperscheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _ATinf_class)) or (_tp in _ATinf_class)) then {_ATinfcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _AAinf_class)) or (_tp in _AAinf_class)) then {_AAinfcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Inf_class)) or (_tp in _Inf_class)) then {_Infcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Art_class)) or (_tp in _Art_class)) then {_Artcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _HArmor_class)) or (_tp in _HArmor_class)) then {_HArmorcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _MArmor_class)) or (_tp in _MArmor_class)) then {_MArmorcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _LArmor_class)) or (_tp in _LArmor_class)) then {_LArmorcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _LArmorAT_class)) or (_tp in _LArmorAT_class)) then {_LArmorATcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Cars_class)) or (_tp in _Cars_class)) then {_Carscheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Air_class)) or (_tp in _Air_class)) then {_Aircheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _BAir_class)) or (_tp in _BAir_class)) then {_BAircheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _RAir_class)) or (_tp in _RAir_class)) then {_RAircheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _NCAir_class)) or (_tp in _NCAir_class)) then {_NCAircheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Naval_class)) or (_tp in _Naval_class)) then {_Navalcheck = true;_Othercheck = false};
				if (((_grp == _grpG) and (_TasV in _Static_class)) or (_tp in _Static_class)) then {_Staticcheck = true;_Othercheck = false};
				if (((_grp == _grpG) and (_TasV in _StaticAA_class)) or (_tp in _StaticAA_class)) then {_StaticAAcheck = true;_Othercheck = false};
				if (((_grp == _grpG) and (_TasV in _StaticAT_class)) or (_tp in _StaticAT_class)) then {_StaticATcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Cargo_class)) or (_tp in _Cargo_class)) then {_Cargocheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _NCCargo_class)) or (_tp in _NCCargo_class)) then {_NCCargocheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Crew_class)) or (_tp in _Crew_class)) then {_Crewcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _NCrewInf_class)) or (_tp in _NCrewInf_class)) then {_NCrewInfcheck = true;_Othercheck = false};
				if (((_grp == _grpD) and (_TasV in _Support_class)) or (_tp in _Support_class)) then {_Supportcheck = true;_NCrewInfcheck = false;_Othercheck = false};

				if ((_TasV in _NCCargo_class) and (_x == (assignedDriver _asV)) and ((count (units (group _x))) == 1) and not ((_ATinfcheck) or (_AAinfcheck) or (_reconcheck) or (_FOcheck) or (_sniperscheck))) then {_NCrewInfcheck = false;_Othercheck = false};
				
				if (_SpecForcheck) then {if not (_vh in _EnSpecFor) then {_EnSpecFor set [(count _EnSpecFor),_vh]};if not (_grp in _EnSpecForG) then {_EnSpecForG set [(count _EnSpecForG),_grp]}};
				if (_reconcheck) then {if not (_vh in _Enrecon) then {_Enrecon set [(count _Enrecon),_vh]};if not (_grp in _EnreconG) then {_EnreconG set [(count _EnreconG),_grp]}};
				if (_FOcheck) then {if not (_vh in _EnFO) then {_EnFO set [(count _EnFO),_vh]};if not (_grp in _EnFOG) then {_EnFOG set [(count _EnFOG),_grp]}};
				if (_sniperscheck) then {if not (_vh in _Ensnipers) then {_Ensnipers set [(count _Ensnipers),_vh]};if not (_grp in _EnsnipersG) then {_EnsnipersG set [(count _EnsnipersG),_grp]}};
				if (_ATinfcheck) then {if not (_vh in _EnATinf) then {_EnATinf set [(count _EnATinf),_vh]};if not (_grp in _EnATinfG) then {_EnATinfG set [(count _EnATinfG),_grp]}};
				if (_AAinfcheck) then {if not (_vh in _EnAAinf) then {_EnAAinf set [(count _EnAAinf),_vh]};if not (_grp in _EnAAinfG) then {_EnAAinfG set [(count _EnAAinfG),_grp]}};
				if (_Infcheck) then {if not (_vh in _EnInf) then {_EValue = _EValue + 1;_EnInf set [(count _EnInf),_vh]};if not (_grp in _EnInfG) then {_EnInfG set [(count _EnInfG),_grp]}};
				if (_Artcheck) then {if not (_vh in _EnArt) then {_EValue = _EValue + 3;_EnArt set [(count _EnArt),_vh]};if not (_grp in _EnArtG) then {_EnArtG set [(count _EnArtG),_grp]}};
				if (_HArmorcheck) then {if not (_vh in _EnHArmor) then {_EValue = _EValue + 10;_EnHArmor set [(count _EnHArmor),_vh]};if not (_grp in _EnHArmorG) then {_EnHArmorG set [(count _EnHArmorG),_grp]}};
				if (_MArmorcheck) then {if not (_vh in _EnMArmor) then {_EnMArmor set [(count _EnMArmor),_vh]};if not (_grp in _EnMArmorG) then {_EnMArmorG set [(count _EnMArmorG),_grp]}};
				if (_LArmorcheck) then {if not (_vh in _EnLArmor) then {_EValue = _EValue + 5;_EnLArmor set [(count _EnLArmor),_vh]};if not (_grp in _EnLArmorG) then {_EnLArmorG set [(count _EnLArmorG),_grp]}};
				if (_LArmorATcheck) then {if not (_vh in _EnLArmorAT) then {_EnLArmorAT set [(count _EnLArmorAT),_vh]};if not (_grp in _EnLArmorATG) then {_EnLArmorATG set [(count _EnLArmorATG),_grp]}};
				if (_Carscheck) then {if not (_vh in _EnCars) then {_EValue = _EValue + 3;_EnCars set [(count _EnCars),_vh]};if not (_grp in _EnCarsG) then {_EnCarsG set [(count _EnCarsG),_grp]}};
				if (_Aircheck) then {if not (_vh in _EnAir) then {_EValue = _EValue + 15;_EnAir set [(count _EnAir),_vh]};if not (_grp in _EnAirG) then {_EnAirG set [(count _EnAirG),_grp]}};
				if (_BAircheck) then {if not (_vh in _EnBAir) then {_EnBAir set [(count _EnBAir),_vh]};if not (_grp in _EnBAirG) then {_EnBAirG set [(count _EnBAirG),_grp]}};				
				if (_RAircheck) then {if not (_vh in _EnRAir) then {_EnRAir set [(count _EnRAir),_vh]};if not (_grp in _EnRAirG) then {_EnRAirG set [(count _EnRAirG),_grp]}};
				if (_NCAircheck) then {if not (_vh in _EnNCAir) then {_EnNCAir set [(count _EnNCAir),_vh]};if not (_grp in _EnNCAirG) then {_EnNCAirG set [(count _EnNCAirG),_grp]}};
				if (_Navalcheck) then {if not (_vh in _EnNaval) then {_EnNaval set [(count _EnNaval),_vh]};if not (_grp in _EnNavalG) then {_EnNavalG set [(count _EnNavalG),_grp]}};
				if (_Staticcheck) then {if not (_vh in _EnStatic) then {_EValue = _EValue + 1;_EnStatic set [(count _EnStatic),_vh]};if not (_grp in _EnStaticG) then {_EnStaticG set [(count _EnStaticG),_grp]}};
				if (_StaticAAcheck) then {if not (_vh in _EnStaticAA) then {_EnStaticAA set [(count _EnStaticAA),_vh]};if not (_grp in _EnStaticAAG) then {_EnStaticAAG set [(count _EnStaticAAG),_grp]}};
				if (_StaticATcheck) then {if not (_vh in _EnStaticAT) then {_EnStaticAT set [(count _EnStaticAT),_vh]};if not (_grp in _EnStaticATG) then {_EnStaticATG set [(count _EnStaticATG),_grp]}};
				if (_Supportcheck) then {if not (_vh in _EnSupport) then {_EnSupport set [(count _EnSupport),_vh]};if not (_grp in _EnSupportG) then {_EnSupportG set [(count _EnSupportG),_grp]}};
				if (_Cargocheck) then {if not (_vh in _EnCargo) then {_EnCargo set [(count _EnCargo),_vh]};if not (_grp in _EnCargoG) then {_EnCargoG set [(count _EnCargoG),_grp]}};
				if (_NCCargocheck) then {if not (_vh in _EnNCCargo) then {_EnNCCargo set [(count _EnNCCargo),_vh]};if not (_grp in _EnNCCargoG) then {_EnNCCargoG set [(count _EnNCCargoG),_grp]}};
				if (_Crewcheck) then {if not (_vh in _EnCrew) then {_EnCrew set [(count _EnCrew),_vh]};if not (_grp in _EnCrewG) then {_EnCrewG set [(count _EnCrewG),_grp]}};
				if (_NCrewInfcheck) then {if not (_vh in _EnNCrewInf) then {_EnNCrewInf set [(count _EnNCrewInf),_vh]};if not (_grp in _EnNCrewInfG) then {_EnNCrewInfG set [(count _EnNCrewInfG),_grp]}};
				
			}
		foreach (units _x)
		}
	foreach _knownEG;
	
	_HQ setVariable ["RydHQ_EValue",_EValue];

	_HQ setVariable ["RydHQ_EnSpecFor",_EnSpecFor];
	_HQ setVariable ["RydHQ_Enrecon",_Enrecon];
	_HQ setVariable ["RydHQ_EnFO",_EnFO];
	_HQ setVariable ["RydHQ_Ensnipers",_Ensnipers];
	_HQ setVariable ["RydHQ_EnATinf",_EnATinf];
	_HQ setVariable ["RydHQ_EnAAinf",_EnAAinf];
	_HQ setVariable ["RydHQ_EnArt",_EnArt];
	_HQ setVariable ["RydHQ_EnHArmor",_EnHArmor];
	_HQ setVariable ["RydHQ_EnMArmor",_EnMArmor];
	_HQ setVariable ["RydHQ_EnLArmor",_EnLArmor];
	_HQ setVariable ["RydHQ_EnLArmorAT",_EnLArmorAT];
	_HQ setVariable ["RydHQ_EnCars",_EnCars];
	_HQ setVariable ["RydHQ_EnAir",_EnAir];
	_HQ setVariable ["RydHQ_EnBAir",_EnBAir];
	_HQ setVariable ["RydHQ_EnRAir",_EnRAir];
	_HQ setVariable ["RydHQ_EnNCAir",_EnNCAir];
	_HQ setVariable ["RydHQ_EnNaval",_EnNaval];
	_HQ setVariable ["RydHQ_EnStatic",_EnStatic];
	_HQ setVariable ["RydHQ_EnStaticAA",_EnStaticAA];
	_HQ setVariable ["RydHQ_EnStaticAT",_EnStaticAT];
	_HQ setVariable ["RydHQ_EnSupport",_EnSupport];
	_HQ setVariable ["RydHQ_EnCargo",_EnCargo];
	_HQ setVariable ["RydHQ_EnNCCargo",_EnNCCargo];
	_HQ setVariable ["RydHQ_EnOther",_EnOther];
	_HQ setVariable ["RydHQ_EnCrew",_EnCrew];

	_HQ setVariable ["RydHQ_EnSpecForG",_EnSpecForG];
	_HQ setVariable ["RydHQ_EnreconG",_EnreconG];
	_HQ setVariable ["RydHQ_EnFOG",_EnFOG];
	_HQ setVariable ["RydHQ_EnsnipersG",_EnsnipersG];
	_HQ setVariable ["RydHQ_EnATinfG",_EnATinfG];
	_HQ setVariable ["RydHQ_EnAAinfG",_EnAAinfG];
	_HQ setVariable ["RydHQ_EnArtG",_EnArtG];
	_HQ setVariable ["RydHQ_EnHArmorG",_EnHArmorG];
	_HQ setVariable ["RydHQ_EnMArmorG",_EnMArmorG];
	_HQ setVariable ["RydHQ_EnLArmorG",_EnLArmorG];
	_HQ setVariable ["RydHQ_EnLArmorATG",_EnLArmorATG];
	_HQ setVariable ["RydHQ_EnCarsG",_EnCarsG];
	_HQ setVariable ["RydHQ_EnAirG",_EnAirG];
	_HQ setVariable ["RydHQ_EnBAirG",_EnBAirG];
	_HQ setVariable ["RydHQ_EnRAirG",_EnRAirG];
	_HQ setVariable ["RydHQ_EnNCAirG",_EnNCAirG];
	_HQ setVariable ["RydHQ_EnNavalG",_EnNavalG];
	_HQ setVariable ["RydHQ_EnStaticG",_EnStaticG];
	_HQ setVariable ["RydHQ_EnStaticAAG",_EnStaticAAG];
	_HQ setVariable ["RydHQ_EnStaticATG",_EnStaticATG];
	_HQ setVariable ["RydHQ_EnSupportG",_EnSupportG];
	_HQ setVariable ["RydHQ_EnCargoG",_EnCargoG];
	_HQ setVariable ["RydHQ_EnNCCargoG",_EnNCCargoG];
	_HQ setVariable ["RydHQ_EnOtherG",_EnOtherG];
	_HQ setVariable ["RydHQ_EnCrewG",_EnCrewG];

	_EnNCrewInfG = _EnNCrewInfG - (_EnRAirG + _EnStaticG);
	_EnNCrewInf = _EnNCrewInf - (_EnRAir + _EnStatic);
	_EnInfG = _EnInfG - (_EnRAirG + _EnStaticG);
	_EnInf = _EnInf - (_EnRAir + _EnStatic);
	
	_HQ setVariable ["RydHQ_EnNCrewInf",_EnNCrewInf];
	_HQ setVariable ["RydHQ_EnNCrewInfG",_EnNCrewInfG];
	_HQ setVariable ["RydHQ_EnInf",_EnInf];
	_HQ setVariable ["RydHQ_EnInfG",_EnInfG];

	if (_HQ getVariable ["RydHQ_Flee",true]) then
		{
		_AllCow = 0;
		_AllPanic = 0;
		
			{
			_cow = _x getVariable ("Cow" + (str _x));
			if (isNil ("_cow")) then {_cow = 0};

			_AllCow = _AllCow + _cow;

			_panic = _x getVariable ("inPanic" + (str _x));
			if (isNil ("_panic")) then {_panic = false};

			if (_panic) then {_AllPanic = _AllPanic + 1};
			}
		foreach _friends;

		if (_AllPanic == 0) then {_AllPanic = 1};
		_midCow = 0;
		if not ((count _friends) == 0) then {_midCow = _AllCow/(count _friends)};

			{
			_cowF = ((- _morale)/(50 + (random 25))) + (random (2 * _midCow)) - _midCow;
			_cowF = _cowF * (_HQ getVariable ["RydHQ_Muu",1]);
			if (_x in _SpecForG) then {_cowF = _cowF - 0.8};
			if (_cowF < 0) then {_cowF = 0};
			if (_cowF > 1) then {_cowF = 1};
			_i = "";
			if (_cowF > 0.5) then
				{
				_UL = leader _x;
				if not (isPlayer _UL) then 
					{
					_inDanger = _x getVariable ["NearE",0];
					if (isNil "_inDanger") then {_inDanger = 0};
					if (_inDanger > 0.05) then
						{
						if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_InFear,"InFear"] call RYD_AIChatter}
						}
					}
				};

			if (((random ((20 + (_morale/5))/_AllPanic)) < _cowF) and ((random 100) > (100/(_AllPanic + 1)))) then 
				{
				_dngr = _x getVariable ["NearE",0];
				if (isNil "_dngr") then {_dngr = 0};
				if (_dngr < (0.3 - (random 0.15) - (random 0.15))) exitWith {};
				
				[_x] call RYD_WPdel;
				_x setVariable [("inPanic" + (str _x)), true];

				if (_HQ getVariable ["RydHQ_DebugII",false]) then 
					{
					_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
					_i = [(getPosATL (vehicle (leader _x))),_x,"markPanic","ColorYellow","ICON","mil_dot",_signum + "!",_signum + "!",[0.5,0.5]] call RYD_Mark
					};
					
				_x setVariable [("Busy" + (str _x)), true];

				_UL = leader _x;
				if not (isPlayer _UL) then 
					{
					if ((random 100) < RydxHQ_AIChatDensity) then {[_UL,RydxHQ_AIC_InPanic,"InPanic"] call RYD_AIChatter}
					};

				if (_HQ getVariable ["RydHQ_Surr",false]) then
					{
					if (_dngr < (0.5 + (random 0.5))) exitWith {};
					
					if ((random 100) > 50) then
						{
						if (_HQ getVariable ["RydHQ_DebugII",false]) then 
							{
							_signum = _HQ getVariable ["RydHQ_CodeSign","X"];
							_i setMarkerColor "ColorPink";
							_i setMarkerText (_signum + "!!!")
							};
							
						_isCaptive = _x getVariable ("isCaptive" + (str _x));
						if (isNil "_isCaptive") then {_isCaptive = false};
						if not (_isCaptive) then
							{
							[_x] spawn
								{
								_gp = _this select 0;
								_gp setVariable [("isCaptive" + (str _gp)), true];
								_gp setVariable ["RydHQ_MIA", true];

								(units _gp) orderGetIn false;
								(units _gp) allowGetIn false;//if (player in (units _gp)) then {diag_log "NOT ALLOW surr"};

									{
									[_x] spawn
										{
										_unit = _this select 0;

										sleep (random 1);
										if (isPlayer _unit) exitWith {[_unit] join grpNull};

										_unit setCaptive true;
										unassignVehicle _unit;

										for [{_a = 0},{_a < (count (weapons _unit))},{_a = _a + 1}] do
											{
											_weapon = (weapons _unit) select _a;
											_unit Action ["dropWeapon", _unit, _weapon] 
											};

										_unit PlayAction "Surrender"
										}
									}
								foreach (units _gp)
								}
							}
						}
					}
				};

			_panic = _x getVariable ("inPanic" + (str _x));
			if (isNil ("_panic")) then {_panic = false};

			if not (_panic) then 
				{
				_x allowFleeing _cowF;
				_x setVariable [("Cow" + (str _x)),_cowF,true];
				} 
			else 
				{
				_x allowFleeing 1; 
				_x setVariable [("Cow" + (str _x)),1,true];
				if ((random 1.1) > _cowF) then 
					{
					_isCaptive = _x getVariable ("isCaptive" + (str _x));
					if (isNil "_isCaptive") then {_isCaptive = false};
					_x setVariable [("inPanic" + (str _x)), false];
					if not (_isCaptive) then {_x setVariable [("Busy" + (str _x)), false]};
					}
				}
			}
		foreach _friends
		};

		{
		_KnEnPos set [(count _KnEnPos),getPosATL (vehicle (leader _x))];
		if ((count _KnEnPos) >= 100) then {_KnEnPos = _KnEnPos - [_KnEnPos select 0]};
		}
	foreach _knownEG;
	
	_HQ setVariable ["RydHQ_KnEnPos",_KnEnPos];

	for [{_z = 0},{_z < (count _knownE)},{_z = _z + 1}] do
		{
		_KnEnemy = _knownE select _z;
			{
			if ((_x knowsAbout _KnEnemy) > 0.01) then {_HQ reveal [_KnEnemy,2]}
			}
		foreach _friends
		};

	if (_cycleC == 1) then
		{
		_Recklessness = _HQ getVariable ["RydHQ_Recklessness",0.5];
		_Activity = _HQ getVariable ["RydHQ_Activity",0.5];
		_Fineness = _HQ getVariable ["RydHQ_Fineness",0.5];
		_Circumspection = _HQ getVariable ["RydHQ_Circumspection",0.5];
		_Consistency = _HQ getVariable ["RydHQ_Consistency",0.5];

		if (_HQ getVariable ["RydHQ_AAO",false]) then
			{		
			_AAO = ((((0.1 + _Recklessness + _Fineness + (_Activity * 1.5))/((1 + _Circumspection) max 1)) min 1.8) max 0.05) > ((random 1) + (random 1));
			_HQ setVariable ["RydHQ_ChosenAAO",_AAO];
			};
			
		if (_HQ getVariable ["RydHQ_EBDoctrine",false]) then
			{
			_EBT = ((((_activity + _Recklessness)/(2 + _Fineness)) min 0.8) max 0.01) > ((random 0.5) + (random 0.5));
			
			_HQ setVariable ["RydHQ_ChosenEBDoctrine",_EBT]
			};
		
		if ((_HQ getVariable ["RydHQ_ArtyShells",1]) > 0) then
			{
			[_ArtG,(_HQ getVariable ["RydHQ_ArtyShells",1])] call RYD_ArtyPrep;
			};

		if ((RydBB_Active) and ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in (RydBBa_HQs + RydBBb_HQs))) then 
			{
			_HQ setVariable ["RydHQ_readyForBB",true];
			_HQ setVariable ["RydHQ_Pending",false];
			if ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in RydBBa_HQs) then 
				{
				waitUntil {sleep 0.1;(RydBBa_InitDone)}
				};

			if ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in RydBBb_HQs) then 
				{
				waitUntil {sleep 0.1;(RydBBb_InitDone)}
				}
			}
		};
	
	if (_cycleC > 1) then
		{
		if (_HQ getVariable ["RydHQ_AAO",false]) then
			{
			_Consistency = _HQ getVariable ["RydHQ_Consistency",0.5];
			
			if ((random 100) > (((90 + ((0.5 + _Consistency) * 4.5)) min 99) max 90)) then
				{
				_Recklessness = _HQ getVariable ["RydHQ_Recklessness",0.5];
				_Activity = _HQ getVariable ["RydHQ_Activity",0.5];
				_Fineness = _HQ getVariable ["RydHQ_Fineness",0.5];
				_Circumspection = _HQ getVariable ["RydHQ_Circumspection",0.5];
				
				_AAO = (((((0.1 + _Recklessness + _Fineness + (_Activity * 1.5))/((1 + _Circumspection) max 1)) min 1.8) max 0.05) > ((random 1) + (random 1)));
				_HQ setVariable ["RydHQ_ChosenAAO",_AAO];		
				}
			}
		};
		
	_AAO = _HQ getVariable ["RydHQ_ChosenAAO",false];
	_EBT = _HQ getVariable ["RydHQ_ChosenEBDoctrine",false];
	
	if ((abs _morale) > (0.1 + (random 10) + (random 10) + (random 10) + (random 10) + (random 10))) then {_AAO = false};
		
	if not (_AAO) then {_AAO = _HQ getVariable ["RydHQ_ForceAAO",false]};
	if not (_EBT) then {_EBT = _HQ getVariable ["RydHQ_ForceEBDoctrine",false]};
	
	if (_EBT) then {_AAO = true};
	
	_HQ setVariable ["RydHQ_ChosenEBDoctrine",_EBT];
	_HQ setVariable ["RydHQ_ChosenAAO",_AAO];
	
	if (_HQ getVariable ["RydHQ_KIA",false]) exitWith {RydxHQ_AllHQ = RydxHQ_AllHQ - [_HQ]};

	if (((count _knownE) > 0) and ((count _ArtG) > 0) and ((_HQ getVariable ["RydHQ_ArtyShells",1]) > 0)) then {[_ArtG,_knownE,(_EnHArmor + _EnMArmor + _EnLArmor),_friends,(_HQ getVariable ["RydHQ_Debug",false]),(_HQ getVariable ["leaderHQ",(leader _HQ)])] call RYD_CFF};

	_gauss100 = (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10) + (random 10);
	_obj = _HQ getVariable "RydHQ_Obj";
	
	_moraleInfl = (_gauss100  * (_HQ getVariable ["RydHQ_OffTend",1])) + (_HQ getVariable ["RydHQ_Inertia",0]) + _morale;
	_enemyInfl = (_EValue/(_FValue max 1)) * 40;
	
	if (((_moraleInfl > _enemyInfl) and not (isNil ("_obj")) and not ((_HQ getVariable ["RydHQ_Order","ATTACK"]) == "DEFEND")) or ((_HQ getVariable ["RydHQ_Berserk",false]))) then 
		{
		_lastS = _HQ getVariable ["LastStance","At"];
		if ((_lastS == "De") or (_cycleC == 1)) then
			{
			if ((random 100) < RydxHQ_AIChatDensity) then {[(_HQ getVariable ["leaderHQ",(leader _HQ)]),RydxHQ_AIC_OffStance,"OffStance"] call RYD_AIChatter};
			};

		_HQ setVariable ["LastStance","At"];
		_HQ setVariable ["RydHQ_Inertia",30 * (0.5 + (_HQ getVariable ["RydHQ_Consistency",0.5]))*(0.5 + (_HQ getVariable ["RydHQ_Activity",0.5]))];
		[_HQ] call HAL_HQOrders 
		} 
	else 
		{
		_lastS = _HQ getVariable ["LastStance","De"];
		if ((_lastS == "At") or (_cycleC == 1)) then
			{
			if ((random 100) < RydxHQ_AIChatDensity) then {[(_HQ getVariable ["leaderHQ",(leader _HQ)]),RydxHQ_AIC_DefStance,"DefStance"] call RYD_AIChatter};
			};

		_HQ setVariable ["LastStance","De"];
		_HQ setVariable ["RydHQ_Inertia", - (30  * (0.5 + (_HQ getVariable ["RydHQ_Consistency",0.5])))/(0.5 + (_HQ getVariable ["RydHQ_Activity",0.5]))];
		[_HQ] call HAL_HQOrdersDef 
		};

	if (((((_HQ getVariable ["RydHQ_Circumspection",0.5]) + (_HQ getVariable ["RydHQ_Fineness",0.5]))/2) + 0.1) > (random 1.2)) then
		{
		_SFcount = {not (_x getVariable ["Busy" + (str _x),false]) and not (_x getVariable ["Resting" + (str _x),false])} count (_SpecForG - (_HQ getVariable ["RydHQ_SFBodyGuard",[]]));

		if (_SFcount > 0) then
			{
			_isNight = [] call RYD_isNight;
			_SFTgts = [];
			_chance = 40 + (60 * (_HQ getVariable ["RydHQ_Activity",0.5]));

				{
				_HQ = group _x;
				if (_HQ in _knownEG) then
					{
					_SFTgts set [(count _SFTgts),_HQ]
					}
				}
			foreach (RydxHQ_AllLeaders - [(_HQ getVariable ["leaderHQ",(leader _HQ)])]);

			if ((count _SFTgts) == 0) then
				{
				_chance = _chance/2;
				_SFTgts = _EnArtG
				};

			if ((count _SFTgts) == 0) then
				{
				_chance = _chance/3;
				_SFTgts = _EnStaticG
				};

			if (_isNight) then
				{
				_chance = _chance + 25
				};

			if ((count _SFTgts) > 0) then
				{
				_chance = _chance + (((2 * _SFcount) - (8/(0.75 + ((_HQ getVariable ["RydHQ_Recklessness",0.5])/2)))) * 20);
				_trgG = _SFTgts select (floor (random (count _SFTgts)));
				_alreadyAttacked = {_x == _trgG} count (_HQ getVariable ["RydHQ_SFTargets",[]]);
				_chance = _chance/(1 + _alreadyAttacked);
				if (_chance  < _SFcount) then 
					{
					_chance = _SFcount
					}
				else
					{
					if (_chance > (85 + _SFcount)) then
						{
						_chance = 85 + _SFcount
						}
					};

				if ((random 100) < _chance) then 
					{
					_SFAv = [];

						{
						_isBusy = _x getVariable ["Busy" + (str _x),false];

						if not (_isBusy) then
							{
							_isResting = _x getVariable ["Resting" + (str _x),false];

							if not (_isResting) then
								{
								if not (_x in (_HQ getVariable ["RydHQ_SFBodyGuard",[]])) then
									{	
									_SFAv set [(count _SFAv),_x]
									}
								}
							}
						}
					foreach _SpecForG;

					_team = _SFAv select (floor (random (count _SFAv)));
					_trg = vehicle (leader _trgG);
					if (not ((toLower (typeOf _trg)) in (_HArmor + _LArmor)) or ((random 100) > (90 - ((_HQ getVariable ["RydHQ_Recklessness",0.5]) * 10)))) then 
						{
						//[_team,_trg,_trgG,_HQ] spawn HAL_GoSFAttack;
						[[_team,_trg,_trgG,_HQ],HAL_GoSFAttack] call RYD_Spawn;
						}
					}
				}
			}
		};

	if ((_HQ getVariable ["RydHQ_LRelocating",false]) and not (_AAO)) then
		{
		if ((abs (speed (vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)])))) < 0.1) then {_HQ setVariable ["onMove",false]};
		_onMove = _HQ getVariable ["onMove",false];

		if not (_onMove) then 
			{
			if (not (isPlayer (_HQ getVariable ["leaderHQ",(leader _HQ)])) and ((_cycleC == 1) or not ((_HQ getVariable ["RydHQ_Progress",0]) == 0))) then
				{
				[_HQ] call RYD_WPdel;if (_HQ getVariable ["RydHQ_KIA",false]) exitWith {};

				_Lpos = position (_HQ getVariable ["leaderHQ",(leader _HQ)]);
				if (_cycleC == 1) then {_HQ setVariable ["RydHQ_Fpos",_Lpos]};

				_rds = 0;

				if (_HQ getVariable ["RydHQ_LRelocating",false]) then 
					{
					_rds = 0;
					switch (_HQ getVariable ["RydHQ_NObj",1]) do
						{
						case (1) : 
							{
							_Lpos = (_HQ getVariable ["RydHQ_Fpos",_Lpos]);
							if ((_HQ getVariable ["leaderHQ",(leader _HQ)]) in (RydBBa_HQs + RydBBb_HQs)) then 
								{
								_Lpos = position (_HQ getVariable ["leaderHQ",(leader _HQ)])
								};

							_rds = 0
							};
							
						case (2) : {_Lpos = position (_HQ getVariable ["RydHQ_Obj1",(leader _HQ)])};
						case (3) : {_Lpos = position (_HQ getVariable ["RydHQ_Obj2",(leader _HQ)])};
						default {_Lpos = position (_HQ getVariable ["RydHQ_Obj3",(leader _HQ)])};
						};
					};

				_spd = "LIMITED";
				if ((_HQ getVariable ["RydHQ_Progress",0]) == -1) then {_spd = "NORMAL"};
				_HQ setVariable ["RydHQ_Progress",0];
				_enemyN = false;

					{
					_eLdr = vehicle (leader _x);
					_eDst = _eLdr distance _Lpos;

					if (_eDst < 600) exitWith {_enemyN = true}
					}
				foreach _knownEG;

				if not (_enemyN) then 
					{
					_wp = [_HQ,_Lpos,"MOVE","AWARE","GREEN",_spd,["true",""],true,_rds,[0,0,0],"FILE"] call RYD_WPadd;
					if (isNull (assignedVehicle (_HQ getVariable ["leaderHQ",(leader _HQ)]))) then
						{
						if ((_HQ getVariable ["RydHQ_GetHQInside",false])) then {[_wp] call RYD_GoInside}
						};

					if (((_HQ getVariable ["RydHQ_LRelocating",false])) and ((_HQ getVariable ["RydHQ_NObj",1]) > 1) and (_cycleC > 1)) then 
						{
						_code =
							{
							_Lpos = _this select 0;
							_HQ = _this select 1;
							_knownEG = _this select 2;
						
							_eDst = 1000;
							_onPlace = false;
							_getBack = false;

							waitUntil 
								{
								sleep 10;

									{
									_eLdr = vehicle (leader _x);
									_eDst = _eLdr distance _Lpos;

									if (_eDst < 600) exitWith {_getBack = true}
									}
								foreach _knownEG;

								if (isNull _HQ) then 
									{
									_onPlace = true
									}
								else
									{
									if not (_getBack) then
										{
										if ((((vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)])) distance _LPos) < 30) or (_HQ getVariable ["RydHQ_KIA",false])) then {_onPlace = true}
										}
									};
								

								((_getback) or (_onPlace))
								};

							if not (_onPlace) then
								{
								_rds = 30;
								switch (true) do
									{
									case ((_HQ getVariable ["RydHQ_NObj",1]) <= 2) : {_Lpos = getPosATL (vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)]));_rds = 0};
									case ((_HQ getVariable ["RydHQ_NObj",1]) == 3) : {_Lpos = position (_HQ getVariable ["RydHQ_Obj1",(leader _HQ)])};
									case ((_HQ getVariable ["RydHQ_NObj",1]) >= 4) : {_Lpos = position (_HQ getVariable ["RydHQ_Obj2",(leader _HQ)])};
									};

								_getBack = false;

									{
									_eLdr = vehicle (leader _x);
									_eDst = _eLdr distance _Lpos;

									if (_eDst < 600) exitWith {_getBack = true}
									}
								foreach _knownEG;

								if (_getBack) then {_Lpos = getPosATL (vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)]));_rds = 0};

								[_HQ] call RYD_WPdel;if (_HQ getVariable ["RydHQ_KIA",false]) exitWith {};	

								_spd = "NORMAL";
								if not (((vehicle (_HQ getVariable ["leaderHQ",(leader _HQ)])) distance _LPos) < 50) then {_spd = "FULL"};
								_wp = [_HQ,_Lpos,"MOVE","AWARE","GREEN",_spd,["true",""],true,_rds,[0,0,0],"FILE"] call RYD_WPadd;
								if (isNull (assignedVehicle (_HQ getVariable ["leaderHQ",(leader _HQ)]))) then
									{
									if (_HQ getVariable ["RydHQ_GetHQInside",false]) then {[_wp] call RYD_GoInside}
									};

								_HQ setVariable ["onMove",true];
								}
							};
							
						[[_Lpos,_HQ,_knownEG],_code] call RYD_Spawn
						}
					}
				}
			}
		};
		
	_delay = round (((22.5 + (count _friends))/(0.5 + (_HQ getVariable ["RydHQ_Reflex",0.5]))) * (_HQ getVariable ["RydHQ_CommDelay",1]));
	_alive = true;
	_ct = time;
	_ctRev = time;
	_ctMedS = time;
	_ctFuel = time;
	_ctAmmo = time;
	_ctRep = time;
	_ctISF = time;
	_ctReloc = time;
	_ctLPos = time;
	_ctDesp = time;
	_ctEScan = time;
	_ctGarr = time;
	
	_HQ setVariable ["RydHQ_Pending",false];
	
	waitUntil
		{
		sleep 1;
	
		switch (true) do
			{
			case (isNull _HQ) : {_alive = false};
			case (({alive _x} count (units _HQ)) == 0) : {_alive = false};
			case (_HQ getVariable ["RydHQ_Surrender",false]) : {_alive = false};
			case (_HQ getVariable ["RydHQ_KIA",false]) : {_alive = false};
			};
			
		if (_alive) then
			{
			if (((time - _ctRev) >= 20) or (((time - _ct) > _delay) and (_delay <= 20))) then
				{
				_ctRev = time;
				[_HQ] call HAL_Rev;
				};
							
			if (((count (_HQ getVariable ["RydHQ_Support",[]])) > 0) and (_cycleC > 2)) then
				{
				if (((time - _ctMedS) >= 25) or (((time - _ct) > _delay) and (_delay <= 25))) then
					{
					if (_HQ getVariable ["RydHQ_SMed",true]) then
						{
						_ctMedS = time;
						[_HQ] call HAL_SuppMed;
						}
					};
				
				if (((time - _ctFuel) >= 25) or (((time - _ct) > _delay) and (_delay <= 25))) then
					{
					if (_HQ getVariable ["RydHQ_SFuel",true]) then
						{
						_ctFuel = time;
						[_HQ] call HAL_SuppFuel;
						}
					};
				
				if (((time - _ctRep) >= 25) or (((time - _ct) > _delay) and (_delay <= 25))) then
					{
					if (_HQ getVariable ["RydHQ_SRep",true]) then
						{
						_ctRep = time;
						[_HQ] call HAL_SuppRep;
						}
					};
				};
					
			if (((count ((_HQ getVariable ["RydHQ_Support",[]]) + (_HQ getVariable ["RydHQ_AmmoDrop",[]]))) > 0) and (_cycleC > 2)) then
				{
				if (((time - _ctAmmo) >= 25) or (((time - _ct) > _delay) and (_delay <= 25))) then
					{
					if (_HQ getVariable ["RydHQ_SAmmo",true]) then
						{
						_ctAmmo = time;
						[_HQ] call HAL_SuppAmmo;
						}
					};
				};
				
			if (((time - _ctISF) >= 30) or (((time - _ct) > _delay) and (_delay <= 30))) then
				{
				_ctISF = time;
				_nPos = getPosATL (vehicle (leader _HQ));
				
				if ((_nPos distance _HQlPos) > 10) then
					{
					_HQlPos = _nPos;
					
					[_HQ] call HAL_SFIdleOrd
					}
				};
				
			if (((time - _ctReloc) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
				{
				_ctReloc = time;
				[_HQ] call HAL_Reloc
				};
				
				
			if (_cycleC > 2) then
				{
				if (((time - _ctLPos) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
					{
					_ctLPos = time;
					[_HQ] call HAL_LPos
					}
				};
				
			if (((time - _ctDesp) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
				{
				_ctDesp = time;
				[_HQ] call Desperado
				};
				
			if (((time - _ctEScan) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
				{
				_ctEScan = time;
				[_HQ] call HAL_EnemyScan
				};	

			if (((time - _ctGarr) >= 60) or (((time - _ct) > _delay) and (_delay <= 60))) then
				{
				_ctGarr = time;
				[_HQ,(_snipers + _ATinf + _AAinf)] call HAL_Garrison
				};	
			};
			
		(((time - _ct) > _delay) or not (_alive))
		};
		
	if not (_alive) exitWith {RydxHQ_AllHQ = RydxHQ_AllHQ - [_HQ]};

		{
		_HQ reveal (vehicle (leader _x))
		}
	foreach _friends;

	for [{_z = 0},{_z < (count _knownE)},{_z = _z + 1}] do
		{
		_KnEnemy = _knownE select _z;

			{
			if ((_x knowsAbout _KnEnemy) > 0.01) then {_HQ reveal [_KnEnemy,2]} 
			}
		foreach _friends
		}
	};

RYD_isInside = 
	{
	private ["_pos","_cam","_target","_pX","_pY","_pZ","_pos1","_pos2","_level","_roofed","_axis","_mark","_vh","_axisArr","_marks"];

	_vh = _this select 0;
	_pos = _this select 1;
	_level = _this select 2;
	_axisArr = _this select 3;
	_marks = _axisArr select 1;
	_axisArr = _axisArr select 0;
	
	_cam = objNull;

	if ((count _this) > 5) then {_cam = _this select 5};

	_target = objNull;

	if ((count _this) > 6) then {_target = _this select 6};
	
	_pX = _pos select 0;
	_pY = _pos select 1;
	_pZ = _pos select 2;

	_pos1 = [_pX,_pY,_pZ];
		
	_roofed = false;
			
		{
		_axis = _x;
		_mark = _marks select _foreachIndex;
		
		_pos2 = +_pos1;
		_pos2 set [_axis,(_pos2 select _axis) + (_level * _mark)];

		_roofed = lineIntersects [ATLtoASL (_vh modelToWorld _pos1), ATLtoASL (_vh modelToWorld _pos2),_cam,_target];
		
		if (_roofed) exitWith {}
		}
	foreach _axisArr;

	_roofed
	};

RYD_LiveFeed = 
	{
	private ["_unit","_HQ","_id"];

	_unit = _this select 0;
	_HQ = _this select 1;

	_id = _unit addAction ["Enable cam view", (RYD_Path + "LF\LF.sqf"),[_HQ], -71, false, true, "", "(not RydxHQ_LFActive) and (_this == _target)"];
	_id = _unit addAction ["Disable cam view", (RYD_Path + "LF\LF.sqf"),[_HQ], -81, false, true, "", "(RydxHQ_LFActive) and (_this == _target)"];

	true
	};

RYD_LF = 
	{
	_SCRname = "RYD_LF";
	
	private ["_src","_dc","_leader","_posS"];
	
	_src = _this select 0;
	_leader = _this select 1;
	
	if not (RydHQ_LF) then
		{
		_dc = "EmptyDetector" createVehicle (getPosATL _src);
		
		RydHQ_LF = true;
		[_src,_src,_leader,0] call BIS_fnc_liveFeed;
				
		waitUntil {not (isNil "BIS_liveFeed")};
		waitUntil {camCommitted BIS_liveFeed};
		
		if ([] call RYD_isNight) then
			{
			[1] call RYD_LF_EFF
			};
		
		_vh = vehicle _src;
		_tp = toLower (typeOf _vh);
		
		(group _leader) setVariable ["RydHQ_LFSourceFin",_vh];
		
		_vPos = [0,50,2];
					
		if not (_src == _vh) then 
			{
			_vPos = [0,30,0];
						
			_pX = 0;
			_pY = (sizeOf (typeof _vh))/15;
			_pZ = -_pY;
			
			_sign = 1;
			
			if (_tp in ["b_truck_01_ammo_f"]) then
				{
				_pZ = 0
				};
			
			if (_vh isKindOf "Air") then 
				{
				_pY = (sizeOf (typeof _vh))/4;
				_pZ = 0;
				_sign = 2
				};
				
			_inside = true;

			while {_inside} do
				{
				_inside = [_vh,[_pX,_pY,_pZ],6,[[1],[1]]] call RYD_isInside;
				_pZ = _pZ + (0.01 * _sign);
				};

			if (_tp in ["b_mbt_01_cannon_f","i_mbt_03_cannon_f"]) then
				{
				_pZ = _pZ + 0.1;
				}
			else
				{
				_pZ = _pZ + 0.2;
				};
			
			//_dc setPos (_vh modelToWorld [_pX,_pY,0]);
			_dc attachTo [_vh,[_pX,_pY,_pZ]];
			}
		else 
			{
			//_dc setPos (_vh modelToWorld [0.22,0.05,0]);
			_dc attachTo [_vh,[0.22,0.05,0.1],"head"];
			};
			
		[[_dc,[0,0,0]]] call BIS_fnc_liveFeedSetSource;
		
		_code =
			{
			_tgt = _this select 0;
			_vPos = _this select 1;
			_isFoot = (_tgt == (vehicle _tgt));
				
			while {not (isNil "BIS_liveFeed")} do
				{
				if ((_isFoot) and not (_tgt == (vehicle _tgt))) exitWith
					{
					if (isNil "RydxHQ_LFTerminating") then
						{
						RydxHQ_LFTerminating = true;
						[] call BIS_fnc_liveFeedTerminate;
						waitUntil {isNil "BIS_liveFeed"};
						RydxHQ_LFTerminating = nil;
						_dc = _tgt getVariable ["RydHQ_CamPoint",objNull];
						
						deleteVehicle _dc;
						
						_tgt setVariable ["RydHQ_CamPoint",nil];
						
						RydHQ_LF = false;
						}					
					};
					
				_tgtF = _tgt modelToWorld _vPos;
				if not (_isFoot) then {BIS_liveFeed setDir (getDir _tgt)};
				[_tgtF] call BIS_fnc_liveFeedSetTarget;
				sleep 0.02
				}
			};
			
		[[_src,_vPos],_code] call RYD_Spawn
		}
	else
		{
		if (isNil "RydxHQ_LFTerminating") then
			{
			RydxHQ_LFTerminating = true;
			[] call BIS_fnc_liveFeedTerminate;
			waitUntil {isNil "BIS_liveFeed"};
			RydxHQ_LFTerminating = nil;
			_dc = _src getVariable ["RydHQ_CamPoint",objNull];
			
			deleteVehicle _dc;
			
			_src setVariable ["RydHQ_CamPoint",nil];
			
			RydHQ_LF = false;
			}		
		}
	};
	
RYD_LF_EFF = 
	{
	private ["_mode"];
	
	_mode = _this select 0;
	
	if not (isNil "BIS_liveFeed") then
		{
		[_mode] call BIS_fnc_liveFeedEffects;
		}
	};

RYD_LF_Loop = 
	{
	_leader = _this select 0;
	_HQ = (_this select 3) select 0;
	_maxD = -1;
	_friends = [];
	
	while {RydxHQ_LFActive} do
		{
		if (not (isNil "BIS_liveFeed") and not (RydHQ_LF)) exitWith {RydxHQ_LFActive = false};
		
		switch (isNil "RydHQ_CamVOnly") do
			{
			case (true) : {_friends = (_HQ getVariable ["RydHQ_Friends",[]]) + (RydHQ_CamVIncluded - (_HQ getVariable ["RydHQ_Friends",[]]))};
			case (false) : {_friends = RydHQ_CamVOnly};
			};
		
		_newS = objNull;
		_newG = grpNull;
		_was0 = true;
		_wasNull = true;
		
		if ((count _friends) > 0) then
			{
			_was0 = false;
			_maxD = -1;
			
				{
				_alive = true;
				switch (true) do
					{
					case (isNil {_x}) : {_alive = false};
					case (isNull _x) : {_alive = false};
					case (({(alive _x)} count (units _x)) < 1) : {_alive = false};
					};
				
				if (_alive) then
					{
					_dngr = _x getVariable ["NearE",0];
					if ((abs (speed (vehicle (leader _x)))) > 0.1) then {_dngr = _dngr + 0.0001};
					if (_x getVariable ["Busy" + (str _x),false]) then {_dngr = 2 * _dngr};
					if (_dngr > _maxD) then
						{
						_maxD = _dngr;
						_units = (units _x) - RydHQ_CamVExcluded;
						if ((count _units) > 0) then
							{
							_newG = _x;
							_newS = _units select (floor (random (count _units)));
							}
						}
					}
				
				}
			foreach _friends
			};
		
		_currentS = _HQ getVariable ["RydHQ_LFSource",objNull];
		
		if not (isNull _newS) then
			{
			_wasNull = false;
			if not (_newS == _currentS) then
				{
				if ((_maxD > 0) or ((random 100) > 75)) then
					{
					_HQ setVariable ["RydHQ_LFSource",_newS];
					_currentS = _HQ getVariable ["RydHQ_LFSource",objNull];
	
					_dName = getText (configFile >> "CfgVehicles" >> (typeOf (vehicle _newS)) >> "displayName");
					
					if (RydHQ_LF) then 
						{
						_leader groupChat "Terminating current video link...";
						_cSFin = _HQ getVariable ["RydHQ_LFSourceFin",_newS];
						[_cSFin,_leader] call RYD_LF;
						waitUntil {(isNil "BIS_liveFeed")};
						};
						
					_leader groupChat format ["Establishing new video link with %1...",_dName];
					[_newS,_leader] call RYD_LF;
					waitUntil {not (isNil "BIS_liveFeed")};
					_leader groupChat format ["Video link with %1 established.",_dName];
					}
				}
			};
						
		_stoper = time;
		_stoper2 = time;
		_alive = true;
		_mpl = 1;
		
		waitUntil
			{
			sleep 0.1;

			switch (true) do
				{
				case (isNull _HQ) : {_alive = false};
				case (({alive _x} count (units _HQ)) < 1) : {_alive = false};
				case (not (alive _leader)) : {_alive = false};
				case ((isNull (_HQ getVariable ["RydHQ_LFSourceFin",(vehicle _newS)])) and not (_wasNull)) : {_alive = false};
				case ((not (alive (_HQ getVariable ["RydHQ_LFSourceFin",(vehicle _newS)]))) and not (_wasNull)) : {_alive = false};
				//case ((not (_newG in (_HQ getVariable ["RydHQ_Friends",[]]))) and not (_wasNull)) : {_alive = false};
				case ((_newG getVariable ["RydHQ_MIA",false]) and not (_wasNull)) : {_alive = false};
				case (_HQ getVariable ["RydHQ_KIA",false]) : {_alive = false};
				};
			
			if (_alive) then
				{
				if not (_maxD > 0) then
					{
					if ((time - _stoper2) > 5) then
						{ 
						if ((_was0) or (_wasNull) or not (_maxd > 0)) then
							{
							if ((count (_HQ getVariable ["RydHQ_Friends",[]])) > 0) then
								{
								_stoper = time - 31
								}
							};
						
						_stoper2 = time
						}			
					}
				};
				
			_dngr = _newG getVariable ["NearE",0];
			if ((abs (speed (vehicle (leader _newG)))) > 0.1) then {_dngr = _dngr + 0.0001};
			if (_newG getVariable ["Busy" + (str _newG),false]) then {_dngr = 2 * _dngr};
			
			if (_dngr > (((random 1) + _dngr) * _mpl)) then
				{
				_stoper = time - (10 * _mpl);
				_mpl = _mpl + 0.1
				};
					
			if not (_alive) then {RydxHQ_LFActive = false};
				
			(not (RydxHQ_LFActive) or ((time - _stoper) > 30))
			};
		};
		
	if not (isNil "BIS_liveFeed") then
		{
		_leader groupChat "Terminating current video link...";
		_currentS = _HQ getVariable ["RydHQ_LFSourceFin",objNull];
		[_currentS,_leader] call RYD_LF;
		waitUntil {(isNil "BIS_liveFeed")};
		_leader groupChat "Video link terminated.";
		};
	};
	
RYD_FindClosest = 
	{
	private ["_ref","_objects","_closest","_dstMin","_dstAct"];

	_ref = _this select 0;
	_objects = _this select 1;

	_closest = objNull;

	if ((count _objects) > 0) then 
		{
		_closest = _objects select 0;
		_dstMin = _ref distance _closest;

			{
			_dstAct = _ref distance _x;

			if (_dstAct < _dstMin) then
				{
				_closest = _x;
				_dstMin = _dstAct
				}
			}
		foreach _objects
		};

	_closest
	};
	
/*RYD_FindClosestWithIndex = 
	{
	private ["_ref","_objects","_closest","_dstMin","_dstAct","_index","_clIndex","_clst","_act"];

	_ref = _this select 0;
	_objects = _this select 1;

	_closest = objNull;

	if ((count _objects) > 0) then 
		{
		_closest = _objects select 0;
		_clst = _closest;
		if ((typeName _clst) == (typename grpNull)) then {_clst = vehicle (leader _clst)};
		_index = 0;
		_clIndex = 0;
		_dstMin = _ref distance _clst;

			{
			_act = _x;
			if ((typeName _act) == (typename grpNull)) then {_act = vehicle (leader _act)};
			_dstAct = _ref distance _act;

			if (_dstAct < _dstMin) then
				{
				_closest = _x;
				_dstMin = _dstAct;
				_clIndex = _index
				};

			_index = _index + 1
			}
		foreach _objects
		};

	[_closest,_clIndex]
	};*/
	
RYD_ClusterC = 
	{
	private ["_points","_clusters","_checked","_newCluster","_point","_range"];

	_points = _this select 0;
	_range = _this select 1;

	_clusters = [];
	_checked = [];
	_newCluster = [];

		{
		if not (_x in _checked) then
			{
			_checked set [(count _checked),_x];
			_point = _x;
			_newCluster = [_point];

				{
				if ((_point distance _x) < _range) then 
					{
					_checked set [(count _checked),_x];
					_newCluster set [(count _newCluster),_x];
					}
				}
			foreach _points;

			_clusters set [(count _clusters),_newCluster]
			}
		}
	foreach _points;

	_clusters
	};
	
RYD_Spawn = 
	{
	private ["_arguments","_script","_handle"];
	
	_arguments = _this select 0;
	_script = _this select 1;
	
	_handle = _arguments spawn _script;
	
	RydxHQ_Handles set [(count RydxHQ_Handles),_handle];
	
		{
		if (isNil {_x}) then
			{
			RydxHQ_Handles set [_foreachIndex,0]
			}
		else
			{
			if not (_x isEqualTo 0) then
				{
				if (scriptDone _x) then
					{
					RydxHQ_Handles set [_foreachIndex,0]
					}
				}
			}
		}
	foreach RydxHQ_Handles;
		
	RydxHQ_Handles = RydxHQ_Handles - [0];
	
	/*diag_log format ["New Handle - time: %1 count: (%2 - %3)",time,{not ((str _x) in ["<NULL-script>"])} count RydxHQ_Handles,{((str _x) in ["<NULL-script>"])} count RydxHQ_Handles];
	
	private ["_arr","_ix"];
	
	_arr = toArray (str _script);
	_ix = _arr find 59;
	_arr resize _ix;
	
	if not ((_arr select 1) in [83]) then
		{
		_arr resize 32
		}
	else
		{
		_arr = _arr - [34];
		_arr = [_arr] call RYD_ReverseArr;
		_arr resize ((_arr find 61) - 1);
		_arr = [_arr] call RYD_ReverseArr;
		};
		
	_string = toString _arr;
	
	if (isNil "RYD_Array") then {RYD_Array = []};
	
	if ((count RYD_Array) < 1) then
		{
		RYD_Array = [[_string,1]]
		}
	else
		{
		_inside = false;
		
			{
			if (_string in _x) exitWith 
				{
				_x set [1,(_x select 1) + 1];
				_inside = true
				}
			}
		foreach RYD_Array;
		
		if not (_inside) then
			{
			RYD_Array set [(count RYD_Array),[_string,1]]
			}
		};
	
	diag_log "--------------------------------------------------------------------------------";
	
		{
		diag_log format ["%1",_x];
		}
	foreach RYD_Array*/
	};
	
RYD_ReverseArr = 
	{
	private ["_arr","_final","_amnt"];
	
	_arr = _this select 0;
	_amnt = count _arr;
	
	_final = [];
	
		{
		_amnt = _amnt - 1;
		_final set [_amnt,_x]
		}
	foreach _arr;
	
	_final
	};
	
RYD_GroupMarkerLoop = 
	{	
	while {true} do
		{
		sleep 5;
		
			{
			_myMark = _x getVariable "RYD_ItsMyMark";
			if (({alive _x} count (units _x)) > 0) then
				{
				_side = side _x;
				if (_side in _this) then
					{
					_ldr = leader _x;
					_pos = getPosATL (vehicle _ldr);
					
					_color = switch (_side) do
						{
						case (west) : {"ColorWEST"};
						case (east) : {"ColorEAST"};
						case (resistance) : {"ColorGUER"};
						default {"ColorCIV"};
						};
						
					if (isNil "_myMark") then
						{
						_myMark = "ItsMyMark_" + (str _x) + (str (random 100));
						_myMark = createMarker [_myMark,_pos];
						_myMark setMarkerColor _color;
						_myMark setMarkerShape "ICON";
						_myMark setMarkerType "mil_dot";
						_myMark setMarkerSize [0.75,0.75];
						
						if (0 in _this) then
							{
							_myMark setMarkerText (str _ldr);
							};
						
						_x setVariable ["RYD_ItsMyMark",_myMark]				
						}
					else
						{
						_myMark setMarkerPos _pos;
						
						if (0 in _this) then
							{
							_myMark setMarkerText (str _ldr)
							};
						
						_nE = _ldr findNearestEnemy _ldr;
						
						if (isNull _nE) then
							{
							_myMark setMarkerType "mil_dot"
							}
						else
							{
							_myMark setMarkerType "mil_triangle"
							}
						}
					}
				}
			else
				{
				if not (isNil "_myMark") then
					{
					deleteMarker _myMark
					}
				}
			}
		foreach AllGroups
		}
	};
