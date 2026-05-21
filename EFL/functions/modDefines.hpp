
#define VALID_VARNAME if (isNil "_varname") exitWith {};

#define VALID_ARGS(el) VALID_VARNAME; if (isNil STR(el)) exitWith {};

#define VALID_NAMESPACE if (isNil "_namespace") then {_namespace = missionNamespace};
