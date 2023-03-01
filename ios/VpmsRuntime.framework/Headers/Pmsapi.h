/*
 * Copyright (c) 1997-2010, CSC Technologies Deutschland GmbH
 * All rights reserved.
 * Unauthorized use of this software in any way or form whatsoever,
 * be it directly or indirectly, in whole or in part, modified or processed
 * is prohibited.
 */


#ifndef PMSAPI_H
#define PMSAPI_H

#ifdef XERT_PLATFORM_UWP
#ifdef UNICODE // MW240117 wegen UNICODE unter UWP
#undef UNICODE
#endif
#ifdef _UNICODE
#undef _UNICODE
#endif
#endif

// TODO TIDY UP THESE import/export DEFINITIONS

#define XERT_USE_DEF_FILE_EXPORT_ON_WINDOWS 1

#if defined(_MSC_VER)
	// VC++
#	if defined(XERT_USE_DEF_FILE_EXPORT_ON_WINDOWS)
#		define XERT_LIB_EXPORT(tp) tp __stdcall
#	else
#		define XERT_LIB_EXPORT(tp)  __declspec(dllexport) tp __stdcall
#	endif
	
	
#elif defined(XERT_USE_PLATFORM_WIN32)
	// other Win32
#	if defined(XERT_USE_DEF_FILE_EXPORT_ON_WINDOWS)
#		define XERT_LIB_EXPORT(tp) tp __stdcall
#	else
#		define XERT_LIB_EXPORT(tp)  __declspec(dllexport) tp __stdcall
#	endif

#elif defined(__MVS__)
	// MVS / z/OS
	#define XERT_LIB_EXPORT(tp)  tp _Export
#else /* default */
	#define XERT_LIB_EXPORT(tp) tp
#endif /* _MFC_VER */


#ifndef WINAPI
 #ifdef __OS2__
  #define WINAPI _System
 #else
  #define WINAPI
 #endif
 #ifdef WIN32
  #define FAR
 #else
  #ifdef _Windows
   #define FAR far
  #else
   #define FAR
  #endif
 #endif

/*
 * On Linux, sqltypes.h contains typedefs for LPSTR, etc.
 * Those typedefs conflict with the #defines in this file.
 * If sqltypes.h is included after this file, then a
 * syntax error occurs. For example, the macros here
 * would cause the sqltypes.h line:
 *  typedef WCHAR*                    LPWSTR;
 * to be compiled as the syntactically invalid line:
 *  typedef short*                    short *;
 */

// #define LPSTR char FAR *
// #define LPCSTR const LPSTR
// #define LPWSTR short FAR *
// #define LPCWSTR const LPWSTR

typedef unsigned short WCHAR;
typedef char TCHAR;
typedef WCHAR*                    LPWSTR;
typedef const WCHAR*                    LPCWSTR;
typedef const char*         LPCSTR;
typedef TCHAR*              LPTSTR;
typedef char*               LPSTR;

 #define FALSE 0
 #define TRUE 1
 #define BOOL int
#endif

#ifdef __cplusplus
extern "C" {
#endif
XERT_LIB_EXPORT(int) closesession(int session);
XERT_LIB_EXPORT(int) opensession(void);
XERT_LIB_EXPORT(int) loadsessionA(const char * filename);
XERT_LIB_EXPORT(int) loadsessionW(const wchar_t * filename);
XERT_LIB_EXPORT(int) preloadA(const char * filename,void *image);
XERT_LIB_EXPORT(int) preloadW(const wchar_t * filename,void *image);
#ifdef UNICODE
XERT_LIB_EXPORT(int) setcallback(int session,const wchar_t * name,void *procaddress);
#else
XERT_LIB_EXPORT(int) setcallback(int session,const char * name,void *procaddress);
#endif
XERT_LIB_EXPORT(int) getcharacterbytes(void);
#ifdef UNICODE
#define loadsession loadsessionW
#define preload preloadW
#else
XERT_LIB_EXPORT(int) loadsession(const char * filename);
XERT_LIB_EXPORT(int) preload(const char * filename,void *image);
#endif
XERT_LIB_EXPORT(int) unloadruntimeA(const char * filename);
XERT_LIB_EXPORT(int) unloadruntimeW(const wchar_t * filename);
#ifdef UNICODE
#define unloadruntime unloadruntimeW
#else
XERT_LIB_EXPORT(int) unloadruntime(const char * filename);
#endif
XERT_LIB_EXPORT(int) unloadall(void);
XERT_LIB_EXPORT(int) moremessageA(int session,char * message,
			      int msglen,char * field,int fldlen);
XERT_LIB_EXPORT(int) moremessageW(int session,wchar_t * message,
			      int msglen,wchar_t * field,int fldlen);
#ifdef UNICODE
#define moremessage moremessageW
#else
XERT_LIB_EXPORT(int) moremessage(int session,char * message,
			      int msglen,char * field,int fldlen);
#endif
XERT_LIB_EXPORT(int) choiceA(int session,const char * name,
                         const char * fieldname,
                         char * result,int reslen,
                         char * message,int msglen,
                         char * field,int fldlen);
XERT_LIB_EXPORT(int) choiceW(int session,const wchar_t * name,
                         const wchar_t * fieldname,
                         wchar_t * result,int reslen,
                         wchar_t * message,int msglen,
                         wchar_t * field,int fldlen);
#ifdef UNICODE
#define choice choiceW
#else
XERT_LIB_EXPORT(int) choice(int session,const char * name,
                         const char * fieldname,
                         char * result,int reslen,
                         char * message,int msglen,
                         char * field,int fldlen);
#endif
XERT_LIB_EXPORT(int) availableA(int session,const char * name,
                            const char * fieldname,
                            char * message,int msglen,
                            char * field,int fldlen);
XERT_LIB_EXPORT(int) availableW(int session,const wchar_t * name,
                            const wchar_t * fieldname,
                            wchar_t * message,int msglen,
                            wchar_t * field,int fldlen);
#ifdef UNICODE
#define available availableW
#else
XERT_LIB_EXPORT(int) available(int session,const char * name,
                            const char * fieldname,
                            char * message,int msglen,
                            char * field,int fldlen);
#endif
XERT_LIB_EXPORT(int) computeA(int session,const char * name,
                          char * result,int reslen,
                          char * message,int msglen,
                          char * field,int fldlen);
XERT_LIB_EXPORT(int) computeW(int session,const wchar_t * name,
                          wchar_t * result,int reslen,
                          wchar_t * message,int msglen,
                          wchar_t * field,int fldlen);
#ifdef UNICODE
#define compute computeW
#else
XERT_LIB_EXPORT(int) setcheck(int session,const char * name, const char * value,
                          char * result,int reslen,
                          char * message,int msglen,
                          char * field,int fldlen);
#endif
XERT_LIB_EXPORT(int) setcheckA(int session,const char * name, const char * value,
                          char * result,int reslen,
                          char * message,int msglen,
                          char * field,int fldlen);
XERT_LIB_EXPORT(int) setcheckW(int session,const wchar_t * name, const wchar_t * value,
                          wchar_t * result,int reslen,
                          wchar_t * message,int msglen,
                          wchar_t * field,int fldlen);
#ifdef UNICODE
#define setcheck setcheckW
#else
XERT_LIB_EXPORT(int) compute(int session,const char * name,
                          char * result,int reslen,
                          char * message,int msglen,
                          char * field,int fldlen);
#endif
XERT_LIB_EXPORT(int) setvarA(int session,const char * name,const char * value);
XERT_LIB_EXPORT(int) setvarW(int session,const wchar_t * name,const wchar_t * value);
#ifdef UNICODE
#define setvar setvarW
#else
XERT_LIB_EXPORT(int) setvar(int session,const char * name,const char * value);
#endif

XERT_LIB_EXPORT(int) xsetvarA(int session,const char * name,const char * value);
XERT_LIB_EXPORT(int) xsetvarW(int session,const wchar_t * name,const wchar_t * value);
#ifdef UNICODE
#define xsetvar(session,name,value) xsetvarW((session),(name),(value));
#else
XERT_LIB_EXPORT(int) xsetvar(int session,const char * name,const char * value);
#endif
XERT_LIB_EXPORT(int) storesession(int session,
                               unsigned char FAR *data);
XERT_LIB_EXPORT(int) storesessionx(int session,int kind,
                                unsigned char FAR *data);
XERT_LIB_EXPORT(int) restoresession(int session,
                                 const unsigned char FAR *data);
XERT_LIB_EXPORT(int) clonesession(int session);
XERT_LIB_EXPORT(int) commitsession(int sold,int snew);

XERT_LIB_EXPORT(int) dectest();
#ifdef __cplusplus
}
#endif
#endif
