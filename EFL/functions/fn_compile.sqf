#include "defines.hpp" 


//-------------- CORE ---------------
EFL_fnc_pushBackNet = {
    params["_namespace", "_varname", "_element", ["_unique", true], ["_callEH", true], ["_target", true], ["_jip", true]];

    VALID_ARGS(_element)

	[_this, {
    	params["_namespace", "_varname", "_element", ["_unique", true], ["_callEH", true]];

        VALID_NAMESPACE
    
		private _array = _namespace getVariable [_varname, []];
		if (_unique) then {
			_array pushBackUnique _element;
		} else {
			_array pushBack _element;
		};
		_namespace setVariable [_varname, _array];
        [_varname, _callEH] call EFL_fnc_callVariableEH;
	}, _target, _jip, true, false] call EFL_fnc_remoteExec;
};

EFL_fnc_hashSetNet = {
    params["_namespace", "_varname", "_key", "_value", ["_callEH", true], ["_target", true], ["_jip", true]];

    VALID_ARGS(_key)

    if (isNil '_key') exitWith {};

	[_this, {
    	params["_namespace", "_varname", "_key", "_value", ["_callEH", true]];

        VALID_NAMESPACE
    
		private _hash = _namespace getVariable [_varname, createHashMap];
		_hash set [_key, _NIL(_value)];
		_namespace setVariable [_varname, _hash];
        [_varname, _callEH] call EFL_fnc_callVariableEH;
	}, _target, _jip, true, false] call EFL_fnc_remoteExec;
};

EFL_fnc_removeFromArrayNet = {
    params["_namespace", "_varname", "_elements", ["_pop", false], ["_callEH", true], ["_target", true], ["_jip", true]];

    VALID_ARGS(_elements)

	[_this, {
    	params["_namespace", "_varname", "_elements", ["_pop", false], ["_callEH", true]];

        VALID_NAMESPACE
            
        if !(_elements isEqualType []) then {
            _elements = [_elements];
        };
    
		private _array = _namespace getVariable [_varname, []];
		if (_pop) then {
            // delete last element
			{
                if (_x in _elements) exitWith {
                    _array deleteAt _forEachIndex;
                };
            } forEachReversed _array;
		} else {
			_array = _array - _elements;
		};
		_namespace setVariable [_varname, _array];
        [_varname, _callEH] call EFL_fnc_callVariableEH;
	}, _target, _jip, true, false] call EFL_fnc_remoteExec;
};

EFL_fnc_deleteAtNet = {
    params["_namespace", "_varname", "_key", ["_callEH", true], ["_target", true], ["_jip", true]];

    VALID_ARGS(_key)
    
	[_this, {
    	params["_namespace", "_varname", "_key", ["_callEH", true]];

        VALID_NAMESPACE
    
		private _map = _namespace getVariable [_varname, []];
		_map deleteAt _key;
		_namespace setVariable [_varname, _map];
        [_varname, _callEH] call EFL_fnc_callVariableEH;
	}, _target, _jip, true, false] call EFL_fnc_remoteExec;
};

EFL_fnc_remoteExec = {
    params[["_args", []], ["_func", "call"], ["_targets", 0], ["_jip", false], ["_call", false, [false]], ["_remoteSelfCall", true]];

	private _isCall = _call isEqualTo true;

    if (_func isEqualType {}) then {
        _args = [_args, _func];
        _func = if (_isCall) then {"call"} else {"spawn"};
    };

    if !(_func isEqualType "") exitWith {format["EFL_fnc_remoteExec ERROR: func not str or code. Func type: %1. Func value: %2", typeName _func, _func] WARN};

    private _isCallCommand = _func in ["call", "spawn"];

    if (_targets isEqualType true) then {
        if (_targets isEqualTo true) then {
            _targets = 0;
        } else {
            _targets = false;
        };
    };
    if (_jip isEqualType objNull) then {
        private _netid = netId _jip;
        private _idArr = (_netid splitString ":");
        private _id = "0";
        if (count _idArr > 1) then {
            _id = trim (_idArr#1);
            if !(_id isEqualType "") then {
                _id = str _id;
            };
        };
        _jip = VAR_PREFIX + "_jip_remote_exec_id_" + _id;
    };

    #define RMT_RMT_EXEC { \
        if (_isCall) then { \
            _args remoteExecCall [_func, _targets, _jip]; \
        } else { \
            _args remoteExec [_func, _targets, _jip]; \
        }; \
    }; \

    #define RMT_TYPE_CALL { \
        if (_isCall) exitWith { \
            isNil{_args call _this} \
        }; \
        if (_func isEqualTo "spawn") exitWith { \
            _args spawn _this \
        }; \
        _args call _this; \
    }; \

    #define RMT_LOCAL_CALL { \
        private _args = _this; \
        if (_isCallCommand) exitWith { \
            if !(_args isEqualType []) then { \
                _args = [_args]; \
            }; \
            if (count _args == 1) then { \
                _args = [[], _args#0]; \
            }; \
            _args params [["_args", []], ["_argFunc", {}]]; \
            _argFunc call RMT_TYPE_CALL; \
        }; \
        private _function = missionNamespace getVariable _func; \
        if (isNil "_function") exitWith { \
            format["EFL_fnc_remoteExec ERROR: func '%1' not found!", _func] WARN; \
            call RMT_RMT_EXEC; \
        }; \
        _function call RMT_TYPE_CALL; \
    }; \

    if (!isMultiplayer || {(_targets in [PLAYER_, false, clientOwner])}) exitWith {_args call RMT_LOCAL_CALL};

	if !(_remoteSelfCall) then {
		private _selfArgs = if ((_args isEqualType []) || {(_args isEqualType createHashMap)}) then {+_args} else {_args};
		_selfArgs call RMT_LOCAL_CALL;
        if !(_isCallCommand) then {
            _args = [_args, _func];
        };
		private _funcRmt = {
            params["_args", "_clientCaller", ["_isCallCommand", false]];
            if (_clientCaller isEqualTo clientOwner) exitWith {}; 
            _args call RMT_LOCAL_CALL;
        };
		_args = [[_args, clientOwner, _isCallCommand], _funcRmt];
        _func = if (_isCall) then {"call"} else {"spawn"};
	};

    call RMT_RMT_EXEC;
};

EFL_fnc_callVariableEH = {
    params[["_varName", ""], ["_callParams", true]];
    _callParams params[["_doCall", true], ["_args", []], ["_ehFuncName", ""]];
    
    if !(_doCall isEqualTo true) exitWith {};

    _ehFuncName params [["_suffix", ""], ["_isFullName", false]];

    private _ehFuncName = "";
    if (_suffix isEqualTo "") then {
        _suffix = missionNamespace getVariable ["EFL_variablesEHsuffix", "_publicEH"];
        _isFullName = false;
    };
    if (_isFullName) then {
        _ehFuncName = _suffix;
    } else {
        _ehFuncName = _varName + _suffix;
    };

    _args call (missionNamespace getVariable [_ehFuncName, {}]);
};

EFL_fnc_publicVariable = {
    private _namespace = _this param [0, nil];
    if (!(isNil "_namespace") && {_namespace isEqualType ""}) then {
        _this = [missionNamespace] + (if (_this isEqualType []) then {_this} else {[_this]});
    };

    params["_namespace", "_varname", ["_callEH", true], ["_target", true], ["_jip", nil]];

    VALID_VARNAME

	[[_NIL(_namespace), _varname, (missionNamespace getVariable _varname), _callEH], {
        params["_namespace", "_varname", "_value", ["_callEH", true]];

        VALID_NAMESPACE
		
        _namespace setVariable [_varname, _NIL(_value)];
        [_varname, _callEH] call EFL_fnc_callVariableEH;
	}, _target, if (isNil "_jip") then {_target isEqualTo true} else {false}, true, false] call EFL_fnc_remoteExec;
};
//-----------------------------------


//-------------- WRAPPERS ---------------
EFL_fnc_pushBackGlobal = {
    params["_namespace", "_varname", "_element", ["_unique", true], ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _NIL(_element), _unique, _callEH, true, true] call EFL_fnc_pushBackNet;
};

EFL_fnc_hashSetGlobal = {
    params["_namespace", "_varname", "_key", "_value", ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _NIL(_key), _NIL(_value), _callEH, true, true] call EFL_fnc_hashSetNet;
};

EFL_fnc_removeFromArrayGlobal = {
    params["_namespace", "_varname", "_elements", ["_pop", false], ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _NIL(_elements), _pop, _callEH, true, true] call EFL_fnc_removeFromArrayNet;
};

EFL_fnc_deleteAtGlobal = {
    params["_namespace", "_varname", "_key", ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _NIL(_key), _callEH, true, true] call EFL_fnc_deleteAtNet;
};

EFL_fnc_publicVariableServer = {
    params["_namespace", "_varname", ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _callEH, 2, false] call EFL_fnc_publicVariable;
};
//-----------------------------------