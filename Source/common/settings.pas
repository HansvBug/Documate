unit Settings;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, IniFiles;

type

  { TSettings }

  TSettings = class(TObject)
  private
    FAppendLogFile: Boolean;
    FLanguage: String;
    FSettingsFile: String;
    FAppName: String;
    FAppVersion: String;
    FAppBuildDate: String;
    FActivateLogging: Boolean;
    FSucces : Boolean;

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

    function get_AppBuildDate: String;
    function get_AppName: String;
    function get_AppVersion: String;
    procedure set_AppBuildDate(AValue: String);
    procedure set_AppName(AValue: String);
    procedure set_AppVersion(AValue: String);

  public
    //constructor Create(SettingsFile : String); overload;  // Create with full settingsfile location and path
    constructor Create; overload;
    destructor  Destroy; override;
    procedure ReadFile;
    procedure WriteSettings;
    procedure WriteSetting(SettingName, AValue: String);
    procedure StoreFormState;
    procedure ReadFormState;

    property SettingsFile    : String read FSettingsFile write FSettingsFile;
    property AppName : String read get_AppName write set_AppName;
    property AppVersion : String read get_AppVersion write set_AppVersion;
    property AppBuildDate : String read get_AppBuildDate write set_AppBuildDate;
    property ActivateLogging : Boolean read FActivateLogging write FActivateLogging;
    property AppendLogFile : Boolean read FAppendLogFile write FAppendLogFile;

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
    property Language : String read FLanguage write FLanguage;

    property Succes: Boolean read FSucces write FSucces;
  end;

implementation

{ TSettings }

function TSettings.get_AppBuildDate: String;
begin
  Result:= FAppBuildDate;
end;

procedure TSettings.set_AppBuildDate(AValue: String);
begin
  FAppBuildDate:= AValue;
end;

function TSettings.get_AppName: String;
begin
  Result:= FAppName;
end;

procedure TSettings.set_AppName(AValue: String);
begin
  FAppName:= AValue;
end;

function TSettings.get_AppVersion: String;
begin
  Result:= FAppVersion;
end;

procedure TSettings.set_AppVersion(AValue: String);
begin
  FAppVersion:= AValue;
end;

procedure TSettings.StoreFormState;
begin
  Succes:= False;
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
        Succes:= True;
      finally
        Free;
      end;
    end;
  end;
end;

procedure TSettings.ReadFormState;
begin
  if FileExists(FSettingsFile) then begin
    With TIniFile.Create(FSettingsFile) do begin
      try
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

constructor TSettings.Create;
begin
  inherited Create;
  //...
end;

destructor TSettings.Destroy;
begin
  //...
  inherited Destroy;
end;

procedure TSettings.ReadFile;
begin
  With TIniFile.Create(FSettingsFile) do begin
    try
      Succes := False;
      if FileExists(FSettingsFile) then begin
        // read settings
        ActivateLogging:= ReadBool('Configure', 'ActivateLogging', True);
        AppendLogFile:= ReadBool('Configure', 'AppendLogFile', True);
        Language:= ReadString('Configure', 'Language', 'en');

        Succes := True;
      end
      else begin  // Write default settings when the settings file is missing.
        WriteString('Application', 'Name', ApplicationName);
        WriteString('Application', 'Version', AppVersion);
        WriteString('Application', 'Build date', AppBuilddate);

        WriteInteger('Position', 'view.main_Top', 10);
        WriteInteger('Position', 'view.main_Left', 10);
        WriteInteger('Position', 'view.main_Height', 550);
        WriteInteger('Position', 'view.main_Width', 1050);

        WriteInteger('Position', 'view.configure_Top', 20);
        WriteInteger('Position', 'view.configure_Left', 20);
        WriteInteger('Position', 'view.configure_Height', 450);
        WriteInteger('Position', 'view.configure_Width', 950);

        WriteBool('Configure', 'ActivateLogging', True);
        WriteBool('Configure', 'AppendLogFile', True);
        writeString('Configure', 'Language', 'en');

        Succes := True;
        //UpdateFile;  { Create a Settings file with default settings }
      end;
    finally
      Free;
    end;
  end;
end;

procedure TSettings.WriteSettings;
begin
  Succes := False;
  if FileExists(FSettingsFile) then begin
    With TIniFile.Create(FSettingsFile) do begin
      try
        WriteBool('Configure', 'ActivateLogging', ActivateLogging);
        WriteBool('Configure', 'AppendLogFile', AppendLogFile);
        if Language <> '' then
          WriteString('Configure', 'Language', Language);

        UpdateFile;
        Succes := True;
      finally
        Free;
      end;
    end;
  end;
end;

procedure TSettings.WriteSetting(SettingName, AValue: String);
begin
  Succes := False;
  if FileExists(FSettingsFile) then begin
    With TIniFile.Create(FSettingsFile) do begin
      try
        WriteString('Configure', SettingName, AValue);
        Succes := True;
      finally
        Free;
      end;
    end;
  end;
end;

end.

