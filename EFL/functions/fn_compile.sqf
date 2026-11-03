#include "defines.hpp" 

#ifndef FINAL
#define CFUNC(f) FUNC(f)
#endif

//-------------- DIAG ---------------
CFUNC(diagRemoteExec) = {
    [[serverTime, [_func, _targets, _jip], _NIL(_args), [IF_NIL(_fnc_scriptName, __FILE_NAME__), IF_NIL(_fnc_scriptNameParent, __FILE_NAME__)], [_NIL(_className), _NIL(_methodName)]], { 
        params["_senderTime", "_rmtParams", ["_args", nil], ["_callFileName", nil], ["_classData", nil]];
        _args = if !(isNil "_args") then {
            if !(_args isEqualType []) then {_args = [_args]};
            private _procArgs = {
                if (_this isEqualType []) exitWith {
                    _this apply {
                        _x call _procArgs;
                    };
                };
                if (_this isEqualType {}) then {(format["{%1}", (str _this) select [0, 30]])} else {_this};
            };
            _args apply {_x call _procArgs};
        } else {nil};

        (IF_NIL(_callFileName, [])) params [["_funcName", ""], ["_parentFuncName", ""]];

        private _funcNames = format["[THIS_FUNC: '%1', PARENT_FUNC: '%2']", _funcName, _parentFuncName];

        private _data = format["REMOTE EXECUTED CODE :: FUNCS: %1 | CLASS: %2 | TIME: %3 | REMOTE_EXEC PARAMS: %4 | ARGS: %5", 
            _funcNames, 
            _NIL(_classData), 
            [serverTime, _senderTime, serverTime - _senderTime], 
            _rmtParams, 
            _NIL(_args)
        ];
        
        private _logVarName = (IF_NIL(_ADDON_PREFX, "TTT")) + '_remoteExec_logCounter';
        private _log = MGVAR [_logVarName, []];
        _log pushBack _data;
        MSVAR [_logVarName, _log];
        _data DLOG
    }] remoteExecCall [CALL_FUNC, _targets, _jip];
};
//-----------------------------------

//-------------- CORE ---------------
CFUNC(pushBackNet) = {
    params["_namespace", "_varname", "_element", ["_unique", true], ["_callEH", true], ["_target", true], ["_jip", true]];

    VALID_ARGS(_element)

    [SPREF(pushBack), _this, _target, _jip] call FUNC(remoteEvent);
};

CFUNC(pushBack) = {
    params["_namespace", "_varname", "_element", ["_unique", true], ["_callEH", true]];

    VALID_NAMESPACE

    private _array = _namespace getVariable [_varname, []];
    if (_unique) then {
        _array pushBackUnique _element;
    } else {
        _array pushBack _element;
    };
    _namespace setVariable [_varname, _array];
    [_varname, _callEH] call FUNC(callVariableEH);
};

CFUNC(hashSetNet) = {
    params["_namespace", "_varname", "_key", "_value", ["_callEH", true], ["_target", true], ["_jip", true]];

    VALID_ARGS(_key)

    [SPREF(hashSet), _this, _target, _jip] call FUNC(remoteEvent);
};

CFUNC(hashSet) = {
    params["_namespace", "_varname", "_key", "_value", ["_callEH", true]];

    VALID_NAMESPACE

    private _hash = _namespace getVariable [_varname, createHashMap];
    _hash set [_key, _NIL(_value)];
    _namespace setVariable [_varname, _hash];
    [_varname, _callEH] call FUNC(callVariableEH);
};

CFUNC(removeFromArrayNet) = {
    params["_namespace", "_varname", "_elements", ["_pop", false], ["_callEH", true], ["_target", true], ["_jip", true]];

    VALID_ARGS(_elements)

    [SPREF(removeFromArray), _this, _target, _jip] call FUNC(remoteEvent);
};

CFUNC(removeFromArray) = {
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
    [_varname, _callEH] call FUNC(callVariableEH);
};

CFUNC(deleteAtNet) = {
    params["_namespace", "_varname", "_key", ["_callEH", true], ["_target", true], ["_jip", true]];

    VALID_ARGS(_key)
    
    [SPREF(deleteAt), _this, _target, _jip] call FUNC(remoteEvent);
};

CFUNC(deleteAt) = {
    params["_namespace", "_varname", "_key", ["_callEH", true]];

    VALID_NAMESPACE

    private _map = _namespace getVariable _varname;
    if (isNil "_map") exitWith {};
    _map deleteAt _key;
    _namespace setVariable [_varname, _map];
    [_varname, _callEH] call FUNC(callVariableEH);
};

CFUNC(remoteExec) = {
    params[["_args", nil], ["_func", CALL_FUNC], ["_targets", 0], ["_jip", false], ["_call", false, [false]], ["_selfLocalCall", true]];

	private _isCall = _call isEqualTo true;

    if (_func isEqualType {}) then {
        _args = [_NIL(_args), _func];
        _func = if (_isCall) then {CALL_FUNC} else {SPAWN_FUNC};
    };

    if !(_func isEqualType "") exitWith {format["FUNC(remoteExec ERROR: func not str or code. Func type: %1. Func value: %2", typeName _func, _func] WARN};

    private _isCallCommand = _func in [CALL_FUNC, SPAWN_FUNC];

    if (_targets isEqualType true) then {
        if (_targets isEqualTo true) then {
            _targets = 0;
        } else {
            _targets = false;
        };
    };
    // jip
    private _jipObjUseStr = false;
    if (_jip isEqualType []) then {
        _jipObjUseStr = true;
        _jip = param [0, false];
    };
    if (_jipObjUseStr && {_jip isEqualType objNull}) then {
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

    #define RMT_EXEC_DIAG_LOG 
    #ifdef DIAG_NET
        #define RMT_EXEC_DIAG_LOG 0 call FUNC(diagRemoteExec);
    #endif

    #define RMT_RMT_EXEC { \
        RMT_EXEC_DIAG_LOG \
        if (isNil "_args") then { \
            if (_isCall) then { \
                remoteExecCall [_func, _targets, _jip]; \
            } else { \
                remoteExec [_func, _targets, _jip]; \
            }; \
        } else { \
            if (_isCall) then { \
                _args remoteExecCall [_func, _targets, _jip]; \
            } else { \
                _args remoteExec [_func, _targets, _jip]; \
            }; \
        }; \
    }; \

    #define RMT_TYPE_CALL { \
        if (_isCall) exitWith { \
            isNil{IF_NIL(_args, []) call _this} \
        }; \
        if (_func isEqualTo SPAWN_FUNC) exitWith { \
            IF_NIL(_args, []) spawn _this \
        }; \
        IF_NIL(_args, []) call _this; \
    }; \

    #define RMT_LOCAL_CALL { \
        if (_isCallCommand) exitWith { \
            if (isNil "_args") then { \
                _args = []; \
            }; \
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
            format["FUNC(remoteExec ERROR: func '%1' not found!", _func] WARN; \
            call RMT_RMT_EXEC; \
        }; \
        _function call RMT_TYPE_CALL; \
    }; \

    if (!isMultiplayer || {
        (_targets in [PLAYER_, false, clientOwner]) || {
            (_targets isEqualType objNull) && {
                local _targets
            }
        }
    }) exitWith {call RMT_LOCAL_CALL};

	private _selfCallRes = if ((IF_NIL(_selfLocalCall, false)) isNotEqualTo false) then {
        private _hasPlayer = !(isNull player);
		if (_targets isEqualTo 0) exitWith {
            call RMT_LOCAL_CALL;
            _targets = -clientOwner;
        };
		if (_targets isEqualType west) exitWith {
            if (_hasPlayer) exitWith {};
            private _side = side player;
            if (_side isNotEqualTo _targets) exitWith {};
            _targets = allPlayers select {(side _x) isEqualTo _side};
            _targets = _targets - [player];
            call RMT_LOCAL_CALL;
        };
        if (_targets isEqualType []) exitWith {
            private _localObjects = _targets select {IS_OBJ(_x) && {local _x}};
            private _hasSelfSide = _hasPlayer && {(side player) in _targets};
            private _hasSelfGroup = _hasPlayer && {(group player) in _targets};
            private _hasSelfClient = clientOwner in _targets;
            if ((_localObjects isEqualTo []) && {!(_hasSelfClient) && !(_hasSelfSide) && !(_hasSelfGroup)}) exitWith {};
            // objects and client id 
            _targets = (_targets - _localObjects) - [clientOwner];
            // sides
            private _sides = _targets select {_x isEqualType west};
            if (_sides isNotEqualTo []) then {
                private _sideTargets = [];
                {
                    private _side = _x;
                    _sideTargets append (allPlayers select {(side _x) isEqualTo _side});
                } forEach _sides;
                _targets = ((_targets - _sides) + _sideTargets) - [player];
            };
            // groups
            private _groups = _targets select {_x isEqualType grpNull};
            if (_groups isNotEqualTo []) then {
                private _groupTargets = [];
                {
                    private _group = _x;
                    _groupTargets append (allPlayers select {(group _x) isEqualTo _group});
                } forEach _groups;
                _targets = ((_targets - _groups) + _groupTargets) - [player];
            };
            // var names
            private _varNames = _targets select {_x isEqualType ""};
            if (_varNames isNotEqualTo []) then {
                private ["_obj"];
                private _varNameTargets = _varNames apply {
                    _obj = missionNamespace getVariable _x;
                    if (isNil "_obj") then {_x} else {_obj};
                };
                _varNameTargets = _varNameTargets select {(_x isEqualType "") || {!(local _x)}};
                _varNameTargets = _varNameTargets - [objNull];
                _targets = _targets - _varNameTargets;
            };
            call RMT_LOCAL_CALL;
        };
        _selfLocalCall = false;
        nil
	} else {nil};

    private _remoteCallRes = call RMT_RMT_EXEC;

    if (_selfLocalCall isEqualTo true) exitWith {_NIL(_selfCallRes)};
    if (_selfLocalCall isEqualTo 0) exitWith {_NIL(_remoteCallRes)};
    if (_selfLocalCall isEqualTo 1) exitWith {[_NIL(_remoteCallRes), _NIL(_selfCallRes)]};

    _NIL(_remoteCallRes)
};

CFUNC(remoteEvent) = {
    params["_eventName", ["_args", []], ["_target", false], ["_jip", false]];

    if (_target in [false, clientOwner]) exitWith {
        [_eventName, _args] call CBA_fnc_localEvent;
    };
    if (_target isEqualTo 2) exitWith {
        [_eventName, _args] call CBA_fnc_serverEvent;
    };
    if (_target isEqualTo true) exitWith {
        if !(_jip isEqualTypeAny ["", objNull]) then {
            _jip = "";
        };
        [_eventName, _args, _NIL(_jip)] call CBA_fnc_globalEventJIP;
    };
    if (_target isEqualTo 0) exitWith {
        [_eventName, _args] call CBA_fnc_globalEvent;
    };
    if (_target isEqualType 1) exitWith {
        [_eventName, _args, _target] call CBA_fnc_ownerEvent;
    };
    if (_target isEqualType objNull) exitWith {
        [_eventName, _args, _target] call CBA_fnc_targetEvent;
    };
    if (_target isEqualType []) exitWith {
        {
            [_eventName, _args, _x] call FUNC(remoteEvent);
        } forEach _target;
    };
    [_eventName, _args] call CBA_fnc_localEvent;
};

CFUNC(callVariableEH) = {
    params[["_varName", ""], ["_callParams", true]];
    _callParams params[["_doCall", true], ["_args", []], ["_ehFuncName", ""]];
    
    if !(_doCall isEqualTo true) exitWith {};

    _ehFuncName params [["_suffix", ""], ["_isFullName", false]];

    private _ehFuncName = "";
    if (_suffix isEqualTo "") then {
        _suffix = missionNamespace getVariable [SPREF(variablesEHsuffix), "_publicEH"];
        _isFullName = false;
    };
    if (_isFullName) then {
        _ehFuncName = _suffix;
    } else {
        _ehFuncName = _varName + _suffix;
    };

    _args call (missionNamespace getVariable [_ehFuncName, {}]);
};

CFUNC(publicVariable) = {
    private _namespace = _this param [0, nil];
    if (!(isNil "_namespace") && {_namespace isEqualType ""}) then {
        _this = [missionNamespace] + (if (_this isEqualType []) then {_this} else {[_this]});
    };

    params["_namespace", "_varname", ["_callEH", true], ["_target", true], ["_jip", nil]];

    VALID_VARNAME

    _jip = if (isNil "_jip") then {_target isEqualTo true} else {false};
    [SPREF(setVariable), [_NIL(_namespace), _varname, (missionNamespace getVariable _varname), _callEH], _target, _jip] call FUNC(remoteEvent);
};

CFUNC(setVariable) = {
    params["_namespace", "_varname", "_value", ["_callEH", true]];

    VALID_NAMESPACE
    
    _namespace setVariable [_varname, _NIL(_value)];
    [_varname, _callEH] call FUNC(callVariableEH);
};
//-----------------------------------


//-------------- WRAPPERS ---------------
CFUNC(pushBackGlobal) = {
    params["_namespace", "_varname", "_element", ["_unique", true], ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _NIL(_element), _unique, _callEH, true, true] call FUNC(pushBackNet);
};

CFUNC(hashSetGlobal) = {
    params["_namespace", "_varname", "_key", "_value", ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _NIL(_key), _NIL(_value), _callEH, true, true] call FUNC(hashSetNet);
};

CFUNC(removeFromArrayGlobal) = {
    params["_namespace", "_varname", "_elements", ["_pop", false], ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _NIL(_elements), _pop, _callEH, true, true] call FUNC(removeFromArrayNet);
};

CFUNC(deleteAtGlobal) = {
    params["_namespace", "_varname", "_key", ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _NIL(_key), _callEH, true, true] call FUNC(deleteAtNet);
};

CFUNC(publicVariableServer) = {
    params["_namespace", "_varname", ["_callEH", true]];

    [_NIL(_namespace), _NIL(_varname), _callEH, 2, false] call FUNC(publicVariable);
};
//-----------------------------------