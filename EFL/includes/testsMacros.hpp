
// Test remoteExecs frequency
#define RMT_DLOG DLOG
#define TEST_REMOTE_EXEC(prefix) { \
    if (isNil 'prefix##_remoteExec_logCounter') then { \
        prefix##_remoteExec_logCounter = []; \
    }; \
    private _data = [diag_tickTime, __FILE_NAME__, [_NIL(_className), _NIL(_methodName)], _NIL(_this)]; \
    _data RMT_DLOG; \
    prefix##_remoteExec_logCounter pushbackunique _data; \
    _this call prefix##_fnc_remoteexec; \
}
#define CFM_fnc_remoteExec TEST_REMOTE_EXEC(CFM)
#define OOP_fnc_remoteExec TEST_REMOTE_EXEC(OOP)