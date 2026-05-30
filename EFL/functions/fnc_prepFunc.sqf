
#define FOLDER_PATH(path) _path = STR(path);
#define PREP(name) [STR(name), _path] call _compileFunc;

private _compileFunc = {
	params["_name", ["_folderPath", ""]];

	if (_folderPath != "") then {
		_folderPath = _folderPath + "\";
	};
	private _funcName = SFUNC_NAME(_name);
	private _funcPath = format["%1\%2fn_%3.sqf", STR(ADDON_PATH), _folderPath, _name];
	private _scriptStr = preprocessFileLineNumbers _funcPath;
	private _funcStr = format["private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'%1'} else {_fnc_scriptName};
	private _fnc_scriptName = '%1';
	scriptName _fnc_scriptName; %2", _funcName, _scriptStr];

#ifdef FINAL
	missionNamespace setVariable [_funcName, compileFinal _funcStr];
#endif
#ifndef FINAL
	missionNamespace setVariable [_funcName, compile _funcStr];
#endif
};

#ifdef DEV
FUNC(compileFunc) = _compileFunc;
#endif