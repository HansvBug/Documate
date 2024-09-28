
unit model.main;
{$mode ObjFPC}{$H+}
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
{-$define dbg}
interface
uses classes, sysutils, LazFileUtils, istrlist, model.decl, model.intf,
  Settings, Logging, StringGridFabric, DmUtils,
  AppDbCreate, AppDbMaintain, AppDbMaintainItems, AppDbOpen, BuildComponents;
//const

type
{$Region 'TModelMainH'}
  { TModelMain }
  TModelMain = class(TObject,IModelMain)
  private { remember to add your views to this array, maybe add a 'RegisterSection' method?!? }
    FSettings : TSettings;
    Logging : TLog_File;
    FStringGridFabric : TStringGridFab;
    FAppDbMaintain : TAppDbMaintainItems;
    FDbInfo: TDatabaseInfo;
    //FDbIsOpened: Boolean;  // For the config view a DB must be open to read the column names. If not open then not start reading columnnaes in the config view.

  const
  Sects: TStringArray = ('[view.main]', '[view.configure]', '[view.main.StatusbarTexts]',
    '[view.configure.hints]', '[view.newdbfile]', '[view.main.hints]',
    '[view.main.logging]', '[View.NewDbFile]'); { remember to add your views to this array } //<<--------!!!!

  var                                              
    fInSection: boolean; { used while searching static text sections }
    fSecId: integer; { tmp id while searching }
    fSectMaxIdx: integer; { used while searching static text sections, limits to 1 section }
  function get_DbFullFilename: String;
    function Obj: TObject;
    procedure set_DbFullFilename(AValue: String);
    procedure set_settings(AValue: TSettings);
    procedure WriteAllCreateMessagesToLog(CreFile : TCreateAppdatabase);  { #todo : Move record with messages to AppDb. Then less functions needed. }
    procedure WriteAllMaintainMessagesToLog(MaintainFile : TAppDbMaintainItems); { #todo : Move record with messages to AppDb. Then less functions needed. }
    procedure WriteAllAppdbMaintainMsgToLog(AppDbMaintain : TAppDbMaintain);

  protected
    fPresenter: IPresenterMain;
    fRoot: shortstring;
    fSection: string; // for use in getting static texts
    fTarget: integer; // for targetting the right result in view
    fTextCache: IStringList;
    { used while searching static text sections, new implementation ;) }
    procedure DoEach(const aValue: string; const anIdx: ptrint; anObj: TObject; aData: pointer);
    function LeftWord(const aStr: string): string; // used while searching static text sections    
  public
    constructor Create(aPresenter: IPresenterMain;const aRoot: shortstring = ''); overload;
    destructor Destroy; override;
    function GetStaticTexts(const aSection: string; out aTarget: integer): IStringList;
    procedure ReloadTextCache;

    function get_Settings: TSettings;
    function SetStatusbarText(const aText: string; panel : Word): TStatusbarPanelText;
    function CreateDirs(const aRootDir: string; const aDirList: string = ''): TDirectoriesRec;
    function ReadFormState(Settingsdata: PSettingsRec): TSettingsRec;
    function ReadSettings(Settingsdata: PSettingsRec): TSettingsRec;
    function StoreFormState(Settingsdata: PSettingsRec): TSettingsRec;
    function WriteSettings(Settingsdata: PSettingsRec): TSettingsRec;
    function WriteSingleSetting(SettingData: PSingleSettingRec): TSingleSettingRec;
    procedure StartLogging;
    procedure StopLogging;
    procedure WriteToLog(const aLogAction: String; LogText: String);
    procedure SwitchLanguage;
    procedure PrepareCloseDb;
    function SetStatusbarPanelsWidth(stbWidth, lpWidth, rpWidth: Integer): TstbPanelsSize;
    procedure DbResetAutoIncrementAll(dbFile: String);
    procedure DbCreateCopy(dbFile, DbFolder, dbBackUpFolder: string);
    procedure DbOptimize(dbFile: String);
    procedure DbCompress(dbFile: String);
    function GetColumnCount(DbFileName: String) : Integer;
    procedure RemoveOwnComponents(DbFilerec : TOpenDbFilePrepareViewRec);
    function BuildAllComponents(DbFilerec : TOpenDbFilePrepareViewRec) : TOpenDbFilePrepareViewRec;
    function CreateDbItemsMaintainer(Filename: string) : TOpenDbFilePrepareViewRec;
    function ExtractNumberFromString(const Value: string): String;
    procedure ActiveStrgridCell(aSender: TObject; ViaAddButton : Boolean);
    procedure StringGridOnPrepareCanvas(aSender: TObject; aCol, aRow: Integer; ShowRelationColor: Boolean);
    procedure StringGridOnSelectCell(aSender: TObject; sgSelect: Pointer);
    procedure StringGridOnDrawCell(aSender: TObject; sgSelect: Pointer);
    function SetStringGridHeaderFontStyle(aFontStyle: Integer): TStringGridRec;
    function SaveChanges(scRec : PSaveChangesRec): Boolean;
    function AddNewItem(anItem : PItemObjectData): TItemObjectData;
    function UpdateItem(anItem : PItemObjectData): TItemObjectData;
    function DeleteItem(anItem : PItemObjectData): TItemObjectData;
    function ValidateCellEntry(sgObject: TObject; aText: string; aRow: Integer): TSaveBtn;
    function SetReadyRelation(cbToggled : PCheckBoxCellPosition) : TCheckBoxCellPosition;
    function ClearMainView(Objectdata: TClearPtrData): TClearPtrData;
    function GetItems(Items: TOpenDbFileGetDataRec): TOpenDbFileGetDataRec;
    function GetColumnNames: TGetColumnNameRec;
    function AdjustStringGrid(SgRec : PStringGridRec; StringGridState: String): TStringGridRec;
    function CreateDbFile(const aDir : string): TCreDbFileRec;
    function InsertDbMetaData(DbData : TCreDbFileRec): Boolean;
    function IsFileInUse(const FileName: String): Boolean;
    function SaveColumnNames(sgData: PGetColumnNameRec) :TGetColumnNameRec;
    procedure SetStringGridWidth(anObj: TObject);


    Property Settings : TSettings read get_Settings write set_settings;
    Property DbFullFilename: String read get_DbFullFilename write set_DbFullFilename;
  end;

{$EndRegion 'TModelMainH'}

{ datastore factory, its intended use is in scenarios, where the 'viewmodel' / 'presenter'
  does NOT OWN the 'model' and thus doesn't free it on end of use...,
  in other words:
    "if you create your 'model' with this factory-function then DON'T FREE IT!" just := nil }
function gModelMain(aPresenter: IPresenterMain;const aRoot: shortstring): IModelMain;


implementation
uses obs_prosu,strutils; 

var Singleton: TModelMain = nil;

{ ModelMain factory }
function gModelMain(aPresenter: IPresenterMain; const aRoot: shortstring): IModelMain;
begin
  if not Assigned(Singleton) then Singleton:= TModelMain.Create(aPresenter,aRoot);
  Result:= Singleton;
end;

{$Region 'TModelMain'}
{ TModelMain }
function TModelMain.Obj: TObject;
begin
  Result:= Self;
end;

function TModelMain.get_DbFullFilename: String;
begin
  Result:= FDbInfo.FullFileName;
end;

procedure TModelMain.set_DbFullFilename(AValue: String);
begin
  FDbInfo.FullFileName:= AValue;
  FDbInfo.FileName:= ExtractFileName(AValue);
  FDbInfo.FileLocation:= ExtractFilePath(AValue);
end;

function TModelMain.get_Settings: TSettings;
begin
  Result:= FSettings;
end;

procedure TModelMain.set_settings(AValue: TSettings);
begin
  FSettings:= AValue;
end;

procedure TModelMain.WriteAllCreateMessagesToLog(CreFile: TCreateAppdatabase);
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

procedure TModelMain.WriteAllMaintainMessagesToLog(
  MaintainFile: TAppDbMaintainItems);
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

procedure TModelMain.WriteAllAppdbMaintainMsgToLog(AppDbMaintain: TAppDbMaintain
  );
var
  i : Integer;
begin
  for i := 0 to Length(AppDbMaintain.DbMaintainMessages) -1 do begin
    if Ord(AppDbMaintain.DbMaintainMessages[i].dbmType) = 0 then begin
      WriteToLog(laInformation, AppDbMaintain.DbMaintainMessages[i].dbmText);
    end
    else if Ord(AppDbMaintain.DbMaintainMessages[i].dbmType) = 1 then begin
      WriteToLog(laError, AppDbMaintain.DbMaintainMessages[i].dbmText);
    end;
  end;

  // Clear the messages
  SetLength(AppDbMaintain.DbMaintainMessages, 0);
end;

procedure TModelMain.DoEach(const aValue: string; const anIdx: ptrint;
                               anObj: TObject; aData: pointer);  
var
  ls: string;
  lid: integer;
begin
  if fSecId = -1 then exit;
  ls:= LeftWord(aValue);
  lid:= {%H-}IndexText(ls,Sects);
  if lid = fSecId then begin
    IStringList(aData).Append(aValue); //<- new feature <aData> typecast :o)
    fInSection:= true;
  end else begin
    if fInSection then begin
      if ((lid >= 0) and (lid <= fSectMaxIdx)) then fInSection:= false; /// 250824 /bc
      if fInSection then IStringList(aData).Append(aValue); //<- new feature <aData>
    end;
  end;
end;

function TModelMain.LeftWord(const aStr: string): string;
var
  li: integer = 1;
begin { pick the left-most word in a string }
  Result:= aStr;
  if Result = '' then exit;
  while ((li <= Length(aStr)) and (not (Result[li] in [#9,#13,#10,' ']))) do inc(li);
  SetLength(Result,li-1);
end; 

constructor TModelMain.Create(aPresenter: IPresenterMain; const aRoot: shortstring);
begin
  inherited Create;
  fPresenter:= aPresenter;
  fRoot:= aRoot;                                        { v- i18n }
  fTextCache:= CreStrListFromFile(format(mvpTexts,[fRoot,Lang])); ///<- i18n
  { we need the model, this is a minor flaw if it fails, because then the }
  if fTextCache.Count = 0 then { user will see a view filled with 'dummy' ;) }
    fPresenter.Provider.NotifySubscribers(prStatus,nil,Str2Pch('(!) ERROR: Could NOT retrieve static texts!'));
                                                               /// the above text can't be translated in the i18n'ed mvptexts, the count is 0! ///
  FStringGridFabric := TStringGridFab.Create;
end;

destructor TModelMain.Destroy;
begin
  fTextCache:= nil; // com-object
  fPresenter:= nil;

  if assigned(FStringGridFabric) then FreeAndNil(FStringGridFabric);
  if assigned(FAppDbMaintain) then FreeAndNil(FAppDbMaintain);
  StopLogging;
  if assigned(FSettings) then FreeAndNil(FSettings);
  inherited Destroy;
end;

function TModelMain.GetStaticTexts(const aSection: string; out aTarget: integer): IStringList;
begin { we use the [] here, because it fits in with standard ini-file format, nifty huh?!? }
  if aSection = '' then exit(nil);
  fSection:= '['+aSection+']';
  fSecId:= {%H-}IndexText(fSection,sects); // iterator-search
  if fTextCache.Count = 0 then begin
    fPresenter.Provider.NotifySubscribers(prStatus,nil,Str2Pch('(!) ERROR: Could NOT retrieve static texts!'));
    exit(nil); /// the above text can't be translated in the i18n'ed mvptexts, the count is 0! ///
  end;
  Result:= CreateStrList; { create our resulting stringlist }
  fTextCache.ForEach(@DoEach,Result);{ iterate over the source-list items, sending 'Result' along }
  aTarget:= fSecId; { for the presenter to differentiate between views }
end;

procedure TModelMain.ReloadTextCache;
begin
  fTextCache.Clear;
  fTextCache.LoadFromFile(format(mvpTexts,[fRoot,Lang]));
end;

function TModelMain.SetStatusbarText(const aText: string; panel: Word
  ): TStatusbarPanelText;
begin
  with Result do begin
    stbPanelText:= aText;
    stbActivePanel:= panel;
  end;
end;

function TModelMain.CreateDirs(const aRootDir: string; const aDirList: string
  ): TDirectoriesRec;
var
  s: string;
  lDirlist: TStrings;
begin
  with Result do try // <-- !!!
    dirSucces:= True;
    if aRootDir = '' then begin  // When there is no Root (program name) the folders will be made in the program directory.
      dirRoot:= ExtractFilePath(ParamStr(0)); { iirc "ExtractFilePath()" includes trailing delimiter }
      if DirectoryIsWritable(dirRoot) then begin
        if aDirList <> '' then begin
          dirRoot:= IncludeTrailingPathDelimiter(dirRoot); { checks for \/ }
          lDirlist:= TStringList.Create;
          try
            lDirlist.Text:= aDirList; { quick'n'dirty way of assigning a whole stringlist to another }
            for s in lDirlist do begin
              try
                MkDir(dirRoot+s);
              except
                dirSuccesMsg:= 'Nakijken 1';
                dirSucces:= False;
              end;
            end;
          finally lDirlist.Free; end;
          dirSuccesMsg:= amSucces;
          dirSucces:= true;
        end; // items in dirlist
      end; // writable
    end
    else begin
      dirRoot:= GetEnvironmentVariable('appdata');
      if DirectoryIsWritable(dirRoot) then begin
        dirRoot:= IncludeTrailingPathDelimiter(dirRoot); { checks for \/ }
        if not DirectoryExists(dirRoot+aRootDir) then begin
          try
            MkDir(dirRoot+aRootDir);
            dirRoot := IncludeTrailingPathDelimiter(dirRoot+aRootDir);
            if aDirList <> '' then begin
              lDirlist:= TStringList.Create;
              try
                lDirlist.Text:= aDirList; { quick'n'dirty way of assigning a whole stringlist to another }
                for s in lDirlist do begin
                  if not DirectoryExists(dirRoot+s) then begin
                    try
                      MkDir(dirRoot+s);
                    except
                      dirSuccesMsg:= 'Nakijken 2';
                      dirSucces:= False;
                    end;
                  end;
                end;
              finally
                lDirlist.Free;
              end;
              dirSuccesMsg := amSucces;
              dirSucces:= True;
            end;
          except on E:Exception do
            begin
              dirSuccesMsg:= 'Failed to create the Root directory or failed to create the subdirectories!' +  '  '  + e.ToString;
              dirSucces:= False;
            end;
          end;
        end
        else begin // dir allready exists
          if aDirList <> '' then begin
            lDirlist:= TStringList.Create;
            dirRoot:= IncludeTrailingPathDelimiter(dirRoot+aRootDir);
            try
              lDirlist.Text:= aDirList; { quick'n'dirty way of assigning a whole stringlist to another }
              for s in lDirlist do begin
                if not DirectoryExists(dirRoot+s) then begin
                  try
                    MkDir(dirRoot+s);
                    dirSuccesMsg := amSucces;
                    dirSucces:= True;
                  except
                    dirSucces:= False;
                    dirSuccesMsg:= 'Nakijken. Dit is waarschijnlijk overbodig, de DIR bestaat al.';
                  end;
                end;
              end;
            finally
              lDirlist.Free;
            end;
          end;
        end;
      end
      else begin
        dirSuccesMsg:= 'Root is Read-Only!';
        dirSucces:= False;
      end;
    end; // rootdir provided
  except on E:Exception do
    begin
      dirSuccesMsg := amFailed;
      dirSucces:= false;
    end;
  end;
end;

function TModelMain.ReadFormState(Settingsdata: PSettingsRec): TSettingsRec;
begin
  if assigned(FSettings) then FreeAndNil(FSettings);

  FSettings := TSettings.Create;
  try
    with PSettingsRec(Settingsdata)^ do begin
      FSettings.FormName:= setFrmName;
      FSettings.SettingsFile:= setSettingsFile;
    end;

    Fsettings.ReadFormState;
  finally
  end;

  with Result do begin
    try
        setSettingsFile:= PSettingsRec(Settingsdata)^.setSettingsFile;
        setReadSettings:= PSettingsRec(Settingsdata)^.setReadSettings;
        setWriteSettings:= PSettingsRec(Settingsdata)^.setWriteSettings;
        setFrmName:= FSettings.FormName;
        setFrmWindowState:= FSettings.FormWindowstate;
        setFrmTop:= FSettings.FormTop;
        setFrmLeft:= FSettings.FormLeft;
        setFrmHeight:= FSettings.FormHeight;
        setFrmWidth:= FSettings.FormWidth;
        setFrmRestoredTop:= FSettings.FormRestoredTop;
        setFrmRestoredLeft:= FSettings.FormRestoredLeft;
        setFrmRestoredHeight:= FSettings.FormRestoredHeight;
        setFrmRestoredWidth:= FSettings.FormRestoredWidth;
        setSucces:= FSettings.Succes;
    except on E:Exception do
      setSucces := False;
    end;
  end;
end;

function TModelMain.ReadSettings(Settingsdata: PSettingsRec): TSettingsRec;
begin
  if assigned(FSettings) then FreeAndNil(FSettings);

  FSettings := TSettings.Create;
  try
    with PSettingsRec(Settingsdata)^ do begin
      FSettings.FormName:= setFrmName;
      FSettings.SettingsFile:= setSettingsFile;
      FSettings.AppName:= setApplicationName;
      FSettings.AppVersion:= setApplicationVersion;
      FSettings.AppBuildDate:= setApplicationBuildDate;
    end;

    Fsettings.ReadFile;
  finally
  end;

  with Result do try
    setSettingsFile:= PSettingsRec(Settingsdata)^.setSettingsFile;
    setReadSettings:= PSettingsRec(Settingsdata)^.setReadSettings;
    setWriteSettings:= PSettingsRec(Settingsdata)^.setWriteSettings;
    setApplicationName:= FSettings.AppName;
    setActivateLogging := FSettings.ActivateLogging;
    setAppendLogging:= FSettings.AppendLogFile;
    setLanguage:= FSettings.Language;
    //...

    setSucces:= FSettings.Succes;
    setSucces := True;
  except on E:Exception do
    setSucces := False;
  end;
end;

function TModelMain.StoreFormState(Settingsdata: PSettingsRec): TSettingsRec;
begin
  if assigned(FSettings) then begin
     with PSettingsRec(Settingsdata)^ do begin
       FSettings.SettingsFile:= setSettingsFile;
       FSettings.FormName:= setFrmName;
       FSettings.FormWindowstate:= setFrmWindowState;
       FSettings.FormTop:= setFrmTop;
       FSettings.FormLeft:= setFrmLeft;
       FSettings.FormHeight:= setFrmHeight;
       FSettings.FormWidth:= setFrmWidth;
       FSettings.FormRestoredTop:= setFrmRestoredTop;
       FSettings.FormRestoredLeft:= setFrmRestoredLeft;
       FSettings.FormRestoredHeight:= setFrmRestoredHeight;
       FSettings.FormRestoredWidth:= setFrmRestoredWidth;
     end;

     FSettings.StoreFormState;
     With result do begin
       setSucces:= FSettings.Succes;
     end;
  end;
end;

function TModelMain.WriteSettings(Settingsdata: PSettingsRec): TSettingsRec;
begin
  if assigned(FSettings) then begin
    with PSettingsRec(Settingsdata)^ do begin
      FSettings.ActivateLogging:= setActivateLogging;
      FSettings.AppendLogFile:= setAppendLogging;
      if setLanguage <> '' then
        FSettings.Language:= setLanguage;
      //...

      FSettings.SettingsFile:= setSettingsFile;
    end;

    FSettings.WriteSettings;
  end;

  with Result do begin
    setReadSettings:= PSettingsRec(Settingsdata)^.setReadSettings;
    setWriteSettings:= PSettingsRec(Settingsdata)^.setWriteSettings;
    setActivateLogging:= PSettingsRec(Settingsdata)^.setActivateLogging;
    setAppendLogging:= PSettingsRec(Settingsdata)^.setAppendLogging;
    if PSettingsRec(Settingsdata)^.setLanguage <> '' then
      setLanguage:= PSettingsRec(Settingsdata)^.setLanguage;

    setSucces:= FSettings.Succes;
  end;
end;

function TModelMain.WriteSingleSetting(SettingData: PSingleSettingRec
  ): TSingleSettingRec;
begin
  if assigned(FSettings) then begin
    with PSingleSettingRec(Settingdata)^ do begin
      FSettings.SettingsFile:= ssSettingsFile;
      FSettings.WriteSetting(ssName, ssValue);
    end;
  end;
end;

procedure TModelMain.StartLogging;
var
  UserName, LogFile: String;
begin
  if assigned(FSettings) then begin
    if FSettings.ActivateLogging then begin
      if Logging = Nil then begin
        UserName:= StringReplace(GetEnvironmentVariable('USERNAME') , ' ', '_', [rfIgnoreCase, rfReplaceAll]) + '_';
        LogFile:= GetEnvironmentVariable('appdata') +
                  PathDelim + ApplicationName + PathDelim +
                  'Logging' + PathDelim + UserName + ApplicationName+'.log';  // 'Logging' is wrong should be adLogging

        Logging := TLog_File.Create(LogFile);
        Logging.ActivateLogging := FSettings.ActivateLogging;  // Readsettings must be executed befor startlogging.
        Logging.AppendLogFile := FSettings.AppendLogFile;
        Logging.ApplicationName := ApplicationName;
        Logging.AppVersion := Application_version;
        Logging.StartLogging;
      end;
    end;
  end;
end;

procedure TModelMain.StopLogging;
begin
  if assigned(Logging) then begin
    Logging.StopLogging;
    FreeAndNil(Logging);
  end;
end;

procedure TModelMain.WriteToLog(const aLogAction: String; LogText: String);
begin
  if Logging <> Nil then begin
    case aLogAction of
      'Information': Logging.WriteToLogInfo(LogText);
      'Warning': Logging.WriteToLogWarning(LogText);
      'Error': Logging.WriteToLogError(LogText);
      'Debug': Logging.WriteToLogDebug(LogText);
    else ;
    end;
  end;
end;

procedure TModelMain.SwitchLanguage;
begin
  fTextCache.Clear;
  fTextCache:= CreStrListFromFile(format(mvpTexts,['',Lang]));
end;

procedure TModelMain.PrepareCloseDb;
begin
   FStringGridFabric.PrepareCloseDb;
end;

function TModelMain.SetStatusbarPanelsWidth(stbWidth, lpWidth, rpWidth: Integer
  ): TstbPanelsSize;
var
  dmUtils: TDmUtils;
  pWidth: Integer;
begin
  dmUtils:= TDmUtils.Create;
  try
    pWidth:= dmUtils.SetStatusbarPanelsWidth(stbWidth, lpWidth, rpWidth);
    with Result do begin
      mpWidth := pWidth;
    end;
  finally
    dmUtils.Free;
  end;
end;

procedure TModelMain.DbResetAutoIncrementAll(dbFile: String);
var
  appDbReset: TAppDbMaintain;
begin
  appDbReset:= TAppDbMaintain.create(dbFile);
  appDbReset.ResetAutoIncrementAll;

  WriteAllAppdbMaintainMsgToLog(appDbReset);
  appDbReset.Free;
end;

procedure TModelMain.DbCreateCopy(dbFile, DbFolder, dbBackUpFolder: string);
var
  appDbCopy: TAppDbMaintain;
begin
  appDbCopy:= TAppDbMaintain.create(dbFile);
  appDbCopy.ResetAutoIncrementAll;
  appDbCopy.CopyDbFile(DbFolder, dbBackUpFolder);

  WriteAllAppdbMaintainMsgToLog(appDbCopy);
  appDbCopy.Free;
end;

procedure TModelMain.DbOptimize(dbFile: String);
var
  appDbReset: TAppDbMaintain;
begin
  appDbReset:= TAppDbMaintain.create(dbFile);
  appDbReset.Optimze;

  WriteAllAppdbMaintainMsgToLog(appDbReset);
  appDbReset.Free;
end;

procedure TModelMain.DbCompress(dbFile: String);
var
  appDbReset: TAppDbMaintain;
begin
  appDbReset:= TAppDbMaintain.create(dbFile);
  appDbReset.CompressAppDatabase;

  WriteAllAppdbMaintainMsgToLog(appDbReset);
  appDbReset.Free;
end;

function TModelMain.GetColumnCount(DbFileName: String): Integer;
var
  OpenDb : TOpenAppdatabase;
begin
  try
    OpenDb:= TOpenAppdatabase.Create(DbFileName);
    Result:= OpenDb.ColumnCount;

    OpenDb.Free;

  except on E:Exception do
    begin
      WriteToLog(laError, 'Failed to get column count. ' + DbFileName);
      WriteToLog(laError, e.ToString);
    end;
  end;
end;

procedure TModelMain.RemoveOwnComponents(DbFilerec: TOpenDbFilePrepareViewRec);
var
  BldComponents : TBuildComponents;
begin
  BldComponents := TBuildComponents.Create(-1);
  BldComponents.RemoveOwnComponents(DbFilerec.odbfParentSingle);
  BldComponents.RemoveOwnComponents(DbFilerec.odbfParentMultiple);
  BldComponents.Free;
end;

function TModelMain.BuildAllComponents(DbFilerec: TOpenDbFilePrepareViewRec
  ): TOpenDbFilePrepareViewRec;
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

function TModelMain.CreateDbItemsMaintainer(Filename: string
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

function TModelMain.ExtractNumberFromString(const Value: string): String;
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

procedure TModelMain.ActiveStrgridCell(aSender: TObject; ViaAddButton: Boolean);
begin
  FStringGridFabric.ActivateStringGridCell(aSender, ViaAddButton);
end;

procedure TModelMain.StringGridOnPrepareCanvas(aSender: TObject; aCol,
  aRow: Integer; ShowRelationColor: Boolean);
begin
  FStringGridFabric.StringGridOnPrepareCanvas(aSender, aCol, aRow, ShowRelationColor);
end;

procedure TModelMain.StringGridOnSelectCell(aSender: TObject; sgSelect: Pointer
  );
begin
  FStringGridFabric.StringGridOnSelectCell(aSender, sgSelect);
end;

procedure TModelMain.StringGridOnDrawCell(aSender: TObject; sgSelect: Pointer);
begin
  FStringGridFabric.StringGridOnDrawCell(aSender, sgSelect);
end;

function TModelMain.SetStringGridHeaderFontStyle(aFontStyle: Integer
  ): TStringGridRec;
begin
  with Result do begin
    sgHeaderFontStyle := aFontStyle;
  end;
end;

function TModelMain.SaveChanges(scRec: PSaveChangesRec): Boolean;
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

function TModelMain.AddNewItem(anItem: PItemObjectData): TItemObjectData;
begin
  with result do begin
    Guid := FAppDbMaintain.AddItem(anItem);
    GridObject := anItem^.GridObject;
    Action := anItem^.Action;
    Name := anItem^.Name;
    Level := anItem^.Level;
  end;
end;

function TModelMain.UpdateItem(anItem: PItemObjectData): TItemObjectData;
begin
  FAppDbMaintain.UpdateItem(anItem);
end;

function TModelMain.DeleteItem(anItem: PItemObjectData): TItemObjectData;
begin
  PItemObjectData(anItem)^.MustSave := FAppDbMaintain.DeleteItem(anItem);
  //FStringGridFabric.AllStringGrids := PtrItemObject(anItem)^.AllSGrids;// wordt nietgebruikt. AllSgrids kan volledig weg uit alle records
  FAppDbMaintain.AddToDeleteList(PtrItemObject(anItem)^.Guid);
end;

function TModelMain.ValidateCellEntry(sgObject: TObject; aText: string;
  aRow: Integer): TSaveBtn;
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

function TModelMain.SetReadyRelation(cbToggled: PCheckBoxCellPosition
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

function TModelMain.ClearMainView(Objectdata: TClearPtrData): TClearPtrData;
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
          WriteToLog(laError, fPresenter.GetstaticText('view.main.logging', 'FailedRemoveComponents'));
          WriteToLog(laError, e.ToString);
        end;
      end;

  finally
    BldComponents.Free;
  end;
end;

function TModelMain.GetItems(Items: TOpenDbFileGetDataRec
  ): TOpenDbFileGetDataRec;
var
  Succes : Boolean;
begin
  Succes := FAppDbMaintain.GetAllItems(Items.gdGrid, Items.gdLevel);
  WriteAllMaintainMessagesToLog(FAppDbMaintain);

  if Succes then
    FDbInfo.DbIsOpened := True
  else
    FDbInfo.DbIsOpened := False;

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

function TModelMain.GetColumnNames: TGetColumnNameRec;
var
  lAllNames : AllColumnNames = nil;  // = Array of records
  i: Integer;
begin
  if FDbInfo.DbIsOpened then begin
    lAllNames := AllColumnNames(FAppDbMaintain.GetAllColumnNames);

    // add the column names to the dbInfo record. Used when a new item is created.
    for i:=0 to High(lAllNames) do begin
      setlength(FDbInfo.ColumnNames, i+1);
      FDbInfo.ColumnNames[i]:= lAllNames[i].Value; // hold the columnnames for further use (labeld in the create new item view).
    end;

  end;
  with result do begin
    AllColNames := lAllNames;
  end;
end;

function TModelMain.AdjustStringGrid(SgRec: PStringGridRec;
  StringGridState: String): TStringGridRec;
begin
  with Result do begin
    sgShowParentCol := SgRec^.sgShowParentCol;
    sgShowChildCol := SgRec^.sgShowChildCol;
    sgState := StringGridState;
  end;
end;

function TModelMain.CreateDbFile(const aDir: string): TCreDbFileRec;
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

function TModelMain.InsertDbMetaData(DbData: TCreDbFileRec): Boolean;
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

function TModelMain.IsFileInUse(const FileName: String): Boolean;
var
  dmUtils: TDmUtils;
begin
  dmUtils:= TDmUtils.Create;
  try
    Result:= dmUtils.IsFileInUse(FileName);
  finally
    dmUtils.Free;
  end;
end;

function TModelMain.SaveColumnNames(sgData: PGetColumnNameRec
  ): TGetColumnNameRec;
begin
  Result := TGetColumnNameRec(FAppDbMaintain.SaveColumnNames(sgData));
end;

procedure TModelMain.SetStringGridWidth(anObj: TObject);
begin
  FStringGridFabric.SetStringGridWidth(anObj);
end;

{$EndRegion 'TModelMain'}

finalization
  if Assigned(Singleton) then FreeAndNil(Singleton); { checks for nil explicitly, freeandnil doesn't! }
end.
