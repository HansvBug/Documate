unit AppDbMaintain;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms,  Controls, Dialogs, Windows, fileutil, SQLite3Conn, DB, SQLDB,
  AppDb;

{
Classes, SysUtils, Forms, Controls, Dialogs, Windows, fileutil, ComCtrls,
AppDb;
}

type
  PDbMaintainMessagesRec = ^TDbMaintainMessagesRec; { #todo : Move to AppDb }
  TDbMaintainMessagesRec = record
    dbmType : TMessageType;
    dbmText: string;
  end;

  { TAppDbMaintain }
  TAppDbMaintain = class(TAppDatabase)
    private
      FSQLite3Connection: TSQLite3Connection;  { #todo : Is gelijk aan appdbCreate. Kan naar AppDb unit }
      FSQLTransaction: TSQLTransaction;
      FSQLQuery :TSQLQuery;

      procedure AddDbMaintainMessage(messageType : TMessageType; aMessage: String);  { #todo : add to appdb }
      function IsFileInUse(const FileName: TFileName): Boolean;
    public
      DbMaintainMessages : array of TDbMaintainMessagesRec;

      constructor Create(DbFileName : String); overload;
      destructor  Destroy; override;

      procedure CompressAppDatabase;
      function CopyDbFile(DbFolder, DbbackUpFolder: string): Boolean;
      procedure Optimze;
      procedure ResetAutoIncrementAll;
      procedure ResetAutoIncrementTbl(const aTblName : String);  // Not used
  end;

implementation

{ TAppDbMaintain }

procedure TAppDbMaintain.AddDbMaintainMessage(messageType: TMessageType;
  aMessage: String);
begin
  SetLength(DbMaintainMessages, Length(DbMaintainMessages) + 1);
  DbMaintainMessages[Length(DbMaintainMessages) -1].dbmType := messageType;
  DbMaintainMessages[Length(DbMaintainMessages) -1].dbmText := aMessage;
end;

function TAppDbMaintain.IsFileInUse(const FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  result := False;
  if not FileExists(FileName) then exit;

  HFileRes := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);

  result := (HFileRes = INVALID_HANDLE_VALUE);

  if not result then CloseHandle(HFileRes);
end;

constructor TAppDbMaintain.Create(DbFileName: String);
begin
  inherited Create;
  dbFile := DbFileName;
  FSQLite3Connection:= TSQLite3Connection.Create(nil);
  FSQLTransaction:= TSQLTransaction.Create(nil);
  FSQLQuery:= TSQLQuery.Create(nil);

  // Connect together
  FSQLite3Connection.Transaction := FSQLTransaction;
  FSQLQuery.DataBase := FSQLite3Connection;
end;

destructor TAppDbMaintain.Destroy;
begin
  FSQLQuery.Free;
  FSQLTransaction.Free;
  FSQLite3Connection.Free;
  inherited Destroy;
end;

procedure TAppDbMaintain.CompressAppDatabase;
begin
  try
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;
    FSQLTransaction.Active := False;

    FSQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
    FSQLite3Connection.ExecuteDirect('VACUUM');
    FSQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
    FSQLite3Connection.Close();

    AddDbMaintainMessage(mInformation, 'De database is schoongemaakt en verkleind.');
  except
    on E : Exception do begin
      AddDbMaintainMessage(mError, 'Fout bij het comprimeren van de applicatie database.');
      AddDbMaintainMessage(mError, 'Melding:');
      AddDbMaintainMessage(mError, E.Message);
    end;
  end;
end;

function TAppDbMaintain.CopyDbFile(DbFolder, DbbackUpFolder: string): Boolean;
var
  Prefix : String;
  SrcFilename, DestFilename : String;
  dbFileName : String;
begin
  Screen.Cursor := crHourGlass;
  SrcFilename := dbFile;
  dbFileName := ExtractFileName(SrcFilename);

  if not IsFileInUse(SrcFilename) then begin
    Prefix := FormatDateTime('YYYYMMDD_', Now);
    //DestFilename := ExtractFilePath(Application.ExeName) + DbbackUpFolder + PathDelim + Prefix + dbFileName;
    DestFilename:= SysUtils.GetEnvironmentVariable('appdata') + PathDelim + ApplicationName + PathDelim + DbbackUpFolder + PathDelim + Prefix + dbFileName;

    { #todo : Controler of de map \backup bestaat }
    if FileExists(SrcFilename) then begin
      if not FileExists(DestFilename) then begin
        CopyFile(SrcFilename, DestFilename);
        AddDbMaintainMessage(mInformation, 'Kopie van de applicatie database is gemaakt.');
        AddDbMaintainMessage(mInformation, 'Kopie is: ' + DestFilename);
        Result := True;
      end
      else begin
        if MessageDlg('Let op.', 'Het bestand bestaat al. Wilt u het overschrijven?'  + sLineBreak +
                                 sLineBreak +
                                 'Bestand: ' + DestFilename,
                                 mtWarning, [mbYes, mbNo], 0, mbNo) = mrYes then begin
           CopyFile(SrcFilename, DestFilename, [cffOverwriteFile]);
           AddDbMaintainMessage(mInformation, 'Kopie van de applicatie database is gemaakt.');
           AddDbMaintainMessage(mInformation, 'Kopie is: ' + DestFilename);
           Result := True;
           end;
      end;
    end
    else begin
      AddDbMaintainMessage(mError, 'Het database bestand is niet gevonden.');
      Screen.Cursor := crDefault;
      messageDlg('Fout.', 'Het database bestand is niet gevonden.', mtError, [mbOK],0);
      Result := False;
    end;
  end
  else begin
    Screen.Cursor := crDefault;
    messageDlg('Let op.', 'Het bestand is in gebruik (door iemand anders). ' +sLineBreak +
                        'Er wordt géén kopie gemaakt.' , mtWarning, [mbOK],0);
    Result := False;
  end;
  Screen.Cursor := crDefault;
end;

procedure TAppDbMaintain.Optimze;
begin
  try
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;
    FSQLTransaction.Active := False;

    FSQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
    FSQLite3Connection.ExecuteDirect('pragma optimize;');
    FSQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
    FSQLite3Connection.Close();

    AddDbMaintainMessage(mInformation, 'De database is geoptimaliseerd.');
  except
    on E : Exception do begin
      AddDbMaintainMessage(mError, 'Fout bij het optimaliseren van de applicatie database.');
      AddDbMaintainMessage(mError, 'Melding:');
      AddDbMaintainMessage(mError, E.Message);
      messageDlg('Let op', 'Onverwachte fout bij het optimaliseren van de applicatie database.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TAppDbMaintain.ResetAutoIncrementAll;
var
  SqlText : String;
begin
  Screen.Cursor := crHourGlass;
  SqlText := 'delete from sqlite_sequence';
  try
    FSQLQuery.Close;
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;

    FSQLQuery.SQL.Text := SqlText;

    FSQLite3Connection.Open;
    FSQLTransaction.Active:=True;

    FSQLQuery.ExecSQL;

    FSQLTransaction.Commit;
    FSQLite3Connection.Close();

    AddDbMaintainMessage(mInformation, 'De ID''s van alle tabellen zijn gereset.');
    Screen.Cursor := crDefault;
  except
    on E : Exception do begin
      AddDbMaintainMessage(mError, 'Fout bij resetten van alle id''s.');
      AddDbMaintainMessage(mError, 'Melding:');
      AddDbMaintainMessage(mError, E.Message);

      Screen.Cursor := crDefault;
      messageDlg('Fout.', 'Fout bij resetten van alle id''s.', mtError, [mbOK],0);
    end;
  end;
end;

procedure TAppDbMaintain.ResetAutoIncrementTbl(const aTblName: String);
var
  SqlText : String;
begin
  SqlText := 'delete from sqlite_sequence where name = :TABLE_NAME';

  try
    FSQLQuery.Close;
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;

    FSQLQuery.SQL.Text := SqlText;
    FSQLQuery.Params.ParamByName('TABLE_NAME').AsString := aTblName;

    FSQLite3Connection.Open;
    FSQLTransaction.Active:=True;

    FSQLQuery.ExecSQL;

    FSQLTransaction.Commit;
    FSQLite3Connection.Close();

    AddDbMaintainMessage(mInformation, 'De ID''s van de tabel ' + aTblName +  ' zijn gereset.');
  except
    on E : Exception do begin
      AddDbMaintainMessage(mError, 'Fout bij resetten van de id''s.');
      AddDbMaintainMessage(mError, 'Melding:');
      AddDbMaintainMessage(mError, E.Message);

    end;
  end;
end;

end.

