//private ["_unit","_actBait","_near","_bait","_dst","_maxBait","_chosen","_lastChosen","_mpl","_sum","_cam","_i","_alive","_actVal","_rnd","_actMpl","_LOS","_tPos","_vGp","_shake"];

[] spawn
	{
	private ["_grps","_ldr","_vGp","_gp"];	

	while {(RydSC_Active)} do
		{
		sleep 10;

		HGroups = AllGroups - RydSC_BLGroups;

		_grps = +HGroups;

			{
			if (isNull _x) then 
				{
				HGroups = HGroups - [_x]
				}
			else
				{
				_ldr = leader _x;
				if (isNull _ldr) then
					{
					HGroups = HGroups - [_x]
					}
				else
					{
					if not (alive _ldr) then
						{
						HGroups = HGroups - [_x]
						}
					else
						{
						if (_ldr isKindOf "ANIMAL") then 
							{
							HGroups = HGroups - [_x]
							}
						}
					}
				}
			}
		foreach _grps;
		}
	};

[] spawn
	{
	private ["_unit","_added"];	

	while {(RydSC_Active)} do
		{
			{
			_unit = vehicle (leader _x);

			_added = _unit getVariable ["EHAdded",false];

			if not (_added) then
				{
				if (_unit == (leader _x)) then 
					{
					_unit setVariable ["EHAdded",true];
					_eh1 = _unit addEventHandler ["FiredNear",{([0.6] + _this) call RYD_BaitFN}];
					_eh2 = _unit addEventHandler ["Hit",{([0.2] + _this) call RYD_BaitFN}];
					
					_ehs = missionNameSpace getVariable ["RydSC_EHs",[]];
					_ehs set [(count _ehs),[_unit,[["FiredNear",_eh1],["Hit",_eh2]]]];
					 missionNameSpace setVariable ["RydSC_EHs",_ehs]
					}
				else
					{
					_unit setVariable ["EHAdded",true];
					_eh1 = _unit addEventHandler ["FiredNear",{([0.4] + _this) call RYD_BaitFN}];
					_eh2 = _unit addEventHandler ["Fired",{([1.2] + _this) call RYD_BaitFN}];
					_eh3 = _unit addEventHandler ["Hit",{([0.2] + _this) call RYD_BaitFN}];
					
					_ehs = missionNameSpace getVariable ["RydSC_EHs",[]];
					_ehs set [(count _ehs),[_unit,[["FiredNear",_eh1],["Fired",_eh2],["Hit",_eh3]]]];
					 missionNameSpace setVariable ["RydSC_EHs",_ehs]
					};

				[_unit] spawn
					{
					private ["_unit","_bait"];

					_unit = _this select 0;

					_bait = _unit getVariable ["RYDBait",0];

					while {(RydSC_Active)} do
						{
						if (isNull _unit) exitWith {};
						if not (alive _unit) exitWith {_unit setVariable ["RYDBait",0]};

						_bait = _unit getVariable ["RYDBait",0];

						if (_bait > 0) then
							{
							if (_bait > 0.1) then
								{
								_unit setVariable ["RYDBait",_bait * 0.8];
								}
							else
								{
								_unit setVariable ["RYDBait",0];
								}
							};

						sleep 5;
						}
					}
				}
			}
		foreach HGroups;

		sleep 5;
		}
	};

_cam = _this select 0;

while {(RydSC_Active)} do
	{

		{
		_unit = vehicle (leader _x);
		_bait = _unit getVariable ["RYDBait",0.1];
		if (_bait < 0.1) then {_bait = 0.1};
		
		_alive = true;

		if not (alive _unit) then {_alive = false};
		if (isNull _unit) then {_alive = false};

		if (_alive) then			
			{
			_near = (getPosATL _unit) nearEntities [["CAManBase","LandVehicle","Air","Ship"],100];
			_near = _near - [_unit];
			_vehF = 1;
			_sum = abs ((sqrt((abs(speed _unit)) + 0.001))/100);
			if not ((_unit isKindOf "CAManBase") or (_sum == 0)) then {_vehF = 2};
			//if (_unit isKindOf "StaticWeapon") then {_vehF = _vehF * 0.5};
			_sum = 0.5 + _sum;
			if (_sum > 3) then {_sum = 3};
			if (([0,0,0] distance (velocity _unit)) > 0.001) then {_sum = _sum * 3};
			_priorM = 1;

			if ((group _unit) in RydSC_Prior) then {_priorM = RydSC_Prior select 0};

			if ((count _near) > 0) then
				{
					{
					_dst = _unit distance _x;
					if (_vehF == 1) then {_dst = _dst * 2};

					if (_dst > 0) then
						{
						_bait = _bait + (0.5 * (1/(sqrt (_dst/5)))/(1 + sqrt (_bait + (1/(sqrt (_dst/5))))))
						}
					}
				foreach (_near - [_unit]);
				
				_nE = _unit findNearestEnemy _unit;
				
				if not (isNull _nE) then
					{
					_dst = (_unit distance _nE);
					if (_dst == 0) then {_dst = 1};
					_eMpl = 400/_dst;
					if (_eMpl > 4) then {_eMpl = 4};
					
					_bait = _bait + 0.5 + (4 * _eMpl * (1/(sqrt (_dst/5)))/(1 + sqrt (_bait + (1/(sqrt (_dst/5))))));
					
					_assT = assignedTarget _unit;
					
					if not (isNull _assT) then
						{
						_dst = (_unit distance _assT);
						if (_dst == 0) then {_dst = 1};
						_eMpl = 800/_dst;
						if (_eMpl > 8) then {_eMpl = 8};
						
						_bait = _bait + 0.5 + (6 * _eMpl * (1/(sqrt (_dst/5)))/(1 + sqrt (_bait + (1/(sqrt (_dst/5))))))
						}
					}
				};

			_unit setVariable ["RYDBait",(_bait * _sum) * _priorM * _vehF];
			}
		}
	foreach HGroups;

	_maxBait = 0;
	_chosenGrp = HGroups select (floor (random (count HGroups)));
	_chosen = vehicle (leader _chosenGrp);
	
	if not (isNull RYD_SCam_Observed) then
		{
		if (alive RYD_SCam_Observed) then
			{
			_chosen = RYD_SCam_Observed;
			_chosenGrp = group RYD_SCam_Observed;
			_maxBait = RYD_SCam_Observed getVariable ["RYDBait",0]
			}
		};

	_mpl = 0;
	if not (isNull _chosenGrp) then {_mpl = _chosenGrp getVariable ["CamMpl",1]};
		
	_maxBait = _maxBait * _mpl;

		{
		if not (isNull _x) then
			{
			if (alive (leader _x)) then
				{
				if not ((vehicle (leader _x)) isKindOf "ANIMAL") then
					{
					_mpl = _x getVariable ["CamMpl",1];
					_actBait = (vehicle (leader _x)) getVariable ["RYDBait",0];
					_gauss2 = (random 0.5) + (random 0.5) + (random 0.5) + (random 0.5);
										
					_actBait = _actBait * _mpl * _gauss2;
					
				

					_alive = true;

					if not (alive (vehicle (leader _x))) then {_alive = false};
					if (isNull (vehicle (leader _x))) then {_alive = false};
					if (_alive) then			
						{
						if (_actBait > _maxBait) then
							{
							_maxBait = _actBait;
							_chosen = (vehicle (leader _x))
							};
						}
					}
				}
			}
		}
	foreach HGroups;

	RYD_SCam_Observed = _chosen;
	_chosenGrp = group (vehicle (leader _chosen));
	_mpl = _chosenGrp getVariable ["CamMpl",1];
	_mpl = _mpl * 0.5;
	_chosenGrp setVariable ["CamMpl",_mpl];

		{
		_mpl = _x getVariable ["CamMpl",1];
		_mpl = _mpl + 0.1;
		if (_mpl > 1.5) then {_mpl = 1.5};
		_x setVariable ["CamMpl",_mpl];
		}
	foreach (HGroups - [_chosenGrp]);

	if not (isNull RYD_SCam_Observed) then {[_cam,RYD_SCam_Observed] call RYD_SceneC};

	_alive = true;

	_actMpl = 1;

	_actMpl = _chosenGrp getVariable ["CamMpl",1];

	waitUntil
		{
		sleep (5 + (random 5));
		
		if ((dayTime < 6) or (dayTime > 20)) then
			{
			 camUseNVG true 
			}
		else
			{
			 camUseNVG false 
			};

		_actVal = 0;
		_rnd = (random 5) * RydSC_ChangeTendMpl;
		_LOS = true;

		if (isNull RYD_SCam_Observed) then {_alive = false};
		if not (alive RYD_SCam_Observed) then {_alive = false};

		if (_alive) then
			{
			_actVal = RYD_SCam_Observed getVariable ["RYDBait",0];
			
			_maxBait = _actVal * _actMpl;
			
				{
				switch (true) do
					{
					case (isNil {_x}) : {HGroups set [_foreachIndex,0]};
					case not ((typeName _x) in [typeName grpNull]) : {HGroups set [_foreachIndex,0]};
					case (isNull _x) : {HGroups set [_foreachIndex,0]};
					}
				}
			foreach HGroups;
			
			HGroups = HGroups - [0];

				{
				if not ((vehicle (leader _x)) isKindOf "ANIMAL") then
					{
					_mpl = _x getVariable ["CamMpl",1];
					if (isNil "_mpl") then {_mpl = 1};
					_actBait = ((vehicle (leader _x)) getVariable ["RYDBait",0]) * _mpl;
					_alive = true;

					if not (alive (vehicle (leader _x))) then {_alive = false};
					if (isNull (vehicle (leader _x))) then {_alive = false};
					if (_alive) then			
						{
						if (_actBait > _maxBait) then
							{
							_maxBait = _actBait
							};
						}
					}
				}
			foreach HGroups;

			if (_maxBait == 0) then {_maxBait = _actVal + 0.1};

			_maxMpl = (_actVal + 0.1)/_maxBait;
			if (_maxMpl > 1) then {_maxMpl = 1};

			_actVal = _actVal * _actMpl * _maxMpl;
			
			_actMpl = _actMpl * 0.8;

			if (true) then
				{
				if ((RYD_SCam_Observed distance _cam) < 20) then 
					{
					_tPos = getPosASL RYD_SCam_Observed;

					_tPos = [(_tPos select 0),(_tPos select 1),(_tPos select 2) + 1.5];		

					_LOS = [(getPosASL _cam),_tPos,_cam,RYD_SCam_Observed] call RYD_CAM_LOSCheck
					};
				}
			};

		((_rnd > ((0.1 + _actVal) * 5)) or (_rnd > 4.5) or not (_alive) or not (_LOS) or not (RydSC_Active))
		};

	RYD_SCam_Observed setVariable ["RYDBait",0]
	};
	
waitUntil
	{
	sleep 0.1;
	not (RydSC_Active)
	};
	
RydSC_Active = nil;

if (RYD_Cam_SOff) then
	{
	_action = missionNameSpace getVariable "RYD_CSwitch_EH";
	
	(_action select 1) removeAction (_action select 0);
	}
else
	{
	waitUntil 
		{
		not (isNull(findDisplay 46))
		};
		
	(findDisplay 46) displayRemoveEventHandler ["KeyDown", (missionNameSpace getVariable ["RYD_CSwitch_EH",-1])];
	};
	
if not (RYD_Cam_SOff) then
	{	
	TitleText ["","BLACK OUT", 0.1]
	};

_ppe = missionNameSpace getVariable ["RYD_SCam_PPE",[]];

ppEffectDestroy _ppe;

terminate RYD_CamFocus_handle;
terminate RYD_CamShake_handle;

_cam cameraEffect ["Terminate", "BACK"];

missionNameSpace setVariable ["RydSC_Camera",nil];

camDestroy _cam;
//deleteVehicle RYD_CamAnch;

	{
	deleteVehicle _x
	}
foreach (entities "RYD_SmartCam");

_ehs = missionNameSpace getVariable ["RydSC_EHs",[]];

	{
	_unit = _x select 0;
	
		{
		_unit removeEventHandler _x
		}
	foreach (_x select 1)
	}
foreach _ehs;

if not (RYD_Cam_SOff) then
	{
	sleep 0.15;
	TitleText ["","BLACK IN", 1]
	};

RYD_Cam_SOff = nil;