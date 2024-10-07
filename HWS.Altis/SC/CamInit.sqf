if not (isNil "RYD_SCam_Exist") exitWith {};

RYD_SCam_Exist = true;
RydSC_Active = true;
RYD_Cam_SOff = false;
RydSC_Additional = false;
RYD_CAM_Active = false;
RydSC_ImmediateTrans = 100;

sleep 0.05;

if (isNil "RydSC_BLGroups") then {RydSC_BLGroups = []};
if (isNil "RydSC_Prior") then {RydSC_Prior = []};

if (isNil "RydSC_PPEffects") then {RydSC_PPEffects = true};
if (isNil "RydSC_Additional") then {RydSC_Additional = true};

if (isNil "RydSC_ViewSwitch") then {RydSC_ViewSwitch = true};

if (isNil "RydSC_TransHeight") then {RydSC_TransHeight = 3};
if (isNil "RydSC_ChangeTendMpl") then {RydSC_ChangeTendMpl = 1};

if (isNil "RydSC_ImmediateTrans") then {RydSC_ImmediateTrans = 0};

RYD_Cam_isAttached = false;

RYD_SCam_Observed = vehicle (leader (allGroups select (floor (random (count allGroups)))));

if (isNil "RydSC_InitPos") then 
	{
	_camPos = entities "RYD_SmartCam";
	if ((count _camPos) > 0) then
		{
		RydSC_InitPos = _camPos select (floor (random (count _camPos)))
		}
	else
		{
		RydSC_InitPos = RYD_SCam_Observed
		}
	};
	
_lvl = RydSC_InitPos getVariable ["RydSC_InitLevel",45];
_dir = RydSC_InitPos getVariable ["RydSC_InitDir",getDir RydSC_InitPos];

if not (isNil "RydSC_WaitForMe") then
	{
	waitUntil
		{
		sleep 0.1;
		
		(RydSC_WaitForMe)
		}
	};
	
TitleText ["","BLACK OUT", 0.1];

sleep 0.15;

_cam = "camera" camCreate [(getPosATL RydSC_InitPos) select 0,(getPosATL RydSC_InitPos) select 1, _lvl];

missionNameSpace setVariable ["RydSC_Camera",_cam];

if (RydSC_ViewSwitch) then
	{
	waitUntil 
		{
		not (isNull(findDisplay 46))
		};

	_eh = (findDisplay 46) displayAddEventHandler ["KeyDown", "nul = [] spawn RYD_CamSwitchOff;true"];
	missionNameSpace setVariable ["RYD_CSwitch_EH",_eh];
	};

_cam cameraEffect ["internal", "BACK"];

_cam camCommit 0;

_cam setDir _dir;

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

sleep 0.1;

if (RydSC_PPEffects) then
	{
	((missionNameSpace getVariable ["RYD_SCam_PPE",[]]) select 0) ppEffectEnable true;
	"FilmGrain" ppEffectEnable true;
	"chromAberration" ppEffectEnable true
	};
	
if ((dayTime < 6) or (dayTime > 20)) then
	{
	 camUseNVG true 
	}
else
	{
	 camUseNVG false 
	};

showCinemaBorder false;

TitleText ["","BLACK IN", 1];

sleep 2;

if (RydSC_Additional) then
	{
	RYD_CamFocus_handle = [_cam] spawn RYD_CAM_Focus;
	RYD_CamShake_handle = [] spawn {true}
	};

//RYD_CamAnch = "EmptyDetector" createVehicle (getPosATL RYD_SCam_Observed);

HGroups = AllGroups - RydSC_BLGroups;

[_cam] execVM "SC\ActionFinder.sqf";

