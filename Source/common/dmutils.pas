unit DmUtils;

{ when this not grows then move the function tot the model}

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Windows;

type

  { TDmUtils }

  TDmUtils = class(TObject)
    private
    public
      constructor Create; overload;
      destructor  Destroy; override;
      function SetStatusbarPanelsWidth(stbWidth, lpWidth, rpWidth: Integer): Integer;
      function IsFileInUse(FileName: TFileName): Boolean;
  end;

implementation

{ TDmUtils }

constructor TDmUtils.Create;
begin
  inherited Create;
  //...
end;

destructor TDmUtils.Destroy;
begin
  //...
  inherited Destroy;
end;

function TDmUtils.SetStatusbarPanelsWidth(stbWidth, lpWidth, rpWidth: Integer
  ): Integer;
begin
  result := stbWidth - lpWidth - rpWidth;
end;

function TDmUtils.IsFileInUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  HFileRes := CreateFile(PChar(FileName),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;



end.

