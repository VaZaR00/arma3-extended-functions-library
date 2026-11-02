#ifdef FINAL
{
	_x params ["_funcVar", "_funcName"];
	missionNamespace setVariable [_funcName, COMPILE_C (str (call COMPILE_C _funcVar))];
} forEach _cFuncs;
#endif