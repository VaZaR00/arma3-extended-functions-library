#include "defines.hpp"

// #define LOG_CBA_EVENT [_NIL(_eventName), time, _NIL(_this), clientOwner] RLOG
#define LOG_CBA_EVENT 

#define WRAP_FUNC(f) {LOG_CBA_EVENT; _this call f}

[SPREF(pushBack), WRAP_FUNC(FUNC(pushBack))] call CBA_fnc_addEventHandler;
[SPREF(hashSet), WRAP_FUNC(FUNC(hashSet))] call CBA_fnc_addEventHandler;
[SPREF(removeFromArray), WRAP_FUNC(FUNC(removeFromArray))] call CBA_fnc_addEventHandler;
[SPREF(deleteAt), WRAP_FUNC(FUNC(deleteAt))] call CBA_fnc_addEventHandler;
[SPREF(setVariable), WRAP_FUNC(FUNC(setVariable))] call CBA_fnc_addEventHandler;