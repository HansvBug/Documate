(* 
primes: 2,    3,    5,    7,   11,   13,   17,   19,   23,   29,
       31,   37,   41,   43,   47,   53,   59,   61,   67,   71,
*)

unit model.base;
{$mode ObjFPC}{$H+}
{$ModeSwitch advancedrecords}
interface
uses classes,sysutils,obs_prosu;
const
  { (p)rovider (r)easons for observer action/reaction, they're here because then we can use them in
    'presenter.trax' without /cyclic dependencies/ with 'model.decl' :o) }
  prStatus = prUser + 1; { carries an optional object in aNotifyClass and usually a pchar in UserData }
  prMainStaticTexts = prUser + 2; { carries an 'IStrings' object in UserData }
  prStatusBarPanelText = prUser + 3;
  prCreateDir = prUser + 4;
  prFormState = prUser + 5;
  prAppSettings = prUser + 6;
  prAppSingleSetting = prUser + 7;
  prStatusBarPanelWidth = prUser + 8;
  prCreateAppDbReference = prUser + 9;
  prOpenDbFile = prUser + 10;
  prOpenDbFilePrepareView = prUser + 11;
  prSgAddRow = prUser + 12;
  prSgHeaderFontStyle = prUser + 13;
  prSaveChanges = prUser + 14;
  prAddNewItem = prUser + 15;
  prUpdateItem = prUser + 16;
  prDeleteItem = prUser + 17;
  prEnableSaveButton = prUser + 18;
  prPmiStatus = prUser + 19;
  prBitBtnShow = prUser + 20;
  prCheckboxToggled = prUser + 21;
  prSgRemoveEmptyRows = prUser + 22;
  prClearMainView = prUser + 23;
  prGetAllItems = prUser + 24;
//  prOpenDbFileGetData = prUser + 25;
  prGetColumnNames = prUser + 26;
  prCreDatabaseFile = prUser + 27;
  prCloseDatabaseFile = prUser + 28;
  prSgAdjust = prUser + 29;
  prSaveColumnNames = prUser + 30;

  //etc...
  
type
{$interfaces corba}
  { this is the ancestor }
  ICorba = interface['{3563A63E-8C1A-40E1-9574-3E4171BB3ACF}']
    function Obj: TObject;
  end;
  TTransaction = class; // forward
  { ImemTransaction is our container vessel for changes }
  ITransaction = interface['{AFE2A986-7D3C-46AB-A4BF-2A0BDA1DECDF}']
    function get_DataPtr: pointer;
    function get_Id: ptrint;
    function get_ModReason: word;
    function get_Sender: TObject;
    function get_StrProp(anIndex: integer): shortstring;
    function Obj: TTransaction;
    procedure set_DataPtr(aValue: pointer);
    procedure set_Id(aValue: ptrint);
    procedure set_ModReason(aValue: word);  
    procedure set_Sender(aValue: TObject);
    procedure set_StrProp(anIndex: integer;aValue: shortstring);
    
    property DataPtr: pointer read get_DataPtr write set_DataPtr; 
    property ID: ptrint read get_Id write set_Id;
    Property ModReason: word read get_ModReason write set_ModReason;
    Property Sender: TObject read get_Sender write set_Sender; 
    property Title: shortstring index 0 read get_StrProp write set_StrProp;
  end;
{$interfaces com}

  PStatusbarPanelText = ^TStatusbarPanelText;
  TStatusbarPanelText = record
    stbPanelText: String;
    stbActivePanel : Word;
  end;

  { TTransaction is our container vessel for changes }
  TTransaction = class(TObject,ITransaction)
  protected
    fDataPtr: pointer;
    fID: ptrint;
    fModReason: word; 
    fSender: TObject;
    fTitle: shortstring;
    function get_DataPtr: pointer; virtual;
    function get_Id: ptrint; virtual;
    function get_ModReason: word; virtual;
    function get_Sender: TObject; virtual;
    function get_StrProp(anIndex: integer): shortstring; virtual;
    function Obj: TTransaction; virtual;
    procedure set_DataPtr(aValue: pointer); virtual;
    procedure set_Id(aValue: ptrint); virtual;
    procedure set_ModReason(aValue: word); virtual;
    procedure set_Sender(aValue: TObject); virtual;
    procedure set_StrProp(anIndex: integer;aValue: shortstring); virtual;
  public
    constructor Create(aModReason: word); virtual;
    destructor Destroy; override;
    property DataPtr: pointer read get_DataPtr write set_DataPtr;
    property ID: ptrint read get_Id write set_Id;
    Property ModReason: word read get_ModReason write set_ModReason;
    Property Sender: TObject read get_Sender write set_Sender;
    property Title: shortstring index 0 read get_StrProp write set_StrProp;
  end; { TTransaction }


  PDirectoriesRec = ^TDirectoriesRec;  // used with CreateDirectories, TCreDirTransaction
  TDirectoriesRec = record
    dirNewDirnames, { we'll translate like this: TStringList.Text:= dirNewDirnames; }
    dirRoot,
    dirSuccesMsg: String;
    dirSucces: boolean;
  end;

  PSettingsRec = ^TSettingsRec;  // used with ReadSettings, TSettingstransaction , ReadFormState; and   StoreFormstate;
  TSettingsRec = record
    setActivateLogging,
    setAppendLogging: Boolean;
    setLanguage : String;
    setSettingsFile,
    setApplicationName,
    setApplicationVersion,
    setApplicationBuildDate : String;

    setFrmName : String;
    setFrmWindowState,
    setFrmTop,
    setFrmLeft,
    setFrmHeight,
    setFrmWidth,
    setFrmRestoredTop,
    setFrmRestoredLeft,
    setFrmRestoredHeight,
    setFrmRestoredWidth : Integer;
    setSucces,
    setReadSettings,
    setWriteSettings,
    setReadFormState: Boolean;
  end;

  PSingleSettingRec = ^TSingleSettingRec;
  TSingleSettingRec = record
    ssSettingsFile: String;
    ssName: String;
    ssValue: String;
  end;

  { Basic information of the openend file. }
  PDatabaseInfo = ^TDatabaseInfo;
  TDatabaseInfo = record
    FileName,
    FileLocation,
    FullFileName: string;
    ColumnCount: Word;
    DbIsOpened: Boolean;
    ColumnNames: array of String;
  end;

  PStbPanelsSize = ^tStbPanelsSize;
  TStbPanelsSize = record
    lpWidth,
    mpWidth,
    rpWidth: Integer;
  end;

  POpenDbFilePrepareViewRec = ^TOpenDbFilePrepareViewRec;  // used with  PrepareView;, TOpenDbFilePrepareViewTransaction
  TOpenDbFilePrepareViewRec = record
    odbfFileComplete : string;
    odbfFileDir : string;
    odbfFileName : string;
    odbfColumnCount : Integer;
    odbfParentSingle: Pointer;
    odbfParentMultiple: Pointer;
    odbfSucces: boolean;
  end;

  PStringGridRec = ^TStringGridRec;
  TStringGridRec = record
    sgName : String;
    sgHeaderFontStyle : Integer;
    sgLevel : Integer;
    sgState : String;
    sgShowParentCol,
    sgAddExtraRow,
    sgShowChildCol: Boolean;
    //sgParentFontColor : Byte;  als de kleur optieel wordt dan is dit nodig
  end;

  PStringGridSelect = ^TStringGridSelect;
  TStringGridSelect = record
    aCol,
    aRow,
    aLevel : Integer;
    sgarray : Array of TObject;
    AllowCellSelectColor : Boolean;
    RectLeft,
    RectTop,
    RectRight,
    RectBottom : Integer;
    Guid : string;
    sgName : string;
    Parent_guid : array of String;
  end;

  PSaveChangesRec = ^TSaveChangesRec;
  TSaveChangesRec = record
    scSuccess,
    MustSave: Boolean;
  end;

  PItemObjectData = ^TItemObjectData;
  TItemObjectData = record
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
    AllSGrids        : Pointer;
  end;
  AllItemsObjectData = array of TItemObjectData;

  PSaveBtn = ^TSaveBtn;
  TSaveBtn = record
    btnEnable : Boolean;  // validate cel entry
    DupFound,                        // nog niet in gebruik
    LengthToLongFound : Boolean      // nog niet in gebruik
  end;

  PPmiVisibility = ^TPmiVisibility;
  TPmiVisibility = record
    pmivDeletItem,
    pmivAddItem,
    pmivImportItems : Boolean;
  end;

  PBitBtnRec = ^TBitBtnRec;
  TBitBtnRec = record
    btnObject: Pointer;
    btnAddVisible: Boolean;
    btnSaveVisible: Boolean;
    btnSaveEnable: Boolean;
  end;

  PCheckBoxCellPosition = ^TCheckBoxCellPosition;
  TCheckBoxCellPosition = record
    Col: Integer;
    Row: Integer;
    Level : Integer;
    Name : String;
    aGridPtr : Pointer;
    aGuid  : String;
    Parent_guid : Array of string;
    Action : String;
    CbIsChecked : Boolean;
    CbParentMultipleCheck : Boolean; // if multiple parents checked then disable save button
    MustSave : Boolean;
    Cansave : Boolean;
    Success : Boolean;
    AllSGrids : Pointer;
    sgName : String;
    RowObject : Pointer;
    // test Trect kan niet mee want is een Windows type
{    RectLeft,
    RectTop,
    RectRight,
    RectBottom: INteger;
    SgState : Byte;}
  end;

  PClearPtrData = ^TClearPtrData;  // used with ClearMainView(...);
  TClearPtrData = record
    cpdObject : Pointer;
    cpdSuccess : Boolean;
  end;

  POpenDbFileGetDataRec = ^TOpenDbFileGetDataRec;  // used with GetAllItemsForStringGrid;, TOpenDbFileGetDataTransaction
  TOpenDbFileGetDataRec = record
    gdFileComplete : string;
    gdLevel: Byte;
    gdGrid: Pointer;
    gdSucces: boolean;
  end;

  PGetColumnNameRec = ^TGetColumnNameRec;
  TGetColumnNameRec = record
    ColumnName : string;
    Key        : String;
    Value      : String;
    AllColNames: array of TGetColumnNameRec;
    aGrid : TObject;
    Success : Boolean;
  end;
  AllColumnNames = array of TGetColumnNameRec;

  PCreDbFileRec = ^TCreDbFileRec;
  TCreDbFileRec = record
    cdbfDirectory,
    cdbfShortDescription,
    cdbfFilename: string;
    cdbfColumnCount : Integer;
    cdbfCreateTable,
    cdbfSucces,
    cdbfSQLiteFileFound: boolean;
    cdbfMessage : String;
  end;

  PDbFileRec= ^TDbFileRec;
  TDbFileRec = record
    dbfFullFileName: string;
    dbfIsClosed: Boolean;
  end;







implementation

{$Region 'TTransaction'}
{ TTransaction }
function TTransaction.get_DataPtr: pointer;
begin
  Result:= fDataPtr;
end;

function TTransaction.get_Id: ptrint;
begin
  Result:= fID;
end;

function TTransaction.get_ModReason: word;
begin
  Result:= fModReason;
end;

function TTransaction.get_Sender: TObject;
begin
  Result:= fSender;
end;

function TTransaction.get_StrProp(anIndex: integer): shortstring;
begin
  case anIndex of
    0: Result:= fTitle;
    1: ;
    2: ;
    else Result:= '';
  end;
end;

function TTransaction.Obj: TTransaction;
begin
  Result:= Self;
end;

procedure TTransaction.set_DataPtr(aValue: pointer);
begin
  fDataPtr:= aValue;
end;

procedure TTransaction.set_Id(aValue: ptrint);
begin
  fID:= aValue;
end;

procedure TTransaction.set_ModReason(aValue: word);
begin
  fModReason:= aValue;
end;

procedure TTransaction.set_Sender(aValue: TObject);
begin
  fSender:= aValue;
end;

procedure TTransaction.set_StrProp(anIndex: integer;aValue: shortstring);
begin
  case anIndex of
    0: fTitle:= aValue;
    1: ;
    2: ;
  end;
end;

constructor TTransaction.Create(aModReason: word);
begin
  inherited Create;
  fModReason:= aModReason;
end;

destructor TTransaction.Destroy;
begin
  inherited Destroy;
end;
{$EndRegion 'TTransaction'}


end.

