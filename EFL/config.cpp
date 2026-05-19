#include "includes\defines.hpp"

class CfgPatches {
	class PREFX {
		name = "Extended Functions Library";
		author = "Vazar";
		requiredAddons[] = {
			// "cba_common",
			"A3_Functions_F"
		};
		units[] = {};
		weapons[] = {};
        skipWhenMissingDependencies = 1;
	};
};

#include "includes\CfgFunctions.hpp"
#include "includes\cfgRemoteExec.hpp"
#include "includes\configIncludes.hpp"