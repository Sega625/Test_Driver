unit uTestDrv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, LPTDrv, StdCtrls, ComCtrls;

type
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
    Undef41    : DWORD;
    Undef42    : DWORD;
    Undef43    : DWORD;
    InteruptLinePin: DWORD;
  end;

  TForm1 = class(TForm)
    InstallDRVBtn: TButton;
    RemoveDRVBtn: TButton;
    OpenDRVBtn: TButton;
    GroupBox1: TGroupBox;
    ReadByteEdit: TEdit;
    ReadByteBtn: TButton;
    WriteByteEdit: TEdit;
    WriteByteBtn: TButton;
    WriteWORDEdit: TEdit;
    WriteWORDBtn: TButton;
    WriteDWORDEdit: TEdit;
    WriteDWORDBtn: TButton;
    ReadWORDBtn: TButton;
    ReadWORDEdit: TEdit;
    ReadDWORDBtn: TButton;
    ReadDWORDEdit: TEdit;
    WriteBARBtn: TButton;
    ReadBARBtn: TButton;
    Label1: TLabel;
    WAddrEdit: TEdit;
    All0Btn: TButton;
    All1Btn: TButton;
    MemLV: TListView;
    RAddrEdit: TEdit;
    Label20: TLabel;
    sRegLV: TListView;
    ReadPCIBtn: TButton;
    InstallStatLab: TLabel;
    RemoveStatLab: TLabel;
    OpenStatLab: TLabel;
    LPTPortsCB: TComboBox;
    PortLab: TLabel;
    ReadPCI2Btn: TButton;
    
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure InstallDRVBtnClick(Sender: TObject);
    procedure RemoveDRVBtnClick(Sender: TObject);
    procedure OpenDRVBtnClick(Sender: TObject);
    procedure ReadByteBtnClick(Sender: TObject);
    procedure WriteByteBtnClick(Sender: TObject);
    procedure ReadWORDBtnClick(Sender: TObject);
    procedure ReadDWORDBtnClick(Sender: TObject);
    procedure WriteWORDBtnClick(Sender: TObject);
    procedure WriteDWORDBtnClick(Sender: TObject);
    procedure WriteBARBtnClick(Sender: TObject);
    procedure ReadBARBtnClick(Sender: TObject);
    procedure ReadPCIBtnClick(Sender: TObject);
    procedure LPTPortsCBChange(Sender: TObject);
    procedure All0BtnClick(Sender: TObject);
    procedure All1BtnClick(Sender: TObject);
    procedure ReadPCI2BtnClick(Sender: TObject);
  private
    BaseAddr: DWORD;
    L: array [0..31] of TLabel;
    PCIReg: TPCIReg;

    function  GetDataFromLabs: Int64;
    procedure LBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function  ByteToStr(Val: byte; Digits: byte=8): String;
  public
    LPTDriver: TLPTDriver;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  n, offset: byte;
begin
  LPTDriver := TLPTDriver.Create();

  if Length(LPTDriver.LPTPort) > 0 then
  begin
    for n := 0 to Length(LPTDriver.LPTPort)-1 do
      LPTPortsCB.Items.Add(LPTDriver.LPTPort[n].Name);
    LPTPortsCB.ItemIndex := 0;
  end
  else
    Application.Terminate();
    
  LPTPortsCBChange(self);

  offset := 0;
  for n := 0 to 31 do
  begin
    L[n] := TLabel.Create(self);
    with L[n] do
    begin
      if (n mod 4) = 0 then Inc(offset, 4);
      Left := 560+n*9+offset;
      Top  := 110;
      Parent := Form1;

      Font.Size := 12;
      Font.Color := clBlue;
      Font.Style := [fsBold];
      Caption := '0';

      Tag := n;

      OnMouseDown := LBtnMouseDown;
    end;
  end;

  MemLV.Columns[0].Width := 50;
  MemLV.Columns[0].MaxWidth := 50;
  MemLV.Columns[0].MinWidth := 50;
  MemLV.Columns[1].Width := 80;
  MemLV.Columns[1].MaxWidth := 80;
  MemLV.Columns[1].MinWidth := 80;
  for n := 2 to 5 do
  begin
    MemLV.Columns[n].Width := 75;
    MemLV.Columns[n].MaxWidth := 75;
    MemLV.Columns[n].MinWidth := 75;
  end;
  MemLV.Columns[6].Width := 80;
  MemLV.Columns[6].MaxWidth := 80;
  MemLV.Columns[6].MinWidth := 80;

  sRegLV.Columns[0].Width := 50;
  sRegLV.Columns[0].MaxWidth := 50;
  sRegLV.Columns[0].MinWidth := 50;
  sRegLV.Columns[1].Width := 150;
  sRegLV.Columns[1].MaxWidth := 150;
  sRegLV.Columns[1].MinWidth := 150;
  sRegLV.Columns[2].Width := 150;
  sRegLV.Columns[2].MaxWidth := 150;
  sRegLV.Columns[2].MinWidth := 150;

  InstallStatLab.Caption := '';
  RemoveStatLab.Caption  := '';
  OpenStatLab.Caption    := '';
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  LPTDriver.Free();
end;

procedure TForm1.InstallDRVBtnClick(Sender: TObject);
var
  Err: DWORD;
begin
{
  Err := Driver.ManageDriver(PChar(Driver.DrvID), PChar(Driver.DrvPath), OLS_DRIVER_INSTALL);
  if Err <> 0 then
  begin
    InstallStatLab.Font.Color := clRed;
    InstallStatLab.Caption := 'Error '+IntToStr(Err);
  end
  else
  begin
    InstallStatLab.Font.Color := clGreen;
    InstallStatLab.Caption := 'OK!';
  end;
}
end;


procedure TForm1.RemoveDRVBtnClick(Sender: TObject);
var
  Err: DWORD;
begin
{
  Err := Driver.ManageDriver(PChar(Driver.DrvID), PChar(Driver.DrvPath), OLS_DRIVER_REMOVE);
  if Err <> 0 then
  begin
    RemoveStatLab.Font.Color := clRed;
    RemoveStatLab.Caption := 'Error '+IntToStr(Err);
  end
  else
  begin
    RemoveStatLab.Font.Color := clGreen;
    RemoveStatLab.Caption := 'OK!';
  end;
}
end;


procedure TForm1.OpenDRVBtnClick(Sender: TObject);
begin
{
  if not Driver.OpenDriver(PChar(Driver.DrvID)) then
  begin
    OpenStatLab.Font.Color := clRed;
    OpenStatLab.Caption := 'Error ';
  end
  else
  begin
    OpenStatLab.Font.Color := clGreen;
    OpenStatLab.Caption := 'OK!';
  end;
}  
end;



procedure TForm1.ReadByteBtnClick(Sender: TObject);
begin
  ReadByteEdit.Text := IntToHex(LPTDriver.ReadIoPortByte(BaseAddr), 2);
end;

procedure TForm1.ReadWORDBtnClick(Sender: TObject);
begin
  ReadWORDEdit.Text := IntToHex(LPTDriver.ReadIoPortWORD(BaseAddr), 4);
end;

procedure TForm1.ReadDWORDBtnClick(Sender: TObject);
begin
  ReadDWORDEdit.Text := IntToHex(LPTDriver.ReadIoPortDWORD(BaseAddr), 8);
end;

procedure TForm1.WriteByteBtnClick(Sender: TObject);
begin
  LPTDriver.WriteIoPortByte(BaseAddr, StrToInt(WriteByteEdit.Text));
end;


procedure TForm1.WriteWORDBtnClick(Sender: TObject);
begin
  LPTDriver.WriteIoPortWORD(BaseAddr, StrToInt(WriteWORDEdit.Text));
end;

procedure TForm1.WriteDWORDBtnClick(Sender: TObject);
begin
  LPTDriver.WriteIoPortDWORD(BaseAddr, StrToInt(WriteDWORDEdit.Text));
end;

procedure TForm1.WriteBARBtnClick(Sender: TObject);
var
  Data: Int64;
  Address: ULONG;

begin
  Address := StrToInt64('$'+WAddrEdit.Text);
  Data := DWORD(GetDataFromLabs());

  LPTDriver.WriteIoPortDword(Address, Data);
end;

procedure TForm1.ReadBARBtnClick(Sender: TObject);
var
  n, i: DWORD;
  Data: ULONG;
  Address: ULONG;
  Str: String;
begin
  MemLV.Clear;

  Address := StrToInt64('$'+RAddrEdit.Text);
  for i := 0 to 15 do
  begin
    MemLV.Items.Add.Caption := IntToStr(i+1);

    Str := '';
    MemLV.Items[MemLV.Items.Count-1].SubItems.add(IntToHex(Address, 8)); 
    Data := LPTDriver.ReadIoPortDword(Address);

    for n := 0 to 3 do
    begin
      MemLV.Items[MemLV.Items.Count-1].SubItems.add(ByteToStr(Data and $FF));
      if (Data and $FF) <> 0 then Str := Str+Chr(Data and $FF)
                             else Str := Str+' ';
      Data := Data shr 8;
    end;
    MemLV.Items[MemLV.Items.Count-1].SubItems.add(Str);

    if Address = $FFFFFFFF then Break;

    Inc(Address, 4);
  end;
end;


procedure TForm1.All0BtnClick(Sender: TObject);
var
  n: byte;
begin
  for n := 0 to 31 do
  begin
    L[n].Caption := '0';
  end;
end;

procedure TForm1.All1BtnClick(Sender: TObject);
var
  n: byte;
begin
  for n := 0 to 31 do
  begin
    L[n].Caption := '1';
  end;
end;

procedure TForm1.ReadPCIBtnClick(Sender: TObject);
var
  n, i: DWORD;
  Data: DWORD;
  Data1, Data2, Data3, Data4, tData: byte;
  Write_Address: DWORD;
  Read_Address: DWORD;
  RegNum, FuncNum, DevNum, BusNum: byte;
begin
  sRegLV.Clear;

  Write_Address := $0CF8;
  Read_Address  := $0CFC;

  n := LPTPortsCB.ItemIndex;
  BusNum  := LPTDriver.LPTPort[n].BusN;
  DevNum  := LPTDriver.LPTPort[n].DevN;
  FuncNum := LPTDriver.LPTPort[n].FuncN;

  for i := 0 to 31 do
  begin
//    RegLV.Items.Add.Caption := IntToStr(i);
    Regnum  := i;
    Data := $80000000+(BusNum shl 16)+(DevNum shl 11)+(FuncNum shl 8)+(Regnum shl 2);
    LPTDriver.WriteIOPortDword(Write_Address, Data);
    Data := LPTDriver.ReadIOPortDword(Read_Address);
    Data1 := byte(Data);
    Data2 := byte(Data shr 8);
    Data3 := byte(Data shr 16);
    Data4 := byte(Data shr 24);

    case i of
       0: begin
            PCIReg.VendorID := Data1+(Data2 shl 8);
            sRegLV.Items.Add.Caption := '$00';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('VendorID');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.VendorID, 4));
                 PCIReg.DeviceID := Data3+(Data4 shl 8);
            sRegLV.Items.Add.Caption := '$02';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('DeviceID');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.DeviceID, 4));
          end;
       1: begin
            PCIReg.Command := Data1+(Data2 shl 8);;
            sRegLV.Items.Add.Caption := '$04';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Command');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.Command, 4));
                 PCIReg.Status := Data3+(Data4 shl 8);;
            sRegLV.Items.Add.Caption := '$06';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Status');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.Status, 4));
          end;
       2: begin
            PCIReg.RevisionID := Data1;
            sRegLV.Items.Add.Caption := '$08';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('RevisionID');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.RevisionID, 2));
                 PCIReg.ClassCode := Data2+(Data3 shl 8)+(Data4 shl 16);
            sRegLV.Items.Add.Caption := '$09';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('ClassCode');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.ClassCode, 6));
          end;
       3: begin
            PCIReg.Undef1 := Data;
            sRegLV.Items.Add.Caption := '$0C';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Undef1');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.Undef1, 8));
          end;
       4: begin
            PCIReg.IOBaseAddr0 := Data;
            sRegLV.Items.Add.Caption := '$10';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr0');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.IOBaseAddr0, 8));
          end;
       5: begin
            PCIReg.IOBaseAddr1 := Data;
            sRegLV.Items.Add.Caption := '$14';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr1');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.IOBaseAddr1, 8));
          end;
       6: begin
            PCIReg.IOBaseAddr2 := Data;
            sRegLV.Items.Add.Caption := '$18';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr2');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.IOBaseAddr2, 8));
          end;
       7: begin
            PCIReg.IOBaseAddr3 := Data;
            sRegLV.Items.Add.Caption := '$1C';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr3');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.IOBaseAddr3, 8));
          end;
       8: begin
            PCIReg.IOBaseAddr4 := Data;
            sRegLV.Items.Add.Caption := '$20';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr4');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.IOBaseAddr4, 8));
          end;
       9: begin
            PCIReg.IOBaseAddr5 := Data;
            sRegLV.Items.Add.Caption := '$24';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr5');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.IOBaseAddr5, 8));
          end;
      10: begin
            PCIReg.IOBaseAddr6 := Data;
            sRegLV.Items.Add.Caption := '$28';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr6');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.IOBaseAddr6, 8));
          end;
      11: begin
            PCIReg.subVendorID := Data1+(Data2 shl 8);
            sRegLV.Items.Add.Caption := '$2C';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('subVendorID');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.subVendorID, 4));
                 PCIReg.subDeviceID := Data3+(Data4 shl 8);
            sRegLV.Items.Add.Caption := '$2E';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('subDeviceID');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.subDeviceID, 4));
          end;
      12: begin
            PCIReg.Undef41 := Data;
            sRegLV.Items.Add.Caption := '$30';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Undef41');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.Undef41, 8));
          end;
      13: begin
            PCIReg.Undef42 := Data;
            sRegLV.Items.Add.Caption := '$34';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Undef42');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.Undef42, 8));
          end;
      14: begin
            PCIReg.Undef43 := Data;
            sRegLV.Items.Add.Caption := '$38';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Undef43');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.Undef43, 8));
          end;
      15: begin
            PCIReg.InteruptLinePin := Data;
            sRegLV.Items.Add.Caption := '$3C';
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('InteruptLinePin');
            sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(PCIReg.InteruptLinePin, 8));
          end;
    end;
{
    for n := 0 to 3 do
    begin
      RegLV.Items[RegLV.Items.Count-1].SubItems.add('$'+IntToHex(Data and $FF, 2));
      Data := Data shr 8;
    end;
    }
  end;
end;

procedure TForm1.ReadPCI2BtnClick(Sender: TObject);
begin
  sRegLV.Clear;

  with LPTDriver.LPTPort[LPTPortsCB.ItemIndex].PCIBARReg do
  begin
    sRegLV.Items.Add.Caption := '$00';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('VendorID');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(VendorID, 4));
    sRegLV.Items.Add.Caption := '$02';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('DeviceID');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(DeviceID, 4));

    sRegLV.Items.Add.Caption := '$04';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Command');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(Command, 4));
    sRegLV.Items.Add.Caption := '$06';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Status');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(Status, 4));

    sRegLV.Items.Add.Caption := '$08';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('RevisionID');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(RevisionID, 2));
    sRegLV.Items.Add.Caption := '$09';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('ClassCode');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(ClassCode, 6));

    sRegLV.Items.Add.Caption := '$0C';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('Undef1');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(Undef1, 8));

    sRegLV.Items.Add.Caption := '$10';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr0');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(IOBaseAddr0, 8));

    sRegLV.Items.Add.Caption := '$14';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr1');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(IOBaseAddr1, 8));

    sRegLV.Items.Add.Caption := '$18';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr2');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(IOBaseAddr2, 8));

    sRegLV.Items.Add.Caption := '$1C';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr3');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(IOBaseAddr3, 8));

    sRegLV.Items.Add.Caption := '$20';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr4');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(IOBaseAddr4, 8));

    sRegLV.Items.Add.Caption := '$24';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr5');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(IOBaseAddr5, 8));

    sRegLV.Items.Add.Caption := '$28';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('IOBaseAddr6');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(IOBaseAddr6, 8));

    sRegLV.Items.Add.Caption := '$2C';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('subVendorID');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(subVendorID, 4));
    sRegLV.Items.Add.Caption := '$2E';
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('subDeviceID');
    sRegLV.Items[sRegLV.Items.Count-1].SubItems.add('$'+IntToHex(subDeviceID, 4));
  end;
end;


function TForm1.GetDataFromLabs: Int64;
var
  n: byte;
begin
  Result := 0;

  for n := 0 to 31 do
  begin
    Result := Result+(StrToInt(L[31-n].Caption) shl n);
  end;
end;


procedure TForm1.LBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if TLabel(Sender).Caption = '0' then TLabel(Sender).Caption := '1'
                                  else TLabel(Sender).Caption := '0';
end;



function TForm1.ByteToStr(Val: byte; Digits: byte=8): String;
var
  n: byte;
begin
  Result := '';

  for n := Digits-1 downto 0 do
    Result := Result+IntTostr((Val shr n) and 1);
end;


procedure TForm1.LPTPortsCBChange(Sender: TObject);
begin
  BaseAddr := LPTDriver.LPTPort[LPTPortsCB.ItemIndex].BaseAddr;
end;


end.
