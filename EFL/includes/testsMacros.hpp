
// Test remoteExecs frequency
#define RMT_DLOG DLOG
#define TEST_REMOTE_EXEC(prefix) { \
    if (isNil 'prefix##_remoteExec_logCounter') then { \
        prefix##_remoteExec_logCounter = []; \
    }; \
    params[["_args", nil], ["_func", "call"], ["_targets", 0], ["_jip", false], ["_call", false, [false]], ["_selfLocalCall", true]]; \
    private _data = [diag_tickTime, [_NIL(_fnc_scriptName), _NIL(_fnc_scriptNameParent)], [_NIL(_className), _NIL(_methodName)], [_NIL(_args), _NIL(_func), _NIL(_targets), _NIL(_jip), _NIL(_call), _NIL(_selfLocalCall)]]; \
    _data RMT_DLOG; \
    prefix##_remoteExec_logCounter pushbackunique _data; \
    _this call prefix##_fnc_remoteexec; \
}
// #define CFM_fnc_remoteExec TEST_REMOTE_EXEC(CFM)
// #define OOP_fnc_remoteExec TEST_REMOTE_EXEC(OOP)