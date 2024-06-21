unit Settings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles;

{$Interfaces CORBA}

type
  { ISettings }

  ISettings = interface['{89E73826-E4FF-401B-AA13-2D58A6455D07}']
    function get_ActivateLogging: Boolean;
    function get_AppBuildDate: string;
    function get_AppName: string;
    function get_AppVersion: string;

    function Obj: TObject;
    procedure set_ActivateLogging(AValue: Boolean);
    procedure ReadFile;
    procedure WriteSettings;
    procedure StoreFormState;
    procedure set_AppBuildDate(AValue: string);
    procedure set_AppName(AValue: string);
    procedure set_AppVersion(AValue: string);

    property ApplicationName : string read get_AppName write set_AppName;
    property ApplicationVersion : string read get_AppVersion write set_AppVersion;
    property ApplicationBuildDate : string read get_AppBuildDate write set_AppBuildDate;

    property ActivateLogging : Boolean read get_ActivateLogging write set_ActivateLogging;
  end;
{$Interfaces COM}

  { TSettings }

  TSettings = class(TObject, ISettings)
    private
      FSettingsFile : String;
      FActivateLogging, FAppendLogging: Boolean;
      FAppName, FAppVersion, FAppBuildDate : String;
      FLanguage : String;

      FFrmName : String;
      FFrmWindowstate : Integer;
      FFrmTop : Integer;
      FFrmLeft : Integer;
      FFrmHeight : Integer;
      FFrmWidth : Integer;
      FFrmRestoredTop : Integer;
      FFrmRestoredLeft : Integer;
      FFrmRestoredHeight : Integer;
      FFrmRestoredWidth : Integer;

      function get_ActivateLogging: Boolean;
      function get_AppBuildDate: String;
      function get_AppendLogging: Boolean;
      function get_AppName: String;
      function get_AppVersion: String;
      function get_Language: String;
      function Obj: TObject;
      procedure set_ActivateLogging(AValue: Boolean);
      procedure set_AppBuildDate(AValue: String);
      procedure set_AppendLogging(AValue: Boolean);
      procedure set_AppName(AValue: String);
      procedure set_AppVersion(AValue: String);
      procedure AddUserName(SettingsFile : String);
      procedure set_Language(AValue: String);


    public
      constructor Create(SettingsFile : String); overload;  // Create with full settingsfile location and path
      destructor  Destroy; override;
      procedure ReadFile;
      procedure ReadFormState(aFormName: String);
      procedure WriteSettings;
      procedure StoreFormState;

      property ApplicationName : String read get_AppName write set_AppName;
      property ApplicationVersion : String read get_AppVersion write set_AppVersion;
      property ApplicationBuildDate : String read get_AppBuildDate write set_AppBuildDate;
      property ActivateLogging : Boolean read get_ActivateLogging write set_ActivateLogging;
      property AppendLogging : Boolean read get_AppendLogging write set_AppendLogging;
      property Language : String read get_Language write set_Language;

      property FormName : String read FFrmName write FFrmName;
      property FormWindowstate : Integer read FFrmWindowstate write FFrmWindowstate;
      property FormTop : Integer read FFrmTop write FFrmTop;
      property FormLeft : Integer read FFrmLeft write FFrmLeft;
      property FormHeight : Integer read FFrmHeight write FFrmHeight;
      property FormWidth : Integer read FFrmWidth write FFrmWidth;
      property FormRestoredTop : Integer read FFrmRestoredTop write FFrmRestoredTop;
      property FormRestoredLeft : Integer read FFrmRestoredLeft write FFrmRestoredLeft;
      property FormRestoredHeight : Integer read FFrmRestoredHeight write FFrmRestoredHeight;
      property FormRestoredWidth : Integer read FFrmRestoredWidth write FFrmRestoredWidth;
  end;

implementation

{ TSettings }

function TSettings.Obj: TObject;
begin
  Result := Self;
end;

function TSettings.get_ActivateLogging: Boolean;
begin
  Result := FActivateLogging;
end;

function TSettings.get_AppName: String;
begin
  Result := FAppName;
end;

procedure TSettings.set_AppName(AValue: String);
begin
  FAppName := AValue;
end;

function TSettings.get_AppVersion: String;
begin
  Result := FAppVersion;
end;

procedure TSettings.set_AppVersion(AValue: String);
begin
  FAppVersion := AValue;
end;

function TSettings.get_AppBuildDate: String;
begin
  Result := FAppBuildDate
end;

function TSettings.get_AppendLogging: Boolean;
begin
  Result := FAppendLogging;
end;

procedure TSettings.set_AppBuildDate(AValue: String);
begin
  FAppBuildDate := Avalue;
end;

procedure TSettings.set_AppendLogging(AValue: Boolean);
begin
  FAppendLogging := AValue;
end;

procedure TSettings.set_ActivateLogging(AValue: Boolean);
begin
  FActivateLogging := AValue;
end;

procedure TSettings.AddUserName(SettingsFile: String);
var
  UserName, FileName, FilePath : string;
begin
  UserName := StringReplace(GetEnvironmentVariable('USERNAME') , ' ', '_', [rfIgnoreCase, rfReplaceAll]) + '_';
  FileName := ExtractFileName(SettingsFile);
  FilePath := ExtractFilePath(SettingsFile);

  FSettingsFile := FilePath + UserName + FileName;
end;

function TSettings.get_Language: String;
begin
  result := FLanguage;
end;

procedure TSettings.set_Language(AValue: String);
begin
  FLanguage := AValue;
end;

constructor TSettings.Create(SettingsFile: String);
begin
  inherited Create;
  AddUserName(SettingsFile); { #todo : Make optional }
end;

destructor TSettings.Destroy;
begin
  //..
  inherited Destroy;
end;

procedure TSettings.ReadFile;
begin
  With TIniFile.Create(FSettingsFile) do begin
    try
      if FileExists(FSettingsFile) then begin
        ActivateLogging := ReadBool('Configure', 'ActivateLogging', True);
        AppendLogging := ReadBool('Configure', 'AppendLogging', True);
        Language := ReadString('Configure', 'Language', 'EN');
        //...
      end
      else begin  // write default settings
        ActivateLogging := True;
        AppendLogging := True;
        Language := 'EN';
        //...

        WriteString('Application', 'Name', ApplicationName);
        WriteString('Application', 'Version', ApplicationVersion);
        WriteString('Application', 'Build date', ApplicationBuilddate);

        WriteBool('Configure', 'ActivateLogging', True);
        WriteBool('Configure', 'AppendLogging', True);
        WriteString('Configure', 'Language', 'EN');
        //...

        // FornMane is unknown here.
        WriteInteger('Position', 'Form_Main' + '_Windowstate', 0);
        WriteInteger('Position', 'Form_Main' + '_Top', 10);
        WriteInteger('Position', 'Form_Main' + '_Left', 10);
        WriteInteger('Position', 'Form_Main' + '_Height', 220);
        WriteInteger('Position', 'Form_Main' + '_Width', 540);
        WriteInteger('Position', 'Form_Main' + '_RestoredTop', 10);
        WriteInteger('Position', 'Form_Main' + '_RestoredLeft', 10);
        WriteInteger('Position', 'Form_Main' + '_RestoredHeight', 220);
        WriteInteger('Position', 'Form_Main' + '_RestoredWidth', 540);

        WriteInteger('Position', 'Form_Configure' + '_Windowstate', 0);
        WriteInteger('Position', 'Form_Configure' + '_Top', 10);
        WriteInteger('Position', 'Form_Configure' + '_Left', 10);
        WriteInteger('Position', 'Form_Configure' + '_Height', 280);
        WriteInteger('Position', 'Form_Configure' + '_Width', 560);
        WriteInteger('Position', 'Form_Configure' + '_RestoredTop', 10);
        WriteInteger('Position', 'Form_Configure' + '_RestoredLeft', 10);
        WriteInteger('Position', 'Form_Configure' + '_RestoredHeight', 240);
        WriteInteger('Position', 'Form_Configure' + '_RestoredWidth', 380);

        UpdateFile;  { Create a Settings file with default settings }
      end;

    finally
      Free;
    end;
  end;
end;

procedure TSettings.ReadFormState(aFormName: String);
begin
  if FileExists(FSettingsFile) then begin
    With TIniFile.Create(FSettingsFile) do begin
      try
        FormName := aFormName;
        FormWindowstate := ReadInteger('Position', FormName + '_Windowstate', 0);
        FormTop := ReadInteger('Position', FormName + '_Top', 10);
        FormLeft := ReadInteger('Position', FormName + '_Left', 10);
        FormHeight := ReadInteger('Position', FormName + '_Height', 220);
        FormWidth := ReadInteger('Position', FormName + '_Width', 540);
        FormRestoredTop := ReadInteger('Position', FormName + '_RestoredTop', 10);
        FormRestoredLeft := ReadInteger('Position', FormName + '_RestoredLeft', 10);
        FormRestoredHeight := ReadInteger('Position', FormName + '_RestoredHeight', 220);
        FormRestoredWidth := ReadInteger('Position', FormName + '_RestoredWidth', 540);
      finally
        Free;
      end;
    end;
  end
  else begin
    // ...
  end;
end;

procedure TSettings.WriteSettings;
begin
  if FileExists(FSettingsFile) then begin
    With TIniFile.Create(FSettingsFile) do begin
      try
        if FormName = 'Form_Configure' then begin  { #todo : property maken per form_name of iets anders waardoor geen tekst string nodig is. }
          WriteBool('Configure', 'ActivateLogging', ActivateLogging);
          WriteBool('Configure', 'AppendLogging', AppendLogging);
        end
        else if FormName = 'Form_Main' then begin
          WriteString('Configure', 'Language', Language);
        end;
        //...
        UpdateFile;
      finally
        Free;
      end;
    end;
  end
  else begin
    //...
  end;
end;

procedure TSettings.StoreFormState;
begin
  if FileExists(FSettingsFile) then begin
    With TIniFile.Create(FSettingsFile) do begin
      try
        WriteInteger('Position', FFrmName + '_Windowstate', FFrmWindowstate);
        WriteInteger('Position', FFrmName + '_Top', FFrmTop);
        WriteInteger('Position', FFrmName + '_Left', FFrmLeft);
        WriteInteger('Position', FFrmName + '_Height', FFrmHeight);
        WriteInteger('Position', FFrmName + '_Width', FFrmWidth);
        WriteInteger('Position', FFrmName + '_RestoredTop', FFrmRestoredTop);
        WriteInteger('Position', FFrmName + '_RestoredLeft', FFrmRestoredLeft);
        WriteInteger('Position', FFrmName + '_RestoredHeight', FFrmRestoredHeight);
        WriteInteger('Position', FFrmName + '_RestoredWidth', FFrmRestoredWidth);
        UpdateFile;
      finally
        Free;
      end;
    end;
  end;
end;

end.

