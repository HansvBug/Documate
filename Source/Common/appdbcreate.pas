unit AppDbCreate;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fileutil,  lazfileutils,
  SQLite3Conn, DB, SQLDB,
  AppDb;


Type
  PDbCreateMessagesRec = ^TDbCreateMessagesRec;  { #todo : Move to AppDb }
  TDbCreateMessagesRec = record
    dbmType : TMessageType;
    dbmText: string;
  end;


  { TCreateAppdatabase }

  TCreateAppdatabase = class(TAppDatabase)
    private
      FError : Boolean;
      FNewDatabaseCreated : Boolean;

      FSQLite3Connection: TSQLite3Connection;
      FSQLTransaction: TSQLTransaction;
      FSQLQuery :TSQLQuery;

      function CheckDatabaseFile : boolean;
      procedure SqliteAutoVacuum;
      procedure SqliteJournalMode;
      procedure SqliteSynchronous;
      procedure SqliteTemStore;
      procedure SqliteUserVersion(version: string= '');
      procedure CreTable(const TableName, SqlText, Version : String);
      function SelectMeta : Integer;
      procedure UpdateMeta(const Version : String);
      procedure AddDbCreateMessage(messageType : TMessageType; aMessage: String);

    public
      DbCreateMessages : array of TDbCreateMessagesRec;

      constructor Create(DbFileName, DbVersion: String); overload;
      destructor  Destroy; override;
      function CreateNewDatabase : boolean;
      procedure InsertMeta(const aKey, aValue : String);
      procedure CreateAllTables;


  end;
implementation

{ TCreateAppdatabase }

{%Region Constants}
const
  creTblSetmeta =     'create table if not exists ' + SETTINGS_META + ' (' +
                      'KEY      VARCHAR(50), ' +
                      'VALUE    VARCHAR(255));';

  creTblItems =       'create table if not exists ' + ITEMS + ' (' +
                      'ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, ' +
                      'GUID            VARCHAR(50)  UNIQUE                                   , ' +
                      'LEVEL	       INTEGER                                               , ' +
                      'NAME            VARCHAR(1000)                                         , ' +
                      'DATE_CREATED    DATE                                                  , ' +
                      'DATE_ALTERED    DATE                                                  , ' +
                      'CREATED_BY      VARCHAR(100)                                          , ' +
                      'ALTERED_BY      VARCHAR(100));';

  creTblItemsMemo =   'create table if not exists ' + ITEMS_MEMO + ' (' +
                      'ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, ' +
                      'GUID            VARCHAR(50)  UNIQUE                                   , ' +
                      'MEMO            VARCHAR(10000)                                        , ' +
                      'GUID_PARENT     VARCHAR(50));';

  creTblRelItems =    'create table if not exists ' + REL_ITEMS + ' (' +
                      'ID              INTEGER      NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, ' +
                      'GUID            VARCHAR(50)  UNIQUE                                   , ' +
                      'GUID_LEVEL_A    VARCHAR(50)                                           , ' +
                      'GUID_LEVEL_B    VARCHAR(50));';
{%Endregion Constants}

function TCreateAppdatabase.CheckDatabaseFile: boolean;
begin
  if dbFile = '' then begin
    result := false;
    AddDbCreateMessage(mtError, 'Geen database aangemaakt. Bestandnaam is leeg.');
  end
  else begin
    if FileExists(dbFile) then begin
      RenameFile(dbFile, StringReplace(dbFile, '.db', '_Expired.db', [rfIgnoreCase]));
      AddDbCreateMessage(mtInformation, 'The file : ' + dbFile + ' is renamed.');
      // DeleteFile(dbFile); // If the file already exists, delete it first because when you arrive here, overwrite existing file has been chosen.
    end;

    AddDbCreateMessage(mtInformation, 'Aanmaken nieuw leeg database bestand op de locatie: '+ dbFile);

    try
      FSQLite3Connection.Close();
      FSQLite3Connection.DatabaseName := dbFile;
      FSQLite3Connection.Open; // Creates the file.
      FSQLite3Connection.Close(True);
      AddDbCreateMessage(mtInformation, 'Leeg database bestand is aangemaakt.');
      FNewDatabaseCreated := True;
      result := true;
    except
      on E : Exception do begin
          AddDbCreateMessage(mtError, 'Fout bij het aanmaken van een leeg database bestand.');
          AddDbCreateMessage(mtError, 'Melding:');
          AddDbCreateMessage(mtError, E.Message);
          AddDbCreateMessage(mtError, '');
        FError := true;
        result := false;
      end;
    end;

  end;
end;

procedure TCreateAppdatabase.SqliteAutoVacuum;
begin
  try
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;
    FSQLTransaction.Active := False;
    FSQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
    FSQLite3Connection.ExecuteDirect('PRAGMA auto_vacuum = INCREMENTAL;');
    FSQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
    FSQLite3Connection.Close();
    AddDbCreateMessage(mtInformation, 'Database instelling: auto_vacuum = incremental.');
  except
    on E : Exception do begin
      AddDbCreateMessage(mtError, 'Fout bij maken van een database instelling. (auto_vacuum).');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteJournalMode;
begin
  try
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;
    FSQLTransaction.Active := False;

    FSQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
    FSQLite3Connection.ExecuteDirect('pragma journal_mode = WAL;');
    FSQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
    FSQLite3Connection.Close();
    AddDbCreateMessage(mtInformation, 'Database instelling: journal_mode = WAL.');
  except
    on E : Exception do begin
      AddDbCreateMessage(mtError, 'Fout bij maken van een database instelling. (journal_mode).');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteSynchronous;
begin
  try
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;
    FSQLTransaction.Active := False;

    FSQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
    FSQLite3Connection.ExecuteDirect('pragma synchronous = normal;');
    FSQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
    FSQLite3Connection.Close();
    AddDbCreateMessage(mtInformation, 'Database instelling: synchronous = normal.');
  except
    on E : Exception do begin
      AddDbCreateMessage(mtError, 'Fout bij maken van een database instelling. (synchronous).');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteTemStore;
begin
  try
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;
    FSQLTransaction.Active := False;

    FSQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
    FSQLite3Connection.ExecuteDirect('pragma temp_store = memory;');
    FSQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
    FSQLite3Connection.Close();
    AddDbCreateMessage(mtInformation, 'Database instelling: temp_store = memory.');
  except
    on E : Exception do begin
      AddDbCreateMessage(mtError, 'Fout bij maken van een database instelling. (temp_store).');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.SqliteUserVersion(version : string = '');
begin
  try
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;
    FSQLTransaction.Active := False;

    FSQLite3Connection.ExecuteDirect('End Transaction');       // End the transaction
    FSQLite3Connection.ExecuteDirect('pragma USER_VERSION = ' + version + ';');
    FSQLite3Connection.ExecuteDirect('Begin Transaction');     //Start a transaction for SQLdb to use
    FSQLite3Connection.Close();
    AddDbCreateMessage(mtInformation, 'Database instelling: USER_VERSION = ' + version);
  except
    on E : Exception do begin
      AddDbCreateMessage(mtError, 'Fout bij maken van een database instelling. (USER_VERSION).');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.CreTable(const TableName, SqlText, Version: String);
begin
  try
    AddDbCreateMessage(mtInformation, 'Start aanmaken tabel: ' + TableName + '. (Versie: ' + Version + ').');
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;
    FSQLTransaction.Active := True;

    FSQLite3Connection.ExecuteDirect(SqlText);

    FSQLTransaction.Commit;
    FSQLite3Connection.Close();
  except
    on E : Exception do begin
      AddDbCreateMessage(mtError, 'Fout bij het aanmaken van de tabel: ' + TableName + '. (Versie: ' + Version + ').');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.InsertMeta(const aKey, aValue : String);
var
  SqlString : String;
begin
  SqlString := 'insert into ' + SETTINGS_META + ' (KEY, VALUE) values (:KEY, :VALUE)';
  try
    if FSQLite3Connection.DatabaseName = '' then begin
      FSQLite3Connection.DatabaseName:=dbFile;
      FSQLite3Connection.Open;
      FSQLTransaction.Active:=True;
    end;

    FSQLQuery.Close;

    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName:=dbFile;

    FSQLQuery.SQL.Text := SqlString;
    FSQLQuery.Params.ParamByName('KEY').AsString := aKey;
    FSQLQuery.Params.ParamByName('VALUE').AsString := aValue;

    FSQLite3Connection.Open;
    FSQLTransaction.Active:=True;

    FSQLQuery.ExecSQL;

    FSQLTransaction.Commit;
    FSQLite3Connection.Close();
    AddDbCreateMessage(mtInformation, 'Toegevoegd aan de tabel '+ SETTINGS_META + ' is : ' + aKey + ' - ' + Avalue + '.');
  except
    on E: EDatabaseError do begin
      AddDbCreateMessage(mtError, 'Het invoeren van "Versienummmer" is mislukt.');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
    end;
  end;
end;

function TCreateAppdatabase.SelectMeta: Integer;
var
  SqlString : String;
  Version : Integer;
begin
  SqlString := 'select VALUE from ' + SETTINGS_META + ' where KEY = :KEY';
    try
      FSQLQuery.Close;

      FSQLite3Connection.Close();
      FSQLite3Connection.DatabaseName:=dbFile;

      FSQLQuery.SQL.Text := SqlString;
      FSQLQuery.Params.ParamByName('KEY').AsString := 'Version';

      FSQLite3Connection.Open;

      FSQLQuery.Open;
      FSQLQuery.First;

      while not FSQLQuery.Eof do begin
        Version := FSQLQuery.FieldByName('VALUE').AsInteger;
        FSQLQuery.Next;
      end;

      FSQLQuery.Close;
      FSQLite3Connection.Close();

      AddDbCreateMessage(mtInformation, 'Versie is opgevraagd. (Tabel: '+ SETTINGS_META + ').');
      Result := Version;
  except
    on E: EDatabaseError do begin
      AddDbCreateMessage(mtError, 'Opvragen versienummer is mislukt.');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
      Result := -1;
    end;
  end;
end;

procedure TCreateAppdatabase.UpdateMeta(const Version: String);
var
  SqlString : String;
begin
  SqlString := 'update ' + SETTINGS_META + ' set VALUE = :VALUE where KEY = :KEY;';
  try
    FSQLQuery.Close;

    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName:=dbFile;

    FSQLQuery.SQL.Text :=SqlString;
    FSQLQuery.Params.ParamByName('KEY').AsString := 'Version';
    FSQLQuery.Params.ParamByName('VALUE').AsString := Version;

    FSQLite3Connection.Open;
    FSQLTransaction.Active:=True;

    FSQLQuery.ExecSQL;

    FSQLTransaction.Commit;
    FSQLite3Connection.Close();
    AddDbCreateMessage(mtInformation, 'Versie is bijgewerkt. (Tabel: '+ SETTINGS_META + ', Versie: ' + Version + ').');
  except
    on E: EDatabaseError do begin
      AddDbCreateMessage(mtError, 'Het actualiseren van '+ SETTINGS_META + ' is mislukt.');
      AddDbCreateMessage(mtError, 'Melding:');
      AddDbCreateMessage(mtError, E.Message);
      AddDbCreateMessage(mtError, '');
      FError := true;
    end;
  end;
end;

procedure TCreateAppdatabase.AddDbCreateMessage(messageType: TMessageType;
  aMessage: String);
begin
  SetLength(DbCreateMessages, Length(DbCreateMessages) + 1);
  DbCreateMessages[Length(DbCreateMessages) -1].dbmType := messageType;
  DbCreateMessages[Length(DbCreateMessages) -1].dbmText := aMessage;
end;


{%region constructor - destructor}
constructor TCreateAppdatabase.Create(DbFileName, DbVersion : String);
begin
  inherited Create;

  FSQLite3Connection:= TSQLite3Connection.Create(nil);
  FSQLTransaction:= TSQLTransaction.Create(nil);
  FSQLQuery:= TSQLQuery.Create(nil);

  // Connect together
  FSQLite3Connection.Transaction := FSQLTransaction;
  FSQLQuery.DataBase := FSQLite3Connection;

  //FSQLite3ConnectionRelItems.Transaction := FSQLTransactionRelItems;
  //FSQLQueryRelItems.DataBase := FSQLite3ConnectionRelItems;

  FNewDatabaseCreated := False;
  dbFile := DbFileName;
  DatabaseVersion := DbVersion;
end;

destructor TCreateAppdatabase.Destroy;
begin
  FSQLQuery.Free;
  FSQLTransaction.Free;
  FSQLite3Connection.Free;
  inherited Destroy;
end;
{%endregion constructor - destructor}

function TCreateAppdatabase.CreateNewDatabase: boolean;
begin
  if CheckDatabaseFile then begin // Check if database file exists. If yes then delete it befor creating a new file.

    if FNewDatabaseCreated then begin
      // Set SQlite database settings.
      if not FError then SqliteAutoVacuum;
      if not FError then SqliteJournalMode;
      if not FError then SqliteSynchronous;
      if not FError then SqliteTemStore;
      if not FError then SqliteUserVersion(DatabaseVersion);
      if not FError then CreTable(SETTINGS_META, creTblSetmeta, '0');
      if not FError then InsertMeta('Version', '0');
      if not FError then InsertMeta('DatabaseName', ExtractFileName(dbFile));
    end;

    CreateAllTables;  // Create the tables
    result := true;
  end
  else begin
    result := false;
  end;
end;

procedure TCreateAppdatabase.CreateAllTables;
var
  Version : String;
begin
  if FileExists(dbFile) then begin
    if (StrToInt(DatabaseVersion) >= 1) and (SelectMeta = 0) then begin  // (version 1 tables)
      Version := '1';
      if not FError then CreTable(ITEMS, creTblItems, Version);
      if not FError then CreTable(ITEMS_MEMO, creTblItemsMemo, Version);
      if not FError then CreTable(REL_ITEMS, creTblRelItems, Version);
      if not FError then UpdateMeta(Version);
    end;

    if StrToInt(DataBaseVersion) > SelectMeta then begin
      if SelectMeta < 3 then begin
        //Version := '2';

        //if not FError then SqliteUserVersion;
        //if not FError then UpdateMeta(Version);

      end;
      {if SelectMeta < 4 then begin
        Version := '3';
        SqliteUserVersion;
        //..
      end;  }
    end;

    if not FError then begin
      AddDbCreateMessage(mtInformation, 'Het aanmaken/bijwerken van de database (tabellen) is gereed. (Versie: ' + Version + ').');
      AddDbCreateMessage(mtInformation, '');
    end;
  end
  else begin  // database file does not exists
    AddDbCreateMessage(mtError, 'De database is niet gevonden.');
    FError := true;
  end;
end;


end.

