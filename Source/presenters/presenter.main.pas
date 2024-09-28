unit presenter.main;
{$mode ObjFPC}{$H+}
{$define dbg}
interface
uses classes,sysutils,obs_prosu, istrlist, model.base, model.intf, model.decl, presenter.trax,
  model.main;

type

  { TPresenterMain }
  TPresenterMain = class(TObject,IPresenterMain)
  private
    fInternalMsg: IStringList; ///<- i18n
    fModel: IModelMain;
    fProvider: IobsProvider;
    fTrxMgr: TTransactionManager;
    function get_Model: IModelMain;
    function get_Provider: IobsProvider;
    function get_TrxMan: ITransactionManager;
    function Obj: TObject;
    procedure set_Provider(aValue: IobsProvider);
  public
    constructor Create(const aRootPath: shortstring = '');
    destructor Destroy; override;
    procedure GetStaticTexts(const aSection: string);
    function GetstaticText(const aView, aText: string): string;
    procedure RefreshTextCache(const aSection,aLangStr: string);
    property Model: IModelMain read get_Model; // TODO: write set_Model; if needed...

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


    property Provider: IobsProvider read get_Provider write set_Provider;
    property TrxMan: ITransactionManager read get_TrxMan;
  end; { TPresenterMain }

function CreatePresenterMain(const aRootPath: shortstring = ''): IPresenterMain;

implementation

function CreatePresenterMain(const aRootPath: shortstring): IPresenterMain;
begin { the constructor knows what to do if/with an empty string :o) }
  Result:= TPresenterMain.Create(aRootPath);
end;

{ TPresenterMain }
function TPresenterMain.get_Model: IModelMain;
begin
  Result:= fModel;
end;

function TPresenterMain.get_Provider: IobsProvider;
begin
  Result:= fProvider;
end;

function TPresenterMain.get_TrxMan: ITransactionManager;
begin
  Result:= fTrxMgr;
end;

function TPresenterMain.Obj: TObject;
begin
  Result:= Self;
end;

procedure TPresenterMain.set_Provider(aValue: IobsProvider);
begin
  if Assigned(fProvider) then begin
    fProvider.Obj.Free;
    fProvider:= nil;
  end;
  fProvider:= aValue;
end;

constructor TPresenterMain.Create(const aRootPath: shortstring);
var
  ldummy: integer;
begin
  inherited Create; { below we leave an option open for user to provide root-path in app-param }
  fProvider:= obs_prosu.CreateObsProvider; { as early as posssible, we need comms }
  if aRootPath <> '' then fModel:= TModelMain.Create(Self,aRootPath)
  else fModel:= TModelMain.Create(Self,ExtractFilePath(ParamStr(0))); // should include \/ trailing
  fInternalMsg:= fModel.GetStaticTexts(ClassName,ldummy); ///<- i18n
  fTrxMgr:= TTransactionManager.Create(Self,fModel);
end;

destructor TPresenterMain.Destroy;
begin
  fTrxMgr.Free; fTrxMgr:= nil;         { it's a class :o) }
  fInternalMsg:= nil;                  { it's com, so not strictly necessary :o) }
  fModel.Obj.Free; fModel:= nil;       { it's corba :o) }
  fProvider.Obj.Free; fProvider:= nil; { it's corba :o) }
  inherited Destroy;
end;

procedure TPresenterMain.GetStaticTexts(const aSection: string); //=^
var
  lsl: IStringList;
  lt: integer;
  lreason: TProviderReason;
begin { due to usage of 'out'-param, 'lt' can't be anything else than integer }
  lsl:= fModel.GetStaticTexts(aSection,lt);
  case lt of
    0: begin
       lreason:= prMainStaticTexts; // remember to correlate with model.sects
       { below we make use of the fInternalMsg stringlist to support i18n }
       fProvider.NotifySubscribers(prStatus,nil,Str2Pch(lsl.Values['msgUpnRun'])); ///<-i18n
    end;
    1: lreason:= prConfigStaticTexts; // i.e.: the more units = more selectors
    3: lreason:= prConfigStaticHints;
    4: lreason:= prNewItemStaticTexts;
    //4:
  end;
  fProvider.NotifySubscribers(lreason,nil,lsl);
  { below we make use of the fInternalMsg stringlist to support i18n }
  fProvider.NotifySubscribers(prStatus,nil,Str2Pch(lsl.Values['msgUpnRun'])); ///<-i18n
end;

function TPresenterMain.GetstaticText(const aView, aText: string): string;
var
  ldummy: integer;
  statText: string;
begin
  fInternalMsg:= fModel.GetStaticTexts(aView, ldummy);
  statText:= fInternalMsg.Values[aText];
  result:= statText;
end;

procedure TPresenterMain.RefreshTextCache(const aSection,aLangStr: string); //=^
var
  ldummy: integer;
begin
  Lang:= trim(aLangStr);
  fModel.ReloadTextCache;
  fInternalMsg.AssignEx(fModel.GetStaticTexts(ClassName,ldummy)); /// clears first
  GetStaticTexts(aSection);
end;

procedure TPresenterMain.SetStatusbarText(aText: string; panel: word);
var
  lstbRec : TStatusbarPanelText;
  ldummy: integer;
  PanelText: String;
begin
  fInternalMsg:= fModel.GetStaticTexts('view.main.StatusbarTexts', ldummy);
  if aText <> '' then
    PanelText:= fInternalMsg.Values[aText];
  if PanelText <> '' then
    lstbRec := FModel.SetStatusbartext(PanelText, panel)
  else
    lstbRec := FModel.SetStatusbartext(aText, panel);

  fProvider.NotifySubscribers(prStatusBarPanelText, Self, @lstbRec);
end;

procedure TPresenterMain.StartLogging;
begin
  fModel.StartLogging;
end;

procedure TPresenterMain.StopLogging;
begin
  FModel.StopLogging;
end;

procedure TPresenterMain.WriteToLog(const aSection, aLogAction: String;
  LogText: String);
var
  LogString: String;
  ldummy: integer;
  logSection: string;
begin
  case aSection of
    'view.main': begin
       logSection := 'view.main.logging';
    end;
  end;

  fInternalMsg:= fModel.GetStaticTexts(logSection, ldummy);
  LogString:= fInternalMsg.Values[LogText];
  FModel.WriteToLog(aLogAction, LogString);
end;

procedure TPresenterMain.SwitchLanguage(aSection: String);
var
  ldummy: integer;
begin
  fModel.SwitchLanguage;
  fInternalMsg:= fModel.GetStaticTexts(ClassName,ldummy);
  GetStaticTexts(aSection);
end;

procedure TPresenterMain.PrepareCloseDb;
begin
  FModel.PrepareCloseDb;
end;

procedure TPresenterMain.SetStatusbarPanelsWidth(Sender: TObject; stbWithd,
  lpWidth, rpWidth: Integer);
var
  lRec: TStbPanelsSize;
begin
  lRec:= fModel.SetStatusbarPanelsWidth(stbWithd, lpWidth,rpWidth);
  fProvider.NotifySubscribers(prStatusBarPanelWidth, Sender, @lRec);
end;

procedure TPresenterMain.DbResetAutoIncrementAll(dbFile: String);
begin
  FModel.DbResetAutoIncrementAll(dbFile);
end;

procedure TPresenterMain.DbCreateCopy(dbFile, DbFolder, dbBackUpFolder: string);
begin
  FModel.DbCreateCopy(dbFile, DbFolder, dbBackUpFolder);
end;

procedure TPresenterMain.DbOptimize(dbFile: String);
begin
  FModel.DbOptimize(DbFile);
end;

procedure TPresenterMain.DbCompress(dbFile: String);
begin
  FModel.DbCompress(DbFile);
end;

function TPresenterMain.ExtractNumberFromString(const Value: string): String;
begin
  Result := FModel.ExtractNumberFromString(Value);
end;

procedure TPresenterMain.SGAddRow(aSender: TObject; AddExtraRow: Boolean);
var
  lsgRec: TStringGridRec;
begin
  lsgRec.sgAddExtraRow := AddExtraRow;
  FProvider.NotifySubscribers(prSgAddRow, aSender, @lsgRec);
end;

procedure TPresenterMain.ActiveStrgridCell(aSender: TObject;
  ViaAddButton: Boolean);
begin
  FModel.ActiveStrgridCell(aSender, ViaAddButton);
end;

procedure TPresenterMain.StringGridOnPrepareCanvas(aSender: TObject; aCol,
  aRow: Integer; ShowRelationColor: Boolean);
begin
  Fmodel.StringGridOnPrepareCanvas(aSender, aCol, aRow, ShowRelationColor);
end;

procedure TPresenterMain.StringGridOnSelectCell(aSender: TObject;
  sgSelect: PStringGridSelect);
begin
  Fmodel.StringGridOnSelectCell(aSender, sgSelect);
end;

procedure TPresenterMain.StringGridOnDrawCell(aSender: TObject;
  sgSelect: PStringGridSelect);
begin
  FModel.StringGridOnDrawCell(aSender, sgSelect);
end;

procedure TPresenterMain.SetStringGridHeaderFontStyle(aSender: TObject;
  aFontStyle: Integer);
var
  lsgRec: TStringGridRec;
begin
  lsgRec := FModel.SetStringGridHeaderFontStyle(aFontStyle);
  FProvider.NotifySubscribers(prSgHeaderFontStyle,aSender,@lsgRec);
end;

procedure TPresenterMain.ValidateCellEntry(sgObject, BtnObject: TObject;
  aText: string; aRow: Integer);
var
  lRec : TSaveBtn;
begin
  lRec := FMOdel.ValidateCellEntry(sgObject, aText, aRow);
  FProvider.NotifySubscribers(prEnableSaveButton, BtnObject, @lRec);
end;

procedure TPresenterMain.SetPmiState(SetPmiState: TPmiVisibility);
var
  lRec : TPmiVisibility;
begin
  lRec := SetPmiState;
  fProvider.NotifySubscribers(prPmiStatus, nil, @lRec);
end;

procedure TPresenterMain.ShowButtons(lBtnRec: PBitBtnRec; aSender: TObject);
begin
  lBtnRec^.btnObject := aSender;
  FProvider.NotifySubscribers(prBitBtnShow, aSender, lBtnRec);
end;

procedure TPresenterMain.SGRemoveEmptyRows(aSender: TObject);
begin
  FProvider.NotifySubscribers(prSgRemoveEmptyRows, aSender, nil);
end;

procedure TPresenterMain.ClearMainView(aScrollBox: Pointer);
var
  lRec : TClearPtrData;
begin
  lRec.cpdObject := aScrollBox;
  lRec := FModel.ClearMainView(lrec);
  //fProvider.NotifySubscribers(prClearMainView, Self, @lRec);  // not used
end;

procedure TPresenterMain.SgSetState(SgRec: PStringGridRec;
  StringGridState: String);
var
  lsgRec : TStringGridRec;
begin
  lsgRec := FModel.AdjustStringGrid(SgRec, StringGridState);
  fProvider.NotifySubscribers(prSgAdjust, nil, @lsgRec);
end;

function TPresenterMain.IsFileInUse(const FileName: String): Boolean;
begin
  Result:= fModel.IsFileInUse(FileName);
end;

procedure TPresenterMain.SaveColumnNames(aSender: TObject;
  sgData: PGetColumnNameRec);
var
  lRec : TGetColumnNameRec;
begin
  lRec := FModel.SaveColumnNames(sgData);
  FProvider.NotifySubscribers(prSaveColumnNames, aSender, @lRec);
end;

procedure TPresenterMain.SetStringGridWidth(anObj: TObject);
begin
  FModel.SetStringGridWidth(anObj);
end;

end.
