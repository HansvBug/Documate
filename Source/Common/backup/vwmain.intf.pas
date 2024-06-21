unit vwmain.intf;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,obs_prosu, vwmain.decl,
  Settings;

type
  {$interfaces corba}
  IPresenter = interface; // forward not used yet  (nodig omdat anders IPresenter hieronder niet wordt geaccepteerd)

    { manages our transactions }

    { ITransactionManager }

    ITransactionManager = interface['{259E7374-453B-4829-B4D3-41EF99517B76}']
      procedure CommitTransaction;
      function InTransaction: boolean;
      function Obj: TObject;
      procedure RollbackTransaction;
      function StartTransaction(aModState: word): TTransaction;
    end;

  { IView }
  IView = interface['{36FA1780-2BB3-4207-99E5-0961BA75B7B0}']
    function get_Presenter: IPresenter;
    function get_Subscriber: IobsSubscriber;
    procedure set_Presenter(aValue: IPresenter);
    function Obj: TObject;
    procedure HandleObsNotify(aReason: TProviderReason;aNotifyClass: TObject;UserData: pointer);
    procedure ReadFormState(FormName: String);

    property Subscriber: IobsSubscriber read get_Subscriber;
    property Presenter: IPresenter read get_Presenter write set_Presenter;
  end;

  { IPresenter }
  IPresenter = interface['{48C70B90-A10A-4691-B8E8-JL6JFF35B7DD}']
    function get_LogFile: String;
//    function get_AppLocation: String;
    function get_Provider: IobsProvider;
    function get_TrxMan: ITransactionManager; // <--- HERE
    function Obj: TObject;
    procedure GetStaticTexts(aRegion: word);
    procedure SetStatusbartext(aText: string; panel: word);
    procedure SetAppInfo;
    procedure ReadSettings(FormName: String);
    procedure set_LogFile(AValue: String);
    procedure StartLogging(logfile : string);
    procedure StopLogging;
    procedure WriteToLog(aLogAction : TLoggingAction; LogText: String);
    procedure ClearMainView(aScrollBox: Pointer);

    function ExtractNumberFromString(const Value: string): String;
    procedure SetStringGridHeaderFontStyle(aSender: TObject; aFontStyle: Integer);
    procedure SGRemoveEmptyRows(aSender: TObject);
    procedure SGAddRow(aSender: TObject; AddExtraRow: Boolean);  // AddExtraRow is when this is activated via Addbutton
    procedure SgSetState(SgRec: PStringGridRec; StringGridState: String);
    procedure ActiveStrgridCell(aSender: TObject; ViaAddButton : Boolean);
    procedure StringGridOnPrepareCanvas(aSender: TObject; aCol, aRow: Integer; ShowRelationColor: Boolean);
    procedure StringGridOnSelectCell(aSender: TObject; sgSelect: PStringGridSelect);
    procedure StringGridOnDrawCell(aSender: TObject; sgSelect: PStringGridSelect);
    procedure PrepareCloseDb;

    procedure ShowButtons(lBtnRec: PBitBtnRec; aSender: TObject);
    procedure SetPmiState(SetPmiState : TPmiVisibility);

    procedure ValidateCellEntry(sgObject, BtnObject: TObject; aText: string; aRow: Integer);

    // Config view
    procedure SaveColumnNames(aSender : TObject; sgData : PGetColumnNameRec);



    property Provider: IobsProvider read get_Provider;
    property TrxMan: ITransactionManager read get_TrxMan; // <--- HERE
    property LogFile : String read get_LogFile write set_LogFile;
  end;

  { IModel represents data, logic & operations }
  IModel = interface['{B21912CB-A4EF-4C97-B11D-402EB7D596CD}']
    function get_AppBuildate: String;
    function get_AppName: String;
    function get_AppVersion: String;
    function get_BldComponents: TBuildComponents;
    function get_Settings: TSettings;
    procedure set_AppBuildate(AValue: String);
    procedure set_AppName(AValue: String);
    procedure set_AppVersion(AValue: String);
    procedure set_BldComponents(AValue: TBuildComponents);
    procedure set_settings(AValue: TSettings);
    function Obj: TObject;

    // Result is used (in the transaction manager) for the notification.
    function FetchViewTextsFull: TStaticTextsAll;
    function SetStatusbartext(aText: string; panel : Word): TStatusbarPanelText;
    function CreateDirs(const aRootDir: string;const aDirList: string = ''): TDirectoriesRec;
    function ReadSettings(SettingsFile, FormName: string) : TSettingsRec;
    function ReadFormState(SettingsFile, FormName: string): TSettingsRec;
    function WriteSettings : TSettingsRec;
    function StoreFormState : TSettingsRec;

    procedure StartLogging(LogFile : string);
    procedure StopLogging;
    procedure WriteToLog(aLogAction: TLoggingAction; LogText: String);

    function CreateDbFile(const aDir : string): TCreDbFileRec;
    function InsertDbMetaData(DbData : TCreDbFileRec): Boolean;

    function GetColumnCount(DbFileName: String) : Integer;
    procedure RemoveOwnComponents(DbFilerec : TOpenDbFilePrepareViewRec);
    function BuildAllComponents(DbFilerec : TOpenDbFilePrepareViewRec) : TOpenDbFilePrepareViewRec;
    function GetItems(Items: TOpenDbFileGetDataRec): TOpenDbFileGetDataRec;
    function ClearMainView(Objectdata: TClearPtrData): TClearPtrData;
    function CreateDbItemsMaintainer(Filename: string) : TOpenDbFilePrepareViewRec;

    procedure ActiveStrgridCell(aSender: TObject; ViaAddButton : Boolean);
    procedure StringGridOnPrepareCanvas(aSender: TObject; aCol, aRow: Integer; ShowRelationColor: Boolean);
    procedure StringGridOnSelectCell(aSender: TObject; sgSelect: Pointer);
    procedure StringGridOnDrawCell(aSender: TObject; sgSelect: Pointer);

    function ValidateCellEntry(sgObject: TObject; aText: string; aRow: Integer): TSaveBtn;

    function ExtractNumberFromString(const Value: string): String;
    function SetStringGridHeaderFontStyle(aFontStyle: Integer): TStringGridRec;
    function AdjustStringGrid(SgRec : PStringGridRec; StringGridState: String): TStringGridRec;
    function SetReadyRelation(cbToggled : PCheckBoxCellPosition) : TCheckBoxCellPosition;

    function AddNewItem(anItem : PtrItemObject): TItemObjectData;
    function UpdateItem(anItem : PtrItemObject): TItemObjectData;
    function DeleteItem(anItem : PtrItemObject): TItemObjectData;
    function SaveChanges(scRec : PSaveChangesRec): Boolean;

    // Config view
    function GetColumnNames(Items: TGetColumnNameRec): TGetColumnNameRec;
    function SaveColumnNames(sgData: PGetColumnNameRec) :TGetColumnNameRec;
    procedure PrepareCloseDb;

    property ApplicationName : String read get_AppName write set_AppName;
    property ApplicationVersion : String read get_AppVersion write set_AppVersion;
    property ApplicationBuildate : String read get_AppBuildate write set_AppBuildate;
    Property Settings : TSettings read get_Settings write set_settings;
    property BuildComponents : TBuildComponents read get_BldComponents write set_BldComponents;
  end;


implementation

end.

