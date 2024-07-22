////////////////////////////////////////////////////////////////////////////////
// ****************** Разработчик: Субботин Сергей (c)2024 ****************** //
// **************************** АО "Ангстрем" ******************************* //
// *************************** Версия 2.0.0.0 ******************************* //
////////////////////////////////////////////////////////////////////////////////

unit LPTDrv;

interface

uses
  Windows, WinSvc, SysUtils, Dialogs, Classes, Registry;

const
// The IOCTL function codes from 0x800 to 0xFFF are for customer use.
{
#define IOCTL_OLS_GET_DRIVER_VERSION \
	CTL_CODE(OLS_TYPE, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define IOCTL_OLS_GET_REFCOUNT \
	CTL_CODE(OLS_TYPE, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define IOCTL_OLS_READ_MSR \
	CTL_CODE(OLS_TYPE, 0x821, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define IOCTL_OLS_WRITE_MSR \
	CTL_CODE(OLS_TYPE, 0x822, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define IOCTL_OLS_READ_PMC \
	CTL_CODE(OLS_TYPE, 0x823, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define IOCTL_OLS_HALT \
	CTL_CODE(OLS_TYPE, 0x824, METHOD_BUFFERED, FILE_ANY_ACCESS)

#define IOCTL_OLS_READ_IO_PORT \
	CTL_CODE(OLS_TYPE, 0x831, METHOD_BUFFERED, FILE_READ_ACCESS)

#define IOCTL_OLS_WRITE_IO_PORT \
	CTL_CODE(OLS_TYPE, 0x832, METHOD_BUFFERED, FILE_WRITE_ACCESS)

#define IOCTL_OLS_READ_IO_PORT_BYTE \
	CTL_CODE(OLS_TYPE, 0x833, METHOD_BUFFERED, FILE_READ_ACCESS)

#define IOCTL_OLS_READ_IO_PORT_WORD \
	CTL_CODE(OLS_TYPE, 0x834, METHOD_BUFFERED, FILE_READ_ACCESS)

#define IOCTL_OLS_READ_IO_PORT_DWORD \
	CTL_CODE(OLS_TYPE, 0x835, METHOD_BUFFERED, FILE_READ_ACCESS)

#define IOCTL_OLS_WRITE_IO_PORT_BYTE \
	CTL_CODE(OLS_TYPE, 0x836, METHOD_BUFFERED, FILE_WRITE_ACCESS)

#define IOCTL_OLS_WRITE_IO_PORT_WORD \
	CTL_CODE(OLS_TYPE, 0x837, METHOD_BUFFERED, FILE_WRITE_ACCESS)

#define IOCTL_OLS_WRITE_IO_PORT_DWORD \
	CTL_CODE(OLS_TYPE, 0x838, METHOD_BUFFERED, FILE_WRITE_ACCESS)

#define IOCTL_OLS_READ_MEMORY \
	CTL_CODE(OLS_TYPE, 0x841, METHOD_BUFFERED, FILE_READ_ACCESS)

#define IOCTL_OLS_WRITE_MEMORY \
	CTL_CODE(OLS_TYPE, 0x842, METHOD_BUFFERED, FILE_WRITE_ACCESS)

#define IOCTL_OLS_READ_PCI_CONFIG \
	CTL_CODE(OLS_TYPE, 0x851, METHOD_BUFFERED, FILE_READ_ACCESS)

#define IOCTL_OLS_WRITE_PCI_CONFIG \
	CTL_CODE(OLS_TYPE, 0x852, METHOD_BUFFERED, FILE_WRITE_ACCESS)
}

  PROCESSOR_ARCHITECTURE_AMD64 = 9;	 // x64 (AMD or Intel)
  PROCESSOR_ARCHITECTURE_ARM   = 5;	 // ARM
  PROCESSOR_ARCHITECTURE_ARM64 = 12; //	ARM64
  PROCESSOR_ARCHITECTURE_IA64  = 6;  // Intel Itanium-based
  PROCESSOR_ARCHITECTURE_INTEL = 0;  //	x86
  PROCESSOR_ARCHITECTURE_UNKNOWN = $FFFF; // Unknown architecture.


  OLS_TYPE = 40000;
  METHOD_BUFFERED   = $0000;
  FILE_READ_ACCESS  = $0001;
  FILE_WRITE_ACCESS = $0002;


  OLS_DRIVER_INSTALL	       	=	1;
  OLS_DRIVER_REMOVE			      = 2;
  OLS_DRIVER_SYSTEM_INSTALL	  = 3;
 	OLS_DRIVER_SYSTEM_UNINSTALL	= 4;

//-----------------------------------------------------------------------------
//
// DLL Status Code
//
//-----------------------------------------------------------------------------

  OLS_DLL_NO_ERROR						           = 0;
  OLS_DLL_UNSUPPORTED_PLATFORM			     = 1;
  OLS_DLL_DRIVER_NOT_LOADED				       = 2;
  OLS_DLL_DRIVER_NOT_FOUND				       = 3;
  OLS_DLL_DRIVER_UNLOADED					       = 4;
  OLS_DLL_DRIVER_NOT_LOADED_ON_NETWORK	 = 5;
  OLS_DLL_UNKNOWN_ERROR				           = 9;

  OLS_DLL_DRIVER_INVALID_PARAM           = 10;
  OLS_DLL_DRIVER_SC_MANAGER_NOT_OPENED   = 11;
  OLS_DLL_DRIVER_SC_DRIVER_NOT_INSTALLED = 12;
  OLS_DLL_DRIVER_SC_DRIVER_NOT_STARTED   = 13;
  OLS_DLL_DRIVER_SC_DRIVER_NOT_REMOVED   = 14;

//-----------------------------------------------------------------------------
//
// Driver Type
//
//-----------------------------------------------------------------------------

  OLS_DRIVER_TYPE_UNKNOWN			= 0;
  OLS_DRIVER_TYPE_WIN_9X			= 1;
  OLS_DRIVER_TYPE_WIN_NT			= 2;
  OLS_DRIVER_TYPE_WIN_NT4			= 3;	// Obsolete
  OLS_DRIVER_TYPE_WIN_NT_X64	=	4;
  OLS_DRIVER_TYPE_WIN_NT_IA64	=	5;	// Reseved

//-----------------------------------------------------------------------------
//
// PCI Error Code
//
//-----------------------------------------------------------------------------

  OLS_ERROR_PCI_BUS_NOT_EXIST	=	$E0000001;
  OLS_ERROR_PCI_NO_DEVICE			= $E0000002;
  OLS_ERROR_PCI_WRITE_CONFIG	=	$E0000003;
  OLS_ERROR_PCI_READ_CONFIG		= $E0000004;


type
  PByte = array of byte; // Для D7

  TPCIReg = record
    VendorID   : WORD;
    DeviceID   : WORD;
    Command    : WORD;
    Status     : WORD;
    RevisionID : byte;
    ClassCode  : DWORD;
    Undef1     : DWORD;
    IOBaseAddr0: DWORD;
    IOBaseAddr1: DWORD;
    IOBaseAddr2: DWORD;
    IOBaseAddr3: DWORD;
    IOBaseAddr4: DWORD;
    IOBaseAddr5: DWORD;
    IOBaseAddr6: DWORD;
    subVendorID: WORD;
    subDeviceID: WORD;
  end;

  TLPTInfo = record
    Name     : string;
    FullName : string;
    VendorID : WORD;
    DeviceID : WORD;
    BusN     : byte;
    DevN     : byte;
    FuncN    : byte;
    RegStr   : string;
    PrefStr  : string;
    BaseAddr : WORD;
    BaseAddr1: WORD;
    BaseAddr2: WORD;
    PCIBARReg:TPCIReg;
  end;
  TLPTInfoMass = array of TLPTInfo;

  OLS_WRITE_IO_PORT_INPUT = record
    PortNumber: DWORD;
    case Integer of
      0: (ByteData : byte );
      1: (WORDData : WORD );
      2: (DWORDData: DWORD);
  end;

  TLPTDriver = class
  public
    EPPMode: Boolean;
    NumPort: byte;

    WinName : string;
    Win64bit: Boolean;
    LPTPort: TLPTInfoMass;
    ActLPTPortNames: array of string;

    constructor Create();
    destructor  Destroy(); override;

    function ReadIoPortByte (const port: WORD): byte;
    function ReadIoPortWORD (const port: WORD): WORD;
    function ReadIoPortDWORD(const port: WORD): DWORD;

    procedure WriteIoPortByte (const port: WORD; const value: byte);
    procedure WriteIoPortWORD (const port: WORD; const value: WORD);
    procedure WriteIoPortDWORD(const port: WORD; const value: DWORD);

    function ReadByte (const port: WORD): byte;
    function ReadWORD (const port: WORD): WORD;
    function ReadDWORD(const port: WORD): DWORD;

    procedure WriteByte (const port: WORD; const Data: byte);
    procedure WriteWORD (const port: WORD; const Data: WORD);
    procedure WriteDWORD(const port: WORD; const Data: WORD);

    function ReadCH382LIoPortByte (const port: WORD): byte;
    function ReadCH382LIoPortWORD (const port: WORD): WORD;
    function ReadCH382LIoPortDWORD(const port: WORD): DWORD;

    procedure WriteCH382LIoPortByte (const port: WORD; const value: byte);
    procedure WriteCH382LIoPortWORD (const port: WORD; const value: WORD);
    procedure WriteCH382LIoPortDWORD(const port: WORD; const value: DWORD);
  private
    DrvPath : TFileName;
    DrvfName: TFileName;
    DrvID: string;
    gHandle: THandle;

    IOCTL_OLS_READ_IO_PORT_BYTE : DWORD;
    IOCTL_OLS_READ_IO_PORT_WORD : DWORD;
    IOCTL_OLS_READ_IO_PORT_DWORD: DWORD;

    IOCTL_OLS_WRITE_IO_PORT_BYTE : DWORD;
    IOCTL_OLS_WRITE_IO_PORT_WORD : DWORD;
    IOCTL_OLS_WRITE_IO_PORT_DWORD: DWORD;

    function  Find_PCIe_LPT: byte;
    function  GetActLPTPortNames: byte;

    function ManageDriver(const DriverId: LPCTSTR; const DriverPath: LPCTSTR; const Func: byte): DWORD;
    function OpenDriver  (const DriverId: LPCTSTR): Boolean;
    function InstallDriver        (const hSCManager: SC_HANDLE; const DriverId, DriverPath: LPCTSTR): Boolean;
    function IsSystemInstallDriver(const hSCManager: SC_HANDLE; const DriverId: LPCTSTR): Boolean;
    function RemoveDriver         (const hSCManager: SC_HANDLE; const DriverId: LPCTSTR): Boolean;
    function StartDriver          (const hSCManager: SC_HANDLE; const DriverId: LPCTSTR): Boolean;
    function StopDriver           (const hSCManager: SC_HANDLE; const DriverId: LPCTSTR): Boolean;
    function SystemInstallDriver  (const hSCManager: SC_HANDLE; const DriverId, DriverPath: LPCTSTR): Boolean;

    procedure FillPCIReg();
    
    function  CTL_CODE(const DeviceType, FuncNo, Method, Access: DWORD): DWORD;

    function  IsWow64(): Boolean;
    function  IsX64  (): Boolean;
    function  GetWinName: string;
    procedure ErrMess(const ErrMes: String);
  end;

//  AX99100: VendorID = $125B; DeviceID = $9100
//  CH382L : VendorID = $1C00; DeviceID = $3250

implementation

{ TDriver }

///////////////////////////////////////////////////////////////////////////////////////////////////
constructor TLPTDriver.Create();                                                                 //
var                                                                                              //
  Buffer: array[0..MAX_PATH] of Char;                                                            //
  Res: DWORD;                                                                                    //
  n: byte;                                                                                       //
begin                                                                                            //
  inherited Create();                                                                            //
                                                                                                 //
  WinName := GetWinName();                                                                       //
//  Win64bit := IsWow64();                                                                         //
  Win64bit := IsX64();                                                                           //
                                                                                                 //
  n := GetActLPTPortNames();                                                                     //
  if n = 0 then                                                                                  //
  begin                                                                                          //
    ErrMess('Не найдены LPT порты!');                                                            //
    Exit;                                                                                        //
  end;                                                                                           //
                                                                                                 //
  n := Find_PCIe_LPT();                                                                          //
  if n = 0 then                                                                                  //
  begin                                                                                          //
    ErrMess('Не найдены PCIe LPT порты!');                                                       //
    Exit;                                                                                        //
  end;                                                                                           //
                                                                                                 //
  DrvID := 'WinRing0_1_2_0';                                                                     //
  if Win64bit then DrvfName := 'WinRing0x64.sys'                                                 //
              else DrvfName := 'WinRing0.sys';                                                   //
                                                                                                 //
//  DrvID := 'AsrDrv101';                                                                          //
//  DrvfName := 'AsrDrv101.sys';                                                                   //
                                                                                                 //
  GetModuleFileName(0, Buffer, MAX_PATH);                                                        //
  DrvPath := ExtractFilePath(Buffer)+DrvfName;                                                   //
  if not FileExists(DrvPath) then                                                                //
  begin                                                                                          //
    ErrMess('Не найден файл драйвера '+DrvfName+'!');                                            //
    Exit;                                                                                        //
  end;                                                                                           //
                                                                                                 //
  IOCTL_OLS_READ_IO_PORT_BYTE   := CTL_CODE(OLS_TYPE, $833, METHOD_BUFFERED, FILE_READ_ACCESS);  //
  IOCTL_OLS_READ_IO_PORT_WORD   := CTL_CODE(OLS_TYPE, $834, METHOD_BUFFERED, FILE_READ_ACCESS);  //
  IOCTL_OLS_READ_IO_PORT_DWORD  := CTL_CODE(OLS_TYPE, $835, METHOD_BUFFERED, FILE_READ_ACCESS);  //
                                                                                                 //
  IOCTL_OLS_WRITE_IO_PORT_BYTE  := CTL_CODE(OLS_TYPE, $836, METHOD_BUFFERED, FILE_WRITE_ACCESS); //
  IOCTL_OLS_WRITE_IO_PORT_WORD  := CTL_CODE(OLS_TYPE, $837, METHOD_BUFFERED, FILE_WRITE_ACCESS); //
  IOCTL_OLS_WRITE_IO_PORT_DWORD := CTL_CODE(OLS_TYPE, $838, METHOD_BUFFERED, FILE_WRITE_ACCESS); //
                                                                                                 //
  gHandle := 0;                                                                                  //
                                                                                                 //
  Res := ManageDriver(PChar(DrvID), PChar(DrvPath), OLS_DRIVER_INSTALL);                         //
  if Res <> 0 then                                                                               //
  begin                                                                                          //
    ErrMess('Ошибка запуска драйвера LPT!');                                                     //
    Exit;                                                                                        //
  end;                                                                                           //
                                                                                                 //
  if not OpenDriver(PChar(DrvID)) then                                                           //
  begin                                                                                          //
    ErrMess('Ошибка открытия драйвера LPT!');                                                    //
    Exit;                                                                                        //
  end;                                                                                           //
                                                                                                 //
  for n := 0 to Length(LPTPort)-1 do                                                             //
    if LPTPort[n].BaseAddr1 = 0 then LPTPort[n].BaseAddr := LPTPort[n].BaseAddr2                 //
                                else LPTPort[n].BaseAddr := LPTPort[n].BaseAddr1;                //
                                                                                                 //
  FillPCIReg();                                                                                  //
                                                                                                 //
  EPPMode := False;                                                                              //
  NumPort := 0;                                                                                  //
end;                                                                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////                                                                                                 
destructor TLPTDriver.Destroy;                                                                   //
begin                                                                                            //
  if gHandle <> INVALID_HANDLE_VALUE then                                                        //
  begin                                                                                          //
    CloseHandle(gHandle);                                                                        //
    gHandle := INVALID_HANDLE_VALUE;                                                             //
  end;                                                                                           //
                                                                                                 //
  ManageDriver(PChar(DrvID), PChar(DrvPath), OLS_DRIVER_REMOVE);                                 //
                                                                                                 //
  inherited;                                                                                     //
end;                                                                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////
function TLPTDriver.GetActLPTPortNames(): byte;    //
var                                                //
  Reg: TRegIniFile;                                //
  Str, Key0: string;                               //
  SL: TStringList;                                 //
  n, P: byte;                                      //
begin                                              //
  Result := 0;                                     //
                                                   //
  SetLength(ActLPTPortNames, 0);                   //
                                                   //
  SL := TStringList.Create();                      //
                                                   //
  Key0 := 'HARDWARE\DEVICEMAP\PARALLEL PORTS\';    //
  try                                              //
    Reg := TRegIniFile.Create('');                 //
    try                                            //
      Reg.RootKey := HKEY_LOCAL_MACHINE;           //
                                                   //
      if (not Reg.KeyExists(Key0)) then Exit;      //
                                                   //
      Reg.OpenKeyReadOnly(Key0);                   //
      Reg.GetValueNames(SL);                       //
      Reg.CloseKey;                                //
                                                   //
      if SL.Count > 0 then                         //
      begin                                        //
        SetLength(ActLPTPortNames, SL.Count);      //
                                                   //
        for n := 0 to SL.Count-1 do                //
        begin                                      //
          Str := Reg.ReadString(Key0, SL[n], 'x'); //
          P := LastDelimiter('\', Str);            //
          Str := Copy(Str, P+1, Length(Str));      //
                                                   //
          ActLPTPortNames[n] := Str;               //
        end;                                       //
      end;                                         //
                                                   //
    finally                                        //
      Reg.Free;                                    //
    end;                                           //
  except                                           //
  end;                                             //
                                                   //
  SL.Free();                                       //
                                                   //
  Result := Length(ActLPTPortNames);               //
end;                                               //
/////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.Find_PCIe_LPT(): byte;                                                                                    //
                                                                                                                              //
/////////////////////////////////////////////////////////////////////                                                         //
  function ReadWord(Buff: PByte; Num: DWORD): WORD;                //                                                         //
  var                                                              //                                                         //
    n: byte;                                                       //                                                         //
  begin                                                            //                                                         //
    Result := 0;                                                   //                                                         //
                                                                   //                                                         //
    for n := Num to Num+1 do Result := Result+(Buff[n] shl (n*8)); //                                                         //
  end;                                                             //                                                         //
/////////////////////////////////////////////////////////////////////                                                         //
/////////////////////////////////////////////////////////////////////                                                         //
  function ReadDWord(Buff: PByte; Num: DWORD): DWORD;              //                                                         //
  var                                                              //                                                         //
    n: byte;                                                       //                                                         //
  begin                                                            //                                                         //
    Result := 0;                                                   //                                                         //
                                                                   //                                                         //
    for n := Num to Num+3 do Result := Result+(Buff[n] shl (n*8)); //                                                         //
  end;                                                             //                                                         //
/////////////////////////////////////////////////////////////////////                                                         //
                                                                                                                              //
var                                                                                                                           //
  Reg: TRegIniFile;                                                                                                           //
  Str, Key0, tKey: String;                                                                                                    //
  SL, tSL1, tSL2: TStringList;                                                                                                //
  n, i, j, m: DWORD;                                                                                                          //
  P: byte;                                                                                                                    //
  DevID, VendID: WORD;                                                                                                        //
  Present: Boolean;                                                                                                           //
  Data: array of byte;                                                                                                        //
begin                                                                                                                         //
  Result := 0;                                                                                                                //
                                                                                                                              //
  SetLength(LPTPort, 0);                                                                                                      //
                                                                                                                              //
  SL   := TStringList.Create();                                                                                               //
  tSL1 := TStringList.Create();                                                                                               //
  tSL2 := TStringList.Create();                                                                                               //
                                                                                                                              //
  Key0 := 'SYSTEM\CurrentControlSet\Enum\MF\';                                                                                //
  try                                                                                                                         //
    Reg := TRegIniFile.Create('');                                                                                            //
    try                                                                                                                       //
      Reg.RootKey := HKEY_LOCAL_MACHINE;                                                                                      //
                                                                                                                              //
      if (not Reg.KeyExists(Key0)) then Exit;                                                                                 //
                                                                                                                              //
      Reg.OpenKeyReadOnly(Key0);                                                                                              //
      Reg.GetKeyNames(SL);                                                                                                    //
      Reg.CloseKey;                                                                                                           //
      if SL.Count > 0 then                                                                                                    //
        for n := 0 to SL.Count-1 do                        //                                                                 //
        begin                                              //                                                                 //
          Str := UpperCase(SL[n]);                         //                                                                 //
          if Pos('PCI', Str) <> 0 then                     //                                                                 //
          begin                                            //                                                                 //
            P := Pos('VEN', Str);                          //                                                                 //
            if P > 0 then                                  //                                                                 //
              try                                          // Узнаем                                                          //
                VendID := StrToInt('$'+Copy(Str, P+4, 4)); // VendorID                                                        //
              except                                       // и                                                               //
                VendID := 0;                               // DeviceID                                                        //
              end;                                         // многофункционального                                            //
                                                           // устройства                                                      //
            P := Pos('DEV', Str);                          // PCIe                                                            //
            if P > 0 then                                  //                                                                 //
              try                                          //                                                                 //
                DevID := StrToInt('$'+Copy(Str, P+4, 4));  //                                                                 //
              except                                       //                                                                 //
                DevID  := 0;                               //                                                                 //
              end;                                         //                                                                 //
          end;                                             //                                                                 //
                                                                                                                              //
          if (VendID = 0) or (DevID = 0) then Continue; // Пропустим, если устройство не определено                           //
                                                                                                                              //
          tKey := Key0+SL[n]+'\';                                                                                             //
          Reg.OpenKeyReadOnly(tKey);                                                                                          //
          Reg.GetKeyNames(tSL1);                                                                                              //
          Reg.CloseKey;                                                                                                       //
          if tSL1.Count > 0 then                                                                                              //
            for i := 0 to tSL1.Count-1 do                                                                                     //
            begin                                                                                                             //
              Str := tSL1[i];                                                                                                 //
              Reg.OpenKeyReadOnly(tKey+tSL1[i]);                                                                              //
              Reg.GetKeyNames(tSL2);                                                                                          //
              Reg.CloseKey;                                                                                                   //
              if tSL2.Count > 0 then                                                                                          //
              begin                                                                                                           //
                for j := 0 to tSL2.Count-1 do                                                                                 //
                begin                                                                                                         //
                  Str := UpperCase(tSL2[j]);                                                                                  //
                                                                                                                              //
                  if Pos('DEVICE PARAMETERS', Str) <> 0 then                                                                  //
                  begin                                                                                                       //
                    Str := Reg.ReadString(tKey+tSL1[i]+'\'+tSL2[j], 'PortName', 'x');                                         //
                                                                                                                              //
                    if Pos('LPT', UpperCase(Str)) <> 0 then // Проверим, что устройство - LPT                                 //
                    begin                                                                                                     //
                      SetLength(LPTPort, Length(LPTPort)+1);                                                                  //
                                                                                                                              //
                      LPTPort[Length(LPTPort)-1].Name     := Str;                                                             //
                      LPTPort[Length(LPTPort)-1].VendorID := VendID;                                                          //
                      LPTPort[Length(LPTPort)-1].DeviceID := DevID;                                                           //
                      LPTPort[Length(LPTPort)-1].RegStr   := SL[n];   // Название для поиска в разделе PCI                    //
                      LPTPort[Length(LPTPort)-1].PrefStr  := tSL1[i]; // Префикс для поиска в разделе PCI                     //
                                                                                                                              //
                      Str := UpperCase(Reg.ReadString(tKey+tSL1[i]+'\', 'FriendlyName', 'x'));                                //
                      LPTPort[Length(LPTPort)-1].FullName := Str;                                                             //
                                                                                                                              //
                      Present := False;                                                                                       //
                                                                                                                              //
                      for m := 0 to tSL2.Count-1 do                                                                           //
                      begin                                                                                                   //
                        Str := UpperCase(tSL2[m]);                                                                            //
                                                                                                                              //
                        if Pos('CONTROL', Str) <> 0 then // Проверим, что устройство присутствует                             //
                        begin                                                                                                 //
                          Reg.OpenKeyReadOnly(tKey+tSL1[i]+'\'+tSL2[m]);                                                      //
                          try                                                                                                 //
                            SetLength(Data, Reg.GetDataSize('AllocConfig')); // узнаем размер данных REG_RESOURCE_LIST        //
                          except                                                                                              //
                            SetLength(Data, 0);                                                                               //
                            Break;                                                                                            //
                          end;                                                                                                //
                                                                                                                              //
                          Reg.ReadBinaryData('AllocConfig', Data[0], Length(Data)); // Считаем их в массив                    //
                                                                                                                              //
//                          LPTPort[Length(LPTPort)-1].BusN  := byte(ReadDWORD(@Data[8])); // Найдем в разделе PCI дальше     //
                          LPTPort[Length(LPTPort)-1].BaseAddr1 := WORD(ReadDWORD(@Data[0], 24)); // Ура!!!                    //
                          LPTPort[Length(LPTPort)-1].BaseAddr2 := WORD(ReadDWORD(@Data[0], 44)); // Ура!!!                    //
                                                                                                                              //
                          Reg.CloseKey;                                                                                       //
                                                                                                                              //
                          Present := True;                                                                                    //
                                                                                                                              //
                          Break;                                                                                              //
                        end;                                                                                                  //
                      end;                                                                                                    //
                                                                                                                              //
                      if not Present then SetLength(LPTPort, Length(LPTPort)-1); // Удалим, если устройство отсутствует       //
                    end;                                                                                                      //
                  end;                                                                                                        //
                end;                                                                                                          //
              end;                                                                                                            //
            end;                                                                                                              //
        end;                                                                                                                  //
                                                                                                                              //
    finally                                                                                                                   //
      Reg.Free;                                                                                                               //
    end;                                                                                                                      //
  except                                                                                                                      //
  end;                                                                                                                        //
                                                                                                                              //
//////////////////// Теперь найдём эти карты в разделе PCI /////////////////////                                              //
                                                                                                                              //
  if Length(LPTPort) <> 0 then                                                                                                //
  begin                                                                                                                       //
    SL.Clear();                                                                                                               //
    tSL1.Clear();                                                                                                             //
    tSL2.Clear();                                                                                                             //
                                                                                                                              //
    Key0 := 'SYSTEM\CurrentControlSet\Enum\PCI\';                                                                             //
    try                                                                                                                       //
      Reg := TRegIniFile.Create('');                                                                                          //
      try                                                                                                                     //
        Reg.RootKey := HKEY_LOCAL_MACHINE;                                                                                    //
                                                                                                                              //
        if (not Reg.KeyExists(Key0)) then Exit;                                                                               //
                                                                                                                              //
        if not Reg.OpenKeyReadOnly(Key0) then Exit;                                                                           //
        Reg.GetKeyNames(SL);                                                                                                  //
        Reg.CloseKey;                                                                                                         //
        if SL.Count > 0 then                                                                                                  //
          for n := 0 to SL.Count-1 do // Цикл PCI устройств                                                                   //
          begin                                                                                                               //
            Str := SL[n];                                                                                                     //
            for j := 0 to Length(LPTPort)-1 do                                                                                //
              if Pos(SL[n], LPTPort[j].RegStr) <> 0 then                                                                      //
              begin                                                                                                           //
                tSL1 := TStringList.Create();                                                                                 //
                                                                                                                              //
                tKey := Key0+SL[n]+'\';                                                                                       //
                if not Reg.OpenKeyReadOnly(tKey) then ShowMessage('!!');                                                      //
                Reg.GetKeyNames(tSL1);                                                                                        //
                Reg.CloseKey;                                                                                                 //
                if tSL1.Count > 0 then                                                                                        //
                  for i := 0 to tSL1.Count-1 do                                                                               //
                  begin                                                                                                       //
                    Str := Reg.ReadString(tKey+tSL1[i], 'ParentIdPrefix', 'x');                                               //
                    if Pos(Str, LPTPort[j].PrefStr) <> 0 then                                                                 //
                    begin                                                                                                     //
                      Str := Reg.ReadString(tKey+tSL1[i], 'LocationInformation', 'x');                                        //
                                                                                                                              //
                      Delete(Str, 1, Pos('(', Str));                                                                          //
                      P := Pos(',', Str);                                                                                     //
                      LPTPort[j].BusN := StrToInt(Copy(Str, 1, P-1));                                                         //
                                                                                                                              //
                      Delete(Str, 1, P);                                                                                      //
                      P := Pos(',', Str);                                                                                     //
                      LPTPort[j].DevN := StrToInt(Copy(Str, 1, P-1));                                                         //
                                                                                                                              //
                      Delete(Str, 1, P);                                                                                      //
                      P := Pos(')', Str);                                                                                     //
                      LPTPort[j].FuncN := StrToInt(Copy(Str, 1, P-1));                                                        //
                    end;                                                                                                      //
                  end;                                                                                                        //
              end;                                                                                                            //
          end;                                                                                                                //
                                                                                                                              //
      finally                                                                                                                 //
        Reg.Free;                                                                                                             //
      end;                                                                                                                    //
    except                                                                                                                    //
    end;                                                                                                                      //
  end;                                                                                                                        //
                                                                                                                              //
  SL.Free();                                                                                                                  //
  tSL1.Free();                                                                                                                //
  tSL2.Free();                                                                                                                //
                                                                                                                              //
  Result := Length(LPTPort);                                                                                                  //
end;                                                                                                                          //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ManageDriver(const DriverId: LPCTSTR; const DriverPath: LPCTSTR; const Func: byte): DWORD; //
var                                                                                                            //
  hSCManager: SC_HANDLE;                                                                                       //
begin                                                                                                          //
  Result := OLS_DLL_NO_ERROR;                                                                                  //
                                                                                                               //
  if (DriverId = nil) or (DriverPath = nil) then                                                               //
  begin                                                                                                        //
    Result := OLS_DLL_DRIVER_INVALID_PARAM;                                                                    //
    Exit;                                                                                                      //
  end;                                                                                                         //
                                                                                                               //
  hSCManager := OpenSCManager(nil, nil, SC_MANAGER_ALL_ACCESS);                                                //
  if hSCManager = 0 then                                                                                       //
  begin                                                                                                        //
    Result := OLS_DLL_DRIVER_SC_MANAGER_NOT_OPENED;                                                            //
    Exit;                                                                                                      //
  end;                                                                                                         //
                                                                                                               //
  case Func of                                                                                                 //
    OLS_DRIVER_INSTALL:                                                                                        //
      if InstallDriver(hSCManager, DriverId, DriverPath) then                                                  //
      begin                                                                                                    //
        if StartDriver(hSCManager, DriverId) then Result := OLS_DLL_NO_ERROR                                   //
        else                                                                                                   //
        begin                                                                                                  //
          Result := OLS_DLL_DRIVER_SC_DRIVER_NOT_STARTED;                                                      //
          Exit;                                                                                                //
        end;                                                                                                   //
      end                                                                                                      //
      else                                                                                                     //
      begin                                                                                                    //
        Result := OLS_DLL_DRIVER_SC_DRIVER_NOT_INSTALLED;                                                      //
        Exit;                                                                                                  //
      end;                                                                                                     //
                                                                                                               //
    OLS_DRIVER_REMOVE:                                                                                         //
      begin                                                                                                    //
        if IsSystemInstallDriver(hSCManager, DriverId) then                                                    //
        begin                                                                                                  //
          StopDriver(hSCManager, DriverId);                                                                    //
          if RemoveDriver(hSCManager, DriverId) then Result := OLS_DLL_NO_ERROR                                //
                                                else Result := OLS_DLL_DRIVER_SC_DRIVER_NOT_REMOVED;           //
        end;                                                                                                   //
      end;                                                                                                     //
{                                                                                                               //
    OLS_DRIVER_SYSTEM_INSTALL:                                                                                 //
      if IsSystemInstallDriver(hSCManager, DriverId) then Result := OLS_DLL_NO_ERROR                           //
      else                                                                                                     //
      begin                                                                                                    //
        if not OpenDriver(DriverId) then                                                                       //
        begin                                                                                                  //
          StopDriver(hSCManager, DriverId);                                                                    //
          RemoveDriver(hSCManager, DriverId);                                                                  //
          if InstallDriver(hSCManager, DriverId, DriverPath) then StartDriver(hSCManager, DriverId);           //
          OpenDriver(DriverId);                                                                                //
        end;                                                                                                   //
                                                                                                               //
        if SystemInstallDriver(hSCManager, DriverId, DriverPath) then Result :=  OLS_DLL_NO_ERROR              //
        else Result := OLS_DLL_DRIVER_SC_DRIVER_NOT_INSTALLED;                                                 //
      end;                                                                                                     //
                                                                                                               //
      OLS_DRIVER_SYSTEM_UNINSTALL:                                                                             //
        if not IsSystemInstallDriver(hSCManager, DriverId) then Result := OLS_DLL_NO_ERROR                     //
        else                                                                                                   //
        begin                                                                                                  //
          if gHandle <> INVALID_HANDLE_VALUE then                                                              //
          begin                                                                                                //
            CloseHandle(gHandle);                                                                              //
            gHandle := INVALID_HANDLE_VALUE;                                                                   //
          end;                                                                                                 //
                                                                                                               //
          if StopDriver(hSCManager, DriverId) then                                                             //
            if RemoveDriver(hSCManager, DriverId) then Result := OLS_DLL_NO_ERROR                              //
                                                  else Result := OLS_DLL_DRIVER_SC_DRIVER_NOT_REMOVED;         //
        end;                                                                                                   //
                                                                                                               //
      else                                                                                                     //
        Result := OLS_DLL_UNKNOWN_ERROR;                                                                       //
}                                                                                                               //
  end;                                                                                                         //
                                                                                                               //
  if hSCManager <> 0 then CloseServiceHandle(hSCManager);                                                      //
end;                                                                                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.InstallDriver(const hSCManager: SC_HANDLE; const DriverId, DriverPath: LPCTSTR): Boolean; //
var                                                                                                           //
  hService: SC_HANDLE;                                                                                        //
begin                                                                                                         //
  Result := False;                                                                                            //
                                                                                                              //
  hService := CreateService(hSCManager,                                                                       //
                            DriverId,                                                                         //
                            DriverId,                                                                         //
                            SERVICE_ALL_ACCESS,                                                               //
                            SERVICE_KERNEL_DRIVER,                                                            //
                            SERVICE_DEMAND_START,                                                             //
                            SERVICE_ERROR_NORMAL,                                                             //
                            DriverPath,                                                                       //
                            nil,                                                                              //
                            nil,                                                                              //
                            nil,                                                                              //
                            nil,                                                                              //
                            nil);                                                                             //
  if hService = 0 then                                                                                        //
  begin                                                                                                       //
    if GetLastError() = ERROR_SERVICE_EXISTS then Result := True;                                             //
  end                                                                                                         //
  else                                                                                                        //
  begin                                                                                                       //
    Result := True;                                                                                           //
    CloseServiceHandle(hService);                                                                             //
  end;                                                                                                        //
end;                                                                                                          //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.SystemInstallDriver(const hSCManager: SC_HANDLE; const DriverId, DriverPath: LPCTSTR): Boolean; //
var                                                                                                                 //
  hService: SC_HANDLE;                                                                                              //
begin                                                                                                               //
  Result := False;                                                                                                  //
                                                                                                                    //
  hService := OpenService(hSCManager, DriverId, SERVICE_ALL_ACCESS);                                                //
  if hService <> 0 then                                                                                             //
  begin                                                                                                             //
    Result := ChangeServiceConfig(hService,                                                                         //
                                  SERVICE_KERNEL_DRIVER,                                                            //
                                  SERVICE_AUTO_START,                                                               //
                                  SERVICE_ERROR_NORMAL,                                                             //
                                  DriverPath,                                                                       //
                                  nil,                                                                              //
                                  nil,                                                                              //
                                  nil,                                                                              //
                                  nil,                                                                              //
                                  nil,                                                                              //
                                  nil);                                                                             //
    CloseServiceHandle(hService);                                                                                   //
  end;                                                                                                              //
end;                                                                                                                //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.RemoveDriver(const hSCManager: SC_HANDLE; const DriverId: LPCTSTR): Boolean; //
var                                                                                              //
  hService: SC_HANDLE;                                                                           //
begin                                                                                            //
  Result := False;                                                                               //
                                                                                                 //
  hService := OpenService(hSCManager, DriverId, SERVICE_ALL_ACCESS);                             //
  if hService = 0 then Result := True                                                            //
  else                                                                                           //
  begin                                                                                          //
    Result := DeleteService(hService);                                                           //
                                                                                                 //
    CloseServiceHandle(hService);                                                                //
  end;                                                                                           //
end;                                                                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.StartDriver(const hSCManager: SC_HANDLE; const DriverId: LPCTSTR): Boolean; //
var                                                                                             //
  hService: SC_HANDLE;                                                                          //
  pcTemp: PChar;                                                                                //
  error: DWORD;                                                                                 //
begin                                                                                           //
  Result := False;                                                                              //
                                                                                                //
  hService := OpenService(hSCManager, DriverId, SERVICE_ALL_ACCESS);                            //
  if hService <> 0 then                                                                         //
  begin                                                                                         //
    pcTemp := nil;                                                                              //
    if not StartService(hService, 0, pcTemp) then                                               //
    begin                                                                                       //
      error := GetLastError();                                                                  //
      if error = ERROR_SERVICE_ALREADY_RUNNING then Result := True;                             //
    end                                                                                         //
    else Result := True;                                                                        //
                                                                                                //
    CloseServiceHandle(hService);                                                               //
  end;                                                                                          //
end;                                                                                            //
//////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.StopDriver(const hSCManager: SC_HANDLE; const DriverId: LPCTSTR): Boolean; //
var                                                                                            //
  hService: SC_HANDLE;                                                                         //
  serviceStatus: SERVICE_STATUS;                                                               //
begin                                                                                          //
  Result := False;                                                                             //
                                                                                               //
  hService := OpenService(hSCManager, DriverId, SERVICE_ALL_ACCESS);                           //
  if hService <> 0 then                                                                        //
  begin                                                                                        //
    Result := ControlService(hService, SERVICE_CONTROL_STOP, serviceStatus);                   //
    CloseServiceHandle(hService);                                                              //
  end;                                                                                         //
end;                                                                                           //
/////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.IsSystemInstallDriver(const hSCManager: SC_HANDLE; const DriverId: LPCTSTR): Boolean; //
var                                                                                                       //
  hService: SC_HANDLE;                                                                                    //
  dwSize: DWORD;                                                                                          //
  lpqsc: PQueryServiceConfig;                                                                             //
begin                                                                                                     //
  Result := False;                                                                                        //
                                                                                                          //
  hService := OpenService(hSCManager, DriverId, SERVICE_ALL_ACCESS);                                      //
  if hService <> 0 then                                                                                   //
  begin                                                                                                   //
    QueryServiceConfig(hService, nil, 0, dwSize);                                                         //
                                                                                                          //
    GetMem(lpqsc, dwSize);                                                                                //
                                                                                                          //
    if QueryServiceConfig(hService, lpqsc, dwSize, dwSize) then                                           //
      if (lpqsc^.dwStartType = SERVICE_AUTO_START) or                                                     //
         (lpqsc^.dwStartType = SERVICE_DEMAND_START) then Result := True;                                 //
                                                                                                          //
    CloseServiceHandle(hService);                                                                         //
                                                                                                          //
    FreeMem(lpqsc);                                                                                       //
  end;                                                                                                    //
end;                                                                                                      //
////////////////////////////////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////
function TLPTDriver.OpenDriver(const DriverId: LPCTSTR): Boolean;  //
begin                                                              //
  Result := False;                                                 //
                                                                   //
  gHandle := CreateFile(PChar('\\.\'+DriverId),                    //
//  gHandle := CreateFile(PChar('\??\'+DriverId),                    //
                        GENERIC_READ or GENERIC_WRITE,             //
                        0,                                         //
                        nil,                                       //
                        OPEN_EXISTING,                             //
                        FILE_ATTRIBUTE_NORMAL,                     //
                        0);                                        //
                                                                   //
  if gHandle <> INVALID_HANDLE_VALUE then Result := True;          //
end;                                                               //
/////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadIoPortByte(const port: WORD): byte;                      //
var                                                                              //
  returnedLength: DWORD;                                                         //
begin                                                                            //
  Result := 0;                                                                   //
                                                                                 //
	if (gHandle = 0) or                                                            //
     (gHandle = INVALID_HANDLE_VALUE) then Exit;                                 //
                                                                                 //
	if not DeviceIoControl(gHandle,                                                //
                         IOCTL_OLS_READ_IO_PORT_BYTE,                            //
                         @port,                                                  //
                         sizeof(port),                                           //
                         @Result,                                                //
                         sizeof(Result),                                         //
                         returnedLength,                                         //
                         nil) then ErrMess('Ошибка: '+IntToStr(GetLastError())); //
end;                                                                             //
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadIoPortWORD(const port: WORD): WORD;                      //
var                                                                              //
  returnedLength: DWORD;                                                         //
begin                                                                            //
  Result := 0;                                                                   //
                                                                                 //
	if (gHandle = 0) or                                                            //
     (gHandle = INVALID_HANDLE_VALUE) then Exit;                                 //
                                                                                 //
	if not DeviceIoControl(gHandle,                                                //
                         IOCTL_OLS_READ_IO_PORT_WORD,                            //
                         @port,                                                  //
                         sizeof(port),                                           //
                         @Result,                                                //
                         sizeof(Result),                                         //
                         returnedLength,                                         //
                         nil) then ErrMess('Ошибка: '+IntToStr(GetLastError())); //
end;                                                                             //
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadIoPortDWORD(const port: WORD): DWORD;                    //
var                                                                              //
  returnedLength: DWORD;                                                         //
  port4: DWORD;                                                                  //
begin                                                                            //
  Result := 0;                                                                   //
                                                                                 //
	if (gHandle = 0) or                                                            //
     (gHandle = INVALID_HANDLE_VALUE) then Exit;                                 //
                                                                                 //
  port4 := port;                                                                 //
                                                                                 //
	if not DeviceIoControl(gHandle,                                                //
                         IOCTL_OLS_READ_IO_PORT_DWORD,                           //
                         @port4,                                                 //
                         sizeof(port4),	// required 4 bytes                      //
                         @Result,                                                //
                         sizeof(Result),                                         //
                         returnedLength,                                         //
                         nil) then ErrMess('Ошибка: '+IntToStr(GetLastError())); //
end;                                                                             //
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteIoPortByte(const port: WORD; const value: byte);       //
var                                                                              //
  returnedLength: DWORD;                                                         //
  length: DWORD;                                                                 //
  inBuf: OLS_WRITE_IO_PORT_INPUT;                                                //
begin                                                                            //
	if (gHandle = 0) or                                                            //
     (gHandle = INVALID_HANDLE_VALUE) then Exit;                                 //
                                                                                 //
	returnedLength := 0;                                                           //
	length := 0;                                                                   //
                                                                                 //
	inBuf.ByteData   := value;                                                     //
	inBuf.PortNumber := port;                                                      //
  length := SizeOf(DWORD)+SizeOf(byte);                                          //
                                                                                 //
	if not DeviceIoControl(gHandle,                                                //
                         IOCTL_OLS_WRITE_IO_PORT_BYTE,                           //
                         @inBuf,                                                 //
                         length,                                                 //
                         nil,                                                    //
                         0,                                                      //
                         returnedLength,                                         //
                         nil) then ErrMess('Ошибка: '+IntToStr(GetLastError())); //
end;                                                                             //
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteIoPortWORD(const port: WORD; const value: WORD);       //
var                                                                              //
  returnedLength: DWORD;                                                         //
  length: DWORD;                                                                 //
  inBuf: OLS_WRITE_IO_PORT_INPUT;                                                //
begin                                                                            //
	if (gHandle = 0) or                                                            //
     (gHandle = INVALID_HANDLE_VALUE) then Exit;                                 //
                                                                                 //
	returnedLength := 0;                                                           //
	length := 0;                                                                   //
                                                                                 //
	inBuf.WORDData  := value;                                                      //
	inBuf.PortNumber := port;                                                      //
  length := SizeOf(DWORD)+SizeOf(WORD);                                          //
                                                                                 //
	if not DeviceIoControl(gHandle,                                                //
                         IOCTL_OLS_WRITE_IO_PORT_WORD,                           //
                         @inBuf,                                                 //
                         length,                                                 //
                         nil,                                                    //
                         0,                                                      //
                         returnedLength,                                         //
                         nil) then ErrMess('Ошибка: '+IntToStr(GetLastError())); //
end;                                                                             //
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteIoPortDWORD(const port: WORD; const value: DWORD);     //
var                                                                              //
  returnedLength: DWORD;                                                         //
  length: DWORD;                                                                 //
  inBuf: OLS_WRITE_IO_PORT_INPUT;                                                //
begin                                                                            //
	if (gHandle = 0) or                                                            //
     (gHandle = INVALID_HANDLE_VALUE) then Exit;                                 //
                                                                                 //
	returnedLength := 0;                                                           //
	length := 0;                                                                   //
                                                                                 //
	inBuf.DWORDData   := value;                                                    //
	inBuf.PortNumber  := port;                                                     //
  length := SizeOf(DWORD)+SizeOf(DWORD);                                         //
                                                                                 //
	if not DeviceIoControl(gHandle,                                                //
                         IOCTL_OLS_WRITE_IO_PORT_DWORD,                          //
                         @inBuf,                                                 //
                         length,                                                 //
                         nil,                                                    //
                         0,                                                      //
                         returnedLength,                                         //
                         nil) then ErrMess('Ошибка: '+IntToStr(GetLastError())); //
end;                                                                             //
///////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadByte(const port: WORD): byte;                              //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
  begin                                                                            //
    if (port = BaseAddr+0) or   // PIR/PDR                                         //
       (port = BaseAddr+1) or   // PSR                                             //
       (port = BaseAddr+2) then // PCR                                             //
    begin                                                                          //
      Result := ReadIoPortByte(port);                                              //
                                                                                   //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+3 then // EPP Addr read byte                                //
      if EPPMode then                                                              //
      begin                                                                        //
        Result := ReadIoPortByte(port);                                            //
                                                                                   //
        Exit;                                                                      //
      end                                                                          //
      else                                                                         //
      begin                                                                        //
        WriteIoPortByte(BaseAddr+2, $2C);                                          //
        Result := ReadIoPortByte(BaseAddr+0);                                      //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        Exit;                                                                      //
      end;                                                                         //
                                                                                   //
    if port = BaseAddr+4 then // EPP Data read byte                                //
      if EPPMode then                                                              //
      begin                                                                        //
        Result := ReadIoPortByte(port);                                            //
                                                                                   //
        Exit;                                                                      //
      end                                                                          //
      else                                                                         //
      begin                                                                        //
        WriteIoPortByte(BaseAddr+2, $26);                                          //
        Result := ReadIoPortByte(BaseAddr+0);                                      //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        Exit;                                                                      //
      end;                                                                         //
  end;                                                                             //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadWORD(const port: WORD): WORD;                              //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
    if port = BaseAddr+5 then // EPP Data read WORD                                //
      if EPPMode then                                                              //
      begin                                                                        //
        Result := ReadIoPortByte(port);                                            //
                                                                                   //
        Exit;                                                                      //
      end                                                                          //
      else                                                                         //
      begin                                                                        //
        WriteIoPortByte(BaseAddr+2, $26);                                          //
        Result := ReadIoPortByte(BaseAddr+0);                                      //
        WriteIoPortByte(BaseAddr+2, $24);                                          //
                                                                                   //
        WriteIoPortByte(BaseAddr+2, $26);                                          //
        Result := (Result shl 8)+ReadIoPortByte(BaseAddr+0);                       //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        Exit;                                                                      //
      end;                                                                         //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadDWORD(const port: WORD): DWORD;                            //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
    if port = BaseAddr+7 then // EPP Data read WORD                                //
      if EPPMode then                                                              //
      begin                                                                        //
        Result := ReadIoPortByte(port);                                            //
                                                                                   //
        Exit;                                                                      //
      end                                                                          //
      else                                                                         //
      begin                                                                        //
        WriteIoPortByte(BaseAddr+2, $26);                                          //
        Result := ReadIoPortByte(BaseAddr+0);                                      //
        WriteIoPortByte(BaseAddr+2, $24);                                          //
                                                                                   //
        WriteIoPortByte(BaseAddr+2, $26);                                          //
        Result := (Result shl 8)+ReadIoPortByte(BaseAddr+0);                       //
        WriteIoPortByte(BaseAddr+2, $24);                                          //
                                                                                   //
        WriteIoPortByte(BaseAddr+2, $26);                                          //
        Result := (Result shl 8)+ReadIoPortByte(BaseAddr+0);                       //
        WriteIoPortByte(BaseAddr+2, $24);                                          //
                                                                                   //
        WriteIoPortByte(BaseAddr+2, $26);                                          //
        Result := (Result shl 8)+ReadIoPortByte(BaseAddr+0);                       //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        Exit;                                                                      //
      end;                                                                         //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteByte(const port: WORD; const Data: byte);                //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
  begin                                                                            //
    if (port = BaseAddr+0) or   // PIR/PDR                                         //
       (port = BaseAddr+2) then // PCR                                             //
    begin                                                                          //
      WriteIoPortByte(port, Data);                                                 //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+3 then // EPP Addr write byte                               //
      if EPPMode then                                                              //
      begin                                                                        //
        WriteIoPortByte(port, Data);                                               //
                                                                                   //
        Exit;                                                                      //
      end                                                                          //
      else                                                                         //
      begin                                                                        //
        WriteIoPortByte(BaseAddr+2, $0D);                                          //
        WriteIoPortByte(BaseAddr+0, Data);                                         //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        Exit;                                                                      //
      end;                                                                         //
                                                                                   //
    if port = BaseAddr+4 then // EPP Data write byte                               //
      if EPPMode then                                                              //
      begin                                                                        //
        WriteIoPortByte(port, Data);                                               //
                                                                                   //
        Exit;                                                                      //
      end                                                                          //
      else                                                                         //
      begin                                                                        //
        WriteIoPortByte(BaseAddr+2, $07);                                          //
        WriteIoPortByte(BaseAddr+0, Data);                                         //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        Exit;                                                                      //
      end;                                                                         //
  end;                                                                             //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteWORD(const port: WORD; const Data: WORD);                //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
    if (port = BaseAddr+4) or   // EPP Data write byte ????
       (port = BaseAddr+5) then // EPP Data write WORD                             //
      if EPPMode then                                                              //
      begin                                                                        //
        WriteIoPortWORD(port, Data);                                               //
        Exit;                                                                      //
      end                                                                          //
      else                                                                         //
      begin                                                                        //
        WriteIoPortByte(BaseAddr+2, $07);                                          //
        WriteIoPortByte(BaseAddr+0, byte(Data shr 8));                             //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        WriteIoPortByte(BaseAddr+2, $07);                                          //
        WriteIoPortByte(BaseAddr+0, byte(Data));                                   //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        Exit;                                                                      //
      end;                                                                         //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteDWORD(const port: WORD; const Data: WORD);               //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
    if (port = BaseAddr+4) or   // EPP Data write byte ????
       (port = BaseAddr+7) then // EPP Data write DWORD                            //
      if EPPMode then                                                              //
      begin                                                                        //
        WriteIoPortDWORD(port, Data);                                              //
        Exit;                                                                      //
      end                                                                          //
      else                                                                         //
      begin                                                                        //
        WriteIoPortByte(BaseAddr+2, $07);                                          //
        WriteIoPortByte(BaseAddr+0, byte(Data shr 24));                            //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        WriteIoPortByte(BaseAddr+2, $07);                                          //
        WriteIoPortByte(BaseAddr+0, byte(Data shr 16));                            //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        WriteIoPortByte(BaseAddr+2, $07);                                          //
        WriteIoPortByte(BaseAddr+0, byte(Data shr 8));                             //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        WriteIoPortByte(BaseAddr+2, $07);                                          //
        WriteIoPortByte(BaseAddr+0, byte(Data));                                   //
        WriteIoPortByte(BaseAddr+2, $04);                                          //
                                                                                   //
        Exit;                                                                      //
      end;                                                                         //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadCH382LIoPortByte(const port: WORD): byte;                  //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
  begin                                                                            //
    if port = BaseAddr+0 then // PIR/PDR                                           //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $00); // PXR (Режим SPP)                         //
      WriteIoPortByte(BaseAddr+2, $C4); // PCR (Режим чтения)                      //
      Result := ReadIoPortByte(BaseAddr+0);                                        //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+1 then // PSR                                               //
    begin                                                                          //
      Result := ReadIoPortByte(BaseAddr+1);                                        //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+2 then // PCR                                               //
    begin                                                                          //
      Result := ReadIoPortByte(BaseAddr+2);                                        //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+3 then // EPP Addr_read                                     //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $0C); // PXR (Режим EPP+Addr)                    //
      WriteIoPortByte(BaseAddr+2, $C4); // PCR (Режим чтения)                      //
      Result := ReadIoPortByte(BaseAddr+0);                                        //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+4 then // EPP Data_read                                     //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $04); // PXR (Режим EPP+Addr)                    //
      WriteIoPortByte(BaseAddr+2, $C4); // PCR (Режим чтения)                      //
      Result := ReadIoPortByte(BaseAddr+0);                                        //
      Exit;                                                                        //
    end;                                                                           //
  end;                                                                             //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadCH382LIoPortWord(const port: WORD): WORD;                  //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
    if port = BaseAddr+5 then // EPP Data_read                                     //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $04); // PXR (Режим EPP+Data)                    //
      WriteIoPortByte(BaseAddr+2, $C4); // PCR (Режим чтения)                      //
      Result := ReadIoPortByte(BaseAddr+0);                                        //
      Result := (Result shl 8)+ReadIoPortByte(BaseAddr+0);

      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.ReadCH382LIoPortDWORD(const port: WORD): DWORD;                //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
    if port = BaseAddr+7 then // EPP Data_read                                     //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $04); // PXR (Режим EPP+Addr)                    //
      WriteIoPortByte(BaseAddr+2, $C0); // PCR (Режим чтения)                      //
      Result := ReadIoPortByte(BaseAddr+0);                                        //
      Result := Result+(ReadIoPortByte(BaseAddr+0) shl  8);                        //
      Result := Result+(ReadIoPortByte(BaseAddr+0) shl 16);                        //
      Result := Result+(ReadIoPortByte(BaseAddr+0) shl 24);                        //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteCH382LIoPortByte(const port: WORD; const value: byte);   //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
  begin                                                                            //
    if port = BaseAddr+0 then // PIR/PDR                                           //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $00); // PXR (Режим SPP)                         //
      WriteIoPortByte(BaseAddr+2, $E4); // PCR (Режим записи)                      //
      WriteIoPortByte(BaseAddr+0, value);                                          //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+2 then // PCR                                               //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+2, value);                                          //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+3 then // EPP Addr_write                                    //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $0C); // PXR (Режим EPP+Addr)                    //
      WriteIoPortByte(BaseAddr+2, $E4); // PCR (Режим записи)                      //
      WriteIoPortByte(BaseAddr+0, value);                                          //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
    if port = BaseAddr+4 then // EPP Data_write                                    //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $04); // PXR (Режим EPP+Data)                    //
      WriteIoPortByte(BaseAddr+2, $E4); // PCR (Режим записи)                      //
      WriteIoPortByte(BaseAddr+0, value);                                          //
      Exit;                                                                        //
    end;                                                                           //
  end;                                                                             //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteCH382LIoPortWORD(const port: WORD; const value: WORD);   //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
    if port = BaseAddr+5 then // EPP Data_write                                    //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $04); // PXR (Режим EPP+Addr)                    //
      WriteIoPortByte(BaseAddr+2, $E4); // PCR (Режим записи)                      //
      WriteIoPortByte(BaseAddr+0, byte(value shr 8));                              //
      WriteIoPortByte(BaseAddr+0, byte(value));                                    //

      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.WriteCH382LIoPortDWORD(const port: WORD; const value: DWORD); //
begin                                                                              //
  with LPTPort[NumPort] do                                                         //
    if port = BaseAddr+7 then // EPP Data_write                                    //
    begin                                                                          //
      WriteIoPortByte(BaseAddr+3, $04); // PXR (Режим EPP+Addr)                    //
      WriteIoPortByte(BaseAddr+2, $E0); // PCR (Режим записи)                      //
      WriteIoPortByte(BaseAddr+0, byte(value));                                    //
      WriteIoPortByte(BaseAddr+0, byte(value shr  8));                             //
      WriteIoPortByte(BaseAddr+0, byte(value shr 16));                             //
      WriteIoPortByte(BaseAddr+0, byte(value shr 24));                             //
      Exit;                                                                        //
    end;                                                                           //
                                                                                   //
  ErrMess('Неправильный адрес!');                                                  //
end;                                                                               //
/////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////
procedure TLPTDriver.FillPCIReg();                                                   //
var                                                                                  //
  n, i: byte;                                                                        //
  Data: DWORD;                                                                       //
  Data1, Data2, Data3, Data4: byte;                                                  //
  Write_Address: DWORD;                                                              //
  Read_Address : DWORD;                                                              //
  FuncNum, DevNum, BusNum: byte;                                                     //
begin                                                                                //
  Write_Address := $0CF8;                                                            //
  Read_Address  := $0CFC;                                                            //
                                                                                     //
                                                                                     //
  for n := 0 to Length(LPTPort)-1 do                                                 //
    with LPTPort[n] do                                                               //
    begin                                                                            //
      BusNum  := BusN;                                                               //
      DevNum  := DevN;                                                               //
      FuncNum := FuncN;                                                              //
                                                                                     //
      for i := 0 to 11 do // Пройдёмся по BARам                                      //
      begin                                                                          //
        Data := $80000000+(BusNum shl 16)+(DevNum shl 11)+(FuncNum shl 8)+(i shl 2); //
        WriteIOPortDword(Write_Address, Data);                                       //
        Data := ReadIOPortDword(Read_Address);                                       //
        Data1 := byte(Data);                                                         //
        Data2 := byte(Data shr 8);                                                   //
        Data3 := byte(Data shr 16);                                                  //
        Data4 := byte(Data shr 24);                                                  //
                                                                                     //
        with PCIBARReg do                                                            //
          case i of                                                                  //
             0: begin                                                                //
                  VendorID := Data1+(Data2 shl 8);                                   //
                  DeviceID := Data3+(Data4 shl 8);                                   //
                end;                                                                 //
             1: begin                                                                //
                  Command := Data1+(Data2 shl 8);;                                   //
                  Status  := Data3+(Data4 shl 8);;                                   //
                end;                                                                 //
             2: begin                                                                //
                  RevisionID := Data1;                                               //
                  ClassCode  := Data2+(Data3 shl 8)+(Data4 shl 16);                  //
                end;                                                                 //
             3: Undef1 := Data;                                                      //
             4: IOBaseAddr0 := Data;                                                 //
             5: IOBaseAddr1 := Data;                                                 //
             6: IOBaseAddr2 := Data;                                                 //
             7: IOBaseAddr3 := Data;                                                 //
             8: IOBaseAddr4 := Data;                                                 //
             9: IOBaseAddr5 := Data;                                                 //
            10: IOBaseAddr6 := Data;                                                 //
            11: begin                                                                //
                  subVendorID := Data1+(Data2 shl 8);                                //
                  subDeviceID := Data3+(Data4 shl 8);                                //
                end;                                                                 //
          end;                                                                       //
      end;                                                                           //
    end;                                                                             //
end;                                                                                 //
///////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.CTL_CODE(const DeviceType, FuncNo, Method, Access: DWORD): DWORD;  //
begin                                                                                  //
  Result := (DeviceType shl 16)+(Access shl 14)+(FuncNo shl 2)+(Method);               //
end;                                                                                   //
/////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.IsWow64(): Boolean;                                               //
var                                                                                   //
  Res: BOOL;                                                                          //
  IsWow64Process: function(hProcess: THandle; var Wow64Process: BOOL): BOOL; stdcall; //
  DLLHandle: THandle;                                                                 //
begin                                                                                 //
  Res := False;                                                                       //
                                                                                      //
  IsWow64Process := nil;                                                              //
  try                                                                                 //
    DLLHandle := LoadLibrary('kernel32.dll');                                         //
    if DLLHandle <> 0 then                                                            //
    begin                                                                             //
      IsWow64Process := GetProcAddress(DLLHandle, 'IsWow64Process');                  //
      if Assigned(IsWow64Process) then IsWow64Process(GetCurrentProcess, Res);        //
    end;                                                                              //
                                                                                      //
  finally                                                                             //
    FreeLibrary(DLLHandle);                                                           //
  end;                                                                                //
                                                                                      //
  Result := Boolean(Res);                                                             //
end;                                                                                  //
////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
function TLPTDriver.IsX64(): Boolean;                                                         //
var                                                                                           //
  SysInfo: TSystemInfo;                                                                       //
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;                     //
  DLLHandle: THandle;                                                                         //
begin                                                                                         //
  Result := False;                                                                            //
                                                                                              //
  GetNativeSystemInfo := nil;                                                                 //
  try                                                                                         //
    DLLHandle := LoadLibrary('kernel32.dll');                                                 //
    if DLLHandle <> 0 then                                                                    //
    begin                                                                                     //
      GetNativeSystemInfo := GetProcAddress(DLLHandle, 'GetNativeSystemInfo');                //
      if Assigned(GetNativeSystemInfo) then                                                   //
      begin                                                                                   //
        GetNativeSystemInfo(SysInfo);                                                         //
        if SysInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64 then Result := True; //
      end;                                                                                    //
    end;                                                                                      //
                                                                                              //
  finally                                                                                     //
    FreeLibrary(DLLHandle);                                                                   //
  end;                                                                                        //
end;                                                                                          //
////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
function TLPTDriver.GetWinName: string;                                    //
var                                                                        //
  Reg: TRegistry;                                                          //
begin                                                                      //
  Result := '';                                                            //
                                                                           //
  Reg := TRegistry.Create(KEY_READ);                                       //
  try                                                                      //
    Reg.RootKey := HKEY_LOCAL_MACHINE;                                     //
                                                                           //
    Reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows\CurrentVersion');      //
    Result := reg.ReadString('ProductName');                               //
                                                                           //
    if Result = '' then                                                    //
    begin                                                                  //
      Reg.CloseKey;                                                        //
      Reg.OpenKeyReadOnly('SOFTWARE\Microsoft\Windows NT\CurrentVersion'); //
      Result := reg.ReadString('ProductName');                             //
    end;                                                                   //
                                                                           //
  finally                                                                  //
    Reg.Free;                                                              //
  end;                                                                     //
end;                                                                       //
/////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////
procedure TLPTDriver.ErrMess(const ErrMes: String);              //
begin                                                            //
  MessageBox(0, PChar(ErrMes), 'Ошибка!!!', MB_ICONERROR+MB_OK); //
end;                                                             //
///////////////////////////////////////////////////////////////////


end.
