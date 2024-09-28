unit AppDbOpen;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, fileutil,  lazfileutils,
  SQLite3Conn, DB, SQLDB,
  AppDb;

type
  PDbOpenMessagesRec = ^TDbOpenMessagesRec;
  TDbOpenMessagesRec = record
    dbmType : TMessageType;
    dbmText: string;
  end;

  PItemDataRec = ^TItemDataRec;
  TItemDataRec = record
    idColumn : Integer;
    idItem   : String;
  end;
  AllItemsData = array of TItemDataRec;


  PtrItemObject = ^ItemObjectData;
  ItemObjectData = record
    Guid             : String;
    Level            : Integer;
    Name             : String;
    Parent_guid      : array of String;
    MemoNew          : String;
    MemoCurrent      : String;
    Action           : String;
  end;
  AllItemsObjectData = array of ItemObjectData;



  { TOpenAppDatabase }

  TOpenAppDatabase = class(TAppDatabase)
    private
      FSQLite3Connection: TSQLite3Connection;  { #todo : Is gelijk aan appdbCreate. Kan naar AppDb unit }
      FSQLTransaction: TSQLTransaction;
      FSQLQuery :TSQLQuery;

      FAllItems : AllItemsData;

      procedure AddDbOpenMessage(messageType : TMessageType; aMessage: String);
    public
      DbOpenMessages : array of TDbOpenMessagesRec;

      constructor Create(DbFileName: String); overload;
      destructor  Destroy; override;

      function ColumnCount : Integer;
      procedure GetItems;

      property AllItems: AllItemsData read FAllItems;
  end;



implementation

{ TOpenAppDatabase }

procedure TOpenAppDatabase.AddDbOpenMessage(messageType: TMessageType;
  aMessage: String);
begin
  SetLength(DbOpenMessages, Length(DbOpenMessages) + 1);
  DbOpenMessages[Length(DbOpenMessages) -1].dbmType := messageType;
  DbOpenMessages[Length(DbOpenMessages) -1].dbmText := aMessage;
end;

constructor TOpenAppDatabase.Create(DbFileName: String);
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

destructor TOpenAppDatabase.Destroy;
begin
  FSQLQuery.Free;
  FSQLTransaction.Free;
  FSQLite3Connection.Free;
  inherited Destroy;
end;

function TOpenAppDatabase.ColumnCount: Integer;
var
  SqlText : String;
  Columns : Integer;
begin
  SqlText := 'Select VALUE from '+ SETTINGS_META + ' where KEY = :KEY;';

  try
    FSQLQuery.Close;

    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName:=dbFile;

    FSQLQuery.SQL.Text := SqlText;
    FSQLQuery.Params.ParamByName('KEY').AsString := 'Columns';

    FSQLite3Connection.Open;
    FSQLQuery.Open;
    FSQLQuery.First;

    while not FSQLQuery.Eof do begin
      Columns := FSQLQuery.FieldByName('VALUE').AsInteger;
      FSQLQuery.next;
    end;
    FSQLQuery.Close;
    FSQLite3Connection.Close();
    Result := Columns;
    AddDbOpenMessage(mInformation, 'Aantal kolommen is opgehaald. (' + IntToStr(Columns) + ' st)');
  except
    on E: EDatabaseError do begin
      AddDbOpenMessage(mError, 'Het ophalen van het aantal kolommen is mislukt.');
      AddDbOpenMessage(mError, 'Melding:');
      AddDbOpenMessage(mError, E.Message);
      AddDbOpenMessage(mError, '');
      Result := 0;
    end;
  end;
end;

procedure TOpenAppDatabase.GetItems;
var
  SqlText : String;
  i: Integer;
begin
  SqlText := 'select LEVEL, NAME from ' + ITEMS;
  i := 0;
  try
    FSQLQuery.Close;

    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName:=dbFile;

    FSQLQuery.SQL.Text := SqlText;

    FSQLite3Connection.Open;
    FSQLQuery.Open;
    FSQLQuery.First;

    while not FSQLQuery.Eof do begin
      Inc(i);
      Setlength(FAllItems, i);
      FAllItems[i-1].idColumn := FSQLQuery.FieldByName('LEVEL').AsInteger;
      FAllItems[i-1].idItem := FSQLQuery.FieldByName('NAME').AsString;
      FSQLQuery.next;
    end;

    FSQLQuery.Close;
    FSQLite3Connection.Close();

    AddDbOpenMessage(mInformation, 'De items zijn opgehaald. (' + IntToStr(i) + ' items.)');
  except
    on E: EDatabaseError do begin
      AddDbOpenMessage(mError, 'Het ophalen van alle items is mislukt.');
      AddDbOpenMessage(mError, 'Melding:');
      AddDbOpenMessage(mError, E.Message);
      AddDbOpenMessage(mError, '');
    end;
  end;
end;

end.


