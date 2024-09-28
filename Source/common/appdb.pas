unit AppDb;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

  TMessageType = (mInformation, mError); // mtError does exists for messagedialogs.

  { TAppDatabase }

  TAppDatabase = class(TObject)
    private
      FdbFile, FBaseFolder, FDatabaseVersion : String;

    protected
      property BaseFolder      : String Read FBaseFolder Write FBaseFolder;
      property DatabaseVersion : String Read FDatabaseVersion write FDatabaseVersion;
      property dbFile          : String Read FdbFile Write FdbFile;

    public
      { Check if the sqlite3.dll file is present in the application folder. }
      function CheckForDllFile : Boolean;

      constructor Create(FullDbFilePath : String); overload;
      destructor  Destroy; override;

    published
  end;


const
  SETTINGS_META = 'SETTINGS_META';
  ITEMS		= 'ITEMS';
  ITEMS_MEMO    = 'ITEMS_MEMO';
  REL_ITEMS	= 'REL_ITEMS';
  SQLiteDllFile = 'sqlite3.dll';  // This file must be present. Otherwise SQLite will not work

implementation

{ TAppDatabase }

constructor TAppDatabase.Create(FullDbFilePath : String);
begin
  FdbFile := FullDbFilePath;
end;

destructor TAppDatabase.Destroy;
begin
  //...
  inherited Destroy;
end;

function TAppDatabase.CheckForDllFile: Boolean;
begin
  if not FileExists(ExtractFilePath(ParamStr(0)) + SQLiteDllFile) then
    begin
      Result := False;
    end
  else
    Result := True;
end;

end.


