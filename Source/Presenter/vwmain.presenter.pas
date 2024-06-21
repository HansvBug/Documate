unit vwmain.presenter;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils,
  obs_prosu, vwmain.intf, vwmain.decl, vwmain.model, vwmain.trxman;

type
  { alias from vwmain.trxman }
  TTransactionManager = vwmain.trxman.TTransactionManager;
  TDirTransaction = vwmain.trxman.TDirTransaction; { alias for: Class used for creating directories (Transaction object) }
  TSettingstransaction = vwmain.trxman.TSettingstransaction;
  TCreateDbFileTransaction = vwmain.trxman.TCreateDbFileTransaction;
  TOpenDbFilePrepareViewTransaction = vwmain.trxman.TOpenDbFilePrepareViewTransaction;
  TOpenDbFileGetDataTransaction = vwmain.trxman.TOpenDbFileGetDataTransaction;

  TCreateAppDbMaintainerTransaction = vwmain.trxman.TCreateAppDbMaintainerTransaction;
  TItemTransaction = vwmain.trxman.TItemTransaction;
  TSaveChangesTransaction = vwmain.trxman.TSaveChangesTransaction;
  TCheckboxToggleTransaction = vwmain.trxman.TCheckboxToggleTransaction;

  TGetColumnNamesTransaction = vwmain.trxman.TGetColumnNamesTransaction;

  { TPresenter }

  TPresenter = class(TObject, IPresenter)
    private
      FProvider: TobsProvider;
      FModel: TModel;
      FTrxMan: TTransactionManager;
      FLogFile: String;

      function get_LogFile: String;
      function get_Provider: IobsProvider;
      function get_TrxMan: ITransactionManager;

      function Obj: TObject;
      procedure set_LogFile(AValue: String);
    public
      constructor Create;
      destructor Destroy; override;
      procedure GetStaticTexts(aRegion: word);
      procedure SetStatusbartext(aText: string; panel: word);
      procedure ReadSettings(FormName: String);
      procedure SetAppInfo;
      procedure StartLogging(logfile : string);
      procedure StopLogging;
      procedure WriteToLog(aLogAction : TLoggingAction; LogText: String);
      procedure ClearMainView(aScrollBox: Pointer);

      function ExtractNumberFromString(const Value: string): String;
      procedure SetStringGridHeaderFontStyle(aSender: TObject; aFontStyle: Integer);
      procedure SGRemoveEmptyRows(aSender: TObject);
      procedure SGAddRow(aSender: TObject; AddExtraRow: Boolean);
      procedure SgSetState(SgRec: PStringGridRec; StringGridState: String);
      procedure ActiveStrgridCell(aSender: TObject; ViaAddButton : Boolean);
      procedure StringGridOnPrepareCanvas(aSender: TObject; aCol, aRow: Integer; ShowRelationColor: Boolean);
      procedure StringGridOnSelectCell(aSender: TObject; sgSelect: PStringGridSelect);
      procedure StringGridOnDrawCell(aSender: TObject; sgSelect: PStringGridSelect);

      procedure ValidateCellEntry(sgObject, BtnObject: TObject; aText: string; aRow: Integer);

      procedure ShowButtons(lBtnRec: PBitBtnRec; aSender: TObject);
      procedure SetPmiState(SetPmiState : TPmiVisibility);

      // Config view
      procedure SaveColumnNames(aSender: TObject; sgData: PGetColumnNameRec);
      procedure PrepareCloseDb;

      property Provider: IobsProvider read get_Provider;
      property TrxMan: ITransactionManager read get_TrxMan;
      property LogFile : String read get_LogFile write set_LogFile;
  end;

implementation

{ TPresenter }

function TPresenter.get_Provider: IobsProvider;
begin
  Result := FProvider;
end;

function TPresenter.get_LogFile: String;
begin
  Result := FLogFile;
end;

procedure TPresenter.set_LogFile(AValue: String);
begin
  FLogFile := AValue;
end;

function TPresenter.get_TrxMan: ITransactionManager;
begin
  Result := FTrxMan;
end;

function TPresenter.Obj: TObject;
begin
  Result := Self;
end;

constructor TPresenter.Create;
begin
  inherited Create;
  FProvider := CreateObsProvider;
  FModel := TModel.Create(Self);  // Presenter owns the model.
  FTrxMan := TTransactionManager.Create(Self, FModel);
end;

destructor TPresenter.Destroy;
begin
  FTrxMan.Free;
  FModel.Free;
  FProvider.Free;
  inherited Destroy;
end;

procedure TPresenter.GetStaticTexts(aRegion: word);
var
  lstaRec: TStaticTextsAll;
begin
  case aRegion of
    gstAll: if Assigned(FModel) then begin
              lstaRec := FModel.FetchViewTextsFull;
              fProvider.NotifySubscribers(prStaticTexts, Self, @lstaRec);
            end;
    end;
end;

procedure TPresenter.SetStatusbartext(aText: string; panel: word);
var
  lsbpRec : TStatusbarPanelText;
begin
  lsbpRec := FModel.SetStatusbartext(aText, panel);
  fProvider.NotifySubscribers(prStatusBarPanelText,Self,@lsbpRec);
end;

procedure TPresenter.ReadSettings(FormName: String);
var
  lStrx : TSettingsTransaction;
begin
  lStrx := TrxMan.StartTransaction(msReadSettings) as TSettingsTransaction;
  try
    lStrx.SettingsLocationAndFileName := ExtractFilePath(ParamStr(0)) + adSettings + PathDelim + afSettings;
    lStrx.FormName := FormName;

    TrxMan.CommitTransaction;
  except
    TrxMan.RollbackTransaction;
  end; // mandatory, does NOTHING and _frees_ transaction
end;

procedure TPresenter.SetAppInfo;
begin
  FModel.ApplicationName := Application_name;
  FModel.ApplicationVersion := Application_version;
  FModel.ApplicationBuildate := Application_buildddate;
end;

procedure TPresenter.StartLogging(logfile: string);
begin
  if FLogFile = '' then
    FLogFile := LogFile + adLogging + PathDelim + afLogging;
  FModel.StartLogging(FLogFile);
end;

procedure TPresenter.StopLogging;
begin
  FModel.StopLogging;
end;

procedure TPresenter.WriteToLog(aLogAction: TLoggingAction; LogText: String);
begin
  FModel.WriteToLog(aLogAction, LogText);
end;

procedure TPresenter.ClearMainView(aScrollBox: Pointer);
var
  lrec : TClearPtrData;
begin
  lrec.cpdObject := aScrollBox;
  lrec := FModel.ClearMainView(lrec);
  fProvider.NotifySubscribers(prClearMainView, Self, @lrec);
end;

function TPresenter.ExtractNumberFromString(const Value: string): String;
begin
  Result := FModel.ExtractNumberFromString(Value);
end;

procedure TPresenter.SetStringGridHeaderFontStyle(aSender: TObject; aFontStyle: Integer);
var
  lsgRec: TStringGridRec;
begin
  lsgRec := FModel.SetStringGridHeaderFontStyle(aFontStyle);
  FProvider.NotifySubscribers(prSgHeaderFontStyle,aSender,@lsgRec);
end;

procedure TPresenter.SGRemoveEmptyRows(aSender: TObject);
begin
  FProvider.NotifySubscribers(prSgRemoveEmptyRows, aSender, nil);
end;

procedure TPresenter.SGAddRow(aSender: TObject; AddExtraRow: Boolean);
var
  lsgRec: TStringGridRec;
begin
  lsgRec.sgAddExtraRow := AddExtraRow;
  FProvider.NotifySubscribers(prSgAddRow, aSender, @lsgRec);
end;

procedure TPresenter.SgSetState(SgRec: PStringGridRec; StringGridState: String);
var
  lsgRec : TStringGridRec;
begin
  lsgRec := FModel.AdjustStringGrid(SgRec, StringGridState);
  fProvider.NotifySubscribers(prSgAdjust, nil, @lsgRec);
end;

procedure TPresenter.ActiveStrgridCell(aSender: TObject; ViaAddButton : Boolean);
begin
  FModel.ActiveStrgridCell(aSender, ViaAddButton);
end;

procedure TPresenter.StringGridOnPrepareCanvas(aSender: TObject; aCol,
  aRow: Integer; ShowRelationColor: Boolean);
begin
  Fmodel.StringGridOnPrepareCanvas(aSender, aCol, aRow, ShowRelationColor);
end;

procedure TPresenter.StringGridOnDrawCell(aSender: TObject;
  sgSelect: PStringGridSelect);
begin
  FModel.StringGridOnDrawCell(aSender, sgSelect);
end;


procedure TPresenter.StringGridOnSelectCell(aSender: TObject; sgSelect: PStringGridSelect);
begin
  Fmodel.StringGridOnSelectCell(aSender, sgSelect);
end;

procedure TPresenter.ValidateCellEntry(sgObject, BtnObject: TObject; aText: string; aRow: Integer);
var
  lRec : TSaveBtn;
begin
  lRec := FMOdel.ValidateCellEntry(sgObject, aText, aRow);
  FProvider.NotifySubscribers(prEnableSaveButton, BtnObject, @lRec);
end;

procedure TPresenter.ShowButtons(lBtnRec: PBitBtnRec; aSender: TObject);
begin
  lBtnRec^.btnObject := aSender;
  FProvider.NotifySubscribers(prBitBtnShow, aSender, lBtnRec);
end;

procedure TPresenter.SetPmiState(SetPmiState: TPmiVisibility);
var
  lRec : TPmiVisibility;
begin
  lRec := SetPmiState;
  fProvider.NotifySubscribers(prPmiStatus, nil, @lRec);
end;

procedure TPresenter.SaveColumnNames(aSender: TObject; sgData: PGetColumnNameRec);
var
  lRec : TGetColumnNameRec;
begin
  lRec := FModel.SaveColumnNames(sgData);
  FProvider.NotifySubscribers(prSaveColumnNames, aSender, @lRec);
end;

procedure TPresenter.PrepareCloseDb;
begin
  FModel.PrepareCloseDb;
end;


end.

