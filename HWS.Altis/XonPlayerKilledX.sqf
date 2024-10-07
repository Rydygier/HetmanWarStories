sleep 1;

RydSC_WaitForMe = nil;

TitleText ["","WHITE OUT", 3];

RYD_SCam_Exist = true;

if (isNil "RydSC_BLGroups") then {RydSC_BLGroups = []};
if (isNil "RydSC_Prior") then {RydSC_Prior = []};

if (isNil "RydSC_PPEffects") then {RydSC_PPEffects = true};
if (isNil "RydSC_Additional") then {RydSC_Additional = true};

if (isNil "RydSC_ViewSwitch") then {RydSC_ViewSwitch = true};

if (isNil "RydSC_TransHeight") then {RydSC_TransHeight = 3};
if (isNil "RydSC_ChangeTendMpl") then {RydSC_ChangeTendMpl = 1};

if (isNil "RydSC_ImmediateTrans") then {RydSC_ImmediateTrans = 0};

RydSC_Active = true;

RYD_Cam_isAttached = false;

sleep 5;

TitleText ["","WHITE IN", 3];

[] call compile preprocessFile "SC\CamManip.sqf";

_player = _this select 0;
_killer = _this select 1;

_cam = "camera" camCreate [(getPosATL _player) select 0,(getPosATL _player) select 1, 5];
_cam camSetTarget _player;

_cam cameraEffect ["internal", "BACK"];
_cam camCommit 0.5;

if (RydSC_PPEffects) then
	{
	_ppBlur = ppEffectCreate ["DynamicBlur", 1];
	_ppBlur ppEffectAdjust [0.08];

	_ppGrain = ppEffectCreate ["FilmGrain", 2];
	_ppGrain ppEffectAdjust [0.1, 2.05, 0.23, 0.11, 0, true];

	_ppChrom = ppEffectCreate ["chromAberration", 3];
	_ppChrom ppEffectAdjust [0.05,0.05,true];

	_ppGrain ppEffectCommit 0;
	_ppBlur ppEffectCommit 0;
	_ppChrom ppEffectCommit 0;
		
	missionNameSpace setVariable ["RYD_SCam_PPE",[_ppBlur,_ppGrain,_ppChrom]]
	};

missionNameSpace setVariable ["RYD_Cam_FOV",0.7];

showCinemaBorder false;

sleep 0.1;

if (RydSC_PPEffects) then
	{
	((missionNameSpace getVariable ["RYD_SCam_PPE",[]]) select 0) ppEffectEnable true;
	"FilmGrain" ppEffectEnable true;
	"chromAberration" ppEffectEnable true
	};

sleep 1.5;

_cam camSetTarget _killer;

_cam camCommit 3;

sleep 5;

RYD_SCam_Observed = (AllUnits + Vehicles) select (floor (random (count (AllUnits + Vehicles))));

RYD_CamAnch = "EmptyDetector" createVehicle (getPosATL RYD_SCam_Observed);

HGroups = AllGroups - RydSC_BLGroups;

if (RydSC_Additional) then
	{
	RYD_CamFocus_handle = [_cam] spawn RYD_CAM_Focus;
	RYD_CamShake_handle = [] spawn {true}
	};

[_cam] execVM "SmartCam\ActionFinder.sqf";

sleep 1;

TitleText ["PRESS ANY KEY TO EXIT","PLAIN DOWN", 3];

[] spawn RYD_EndMission;
