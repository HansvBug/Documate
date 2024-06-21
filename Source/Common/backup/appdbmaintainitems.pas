unit AppDbMaintainItems;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Grids, fileutil, lazfileutils,
  SQLite3Conn, DB, SQLDB,
  AppDb;

const
  { (I)tem (A)ction }
  iaCreate = 'Create';  // Item Action = Create
  iaRead = 'Read';      // Item Action = Read
  iaUpdate = 'Update';  // Item Action = Update
  iaDelete = 'Delete';  // Item Action = Delete

type
  PDbMaintainMessagesRec = ^TDbMaintainMessagesRec; { #todo : Move to AppDb }
  TDbMaintainMessagesRec = record
    dbmType : TMessageType;
    dbmText: string;
  end;

  PtrItemObject = ^ItemObjectData;
  ItemObjectData = record
    Id_table         : Integer;  // ID column database table ITEMS. NOT used
    Guid             : String;
    Level            : Integer;
    Name             : String;
    Parent_guid      : array of String;
    MemoNew          : String;
    MemoCurrent      : String;
    Action           : String;
    GridObject       : Pointer;
    sgCol,
    sgRow            : Integer;
    MustSave         : Boolean;
  end;
  AllItemsObjectData = array of ItemObjectData;

  PGetColumnNameRec = ^TGetColumnNameRec;
  TGetColumnNameRec = record
    ColumnName : string;
    Key        : String;
    Value      : String;
    AllColNames: array of string;
    aGrid : TObject;
    Success : Boolean;
    NameView : String;
  end;
  AllColumnNames = array of TGetColumnNameRec;

  PItemList = ^TItemList;
  TItemList = record
    aGuid  : String;
    Parent_guid : Array of string;
    Action : String;
  end;



  { TAppDbMaintainItems }

  TAppDbMaintainItems = class(TAppDatabase)
    private
      FSQLite3Connection: TSQLite3Connection;  { #todo : Is gelijk aan appdbCreate. Kan naar AppDb unit }
      FSQLTransaction: TSQLTransaction;
      FSQLQuery :TSQLQuery;
      FArrayCounter : Integer;

      FCanSave : Boolean;
      FDeleteList : array of TItemList;

      { Create a GUID }
      function CreateNewGuid: String;
      function ReadLevel(aGrid: Pointer; level: Byte): Boolean;
      procedure GetRelations;
      procedure PopulateStringGrid(aGrid: Pointer; level: Byte);
      procedure AddDbMaintainMessage(messageType : TMessageType; aMessage: String);
      function InsertDbItems: Boolean;
      function UpdateDbItems: Boolean;
      function DeleteDbItems: Boolean;
      function InsertRelation(aGuid, PGuid: String): Boolean;
      function DeleteRelation(aGuid, PGuid: String): Boolean;

      function GetColNames: AllColumnNames;
      function GetNumbers(const Value: string): String;

      // Config view
      procedure UpdateColumnNames(Key, Value: String);

    public
      DbMaintainMessages : array of TDbMaintainMessagesRec;
      FSaveList : array of TItemList;


      constructor Create(DbFileName : String); overload;
      destructor  Destroy; override;

      function GetAllItems(aGrid : Pointer; level : Byte): Boolean;
      function AddItem(anItem: Pointer): string;     { #todo : Kan dit 1 nveau hoger? betreft alleen de array AllItems. }
      procedure UpdateItem(anItem: Pointer);  { #todo : Kan dit 1 nveau hoger? betreft alleen de array AllItems. }
      function DeleteItem(anItem: Pointer): Boolean;  { #todo : Kan dit 1 nveau hoger? betreft alleen de array AllItems. }
      function SaveChanges: Boolean;
      function SaveRelations: Boolean;
      procedure AddToDeleteList(aGuid: String);
      procedure ResetDeleteList;

      // Config view
      function GetAllColumnNames : AllColumnNames;
      function SaveColumnNames(sgData: Pointer): TGetColumnNameRec;

      property CanSave : Boolean read FCanSave write FCanSave;
  end;

var
  AllItems : AllItemsObjectData;

implementation

{ TAppDbMaintainItems }

function TAppDbMaintainItems.CreateNewGuid: String;
var
  newGUID: TGUID;
begin
  CreateGUID(newGUID);
  Result := GUIDToString(newGUID);
end;

function TAppDbMaintainItems.ReadLevel(aGrid: Pointer; level: Byte): Boolean;
var
  SqlText : String;
begin
  SqlText := 'select ID, GUID, LEVEL, NAME ';
  SqlText += 'from '+ ITEMS;
  if level > 0 then begin
    SqlText += ' where LEVEL = :LEVEL';
  end;

  try
    FSQLQuery.Close;
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;

    FSQLQuery.PacketRecords := -1;
    FSQLQuery.SQL.Text := SqlText;

    FSQLite3Connection.Open;

    if level > 0 then begin
      FSQLQuery.Params.ParamByName('LEVEL').AsInteger := level;
    end;

    FSQLQuery.Open;

    if FSQLQuery.RecordCount > 0 then begin
      SetLength(AllItems, Length(AllItems)+ FSQLQuery.RecordCount );  // +1 ?
    end;

    FSQLQuery.First;
    while not FSQLQuery.Eof do begin
      AllItems[FArrayCounter].Id_table := FSQLQuery.FieldByName('ID').AsInteger;
      AllItems[FArrayCounter].Guid := FSQLQuery.FieldByName('GUID').AsString;
      AllItems[FArrayCounter].Name := FSQLQuery.FieldByName('NAME').AsString;
      AllItems[FArrayCounter].Level := FSQLQuery.FieldByName('LEVEL').AsInteger;
      AllItems[FArrayCounter].Action := iaRead;  // when opening the first time all items actions are set to "Read".
      AllItems[FArrayCounter].GridObject := aGrid;

      FSQLQuery.next;
      Inc(FArrayCounter);
    end;

    FSQLQuery.Close;
    FSQLite3Connection.Close();
    Result := True;
  except
    on E : Exception do begin
      Result := False;
      AddDbMaintainMessage(mtError, 'Fout bij het ophalen van alle items.');
      AddDbMaintainMessage(mtError, 'Melding:');
      AddDbMaintainMessage(mtError, E.Message);
      AddDbMaintainMessage(mtError, '');
    end;
  end;
end;

procedure TAppDbMaintainItems.GetRelations;
var
  SqlText : String;
  i,j,k   : Integer;
begin
  SqlText := 'select GUID_LEVEL_A, GUID_LEVEL_B from ' + REL_ITEMS;

  try
    FSQLQuery.Close;
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;

    FSQLQuery.PacketRecords := -1;
    FSQLQuery.SQL.Text := SqlText;

    FSQLQuery.Open;

    FSQLQuery.First;
    while not FSQLQuery.Eof do begin
      for i := 0 to Length(AllItems) - 1 do begin
        if AllItems[i].Guid = FSQLQuery.FieldByName('GUID_LEVEL_A').AsString then begin
          for j := 0 to Length(AllItems) - 1 do begin
            if AllItems[j].Guid = FSQLQuery.FieldByName('GUID_LEVEL_B').AsString then begin
              SetLength(AllItems[j].Parent_guid, length(AllItems[j].Parent_guid) + 1);

              for k := 0 to Length(AllItems[j].Parent_guid) - 1 do begin
                if AllItems[j].Parent_guid[k] = '' then begin
                  AllItems[j].Parent_guid[k] := FSQLQuery.FieldByName('GUID_LEVEL_A').AsString;
                end;
              end;

            end;
          end;
        end;
      end;
      FSQLQuery.next;
    end;

    FSQLQuery.Close;
    FSQLite3Connection.Close();
  except
    on E : Exception do begin
      AddDbMaintainMessage(mtError, 'Fout bij het ophalen van de relaties.');
      AddDbMaintainMessage(mtError, 'Melding:');
      AddDbMaintainMessage(mtError, E.Message);
      AddDbMaintainMessage(mtError, '');
    end;
  end;
end;

procedure TAppDbMaintainItems.PopulateStringGrid(aGrid: Pointer; level: Byte);
var
  i, j, k : Integer;
  sg : TStringGrid;
  pItem : PtrItemObject;
  aCol, aRow : Integer;
begin
  if length(AllItems) > 0 then begin
    sg :=  TStringGrid(aGrid);   // Dit past niet in het MVP concept. TStringGrid hoort bij de View en niet in een logica unit.

    // clear the StringDrid pointer objects.
    sg.BeginUpdate;

    if sg.RowCount > 0 then begin
      for j := 0 to sg.RowCount-1 do begin
        for k := 0 to sg.ColCount -1 do begin
          if PtrItemObject(sg.Objects[k,j]) <> nil then begin
            Dispose(PtrItemObject(sg.Objects[k,j]));
          end;
        end;
      end;
    end;

    aCol := 3;  // The item name = column 3 in the StringGrid.
    aRow := 1;

    for i := 0 to length(AllItems) -1 do begin
      if level = AllItems[i].Level then begin
        new(pItem);
        pItem^.Name := AllItems[i].Name;
        pItem^.Action := AllItems[i].Action;
        pItem^.Id_table := AllItems[i].Id_table;
        pItem^.Guid := AllItems[i].Guid;
        pItem^.Level:= AllItems[i].Level;
        pItem^.Parent_guid := AllItems[i].Parent_guid;
        pItem^.MemoCurrent := AllItems[i].MemoCurrent;

        sg.RowCount := sg.RowCount + 1;

        sg.Cells[aCol, aRow] := AllItems[i].Name;
        sg.Objects[aCol, aRow] := TObject(pItem);

        // Uncheck all checkboxes
        sg.Cells[1,aRow] := '0';  // "Uncheck" parent checkbox cell
        sg.Cells[2,aRow] := '0';  // "Uncheck" child checkbox cell

        Inc(aRow);
      end;
    end;

    sg.EndUpdate;
  end;
end;

procedure TAppDbMaintainItems.AddDbMaintainMessage(messageType: TMessageType;
  aMessage: String);
begin
  SetLength(DbMaintainMessages, Length(DbMaintainMessages) + 1);
  DbMaintainMessages[Length(DbMaintainMessages) -1].dbmType := messageType;
  DbMaintainMessages[Length(DbMaintainMessages) -1].dbmText := aMessage;
end;

function TAppDbMaintainItems.InsertDbItems: Boolean;
var
  SqlText : String;
  i : Integer;
  CanContinue : Boolean;
begin
  CanContinue := True;
  for i := 0 to Length(AllItems) -1 do begin
    if AllItems[i].Guid <> '' then begin
      if AllItems[i].Action = iaCreate then begin

        SqlText := 'insert into ' + ITEMS + '(GUID, LEVEL, NAME, DATE_CREATED, CREATED_BY) ';
        SqlText += 'select :GUID, :LEVEL, :NAME, :DATE_CREATED, :CREATED_BY ';
        SqlText += 'where not exists (select NAME from ' + ITEMS; // There are no duplicates allowed so this where is not necessary
        SqlText += ' where NAME = :NAME and LEVEL = :LEVEL);';

        try
          FSQLQuery.Close;
          FSQLite3Connection.Close();
          FSQLite3Connection.DatabaseName := dbFile;

          FSQLQuery.SQL.Text := SqlText;

          FSQLQuery.Params.ParamByName('GUID').AsString := AllItems[i].Guid;
          FSQLQuery.Params.ParamByName('LEVEL').AsInteger := AllItems[i].Level;
          FSQLQuery.Params.ParamByName('NAME').AsString := AllItems[i].Name;
          FSQLQuery.Params.ParamByName('DATE_CREATED').AsString := FormatDateTime('DD MM YYYY hh:mm:ss', Now);
          FSQLQuery.Params.ParamByName('CREATED_BY').AsString := SysUtils.GetEnvironmentVariable('USERNAME');

          FSQLite3Connection.Open;
          FSQLTransaction.Active:=True;

          FSQLQuery.ExecSQL;

          FSQLTransaction.Commit;
          FSQLite3Connection.Close();

          AllItems[i].Action := iaRead; // Insert Item is done.

          AddDbMaintainMessage(mtInformation, 'Item ' + AllItems[i].Name + ' is toegevoegd aan tabel ' + ITEMS + '.');
        except
          on E: EDatabaseError do
            begin
              AddDbMaintainMessage(mtError, 'Het invoeren van een nieuw item in de tabel LEVEL_' + IntToStr(AllItems[i].Level) +' is mislukt.');
              AddDbMaintainMessage(mtError, 'Melding:');
              AddDbMaintainMessage(mtError, E.Message);
              CanContinue := False;
            end;
        end;
      end // action
    end
    else begin
      AddDbMaintainMessage(mtError, 'Nieuw item niet opgeslagen. Guid ontbreekt.');
    end
  end;
  result := CanContinue;
end;

function TAppDbMaintainItems.UpdateDbItems: Boolean;
var
  i : Integer;
  SqlText : String;
  CanContinue : Boolean;
begin
  CanContinue := True;
  for i := 0 to Length(AllItems) -1 do begin
    if AllItems[i].Guid <> '' then begin
      if AllItems[i].Action = iaUpdate then begin

        SqlText := 'update '+ ITEMS;
        SqlText += ' set NAME = :NAME';
        SqlText += ' where GUID = :GUID';
        SqlText += ' and LEVEL = :LEVEL';

        try
          FSQLQuery.Close;
          FSQLite3Connection.Close();
          FSQLite3Connection.DatabaseName := dbFile;

          FSQLQuery.SQL.Text := SqlText;

          FSQLQuery.Params.ParamByName('GUID').AsString := AllItems[i].Guid;
          FSQLQuery.Params.ParamByName('NAME').AsString := AllItems[i].Name;
          FSQLQuery.Params.ParamByName('LEVEL').AsInteger := AllItems[i].Level;
          { #todo -o- : Add modified by and modified date bij de update. }

          FSQLite3Connection.Open;
          FSQLTransaction.Active:=True;

          FSQLQuery.ExecSQL;

          FSQLTransaction.Commit;
          FSQLite3Connection.Close();

          AllItems[i].Action := iaRead; // Update is done.
          AddDbMaintainMessage(mtInformation, 'Item ' + AllItems[i].Name + ' is gemuteerd in tabel ' + ITEMS + '.');
        except
          on E: EDatabaseError do
            begin
              AddDbMaintainMessage(mtError, 'Het hernoemen van een bestaand item is mislukt.');
              AddDbMaintainMessage(mtError, 'Melding:');
              AddDbMaintainMessage(mtError, E.Message);
              CanContinue := False;
            end;
        end;
      end;
    end;
  end;
  result := CanContinue;
end;

function TAppDbMaintainItems.DeleteDbItems: Boolean;
var
  i : Integer;
  SqlText : String;
  CanContinue : Boolean;
begin
  CanContinue := True;

  for i := 0 to Length(AllItems) -1 do begin
    if AllItems[i].Guid <> '' then begin
      if AllItems[i].Action = iaDelete then begin

        SqlText := 'delete from ' + ITEMS;
        SqlText += ' where GUID = :GUID';

        try
          FSQLQuery.Close;
          FSQLite3Connection.Close();

          FSQLite3Connection.DatabaseName := dbFile;
          FSQLite3Connection.Open;

          FSQLQuery.SQL.Text := SqlText;

          FSQLQuery.Params.ParamByName('GUID').AsString := AllItems[i].Guid;

          FSQLite3Connection.Open;
          FSQLTransaction.Active:=True;

          FSQLQuery.ExecSQL;

          FSQLTransaction.Commit;
          FSQLite3Connection.Close();

          AllItems[i].Action := iaRead; // Update is done.
          AddDbMaintainMessage(mtInformation, 'Item ' + AllItems[i].Name + ' is verwijdert uit de tabel ' + ITEMS + '.');

        except
          on E : Exception do begin
            AddDbMaintainMessage(mtError, 'Fout bij het verwijderen van een item.');
            AddDbMaintainMessage(mtError, 'Melding:');
            AddDbMaintainMessage(mtError, E.Message);

            CanContinue := False;
          end;
        end;
      end;
     end;
   end;
   result := CanContinue;
end;

function TAppDbMaintainItems.InsertRelation(aGuid, PGuid: String): Boolean;
var
  i : Integer;
  SqlText : String;
  CanContinue : Boolean;
begin
  CanContinue := false;
  if (aGuid <> '') and (PGuid <> '') then begin

    SqlText := 'insert into ' + REL_ITEMS + '(GUID, GUID_LEVEL_A, GUID_LEVEL_B) ';
    SqlText += 'select :GUID, :GUID_LEVEL_A, :GUID_LEVEL_B ';
    SqlText += 'where not exists (select GUID from ' + REL_ITEMS;
    SqlText += ' where GUID_LEVEL_A = :GUID_LEVEL_A and GUID_LEVEL_B = :GUID_LEVEL_B);';

    try
      FSQLQuery.Close;
      FSQLite3Connection.Close();

      FSQLite3Connection.DatabaseName := dbFile;
      FSQLite3Connection.Open;

      FSQLQuery.SQL.Text := SqlText;

      FSQLQuery.Params.ParamByName('GUID').AsString := CreateNewGuid;
      FSQLQuery.Params.ParamByName('GUID_LEVEL_A').AsString := PGuid;
      FSQLQuery.Params.ParamByName('GUID_LEVEL_B').AsString := aGuid;

      FSQLite3Connection.Open;
      FSQLTransaction.Active:=True;

      FSQLQuery.ExecSQL;

      FSQLTransaction.Commit;
      FSQLite3Connection.Close();

      CanContinue := true;

      AddDbMaintainMessage(mtInformation, 'Relatie toegevoegd. Parent: ' + PGuid + '; child: ' + aGuid + '.');
    except
      on E : Exception do begin
        AddDbMaintainMessage(mtError, 'Fout bij het toevoegen van een realatie.');
        AddDbMaintainMessage(mtError, 'Melding:');
        AddDbMaintainMessage(mtError, E.Message);
      end;
    end;
  end;
  result := CanContinue;
end;

function TAppDbMaintainItems.DeleteRelation(aGuid, PGuid: String): Boolean;
var
  i : Integer;
  SqlText : String;
  CanContinue : Boolean;
begin
  CanContinue := false;
  if (aGuid <> '') and (PGuid <> '') then begin

    SqlText := 'delete from ' + REL_ITEMS;
    SqlText += ' where GUID_LEVEL_A = :GUID_A';
    SqlText += ' and  GUID_LEVEL_B = :GUID_B';
  end
  else if (aGuid <> '') and (PGuid = '') then begin
    SqlText := 'delete from ' + REL_ITEMS;
    SqlText += ' where GUID_LEVEL_A = :GUID_A';
  end;

  try
    FSQLQuery.Close;
    FSQLite3Connection.Close();

    FSQLite3Connection.DatabaseName := dbFile;
    FSQLite3Connection.Open;

    FSQLQuery.SQL.Text := SqlText;

    if (aGuid <> '') and (PGuid <> '') then begin
      FSQLQuery.Params.ParamByName('GUID_A').AsString := PGuid;
      FSQLQuery.Params.ParamByName('GUID_B').AsString := aGuid;
    end
    else if (aGuid <> '') and (PGuid = '') then begin
      FSQLQuery.Params.ParamByName('GUID_A').AsString := aGuid;
    end;


    FSQLite3Connection.Open;
    FSQLTransaction.Active:=True;

    FSQLQuery.ExecSQL;

    FSQLTransaction.Commit;
    FSQLite3Connection.Close();

    CanContinue := true;
    AddDbMaintainMessage(mtInformation, 'Relatie verwijderd. Parent: ' + PGuid + '; child: ' + aGuid + '.');
  except
    on E : Exception do begin
      AddDbMaintainMessage(mtError, 'Fout bij het verwijderen van een realatie.');
      AddDbMaintainMessage(mtError, 'Melding:');
      AddDbMaintainMessage(mtError, E.Message);
    end;
  end;


  result := CanContinue;
end;

procedure TAppDbMaintainItems.AddToDeleteList(aGuid: String);
begin
  if FDeleteList = nil then SetLength(FDeleteList,0);

  if aGuid <> '' then begin
    Setlength(FDeleteList, Length(FDeleteList)+1);
    FDeleteList[Length(FDeleteList)-1].aGuid := aGuid;
    FDeleteList[Length(FDeleteList)-1].Action := 'Delete';
  end;
end;

procedure TAppDbMaintainItems.ResetDeleteList;
begin
  SetLength(FDeleteList,0);
end;

function TAppDbMaintainItems.GetColNames: AllColumnNames;
var
  SqlText : String;
  allNames : AllColumnNames = nil;
  collData : TGetColumnNameRec;
  i : Integer;
begin
  SqlText := 'select KEY, VALUE from ' + SETTINGS_META;
  SqlText += ' where KEY like :KEY';
  SqlText += ' order by KEY';

  try
    FSQLQuery.Close;
    FSQLite3Connection.Close();

    FSQLite3Connection.DatabaseName := dbFile;
    FSQLQuery.SQL.Text := SqlText;
    FSQLQuery.Params.ParamByName('KEY').AsString := 'COL_%'; // how to escape _ in SQLlite?

    FSQLite3Connection.Open;
    FSQLQuery.Open;
    FSQLQuery.First;

    i := 1;
    while not FSQLQuery.Eof do begin

      if GetNumbers(copy(FSQLQuery.FieldByName('KEY').AsString,5,3)) <> '' then begin
        SetLength(allNames, i);
        collData.Key := GetNumbers(copy(FSQLQuery.FieldByName('KEY').AsString,5,3));
        collData.Value := FSQLQuery.FieldByName('VALUE').AsString;
        allNames[i-1] :=  collData;
        Inc(i);
      end;
      FSQLQuery.next;
    end;

    FSQLQuery.Close;
    FSQLite3Connection.Close();
    Result := allNames;
  except
    on E : Exception do begin
      AddDbMaintainMessage(mtError, 'Fout bij het ophalen van de kolom namen.');
      AddDbMaintainMessage(mtError, 'Melding:');
      AddDbMaintainMessage(mtError, E.Message);
      Result := nil;
    end;
  end;
end;

function TAppDbMaintainItems.GetNumbers(const Value: string): String;
var
  ch: char;
  Index, Count: integer;
begin
  { #todo : Dezelfde functie staat ook in het main form }
  Result := '';
  SetLength(Result, Length(Value));
  Count := 0;
  for Index := 1 to length(Value) do
  begin
    ch := Value[Index];
    if (ch >= '0') and (ch <='9') then
    begin
      inc(Count);
      Result[Count] := ch;
    end;
  end;
  SetLength(Result, Count);
end;

procedure TAppDbMaintainItems.UpdateColumnNames(Key, Value: String);
var
  SqlText : String;
begin
  SqlText := 'update ' + SETTINGS_META;
  SqlText += ' set VALUE = :VALUE';
  SqlText += ' where KEY = :KEY';
  try
    FSQLQuery.Close;
    FSQLite3Connection.Close();
    FSQLite3Connection.DatabaseName := dbFile;

    FSQLQuery.SQL.Text := SqlText;

    FSQLQuery.Params.ParamByName('VALUE').AsString := Value;
    FSQLQuery.Params.ParamByName('KEY').AsString := 'COL_' + Key;

    FSQLite3Connection.Open;
    FSQLTransaction.Active:=True;

    FSQLQuery.ExecSQL;

    FSQLTransaction.Commit;
    FSQLite3Connection.Close();
    FCanSave := True;
  except
    on E: EDatabaseError do
      begin
        AddDbMaintainMessage(mtError, 'Het actualiseren van de kolomnamen is mislukt.');
        AddDbMaintainMessage(mtError, 'Melding:');
        AddDbMaintainMessage(mtError, E.Message);
        FCanSave := False;
      end;
  end;
end;

constructor TAppDbMaintainItems.Create(DbFileName: String);
begin
  inherited Create;
  dbFile := DbFileName;

  FSQLite3Connection:= TSQLite3Connection.Create(nil);
  FSQLTransaction:= TSQLTransaction.Create(nil);
  FSQLQuery:= TSQLQuery.Create(nil);

  // Connect together
  FSQLite3Connection.Transaction := FSQLTransaction;
  FSQLQuery.DataBase := FSQLite3Connection;

  Setlength(AllItems,0);
  FArrayCounter := 0;
end;

destructor TAppDbMaintainItems.Destroy;
begin
  //sg.Free;
  FSQLQuery.Free;
  FSQLTransaction.Free;
  FSQLite3Connection.Free;
  inherited Destroy;
end;

function TAppDbMaintainItems.GetAllItems(aGrid: Pointer; level: Byte): Boolean;
var
  CanContinue : Boolean;
begin
  CanContinue := ReadLevel(aGrid, level);
  GetRelations;
  //
  if CanContinue then begin
    PopulateStringGrid(aGrid, level);
  end;

  Result := CanContinue;
end;

function TAppDbMaintainItems.AddItem(anItem: Pointer): string;
begin
  Setlength(AllItems, Length(AllItems) + 1);
  AllItems[Length(AllItems)-1].Guid := CreateNewGuid;
  AllItems[Length(AllItems)-1].Name := PtrItemObject(anItem)^.Name;
  AllItems[Length(AllItems)-1].Level := PtrItemObject(anItem)^.Level;
  AllItems[Length(AllItems)-1].Action := PtrItemObject(anItem)^.Action;

  result := AllItems[Length(AllItems)-1].Guid;
end;

procedure TAppDbMaintainItems.UpdateItem(anItem: Pointer);
var
  i: Integer;
begin
  for i := 0 to Length(AllItems)-1 do begin
    if AllItems[i].Guid = PtrItemObject(anItem)^.Guid then begin
      AllItems[i].Name := PtrItemObject(anItem)^.Name;

      // Item dat is aangemakt en direct gemuteerd zonder eerst op te slaan.
      // Actie moet dan Create blijven.
      if PtrItemObject(anItem)^.Action <> iaCreate then begin
        AllItems[i].Action := iaUpdate;
      end;
      break;
    end;
  end;
end;

function TAppDbMaintainItems.DeleteItem(anItem: Pointer): Boolean;
var
  i: Integer;
begin
  // parent als te verwijderen klaar zetten
  Result := False;
  for i := 0 to Length(AllItems)-1 do begin
    if AllItems[i].Guid = PtrItemObject(anItem)^.Guid then begin
      if PtrItemObject(anItem)^.Action = iaDelete then begin
        AllItems[i].Action := iaDelete;
        Result := True;
      end;
      break;
    end;
  end;
end;


function TAppDbMaintainItems.SaveChanges: Boolean;
var
  CanContinue : Boolean;
begin
  CanContinue := UpdateDbItems;
  if CanContinue then CanContinue := InsertDbItems;
  if CanContinue then CanContinue := DeleteDbItems;


  Result := CanContinue;
end;

function TAppDbMaintainItems.SaveRelations: Boolean;
var
  i : Integer;
begin
  for i:=0 to Length(FSaveList)-1 do begin
    if FSaveList[i].Action = 'Insert' then begin
      InsertRelation(FSaveList[i].aGuid, FSaveList[i].Parent_guid[0]);
    end
    else if FSaveList[i].Action = 'Existing Delete' then begin
      DeleteRelation(FSaveList[i].aGuid, FSaveList[i].Parent_guid[0]);
    end;
  end;

  for i:= 0 to length(FDeleteList)-1 do begin
    DeleteRelation(FDeleteList[i].aGuid, '');
  end;
end;

function TAppDbMaintainItems.GetAllColumnNames: AllColumnNames;
begin
  Result := GetColNames;
end;

function TAppDbMaintainItems.SaveColumnNames(sgData: Pointer): TGetColumnNameRec;
var
  lRec : PGetColumnNameRec;
  r : Integer;
  _sg : TStringGrid;
begin
  lRec := PGetColumnNameRec(sgData);
  _sg := TStringGrid(lRec^.aGrid);

  for r:=1 to _sg.RowCount-1 do begin
    UpdateColumnNames(_sg.Cells[0,r], _sg.Cells[1,r]);
  end;

 with result do begin
   Success := FCanSave;
 end;

end;

end.

