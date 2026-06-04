#include "defines.hpp"

#define DO_LOG_CBA_EVENTS

#ifdef DO_LOG_CBA_EVENTS
	#define LOG_CBA_EVENT [_NIL(_eventName), time, _NIL(_this), clientOwner] RLOG
#endif

#define WRAP_FUNC(f) {LOG_CBA_EVENT; _this call f}

["EFL_pushBack", WRAP_FUNC(EFL_fnc_pushBack)] call CBA_fnc_addEventHandler;
["EFL_hashSet", WRAP_FUNC(EFL_fnc_hashSet)] call CBA_fnc_addEventHandler;
["EFL_removeFromArray", WRAP_FUNC(EFL_fnc_removeFromArray)] call CBA_fnc_addEventHandler;
["EFL_deleteAt", WRAP_FUNC(EFL_fnc_deleteAt)] call CBA_fnc_addEventHandler;
["EFL_setVariable", WRAP_FUNC(EFL_fnc_setVariable)] call CBA_fnc_addEventHandler;