unit ViewConfigure;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls, Grids,
  obs_prosu, vwmain.intf, vwmain.decl, vwmain.presenter, vwmain.types;

type

  { TfrmViewConfigure }

  TfrmViewConfigure = class(TForm, IView)
    btnClose: TButton;
    btnColumnsave: TButton;
    chkActiveLogging: TCheckBox;
    chkAppenLogging: TCheckBox;
    gbLogging: TGroupBox;
    GroupBoxColumnnames: TGroupBox;
    PageControlConfigure: TPageControl;
    StringGridColumnNames: TStringGrid;
    TabSheetAppDb: TTabSheet;
    TabSheetMiscellaneous: TTabSheet;
    procedure btnCloseClick(Sender: TObject);
    procedure btnColumnsaveClick(Sender: TObject);
    procedure chkActiveLoggingChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StringGridColumnNamesSelectCell(Sender: TObject; aCol,
      aRow: Integer; var CanSelect: Boolean);
  private
    FSubscriber : TobsSubscriber;  // Holds the Observer.
    FPresenter : TPresenter;       // Holds the Presenter.
    FCanClose    : Boolean;
    FOrgColNames: AllColumnNames;

    function get_Presenter: IPresenter;
    function get_Subscriber: IobsSubscriber;
    function Obj: TObject;
    procedure set_Presenter(AValue: IPresenter);
    procedure DoReadFormState({%H-}anObj: TObject; Settings: PSettingsRec);
    procedure DoGetColumnnames(anObj: TObject; Collnames: PGetColumnNameRec);
    procedure DosaveColumnNames(anObj: TObject; Collnames: PGetColumnNameRec);
    procedure WriteSettings;
    procedure ReadFormState(FormName: String);
    procedure StoreFormstate;
    function CheckFormIsEntireVisible(Rect: TRect): TRect;
  protected
    procedure HandleObsNotify(aReason: TProviderReason;aNotifyClass: TObject;UserData: pointer);
    procedure DoSetStaticTexts(aTextRec: PStaticTextsAll);
    procedure DoReadSettings({%H-}anObj: TObject; Settings: PSettingsRec);
  public
    procedure GetAllColumNamesForStringgrid;

    property Subscriber: IobsSubscriber read get_Subscriber;
    property Presenter: IPresenter read get_Presenter write set_Presenter; // Set via the main form
  end;

var
  frmViewConfigure: TfrmViewConfigure;

implementation

{$R *.lfm}

{ TfrmViewConfigure }

function TfrmViewConfigure.get_Presenter: IPresenter;
begin
  Result := FPresenter;
end;

function TfrmViewConfigure.get_Subscriber: IobsSubscriber;
begin
  Result := FSubscriber;
end;

function TfrmViewConfigure.Obj: TObject;
begin
  Result := self;
end;

procedure TfrmViewConfigure.set_Presenter(AValue: IPresenter);
begin
  { This is called when the view is created. }
  if aValue = nil then begin
    if Assigned(fPresenter) then FPresenter.Provider.UnSubscribe(FSubscriber);    // ==> Provider = property from TPresenter. LET OP: Hier koppel je de  HandleObsNotify
    FPresenter.Free;
    FPresenter:= nil;
    exit;
  end;
  if TPresenter(aValue.Obj) <> fPresenter then begin
    if Assigned(FPresenter) then fPresenter.Provider.UnSubscribe(FSubscriber); { we can't detach nil }
    FPresenter.Free;
    if Assigned(aValue) then begin
      FPresenter:= TPresenter(aValue.Obj);
      FPresenter.Provider.Subscribe(FSubscriber);
      FPresenter.GetStaticTexts(gstAll);  // Get All static texts
    end;
  end;
end;

procedure TfrmViewConfigure.DoReadFormState(anObj: TObject;
  Settings: PSettingsRec);
var
  LastWindowState : TWindowstate;
begin
  if (Settings^.setSucces)  and (Settings^.setFrmName = fnConfigure) then begin
    LastWindowState := TWindowState(Settings^.setFrmWindowState);
    if LastWindowState = wsMaximized then begin
      BoundsRect := Bounds(
        Settings^.setFrmRestoredLeft,
        Settings^.setFrmRestoredTop,
        Settings^.setFrmRestoredWidth,
        Settings^.setFrmRestoredHeight);

      WindowState := wsMaximized;
    end
    else begin
      WindowState := wsNormal;
      BoundsRect := Bounds(
        Settings^.setFrmLeft,
        Settings^.setFrmTop,
        Settings^.setFrmWidth,
        Settings^.setFrmHeight);

      BoundsRect := CheckFormIsEntireVisible(BoundsRect);
    end;
  end;
end;

procedure TfrmViewConfigure.DoGetColumnnames(anObj: TObject; Collnames: PGetColumnNameRec);
var
  i : Integer;
  counter : Integer;
begin
  if Collnames = nil then exit;
  StringGridColumnNames.Enabled := False;

  Counter := 2;
  with PGetColumnNameRec(Collnames)^ do begin
    if NameView = 'ConfigView' then begin
      if (AllColNames <> Nil) and (length(AllColNames)>0) then begin
        FOrgColNames:= AllColNames; // FOrgColNames is used to detect changes is the column names.
        StringGridColumnNames.Enabled := True;
        for i:=0 to Length(AllColNames)-1 do begin
          with StringGridColumnNames Do begin
            RowCount := Counter;
            Cells[0,counter-1] := AllColNames[i].Key;
            Cells[1,counter-1] := AllColNames[i].Value;
            Inc(Counter);
          end;
        end;
      end;
    end
    else begin
      StringGridColumnNames.Enabled := False;
    end;
  end;
end;

procedure TfrmViewConfigure.DosaveColumnNames(anObj: TObject;
  Collnames: PGetColumnNameRec);
begin
  with PGetColumnNameRec(Collnames)^ do begin
    if Success Then begin
      btnColumnsave.Enabled := False;
      FCanClose := True;
    end
    else begin
      btnColumnsave.Enabled := True;
      FCanClose := False;
    end;
  end;
end;

procedure TfrmViewConfigure.WriteSettings;
var
  lSettingsTrx : TSettingstransaction;
begin
  lSettingsTrx := FPresenter.TrxMan.StartTransaction(msUpdateSettings) as TSettingsTransaction;
  try
    lSettingsTrx.SettingsLocationAndFileName := ExtractFilePath(ParamStr(0)) + adSettings + PathDelim + afSettings;
    lSettingsTrx.FormName := fnConfigure;  // Determines which settings are saved.
    lSettingsTrx.ActivateLogging := chkActiveLogging.Checked;
    lSettingsTrx.AppendLogging :=  chkAppenLogging.Checked;
    //...

    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmViewConfigure.ReadFormState(FormName: String);
var
  lSettingsTrx : TSettingstransaction;
begin
  lSettingsTrx := FPresenter.TrxMan.StartTransaction(msReadFormState) as TSettingstransaction;
  try
    lSettingsTrx.SettingsLocationAndFileName := ExtractFilePath(ParamStr(0)) + adSettings + PathDelim + afSettings;
    lSettingsTrx.FormName := FormName;

    FPresenter.TrxMan.CommitTransaction;
  except fPresenter.TrxMan.RollbackTransaction; end;
end;

procedure TfrmViewConfigure.StoreFormstate;
var
  lSettingsTrx : TSettingstransaction;
begin
  lSettingsTrx := FPresenter.TrxMan.StartTransaction(msStoreFormState) as TSettingsTransaction;
  try
    lSettingsTrx.SettingsLocationAndFileName := ExtractFilePath(ParamStr(0)) + adSettings + PathDelim + afSettings;
    lSettingsTrx.FormName := fnConfigure;
    lSettingsTrx.FormWindowstate := integer(Windowstate);
    lSettingsTrx.FormTop := Top;
    lSettingsTrx.FormLeft := Left;
    lSettingsTrx.FormHeight := Height;
    lSettingsTrx.FormWidth := Width;
    lSettingsTrx.FormRestoredTop := RestoredTop;
    lSettingsTrx.FormRestoredLeft := RestoredLeft;
    lSettingsTrx.FormRestoredHeight := RestoredHeight;
    lSettingsTrx.FormRestoredWidth := RestoredWidth;

    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
  end;
end;

function TfrmViewConfigure.CheckFormIsEntireVisible(Rect: TRect): TRect;
var
  aWidth: Integer;
  aHeight: Integer;
begin
  Result := Rect;
  aWidth := Rect.Right - Rect.Left;
  aHeight := Rect.Bottom - Rect.Top;

  if Result.Left < (Screen.DesktopLeft) then begin
    Result.Left := Screen.DesktopLeft;
    Result.Right := Screen.DesktopLeft + aWidth;
  end;
  if Result.Right > (Screen.DesktopLeft + Screen.DesktopWidth) then begin
    Result.Left := Screen.DesktopLeft + Screen.DesktopWidth - aWidth;
    Result.Right := Screen.DesktopLeft + Screen.DesktopWidth;
  end;
  if Result.Top < Screen.DesktopTop then begin
    Result.Top := Screen.DesktopTop;
    Result.Bottom := Screen.DesktopTop + aHeight;
  end;
  if Result.Bottom > (Screen.DesktopTop + Screen.DesktopHeight) then begin
    Result.Top := Screen.DesktopTop + Screen.DesktopHeight - aHeight;
    Result.Bottom := Screen.DesktopTop + Screen.DesktopHeight;
  end;
end;

procedure TfrmViewConfigure.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmViewConfigure.btnColumnsaveClick(Sender: TObject);
var
  lRec : TGetColumnNameRec;
begin
  Screen.Cursor := crHourGlass;
  FPresenter.SetStatusbartext('Opslaan aangepaste kolomnamen...', 0);

  lRec.aGrid := StringGridColumnNames;
  FPresenter.SaveColumnNames(btnColumnsave, @lRec);

  FPresenter.SetStatusbartext('', 0);
  Screen.Cursor := crDefault;
end;

procedure TfrmViewConfigure.chkActiveLoggingChange(Sender: TObject);
begin
  if chkActiveLogging.Checked then begin
    chkAppenLogging.Enabled := True;
    FPresenter.StartLogging(FPresenter.LogFile);
  end
  else begin
    chkAppenLogging.Enabled := False;
    chkAppenLogging.Checked := False;
    FPresenter.StopLogging;
  end;
  WriteSettings;
end;

procedure TfrmViewConfigure.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  WriteSettings;
  StoreFormstate;
end;

procedure TfrmViewConfigure.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  buttonSelected : Integer;
begin
  if not FCanClose then begin
    buttonSelected := MessageDlg('De wijzigingen in de kolomnamen zijn niet opgeslagen.' + sLineBreak + 'Doorgaan zonder op te slaan?' ,mtConfirmation, [mbYes,mbCancel], 0);
    if buttonSelected = mrYes then begin
      CanClose := True;
    end
    else begin
      CanClose := False;
    end;
  end;
end;

procedure TfrmViewConfigure.FormCreate(Sender: TObject);
begin
  FSubscriber := CreateObsSubscriber(@HandleObsNotify);
  StringGridColumnNames.OnSelectCell := nil;
  FCanClose := True;
end;

procedure TfrmViewConfigure.FormDestroy(Sender: TObject);
begin
  if Assigned(FPresenter) then begin
    FPresenter.Provider.UnSubscribe(FSubscriber);
    FSubscriber.Free;
  end;
end;

procedure TfrmViewConfigure.FormShow(Sender: TObject);
begin
  Fpresenter.ReadSettings(fnConfigure);
  if not chkActiveLogging.Checked then
    chkAppenLogging.Enabled := False
  else
    chkAppenLogging.Enabled := True;

  ReadFormState(fnConfigure);  // Get form position.
  GetAllColumNamesForStringgrid;
  StringGridColumnNames.OnSelectCell := @StringGridColumnNamesSelectCell;
end;

procedure TfrmViewConfigure.StringGridColumnNamesSelectCell(Sender: TObject;
  aCol, aRow: Integer; var CanSelect: Boolean);
var
  i : Integer;
  mustSave : Boolean;
begin
  mustSave := False;
  for i:=0 to Length(FOrgColNames) - 1 do begin
    if StringGridColumnNames.Cells[1,i+1] <> FOrgColNames[i].Value then begin
      mustSave := True;
      FCanClose := False;
      break;
    end;
  end;

  if mustSave then begin
    btnColumnsave.Enabled := True;
  end
  else begin
    btnColumnsave.Enabled := False;
  end;
end;


procedure TfrmViewConfigure.HandleObsNotify(aReason: TProviderReason;
  aNotifyClass: TObject; UserData: pointer);
begin
  case aReason of
    prStaticTexts: DoSetStaticTexts(UserData);
    prReadsettings: DoReadsettings(aNotifyClass,UserData);
    prReadFormState : DoReadFormState(aNotifyClass,UserData);
    prGetColumnNames : DoGetColumnnames(aNotifyClass,UserData);
    prSaveColumnNames: DosaveColumnNames(aNotifyClass,UserData);
  end;
end;

procedure TfrmViewConfigure.DoSetStaticTexts(aTextRec: PStaticTextsAll);
begin
  with aTextRec^ do begin
    Caption := staVwConfigure;
    btnClose.caption := staOptionsBtnCloseCaption;
    TabSheetAppDb.Caption := staTbsAppDdCaption;
    TabSheetMiscellaneous.Caption := staTbsMiscellaneousCaption;
    gbLogging.Caption := staGbLoggingCaption;
    chkActiveLogging.Caption := staChkActiveLoggingCaption;
    chkAppenLogging.Caption := staChkAppendLoggingCaption;
    GroupBoxColumnNames.Caption := staGroupBoxColumnnamesCaption;
    btnColumnSave.Caption := stabtnColumnSaveCaption;

    StringGridColumnNames.Cells[0,0] := staSgColLevel;
    StringGridColumnNames.Cells[1,0] := staSgColName;
  end;
end;

procedure TfrmViewConfigure.DoReadSettings(anObj: TObject;
  Settings: PSettingsRec);
begin
  if Settings^.setSucces then begin
    chkActiveLogging.Checked := Settings^.setActivateLogging;
    chkAppenLogging.Checked := Settings^.setAppendLogging
  end;
end;

procedure TfrmViewConfigure.GetAllColumNamesForStringgrid;
var
  lRec : TGetColumnNamesTransaction;
begin
  try
    lRec := FPresenter.TrxMan.StartTransaction(msGetColumnnames) as TGetColumnNamesTransaction;
    lrec.NameView := 'ConfigView';
    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
    FPresenter.SetStatusbartext('Fout bij ophalen Kolomnamen.',0);
    screen.Cursor := crDefault;
  end;
end;

end.

