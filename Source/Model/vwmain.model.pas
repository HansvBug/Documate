unit vwmain.model;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LazFileUtils, vwmain.intf, vwmain.decl,
  Settings, Logging;

type

  { TModel }

  TModel = class(TObject, IModel)
    private
      FOwner: IPresenter;
      FAppName, FAppVersion, FAppBuildDate : String;
      FSettings : TSettings;
      Logging : TLog_File;
      FBuildComponents : TBuildComponents;
      FAppDbMaintain : TAppDbMaintainItems;
      FStringGridFabric : TStringGridFab;
      FDbIsOpened: Boolean;  // For the config view a DB must be open to read the column names. If not open then not start reading columnnaes in the config view.

      function get_AppBuildate: String;
      function get_AppName: String;
      function get_AppVersion: String;
      function get_BldComponents: TBuildComponents;
      function get_Settings: TSettings;
      function Obj: TObject;
      procedure set_AppBuildate(AValue: String);
      procedure set_AppName(AValue: String);
      procedure set_AppVersion(AValue: String);
      procedure set_BldComponents(AValue: TBuildComponents);
      procedure set_settings(AValue: TSettings);
      { Check for messages while creating the database(tables). }
      procedure WriteAllCreateMessagesToLog(CreFile : TCreateAppdatabase);  { #todo : Move record with messages to AppDb. Then less functions needed. }
      procedure WriteAllMaintainMessagesToLog(MaintainFile : TAppDbMaintainItems); { #todo : Move record with messages to AppDb. Then less functions needed. }

    public
      constructor Create(anOwner: IPresenter);
      destructor Destroy; override;
      function FetchViewTextsFull: TStaticTextsAll;
      function SetStatusbartext(aText: string; panel : Word): TStatusbarPanelText;
      function CreateDirs(const aRootDir: string;const aDirList: string = ''): TDirectoriesRec;
      function ReadSettings(SettingsFile, FormName: string): TSettingsRec;
      function ReadFormState(SettingsFile, FormName: string): TSettingsRec;
      function WriteSettings : TSettingsRec;
      function StoreFormState : TSettingsRec;
      procedure StartLogging(LogFile : string);
      procedure StopLogging;
      procedure WriteToLog(aLogAction: TLoggingAction; LogText: String);
      function CreateDbFile(const aDir: string): TCreDbFileRec;
      function InsertDbMetaData(DbData : TCreDbFileRec): Boolean;

      function GetColumnCount(DbFileName: String): Integer;
      procedure RemoveOwnComponents(DbFilerec: TOpenDbFilePrepareViewRec);
      function BuildAllComponents(DbFilerec : TOpenDbFilePrepareViewRec) : TOpenDbFilePrepareViewRec;
      function GetItems(Items: TOpenDbFileGetDataRec): TOpenDbFileGetDataRec;
      function ClearMainView(Objectdata: TClearPtrData): TClearPtrData;
      function CreateDbItemsMaintainer(Filename: string) : TOpenDbFilePrepareViewRec;

      function ExtractNumberFromString(const Value: string): String;
      function SetStringGridHeaderFontStyle(aFontStyle: Integer): TStringGridRec;
      function AdjustStringGrid(SgRec : PStringGridRec; StringGridState: String): TStringGridRec;
      procedure ActiveStrgridCell(aSender: TObject; ViaAddButton: Boolean);
      procedure StringGridOnPrepareCanvas(aSender: TObject; aCol, aRow: Integer; ShowRelationColor: Boolean);
      procedure StringGridOnSelectCell(aSender: TObject; sgSelect: Pointer);
      procedure StringGridOnDrawCell(aSender: TObject; sgSelect: Pointer);
      function ValidateCellEntry(sgObject: TObject; aText: string; aRow: Integer): TSaveBtn;

      function AddNewItem(anItem: PtrItemObject): TItemObjectData;
      function UpdateItem(anItem : PtrItemObject): TItemObjectData;
      function DeleteItem(anItem : PtrItemObject): TItemObjectData;
      function SaveChanges(scRec: PSaveChangesRec): Boolean;
      function SetReadyRelation(cbToggled : PCheckBoxCellPosition) : TCheckBoxCellPosition;

      // config view
      function GetColumnNames: TGetColumnNameRec;
      function SaveColumnNames(sgData: PGetColumnNameRec) :TGetColumnNameRec;
      procedure PrepareCloseDb;

      property ApplicationName : String read get_AppName write set_AppName;
      property ApplicationVersion : String read get_AppVersion write set_AppVersion;
      property ApplicationBuildate : String read get_AppBuildate write set_AppBuildate;
      Property Settings : TSettings read get_Settings write set_settings;
      property BuildComponents : TBuildComponents read get_BldComponents write set_BldComponents;

  end;

implementation

{ TModel }

{%Region Properties}
function TModel.get_AppName: String;
begin
  Result := FAppName;
end;

procedure TModel.set_AppName(AValue: String);
begin
  FAppName := AValue;
end;

function TModel.get_AppVersion: String;
begin
  Result := FAppVersion;
end;

procedure TModel.set_AppVersion(AValue: String);
begin
  FAppVersion := AValue;
end;

function TModel.get_BldComponents: TBuildComponents;
begin
  Result := FBuildComponents;
end;

procedure TModel.set_BldComponents(AValue: TBuildComponents);
begin
  FBuildComponents := AValue;
end;

function TModel.get_AppBuildate: String;
begin
  Result := FAppBuildDate;
end;

procedure TModel.set_AppBuildate(AValue: String);
begin
  FAppBuilddate := AValue;
end;

function TModel.get_Settings: TSettings;
begin
  Result := FSettings;
end;

procedure TModel.set_settings(AValue: TSettings);
begin
  FSettings := AValue;
end;

function TModel.Obj: TObject;
begin
  Result:= Self;
end;

{%EndRegion Properties}

procedure TModel.WriteAllCreateMessagesToLog(CreFile: TCreateAppdatabase);
var
  i : Integer;
begin
  for i := 0 to Length(CreFile.DbCreateMessages) -1 do begin
    if Ord(CreFile.DbCreateMessages[i].dbmType) = 0 then begin
      WriteToLog(laInformation, CreFile.DbCreateMessages[i].dbmText);
    end
    else if Ord(CreFile.DbCreateMessages[i].dbmType) = 1 then begin
      WriteToLog(laError, CreFile.DbCreateMessages[i].dbmText);
    end;
  end;

  // Clear the messages
  SetLength(CreFile.DbCreateMessages, 0);
end;

procedure TModel.WriteAllMaintainMessagesToLog(MaintainFile: TAppDbMaintainItems);
var
  i : Integer;
begin
  for i := 0 to Length(MaintainFile.DbMaintainMessages) -1 do begin
    if Ord(MaintainFile.DbMaintainMessages[i].dbmType) = 0 then begin
      WriteToLog(laInformation, MaintainFile.DbMaintainMessages[i].dbmText);
    end
    else if Ord(MaintainFile.DbMaintainMessages[i].dbmType) = 1 then begin
      WriteToLog(laError, MaintainFile.DbMaintainMessages[i].dbmText);
    end;
  end;

  // Clear the messages
  SetLength(MaintainFile.DbMaintainMessages, 0);
end;

constructor TModel.Create(anOwner: IPresenter);
begin
  inherited Create;
  FOwner := anOwner;
  FStringGridFabric := TStringGridFab.Create;
  FDbIsOpened := False;
end;

destructor TModel.Destroy;
begin
  if assigned(FStringGridFabric) then FreeAndNil(FStringGridFabric);
  if assigned(FAppDbMaintain) then FreeAndNil(FAppDbMaintain);
  StopLogging;
  if assigned(FSettings) then FreeAndNil(FSettings);
  FOwner := nil;
  inherited Destroy;
end;

function TModel.FetchViewTextsFull: TStaticTextsAll;
begin
  with Result do begin
    staClear := '';
    staVwmainTitle := Application_name;

    staMmiProgramCaption := '&Program';                     // &Programma
    staMmiProgramOpenDbFileCaption := '&Open data file';    // &Open databestand
    staMmiProgramCloseDbFileCaption := 'C&lose data file';  // &Sluit databestand
    staMmiProgramNewDbFileCaption := '&New data file';      // &Nieuw databestand
    staMmiProgramQuitCaption := 'Close';                    // Afsluiten

    staVwConfigure := 'Settings';                           // Instellingen
    staMmiOptionsCaption := '&Options';                     // &Opties
    staMmiOptionsOptionsCaption := '&Settings';             // &Instellingen
    staMmiOptionsLanguageENCaption := '&English';           // &Engels
    staMmiOptionsLanguageNLCaption := '&Dutch';             // &Nederlands

    staMmiOptionsLanguageCaption := '&Language';            // &Taal
    staTbsMiscellaneousCaption := 'Miscellaneous';          // Diversen
    staTbsAppDdCaption := 'Application Database';           // Applicatie database
    staOptionsBtnCloseCaption := 'Close';                   // Sluiten

    staGbLoggingCaption := 'Logging';                       // Logging
    staChkActiveLoggingCaption := 'Active logging';         // Activeer logging
    staChkAppendLoggingCaption := 'Append logfile';         // Aanvullen logbestand
    staGroupBoxColumnNamesCaption := 'Column names';        // Kolom namen
    stabtnColumnSaveCaption := '&Save';                     // Op&slaan
    staSgColLevel := 'Level';                               // Kolom
    staSgColName := 'Name';                                 // Naam

    staTsItemsCaption := 'Items';                           // Items

    staRgrpStrings_1 := 'Read only';                        // Raadplegen
    staRgrpStrings_2 := 'Modify items';                     // Muteer items
    staRgrpStrings_3 := 'Modify relations';                 // Muteer relaties
    staBtnSaveCaption := '&Save';                           // Opslaan

    staPmiAutoSizeStringGridCaption := 'Autosize';          // Automatische grootte lijst / Volledige breedte Lijst
    staPmiAutoSizeStringGridAllCaption := 'Autosize all';   // Automatische grootte alle lijsten / Volledige breedte alle Lijsten
    staPmiDeleteItemCaption := 'Delete row';                // Verwijder regel
    staPmiAddItemCaption := 'Add row';                      // Voeg rij toe
    staPmiImportCaption := 'Import';                        // Importeer

  end;
  { #todo : resourse file / languages EN and NL }
end;

function TModel.SetStatusbartext(aText: string; panel: Word
  ): TStatusbarPanelText;
begin
  with Result do begin
    case panel of
      0: begin
           sbpt_panel0 := aText;
           sbpt_activePanel := 0;
      end;
      1: begin
           sbpt_panel1 := aText;
           sbpt_activePanel := 1;
      end;
      2: begin
           sbpt_panel2 := aText;
           sbpt_activePanel := 2;
      end;
    end;
  end;
end;

function TModel.CreateDirs(const aRootDir: string; const aDirList: string
  ): TDirectoriesRec;
var
  //  i: integer;
    s: string;
    ldl: TStrings;
begin
  with Result do try // <-- !!!
    if aRootDir = '' then begin
      dirRoot:= ExtractFilePath(ParamStr(0)); { iirc "ExtractFilePath()" includes trailing delimiter }
      if DirectoryIsWritable(dirRoot) then begin
        if aDirList <> '' then begin
          dirRoot:= IncludeTrailingPathDelimiter(dirRoot); { checks for \/ }
          ldl:= TStringList.Create;

          try
            ldl.Text:= aDirList; { quick'n'dirty way of assigning a whole stringlist to another }
            for s in ldl do begin
              if not DirectoryExists(dirRoot+s) then begin
                try MkDir(dirRoot+s); except  end;
              end;
              //lpr.prText:= '<'+s+'>';
            end;
          finally
            ldl.Free;
          end;

          dirSuccesMsg := amSucces;
          dirSucces:= true;
        end; // items in dirlist
      end; // writable
    end else begin
      if DirectoryExists(aRootDir) then begin
        dirRoot:= IncludeTrailingPathDelimiter(aRootDir); { checks for \/ }
        if DirectoryIsWritable(dirRoot) then begin
          if aDirList <> '' then begin
            ldl:= TStringList.Create;

            try
              ldl.Text:= aDirList; { quick'n'dirty way of assigning a whole stringlist to another }
              for s in ldl do begin
                if not DirectoryExists(dirRoot+s) then begin
                  try MkDir(dirRoot+s); except  end;
                end;
                //lpr.prText:= '<'+s+'>';
              end;
            finally
              ldl.Free;
            end;

            dirSuccesMsg := amSucces;
            dirSucces:= true;
          end;
        end else begin
          dirSuccesMsg := 'Root is Read-Only!'; dirSucces:= false;
        end; //RO
      end else begin
        dirSuccesMsg := 'Root does not exist!'; dirSucces:= false;
      end; // not exist
    end; // rootdir provided
  except on E:Exception do
    begin
      dirSuccesMsg := amFailed;
      dirSucces:= false;
      { we /only/ use the "owner" strategi with errors or progress reports }
      //fOwner.Provider.NotifySubscribers(prErrorFile,E,@Result);
    end;
  end;
end;

function TModel.ReadSettings(SettingsFile, FormName: string): TSettingsRec;
begin
  if assigned(FSettings) then FreeAndNil(FSettings);

  FSettings := TSettings.Create(SettingsFile);
  FSettings.FormName := FormName;
  FSettings.ApplicationName := ApplicationName;
  FSettings.ApplicationVersion := ApplicationVersion;
  FSettings.ApplicationBuildDate := ApplicationBuildate;

  Fsettings.ReadFile;

  with result do try
    setActivateLogging := FSettings.ActivateLogging;
    setAppendLogging := FSettings.AppendLogging;
    setLanguage := FSettings.Language;
    //...
    setSucces := True;
  except on E:Exception do
    setSucces := False;
  end;
end;

function TModel.ReadFormState(SettingsFile, FormName: string): TSettingsRec;
begin
  if assigned(FSettings) then FreeAndNil(FSettings);

  FSettings := TSettings.Create(SettingsFile);
  Fsettings.ReadFormState(FormName);

  with result do try
    setFrmName := FSettings.FormName;
    setFrmWindowState := FSettings.FormWindowstate;
    setFrmTop := FSettings.FormTop;
    setFrmLeft := FSettings.FormLeft;
    setFrmHeight := FSettings.FormHeight;
    setFrmWidth := FSettings.FormWidth;
    setFrmRestoredTop := FSettings.FormRestoredTop;
    setFrmRestoredLeft := FSettings.FormRestoredLeft;
    setFrmRestoredHeight := FSettings.FormRestoredHeight;
    setFrmRestoredWidth := FSettings.FormRestoredWidth;
    //...
    setSucces := True;
  except on E:Exception do
    setSucces := False;
  end;
end;

function TModel.WriteSettings: TSettingsRec;
begin
  FSettings.FormName := Settings.FormName;
  FSettings.ActivateLogging := Settings.ActivateLogging;
  FSettings.AppendLogging := Settings.AppendLogging;
  FSettings.Language := Settings.Language;

  FSettings.WriteSettings;

  with result do try
    setActivateLogging := FSettings.ActivateLogging;
    setAppendLogging := FSettings.AppendLogging;
    setLanguage := FSettings.Language;
    //...
    setSucces := True;
  except on E:Exception do
    setSucces := False;
  end;
end;

function TModel.StoreFormState: TSettingsRec;
begin
  FSettings.StoreFormState;

  with result do try
    setFrmWindowState := FSettings.FormWindowstate;
    setFrmTop := FSettings.FormTop;
    setFrmLeft := FSettings.FormLeft;
    setFrmHeight := FSettings.FormHeight;
    setFrmWidth := FSettings.FormWidth;
    setFrmRestoredTop := FSettings.FormRestoredTop;
    setFrmRestoredLeft := FSettings.FormRestoredLeft;
    setFrmRestoredHeight := FSettings.FormRestoredHeight;
    setFrmRestoredWidth := FSettings.FormRestoredWidth;

    setSucces := True;
  except on E:Exception do
    setSucces := False;
  end;
end;

procedure TModel.StartLogging(LogFile: string);
begin
  if Logging = Nil then begin
    Logging := TLog_File.Create(LogFile);
    Logging.ActivateLogging := FSettings.ActivateLogging;
    Logging.AppendLogFile := FSettings.AppendLogging;
    Logging.ApplicationName := Application_name;
    Logging.AppVersion := Application_version;
    Logging.StartLogging;
  end;
end;

procedure TModel.StopLogging;
begin
  if assigned(Logging) then begin
    Logging.StopLogging;
    FreeAndNil(Logging);
    //Logging.Free;
  end;
end;

procedure TModel.WriteToLog(aLogAction: TLoggingAction; LogText: String);
begin
  if Logging <> Nil then begin
    case aLogAction of
      laInformation: Logging.WriteToLogInfo(LogText);
      laWarning: Logging.WriteToLogWarning(LogText);
      laError: Logging.WriteToLogError(LogText);
      laDebug: Logging.WriteToLogDebug(LogText);
    else ;
    end;
  end;
end;

function TModel.CreateDbFile(const aDir: string): TCreDbFileRec;
var
  CreFile : TCreateAppdatabase;
begin
  with Result do
  try
    CreFile := TCreateAppdatabase.Create(aDir, Application_databaseVersion);

    if not CreFile.CheckForDllFile then begin
      cdbfSucces := False;
      cdbfMessage := 'The necessary SQLite dll file is missing. (sqlite3.dll).';
      WriteToLog(laError, 'The necessary SQLite dll file is missing. (sqlite3.dll).' + aDir);
      CreFile.Free;
      exit;
    end;

    if CreFile.CreateNewDatabase then begin
      cdbfSucces := True;
    end
    else begin
      cdbfSucces := False;
    end;

    WriteAllCreateMessagesToLog(CreFile);  // Write information and/or error massages to the log file.

    CreFile.Free;
  except on E:Exception do
    begin
      WriteToLog(laError, 'Failed to create Database. ' + aDir);
      WriteToLog(laError, e.ToString);
    end;
  end;
end;

function TModel.InsertDbMetaData(DbData: TCreDbFileRec): Boolean;
var
  CreFile : TCreateAppdatabase;
  i : Integer;
begin
  CreFile := TCreateAppdatabase.Create(DbData.cdbfDirectory, Application_databaseVersion);
  try
    // Add the number of columns into SETTINGS_META
    CreFile.InsertMeta('Columns', IntToStr(DbData.cdbfColumnCount));

    // Insert column identifier
    if DbData.cdbfColumnCount <= 9 then begin
       for i := 0 to DbData.cdbfColumnCount - 1 do begin
         CreFile.InsertMeta('COL_00' + IntToStr(i + 1), '');
       end;
     end
     else if (DbData.cdbfColumnCount >= 10) and (DbData.cdbfColumnCount <= 99) then begin
       for i := 0 to 8 do begin
         CreFile.InsertMeta('COL_00' + IntToStr(i + 1), '');
       end;
       for i := 9 to DbData.cdbfColumnCount - 1 do begin
         CreFile.InsertMeta('COL_0' + IntToStr(i + 1), '');
       end;
     end;

     if DbData.cdbfShortDescription <> '' then begin
       CreFile.InsertMeta('SHORT DESCRIPTION', DbData.cdbfShortDescription);
     end;

     Result := True;
     for i := 0 to length(CreFile.DbCreateMessages) -1 do begin
       if ord(CreFile.DbCreateMessages[i].dbmType) = 1 then begin
         Result := False;
         break;
       end;
     end;
  finally
    CreFile.Free;
  end;
end;

function TModel.GetColumnCount(DbFileName: String): Integer;
var
  OpenDb : TOpenAppdatabase;
begin
  try
    OpenDb := TOpenAppdatabase.Create(DbFileName);
    Result := OpenDb.ColumnCount;

    OpenDb.Free;

  except on E:Exception do
    begin
      WriteToLog(laError, 'Failed to get column count. ' + DbFileName);
      WriteToLog(laError, e.ToString);
    end;
  end;
end;

procedure TModel.RemoveOwnComponents(DbFilerec: TOpenDbFilePrepareViewRec);
var
  BldComponents : TBuildComponents;
begin
  BldComponents := TBuildComponents.Create(-1);
  BldComponents.RemoveOwnComponents(DbFilerec.odbfParentSingle);
  BldComponents.RemoveOwnComponents(DbFilerec.odbfParentMultiple);
  BldComponents.Free;
end;

function TModel.BuildAllComponents(DbFilerec: TOpenDbFilePrepareViewRec): TOpenDbFilePrepareViewRec;
var
  BldComponents : TBuildComponents;
begin
  with result do
  try
    BldComponents := TBuildComponents.Create(DbFilerec.odbfColumnCount);
    try
      odbfSucces := BldComponents.BuildAllComponents(DbFilerec.odbfParentSingle, DbFilerec.odbfParentMultiple);
      odbfFileName := DbFilerec.odbfFileName;
      odbfFileDir := DbFilerec.odbfFileDir;
      odbfColumnCount := DbFilerec.odbfColumnCount;
    finally
      BldComponents.Free;
    end;
  except on E:Exception do
    begin
      WriteToLog(laError, 'Failed to build the components.');
      WriteToLog(laError, e.ToString);
    end;
  end;
end;

function TModel.GetItems(Items: TOpenDbFileGetDataRec): TOpenDbFileGetDataRec;
var
  Succes : Boolean;
begin
  Succes := FAppDbMaintain.GetAllItems(Items.gdGrid, Items.gdLevel);
  WriteAllMaintainMessagesToLog(FAppDbMaintain);

  if Succes then
    FDbIsOpened := True
  else
    FDbIsOpened := False;

  with result do
    try
      gdFileComplete := Items.gdFileComplete;
      gdSucces := Succes;
      gdLevel := Items.gdLevel;
      gdGrid := Items.gdGrid;
    except on E:Exception do
      begin
        WriteToLog(laError, 'Failed to get the items.');
        WriteToLog(laError, e.ToString);
      end;
    end;
end;

function TModel.ClearMainView(Objectdata: TClearPtrData): TClearPtrData;
var
  BldComponents : TBuildComponents;
begin
  BldComponents := TBuildComponents.Create(-1);
  try
    BldComponents.RemoveOwnComponents(Objectdata.cpdObject);

    with result do
      try
        cpdSuccess := True;
      except on E:Exception do
        begin
          cpdSuccess := False;
          WriteToLog(laError, 'Failed to remove the components.');
          WriteToLog(laError, e.ToString);
        end;
      end;

  finally
    BldComponents.Free;
  end;
end;

function TModel.CreateDbItemsMaintainer(Filename: string
  ): TOpenDbFilePrepareViewRec;
var
  Success : Boolean;
begin
  if Filename <> '' then begin
    if Assigned(FAppDbMaintain) then FreeAndNil(FAppDbMaintain);
    FAppDbMaintain := TAppDbMaintainItems.Create(Filename);
    Success := True;
  end
  else begin
    Success := False;
  end;
  with Result do begin
    odbfFileComplete := FileName;
    odbfSucces := Success;
  end;
end;

function TModel.ExtractNumberFromString(const Value: string): String;
var
  ch: char;
  Index, Count: integer;
begin
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

function TModel.SetStringGridHeaderFontStyle(aFontStyle: Integer): TStringGridRec;
begin
  with Result do begin
    sgHeaderFontStyle := aFontStyle;
  end;
end;

function TModel.AdjustStringGrid(SgRec: PStringGridRec; StringGridState: String
  ): TStringGridRec;
begin
  with Result do begin
    sgShowParentCol := SgRec^.sgShowParentCol;
    sgShowChildCol := SgRec^.sgShowChildCol;
    sgState := StringGridState;
  end;
end;

procedure TModel.ActiveStrgridCell(aSender: TObject; ViaAddButton : Boolean);
begin
  FStringGridFabric.ActivateStringGridCell(aSender, ViaAddButton);
end;

procedure TModel.StringGridOnPrepareCanvas(aSender: TObject; aCol,
  aRow: Integer; ShowRelationColor: Boolean);
begin
  FStringGridFabric.StringGridOnPrepareCanvas(aSender, aCol, aRow, ShowRelationColor);
end;

procedure TModel.StringGridOnDrawCell(aSender: TObject; sgSelect: Pointer);
begin
  FStringGridFabric.StringGridOnDrawCell(aSender, sgSelect);
end;

procedure TModel.StringGridOnSelectCell(aSender: TObject; sgSelect: Pointer);
begin
  FStringGridFabric.StringGridOnSelectCell(aSender, sgSelect);
end;

function TModel.ValidateCellEntry(sgObject: TObject; aText: string; aRow: Integer): TSaveBtn;
begin
  With result do begin
    DupFound := FStringGridFabric.ValidateDupText(sgObject);
    LengthToLongFound := FStringGridFabric.ValidateCellEntry(sgObject, aText, aRow);

    if (LengthToLongFound) or (DupFound) then
      btnEnable := False
    else
      btnEnable := true;
  end;
end;

function TModel.AddNewItem(anItem: PtrItemObject): TItemObjectData;
begin
  with result do begin
    Guid := FAppDbMaintain.AddItem(anItem);
    GridObject := anItem^.GridObject;
    Action := anItem^.Action;
    Name := anItem^.Name;
    Level := anItem^.Level;
  end;
end;

function TModel.UpdateItem(anItem: PtrItemObject): TItemObjectData;
begin
  FAppDbMaintain.UpdateItem(anItem);
end;

function TModel.DeleteItem(anItem: PtrItemObject): TItemObjectData;
begin
  PtrItemObject(anItem)^.MustSave := FAppDbMaintain.DeleteItem(anItem);

  //FStringGridFabric.AllStringGrids := PtrItemObject(anItem)^.AllSGrids;// wordt nietgebruikt. AllSgrids kan volledig weg uit alle records

  FAppDbMaintain.AddToDeleteList(PtrItemObject(anItem)^.Guid);
end;

function TModel.SaveChanges(scRec: PSaveChangesRec): Boolean;
var
  CanContinue : Boolean;
  i : Integer;
begin
  CanContinue := FAppDbMaintain.SaveChanges; // Does save all changes to the db file

  //FStringGridFabric.DebugCtrl; // tmp om te kijken of the checked childs is gevuld

  // save the relations
  if CanContinue then begin
    for i:=0 to length(FStringGridFabric.SaveList)-1 do begin
      SetLength(FAppDbMaintain.FSaveList, i+1);
      FAppDbMaintain.FSaveList[i].aGuid := FStringGridFabric.SaveList [i].aGuid;
      FAppDbMaintain.FSaveList[i].Parent_guid := FStringGridFabric.SaveList [i].Parent_guid;
      FAppDbMaintain.FSaveList[i].Action := FStringGridFabric.SaveList [i].Action;
    end;

    CanContinue := FAppDbMaintain.SaveRelations;
  end;

  if CanContinue then begin
    FStringGridFabric.ResetAll;
    FAppDbMaintain.ResetDeleteList;
  end;

  if CanContinue then
    scRec^.MustSave := False
  else
    scRec^.MustSave := True;

  WriteAllMaintainMessagesToLog(FAppDbMaintain);
  result := CanContinue;
end;

function TModel.SetReadyRelation(cbToggled: PCheckBoxCellPosition
  ): TCheckBoxCellPosition;
begin
  FStringGridFabric.AllStringGrids := PCheckBoxCellPosition(cbToggled)^.AllSGrids; // stringgrids nodig om de juiste cell te kunnen aanvinken

  if PCheckBoxCellPosition(cbToggled)^.Col = 1 then begin
    FStringGridFabric.SetParent(pointer(cbToggled));
  end
  else if PCheckBoxCellPosition(cbToggled)^.Col = 2 then begin
    FStringGridFabric.SetChild(pointer(cbToggled));
  end;

  FStringGridFabric.CleanUpCheckedParents; // uncheck any childs when there are no more parent checked
  FStringGridFabric.PrepareSaveList;

  //FStringGridFabric.DebugCtrl;

  With result do begin
    Cansave := FStringGridFabric.CanSave;
    Mustsave := FStringGridFabric.MustSave;
    CbParentMultipleCheck := FStringGridFabric.MultipleParentsChecked;
    Col := cbToggled^.Col;
    Row := cbToggled^.Row;
    aGridPtr := cbToggled^.aGridPtr;
    Action := cbToggled^.Action; // wordt niet gebruikt
   Parent_guid := cbToggled^.Parent_guid;
  end;
end;

function TModel.GetColumnNames: TGetColumnNameRec;
var
  allNames : AllColumnNames = nil;
begin
  if FDbIsOpened then begin
    allNames := AllColumnNames(FAppDbMaintain.GetAllColumnNames);
  end;

  with result do begin
    AllColNames := allNames;
  end;
end;

function TModel.SaveColumnNames(sgData: PGetColumnNameRec): TGetColumnNameRec;
begin
  Result := TGetColumnNameRec(FAppDbMaintain.SaveColumnNames(sgData));
end;

procedure TModel.PrepareCloseDb;
begin
  FStringGridFabric.PrepareCloseDb;
end;



end.

