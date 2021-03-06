/*──────────────────────────────────────────────────────┐
│   Author: Connor                                      │
│   Steam:  https://steamcommunity.com/id/_connor       │
│   Github: https://github.com/ConnorAU                 │
│                                                       │
│   Please do not modify or remove this comment block   │
└──────────────────────────────────────────────────────*/

#define THIS_FUNC FUNC(log)

#include "_defines.inc"

#define VAL_ENABLE_LOG_VAR(n) format["%1_%2",QUOTE(VAR_ENABLE_LOGGING),n]

if !isServer exitWith {};

SWITCH_SYS_PARAMS;

switch _mode do {
	case "toggle":{
		// toggle entire logging system
		if (_params isEqualType true) exitWith {
			// broadcast variable to prevent remoteexec while logging is disabled
			missionNameSpace setVariable [QUOTE(VAR_ENABLE_LOGGING),_params,true];
			_params
		};

		// toggle individual channel
		if !(_params isEqualType 0) exitWith {false};
		private _variable = VAL_ENABLE_LOG_VAR(_params);
		private _value = missionNameSpace getVariable [_variable,true];
		if !(_value isEqualType true) then {_value = true;};
		_value = !_value;
		missionNameSpace setVariable [_variable,_value];
		_value
	};
	case "text":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]) exitWith {};
		_params params [
			["_channelID",-10,[0]],
			["_text","",[""]],
			["_name","",[""]],
			["_pid","",[""]]
		];
		if (_channelID < -2 || _channelID > 15) exitWith {};
		if !(missionNameSpace getVariable [VAL_ENABLE_LOG_VAR(_channelID),true]) exitWith {};

		private _channel = if (_channelID < 6) then {
			["ChannelName",_channelID] call FUNC(commonTask);
		} else {
			["get",[_channelID - 5,1]] call FUNC(radioChannelCustom);
		};
		private _log = if (_channelID == -1) then {
			// system channel, no message author
			_text
		} else {
			format[
				(["(%3) ",""] select (_pid == "")) + "%1: %2",
				_name,_text,_pid
			];
		};

		// text _log so it dequotes the log string
		"ExtendedChat" callExtension [format["%1 %2",_channelID,_channel],[text _log]];
	};
	case "voice":{
		if !(missionNameSpace getVariable [QUOTE(VAR_ENABLE_LOGGING),false]) exitWith {};
		_params params [
			["_active",true,[true]],
			["_channelID",-10,[0]],
			["_name","",[""]],
			["_pid","",[""]]
		];

		// dont log channels like system as it cant be spoken into
		if (_channelID < 0 || _channelID > 15) exitWith {};
		if !(missionNameSpace getVariable [VAL_ENABLE_LOG_VAR(_channelID),true]) exitWith {};

		private _channel = if (_channelID < 6) then {
			["ChannelName",_channelID] call FUNC(commonTask);
		} else {
			["get",[_channelID - 5,1]] call FUNC(radioChannelCustom);
		};
		private _log = format[
			"(%1) %2 %4 speaking in %3",
			_pid,_name,_channel,
			["stopped","started"] select _active				
		];

		// text _log so it dequotes the log string
		"ExtendedChat" callExtension [format["%1 %2 VON",_channelID,_channel],[text _log]];
	};
};