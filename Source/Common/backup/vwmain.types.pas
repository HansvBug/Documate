unit vwmain.types;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  PStaticTextsAll = ^TStaticTextsAll;
  TStaticTextsAll = record
    staClear,
    staVwMainTitle,
    staMmiProgramCaption,
    staMmiProgramOpenDbFileCaption,
    staMmiProgramCloseDbFileCaption,
    staMmiProgramNewDbFileCaption,
    staMmiProgramQuitCaption,

    staVwConfigure,
    staMmiOptionsCaption,
    staMmiOptionsOptionsCaption,
    staMmiOptionsLanguageCaption,
    staMmiOptionsLanguageENCaption,
    staMmiOptionsLanguageNLCaption,

    staTbsMiscellaneousCaption,
    staTbsAppDdCaption,
    staOptionsBtnCloseCaption,

    staGbLoggingCaption,
    staChkActiveLoggingCaption,
    staChkAppendLoggingCaption,
    staGroupBoxColumnNamesCaption,
    stabtnColumnSaveCaption,
    staSgColLevel,
    staSgColName,

    staTsItemsCaption,

    staRgrpStrings_1,
    staRgrpStrings_2,
    staRgrpStrings_3,
    staBtnSaveCaption,

    staPmiAutoSizeStringGridCaption,
    staPmiAutoSizeStringGridAllCaption,
    staPmiDeleteItemCaption,
    staPmiAddItemCaption,
    staPmiImportCaption : String;
  end;

  PClearPtrData = ^TClearPtrData;
  TClearPtrData = record
    cpdObject : Pointer;
    cpdSuccess : Boolean;
  end;

  PStatusbarPanelText = ^TStatusbarPanelText;
  TStatusbarPanelText = record
    sbpt_panel0,
    sbpt_panel1,
    sbpt_panel2 : String;
    sbpt_activePanel : Word;
  end;


  PDirectoriesRec = ^TDirectoriesRec;
  TDirectoriesRec = record
    dirNewDirnames, { we'll translate like this: TStringList.Text:= dirNewDirnames; }
    dirProjectName, { dunno, could be useful }
    dirRoot,
    dirSuccesMsg: string;
    dirSucces: boolean;
  end;

  PSettingsRec = ^TSettingsRec;
  TSettingsRec = record
    setActivateLogging,
    setAppendLogging: Boolean;
    setLanguage : String;

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
    setSucces: Boolean;
  end;

  PCreDbFileRec = ^TCreDbFileRec;
  TCreDbFileRec = record
    cdbfDirectory,
    cdbfShortDescription,
    cdbfFilename: string;
    cdbfColumnCount : Integer;
    cdbfCreateTable,
    cdbfSucces: boolean;
    cdbfMessage : String;
  end;

  // dubbel met TCreDbFileRec
  { #todo : Kan samengevoegd worden met TCreDbFileRec }
  POpenDbFilePrepareViewRec = ^TOpenDbFilePrepareViewRec;
  TOpenDbFilePrepareViewRec = record
    odbfFileComplete : string;
    odbfFileDir : string;
    odbfFileName : string;
    odbfColumnCount : Integer;
    odbfParentSingle: Pointer;
    odbfParentMultiple: Pointer;
    odbfSucces: boolean;
  end;

  PItemDataRec = ^TItemDataRec;
  TItemDataRec = record
    idColumn : Integer;
    idItem   : String;
  end;
  AllItemsData = array of TItemDataRec;

  POpenDbFilegetDataRec = ^TOpenDbFileGetDataRec;
  TOpenDbFileGetDataRec = record
    gdFileComplete : string;
    gdLevel: Byte;
    gdGrid: Pointer;
    gdSucces: boolean;
  end;

  PtrItemObject = ^TItemObjectData;
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
    AllGrids         : Pointer;
  end;
  AllItemsObjectData = array of TItemObjectData;

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

  PBitBtnRec = ^TBitBtnRec;
  TBitBtnRec = record
    btnObject: Pointer;
    btnAddVisible: Boolean;
    btnSaveVisible: Boolean;
    btnSaveEnable: Boolean;
  end;

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

  PSaveChangesRec = ^TSaveChangesRec;
  TSaveChangesRec = record
    scSuccess,
    MustSave: Boolean;
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

  PGetColumnNameRec = ^TGetColumnNameRec;
  TGetColumnNameRec = record
    ColumnName : string;
    Key        : String;
    Value      : String;
    AllColNames: array of TGetColumnNameRec;
    aGrid : TObject;
    Success : Boolean;
    NameView : String;
  end;
  AllColumnNames = array of TGetColumnNameRec;

  {$interfaces corba}
    TTransaction = class;
    { ITransaction this interface is to be inherited from }
    ITransaction = interface['{D9DB6EFE-480A-4E37-B250-A3594D5459FA}']
      function get_DataPtr: pointer;
      function get_ModState: word;
      function get_Sender: TObject;
      function Obj: TTransaction;
      procedure set_DataPtr(aValue: pointer);
      procedure set_ModState(aValue: word);
      procedure set_Sender(aValue: TObject);
      property DataPtr: pointer read get_DataPtr write set_DataPtr; { you never know }
      Property ModState: word read get_ModState write set_ModState;
      Property Sender: TObject read get_Sender write set_Sender;
    end;

  {$interfaces com}
    { TTransaction this class is to be inherited from }
    TTransaction = class(TObject, ITransaction)
    private
      fDataPtr: pointer;
      fModState: word;
      fSender: TObject;
      function get_DataPtr: pointer;
      function get_ModState: word;
      function get_Sender: TObject;
      function Obj: TTransaction;
      procedure set_DataPtr(aValue: pointer);
      procedure set_ModState(aValue: word);
      procedure set_Sender(aValue: TObject);
    public
      constructor Create(aModState: word); virtual;
      destructor Destroy; override;
      property DataPtr: pointer read get_DataPtr write set_DataPtr; { you never know }
      Property ModState: word read get_ModState write set_ModState;
      Property Sender: TObject read get_Sender write set_Sender;
    end;

implementation

{ TTransaction }

function TTransaction.get_DataPtr: pointer;
begin
  Result:= fDataPtr;
end;

function TTransaction.get_ModState: word;
begin
  Result:= fModState;
end;

function TTransaction.get_Sender: TObject;
begin
  Result:= fSender;
end;

function TTransaction.Obj: TTransaction;
begin
  Result:= Self;
end;

procedure TTransaction.set_DataPtr(aValue: pointer);
begin
  fDataPtr:= aValue;
end;

procedure TTransaction.set_ModState(aValue: word);
begin
  fModState:= aValue;
end;

procedure TTransaction.set_Sender(aValue: TObject);
begin
  fSender:= aValue;
end;

constructor TTransaction.Create(aModState: word);
begin
  inherited Create;
  fModState:= aModState;
end;

destructor TTransaction.Destroy;
begin
  inherited Destroy;
end;

end.

