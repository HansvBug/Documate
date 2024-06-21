unit vwmain.trxman;

{$mode ObjFPC}{$H+}

interface

uses
  classes, sysUtils, vwmain.intf, vwmain.decl;

type
  { TTransactionManager }
  TTransactionManager = class(TObject,ITransactionManager)
  protected
    FModel: IModel;
    FOwner: IPresenter;
    FTrx: TTransaction;  // alias

    function Obj: TObject;
    procedure CommitCreatingDirs;
    procedure CommitReadSettings;
    procedure CommitReadFormState;
    procedure CommitUpdateSettings;
    procedure CommitStoreFormstate;
    procedure CommitCreateDbFile;
    procedure CommitOpenDbFilePrepareView;
    procedure CommitCreateAppDbReference;
    procedure CommitOpenDbFileGetData;
    procedure CommitAddNewItem;
    procedure CommitUpdateItem;
    procedure CommitDeleteItem;
    procedure CommitSaveChanges;
    procedure CommitCheckboxToggled;
    procedure CommitGetColumnNames;
  public
    constructor Create(anOwner: IPresenter;aModel: IModel);
    destructor Destroy; override;
    procedure CommitTransaction;
    function InTransaction: boolean;
    procedure RollbackTransaction;
    function StartTransaction(aModState: word): TTransaction;
  end;

  { TDirTransaction }

  { Class used for creating directories (Transaction object) }
  TDirTransaction = class(TTransaction)
    private
      FNewDirnames: TStrings;
      FProjectName: string;
      FRootDir: string;
      FSucces: boolean;
      FSuccesMsg: string;
      FUseAppDir: boolean;
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;
      property NewDirnames: TStrings read fNewDirnames write fNewDirnames;
      property ProjectName: string read FProjectName write FProjectName;
      property RootDir: string read FRootDir write FRootDir;
      property Succes: boolean read FSucces write FSucces;
      property SuccesMsg: string read FSuccesMsg write FSuccesMsg;
      property UseAppDir: boolean read FUseAppDir write FUseAppDir;
  end;

  { TSettingstransaction }

  TSettingstransaction = class(TTransaction)
    private
      FSettingsFile : String; // Holds the settingslocation and settingsfile name.
      FRead : Boolean;
      FWrite: Boolean;
      FAppName, FAppVersion, FAppBuildDate : string;
      FActivateLogging, FAppendLogging : Boolean;
      FLanguage : String;
      FFormName : String;
      FFormWindowstate : Integer;
      FFormTop : Integer;
      FFormLeft : Integer;
      FFormHeight : Integer;
      FFormWidth : Integer;
      FFrmRestoredTop : Integer;
      FFrmRestoredLeft : Integer;
      FFrmRestoredHeight : Integer;
      FFrmRestoredWidth : Integer;
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;
      property SettingsLocationAndFileName : String read FSettingsFile write FSettingsFile;
      property setApplicationName : string read FAppName write FAppName;
      property setApplicationVersion : string read FAppVersion write FAppVersion;
      property setApplicationBuildDate : string read FAppBuildDate write FAppBuildDate;

      property ReadSettings : Boolean read FRead write FRead;
      property WriteSettings : Boolean read FWrite write FWrite;

      property ApplicationName : string read FAppName write FAppName;
      property ApplicationVersion : string read FAppVersion write FAppVersion;
      property ApplicationBuildDate : string read FAppBuildDate write FAppBuildDate;

      property ActivateLogging : Boolean read FActivateLogging write FActivateLogging;  // Enable or disbable Logging.
      property AppendLogging : Boolean read FAppendLogging write FAppendLogging;        // Append new logging to the log file. ((r when disabled, delete previous logging and start again.
      property Language : String read FLanguage write FLanguage;                        // The chosen Language.

      property FormName : String read FFormName write FFormName;  // Determines which settings are saved.
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

  { TCreateDbFileTransaction }

  TCreateDbFileTransaction = class(TTransaction)
    private
      FDirName, FFileName, FShortDescription : string;
      FColumnCount : Word;
      FCreateTable : Boolean;
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;
      property DirName : String read FDirName write FDirName;
      property FileName : String read FFileName write FFileName;
      property ColumnCount : Word read FColumnCount write FColumnCount;
      property ShortDescription : string read FShortDescription write FShortDescription;
      property CreateTable : Boolean read FCreateTable write FCreateTable;
  end;

  { TOpenDbFilePrepareViewTransaction }

  TOpenDbFilePrepareViewTransaction = class(TTransaction)
    private
      FFileName: String;
      FParentMultiColumns: Pointer;
      FParentSingleColumn: Pointer;
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;

      property FileName : String read FFileName write FFileName;
      property PParentSingleColumn: Pointer read FParentSingleColumn write FParentSingleColumn;
      property PParentMultiColumns: Pointer read FParentMultiColumns write FParentMultiColumns;
  end;


  { TCreateAppDbMaintainerTransaction }

  TCreateAppDbMaintainerTransaction = class(TTransaction)
    private
      FFileName: String;
      FSucces: boolean;
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;

      property Succes: boolean read FSucces write FSucces;
      property FileName : String read FFileName write FFileName;
  end;

  { TOpenDbFileGetDataTransaction }

  TOpenDbFileGetDataTransaction = class(TTransaction)
    private
      FColumnCount: Integer;
      FFileName: String;
      FLevel: Integer;
      FStringgridPtr : Pointer;
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;

      property FileName : String read FFileName write FFileName;
      property StringGridPtr: Pointer read FStringgridPtr write FStringgridPtr;
      property ColumnCount: Integer read FColumnCount write FColumnCount;
      property Level: Integer read FLevel write FLevel;
  end;

  { TSaveChangesTransaction }

  TSaveChangesTransaction = class(TTransaction)
    private
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;
  end;

  { TItemTransaction }

  TItemTransaction = class(TTransaction)
    private
      FAction: String;
      FAllSGrids: Pointer;
      //FAllSGrids: Pointer;
      FGuid: String;
      FLevel: Integer;
      FMustSave: Boolean;
      FName: String;
      FParentGuid: TStrings;
      FGridObject: Pointer;
      FCol: Integer;
      FRow: Integer;
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;

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

  TCheckboxToggleTransaction = class(TTransaction)
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
      constructor Create(aModState: word); override;
      destructor Destroy; override;

      //procedure SetLengthParentGuidPlusOne;

      property Col : Integer Read FCol write FCol;
      property Row: Integer Read FRow write FRow;
      property Level : Integer Read FLevel write FLevel;
      property Name : String Read FName write FName;
      property aGridPtr : Pointer Read FaGridPtr write FaGridPtr;
      property aGuid  : String Read FaGuid write FaGuid;
      property AllSGrids : Pointer read FAllSGrids write FAllSGrids;

      //property Parent_guid[Index: Integer] : String Read Get_Parent_guid write Set_Parent_guid;

      property Action : String Read FAction write FAction;
      property CbIsChecked : Boolean read FCbIsChecked write FCbIsChecked;
      property CanSave : Boolean read FCanSave write FCanSave;
      property RowObject : Pointer read FRowObject write FRowObject;
  end;

  { TgtColumnNamesTransaction }

  { TGetColumnNamesTransaction }

  TGetColumnNamesTransaction = class(TTransaction)
    private
      FNameView: String;
    public
      constructor Create(aModState: word); override;
      destructor Destroy; override;

      property NameView : String read FNameView write FNameView;
  end;

implementation

{ TTransactionManager }

function TTransactionManager.Obj: TObject;
begin
  Result:= Self;
end;

procedure TTransactionManager.CommitCreatingDirs;
var
  lDirRec: TDirectoriesRec;
begin { these methods are where the differentiation happens, between transactions }
  with TDirTransaction(FTrx) do begin
    lDirRec:= FModel.CreateDirs(RootDir, NewDirnames.Text);
  end;
  FOwner.Provider.NotifySubscribers(prCreateDirs,Self, @lDirRec);
{  if fOwner.LogActions then
    fOwner.Provider.NotifySubscribers(prLogLine,Self,Str2Pch('(i) CreateDirs had '+ldr.dirSuccesMsg));}
end;

procedure TTransactionManager.CommitReadSettings;
var
  lSetRec : TSettingsRec;
begin
  with TSettingstransaction(FTrx) do
  begin
    lSetRec := FModel.ReadSettings(SettingsLocationAndFileName, FormName);
  end;

  FOwner.Provider.NotifySubscribers(prReadSettings, Self, @lSetRec);
end;

procedure TTransactionManager.CommitReadFormState;
var
  lSetRec : TSettingsRec;
begin
  with TSettingstransaction(FTrx) do
  begin
    lSetRec := FModel.ReadFormState(SettingsLocationAndFileName, FormName );
  end;

  FOwner.Provider.NotifySubscribers(prReadFormState, Self, @lSetRec);
end;

procedure TTransactionManager.CommitStoreFormstate;
var
  lSetRec : TSettingsRec;
begin
  with TSettingstransaction(FTrx) do
  begin
    lSetRec := FModel.ReadSettings(SettingsLocationAndFileName, FormName);
    FModel.Settings.FormName := FormName;
    Fmodel.Settings.FormWindowstate := FormWindowstate;
    FModel.Settings.FormTop := FormTop;
    Fmodel.Settings.FormLeft := FormLeft;
    FModel.Settings.FormHeight := FormHeight;
    Fmodel.Settings.FormWidth := FormWidth;
    FModel.Settings.FormRestoredTop := FormRestoredTop;
    Fmodel.Settings.FormRestoredLeft := FormRestoredLeft;
    FModel.Settings.FormRestoredHeight := FormRestoredHeight;
    Fmodel.Settings.FormRestoredWidth := FormRestoredWidth;
    //...

    lSetRec := FModel.StoreFormState;
  end;
  FOwner.Provider.NotifySubscribers(prReadFormState, Self, @lSetRec);
end;

procedure TTransactionManager.CommitCreateDbFile;
var
  lcdbft : TCreDbFileRec;
begin
  with TCreateDbFileTransaction(fTrx) do begin
    lcdbft := FModel.CreateDbFile(DirName);  // Creae the file with the tables.
    lcdbft.cdbfFilename := FileName;
    lcdbft.cdbfDirectory := DirName;
    lcdbft.cdbfColumnCount := ColumnCount;
    lcdbft.cdbfShortDescription := ShortDescription;

    if lcdbft.cdbfSucces then  // If creating the file and tables was successfull then insert data
    if FModel.InsertDbMetaData(lcdbft) then
      lcdbft.cdbfSucces := True
    else
      lcdbft.cdbfSucces := False;
  end;
  fOwner.Provider.NotifySubscribers(prCreateDbFile, Self, @lcdbft);
end;

procedure TTransactionManager.CommitOpenDbFilePrepareView;
var
  i: Integer;
  lRec : TOpenDbFilePrepareViewRec;
begin
  with TOpenDbFilePrepareViewTransaction(FTrx) do begin
    { #todo : Controle maken op filenaname is leeg. Wat gebeurd er dan? }
    i := FModel.GetColumnCount(FileName); // Get the number of columns.
    lRec.odbfColumnCount := i;
    lRec.odbfParentSingle := PParentSingleColumn;
    lRec.odbfParentMultiple := PParentMultiColumns;
    lRec.odbfFileName := ExtractFileName(Filename);  // Used in the notification and is shown in the taskbar of the mainview
    lRec.odbfFileDir := ExtractFileDir(Filename);
    FModel.RemoveOwnComponents(lRec);
    lRec := FModel.BuildAllComponents(lRec);  // Build the components ==> under construction
  end;

  fOwner.Provider.NotifySubscribers(prOpenDbFile, Self, @lRec);
end;

procedure TTransactionManager.CommitCreateAppDbReference;
begin
  with TCreateAppDbMaintainerTransaction(FTrx) do begin
    FModel.CreateDbItemsMaintainer(FileName);
  end;
end;

procedure TTransactionManager.CommitOpenDbFileGetData;
var
  lRec : TOpenDbFilegetDataRec;
begin
  with TOpenDbFileGetDataTransaction(FTrx) do begin
    lrec.gdLevel := Level;
    lrec.gdGrid := StringGridPtr;
    lRec := FModel.GetItems(lRec);
  end;

  fOwner.Provider.NotifySubscribers(prGetAllItems, Self, @lRec);
end;

procedure TTransactionManager.CommitAddNewItem;
var
  lRec : TItemObjectData;
begin
  with TItemTransaction(FTrx) do begin
    lRec.Name := Name;
    lRec.Level := Level;
    lRec.Action := Action;
    lRec.GridObject := GridObject; // ! wordt in view main weer omgezet naar het stringgrid waarvan de onvalidate werd getriggert.
    lRec.MustSave := MustSave;
    lRec := FModel.AddNewItem(@lRec);
  end;
  FOwner.Provider.NotifySubscribers(prAddNewItem, self, @lRec);
end;

procedure TTransactionManager.CommitUpdateItem;
var
  lRec : TItemObjectData;
begin
  with TItemTransaction(FTrx) do begin
    lRec.Guid := Guid;
    lRec.Name := Name;
    lRec.Level := Level;
    lRec.Action := Action;
    lRec.GridObject := GridObject; // ! wordt in view main weer omgezet naar het stringgrid waarvan de onvalidate werd getriggert.
    lRec.MustSave := MustSave;
    lRec.sgCol := Col;
    lrec.sgRow := Row;
    FModel.UpdateItem(@lRec);
  end;
  FOwner.Provider.NotifySubscribers(prUpdateItem, self, @lRec);
end;

procedure TTransactionManager.CommitDeleteItem;
  var
    lRec : TItemObjectData;
  begin
    with TItemTransaction(FTrx) do begin
      lRec.Guid := Guid;
      lRec.Name := Name;
      lRec.Level := Level;
      lRec.Action := Action;
      lRec.GridObject := GridObject; // ! wordt in view main weer omgezet naar het stringgrid waarvan de onvalidate werd getriggert.
      lRec.MustSave := MustSave;
      lRec.sgCol := Col;
      lRec.sgRow := Row;
      lRec.AllSGrids := AllSGrids;
      FModel.DeleteItem(@lRec);
    end;
    FOwner.Provider.NotifySubscribers(prDeleteItem, self, @lRec);
end;

procedure TTransactionManager.CommitSaveChanges;
var
  lRec : TSaveChangesRec;
begin
  with TSaveChangesTransaction(Ftrx) do begin
    lRec.scSuccess := FModel.SaveChanges(@lRec);
  end;
  FOwner.Provider.NotifySubscribers(prSaveChanges, self, @lRec);
end;

procedure TTransactionManager.CommitCheckboxToggled;
var
  lRec : TCheckBoxCellPosition;
begin
  with TCheckboxToggleTransaction(FTrx) do begin
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
    lRec := FModel.SetReadyRelation(@lRec);
  end;
  FOwner.Provider.NotifySubscribers(prCheckboxToggled, self, @lRec);
end;

procedure TTransactionManager.CommitGetColumnNames;
var
  lRec : TGetColumnNameRec;
begin
  with TGetColumnNamesTransaction(FTrx) do begin
    lRec := FModel.GetColumnNames(lRec);
    lRec.NameView := NameView;
  end;

  fOwner.Provider.NotifySubscribers(prGetColumnNames, Self, @lRec);
end;

procedure TTransactionManager.CommitUpdateSettings;
var
  lSetRec : TSettingsRec;
begin
  with TSettingstransaction(FTrx) do
  begin
    lSetRec := FModel.ReadSettings(SettingsLocationAndFileName, FormName);
    FModel.Settings.FormName := FormName;
    FModel.Settings.ActivateLogging := ActivateLogging;
    FModel.Settings.AppendLogging := AppendLogging;
    FModel.Settings.Language := Language;
    //...

    lSetRec := FModel.WriteSettings;
  end;
  FOwner.Provider.NotifySubscribers(prUpdateSettings, Self, @lSetRec);
end;

constructor TTransactionManager.Create(anOwner: IPresenter; aModel: IModel);
begin
  inherited Create;
  FModel := aModel;
  FOwner := anOwner;
  FTrx := nil;
end;

destructor TTransactionManager.Destroy;
begin
  FModel := nil;
  FOwner := nil;
  if InTransaction then RollbackTransaction; { forget changes }
  inherited Destroy;
end;

procedure TTransactionManager.CommitTransaction;
begin { we delegate according to creational type }
  if InTransaction then begin
    case fTrx.ModState of
      msCreateDir             : CommitCreatingDirs;
      msReadSettings          : CommitReadSettings;
      msUpdateSettings        : CommitUpdateSettings;
      msStoreFormState        : CommitStoreFormState;
      msReadFormState         : CommitReadFormState;
      msCreateDbFile          : CommitCreateDbFile;
      msOpenDbFilePrepareView : CommitOpenDbFilePrepareView;
      msCreateAppDbReference  : CommitCreateAppDbReference;
      msOpenDbFileGetData     : CommitOpenDbFileGetData;
      msAddNewItem            : CommitAddNewItem;
      msUpdateItem            : CommitUpdateItem;
      msDeleteItem            : CommitDeleteItem;
      msSaveChanges           : CommitSaveChanges;
      msCheckboxToggled       : CommitCheckboxToggled;
      msGetColumnNames        : CommitGetColumnNames;
    end;
    FreeAndNil(fTrx); { ready, free and make sure it's nil again! }
  end;
end;

function TTransactionManager.InTransaction: boolean;
begin { if it's assigned, then we haven't been committed or rolled back yet }
  Result:= Assigned(fTrx);
end;

procedure TTransactionManager.RollbackTransaction;
begin { just forget changes }
  if InTransaction then FreeAndNil(fTrx);
end;

function TTransactionManager.StartTransaction(aModState: word): TTransaction;
begin { we create a descendant that supports our modification needs }
  if not InTransaction then case aModState of
    msCreateDir             : FTrx := TDirTransaction.Create(aModState);
    msReadSettings          : FTrx := TSettingstransaction.Create(aModState);
    msUpdateSettings        : FTrx := TSettingstransaction.Create(aModState);
    msReadFormState         : FTrx := TSettingstransaction.Create(aModState);
    msStoreFormState        : FTrx := TSettingstransaction.Create(aModState);
    msCreateDbFile          : FTrx := TCreateDbFileTransaction.Create(aModState);
    msOpenDbFilePrepareView : FTrx := TOpenDbFilePrepareViewTransaction.Create(aModState);
    msCreateAppDbReference  : FTrx := TCreateAppDbMaintainerTransaction.Create(aModState);
    msOpenDbFileGetData     : FTrx := TOpenDbFileGetDataTransaction.Create(aModState);
    msAddNewItem            : FTrx := TItemTransaction.Create(aModState); { #todo : Deze kan samengevoegd worden met de volgende. onderscheid kan met aModState worden gemaakt}
    msUpdateItem            : FTrx := TItemTransaction.Create(aModState);
    msDeleteItem            : FTrx := TItemTransaction.Create(aModState);
    msSaveChanges           : FTrx := TSaveChangesTransaction.Create(aModState);
    msCheckboxToggled       : FTrx := TCheckboxToggleTransaction.Create(aModState);
    msGetColumnnames        : FTrx := TGetColumnNamesTransaction.Create(aModState);
  end;

  Result:= fTrx;
end;

{ TDirTransaction }

constructor TDirTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
  FNewDirnames := TStringList.Create;
  FNewDirnames.SkipLastLineBreak := true;
end;

destructor TDirTransaction.Destroy;
begin
  FNewDirnames.Free;
  inherited Destroy;
end;

{ TSettingstransaction }

constructor TSettingstransaction.Create(aModState: word);
begin
  inherited Create(aModState);
end;

destructor TSettingstransaction.Destroy;
begin
  inherited Destroy;
end;

{ TCreateDbFileTransaction }

constructor TCreateDbFileTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
end;

destructor TCreateDbFileTransaction.Destroy;
begin
  inherited Destroy;
end;

{ TOpenDbFilePrepareViewTransaction }

constructor TOpenDbFilePrepareViewTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
end;

destructor TOpenDbFilePrepareViewTransaction.Destroy;
begin
  inherited Destroy;
end;

{ TCreateAppDbMaintainerTransaction }

constructor TCreateAppDbMaintainerTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
end;

destructor TCreateAppDbMaintainerTransaction.Destroy;
begin
  inherited Destroy;
end;

{ TGetAllItemDataTransaction }

constructor TOpenDbFileGetDataTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
end;

destructor TOpenDbFileGetDataTransaction.Destroy;
begin
  inherited Destroy;
end;

{ TSaveChangesTransaction }

constructor TSaveChangesTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
end;

destructor TSaveChangesTransaction.Destroy;
begin
  inherited Destroy;
end;

{ TInsertItemTransaction }

constructor TItemTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
end;

destructor TItemTransaction.Destroy;
begin
  inherited Destroy;
end;

{ TCheckboxToggleTransaction }

{
function TCheckboxToggleTransaction.Get_Parent_guid(Index: Integer): String;
begin
  Result := FParent_guid[Index];
end;

procedure TCheckboxToggleTransaction.Set_Parent_guid(Index: Integer;
  AValue: String);
begin
  FParent_guid[Index] := AValue;
end;    }

constructor TCheckboxToggleTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
//  SetLength(FParent_guid, 0);
end;

destructor TCheckboxToggleTransaction.Destroy;
begin
  inherited Destroy;
end;

{
procedure TCheckboxToggleTransaction.SetLengthParentGuidPlusOne;
begin
  SetLength(FParent_guid, Length(FParent_guid) +1);
end;}

{ TgtColumnNamesTransaction }

constructor TGetColumnNamesTransaction.Create(aModState: word);
begin
  inherited Create(aModState);
end;

destructor TGetColumnNamesTransaction.Destroy;
begin
  inherited Destroy;
end;

end.


