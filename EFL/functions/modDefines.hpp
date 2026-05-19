
#define VALID_ARGS(el) if (isNil "_varname") exitWith {}; \
if (isNil STR(el)) exitWith {};

#define VALID_NAMESPACE if (isNil "_namespace") then {_namespace = missionNamespace};
