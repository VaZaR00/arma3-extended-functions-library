#ifdef FINAL
{
	_x params ["_funcVar", "_funcName"];
	private _compiled = COMPILE_C (call COMPILE_C _funcVar);
	missionNamespace setVariable [_funcName, _compiled];
	uiNamespace setVariable [_funcName, _compiled];
} forEach _cFuncs;
#endif