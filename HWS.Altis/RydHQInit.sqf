
if (isNil ("RydHQ_Wait")) then {RydHQ_Wait = 15};

sleep RydHQ_Wait;

waituntil {sleep 1;not (isNil ("leaderHQ"))};

_hi = "HAL 1.161 is here";

if ((random 100) < 1) then {_hi = "Good morning, Dave."};

//leaderHQ globalchat _hi;

//publicVariable "RYD_MP_Sidechat";

if (RydHQ_RHQCheck) then {[] call RYD_RHQCheck};

if (RydHQ_TimeM) then 
	{
	[([player] + (switchableUnits - [player]))] call RYD_TimeMachine
	};
	
if (RydBB_Active) then 
	{
	call compile preprocessfile (RYD_Path + "Boss_fnc.sqf");
	RydBBa_InitDone = false;
	RydBBb_InitDone = false;

		{
		if ((count (_x select 0)) > 0) then 
			{
			if ((_x select 1) == "A") then {RydBBa_Init = false};
			_BBHQs = _x select 0;
			_BBHQGrps = [];

				{
				_BBHQGrps set [(count _BBHQGrps),(group _x)]
				}
			foreach _BBHQs;

				{
				_x setVariable ["BBProgress",0]
				}
			foreach _BBHQGrps;
			[[_x,_BBHQGrps],Boss] call RYD_Spawn
			};

		sleep 1;
		}
	foreach [[RydBBa_HQs,"A"],[RydBBb_HQs,"B"]];
	};

if (((RydHQ_Debug) or (RydHQB_Debug) or (RydHQC_Debug) or (RydHQD_Debug) or (RydHQE_Debug) or (RydHQF_Debug) or (RydHQG_Debug) or (RydHQH_Debug)) and (RydHQ_DbgMon)) then {[[],RYD_DbgMon] call RYD_Spawn};

if not (isNull leaderHQ) then {[[(group leaderHQ)],A_HQSitRep] call RYD_Spawn;sleep 5};
if not (isNull leaderHQB) then {[[(group leaderHQB)],B_HQSitRep] call RYD_Spawn;sleep 5};
if not (isNull leaderHQC) then {[[(group leaderHQC)],C_HQSitRep] call RYD_Spawn;sleep 5};
if not (isNull leaderHQD) then {[[(group leaderHQD)],D_HQSitRep] call RYD_Spawn;sleep 5};
if not (isNull leaderHQE) then {[[(group leaderHQE)],E_HQSitRep] call RYD_Spawn;sleep 5};
if not (isNull leaderHQF) then {[[(group leaderHQF)],F_HQSitRep] call RYD_Spawn;sleep 5};
if not (isNull leaderHQG) then {[[(group leaderHQG)],G_HQSitRep] call RYD_Spawn;sleep 5};
if not (isNull leaderHQH) then {[[(group leaderHQH)],H_HQSitRep] call RYD_Spawn;sleep 5};

if ((count RydHQ_GroupMarks) > 0) then
	{
	[RydHQ_GroupMarks,RYD_GroupMarkerLoop] call RYD_Spawn
	};
