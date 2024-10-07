RYD_EndMission = 
	{
	waitUntil 
		{
		not (isNull(findDisplay 46))
		};

	(findDisplay 46) displayAddEventHandler ["KeyDown", "enableEndDialog"]; 
	};
	
RYD_CamSwitchOff = 
	{
	if not (RydSC_ViewSwitch) exitWith 
		{
		waitUntil 
			{
			not (isNull(findDisplay 46))
			};
			
		(findDisplay 46) displayRemoveEventHandler ["KeyDown", (missionNameSpace getVariable ["RYD_CSwitch_EH",-1])];
		};
		
	RYD_Cam_SOff = true;
	TitleText ["","BLACK OUT", 0.1];
	
	waitUntil 
		{
		not (isNull(findDisplay 46))
		};
		
	(findDisplay 46) displayRemoveEventHandler ["KeyDown", (missionNameSpace getVariable ["RYD_CSwitch_EH",-1])];

	sleep 0.15;

	if (RydSC_PPEffects) then
		{	
		((missionNameSpace getVariable ["RYD_SCam_PPE",[]]) select 0) ppEffectEnable false;
		"FilmGrain" ppEffectEnable false;
		"chromAberration" ppEffectEnable false
		};
	
	(missionNameSpace getVariable ["RydSC_Camera",objNull]) cameraEffect ["Terminate", "BACK"];
	
	/*_aIDs = [];
	
	_aID = player addAction ["<t color='#d0a900'>Spectator</t>", "SC\CamSwitchOn.sqf", [], 1, false, true, "", "(RydSC_ViewSwitch) and (player == (vehicle player))"];
	_aIDs set [(count _aIDs),_aID];
	
	if not (player == (vehicle player)) then
		{
		_aID = (vehicle player) addAction ["<t color='#d0a900'>Spectator</t>", "SC\CamSwitchOn.sqf", [], 1, false, true, "", "(RydSC_ViewSwitch) and (_this in _target)"];
		_aIDs set [(count _aIDs),_aID]
		};
		
	missionNameSpace setVariable ["RYD_CSwitch_EH",[_aIDs,[player,(vehicle player)]]];*/
	
	TitleText ["","BLACK IN", 1]
	};
	
RYD_CamSwitchOn = 
	{
	if (isNil "RYD_SCam_Exist") exitWith {[] execVM "SC\CamInit.sqf"};
	
	if not (RydSC_ViewSwitch) exitWith {};
	RYD_Cam_SOff = false;
	TitleText ["","BLACK OUT", 0.1];
	
	/*_action = missionNameSpace getVariable ["RYD_CSwitch_EH",[]];
	
		{
		(_action select _foreachIndex) removeAction (_x select 0)
		}
	foreach _action;*/

	sleep 0.15;

	if (RydSC_PPEffects) then
		{	
		((missionNameSpace getVariable ["RYD_SCam_PPE",[]]) select 0) ppEffectEnable true;
		"FilmGrain" ppEffectEnable true;
		"chromAberration" ppEffectEnable true
		};
	
	(missionNameSpace getVariable ["RydSC_Camera",objNull]) cameraEffect ["internal", "BACK"];
	
	waitUntil 
		{
		not (isNull(findDisplay 46))
		};
		
	_eh = (findDisplay 46) displayAddEventHandler ["KeyDown", "nul = [] spawn RYD_CamSwitchOff;true"];
	missionNameSpace setVariable ["RYD_CSwitch_EH",_eh];
	
	TitleText ["","BLACK IN", 1];
	};
	
RYD_BaitFN = 
	{
	private ["_val","_unit","_bait","_stoper"];

	_val = _this select 0;
	_unit = _this select 1;

	_stoper = _unit getVariable ["FromLast",0];

	if ((time - _stoper) < 0.5) exitWith {};

	_unit setVariable ["FromLast",time];

	_bait = _unit getVariable ["RYDBait",0];

	_unit setVariable ["RYDBait",_bait + ((_val * 2)/(1 + sqrt(_bait + _val + 0.0001)))];
	};

if (isNil "RydSC_RelPos") then
	{
	RydSC_RelPos = 
		[
		[0,-2,1.5],
		[0,-3,1.75],
		[0,-5,2.0],
		[0,-60,25],
		[60,0,25],
		[0,60,25],
		[-60,0,25],
		[3,0,1.75],
		[5,0,2.0],
		[-3,0,1.75],
		[-5,0,2.0],
		[-3,-3,1.75],
		[3,-3,1.75],
		[-3,3,1.75],
		[3,3,1.75],
		[5,-5,2.0],
		[-5,5,2.0],
		[5,5,2.0]
		];
	};
		
RYD_CAM_LOSCheck = 
	{
	private ["_pos1","_pos2","_tint","_lint","_isLOS","_cam","_target","_pX1","_pY1","_pX2","_pY2","_pos1ATL","_pos2ATL"];

	_pos1 = _this select 0;
	_pos2 = _this select 1;

	_pX1 = _pos1 select 0;
	_pY1 = _pos1 select 1;

	_pX2 = _pos2 select 0;
	_pY2 = _pos2 select 1;

	_pos1ATL = ASLtoATL _pos1;//[_pX1,_pY1,1.5];
	if (surfaceIsWater _pos1ATL) then
		{
		_pos1ATL set [2,((((ATLtoASL _pos1ATL) select 2) max 0) + ((_pos1ATL select 2) max 1.5))];
		}
	else
		{
		_pos1ATL set [2,(_pos1ATL select 2) max 1.5];
		};
		
	_pos2ATL = ASLtoATL _pos2;//[_pX2,_pY2,1.5];
	if (surfaceIsWater _pos2ATL) then
		{
		_pos2ATL set [2,((((ATLtoASL _pos2ATL) select 2) max 0) + ((_pos2ATL select 2) max 1.5))];
		}
	else
		{
		_pos2ATL set [2,(_pos2ATL select 2) max 1.5];
		};
		
	_pos1 = ATLtoASL _pos1ATL;
	_pos2 = ATLtoASL _pos2ATL;

	_cam = objNull;

	if ((count _this) > 2) then {_cam = _this select 2};

	_target = objNull;

	if ((count _this) > 3) then {_target = _this select 3};

	_tint = terrainintersect [_pos1ATL, _pos2ATL]; 
	_lint = lineintersects [_pos1, _pos2,_cam,_target]; 

	_isLOS = true;

	if ((_tint) or (_lint)) then {_isLOS = false};

	_isLOS
	};
	
RYD_CAM_AnglesMinDiff = 
	{	
	private _diff = (_this select 0) - (_this select 1);
	(sin _diff) atan2 (cos _diff)
	};

RYD_SceneC = 
	{
	private ["_target","_cam","_speed","_dst","_relPos","_tPos","_plnPos","_ct","_ab","_posT","_posE","_nE","_isLOS","_height","_angle","_size"];

	_cam = _this select 0;
	_target = _this select 1;

	_dst = _cam distance _target;

	_speed = _dst/40;

	if (_speed < 1.5) then {_speed = 1.5};
	if (_speed > 10) then {_speed = 10};
	
	_nE = _target findNearestEnemy _target;
	_plnPos = [0,0,0];

	if ((isNull _nE) or ((random 100) > 85)) then
		{
		_posT = getPosASL _target;
		_relPos = RydSC_RelPos select (floor (random (count RydSC_RelPos)));
		_plnPos = _target modelToWorld _relPos;
		_plnPos set [2,(_plnPos select 2) max 1.5];
		_posR = ATLtoASL _plnPos;
		
		_isLOS = [_posT,_posR,_target,objNull] call RYD_CAM_LOSCheck;
		_angle = _posT getDir _posR;
		_dst = _posT distance2D _posR;
		_cnt = 0;
		
		while {not (_isLOS)} do
			{
			_cnt = _cnt + 5;
			_plnPos = [_posT,_angle + _cnt,_dst] call RYD_CAM_PosTowards2D;
			_plnPos set [2,(_plnPos select 2) max 1.5];
			_isLOS = [_posT,(ATLtoASL _plnPos),_target,objNull] call RYD_CAM_LOSCheck;
			if (_cnt > 360) exitWith {}
			};
					
		_relPos = _target worldToModel _plnPos
		//_plnPos = _target modelToWorld _relPos;
		}
	else
		{
		_posT = getPosASL _target;
		_posE = getPosASL _nE;
		
		_isLOS = [_posT,_posE,_target,_nE] call RYD_CAM_LOSCheck;

		if (_isLOS) then
			{
			_height = 1 + (random 1.5);
			if (_target in Vehicles) then
				{
				_height = _height * 1.5
				};
				
			_dst = _height * (4 + (random 2));

			_angle = [_posT,_posE,10] call RYD_CAM_AngTowards;
			_angle = _angle + 180;
				
			_plnPos = [_posT,_angle,_dst] call RYD_CAM_PosTowards2D;
			_plnPos = [_plnPos select 0,_plnPos select 1,((getPosATL _target) select 2) + _height];
			_relPos = _target worldToModel _plnPos;
			if ((_relPos select 2) < 1) then {_relPos set [2,1]};
			if ((_relPos select 2) < 2) then 
				{
				if (_target in Vehicles) then
					{
					_relPos set [2,2]
					}
				}
			}
		else
			{
			_posT = getPosASL _target;
			_relPos = RydSC_RelPos select (floor (random (count RydSC_RelPos)));
			_plnPos = _target modelToWorld _relPos;
			_plnPos set [2,(_plnPos select 2) max 1.5];
			_posR = ATLtoASL _plnPos;
			
			_isLOS = [_posT,_posR,_target,objNull] call RYD_CAM_LOSCheck;
			_angle = _posT getDir _posR;
			_dst = _posT distance2D _posR;
			_cnt = 0;
			
			while {not (_isLOS)} do
				{
				_cnt = _cnt + 5;
				_plnPos = [_posT,_angle + _cnt,_dst] call RYD_CAM_PosTowards2D;
				_plnPos set [2,(_plnPos select 2) max 1.5];
				_isLOS = [_posT,(ATLtoASL _plnPos),_target,objNull] call RYD_CAM_LOSCheck;
				if (_cnt > 360) exitWith {}
				};
						
			_relPos = _target worldToModel _plnPos
			//_plnPos = _target modelToWorld _relPos;
			}
		};
		
	if (true) then
		{
		if ((_plnPos distance _target) < 20) then 
			{
			_tPos = getPosASL _target;
			_tPos = [(_tPos select 0),(_tPos select 1),(_tPos select 2) + 1.5];
			_plnPos = [(_plnPos select 0),(_plnPos select 1),(getTerrainHeightASL [(_plnPos select 0),(_plnPos select 1)]) + 1.5];
			_ct = 1;

			while {(not ([_plnPos,_tPos,_cam,_target] call RYD_CAM_LOSCheck) and not ((_plnPos distance _target) >= 20))} do
				{
				_relPos = RydSC_RelPos select (floor (random (count RydSC_RelPos)));
				_plnPos = _target modelToWorld _relPos;
				_plnPos = [(_plnPos select 0),(_plnPos select 1),(getTerrainHeightASL [(_plnPos select 0),(_plnPos select 1)]) + 1.5];
				if (_ct > 20) exitWith {};
				_ct = _ct + 1
				};
			};
		};
				
	if (_target in Vehicles) then 
		{
		_vx = _relPos select 0;
		_vy = _relPos select 1;
		_vz = (_relPos select 2)/2;
		_ct = 0;

		_size = (sizeOf (typeOf _target))/2.5;

			{
			_ab = _x;
			if ((abs _x) < 10) then 
				{
				if (_ct == 2) then
					{
					_ab = _size * _x * 1.2;
					if (_ab < 2) then {_ab = 2}
					}
				else
					{
					_ab = (_size * 1.1) * _x
					};
				};

			_relPos set [_ct,_ab];
			_ct = _ct + 1
			}
		foreach [_vx,_vy,_vz];
		};
	
	if (RYD_CAM_Active) then
		{
		RYD_CAM_Active = false;
		waitUntil
			{
			not (isNil "RYD_CAM_Ended")
			};
			
		RYD_CAM_Ended = nil
		};
		
	_wPos = _target modelToWorld _relPos;
	_wPos set [2,(_wPos select 2) max 1.5];
	_relPos = _target worldToModel _wPos;

	[_cam,_target,_relPos,_speed,50,true] call RYD_CAM_MoveCamRel;
	};
		
RYD_CAM_RandomAroundMM = 
	{//based on Muzzleflash' function
	private ["_pos","_xPos","_yPos","_a","_b","_dir","_angle","_mag","_nX","_nY","_temp"];

	_pos = _this select 0;
	_a = _this select 1;
	_b = _this select 2;

	_xPos = _pos select 0;
	_yPos = _pos select 1;

	_dir = random 360;

	_mag = _a + (sqrt ((random _b) * _b));
	_nX = _mag * (sin _dir);
	_nY = _mag * (cos _dir);

	_pos = [_xPos + _nX, _yPos + _nY,0];  

	_pos	
	};
	
RYD_CAM_AngTowards = 
	{
	private ["_source0", "_target0", "_rnd0","_dX0","_dY0","_angleAzimuth0"];

	_source0 = _this select 0;
	_target0 = _this select 1;
	_rnd0 = _this select 2;

	_dX0 = (_target0 select 0) - (_source0 select 0);
	_dY0 = (_target0 select 1) - (_source0 select 1);

	_angleAzimuth0 = (_dX0 atan2 _dY0) + (random (2 * _rnd0)) - _rnd0;
	
	if (_angleAzimuth0 < 0) then {_angleAzimuth0 = _angleAzimuth0 + 360};

	_angleAzimuth0
	};
	
RYD_CAM_PosTowards2D = 
	{
	private ["_source","_distT","_angle","_dXb","_dYb","_px","_py"];

	_source = _this select 0;
	_angle = _this select 1;
	_distT = _this select 2;

	_dXb = _distT * (sin _angle);
	_dYb = _distT * (cos _angle);

	_px = (_source select 0) + _dXb;
	_py = (_source select 1) + _dYb;

	[_px,_py,0]
	};
		
RYD_PosTowards3D = 
	{
	private ["_pos","_angleH","_angleV","_distT","_sx","_sy","_sz","_tPos","_tx","_ty","_tz","_sPos","_dZ","_dist3D","_dXb","_dYb","_dZb","_px","_py","_pz"];

	_pos = _this select 0;//ASL
	_angleH = _this select 1;
	_angleV = _this select 2;
	_distT = _this select 3;
	_dist3D = _this select 4;

	_sx = _pos select 0;
	_sy = _pos select 1;
	_sz = _pos select 2;

	_tPos = [_pos,_angleH,_distT] call RYD_CAM_PosTowards2D;
	_tx = _tPos select 0;
	_ty = _tPos select 1;

	_tPos = [_tx,_ty];
	_tz = (getTerrainHeightASL _tPos);

	_sPos = [_sx,_sy];

	_dZ = _tz - _sz;

	_dXb = _distT * (sin _angleH);
	_dYb = _distT * (cos _angleH);
	_dZb = _dist3D * (sin _angleV);

	_px = (_pos select 0) + _dXb;
	_py = (_pos select 1) + _dYb;
	_pz = _dZb - _dZ;

	[_px,_py,_pz]//AGL
	};		
		
RYD_CAM_Shake = 
	{
	_obj = _this select 0;
	_tgt = _this select 1;
	_cam = _this select 2;
	
	addCamShake [10, 1, 25];
	
	if (true) exitWith {};
	
	sleep 0.001;
	
	detach _obj;
	_obj setPosATL (getPosATL _tgt);
	
	_ct = 1;
	_final = [];
	_wasShake = false;
	
	while {not ((isNull _obj) or (isNull _tgt) or (isNull _cam))} do
		{
		_tgt = vehicle _tgt;
		_cDst = _cam distance _tgt;
		_pos = getPosATL _tgt;
		_oPos = getPosATL _obj;
		_speedF = (1 + ((sqrt (abs (speed _tgt)))/1.5));
	
		_dst = 0.02 * _cDst * _speedF * (0.75 + (random 0.5));
		
		_newPos = _pos;

		_chance = (((sqrt (1 + ((abs (speed _tgt)) * 10))) + (_cDst/10) + (_oPos distance _newPos))/100) * _ct * 1.5;
				
		if (_chance < 0.1) then {_chance = 0.1};
		if (_chance > 0.9) then {_chance = 0.9};

		_shakeIt = ((random 1) < _chance);
		_wasShake = false;

		if (_shakeIt) then
			{
			_wasShake = true;
			if (_ct > 0.05) then {_ct = _ct * 0.95};
			if (_ct < 0.5) then
				{
				if ((random 1) > 0.95) then
					{
					_ct = _ct * (1 + (random 1))
					}
				};
			
			_slp = 0.003;
			
			if (_tgt isKindOf "Air") then
				{
				if (_speedF > 1.1) then
					{
					_slp = 0.002
					}
				};
				
			_tgtPos = getPosASL _tgt;
			_camPos = getPosASL _cam;
				
			_dX = (_tgtPos select 0) - (_camPos select 0);
			_dY = (_tgtPos select 1) - (_camPos select 1);
			_dZ = ((_tgtPos select 2) + 1.5) - (_camPos select 2);
			_2D = sqrt ((_dX^2) + (_dY^2));
			
			_speedF = sqrt (_speedF * 10);
			if (_speedF > 9) then {_speedF = 9};

			_angleV = (_dZ atan2 _2D) + (random (2 * _speedF)) - _speedF;
			_angleH = (_dX atan2 _dY) + (random (2 * _speedF)) - _speedF;
	
			_baseDst = [_camPos select 0,_camPos select 1] distance [_tgtPos select 0,_tgtPos select 1];
			
			_newPos = [_camPos,_angleH,_angleV,_baseDst,_camPos distance _tgtPos] call RYD_PosTowards3D;
			
			_oPos = getPosATL _obj;
			
			_nRel = _tgt worldToModel _newPos;
			_oRel = _tgt worldToModel _oPos;

			if ((count _final) > 0) then {_oRel = _final};
												
			_dst = _oPos distance _newPos;
			_midRel = _final;

			if (_dst > 0.35) then
				{
				_dX = (_nRel select 0) - (_oRel select 0);
				_dY = (_nRel select 1) - (_oRel select 1);
				_dZ = (_nRel select 2) - (_oRel select 2);

				_nr = 30 + (floor (random 20));

				_stepX0 = (_dX/_nr) * 4;
				_stepY0 = (_dY/_nr) * 4;
				_stepZ0 = (_dZ/_nr) * 4;
				
				_sumX = 0;
				_sumY = 0;
				_sumZ = 0;
		
				for "_i" from 1 to _nr do
					{
					_midFar = ((10 * _i)/_nr);//(1 + (abs (_i - _nr)));//abs ((_nr/2) - _i);
					
					_stepX = (_stepX0/(1 + _midFar));
					_sumX = _sumX + _stepX;
					_stepY = (_stepY0/(1 + _midFar));
					_sumY = _sumY + _stepY;
					_stepZ = (_stepZ0/(1 + _midFar));
					_sumZ = _sumZ + _stepZ;

					_midRel = [(_oRel select 0) + _sumX,(_oRel select 1) + _sumY,(_oRel select 2) + _sumZ];

					_obj attachTo [_tgt,_midRel];

					sleep (_slp * (sqrt (1 + _midFar)))
					};
					
				_oPos = getPosATL _obj;
				_newPos = [(((_oPos select 0) + (_newPos select 0))/2),(((_oPos select 1) + (_newPos select 1))/2),(((_oPos select 2) + (_newPos select 2))/2)];
								
				_nRel = _tgt worldToModel _newPos;
				_oRel = _tgt worldToModel _oPos;

				_dst = _oPos distance _newPos;

				_midRel = _final;

				if (_dst > 0.175) then
					{
					_dX = (_nRel select 0) - (_oRel select 0);
					_dY = (_nRel select 1) - (_oRel select 1);
					_dZ = (_nRel select 2) - (_oRel select 2);

					_nr = 30 + (floor (random 20));

					_stepX0 = (_dX/_nr) * 4;
					_stepY0 = (_dY/_nr) * 4;
					_stepZ0 = (_dZ/_nr) * 4;
					
					_sumX = 0;
					_sumY = 0;
					_sumZ = 0;
			
					for "_i" from 1 to _nr do
						{
						_midFar = ((10 * _i)/_nr);//(1 + (abs (_i - _nr)));//abs ((_nr/2) - _i);
						
						_stepX = (_stepX0/(1 + _midFar));
						_sumX = _sumX + _stepX;
						_stepY = (_stepY0/(1 + _midFar));
						_sumY = _sumY + _stepY;
						_stepZ = (_stepZ0/(1 + _midFar));
						_sumZ = _sumZ + _stepZ;

						_midRel = [(_oRel select 0) + _sumX,(_oRel select 1) + _sumY,(_oRel select 2) + _sumZ];

						_obj attachTo [_tgt,_midRel];

						sleep (_slp * (sqrt (1 + _midFar)))
						};				
					};
				};
				
			_final = _midRel;
			};
			
		_dur = 0.001;
		
		_chance = 1;
		if (_wasShake) then {_chance = 0.1};

		if ((random 1) < (random _chance)) then
			{
			_dur = 0.05 + (random 0.2);
			};
			
		sleep _dur
		};
	};
	
RYD_CAM_Focus = 
	{
	_cam = _this select 0;
	
	_focus = 1;
	
	while {not (isNull _cam)} do
		{
		if not (isNull RYD_SCam_Observed) then
			{
			_dst = _cam distance RYD_SCam_Observed;
			_mpl = 1;
			if (RYD_SCam_Observed isKindOf "Air") then
				{
				_mpl = 2
				};
			
			if ((_dst >= (20 * _mpl)) and (RYD_Cam_isAttached)) then
				{
				if ((random 1) > 0.8) then
					{
					if ((missionNameSpace getVariable ["RYD_Cam_FOV",0.7]) == 0.7) then
						{
						_fov = (7/_dst) * _mpl;
						missionNameSpace setVariable ["RYD_Cam_FOV",_fov];
												
						_cam camPrepareFOV _fov;
						_cam camCommit (0.5 + (random 0.5));
						waitUntil {(camCommitted _cam)}
						}
					}
				};
			
			if (((abs (_focus - _dst)) > (_dst/50))) then
				{
				_rangeF = 0.25;

				_focus = _dst * (_rangeF + (random ((1/_rangeF) - _rangeF)));
				
				while {((abs (_focus - _dst)) > (_dst/50))} do
					{
					if (isNull _cam) exitWith {};
					if (isNull RYD_SCam_Observed) exitWith {};
					
					_dst = _cam distance RYD_SCam_Observed;
					
					_cam camSetFocus [_focus, 1.5];
					_cam camCommit (0.5 + (random 0.5));
					waitUntil {(camCommitted _cam)};
					
					_mpl = 1.25 + (random 0.25);
					if (_rangeF > 1) then {_mpl = 1/_mpl};
					
					_rangeF = _rangeF * _mpl;  
					
					_focus = _dst * (_rangeF + (random ((1/_rangeF) - _rangeF)));
					};
				};
			};
			
		sleep 0.1;	
		};
	};

RYD_CAM_MoveCamRel = 
	{
	private ["_cam","_target","_relPos","_speed","_interest","_isAttach","_last","_lastRpos","_lastPos","_lastHeight","_targetPos","_targetHeight","_refHeight",
	"_angle","_lPosATL","_tPosATL","_dst","_stepsC","_maxHeight","_finalHeight","_posStep","_actHeight","_target","_step","_shake"];
	
	_cam = _this select 0;
	
	_target = _this select 1;
	_relPos = _this select 2;
	_speed = _this select 3;
	_interest = 50;
				
	if ((count _this) > 4) then {_interest = _this select 4};
	_isAttach = false;
	if ((count _this) > 5) then {_isAttach = _this select 5};
	
	if (RydSC_ImmediateTrans > (random 100)) exitWith
		{
		if ((RydSC_Active) and not (RYD_Cam_SOff)) then 
			{
			10 cutText ["","BLACK OUT",0.05];
			0.04 fadeSound 0;
			};
		
		
		_last = missionNameSpace getVariable ["CamTgt",[objNull,[]]];
		_lastRpos = _last select 1;
		_last = _last select 0;
		
		sleep 0.05;
		
		if not (isNull _last) then
			{
			if not ((missionNameSpace getVariable ["RYD_Cam_FOV",0.7]) == 0.7) then
				{
				_cam camPrepareFOV 0.7;
				missionNameSpace setVariable ["RYD_Cam_FOV",0.7]
				};

			_cam camCommit 0;

			waitUntil {(camCommitted _cam)};
			
			sleep 0.001;
			};
		
		detach _cam;
		RYD_Cam_isAttached = false;
		
		if (RydSC_Additional) then
			{	
			terminate RYD_CamFocus_handle;
			terminate RYD_CamShake_handle
			};
			
		/*detach RYD_CamAnch;
		RYD_CamAnch setDir (getDir _target);
		RYD_CamAnch setPosATL [((getPosATL _target) select 0),((getPosATL _target) select 1),((getPosATL _target) select 2) + 1.5];
		RYD_CamAnch attachTo [_target,[0,0,1.5]];
		RYD_CamAnch setVariable ["RYD_attachedTo",_target];*/

		//_cam camPrepareTarget _target;
		_cam camSetPos (_target modelToWorld _relPos);
		_pos1 = getPosATL _cam;
		_pos2 = getPosATL _target;
		_posA = if (surfaceIsWater _pos1) then
			{
			+_pos1
			}
		else
			{
			+(ATLtoASL _pos1)
			};
			
		_posB = if (surfaceIsWater _pos2) then
			{
			+_pos2
			}
		else
			{
			+(ATLtoASL _pos2)
			};
		
		_vTgt = _posA vectorFromTo _posB;
		_cam camSetDir _vTgt;
		_cam camCommit 0;

		waitUntil {(camCommitted _cam)};
		
		/*_mapPos = (getPosATL _cam);
		_hgt = (_mapPos select 2) - ((getPosATL _target) select 2);

		if (_hgt < 1.5) then
			{
			_mapPos = [(_mapPos select 0),(_mapPos select 1),((getPosATL _target) select 2) + 1.5]
			};

		_cam attachTo [_target,(_target worldToModel _mapPos)];*/
		RYD_Cam_isAttached = true;
		
		/*if (RydSC_Additional) then
			{
			RYD_CamShake_handle = [RYD_CamAnch,_target,_cam] spawn RYD_CAM_Shake;
			RYD_CamFocus_handle = [_cam] spawn RYD_CAM_Focus
			};*/
			
		RYD_CAM_NChandle = [_target,(_target modelToWorld _relPos),1,_cam,true,false,false,1,1,0.75,2,0.75,0.75,false,-1,0] spawn RYD_CAM_NaturalCam;
			
		if ((RydSC_Active) and not (RYD_Cam_SOff)) then 
			{
			10 cutText ["","BLACK IN",0.05];
			0.04 fadeSound 1;
			};
			
		missionNameSpace setVariable ["CamTgt",[_target,_relPos]];
		};

	_last = missionNameSpace getVariable ["CamTgt",[objNull,[]]];
	_lastRpos = _last select 1;
	_last = _last select 0;
	
	_maxHeight = 0;
	_lastHeight = 0;
	_targetHeight = 0;

	if not ((isNull (_last)) or (_last == _target)) then
		{
		_lastPos = getPosASL _last;
		_lastHeight = _lastPos select 2;
		_targetPos = getPosASL _target;
		_targetHeight = _targetPos select 2;
		
		_refHeight = _lastHeight min _targetHeight;

		_angle = [_lastPos,_targetPos,0] call RYD_CAM_AngTowards;
		
		_lPosATL = getPosATL _last;
		_tPosATL = getPosATL _target;
		
		_dst = _lPosATL distance _tPosATL;
		
		_stepsC = floor (_dst/10);
		_step = 10;
		
		if (_stepsC < 1) then
			{
			_stepsC = 1;
			_step = _dst/2 
			};
		
		_dst = 0;
		
		for "_i" from 1 to _stepsC do
			{
			_dst = _dst + _step;
			_posStep = [_lastPos,_angle,_dst] call RYD_CAM_PosTowards2D;
			_actHeight = getTerrainHeightASL [(_posStep select 0),(_posStep select 1)];
			if (_actHeight > _maxHeight) then
				{
				_maxHeight = _actHeight
				}
			}
		}
	else
		{
		if (isNull (_last)) then
			{
			_maxHeight = 165
			}
		};
		
	detach _cam;
	RYD_Cam_isAttached = false;
	
	if (RydSC_Additional) then
		{	
		terminate RYD_CamFocus_handle
		};

	if not (isNull _last) then
		{
		if not ((missionNameSpace getVariable ["RYD_Cam_FOV",0.7]) == 0.7) then
			{
			_cam camPrepareFOV 0.7;
			missionNameSpace setVariable ["RYD_Cam_FOV",0.7]
			};
		
		//_cam camPrepareTarget _last;
		_cam camSetPos (_last modelToWorld [_lastRpos select 0,_lastRpos select 1,_maxHeight - _lastHeight + RydSC_TransHeight]);
		//_cam camSetRelPos [_lastRpos select 0,_lastRpos select 1,_maxHeight - _lastHeight + RydSC_TransHeight];
		_pos1 = getPosATL _cam;
		_pos2 = getPosATL _target;
		_posA = if (surfaceIsWater _pos1) then
			{
			+_pos1
			}
		else
			{
			+(ATLtoASL _pos1)
			};
			
		_posB = if (surfaceIsWater _pos2) then
			{
			+_pos2
			}
		else
			{
			+(ATLtoASL _pos2)
			};
		
		_vTgt = _posA vectorFromTo _posB;
		_cam camSetDir _vTgt;

		_spd = RydSC_TransHeight/35;
		if (_spd > 1) then {_spd = 1};
		if (_spd < 0.5) then {_spd = 0.5};
		_cam camCommit _spd;

		waitUntil {(camCommitted _cam)};
		
		sleep 0.001;
		};
				
	//_cam camPrepareTarget _target;
	_cam camSetPos (_target modelToWorld [_relPos select 0,_relPos select 1,_maxHeight - _targetHeight + RydSC_TransHeight]);
	//_cam camSetRelPos [_relPos select 0,_relPos select 1,_maxHeight - _targetHeight + RydSC_TransHeight];
	_pos1 = getPosATL _cam;
	_pos2 = getPosATL _target;
	_posA = if (surfaceIsWater _pos1) then
		{
		+_pos1
		}
	else
		{
		+(ATLtoASL _pos1)
		};
		
	_posB = if (surfaceIsWater _pos2) then
		{
		+_pos2
		}
	else
		{
		+(ATLtoASL _pos2)
		};
	
	_vTgt = _posA vectorFromTo _posB;
	_cam camSetDir _vTgt;

	_cam camCommit _speed;

	waitUntil {(camCommitted _cam)};
	
	/*if (RydSC_Additional) then
		{
		terminate RYD_CamShake_handle
		};
	
	detach RYD_CamAnch;
	RYD_CamAnch setDir (getDir _target);
	RYD_CamAnch setPosATL [((getPosATL _target) select 0),((getPosATL _target) select 1),((getPosATL _target) select 2) + 1.5];
	RYD_CamAnch attachTo [_target,[0,0,1.5]];
	RYD_CamAnch setVariable ["RYD_attachedTo",_target];
		
	if (RydSC_Additional) then
		{
		RYD_CamShake_handle = [RYD_CamAnch,_target,_cam] spawn RYD_CAM_Shake
		};*/
			
	sleep 0.001;

	//_cam camPrepareTarget _target;
	_cam camSetPos (_target modelToWorld _relPos);
	_pos1 = getPosATL _cam;
	_pos2 = getPosATL _target;
	_posA = if (surfaceIsWater _pos1) then
		{
		+_pos1
		}
	else
		{
		+(ATLtoASL _pos1)
		};
		
	_posB = if (surfaceIsWater _pos2) then
		{
		+_pos2
		}
	else
		{
		+(ATLtoASL _pos2)
		};
	
	_vTgt = _posA vectorFromTo _posB;
	_cam camSetDir _vTgt;

	_cam camCommit (_speed/5);

	waitUntil {(camCommitted _cam)};
	sleep 0.001;
	
	//_cam camPrepareTarget _target;
	_cam camSetPos (_target modelToWorld _relPos);
	_pos1 = getPosATL _cam;
	_pos2 = getPosATL _target;
	_posA = if (surfaceIsWater _pos1) then
		{
		+_pos1
		}
	else
		{
		+(ATLtoASL _pos1)
		};
		
	_posB = if (surfaceIsWater _pos2) then
		{
		+_pos2
		}
	else
		{
		+(ATLtoASL _pos2)
		};
	
	_vTgt = _posA vectorFromTo _posB;
	_cam camSetDir _vTgt;
	
	_cam camCommit (_speed/25);

	waitUntil {(camCommitted _cam)};
	sleep 0.001;
	
	_mapPos = (getPosATL _cam);
	_hgt = (_mapPos select 2) - ((getPosATL _target) select 2);

	if (_hgt < 1.5) then
		{
		_mapPos = [(_mapPos select 0),(_mapPos select 1),((getPosATL _target) select 2) + 1.5]
		};

	//_cam attachTo [_target,(_target worldToModel _mapPos)];

	RYD_Cam_isAttached = true;
	
	/*if (RydSC_Additional) then
		{
		RYD_CamFocus_handle = [_cam] spawn RYD_CAM_Focus
		};*/

	missionNameSpace setVariable ["CamTgt",[_target,_relPos]];
	
	RYD_CAM_NChandle = [_target,(_target modelToWorld _relPos),1,_cam,true,false,false,1,((floor (random 3)) min 0.75),0.75,1,0.75,0.75,false,-1,0] spawn RYD_CAM_NaturalCam;
	};
	
RYD_CAM_AnglesMinDiff = 
	{	
	private _diff = (_this select 0) - (_this select 1);
	(sin _diff) atan2 (cos _diff)
	};
	
RYD_CAM_NaturalCam = 
	{
	RYD_NCAM_target = param [0,player,[objNull]];
	private _initPos = param [1,(RYD_NCAM_target modelToWorld [0,-10,5]),[objNull,[],""],[2,3]];
	RYD_NCAM_mode = param [2,0,[0]];
	RYD_NCAM_cam = param [3,objNull,[objNull]];
	RYD_CAM_Active = param [4,true,[true]];
	private _del = param [5,true,[true]];
	private _border = param [6,false,[false]];
	RYD_NCAM_swayCh = param [7,1,[0]];
	RYD_NCAM_zoomCh = param [8,1,[0]];
	RYD_NCAM_focusCh = param [9,1,[0]];
	RYD_NCAM_swayMpl = param [10,1,[0]];
	RYD_NCAM_zoomMpl = param [11,1,[0]];
	RYD_NCAM_focusMpl = param [12,1,[0]];
	private _isPPE = param [13,true,[true]];
	private _fs = param [14,1,[0]];
	private _speed = param [15,1,[0]];	
	
	if ((typeName _initPos) isEqualTo (typeName objNull)) then
		{
		_initPos = getPosATL _initPos;
		};
		
	if ((typeName _initPos) isEqualTo (typeName "")) then
		{
		_initPos = getMarkerPos _initPos;
		};
	
	if (isNull RYD_NCAM_cam) then
		{
		RYD_NCAM_cam = "camera" camCreate _initPos;
		RYD_NCAM_cam setDir (getDir RYD_NCAM_target);
		RYD_NCAM_cam cameraEffect ["INTERNAL", "BACK"];
		};

	RYD_CAM_cam = RYD_NCAM_cam;
	//_ixS = RYD_NCAM_target addEventHandler ["FiredNear", RYD_CAM_FireShake];
	//_ixE = RYD_NCAM_target addEventHandler ["Explosion", RYD_CAM_ExplShake];
		
	showCinemaBorder _border;
		
	private _initPos = getPosATL RYD_NCAM_cam;
	private _initPosT = getPosATL RYD_NCAM_target;
	RYD_NCAM_initDst = RYD_NCAM_cam distance RYD_NCAM_target;
	RYD_NCAM_initDst2D = RYD_NCAM_cam distance2D RYD_NCAM_target;
	RYD_NCAM_initRelPos = RYD_NCAM_target worldToModel _initPos;
	
	private _initElevCam = if (surfaceIsWater _initPos) then
		{
		((ATLtoASL _initPos) select 2)
		}
	else
		{
		(_initPos select 2)
		};
		
	private _initElevTgt = if (surfaceIsWater _initPosT) then
		{
		((ATLtoASL _initPosT) select 2)
		}
	else
		{
		(_initPosT select 2)
		};
	
	RYD_NCAM_initElev = _initElevCam - _initElevTgt;
	
	RYD_NCAM_initDir = _initPosT getDir _initPos;
	RYD_NCAM_stoper = 0;
	RYD_NCAM_int = 0;
	RYD_NCAM_spdDst = 0;
	RYD_NCAM_spdDstH = 0;
	RYD_NCAM_spdDstV = 0;
	RYD_NCAM_newSwayTime = ((0.1 * (1 + RYD_NCAM_spdDst)) + (random 0.5));
	//private _addElev = 0;
	RYD_NCAM_currElev = 0;
	//private _lastElev = 0;
	//private _waitForMore = true;
	RYD_NCAM_actFocus = RYD_NCAM_initDst;
	
	/*private _elev0 = if (surfaceIsWater (getPosATL RYD_NCAM_target)) then
		{
		(((getPosASL RYD_NCAM_target) select 2) + RYD_NCAM_initElev)
		}
	else
		{
		(((getPosATL RYD_NCAM_target) select 2) + RYD_NCAM_initElev)
		};*/
	
	RYD_NCAM_cam camSetDir (_initPos vectorFromTo _initPosT);
	RYD_NCAM_cam camCommit 0;
	//RYD_NCAM_lastCamPos = _initPos;
	RYD_NCAM_lastVelH = 0;
	RYD_NCAM_lastVelV = 0;
	RYD_NCAM_lastAccH = 0;
	RYD_NCAM_lastAccV = 0;
	RYD_NCAM_lastAccDiff = 0;
	RYD_NCAM_lastAccDiffV = 0;

	RYD_NCAM_target setCameraInterest 0;
	RYD_NCAM_dirCommit = time;
	RYD_NCAM_cFOV = 0.75;
	RYD_NCAM_preTPos = _initPos;
	//private _lastVelDst = 0;
	RYD_NCAM_preTPosRel = [0,0,0];
	RYD_NCAM_isZooming = time;
	RYD_NCAM_dirTme = 0.5;
	RYD_NCAM_cam camSetFocus [-1,-1];
	RYD_NCAM_cam camCommit 0;
	RYD_NCAM_diam = (sizeOf (typeOf RYD_NCAM_target)) max 0.1;
	
	if (_isPPE) then
		{
		private _ppBlur = ppEffectCreate ["DynamicBlur", 1];
		_ppBlur ppEffectAdjust [0.08];

		private _ppGrain = ppEffectCreate ["FilmGrain", 2];
		_ppGrain ppEffectAdjust [0.1, 2.05, 0.23, 0.11, 0, true];

		private _ppChrom = ppEffectCreate ["chromAberration", 3];
		_ppChrom ppEffectAdjust [0.05,0.05,true];

		_ppGrain ppEffectCommit 0;
		_ppBlur ppEffectCommit 0;
		_ppChrom ppEffectCommit 0;
			
		missionNameSpace setVariable ["RYD_CAM_SCam_PPE",[_ppBlur,_ppGrain,_ppChrom]];
		
		((missionNameSpace getVariable ["RYD_CAM_SCam_PPE",[]]) select 0) ppEffectEnable true;
		"FilmGrain" ppEffectEnable true;
		"chromAberration" ppEffectEnable true
		};
				
	if not (_fs < 0) then
		{
		0 fadeSound _fs
		};
	
	if not (_speed < 0) then
		{
		RYD_NCAM_cam camPrepareTarget objNull;
		RYD_NCAM_cam camCommit 0;
				
		private _posA = if (surfaceIsWater _initPos) then
			{
			+_initPos
			}
		else
			{
			+(ATLtoASL _initPos)
			};
			
		private _posB = if (surfaceIsWater _initPosT) then
			{
			+_initPosT
			}
		else
			{
			+(ATLtoASL _initPosT)
			};
		
		_vTgt = _posA vectorFromTo _PosB;
		RYD_NCAM_cam camSetDir _vTgt;
		
		RYD_NCAM_cam camCommit 0;
		waitUntil {(camCommitted RYD_NCAM_cam)};
		};
	
	RYD_NCAM_FOV = ((10 * (RYD_NCAM_diam/20)/RYD_NCAM_initDst) min 1 max 0.01);
	RYD_NCAM_aFOV = 2;
		
	//while {RYD_CAM_Active} do
	RYD_CAM_NaturalCam_Loop = 
		{
		_lt = diag_tickTime;
		if ((isNull RYD_NCAM_cam) or {(isNull RYD_NCAM_target)}) exitwith {true};
		_isSway = (random 100) < (100 * RYD_NCAM_swayCh);
		
		_ivMpl = 0.01;
		if (RYD_NCAM_mode isEqualTo 3) then
			{
			_ivMpl = 0.5
			};
		
		if (RYD_NCAM_stoper > RYD_NCAM_newSwayTime) then
			{
			RYD_NCAM_int = time;
			RYD_NCAM_newSwayTime = ((0.1 * (1 + RYD_NCAM_spdDst)) + (random 0.5));			
			//_lastElev = RYD_NCAM_currElev;
			RYD_NCAM_currElev = 0;
			};
			
		_pos1 = getPosATL RYD_NCAM_cam;
		if (surfaceIsWater _pos1) then
			{
			_pos1 = ATLtoASL _pos1
			};
			
		//RYD_NCAM_lastCamPos = +_pos1;

		_actPos = getPosATL RYD_NCAM_target;
		
		if (surfaceIsWater _actPos) then
			{
			_actPos = ATLtoASL _actPos
			};
		
		_scrPos = worldToScreen _actPos;
	
		_scrDst = if ((count _scrPos) < 2) then
			{
			_scrPos = [0.5,0.5];
			1
			}
		else
			{
			([0.5,0.5] distance _scrPos)
			};
		
		_dir = _pos1 getDir _actPos;
		_camDir = getDir RYD_NCAM_cam;
		if (_camDir > 180) then
			{
			_camDir = _camDir - 360
			};
			
		_diff = [_camDir,_dir] call RYD_CAM_AnglesMinDiff;
		
		_vCam = vectorDir RYD_NCAM_cam;
		_vDir1 = (_vCam select 1) atan2 (_vCam select 2);
		
		_posA = if (surfaceIsWater _pos1) then
			{
			+_pos1
			}
		else
			{
			+(ATLtoASL _pos1)
			};
			
		_posB = if (surfaceIsWater RYD_NCAM_preTPos) then
			{
			+RYD_NCAM_preTPos
			}
		else
			{
			+(ATLtoASL RYD_NCAM_preTPos)
			};
			
		_vTgt = _posA vectorFromTo _PosB;
		_velT = velocity RYD_NCAM_target;
		_velDst = [0,0,0] distance _velT;
		_accH = (RYD_NCAM_spdDstH - RYD_NCAM_lastVelH);
		_accV = (RYD_NCAM_spdDstV - RYD_NCAM_lastVelV);
		_velDstH = [0,0] distance2D [(_velT select 0),(_velT select 1)];
		_zoomDiff = RYD_NCAM_isZooming - time;

		_changeDisp = ((random 100) < ((((((1 + _velDst))/0.5) max (_scrDst)) min 75) max 0.01)) or {(_zoomDiff > 0)};//czy w og󬥠przesuwamy
		
		//_lastVelDst = _velDst;
		
		RYD_NCAM_preTPos = if (_changeDisp) then
			{
			+_actPos
			}
		else
			{
			_wPos = (RYD_NCAM_target modelToWorld RYD_NCAM_preTPosRel);
			
			if (surfaceIsWater _wPos) then
				{
				+(ATLtoASL _wPos)
				}
			else
				{
				+_wPos
				};	
			};
			
		RYD_NCAM_preTPos set [2,(_actPos select 2)];
		
		_accDiff = ((RYD_NCAM_lastAccDiff * 0.99) + (((100 * RYD_NCAM_swayMpl * (_accH - RYD_NCAM_lastAccH)) min (((abs RYD_NCAM_lastAccDiff) * 0.01) max (0.2 max (1 - _velDstH)))) max ((-(abs RYD_NCAM_lastAccDiff) * 0.01) min (-0.2 min (-1 + _velDstH)))));//suw horyzontalny
		_accDiffV = ((RYD_NCAM_lastAccDiffV * 0.99) + (((100 * RYD_NCAM_swayMpl * (_accV - RYD_NCAM_lastAccV)) min (((abs RYD_NCAM_lastAccDiffV) * 0.01) max (0.2 max (1 - RYD_NCAM_spdDstV)))) max ((-(abs RYD_NCAM_lastAccDiffV) * 0.01) min (-0.2 min (-1 + RYD_NCAM_spdDstV)))));//suw wertykalny
		
		if ((_isSway) and {(((abs _accDiff) > 2) and {((random (abs RYD_NCAM_spdDstH)) > 1) and {(_changeDisp)}}) or {(_zoomDiff > (random 0.1))}}) then//czy przesuwamy w poziomie
			{
			_preDir = if (_velDstH > 1) then
				{
				((_velT select 0) atan2 (_velT select 1))
				}
			else
				{
				(getDir RYD_NCAM_target)
				};

			RYD_NCAM_preTPos = [_actPos,_preDir,_accDiff] call RYD_CAM_PosTowards2D;
			RYD_NCAM_preTPos set [2,(_actPos select 2)];
			
			_posA = if (surfaceIsWater _pos1) then
				{
				+_pos1
				}
			else
				{
				+(ATLtoASL _pos1)
				};
				
			_posB = if (surfaceIsWater RYD_NCAM_preTPos) then
				{
				+RYD_NCAM_preTPos
				}
			else
				{
				+(ATLtoASL RYD_NCAM_preTPos)
				};

			_vTgt = _posA vectorFromTo _posB;
			};
		
		if ((_isSway) and {(((abs _accDiffV) > 2) and {((random (abs RYD_NCAM_spdDstV)) > 1) and {(_changeDisp)}}) or {(_zoomDiff > (random 0.1))}}) then//czy przesuwamy w pionie
			{
			_add = if ((abs _accDiffV) > 0) then
				{
				((sqrt (abs _accDiffV)) * (_accDiffV/(abs _accDiffV)))
				}
			else
				{
				0
				};
				
			RYD_NCAM_preTPos set [2,(RYD_NCAM_preTPos select 2) + _add];
			
			_posA = if (surfaceIsWater _pos1) then
				{
				+_pos1
				}
			else
				{
				+(ATLtoASL _pos1)
				};
				
			_posB = if (surfaceIsWater RYD_NCAM_preTPos) then
				{
				+RYD_NCAM_preTPos
				}
			else
				{
				+(ATLtoASL RYD_NCAM_preTPos)
				};
			
			_vTgt = _posA vectorFromTo _posB;
			};

		RYD_NCAM_lastVelH = RYD_NCAM_spdDstH;
		RYD_NCAM_lastVelV = RYD_NCAM_spdDstV;
		RYD_NCAM_lastAccH = _accH;
		RYD_NCAM_lastAccV = _accV;
		RYD_NCAM_lastAccDiff = _accDiff;
		RYD_NCAM_lastAccDiffV = _accDiffV;
		RYD_NCAM_preTPosRel = RYD_NCAM_target worldToModel RYD_NCAM_preTPos;
		
		_vDir2 = (_vTgt select 1) atan2 (_vTgt select 2);
		RYD_NCAM_spdDst = [0,0,0] distance _velT;
		RYD_NCAM_spdDstH = [0,0,0] distance2D _velT;
		RYD_NCAM_spdDstV = _velT select 2;
				
		//a1 setPos RYD_NCAM_preTPos;
		
		_diffV = [_vDir1,_vDir2] call RYD_CAM_AnglesMinDiff;
		_diffDst = if not (RYD_NCAM_mode isEqualTo 3) then 
			{
			((abs (RYD_NCAM_initDst - (RYD_NCAM_cam distance RYD_NCAM_target))) * (1 + RYD_NCAM_spdDst)/10)
			}
		else
			{
			0
			};
		
		_maxDiff = ((abs _diff) max (abs _diffV)) max _diffDst;
		_maxDiff2 = (abs _diff) max (abs _diffV);
		
		_actDst = RYD_NCAM_cam distance RYD_NCAM_target;
		_focusAm = abs (_actDst - RYD_NCAM_actFocus);
		
		if ((_maxDiff > 0.1) or {(((RYD_NCAM_actFocus < _actDst) and {RYD_NCAM_actFocus < 20}) or {((abs(RYD_NCAM_aFOV - RYD_NCAM_FOV)) > 0.01)}) and {((time - RYD_NCAM_dirCommit) > (_ivMpl max RYD_NCAM_dirTme))}}) then
			{
			_mvEdge = if (_diff < 0) then
				{
				0.9
				}
			else
				{
				0.1
				};
			
			if not (RYD_NCAM_mode isEqualTo 3) then
				{
				_movPos = switch (RYD_NCAM_mode) do
					{
					case (0) : 
						{
						_movDir = _actPos getDir _pos1;
						([_actPos,_movDir,RYD_NCAM_initDst2D] call RYD_CAM_PosTowards2D)
						};
						
					case (1) :
						{
						([_actPos,RYD_NCAM_initDir,RYD_NCAM_initDst2D] call RYD_CAM_PosTowards2D)
						};
						
					default 
						{
						(RYD_NCAM_target modelToWorld RYD_NCAM_initRelPos)
						};
					};
				
				_elev = if (surfaceIsWater (getPosATL RYD_NCAM_target)) then
					{
					(((getPosASL RYD_NCAM_target) select 2) + RYD_NCAM_initElev)
					}
				else
					{
					(((getPosATL RYD_NCAM_target) select 2) + RYD_NCAM_initElev)
					};
										
				_movPos set [2,((_elev + RYD_NCAM_currElev) max 0.01)];

				RYD_NCAM_cam camSetPos _movPos;
				/*_pos1 = getPosATL RYD_NCAM_cam;
				_pos2 = getPosATL RYD_NCAM_target;
				_posA = if (surfaceIsWater _pos1) then
					{
					+_pos1
					}
				else
					{
					+(ATLtoASL _pos1)
					};
					
				_posB = if (surfaceIsWater _pos2) then
					{
					+_pos2
					}
				else
					{
					+(ATLtoASL _pos2)
					};
				
				_vTgt = _posA vectorFromTo _posB;
				RYD_NCAM_cam camSetDir _vTgt;*/
				};
											
			_tme = ((1/((abs _maxDiff) max 1)) max (_ivMpl * 1.1));
										
			RYD_NCAM_cam camCommit _tme;
			_actDst = RYD_NCAM_cam distance RYD_NCAM_target;
			RYD_NCAM_actFocus = _actDst;
					
			if ((time - RYD_NCAM_dirCommit) > (_ivMpl max RYD_NCAM_dirTme)) then//zoom
				{
				RYD_NCAM_dirCommit = time;
				RYD_NCAM_cam camSetDir _vTgt;
				
				_isZoom = (random 100) < (100 * RYD_NCAM_zoomCh);

				if (_isZoom) then
					{
					RYD_NCAM_FOV = if (((count _scrPos) > 1) and {(random _scrDst) < 0.25}) then
						{
						(((10 max ((sqrt RYD_NCAM_spdDst) * 2)) * (RYD_NCAM_diam/20)/_actDst) min 1 max 0.01)
						}
					else
						{
						((RYD_NCAM_cFOV + ((0.05 * RYD_NCAM_cFOV) max 0.025)) min 1 max 0.01)
						};
																	
					_diffFOV = abs (RYD_NCAM_FOV - RYD_NCAM_cFOV);
					//"debug" cutText [(format ["[_diffFOV]: %1",[_diffFOV]]),"PLAIN",0.1];	
					RYD_NCAM_aFOV = (RYD_NCAM_FOV - (random (0.5 * RYD_NCAM_zoomMpl * RYD_NCAM_FOV)) + (random (0.5 * RYD_NCAM_zoomMpl * RYD_NCAM_FOV))) max 0;
										
					if ((random _diffFOV) > 0.01) then
						{					
						RYD_NCAM_cam camPrepareFov RYD_NCAM_aFOV;
						
						RYD_NCAM_actFocus = _actDst/(1 + ((abs(RYD_NCAM_FOV - RYD_NCAM_aFOV)) * RYD_NCAM_focusMpl * 100));
						
						RYD_NCAM_cam camSetFocus [RYD_NCAM_actFocus, 5];
						//"debug" cutText [(format ["[1_focusAm]: %1",[abs (RYD_NCAM_actFocus - _actDst)]]),"PLAIN",0.1];

						_zoomTme = (sqrt(1 + _diffFOV))/3;
																
						RYD_NCAM_isZooming = (time + (_ivMpl max _zoomTme));
											
						RYD_NCAM_cam camCommit (_ivMpl max _zoomTme);
						
						RYD_NCAM_cFOV = RYD_NCAM_aFOV;
						};
						
					RYD_NCAM_dirTme = 0.4 + (random 0.2);
					_isFocus = (random 100) < (100 * RYD_NCAM_focusCh);
			
					if (_isFocus) then
						{
						RYD_NCAM_actFocus = RYD_NCAM_actFocus/(1 + ((abs(RYD_NCAM_FOV - RYD_NCAM_aFOV)) * RYD_NCAM_focusMpl * 100));														
						RYD_NCAM_cam camSetFocus [RYD_NCAM_actFocus, 5];
						//"debug" cutText [(format ["[_focusAm]: %1",[abs (RYD_NCAM_actFocus - _actDst)]]),"PLAIN",0.1];
						}
					};

				RYD_NCAM_cam camCommit (_ivMpl max RYD_NCAM_dirTme)
				};
			};
		
		RYD_NCAM_stoper = time - RYD_NCAM_int;
		
		//diag_log format ["t: %1",(diag_tickTime - _lt)];
		//"debug" cutText [(format ["[t]: %1",[(diag_tickTime - _lt)]]),"PLAIN",0.01];
		
		//sleep _ivMpl;
		
		//false
		};
		
	RYD_CAM_naturalEH = addMissionEventHandler ["EachFrame",RYD_CAM_NaturalCam_Loop];
	
	waitUntil
		{
		sleep 1;
		
		not (RYD_CAM_Active)
		};
	
	removeMissionEventHandler ["EachFrame",RYD_CAM_naturalEH];
	if (_del) then
		{
		RYD_NCAM_cam cameraEffect ["terminate", "BACK"];
		deleteVehicle RYD_NCAM_cam;
		}
	else
		{
		RYD_NCAM_cam camSetFocus [-1,-1];
		RYD_NCAM_cam camPrepareFOV 0.7;
		RYD_NCAM_cam camCommit 0.5;
		
		waitUntil
			{
			(camCommitted RYD_NCAM_cam)
			}
		};
		
	RYD_CAM_Ended = true;
	};
