unit view.configure;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Grids,
  obs_prosu, istrlist, model.intf, model.decl, presenter.main, presenter.trax;

type

  { TfrmConfigure }

  TfrmConfigure = class(TForm)
    btnClose: TButton;
    btnColumnSave: TButton;
    btnCompressDb: TButton;
    btnCopyDb: TButton;
    chkActiveLogging: TCheckBox;
    chkAppendLogging: TCheckBox;
    gbColumnnames: TGroupBox;
    gbLogging: TGroupBox;
    pgcConfigure: TPageControl;
    sgColumnNames: TStringGrid;
    tbsAppDb: TTabSheet;
    tbsMiscellaneous: TTabSheet;
    procedure btnCloseClick(Sender: TObject);
    procedure btnColumnSaveClick(Sender: TObject);
    procedure btnCompressDbClick(Sender: TObject);
    procedure btnCopyDbClick(Sender: TObject);
    procedure chkActiveLoggingChange(Sender: TObject);
    procedure chkAppendLoggingChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sgColumnNamesSelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private
    fPresenter: IPresenterMain;
    fSubscriber: IobsSubscriber;
    FCanClose    : Boolean;
    FOrgColNames: AllColumnNames;

    procedure ReadFormState;
    procedure StoreFormstate;
    function CheckFormIsEntireVisible(Rect: TRect): TRect;  // Duplicate with view.main
    procedure WriteSettings;
    procedure ReadSettings;
    procedure GetAllColumNamesForStringgrid;

  protected
    procedure SetStaticTexts(Texts: IStrings);
    procedure SetStaticHints(Texts: IStrings);
    procedure DoAppSettings({%H-}anObj: TObject; Settings: PSettingsRec);
    procedure DoGetColumnnames(anObj: TObject; Collnames: PGetColumnNameRec);
    procedure DoFormState({%H-}anObj: TObject; Settings: PSettingsRec);
    procedure DosaveColumnNames(anObj: TObject; Collnames: PGetColumnNameRec);
  public

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure HandleObsNotify(aReason: ptrint; aNotifyClass: TObject; UserData: pointer);

  end;

  function SetUpConfigureView(aPresenter: IPresenterMain): Boolean; // forward function

var
  frmConfigure: TfrmConfigure;

implementation

function SetUpConfigureView(aPresenter: IPresenterMain): Boolean;
begin
  with TfrmConfigure.Create(nil) do try
    fPresenter:= aPresenter;
    fPresenter.Provider.Subscribe(fSubscriber);
    fPresenter.GetStaticTexts(UnitName);
    fPresenter.GetStaticTexts('view.configure.hints');   // Get the hint texts.
    Result:= (ShowModal = mrOK);
  finally
    Free;
  end;
end;

{$R *.lfm}

{ TfrmConfigure }

procedure TfrmConfigure.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConfigure.btnColumnSaveClick(Sender: TObject);
var
  lRec : TGetColumnNameRec;
begin
  Screen.Cursor := crHourGlass;
  FPresenter.SetStatusbartext(fPresenter.GetstaticText(UnitName, 'SaveColumnNames'), 0);

  lRec.aGrid := sgColumnNames;
  FPresenter.SaveColumnNames(btnColumnsave, @lRec);

  FPresenter.SetStatusbartext('', 0);
  Screen.Cursor := crDefault;
end;

procedure TfrmConfigure.btnCompressDbClick(Sender: TObject);
begin
  screen.Cursor := crHourGlass;
  FPresenter.DbResetAutoIncrementAll(fPresenter.Model.DbFullFilename);
  FPresenter.DbOptimize(fPresenter.Model.DbFullFilename);
  FPresenter.DbCompress(fPresenter.Model.DbFullFilename);
  screen.Cursor := crDefault;
end;

procedure TfrmConfigure.btnCopyDbClick(Sender: TObject);
begin
  FPresenter.DbCreateCopy(fPresenter.Model.DbFullFilename, adDatabase, adBackUpFld);
end;

procedure TfrmConfigure.chkActiveLoggingChange(Sender: TObject);
begin
  chkAppendLogging.OnChange:= nil; // Ugly but prevents onchange of the append checkbox from being triggered.
  if chkActiveLogging.Checked then begin
    chkAppendLogging.Enabled := True;
  end
  else begin
    chkAppendLogging.Enabled := False;
    chkAppendLogging.Checked := False;
  end;

  chkAppendLogging.OnChange:= @chkAppendLoggingChange;
end;

procedure TfrmConfigure.chkAppendLoggingChange(Sender: TObject);
begin
  ShowMessage('You must stop and restart the application for this option to work.');
end;

procedure TfrmConfigure.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  WriteSettings;
  StoreFormstate;
end;

procedure TfrmConfigure.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  buttonSelected : Integer;
begin
  if not FCanClose then begin
    buttonSelected := MessageDlg(fPresenter.GetStaticText(UnitName, 'CanCloseMessage') + sLineBreak + fPresenter.GetStaticText(UnitName, 'CanCloseMessage2') ,mtConfirmation, [mbYes,mbCancel], 0);
    if buttonSelected = mrYes then begin
      CanClose := True;
    end
    else begin
      CanClose := False;
    end;
  end;
end;

procedure TfrmConfigure.FormCreate(Sender: TObject);
begin
  sgColumnNames.OnSelectCell := nil;
  pgcConfigure.ActivePage:= tbsMiscellaneous; // Set the active page.
end;

procedure TfrmConfigure.FormShow(Sender: TObject);
begin
  ReadSettings;
  ReadFormState;
  GetAllColumNamesForStringgrid;
  sgColumnNames.OnSelectCell := @sgColumnNamesSelectCell;
  FCanClose := True;

  if fPresenter.Model.DbFullFilename = '' then begin
    btnCompressDb.Enabled := False;
    btnCopyDb.Enabled := False;
  end
  else begin
    btnCompressDb.Enabled := True;
    btnCopyDb.Enabled := True;
  end;
end;

procedure TfrmConfigure.sgColumnNamesSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
var
  i : Integer;
  mustSave : Boolean;
begin
  mustSave := False;
  for i:=0 to Length(FOrgColNames) - 1 do begin
    if sgColumnNames.Cells[1,i+1] <> FOrgColNames[i].Value then begin
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

procedure TfrmConfigure.ReadFormState;
var
  lTrs : TSettingstransaction;
begin
  lTrs := FPresenter.TrxMan.StartTransaction(prAppSettings) as TSettingstransaction;
  try
    lTrs.ReadSettings:= True;
    lTrs.ReadFormState:= True;
    lTrs.FormName := UnitName;

    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmConfigure.StoreFormstate;
var
  lTrs : TSettingstransaction;
begin
  lTrs := FPresenter.TrxMan.StartTransaction(prAppSettings) as TSettingsTransaction;
  try
    lTrs.WriteSettings:= True;
    lTrs.StoreFormState:= True; // <<---
    lTrs.FormName := UnitName;
    lTrs.FormWindowstate := integer(Windowstate);
    lTrs.FormTop := Top;
    lTrs.FormLeft := Left;
    lTrs.FormHeight := Height;
    lTrs.FormWidth := Width;
    lTrs.FormRestoredTop := RestoredTop;
    lTrs.FormRestoredLeft := RestoredLeft;
    lTrs.FormRestoredHeight := RestoredHeight;
    lTrs.FormRestoredWidth := RestoredWidth;

    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
  end;
end;

function TfrmConfigure.CheckFormIsEntireVisible(Rect: TRect): TRect;
{ #todo : Moet naar een utils unit. }
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

procedure TfrmConfigure.WriteSettings;
var
  lTrs: TSettingstransaction;
begin
  //ReadSettings; // First read the curent settings.

  lTrs:= FPresenter.TrxMan.StartTransaction(prAppSettings) as TSettingstransaction;
  try
    lTrs.WriteSettings:= True;  // <<---
    lTrs.ReadSettings:= False;
    lTrs.ActivateLogging:= chkActiveLogging.Checked;
    lTrs.AppendLogging:= chkAppendLogging.Checked;
    FPresenter.TrxMan.CommitTransaction;
  except
    FPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmConfigure.ReadSettings;
var
  lTrs: TSettingstransaction;
begin
  lTrs:= FPresenter.TrxMan.StartTransaction(prAppSettings) as TSettingstransaction;
  try
    lTrs.ReadSettings:= True;  // <<---
    lTrs.WriteSettings:= False;
    FPresenter.TrxMan.CommitTransaction;
  except
    FPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmConfigure.GetAllColumNamesForStringgrid;
var
  lRec : TGetColumnNamesTransaction;
begin
  try
    lRec := FPresenter.TrxMan.StartTransaction(prGetColumnnames) as TGetColumnNamesTransaction;
    lrec.NameView := UnitName;
    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
    FPresenter.SetStatusbartext(fPresenter.GetstaticText(UnitName,'Fout bij ophalen Kolomnamen.'), 0);
    screen.Cursor := crDefault;
  end;
end;

procedure TfrmConfigure.SetStaticTexts(Texts: IStrings);
var
  i: integer;
  lc: TComponent;
begin
  Caption:= Texts.Values[Name];

  for i:= 0 to ComponentCount-1 do begin
    lc:= Components[i];
    if (lc is TTabSheet) then
      TTabSheet(lc).Caption:= Texts.Values[TTabSheet(lc).Name];
    if (lc is TButton) then
      TButton(lc).Caption:= Texts.Values[TButton(lc).Name];
    if (lc is TGroupBox) then
      TGroupBox(lc).Caption:= Texts.Values[TGroupBox(lc).Name];
    if (lc is TCheckBox) then
      TCheckBox(lc).Caption:= Texts.Values[TCheckBox(lc).Name];
  end;
end;

procedure TfrmConfigure.SetStaticHints(Texts: IStrings);
var
  i: integer;
  lc: TComponent;
begin
  for i:= 0 to ComponentCount-1 do begin
    lc:= Components[i];
    if (lc is TCheckBox) then
      TCheckBox(lc).Hint:= Texts.Values[TCheckBox(lc).Name];
  end;
end;

procedure TfrmConfigure.DoAppSettings(anObj: TObject; Settings: PSettingsRec);
begin
  with Settings^ do begin
    if setReadSettings then begin
      chkActiveLogging.Checked:= setActivateLogging;

      chkAppendLogging.OnChange:= nil;  // Ugly but prevents onchange of the append checkbox from being triggered.
      chkAppendLogging.Checked:= setAppendLogging;
      chkAppendLogging.OnChange:= @chkAppendLoggingChange;
    end
    else if setWriteSettings then begin
      if not setActivateLogging then
        FPresenter.StopLogging
      else
        FPresenter.StartLogging;
      if setAppendLogging then
        FPresenter.StartLogging;  // sets only appendlogging to true for the logging
    end;
  end;
end;

procedure TfrmConfigure.DoGetColumnnames(anObj: TObject;
  Collnames: PGetColumnNameRec);
var
  i : Integer;
  counter : Integer;
begin
  if Collnames = nil then exit;
  sgColumnNames.Enabled := False;

  Counter := 2;
  with PGetColumnNameRec(Collnames)^ do begin
    if (AllColNames <> Nil) and (length(AllColNames)>0) then begin
      FOrgColNames:= AllColNames; // FOrgColNames is used to detect changes is the column names.
      sgColumnNames.Enabled := True;
      for i:=0 to Length(AllColNames)-1 do begin
        with sgColumnNames Do begin
          RowCount := Counter;
          Cells[0,counter-1] := AllColNames[i].Key;
          Cells[1,counter-1] := AllColNames[i].Value;
          Inc(Counter);
        end;
      end;
    end
    else begin
      sgColumnNames.Enabled := False;
    end;
  end;
end;

procedure TfrmConfigure.DoFormState(anObj: TObject; Settings: PSettingsRec);
var
  LastWindowState : TWindowstate;
begin
  with Settings^ do begin
    if (setReadFormState) and (setFrmName = UnitName) then begin
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
end;

procedure TfrmConfigure.DosaveColumnNames(anObj: TObject;
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

procedure TfrmConfigure.HandleObsNotify(aReason: ptrint; aNotifyClass: TObject;
  UserData: pointer);
begin
  case aReason of
    prConfigStaticTexts: SetStaticTexts(IStringList(UserData));
    prConfigStaticHints: SetStaticHints(IStringList(UserData));
    prFormState        : DoFormState(aNotifyClass,UserData);
    prAppSettings      : DoAppSettings(aNotifyClass,UserData);
    prGetColumnnames   : DoGetColumnnames(aNotifyClass,UserData);
    prSaveColumnNames  : DosaveColumnNames(aNotifyClass,UserData);
  end;
end;

procedure TfrmConfigure.AfterConstruction;
begin
  inherited AfterConstruction;
  fSubscriber:= CreateObsSubscriber(@HandleObsNotify);

  self.Color:= clWindow;
  chkAppendLogging.ShowHint:= True;
end;

procedure TfrmConfigure.BeforeDestruction;
begin
  WriteSettings;
  StoreFormstate;  // Store the forn position and size.

  fPresenter.Provider.UnSubscribe(fSubscriber);
  fSubscriber.Obj.Free;
  inherited BeforeDestruction;
end;



end.

