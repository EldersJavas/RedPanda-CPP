####################################################################
# Startup

!define COMPILERNAME "MinGW-w64 X86_64 GCC 11.2"
!define COMPILERFOLDER "MinGW64"
!define DEVCPP_VERSION "0.8.0.beta"
!define FINALNAME "RedPanda-Cpp.7.${DEVCPP_VERSION}.${COMPILERNAME}.Setup.exe"
!define DISPLAY_NAME "Red Panda Dev-C++ 7 ${DEVCPP_VERSION}"

!include "MUI2.nsh"
!include "lang.nsh"

!define MUI_CUSTOMFUNCTION_GUIINIT myGuiInit

####################################################################
# Installer Attributes

Name "${DISPLAY_NAME}"
OutFile "${FINALNAME}"
Caption "${DISPLAY_NAME}"

LicenseData "LICENSE"
InstallDir $PROGRAMFILES\RedPanda-Cpp
####################################################################
# Interface Settings

ShowInstDetails show
AutoCloseWindow false
SilentInstall normal
CRCCheck on
SetCompressor /SOLID /FINAL lzma
SetCompressorDictSize 64
SetDatablockOptimize on
SetOverwrite try
XPStyle on

InstType "Full";1
InstType "Minimal";2
InstType "Safe";3

## Remember the installer language
!define MUI_LANGDLL_REGISTRY_ROOT "HKCU"
!define MUI_LANGDLL_REGISTRY_KEY "Software\RedPanda-C++"
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

####################################################################
# Pages

!define MUI_ICON "devcpp.ico"
!define MUI_UNICON "devcpp.ico"
!define MUI_ABORTWARNING
!define MUI_LANGDLL_ALLLANGUAGES
!define MUI_FINISHPAGE_RUN "$INSTDIR\RedPandaIDE.exe"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
!define MUI_COMPONENTSPAGE_SMALLDESC

!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

####################################################################
# Languages

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "TradChinese"
!insertmacro MUI_LANGUAGE "Bulgarian"
!insertmacro MUI_LANGUAGE "Catalan"
!insertmacro MUI_LANGUAGE "Croatian"
!insertmacro MUI_LANGUAGE "Czech"
!insertmacro MUI_LANGUAGE "Danish"
!insertmacro MUI_LANGUAGE "Dutch"
!insertmacro MUI_LANGUAGE "Estonian"
!insertmacro MUI_LANGUAGE "French"
!insertmacro MUI_LANGUAGE "German"
!insertmacro MUI_LANGUAGE "Greek"
!insertmacro MUI_LANGUAGE "Hungarian"
!insertmacro MUI_LANGUAGE "Italian"
!insertmacro MUI_LANGUAGE "Korean"
!insertmacro MUI_LANGUAGE "Latvian"
!insertmacro MUI_LANGUAGE "Polish"
!insertmacro MUI_LANGUAGE "Portuguese"
!insertmacro MUI_LANGUAGE "Romanian"
!insertmacro MUI_LANGUAGE "Russian"
!insertmacro MUI_LANGUAGE "Slovak"
!insertmacro MUI_LANGUAGE "Slovenian"
!insertmacro MUI_LANGUAGE "Spanish"
!insertmacro MUI_LANGUAGE "Swedish"
!insertmacro MUI_LANGUAGE "Turkish"
!insertmacro MUI_LANGUAGE "Ukrainian"

####################################################################
# Files, by option section

Section "$(SectionMainName)" SectionMain
  SectionIn 1 2 3 RO
  
  SetOutPath $INSTDIR

  ; Allways create an uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++" "DisplayName" "Redpanda-C++"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++" "UninstallString" "$INSTDIR\uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++" "DisplayVersion" "${DEVCPP_VERSION}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++" "DisplayIcon" "$INSTDIR\RedPandaIDE.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++" "Publisher" "Roy Qu(royqh1979@gmail.com)"


  ; Write required files
  File "RedPandaIDE.exe"
  File "ConsolePauser.exe"
  File "astyle.exe"
  File "LICENSE"
  File "NEWS.md"
  File "README.md"
  
  ; Write required paths
  SetOutPath $INSTDIR\Templates
  File /nonfatal /r "Templates\*"

  SetOutPath $INSTDIR\Icons
  File /nonfatal /r "Icons\*"
SectionEnd

Section "$(SectionMinGWName)" SectionMinGW
  SectionIn 1 3
  SetOutPath $INSTDIR\MinGW64

  File /nonfatal /r "${COMPILERFOLDER}\*"
SectionEnd

Section "$(SectionIconsName)" SectionIcons
  SectionIn 1 3
  
  SetOutPath $INSTDIR\Icons
  File /nonfatal /r "Icons\*.*"
SectionEnd

####################################################################
# File association
SubSection "$(SectionAssocsName)" SectionAssocs
Section "$(SectionAssocExtNameBegin) .dev $(SectionAssocExtNameEnd)"
  SectionIn 1 3

  StrCpy $0 ".dev"
  Call BackupAssoc

  StrCpy $0 $INSTDIR\RedPandaIDE.exe
  WriteRegStr HKCR ".dev" "" "DevCpp.dev"
  WriteRegStr HKCR "DevCpp.dev" "" "Dev-C++ Project File"
  WriteRegStr HKCR "DevCpp.dev\DefaultIcon" "" '$0,3'
  WriteRegStr HKCR "DevCpp.dev\Shell\Open\Command" "" '$0 "%1"'
  Call RefreshShellIcons
SectionEnd

Section "$(SectionAssocExtNameBegin) .c $(SectionAssocExtNameEnd)"
  SectionIn 1 3

  StrCpy $0 ".c"
  Call BackupAssoc

  StrCpy $0 $INSTDIR\RedPandaIDE.exe
  WriteRegStr HKCR ".c" "" "DevCpp.c"
  WriteRegStr HKCR "DevCpp.c" "" "C Source File"
  WriteRegStr HKCR "DevCpp.c\DefaultIcon" "" '$0,4'
  WriteRegStr HKCR "DevCpp.c\Shell\Open\Command" "" '$0 "%1"'
  Call RefreshShellIcons
SectionEnd

Section "$(SectionAssocExtNameBegin) .cpp $(SectionAssocExtNameEnd)"
  SectionIn 1 3

  StrCpy $0 ".cpp"
  Call BackupAssoc

  StrCpy $0 $INSTDIR\RedPandaIDE.exe
  WriteRegStr HKCR ".cpp" "" "DevCpp.cpp"
  WriteRegStr HKCR "DevCpp.cpp" "" "C++ Source File"
  WriteRegStr HKCR "DevCpp.cpp\DefaultIcon" "" '$0,5'
  WriteRegStr HKCR "DevCpp.cpp\Shell\Open\Command" "" '$0 "%1"'
  Call RefreshShellIcons
SectionEnd

Section "$(SectionAssocExtNameBegin) .cxx $(SectionAssocExtNameEnd)"
  SectionIn 1 3

  StrCpy $0 ".cxx"
  Call BackupAssoc

  StrCpy $0 $INSTDIR\RedPandaIDE.exe
  WriteRegStr HKCR ".cxx" "" "DevCpp.cxx"
  WriteRegStr HKCR "DevCpp.cxx" "" "C++ Source File"
  WriteRegStr HKCR "DevCpp.cxx\DefaultIcon" "" '$0,5'
  WriteRegStr HKCR "DevCpp.cxx\Shell\Open\Command" "" '$0 "%1"'
  Call RefreshShellIcons
SectionEnd

Section "$(SectionAssocExtNameBegin) .cc $(SectionAssocExtNameEnd)"
  SectionIn 1 3

  StrCpy $0 ".cc"
  Call BackupAssoc

  StrCpy $0 $INSTDIR\RedPandaIDE.exe
  WriteRegStr HKCR ".cc" "" "DevCpp.cc"
  WriteRegStr HKCR "DevCpp.cc" "" "C++ Source File"
  WriteRegStr HKCR "DevCpp.cc\DefaultIcon" "" '$0,5'
  WriteRegStr HKCR "DevCpp.cc\Shell\Open\Command" "" '$0 "%1"'
  Call RefreshShellIcons
SectionEnd

Section "$(SectionAssocExtNameBegin) .hxx $(SectionAssocExtNameEnd)"
  SectionIn 1 3

  StrCpy $0 ".hxx"
  Call BackupAssoc

  StrCpy $0 $INSTDIR\RedPandaIDE.exe
  WriteRegStr HKCR ".hxx" "" "DevCpp.hxx"
  WriteRegStr HKCR "DevCpp.hxx" "" "C++ Header File"
  WriteRegStr HKCR "DevCpp.hxx\DefaultIcon" "" '$0,7'
  WriteRegStr HKCR "DevCpp.hxx\Shell\Open\Command" "" '$0 "%1"'
  Call RefreshShellIcons
SectionEnd

Section "$(SectionAssocExtNameBegin) .h $(SectionAssocExtNameEnd)"
  SectionIn 1 3

  StrCpy $0 ".h"
  Call BackupAssoc

  StrCpy $0 $INSTDIR\RedPandaIDE.exe
  WriteRegStr HKCR ".h" "" "DevCpp.h"
  WriteRegStr HKCR "DevCpp.h" "" "C Header File"
  WriteRegStr HKCR "DevCpp.h\DefaultIcon" "" '$0,6'
  WriteRegStr HKCR "DevCpp.h\Shell\Open\Command" "" '$0 "%1"'
  Call RefreshShellIcons
SectionEnd

Section "$(SectionAssocExtNameBegin) .hpp $(SectionAssocExtNameEnd)"
  SectionIn 1 3

  StrCpy $0 ".hpp"
  Call BackupAssoc

  StrCpy $0 $INSTDIR\RedPandaIDE.exe
  WriteRegStr HKCR ".hpp" "" "DevCpp.hpp"
  WriteRegStr HKCR "DevCpp.hpp" "" "C++ Header File"
  WriteRegStr HKCR "DevCpp.hpp\DefaultIcon" "" '$0,7'
  WriteRegStr HKCR "DevCpp.hpp\Shell\Open\Command" "" '$0 "%1"'
  Call RefreshShellIcons
SectionEnd

SubSectionEnd

####################################################################
# Shortcuts
SubSection "$(SectionShortcutsName)" SectionShortcuts

Section "$(SectionMenuLaunchName)" SectionMenuLaunch
  SectionIn 1 3
 
  ; always use all user start menu, normal users can delete these
  SetShellVarContext all 
  StrCpy $0 $SMPROGRAMS ; start menu Programs folder
  CreateDirectory "$0\Dev-C++"
  CreateShortCut "$0\Dev-C++\Red Panda Dev-C++.lnk" "$INSTDIR\RedPandaIDE.exe"
  CreateShortCut "$0\Dev-C++\License.lnk" "$INSTDIR\LICENSE"
  CreateShortCut "$0\Dev-C++\Uninstall Red Panda Dev-C++.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

Section "$(SectionDesktopLaunchName)" SectionDesktopLaunch
  SectionIn 1 3
  
  ; always use current user desktop, normal users can't delete all users' shortcuts
  SetShellVarContext current
  CreateShortCut "$DESKTOP\Red Panda Dev-C++.lnk" "$INSTDIR\RedPandaIDE.exe"
SectionEnd

SubSectionEnd

Section "$(SectionConfigName)" SectionConfig
  SectionIn 3

  RMDir /r "$APPDATA\RedPanda-C++"
  
SectionEnd

####################################################################

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SectionMain}        "$(MessageSectionMain)"
!insertmacro MUI_DESCRIPTION_TEXT ${SectionMinGW}      "$(MessageSectionMinGW)"
!insertmacro MUI_DESCRIPTION_TEXT ${SectionIcons}      "$(MessageSectionIcons)"
!insertmacro MUI_DESCRIPTION_TEXT ${SectionShortcuts}   "$(MessageSectionShortcuts)"
!insertmacro MUI_DESCRIPTION_TEXT ${SectionAssocs}      "$(MessageSectionAssocs)"
!insertmacro MUI_DESCRIPTION_TEXT ${SectionConfig}      "$(MessageSectionConfig)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

####################################################################
# Functions, utilities

Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY

  IfFileExists "C:\Dev-Cpp\devcpp.exe" 0 +2
    SectionSetFlags ${SectionConfig} ${SF_SELECTED} # Remove old Dev-Cpp config files
	
  IfFileExists "$APPDATA\Dev-Cpp\devcpp.cfg" 0 +2 # deprecated config file
    SectionSetFlags ${SectionConfig} ${SF_SELECTED}

FunctionEnd

Function myGuiInit

  ; uninstall existing
  Call UninstallExisting

FunctionEnd

;backup file association
Function BackupAssoc
  ;$0 is an extension - for example ".dev"

  ;check if backup already exists
  ReadRegStr $1 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++\Backup" "$0" 
  ;don't backup if backup exists in registry
  StrCmp $1 "" 0 no_assoc

  ReadRegStr $1 HKCR "$0" ""
  ;don't backup dev-cpp associations
  StrCmp $1 "DevCpp$0" no_assoc

  StrCmp $1 "" no_assoc
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++\Backup" "$0" "$1"
  no_assoc:
  
FunctionEnd

Function un.onInit
   !insertmacro MUI_UNGETLANGUAGE
FunctionEnd

;restore file association
Function un.RestoreAssoc
  ;$0 is an extension - for example ".dev"

  DeleteRegKey HKCR "$0"
  ReadRegStr $1 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++\Backup" "$0"
  StrCmp $1 "" no_backup
    WriteRegStr HKCR "$0" "" "$1"
    Call un.RefreshShellIcons
  no_backup:
  
FunctionEnd

;http://nsis.sourceforge.net/archive/viewpage.php?pageid=202
;After changing file associations, you can call this macro to refresh the shell immediatly. 
;It calls the shell32 function SHChangeNotify. This will force windows to reload your changes from the registry.
!define SHCNE_ASSOCCHANGED 0x08000000
!define SHCNF_IDLIST 0

Function RefreshShellIcons
  ; By jerome tremblay - april 2003
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Function un.RefreshShellIcons
  ; By jerome tremblay - april 2003
  System::Call 'shell32.dll::SHChangeNotify(i, i, i, i) v \
  (${SHCNE_ASSOCCHANGED}, ${SHCNF_IDLIST}, 0, 0)'
FunctionEnd

Function un.DeleteDirIfEmpty
  FindFirst $R0 $R1 "$0\*.*"
  strcmp $R1 "." 0 NoDelete
   FindNext $R0 $R1
   strcmp $R1 ".." 0 NoDelete
    ClearErrors
    FindNext $R0 $R1
    IfErrors 0 NoDelete
     FindClose $R0
     Sleep 1000
     RMDir "$0"
  NoDelete:
   FindClose $R0
FunctionEnd

Function GetParent
 
  Exch $R0
  Push $R1
  Push $R2
  Push $R3
 
  StrCpy $R1 0
  StrLen $R2 $R0
 
  loop:
    IntOp $R1 $R1 + 1
    IntCmp $R1 $R2 get 0 get
    StrCpy $R3 $R0 1 -$R1
    StrCmp $R3 "\" get
  Goto loop
 
  get:
    StrCpy $R0 $R0 -$R1
 
    Pop $R3
    Pop $R2
    Pop $R1
    Exch $R0
 
FunctionEnd

Function UninstallExisting
    ReadRegStr $R0 HKLM  "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++"  "UninstallString"

    StrCmp $R0 "" done

    Push $R0
    Call GetParent
    Pop $R1

    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
        "$(MessageUninstallExisting)" \
        IDOK uninst
    Abort

    ;Run the uninstaller
    uninst:
        ClearErrors
        HideWindow
        ClearErrors
        ExecWait '"$R0" _?=$R1'
        BringToFront

    done:
FunctionEnd
####################################################################
# uninstall

UninstallText "$(MessageUninstallText)"
ShowUninstDetails show

Section "Uninstall"

  ; Remove uninstaller
  Delete "$INSTDIR\uninstall.exe"

  ; Remove start menu stuff, located in all users folder
  SetShellVarContext all 
  Delete "$SMPROGRAMS\Dev-C++\Red Panda Dev-C++.lnk"
  Delete "$SMPROGRAMS\Dev-C++\License.lnk"
  Delete "$SMPROGRAMS\Dev-C++\Uninstall Red Panda Dev-C++.lnk"
  RMDir "$SMPROGRAMS\Dev-C++"
  
  ; Remove desktop stuff, located in current user folder
  SetShellVarContext current
  Delete "$QUICKLAUNCH\Red Panda Dev-C++.lnk"
  Delete "$DESKTOP\Red Panda Dev-C++.lnk"

  ; Restore file associations
  StrCpy $0 ".dev"
  Call un.RestoreAssoc
  StrCpy $0 ".c"
  Call un.RestoreAssoc
  StrCpy $0 ".cpp"
  Call un.RestoreAssoc
  StrCpy $0 ".h"
  Call un.RestoreAssoc
  StrCpy $0 ".hpp"
  Call un.RestoreAssoc
 
  DeleteRegKey HKCR "DevCpp.dev"
  DeleteRegKey HKCR "DevCpp.c"
  DeleteRegKey HKCR "DevCpp.cpp"
  DeleteRegKey HKCR "DevCpp.cxx"
  DeleteRegKey HKCR "DevCpp.cc"
  DeleteRegKey HKCR "DevCpp.h"
  DeleteRegKey HKCR "DevCpp.hpp"
  DeleteRegKey HKCR "DevCpp.hxx"


  Delete "$INSTDIR\NEWS.md"
  Delete "$INSTDIR\RedPandaIDE.exe"
  Delete "$INSTDIR\ConsolePauser.exe"
  Delete "$INSTDIR\astyle.exe"
  Delete "$INSTDIR\LICENSE"
  Delete "$INSTDIR\README.md"

  RMDir /r "$INSTDIR\Lang"
  RMDir /r "$INSTDIR\Icons"
  RMDir /r "$INSTDIR\Templates"
  RMDir /r "$INSTDIR\MinGW32"
  RMDir /r "$INSTDIR\MinGW64"

  StrCpy $0 "$INSTDIR"
  Call un.DeleteDirIfEmpty

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\RedPanda-C++"
  DeleteRegKey HKCU "Software\RedPanda-C++"

  IfSilent +2 ; Don't ask when running in silent mode
  MessageBox MB_YESNO "$(MessageRemoveConfig)" IDNO Done

  RMDir /r "$APPDATA\RedPanda-C++"

Done:
SectionEnd