CC=cl
LINK=link
RC=rc

CFLAGS=/nologo /MT /EHsc /wd4731 /wd4477 /D_WINNT_WIN32=0x501 /DKS_JMP_SHIFT=4 $(EXTRA_CFLAGS) /DUSE_HASHMAPS /D_WIN32
LFLAGS=/NOLOGO /NODEFAULTLIB:libci.lib /LIBPATH:soft\dxsdk81\lib
LIBS=user32.lib gdi32.lib advapi32.lib


INCLUDE=$(INCLUDE);soft\dxsdk81\include
LIB=$(LIB);soft\dxsdk81\lib


all: dlls apps
	if exist output (rd /S /Q output)
	mkdir output
	copy *.exe output
	copy *.dll output
	
all_apps: apps
	if exist output (rd /S /Q output)
	mkdir output
	copy *.exe output

dlls: kserv.dll
apps: kctrl.exe setup.exe afstest.exe afswalk.exe


!if "$(debug)"=="1"
EXTRA_CFLAGS=/DDEBUG
!else
EXTRA_CFLAGS=/DMYDLL_RELEASE_BUILD
!endif
	
	
setup: setup.exe
afstest: afstest.exe
afswalk: afswalk.exe

win32gui.obj: win32gui.cpp win32gui.h
config.obj: config.cpp config.h
kdb.obj: kdb.cpp kdb.h
imageutil.obj: imageutil.cpp imageutil.h
d3dfont.obj: d3dfont.cpp d3dfont.h dxutil.h
dxutil.obj: dxutil.cpp dxutil.h
regtools.obj: regtools.cpp regtools.h
log.obj: log.cpp log.h
crc32.obj: crc32.cpp crc32.h
afsreader.obj: afsreader.cpp afsreader.h
apihijack.obj: apihijack.cpp apihijack.h

kserv.lib: mydll.obj detect.obj kdb.obj log.obj config.obj imageutil.obj d3dfont.obj dxutil.obj crc32.obj afsreader.obj apihijack.obj
kserv.dll: kserv.lib mydll.res
	$(LINK) $(LFLAGS) /out:kserv.dll /DLL mydll.obj detect.obj kdb.obj log.obj config.obj crc32.obj afsreader.obj imageutil.obj d3dfont.obj dxutil.obj apihijack.obj mydll.res $(LIBS) d3dx8.lib winmm.lib /LIBPATH:/LIBPATH:\DXSDK\lib
mydll.obj: mydll.cpp mydll.h shared.h config.h kdb.h
detect.obj: detect.cpp

mydll.res: 
	$(RC)  -r -fo mydll.res mydll.rc

kctrl.exe: kctrl.obj config.obj log.obj win32gui.obj
	$(LINK) $(LFLAGS) /out:kctrl.exe kctrl.obj config.obj log.obj win32gui.obj $(LIBS)
kctrl.obj: kctrl.cpp kctrl.h config.h win32gui.h

setupgui.obj: setupgui.cpp setupgui.h
setup.exe: setup.obj detect.obj setupgui.obj imageutil.obj setup.res
	$(LINK) $(LFLAGS) /out:setup.exe setup.obj detect.obj setupgui.obj imageutil.obj setup.res $(LIBS)
setup.obj: setup.cpp setup.h setupgui.h
setup.res: setup.rc
	$(RC) -r -fo setup.res setup.rc

afstest.obj: afstest.cpp afsreader.h
afstest.exe: afstest.obj afsreader.obj crc32.obj log.obj config.obj
	$(LINK) $(LFLAGS) /out:afstest.exe afstest.obj afsreader.obj crc32.obj log.obj config.obj

afswalk.obj: afswalk.cpp afsreader.h
afswalk.exe: afswalk.obj afsreader.obj crc32.obj log.obj config.obj
	$(LINK) $(LFLAGS) /out:afswalk.exe afswalk.obj afsreader.obj crc32.obj log.obj config.obj

.cpp.obj:
	$(CC) $(CFLAGS) -c $<

clean:
	del /Q /F *.exp *.lib *.obj *.res

clean-all:
	del /Q /F *.exp *.lib *.obj *.res *.log *~
