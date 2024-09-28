
unit presenter.trax;
{$mode objfpc}{$H+}
{.$define dbg}
interface
uses classes,sysutils,obs_prosu, istrlist, model.intf, model.base;

(* this unit is by design, for specialized transactions... can have siblings :o)  *)

type
  { TTextEdit example, ultra simple, uses the inherited 'Title' prop }
  TTextEdit = class(TTransaction,ITrxExec) { <- notice the interface => important }
  private
    fSuccess: boolean;       { this trx gets triggered by 'prDataChanged' ~ 3 }
  public
    function Execute(aMgr: ITransactionManager): boolean;
    property Success: boolean read fSuccess write fSuccess;
  end;


  { Create the new transactions here. -----------------------------------------}

  { TCreDirTransaction }

  TCreDirTransaction = class(TTransaction, ITrxExec)
  private
    FNewDirnames: TStrings;
    FRootDir: string;
    FSucces: boolean;
    FUseAppDir: boolean;
  public
    constructor {%H-}Create(aModReason: word); overload;
    destructor Destroy; override;
    function Execute(aMgr: ITransactionManager): boolean;
    property RootDir: string read FRootDir write FRootDir;
    property NewDirnames: TStrings read fNewDirnames write fNewDirnames;
    property Succes: boolean read FSucces write FSucces;
    property UseAppDir: boolean read FUseAppDir write FUseAppDir; { AppDir = Application directory }
  end;

  { TSettingstransaction }

  TSettingstransaction = class(TTransaction, ITrxExec)
  private
    FActivateLogging: Boolean;
    FAppBuildDate: string;
    FAppendLogging: Boolean;
    FAppName: string;
    FAppVersion: string;
    FFormHeight: Integer;
    FFormLeft: Integer;
    FFormName: String;
    FFormTop: Integer;
    FFormWidth: Integer;
    FFormWindowstate: Integer;
    FFrmRestoredHeight: Integer;
    FFrmRestoredLeft: Integer;
    FFrmRestoredTop: Integer;
    FFrmRestoredWidth: Integer;
    FLanguage: String;
    FRead: Boolean;
    FReadFrmState: Boolean;
    FSettingsFile: String;
    fSuccess: boolean;
    FWrite: Boolean;
    FStoreFrmState: Boolean;

  public
    function Execute(aMgr: ITransactionManager): boolean;
    property Success: boolean read fSuccess write fSuccess;
    property SettingsLocationAndFileName : String read FSettingsFile write FSettingsFile;
    property ReadSettings : Boolean read FRead write FRead;     // If true then read the settingsfile.
    property WriteSettings : Boolean read FWrite write FWrite;  // If true then write the settingsfile.
    property ReadFormState : Boolean read FReadFrmState write FReadFrmState;
    property StoreFormState : Boolean read FStoreFrmState write FStoreFrmState;

    property AppName : string read FAppName write FAppName;
    property AppVersion : string read FAppVersion write FAppVersion;
    property AppBuildDate : string read FAppBuildDate write FAppBuildDate;

    property ActivateLogging : Boolean read FActivateLogging write FActivateLogging;  // Enable or disbable Logging.
    property AppendLogging : Boolean read FAppendLogging write FAppendLogging;        // Append new logging to the log file. Or when disabled, delete previous logging and start again.
    property Language : String read FLanguage write FLanguage;                        // The choosen Language.

    property FormName : String read FFormName write FFormName;                        // Determines which settings are saved.
    property FormWindowstate : Integer read FFormWindowstate write FFormWindowstate;
    property FormTop : Integer read FFormTop write FFormTop;
    property FormLeft : Integer read FFormLeft write FFormLeft;
    property FormHeight : Integer read FFormHeight write FFormHeight;
    property FormWidth : Integer read FFormWidth write FFormWidth;
    property FormRestoredTop : Integer read FFrmRestoredTop write FFrmRestoredTop;
    property FormRestoredLeft : Integer read FFrmRestoredLeft write FFrmRestoredLeft;
    property FormRestoredHeight : Integer read FFrmRestoredHeight write FFrmRestoredHeight;
    property FormRestoredWidth : Integer read FFrmRestoredWidth write FFrmRestoredWidth;
  end;

  { TSingleSettingTransaction }

  TSingleSettingTransaction = class(TTransaction, ITrxExec)
  private
    FSettingName: String;
    FSettingsFile: String;
    FSettingValue: String;
  public
    function Execute(aMgr: ITransactionManager): boolean;

    property SettingsLocationAndFileName : String read FSettingsFile write FSettingsFile;
    property SettingName: String read FSettingName write FSettingName;
    property SettingValue: String read FSettingValue write FSettingValue;
  end;

  { TOpenDbFilePrepareViewTransaction }

  TOpenDbFilePrepareViewTransaction = class(TTransaction, ITrxExec)
    private
      FFileName: String;
      FParentMultiColumns: Pointer;
      FParentSingleColumn: Pointer;
    public
      function Execute(aMgr: ITransactionManager): boolean;

      property FileName : String read FFileName write FFileName;
      property PParentSingleColumn: Pointer read FParentSingleColumn write FParentSingleColumn;
      property PParentMultiColumns: Pointer read FParentMultiColumns write FParentMultiColumns;
  end;

  { TCreateAppDbMaintainerTransaction }

  TCreateAppDbMaintainerTransaction = class(TTransaction, ITrxExec)
    private
      FFileName: String;
      FSucces: boolean;
    public
      function Execute(aMgr: ITransactionManager): boolean;

      property Succes: boolean read FSucces write FSucces;
      property FileName : String read FFileName write FFileName;
  end;

  { TSaveChangesTransaction }

  TSaveChangesTransaction = class(TTransaction, ITrxExec)
    private
    public
      function Execute(aMgr: ITransactionManager): boolean;
  end;

  { TNewItemTransaction }

  TNewItemTransaction = class(TTransaction, ITrxExec)
    private
      FAction: String;
      FAllSGrids: Pointer;
      FGuid: String;
      FLevel: Integer;
      FMustSave: Boolean;
      FName: String;
      FParentGuid: TStrings;
      FGridObject: Pointer;
      FCol: Integer;
      FRow: Integer;
    public
      function Execute(aMgr: ITransactionManager): boolean;

      property Guid        : String read FGuid write FGuid;
      property Row         : Integer read FRow write FRow;
      property Col         : Integer read FCol write FCol;
      property Level       : Integer read FLevel write FLevel;
      property Name        : String read FName write FName;
      property ParentGuid  : TStrings read FParentGuid write FParentGuid;
      property Action      : String read FAction write FAction;
      property GridObject  : Pointer read FGridObject write FGridObject;
      Property MustSave    : Boolean read FMustSave write FMustSave;
      property AllSGrids   : Pointer read FAllSGrids write FAllSGrids;
  end;

  { TUpdateItemTransaction }

  TUpdateItemTransaction = class(TTransaction, ITrxExec)
    private
      FAction: String;
      FAllSGrids: Pointer;
      FCol: Integer;
      FGridObject: Pointer;
      FGuid: String;
      FLevel: Integer;
      FMustSave: Boolean;
      FName: String;
      FParentGuid: TStrings;
      FRow: Integer;
    public
      function Execute(aMgr: ITransactionManager): boolean;

      property Guid        : String read FGuid write FGuid;
      property Row         : Integer read FRow write FRow;
      property Col         : Integer read FCol write FCol;
      property Level       : Integer read FLevel write FLevel;
      property Name        : String read FName write FName;
      property ParentGuid  : TStrings read FParentGuid write FParentGuid;
      property Action      : String read FAction write FAction;
      property GridObject  : Pointer read FGridObject write FGridObject;
      Property MustSave    : Boolean read FMustSave write FMustSave;
      property AllSGrids   : Pointer read FAllSGrids write FAllSGrids;
  end;

  { TDeleteItemTransaction }

  TDeleteItemTransaction = class(TTransaction, ITrxExec)
    private
      FAction: String;
      FAllSGrids: Pointer;
      FGuid: String;
      FLevel: Integer;
      FMustSave: Boolean;
      FName: String;
      FParentGuid: TStrings;
      FGridObject: Pointer;
      FCol: Integer;
      FRow: Integer;
    public
      function Execute(aMgr: ITransactionManager): boolean;

      property Guid        : String read FGuid write FGuid;
      property Row         : Integer read FRow write FRow;
      property Col         : Integer read FCol write FCol;
      property Level       : Integer read FLevel write FLevel;
      property Name        : String read FName write FName;
      property ParentGuid  : TStrings read FParentGuid write FParentGuid;
      property Action      : String read FAction write FAction;
      property GridObject  : Pointer read FGridObject write FGridObject;
      Property MustSave    : Boolean read FMustSave write FMustSave;
      property AllSGrids   : Pointer read FAllSGrids write FAllSGrids;
  end;

  { TCheckboxToggleTransaction }

  TCheckboxToggleTransaction = class(TTransaction, ITrxExec)
    private
      FAction: String;
      FaGridPtr: Pointer;
      FaGuid: String;
      FAllSGrids: Pointer;
      FCanSave: Boolean;
      FCbIsChecked: Boolean;
      FCol: Integer;
      FLevel: Integer;
      FName: String;
      //FParent_guid: array of String;
      FRow: Integer;
      FRowObject: Pointer;

      //function Get_Parent_guid(Index: Integer): String;
      //procedure Set_Parent_guid(Index: Integer; AValue: String);
    public
      FParent_guid: array of String; // bewust public gezet. via een property met aaray of string is voor nu te lastig.
      function Execute(aMgr: ITransactionManager): boolean;

      property Col : Integer Read FCol write FCol;
      property Row: Integer Read FRow write FRow;
      property Level : Integer Read FLevel write FLevel;
      property Name : String Read FName write FName;
      property aGridPtr : Pointer Read FaGridPtr write FaGridPtr;
      property aGuid  : String Read FaGuid write FaGuid;
      property AllSGrids : Pointer read FAllSGrids write FAllSGrids;
      property Action : String Read FAction write FAction;
      property CbIsChecked : Boolean read FCbIsChecked write FCbIsChecked;
      property CanSave : Boolean read FCanSave write FCanSave;
      property RowObject : Pointer read FRowObject write FRowObject;
  end;


  { TOpenDbFileGetDataTransaction }

  TOpenDbFileGetDataTransaction = class(TTransaction, ITrxExec)
    private
      FColumnCount: Integer;
      FFileName: String;
      FLevel: Integer;
      FStringgridPtr : Pointer;
    public
      function Execute(aMgr: ITransactionManager): boolean;

      property FileName : String read FFileName write FFileName;
      property StringGridPtr: Pointer read FStringgridPtr write FStringgridPtr;
      property ColumnCount: Integer read FColumnCount write FColumnCount;
      property Level: Integer read FLevel write FLevel;
  end;

  { TGetColumnNamesTransaction }

  TGetColumnNamesTransaction = class(TTransaction, ITrxExec)
    private
      FNameView: String;
    public
      function Execute(aMgr: ITransactionManager): boolean;

      property NameView : String read FNameView write FNameView;
  end;

  { TCreateDbFileTransaction }

  TCreateDbFileTransaction = class(TTransaction, ITrxExec)
    private
      FDirName, FFileName, FShortDescription : string;
      FColumnCount : Word;
      FCreateTable : Boolean;
    public
      function Execute(aMgr: ITransactionManager): boolean;

      property DirName : String read FDirName write FDirName;
      property FileName : String read FFileName write FFileName;
      property ColumnCount : Word read FColumnCount write FColumnCount;
      property ShortDescription : string read FShortDescription write FShortDescription;
      property CreateTable : Boolean read FCreateTable write FCreateTable;
  end;







implementation
// uses StrUtils; { for: 'IndexText' etc... }

{ utility functions, taking advantage of the publicly exported functions,
  in a unit that we can't /see/ from here. compiler imports for us :o) gotta love FPC }
function Pch2Str(aPch: pchar): string; external name 'BC_PCH2STR';
function Str2Pch(aStr: string): pchar; external name 'BC_STR2PCH'; 
{ the above 2 imports, are here to avoid referencing 'model.decl' in this unit.
  if you have to, then only in this 'implementation' part. }       


{ TTextEdit }
function TTextEdit.Execute(aMgr: ITransactionManager): boolean;
var
  lsl: IStringList;
begin { very lazy example :-/ i don't even touch the model => DON'T DO THIS }
  Result:= FileExists(fTitle);
  if Result then begin
    lsl:= CreateStrList;
    lsl.LoadFromFile(fTitle);
    fSuccess:= (lsl.Count > 0);
    aMgr.Owner.Provider.NotifySubscribers(prDataChanged,Self,lsl);
  end;
end; { end of example }

{ TCreDirTransaction }

constructor TCreDirTransaction.Create(aModReason: word);
begin
  FModReason:= aModReason;
  FNewDirnames := TStringList.Create;
  FNewDirnames.SkipLastLineBreak := true;
end;

destructor TCreDirTransaction.Destroy;
begin
  FNewDirnames.Free;
  inherited Destroy;
end;

function TCreDirTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec: TDirectoriesRec;
begin
  lRec:= aMgr.Owner.Model.CreateDirs(RootDir, NewDirnames.Text);
  Result:= lRec.dirSucces;
  aMgr.Owner.Provider.NotifySubscribers(prCreateDir, Self, @lRec); // Go back to the view. If succes is false there are no subdirs and the program must stop.
end;

{ TSettingstransaction }

function TSettingstransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec: TSettingsRec;
  UserName: string;
begin
  UserName:= StringReplace(GetEnvironmentVariable('USERNAME') , ' ', '_', [rfIgnoreCase, rfReplaceAll]) + '_';
  SettingsLocationAndFileName := GetEnvironmentVariable('appdata') + PathDelim + ApplicationName+PathDelim+ 'Settings' +PathDelim+ UserName + ApplicationName+'.cfg';  // 'Settings' is wrong should be adSettings
  lRec.setSettingsFile:= SettingsLocationAndFileName;

  if ReadSettings then begin
    lRec.setReadSettings:= ReadSettings;
    if ReadFormState then begin
      lRec.setFrmName:= FormName;
      lRec:= aMgr.Owner.Model.ReadFormState(@lRec);
      lRec.setReadSettings:= ReadSettings;
      lRec.setReadFormState:= ReadFormState;
      aMgr.Owner.Provider.NotifySubscribers(prFormState, Self, @lRec);
    end
    else begin  // read all other settings
      // pass the settings
      // first some defaults....
      lRec.setApplicationName:= AppName;
      lRec.setApplicationVersion:= AppVersion;
      lRec.setApplicationBuildDate:= AppBuildDate;

      lRec.setWriteSettings:= WriteSettings;
      lRec:= aMgr.Owner.Model.ReadSettings(@lRec);

      aMgr.Owner.Provider.NotifySubscribers(prAppSettings, Self, @lRec);
    end;
  end
  else if WriteSettings then begin
    lRec.setWriteSettings:= WriteSettings;
    if StoreFormstate then begin
      lRec.setFrmName := FormName;
      lRec.setFrmWindowState := FormWindowstate;
      lRec.setFrmTop:= FormTop;
      lRec.setFrmLeft := FormLeft;
      lRec.setFrmHeight := FormHeight;
      lRec.setFrmWidth := FormWidth;
      lRec.setFrmRestoredTop := FormRestoredTop;
      lRec.setFrmRestoredLeft := FormRestoredLeft;
      lRec.setFrmRestoredHeight := FormRestoredHeight;
      lRec.setFrmRestoredWidth := FormRestoredWidth;

      lRec:= aMgr.Owner.Model.StoreFormState(@lRec);

      aMgr.Owner.Provider.NotifySubscribers(prAppSettings, Self, @lRec);  // not used
    end
    else begin
      lRec.setActivateLogging:= ActivateLogging;
      lRec.setAppendLogging:= AppendLogging;
      lRec.setLanguage:= Language;

      lRec:= aMgr.Owner.Model.WriteSettings(@lRec);
      aMgr.Owner.Provider.NotifySubscribers(prAppSettings, Self, @lRec);
    end;
  end;
  Result:= True; // Not used.
end;

{ TSingleSettingTransaction }

function TSingleSettingTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec: TSingleSettingRec;
  UserName: string;
begin
  UserName:= StringReplace(GetEnvironmentVariable('USERNAME') , ' ', '_', [rfIgnoreCase, rfReplaceAll]) + '_';
  SettingsLocationAndFileName := GetEnvironmentVariable('appdata') + PathDelim + ApplicationName+PathDelim+ 'Settings' +PathDelim+ UserName + ApplicationName+'.cfg';  // 'Settings' is wrong should be adSettings

  lRec.ssSettingsFile:= SettingsLocationAndFileName;
  lRec.ssName:= SettingName;
  lRec.ssValue:= SettingValue;

  lRec := aMgr.Owner.Model.WriteSingleSetting(@lRec);
end;

{ TOpenDbFilePrepareViewTransaction }

function TOpenDbFilePrepareViewTransaction.Execute(aMgr: ITransactionManager
  ): boolean;
var
  i : Integer;
  lRec : TOpenDbFilePrepareViewRec;
begin
  i := aMgr.Owner.Model.GetColumnCount(FileName); // Get the number of columns.
  lRec.odbfColumnCount := i;
  lRec.odbfParentSingle := PParentSingleColumn;
  lRec.odbfParentMultiple := PParentMultiColumns;
  lRec.odbfFileName := ExtractFileName(Filename);  // Used in the notification and is shown in the taskbar of the mainview
  lRec.odbfFileDir := ExtractFileDir(Filename);
  aMgr.Owner.Model.RemoveOwnComponents(lRec);
  lRec := aMgr.Owner.Model.BuildAllComponents(lRec);  // Build the components ==> under construction

  aMgr.Owner.Provider.NotifySubscribers(prOpenDbFile, Self, @lRec);
end;

{ TCreateAppDbMaintainerTransaction }

function TCreateAppDbMaintainerTransaction.Execute(aMgr: ITransactionManager
  ): boolean;
begin
  aMgr.Owner.Model.CreateDbItemsMaintainer(FileName);
end;

{ TSaveChangesTransaction }

function TSaveChangesTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec : TSaveChangesRec;
begin
  lRec.scSuccess := aMgr.Owner.Model.SaveChanges(@lRec);
  aMgr.Owner.Provider.NotifySubscribers(prSaveChanges, self, @lRec);
end;

{ TNewItemTransaction }

function TNewItemTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec : TItemObjectData;
begin
  lRec.Name := Name;
  lRec.Level := Level;
  lRec.Action := Action;
  lRec.GridObject := GridObject; // ! wordt in view main weer omgezet naar het stringgrid waarvan de onvalidate werd getriggert.
  lRec.MustSave := MustSave;
  lRec := aMgr.Owner.Model.AddNewItem(@lRec);

  aMgr.Owner.Provider.NotifySubscribers(prAddNewItem, self, @lRec);
end;

{ TUpdateItemTransaction }

function TUpdateItemTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec : TItemObjectData;
begin
  lRec.Guid := Guid;
  lRec.Name := Name;
  lRec.Level := Level;
  lRec.Action := Action;
  lRec.GridObject := GridObject; // ! wordt in view main weer omgezet naar het stringgrid waarvan de onvalidate werd getriggert.
  lRec.MustSave := MustSave;
  lRec.sgCol := Col;
  lrec.sgRow := Row;
  aMgr.Owner.Model.UpdateItem(@lRec);

  aMgr.Owner.Provider.NotifySubscribers(prUpdateItem, self, @lRec);
end;

{ TDeleteItemTransaction }

function TDeleteItemTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec : TItemObjectData;
begin
  lRec.Guid := Guid;
  lRec.Name := Name;
  lRec.Level := Level;
  lRec.Action := Action;
  lRec.GridObject := GridObject; // ! wordt in view main weer omgezet naar het stringgrid waarvan de onvalidate werd getriggert.
  lRec.MustSave := MustSave;
  lRec.sgCol := Col;
  lRec.sgRow := Row;
  lRec.AllSGrids := AllSGrids;
  aMgr.Owner.Model.DeleteItem(@lRec);

  aMgr.Owner.Provider.NotifySubscribers(prDeleteItem, self, @lRec);
end;

{ TCheckboxToggleTransaction }

function TCheckboxToggleTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec : TCheckBoxCellPosition;
begin
  lRec.Col:= Col;
  lRec.Row:= Row;
  lRec.aGridPtr:= aGridPtr;
  lRec.aGuid:= aGuid;
  lRec.Name:= Name;
  lRec.Level := Level;
  lRec.CbIsChecked:= CbIsChecked;
  lRec.Parent_guid := FParent_guid;
  lRec.CbIsChecked := CbIsChecked;
  lRec.AllSGrids := AllSGrids;
  lRec.Action := Action;
  lRec.RowObject := RowObject;
  lRec := aMgr.Owner.Model.SetReadyRelation(@lRec);

  aMgr.Owner.Provider.NotifySubscribers(prCheckboxToggled, self, @lRec);
end;

{ TOpenDbFileGetDataTransaction }

function TOpenDbFileGetDataTransaction.Execute(aMgr: ITransactionManager
  ): boolean;
var
  lRec : TOpenDbFileGetDataRec;
begin
  lrec.gdLevel := Level;
  lrec.gdGrid := StringGridPtr;
  lRec:= aMgr.Owner.Model.GetItems(lRec);

  aMgr.Owner.Provider.NotifySubscribers(prGetAllItems, nil, @lRec);
end;

{ TGetColumnNamesTransaction }

function TGetColumnNamesTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lRec : TGetColumnNameRec;
begin
  lRec := aMgr.Owner.Model.GetColumnNames;
  aMgr.Owner.Provider.NotifySubscribers(prGetColumnNames, Self, @lRec);
end;

{ TCreateDbFileTransaction }

function TCreateDbFileTransaction.Execute(aMgr: ITransactionManager): boolean;
var
  lcdbft : TCreDbFileRec;
begin
  lcdbft := aMgr.Owner.Model.CreateDbFile(DirName);  // Create the file with the tables.
  lcdbft.cdbfFilename := FileName;
  lcdbft.cdbfDirectory := DirName;
  lcdbft.cdbfColumnCount := ColumnCount;
  lcdbft.cdbfShortDescription := ShortDescription;

  if lcdbft.cdbfSucces then  // If creating the file and tables was successfull then insert data
  if aMgr.Owner.Model.InsertDbMetaData(lcdbft) then begin
    lcdbft.cdbfSucces := True;
    lcdbft.cdbfMessage:= 'The file has been created successfully.';
  end
  else
    lcdbft.cdbfSucces := False;

  aMgr.Owner.Provider.NotifySubscribers(prCreDatabaseFile, Self, @lcdbft);
end;

{ TCheckboxToggleTransaction }




initialization
//  __Example:= nil;

finalization 
//  FreeAndNil(__Example);
  
end.

