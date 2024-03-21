// stdafx.h : include file for standard system include files,
// or project specific include files that are used frequently, but
// are changed infrequently
//

#pragma once

#ifdef _WINDOWS
	#include "targetver.h"
	
	#define WIN32_LEAN_AND_MEAN // Exclude rarely-used stuff from Windows headers
	#include <windows.h>
#endif

#define trace(...) { printf("[GmxGenTest:%d] ", __LINE__); printf(__VA_ARGS__); printf("\n"); fflush(stdout); }

#include "gml_ext.h"

// TODO: reference additional headers your program requires here