unit model.intf;
{$mode ObjFPC}{$H+}
{-$define dbg}
interface
uses classes, istrlist, model.base, obs_prosu, Settings;
type
{$interfaces corba}
  IPresenterMain = interface; // forward 
  { aliases for provider & subscriber }
  IobsProvider = obs_prosu.IobsProvider;
  IobsSubscriber = obs_prosu.IobsSubscriber;
  { alias for transaction }
  ITransaction = model.base.ITransaction;


  { the actual model/datastore api, the "King" }

  { IModelMain }

  IModelMain = interface(ICorba)['{0349B40E-FBB4-4C6E-9CB0-A63690CF0898}']
    function GetStaticTexts(const aSection: string; out aTarget: integer): IStringList;
    function get_DbFullFilename: String;
    function get_Settings: TSettings;
    procedure ReloadTextCache;

    function SetStatusbarText(const aText: string; panel : Word): TStatusbarPanelText;
    function CreateDirs(const aRootDir: string; const aDirList: string = ''): TDirectoriesRec;
    function ReadFormState(Settingsdata: PSettingsRec): TSettingsRec;
    function ReadSettings(Settingsdata: PSettingsRec): TSettingsRec;
    procedure set_DbFullFilename(AValue: String);
    procedure set_settings(AValue: TSettings);
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
  end; { IModel }


  { ITransactionManager reacts to user actions }
  ITransactionManager = interface(ICorba)['{C75AE70E-43DA-4A76-A52D-061AFC6562D0}'] 
    function get_ActiveTrx: ITransaction;
    function get_Model: IModelMain;
    function get_Owner: IPresenterMain;   
    procedure CommitTransaction;
    function InTransaction: boolean;
    procedure RollbackTransaction;
    function StartTransaction(aModReason: word): TTransaction;
    property ActiveTrx: ITransaction read get_ActiveTrx;
    property Model: IModelMain read get_Model;
    property Owner: IPresenterMain read get_Owner;       
  end; { ITransactionManager }


  { specialized transaction, sports an 'execute' method, i.e.: it knows how to commit itself ;-) }
  ITrxExec = interface(ITransaction)['{2E618F58-DE15-4A79-ADEF-C4E0A7CBECA4}']
    function Execute(aMgr: ITransactionManager): boolean;
  end; { ITrxExec }


  { the "Queen" }
  IPresenterMain = interface(ICorba)['{736B14F8-8BB7-4F5D-ADAA-B90A1735765C}']
    function get_Model: IModelMain;
    function get_Provider: IobsProvider;
    function get_TrxMan: ITransactionManager;
    procedure set_Provider(aValue: IobsProvider);
    procedure GetStaticTexts(const aSection: string);
    function GetstaticText(const aView, aText: string): string;
    procedure RefreshTextCache(const aSection,aLangStr: string);

    procedure SetStatusbarText(aText: string; panel: word);
    procedure StartLogging;
    procedure StopLogging;
    procedure WriteToLog(const aSection, aLogAction : String; LogText: String);
    procedure SwitchLanguage(aSection: String);
    procedure PrepareCloseDb;
    procedure SetStatusbarPanelsWidth(Sender: TObject; stbWithd, lpWidth, rpWidth: Integer);
    procedure DbResetAutoIncrementAll(dbFile: String);
    procedure DbCreateCopy(dbFile, DbFolder, dbBackUpFolder: string);
    procedure DbOptimize(dbFile: String);
    procedure DbCompress(dbFile: String);
    function ExtractNumberFromString(const Value: string): String;
    procedure SGAddRow(aSender: TObject; AddExtraRow: Boolean);  // AddExtraRow is when this is activated via Addbutton
    procedure ActiveStrgridCell(aSender: TObject; ViaAddButton : Boolean);
    procedure StringGridOnPrepareCanvas(aSender: TObject; aCol, aRow: Integer; ShowRelationColor: Boolean);
    procedure StringGridOnSelectCell(aSender: TObject; sgSelect: PStringGridSelect);
    procedure StringGridOnDrawCell(aSender: TObject; sgSelect: PStringGridSelect);
    procedure SetStringGridHeaderFontStyle(aSender: TObject; aFontStyle: Integer);
    procedure ValidateCellEntry(sgObject, BtnObject: TObject; aText: string; aRow: Integer);
    procedure SetPmiState(SetPmiState : TPmiVisibility);
    procedure ShowButtons(lBtnRec: PBitBtnRec; aSender: TObject);
    procedure SGRemoveEmptyRows(aSender: TObject);
    procedure ClearMainView(aScrollBox: Pointer);
    procedure SgSetState(SgRec: PStringGridRec; StringGridState: String);
    function IsFileInUse(const FileName: String): Boolean;
    procedure SaveColumnNames(aSender: TObject; sgData: PGetColumnNameRec);
    procedure SetStringGridWidth(anObj: TObject);


    property Model: IModelMain read get_Model; // TODO: write set_Model;
    property Provider: IobsProvider read get_Provider write set_Provider;
    property TrxMan: ITransactionManager read get_TrxMan;
  end; { IPresenterMain }


  { this is the 'contract' the view has to fulfill, for us to work with it }
  IViewMain = interface(ICorba)['{5AC3C283-C7EB-437D-8A72-3A0BD7A47B1C}']
    function get_Observer: IobsSubscriber; 
    function get_Presenter: IPresenterMain;
    procedure set_Observer(aValue: IobsSubscriber);
    procedure set_Presenter(aValue: IPresenterMain);
    procedure HandleObsNotify(aReason: ptrint; aNotifyClass: TObject; UserData: pointer);
    { mainly here for when implementing console-views for the same back-end / engine }
    procedure Show; // TForm implements it too

    property Observer: IobsSubscriber read get_Observer write set_Observer;
    property Presenter: IPresenterMain read get_Presenter write set_Presenter;
  end; { IViewMain }


  { IViewNewItem }

  IViewNewItem= interface(ICorba)['{3BD72226-516D-4049-9CB5-B429D5E39FD2}']
    procedure HandleObsNotify(aReason: ptrint; aNotifyClass: TObject; UserData: pointer);

  end;

{$interfaces com}

implementation


end.

