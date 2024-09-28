
unit model.decl;
{$mode ObjFPC}{$H+}
interface 
uses classes,sysutils,contnrs, istrlist, obs_prosu, model.base, model.intf,
  presenter.trax;
const
  Version = '0.26.08.2024'; // 1.st commit,
  bcMaxWord = 65535;
  mvpTexts = '%smvptexts.%s'; // <-- remember to change to your choice
  Lang: string = 'en'; //<- - - -^ i18n support ~ writable const / static var

  Application_version = '0.4.0.0';
  Application_buildDate = '22-09-2024';
  Application_databaseVersion = '1';

  laInformation = 'Information';
  laWarning = 'Warning';
  laError = 'Error';
  laDebug = 'Debug';


  { string guids for the interfaces / services used in this app }
  SGUIDIModelMain = '{0349B40E-FBB4-4C6E-9CB0-A63690CF0898}';          //=^
  SGUIDIPresenterMain = '{736B14F8-8BB7-4F5D-ADAA-B90A1735765C}';      //=^
  SGUIDITransactionManager = '{C75AE70E-43DA-4A76-A52D-061AFC6562D0}'; //=^
  SGUIDITrxExec = '{2E618F58-DE15-4A79-ADEF-C4E0A7CBECA4}';            //=^
  SGUIDIViewMain = '{5AC3C283-C7EB-437D-8A72-3A0BD7A47B1C}';           //=^
  SGUIDIViewNewItem= '{3BD72226-516D-4049-9CB5-B429D5E39FD2}';
  
  { aliased (p)rovider (r)easons for observer action/reaction }
  prStatus                = model.base.prStatus; { carries an optional object in aNotifyClass and usually a pchar in UserData }
  prMainStaticTexts       = model.base.prMainStaticTexts; { carries an 'IStrings' object in UserData }
  prStatusBarPanelText    = model.base.prStatusBarPanelText;
  prCreateDir             = model.base.prCreateDir;
  prAppSettings           = model.base.prAppSettings;
  prAppSingleSetting      = model.base.prAppSingleSetting;
  prFormState             = model.base.prFormState;
  prStatusBarPanelWidth   = model.base.prStatusBarPanelWidth;
  prCreateAppDbReference  = model.base.prCreateAppDbReference;
  prCreDatabaseFile       = model.base.prCreDatabaseFile;
  prOpenDbFile            = model.base.prOpenDbFile;
  prOpenDbFilePrepareView = model.base.prOpenDbFilePrepareView;
  prSgHeaderFontStyle     = model.base.prSgHeaderFontStyle;
  prSaveChanges           = model.base.prSaveChanges;
  prAddNewItem            = model.base.prAddNewItem;
  prUpdateItem            = model.base.prUpdateItem;
  prDeleteItem            = model.base.prDeleteItem;
  prEnableSaveButton      = model.base.prEnableSaveButton;
  prPmiStatus             = model.base.prPmiStatus;
  prBitBtnShow            = model.base.prBitBtnShow;
  prCheckboxToggled       = model.base.prCheckboxToggled;
  prSgRemoveEmptyRows     = model.base.prSgRemoveEmptyRows;
  prGetAllItems           = model.base.prGetAllItems;
  prGetColumnNames        = model.base.prGetColumnNames;
  prCloseDatabaseFile     = model.base.prCloseDatabaseFile;
  prSgAdjust              = model.base.prSgAdjust;
  prSaveColumnNames       = model.base.prSaveColumnNames;
  prSgAddRow              = model.base.prSgAddRow;


  { (p)rovider (r)easons for view.configure }
  prConfigStaticTexts = prUser + 500; { carries an 'IStrings' object in UserData }
  prConfigStaticHints = prUser + 501;
  prNewItemStaticTexts = prUser + 502;

  // etc...

  { targettexts below lets you use 1 handler in view, 1 result record and differentiate on target-id }
  TargetTexts: TStringArray = ('Directories','Resources','Models','Presenters','Views'); // example


  { (a)pplication (m)essages }
  amSucces = 'Success';
  amFailed = 'Failed';

  { (a)pplication (d)irectories }
  adSettings  = 'Settings';
  adLogging   = 'Logging';
  adDatabase  = 'Database';
  adBackUpFld = 'Database\BackUp';

  { (I)tem (A)ction }
  iaCreate = 'Create';  // Item Action = Create
  iaRead = 'Read';      // Item Action = Read
  iaUpdate = 'Update';  // Item Action = Update
  iaDelete = 'Delete';  // Item Action = Delete

  { (s)tringgrid (s)tate }
  ssRead = 'ReadOnly';
  ssModify = 'ModifyItems';
  ssModifyRelations = 'ModifyRelations';


type
  TTransaction = model.base.TTransaction; // ancester alias
  { TTransactionmanager governs alterations to datastore }
  TTransactionManager = class(TObject,ITransactionManager)
  private
    fTrx: TTransaction;
    fOwner: IPresenterMain;
    fModel: IModelMain;
    function get_ActiveTrx: ITransaction;
    function get_Model: IModelMain;          
    function get_Owner: IPresenterMain;   
    function Obj: TObject;
  public
    constructor Create(anOwner: IPresenterMain;aModel: IModelMain);
    destructor Destroy; override;
    procedure CommitTransaction;
    function InTransaction: boolean;
    procedure RollbackTransaction;
    function StartTransaction(aModReason: word): TTransaction;
    property ActiveTrx: ITransaction read get_ActiveTrx;
    property Model: IModelMain read get_Model;
    property Owner: IPresenterMain read get_Owner;       
  end;


  { alias }
  TStatusbarPanelText       = model.base.TStatusbarPanelText;
  PStatusbarPanelText       = model.base.PStatusbarPanelText;
  TDirectoriesRec           = model.base.TDirectoriesRec;
  PDirectoriesRec           = model.base.PDirectoriesRec;
  TSettingsRec              = model.base.TSettingsRec;
  PSettingsRec              = model.base.PSettingsRec;
  TSingleSettingRec         = model.base.TSingleSettingRec;
  PSingleSettingRec         = model.base.PSingleSettingRec;
  TDatabaseInfo             = model.base.TDatabaseInfo;
  TstbPanelsSize            = model.base.TstbPanelsSize;
  PStbPanelsSize            = model.base.PStbPanelsSize;
  TOpenDbFilePrepareViewRec = model.base.TOpenDbFilePrepareViewRec;
  TCreDbFileRec             = model.base.TCreDbFileRec;
  PCreDbFileRec             = model.base.PCreDbFileRec;
  POpenDbFilePrepareViewRec = model.base.POpenDbFilePrepareViewRec;
  TStringGridSelect         = model.base.TStringGridSelect;
  PStringGridSelect         = model.base.PStringGridSelect;
  TStringGridRec            = model.base.TStringGridRec;
  PStringGridRec            = model.base.PStringGridRec;
  TSaveChangesRec           = model.base.TSaveChangesRec;
  PSaveChangesRec           = model.base.PSaveChangesRec;
  TItemObjectData           = model.base.TItemObjectData;
  PItemObjectData           = model.base.PItemObjectData;
  TSaveBtn                  = model.base.TSaveBtn;
  PSaveBtn                  = model.base.PSaveBtn;
  TPmiVisibility            = model.base.TPmiVisibility;
  PPmiVisibility            = model.base.PPmiVisibility;
  TBitBtnRec                = model.base.TBitBtnRec;
  PBitBtnRec                = model.base.PBitBtnRec;
  TCheckBoxCellPosition     = model.base.TCheckBoxCellPosition;
  PCheckBoxCellPosition     = model.base.PCheckBoxCellPosition;
  TClearPtrData             = model.base.TClearPtrData;
  PClearPtrData             = model.base.PClearPtrData;
  TOpenDbFileGetDataRec     = model.base.TOpenDbFileGetDataRec;
  POpenDbFileGetDataRec     = model.base.POpenDbFileGetDataRec;
  TGetColumnNameRec         = model.base.TGetColumnNameRec;
  PGetColumnNameRec         = model.base.PGetColumnNameRec;
  AllColumnNames            = model.base.AllColumnNames;
  TDbFileRec                = model.base.TDbFileRec;
  PDbFileRec                = model.base.PDbFileRec;


{ utility functions, here we publicly export these functions, to be made available
  in other units, that can't /see/ us, for import :o) gotta love FPC \o/\ö/\o/ }
function Pch2Str(aPch: pchar): string; public name 'BC_PCH2STR';
function Str2Pch(aStr: string): pchar; public name 'BC_STR2PCH'; 

implementation

{$Region 'utility'}
function Pch2Str(aPch: pchar): string;
begin // compiler conversion, implicit new memory allocation :o)
  if aPch = nil then exit('');
  Result:= string(aPch);
end;

function Str2Pch(aStr: string): pchar;
begin // compiler conversion, pointer :o)
  if aStr = '' then exit(nil);
  Result:= pchar(aStr);
end;
{$EndRegion 'utility'}

{$Region 'TTransactionManager'}
{ TTransactionManager }
function TTransactionManager.Obj: TObject;
begin
  Result:= Self;
end;

function TTransactionManager.get_ActiveTrx: ITransaction;
begin
  Result:= fTrx;
end;

function TTransactionManager.get_Model: IModelMain; //+
begin
  Result:= fModel;
end;

function TTransactionManager.get_Owner: IPresenterMain; //+
begin
  Result:= fOwner;
end;
  
constructor TTransactionManager.Create(anOwner: IPresenterMain;aModel: IModelMain);
begin
  inherited Create;
  fOwner:= anOwner;
  fModel:= aModel;  
  fTrx:= nil;
end;

destructor TTransactionManager.Destroy;
begin       
  if InTransaction then RollbackTransaction; // forget changes
  fOwner:= nil;
  fModel:= nil;
  inherited Destroy;
end;

procedure TTransactionManager.CommitTransaction;
var
  lte: ITrxExec; { when you use "self-committing" transactions. in doubt? ask me in forum }
begin
  if InTransaction then begin
    case fTrx.ModReason of
      prNone: raise Exception.Create('Error! TTransactionManager.CommitTransaction: "ModReason = prNone"'); // failsafe
      prDataAdded: ;      // 2=const in obs_prosu
      { example of using the trxExec interface, "TTextEdit" implements it (if you write the code) }
      prDataChanged: if fTrx.GetInterface(SGUIDITrxExec,lte) then begin
                       if lte.Execute(Self) then
                         fOwner.Provider.NotifySubscribers(prStatus,nil,Str2Pch(' (i) Textfile "'+lte.Title+'" changed successfully'));
                     end;      // 3
      prDataDeleted: ;    // 4
      //prUser=11+x
      prCreateDir: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin  // <<= use exec sguid
                     lte.Execute(Self);
      end;
      prAppSettings: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                       lte.Execute(Self);
      end;
      prAppSingleSetting: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                            lte.Execute(Self);
      end;
      prFormState: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                     lte.Execute(Self);
      end;
      prCreateAppDbReference: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                                lte.Execute(Self);
      end;
      prSaveChanges: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                       lte.Execute(Self);
      end;
      prOpenDbFilePrepareView: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                                 lte.Execute(Self);
      end;
      prAddNewItem: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                      lte.Execute(Self);
      end;
      prUpdateItem: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                      lte.Execute(Self);
      end;
      prDeleteItem: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                      lte.Execute(Self);
      end;
      prCheckboxToggled: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                           lte.Execute(Self);
      end;
      prGetAllItems: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                       lte.Execute(Self);
      end;
{      prOpenDbFileGetData: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                             lte.Execute(Self);
      end;}
      prGetColumnNames: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                          lte.Execute(Self);
      end;
      prCreDatabaseFile: if fTrx.GetInterface(SGUIDItrxExec, lte) then begin
                          lte.Execute(Self);
      end;
    end;
    FreeAndNil(fTrx); // done, free and make sure it's nil again!
  end;
end;

function TTransactionManager.InTransaction: boolean;
begin
  Result:= Assigned(fTrx);
end;

procedure TTransactionManager.RollbackTransaction;
begin
  if InTransaction then FreeAndNil(fTrx);
end;

function TTransactionManager.StartTransaction(aModReason: word): TTransaction;
begin
  if not InTransaction then case aModReason of
    prCustom:                fTrx:= TTransaction.Create(aModReason); // 1 ~ doen't cause an exception, 0 does!
    prDataChanged:           fTrx:= TTextEdit.Create(aModReason); // 1
    prCreateDir:             fTrx:= TCreDirTransaction.Create(aModReason);
    prAppSettings:           fTrx:= TSettingstransaction.Create(aModReason);
    prAppSingleSetting:      fTrx:= TSingleSettingTransaction.Create(aModReason);
    prFormState:             fTrx:= TSettingstransaction.Create(aModReason);
    prCreateAppDbReference:  fTrx:= TCreateAppDbMaintainerTransaction.Create(aModReason);      // prCreateAppDbReference
    prSaveChanges:           fTrx:= TSaveChangesTransaction.Create(aModReason);
    prOpenDbFilePrepareView: fTrx:= TOpenDbFilePrepareViewTransaction.Create(aModReason);
    prAddNewItem:            fTrx:= TNewItemTransaction.Create(aModReason);
    prUpdateItem:            fTrx:= TUpdateItemTransaction.Create(aModReason);
    prDeleteItem:            fTrx:= TDeleteItemTransaction.Create(aModReason);
    prCheckboxToggled:       fTrx:= TCheckboxToggleTransaction.Create(aModReason);
    prGetAllItems:           fTrx:= TOpenDbFileGetDataTransaction.Create(aModReason);
    prGetColumnNames:        fTrx:= TGetColumnNamesTransaction.Create(aModReason);
    prCreDatabaseFile:       fTrx:= TCreateDbFileTransaction.Create(aModReason);
    /// etc...
    else fTrx:= TTransaction.Create(aModReason); // 0 or anything undefined by us
  end;
  Result:= fTrx;
end;
{$EndRegion 'TTransactionManager'}

end.
