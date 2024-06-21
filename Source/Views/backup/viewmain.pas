unit ViewMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, ComCtrls,
  ExtCtrls, {StdCtrls,} Buttons, Windows, Grids, StdCtrls,
  obs_prosu,
  vwmain.intf, vwmain.decl, vwmain.presenter, vwmain.types, ViewConfigure,
  ViewNewDbFile;

type

  { TfrmViewMain }

  TfrmViewMain = class(TForm, IView)
    btnSave: TButton;
    CoolBar1: TCoolBar;
    EditTmp: TEdit;
    ImageList1: TImageList;
    mmiOptionsLanguageNL: TMenuItem;
    mmiOptionsLanguageEN: TMenuItem;
    mmiOptionsLanguage: TMenuItem;
    mmiOptions: TMenuItem;
    mmiOptionsOptions: TMenuItem;
    mmiProgram: TMenuItem;
    mmiProgramCloseDbFile: TMenuItem;
    mmiProgramNewDbFile: TMenuItem;
    mmiProgramOpenDbFile: TMenuItem;
    mmiProgramQuit: TMenuItem;
    mmViewMain: TMainMenu;
    PanelItemsTop: TPanel;
    pnlMain: TPanel;
    pgcMain: TPageControl;
    pmMain: TPopupMenu;
    pmiAddItem: TMenuItem;
    pmiAutoSizeStringGrid: TMenuItem;
    pmiAutoSizeStringGridAll: TMenuItem;
    pmiDeleteItem: TMenuItem;
    pmiImport: TMenuItem;
    RadioGroup1: TRadioGroup;
    sbxLeft: TScrollBox;
    sbxMain: TScrollBox;
    Separator1: TMenuItem;
    pmiSeparator1: TMenuItem;
    pmiSeparator2: TMenuItem;
    splMain: TSplitter;
    StatusBar1: TStatusBar;
    tsItems: TTabSheet;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure btnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var {%H-}CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mmiOptionsLanguageENClick(Sender: TObject);
    procedure mmiOptionsLanguageNLClick(Sender: TObject);
    procedure mmiOptionsOptionsClick(Sender: TObject);
    procedure mmiProgramCloseDbFileClick(Sender: TObject);
    procedure mmiProgramNewDbFileClick(Sender: TObject);
    procedure mmiProgramOpenDbFileClick(Sender: TObject);
    procedure mmiProgramQuitClick(Sender: TObject);
    procedure pmiAddItemClick(Sender: TObject);
    procedure pmiAutoSizeStringGridAllClick(Sender: TObject);
    procedure pmiAutoSizeStringGridClick(Sender: TObject);
    procedure pmiDeleteItemClick(Sender: TObject);
    procedure pmiImportClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure sbxMainResize(Sender: TObject);
  private
    FSubscriber : TobsSubscriber;  // Holds the Observer.
    FPresenter : TPresenter;       // Holds the Presenter.
    FCanContinue : Boolean;
    FMustSaveFirst : Boolean;
    FNumberOfColumns : Integer;
    AllStringGrids : array of TStringGrid;
    PtrSgArr : Array of TObject; // used for stringgridFabric
    AllBitButtonsAdd : array of TBitBtn;
    FActiveStringGrid :  TStringGrid;
    FCanDeletePmi : Boolean;
    FLastRadioGroupIndex : Byte;
    FCol, FRow : Integer; // only use(d) for delete a row
    FAllowCellselectColor : Boolean;

    function CreateNewDbFile: String;
    function get_Presenter: IPresenter;
    function get_Subscriber: IobsSubscriber;
    procedure PrepareView(Filename: String);
    procedure set_Presenter(AValue: IPresenter);

    function Obj: TObject;
    procedure AlterSystemMenu(AppName, AppVersion : String; hWnd:HWND);
    { Check if the necessary directories exists. If not then create them. }
    procedure CheckDirectories;
    procedure DisableFuncions;
    procedure ReadFormState(FormName: String);
    procedure WriteSettings;
    procedure StoreFormstate;
    function CheckFormIsEntireVisible(Rect: TRect): TRect;
    { Start logging. Creates or opens a log file. }
    procedure StartLogging;
    function IsFileInUse(FileName: TFileName): Boolean;
    procedure NewDbFileData(DbFileName: String; DbFileInfo: PCreDbFileRec);

    procedure PrepareGlobalComponentArrays;  // Moet beter kunnen

    procedure CreateDbItemsMaintainer(FileName: String);  // gebruikt FPresenter
    procedure GetAllItemsForStringGrid;  // Transaction
    function GetTheRightStringGid(identifier: Byte; aName : String) : TStringGrid; // gebruikt FPresenter = n.v.t.
    { Remove last empty row from StringGrid. }
    procedure RemoveEmptyRowStringGrid;  // gebruikt FPresenter
    procedure ShowNewRowButtons(lBtnRec : TBitBtnRec);


    procedure BitButtonAddOnClick(Sender: TObject);
    procedure PanelOnResize(Sender: TObject);      // gebruikt FPresenter = n.v.t.
    procedure StringGridOnClick(Sender: TObject);  // gebruikt FPresenter
    procedure StringGridOnExit(Sender: TObject);   // gebruikt FPresenter
    procedure StringGridOnKeyUp(Sender : TObject ; var Key : Word ; {%H-}Shift : TShiftState );  // gebruikt FPresenter = nvt
    procedure StringGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StringGridOnValidateEntry(Sender: TObject; aCol, aRow: Integer; const OldValue: string; var NewValue: String);
    procedure StringGridOnSelectCell(Sender: TObject; aCol, aRow: Integer; {%H-}var CanSelect: Boolean);
    procedure StringGridMouseDown(Sender: TObject; Button: TMouseButton; {%H-}Shift: TShiftState; X, Y: Integer);
    procedure StringGridOnPrepareCanvas(Sender: TObject; aCol, aRow: Integer; aState: TGridDrawState);
    procedure StringGridOnCheckboxToggled(Sender: TObject; aCol, aRow: Integer; aState: TCheckboxState);
    procedure StringGridOnDrawCell(Sender : TObject ; aCol , aRow : Integer ; aRect : TRect ; aState : TGridDrawState );
    procedure StringGridOnEditingDone(Sender: TObject);


    function CanContinue: Boolean;
    procedure SetColumnHeaderNames;

  protected
    procedure DoSetStaticTexts(aTextRec: PStaticTextsAll);
    { Check if the necessary exists. If not then create the directorys }
    procedure DoCreateDirs({%H-}anObj: TObject; aDirs: PDirectoriesRec);
    procedure DoReadSettings({%H-}anObj: TObject; Settings: PSettingsRec);
    procedure DoReadFormState({%H-}anObj: TObject; Settings: PSettingsRec);
    procedure DoSetStatusBarText(aTextRec: PStatusbarPanelText);
    procedure DoCreateDbFile({%H-}anObj: TObject; DbFileRec: PCreDbFileRec);
    procedure DoOpenDbFilePrepare({%H-}anObj: TObject; DbFileRec: POpenDbFilePrepareViewRec);
    procedure DoOpenDbFileGetData({%H-}anObj: TObject; DbFileRec: POpenDbFilegetDataRec);
    procedure DoClearMainView({%H-}anObj: TObject; ViewdataRec: PClearPtrData);
    procedure DoCreateAppDbMaintainer({%H-}anObj: TObject; AppDbMaintainer: POpenDbFilegetDataRec);
    procedure DoSetStringGridHeaderFontStyle({%H-}anObj: TObject; StrinGridrecRec: PStringGridRec);
    procedure DoRemoveSgEmptyRows({%H-}anObj: TObject; StrinGridrecRec: PStringGridRec);
    procedure DoSgAddRow({%H-}anObj: TObject; StrinGridrecRec: PStringGridRec);
    procedure DoSgChange({%H-}anObj: TObject; StrinGridrecRec: PStringGridRec);
    procedure DoShowBitBtn({%H-}anObj: TObject; BitBtnrec: PBitBtnRec);
    procedure DoEnableSaveButton({%H-}anObj: TObject; Btnrec: PSaveBtn);
    procedure DoSetupPmiStatus({%H-}anObj: TObject; pmiVisibility: PPmiVisibility);
    procedure DoAddNewItem({%H-}anObj: TObject; NewItem: PtrItemObject);
    procedure DoUpdateItem({%H-}anObj: TObject; NewItem: PtrItemObject);
    procedure DoDeleteItem({%H-}anObj: TObject; DeleteItem: PtrItemObject);
    procedure DoSaveChanges({%H-}anObj: TObject; SaveChanges: PSaveChangesRec);
    procedure DoSaveCheckBoxToggled({%H-}anObj: TObject; CheckBoxToggled: PCheckBoxCellPosition);
    procedure DoGetColumnnames(anObj: TObject; Collnames: PGetColumnNameRec);

public
    { Handle Observer Notifications ! }
    procedure HandleObsNotify(aReason: TProviderReason;aNotifyClass: TObject;UserData: pointer);  // <<----

    property Subscriber: IobsSubscriber read get_Subscriber;
    property Presenter: IPresenter read get_Presenter write set_Presenter;
  end;

var
  frmViewMain: TfrmViewMain;

implementation

{$R *.lfm}

{ TfrmViewMain }

{%Region Properties }
function TfrmViewMain.get_Presenter: IPresenter;
begin
  Result := FPresenter;
end;

procedure TfrmViewMain.set_Presenter(AValue: IPresenter);
begin
  { This is called when the view is created. }
  if aValue = nil then begin
    if Assigned(FPresenter) then FPresenter.Provider.UnSubscribe(FSubscriber);    // ==> Provider = property from TPresenter. LET OP: Hier koppel je de  HandleObsNotify
    FPresenter.Free;
    FPresenter:= nil;
    exit;
  end;
  if TPresenter(aValue.Obj) <> fPresenter then begin
    if Assigned(FPresenter) then fPresenter.Provider.UnSubscribe(FSubscriber); { we can't detach nil }
    FPresenter.Free; { we own it }
    if Assigned(aValue) then begin
      FPresenter:= TPresenter(aValue.Obj);
      FPresenter.Provider.Subscribe(FSubscriber);
      FPresenter.GetStaticTexts(gstAll);  // Get All static texts
      FPresenter.SetAppInfo;
    end;
  end;
end;

function TfrmViewMain.get_Subscriber: IobsSubscriber;
begin
  Result := FSubscriber;
end;
{%endregion Properties }

function TfrmViewMain.Obj: TObject;
begin
  Result := self;
end;

procedure TfrmViewMain.AlterSystemMenu(AppName, AppVersion: String; hWnd: HWND);
// Expand system menu with 1 line
const
   SC_MyMenuItem1 = WM_USER + 1;
var
  SysMenu : HMenu;
  sMyMenuCaption1 : String;
begin
  sMyMenuCaption1 := AppName + '  V' + AppVersion + '.   (HvB)';

  SysMenu := GetSystemMenu(hWnd, FALSE) ;                            {Get system menu}
  AppendMenu(SysMenu, MF_SEPARATOR, 0, '') ;                         {Add a seperator bar to main form}

  // AppendMenu(SysMenu, MF_STRING, SC_MyMenuItem1, '') ;            //empty line
  AppendMenu(SysMenu, MF_STRING, SC_MyMenuItem1, PChar(sMyMenuCaption1)) ;  {add our menu}
end;

procedure TfrmViewMain.CheckDirectories;
var
  lDirTrx: TDirTransaction;
  dirList : TStringList;
begin
  lDirTrx:= FPresenter.TrxMan.StartTransaction(msCreateDir) as TDirTransaction;
  dirList := TStringList.Create;  // Create stringlist that contains the directory names.
  try
    dirList.Add(adSettings);
    dirList.Add(adLogging);
    dirList.Add(adDatabase);
    lDirTrx.NewDirnames.AddStrings(dirList);
    lDirTrx.RootDir:= '';  { #todo : Make the root dir for folders optional } // For now we the use app-dir as root.
    FPresenter.TrxMan.CommitTransaction; // Mandatory, takes action (process the data) and _frees_ transaction.

    dirList.Free;
  except fPresenter.TrxMan.RollbackTransaction; end; // mandatory, does NOTHING and _frees_ transaction
end;

procedure TfrmViewMain.DisableFuncions;
begin
  if not FCanContinue then begin
    mmiProgramOpenDbFile.Enabled := False;
    mmiProgramCloseDbFile.Enabled := False;
    mmiProgramNewDbFile.Enabled := False;
  end;
end;

procedure TfrmViewMain.ReadFormState(FormName: String);
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

procedure TfrmViewMain.WriteSettings;
var
  lSettingsTrx : TSettingstransaction;
begin
  lSettingsTrx := FPresenter.TrxMan.StartTransaction(msUpdateSettings) as TSettingsTransaction;
  try
    lSettingsTrx.SettingsLocationAndFileName := ExtractFilePath(ParamStr(0)) + adSettings + PathDelim + afSettings;
    lSettingsTrx.FormName := fnMain;  // Determines which settings are saved.

    if mmiOptionsLanguageEN.Checked then
      lSettingsTrx.Language := lEN
    else if mmiOptionsLanguageNL.Checked then
      lSettingsTrx.Language := lNL;
    //...

    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmViewMain.StoreFormstate;
var
  lSettingsTrx : TSettingstransaction;
begin
  lSettingsTrx := FPresenter.TrxMan.StartTransaction(msStoreFormState) as TSettingsTransaction;
  try
    lSettingsTrx.SettingsLocationAndFileName := ExtractFilePath(ParamStr(0)) + adSettings + PathDelim + afSettings;
    lSettingsTrx.FormName := fnMain;
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

function TfrmViewMain.CheckFormIsEntireVisible(Rect: TRect): TRect;
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

procedure TfrmViewMain.StartLogging;
begin
  FPresenter.StartLogging(ExtractFilePath(ParamStr(0)));
end;

function TfrmViewMain.IsFileInUse(FileName: TFileName): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False;
  if not FileExists(FileName) then Exit;
  HFileRes := CreateFile(PChar(FileName),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL,
                         0);
  Result := (HFileRes = INVALID_HANDLE_VALUE);
  if not Result then
    CloseHandle(HFileRes);
end;

procedure TfrmViewMain.NewDbFileData(DbFileName: String;
  DbFileInfo: PCreDbFileRec);
var
  frm : TfrmViewCreDbFile;
begin
  frm := TfrmViewCreDbFile.create(self);
  try
    frm.NewFileName:= ExtractFileName(DbFileName);
    FPresenter.SetStatusbartext('Enter database details', 0);
    frm.ShowModal;

    DbFileInfo^.cdbfFilename:= frm.NewFileName;
    DbFileInfo^.cdbfColumnCount:= frm.NumberOfColumns;
    DbFileInfo^.cdbfShortDescription:= frm.DbDescriptionShort;
    DbFileInfo^.cdbfCreateTable:= frm.CreateTable;
  finally
    frm.Free;
    FPresenter.SetStatusbartext('', 0);
  end;
end;

procedure TfrmViewMain.PrepareGlobalComponentArrays;
var
  i, j, k, SgCounter, BitBtnCounter: Integer;
  _panel1, _panel2 : TPanel;
  _bitBtn : TBitBtn;
  _stringGrid : TStringgrid;
begin
  Screen.Cursor := crHourGlass;
  SgCounter := 1;
  Setlength(AllStringGrids, SgCounter);
  SetLength(PtrSgArr, SgCounter);

  BitBtnCounter := 1;
  Setlength(AllBitButtonsAdd, BitBtnCounter);

  for i:= 0 to sbxLeft.ControlCount -1 do begin
    if sbxLeft.Controls[i] is TPanel then begin
      _panel1 := TPanel(sbxLeft.Controls[i]);

      //PanelBody_ --> PanelHeader_ --> bitbutton
      if _panel1.Name.Contains('PanelBody_') then begin
        for j:= 0 to _panel1.ControlCount -1 do begin
          if _panel1.Controls[j] is TPanel then begin
            _panel2 := TPanel(_panel1.Controls[j]);
            _panel2.OnResize := @PanelOnResize;
            if _panel2.Name.Contains('PanelHeader_') then begin
              for k:=0 to _panel2.ControlCount -1 do begin
                if _panel2.Controls[k] is TBitBtn then begin
                  _bitBtn := TBitBtn(_panel2.Controls[k]);
                  Setlength(AllBitButtonsAdd, BitBtnCounter);
                  AllBitButtonsAdd[BitBtnCounter-1] := _bitBtn;
                  Inc(BitBtnCounter);
                  _bitBtn.OnClick := @BitButtonAddOnClick;
                  Break;
                end;
              end;
            end
            else if _panel2.Name.Contains('PanelData_') then begin
              // add TStringgrids to an array
              for k:=0 to _panel2.ControlCount -1 do begin
                if _panel2.Controls[k] is TStringGrid then begin
                  _stringGrid := TStringgrid(_panel2.Controls[k]);
                  Setlength(AllStringGrids, SgCounter);
                  AllStringGrids[SgCounter-1] := _stringGrid;  // Add StringGrid to the array.

                  Setlength(PtrSgArr, SgCounter);
                  PtrSgArr[SgCounter-1] := TObject(_stringGrid);

                  Inc(SgCounter);
                  _stringGrid.OnClick := @StringGridOnClick;
                  _stringGrid.OnExit := @StringGridOnExit;
                  _stringGrid.OnKeyDown := @StringGridKeyDown;
                  _stringGrid.OnKeyUp := @StringGridOnKeyUp;
                  _stringGrid.OnValidateEntry := @StringGridOnValidateEntry;
                  _stringGrid.OnSelectCell := @StringGridOnSelectCell;
                  _stringGrid.PopupMenu := pmMain;
                  _stringGrid.OnMouseDown := @StringGridMouseDown;
                  _stringGrid.OnPrepareCanvas := @StringGridOnPrepareCanvas;
                  _stringGrid.OnEditingDone := @StringGridOnEditingDone;
                  _stringGrid.OnCheckboxToggled := @StringGridOnCheckboxToggled;
                  _stringGrid.OnDrawCell := @StringGridOnDrawCell;
                  Break;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  for i:= 0 to sbxMain.ControlCount -1 do begin
    if sbxMain.Controls[i] is TPanel then begin
      _panel1 := TPanel(sbxMain.Controls[i]);

      //PanelBody_ --> PanelHeader_ --> bitbutton
      if _panel1.Name.Contains('PanelBody_') then begin
        for j:= 0 to _panel1.ControlCount -1 do begin
          if _panel1.Controls[j] is TPanel then begin
            _panel2 := TPanel(_panel1.Controls[j]);
            _panel2.OnResize := @PanelOnResize;
            if _panel2.Name.Contains('PanelHeader_') then begin
              for k:=0 to _panel2.ControlCount -1 do begin
                if _panel2.Controls[k] is TBitBtn then begin
                  _bitBtn := TBitBtn(_panel2.Controls[k]);
                  Setlength(AllBitButtonsAdd, BitBtnCounter);
                  AllBitButtonsAdd[BitBtnCounter-1] := _bitBtn;
                  Inc(BitBtnCounter);
                  _bitBtn.OnClick := @BitButtonAddOnClick;
                  Break;
                end;
              end;
            end
            else if _panel2.Name.Contains('PanelData_') then begin
              // add TStringgrids to an array
              for k:=0 to _panel2.ControlCount -1 do begin
                if _panel2.Controls[k] is TStringGrid then begin
                  _stringGrid := TStringgrid(_panel2.Controls[k]);
                  Setlength(AllStringGrids, SgCounter);
                  AllStringGrids[SgCounter-1] := _stringGrid;  // Add StringGrid to the array.

                  Setlength(PtrSgArr, SgCounter);
                  PtrSgArr[SgCounter-1] := TObject(_stringGrid);

                  Inc(SgCounter);
                  _stringGrid.OnClick := @StringGridOnClick;
                  _stringGrid.OnExit := @StringGridOnExit;
                  _stringGrid.OnKeyDown := @StringGridKeyDown;
                  _stringGrid.OnKeyUp := @StringGridOnKeyUp;
                  _stringGrid.OnValidateEntry := @StringGridOnValidateEntry;
                  _stringGrid.OnSelectCell := @StringGridOnSelectCell;
                  _stringGrid.PopupMenu := pmMain;
                  _stringGrid.OnMouseDown := @StringGridMouseDown;
                  _stringGrid.OnPrepareCanvas := @StringGridOnPrepareCanvas;
                  _stringGrid.OnEditingDone := @StringGridOnEditingDone;
                  _stringGrid.OnCheckboxToggled := @StringGridOnCheckboxToggled;
                  _stringGrid.OnDrawCell := @StringGridOnDrawCell;
                  Break;
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
  Screen.Cursor := crDefault;
end;

procedure TfrmViewMain.CreateDbItemsMaintainer(FileName: String);
var
  ltrx : TCreateAppDbMaintainerTransaction;
begin
  // Create a TAppDbMaintainItems reference. This will live until a new db file is openend or created.
  if FileName = '' then exit;

  try
    ltrx := FPresenter.TrxMan.StartTransaction(msCreateAppDbReference) as TCreateAppDbMaintainerTransaction;
    ltrx.FileName := FileName;
    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
    FPresenter.SetStatusbartext('Fout bij aanmaken van een AppDb object.',0);
    screen.Cursor := crDefault;
  end;
end;

procedure TfrmViewMain.GetAllItemsForStringGrid;
var
  lodbt : TOpenDbFileGetDataTransaction;
  i : Integer;
  _stringGrid : TStringGrid;
begin
  screen.Cursor := crHourGlass;

  for i:= 1 to FNumberOfColumns do begin
    try
      FPresenter.SetStatusbartext('Data kolom ' + IntToStr(i) + ' wordt opgehaald...', 0);
      _stringGrid := GetTheRightStringGid(i, 'STRINGGRID_');
      _stringGrid.OnSelectCell := Nil;

      lodbt := FPresenter.TrxMan.StartTransaction(msOpenDbFileGetData) as TOpenDbFileGetDataTransaction; // testen of dit buiten de loop kan
      lodbt.StringgridPtr := _stringGrid;
      lodbt.Level := i;

      FPresenter.TrxMan.CommitTransaction;
      _stringGrid.OnSelectCell := @StringGridOnSelectCell;
      SetColumnHeaderNames;  // Set the (new) header names.
      screen.Cursor := crDefault;
    except
      fPresenter.TrxMan.RollbackTransaction;
      FPresenter.SetStatusbartext('Fout bij ophalen data.',0);
      screen.Cursor := crDefault;
    end;
  end;

  screen.Cursor := crDefault;
end;

function TfrmViewMain.GetTheRightStringGid(identifier: Byte; aName: String
  ): TStringGrid;
var
  i : Integer;
  _stringGrid : TStringGrid;
begin
  Result := nil;

  for i := 0 to Length(AllStringGrids) -1 do begin
    _stringGrid :=  AllStringGrids[i];
    if _stringGrid.Name = aName + IntToStr(identifier)  then
      begin
        Result := _stringGrid;
        break;
      end;
  end;
end;

procedure TfrmViewMain.RemoveEmptyRowStringGrid;
var
  i : Integer;
begin
  if Length(AllStringGrids) > 0 then begin
    for i := 0 to Length(AllStringGrids)-1 do begin
      FPresenter.SGRemoveEmptyRows(AllStringGrids[i]);
    end;
  end;
end;

procedure TfrmViewMain.ShowNewRowButtons(lBtnRec : TBitBtnRec);
var
  i : Integer;
begin
  if Length(AllBitButtonsAdd) > 0 then begin
    for i := 0 to Length(AllBitButtonsAdd)-1 do begin
      FPresenter.ShowButtons(@lBtnRec, AllBitButtonsAdd[i]);
    end;
  end;
end;

procedure TfrmViewMain.BitButtonAddOnClick(Sender: TObject);
var
  s: String;
  _sg: TStringGrid;
begin
  if sender is TBitBtn then begin
    s:= FPresenter.ExtractNumberFromString(TBitBtn(sender).Name);
    _sg := GetTheRightStringGid(StrToInt(s), 'STRINGGRID_');
  end
  else if sender is TStringGrid then begin
    _sg := TStringGrid(Sender);
  end;

  FActiveStringGrid := _sg;

  if _sg.Cells[3,_sg.RowCount-1] <> '' then begin
    FPresenter.SGAddRow(_sg, True);
    FPresenter.ActiveStrgridCell(_sg, True);
  end
  else if _sg.RowCount = 1 then begin  // stringgrid is empty
    FPresenter.SGAddRow(_sg, True);
    FPresenter.ActiveStrgridCell(_sg, True);
  end;

end;

procedure TfrmViewMain.DoSetStaticTexts(aTextRec: PStaticTextsAll);
var
  sl : TStringList;
begin
  with aTextRec^ do begin
    Caption := staVwMainTitle;
    mmiProgram.Caption := staMmiProgramCaption;
    mmiProgramOpenDbFile.Caption := staMmiProgramOpenDbFileCaption;
    mmiProgramCloseDbFile.Caption := staMmiProgramCloseDbFileCaption;
    mmiProgramNewDbFile.Caption := staMmiProgramNewDbFileCaption;
    mmiProgramQuit.Caption:= staMmiProgramQuitCaption;

    mmiOptions.Caption := staMmiOptionsCaption;
    mmiOptionsOptions.Caption := staMmiOptionsOptionsCaption;
    mmiOptionsLanguage.Caption := staMmiOptionsLanguageCaption;
    mmiOptionsLanguageEN.Caption := staMmiOptionsLanguageENCaption;
    mmiOptionsLanguageNL.Caption := staMmiOptionsLanguageNLCaption;

    tsItems.Caption := staTsItemsCaption;
    pnlMain.Caption := staClear;

    sl := TStringList.Create;
    sl.Add(staRgrpStrings_1);
    sl.Add(staRgrpStrings_2);
    sl.Add(staRgrpStrings_3);
    RadioGroup1.Items := sl;
    sl.Free;

    btnSave.Caption := staBtnSaveCaption;

    pmiAutoSizeStringGrid.Caption := staPmiAutoSizeStringGridCaption;
    pmiAutoSizeStringGridAll.Caption := staPmiAutoSizeStringGridAllCaption;
    pmiDeleteItem.Caption := staPmiDeleteItemCaption;
    pmiAddItem.Caption := staPmiAddItemCaption;
    pmiImport.Caption := staPmiImportCaption;
  end;
end;

procedure TfrmViewMain.DoCreateDirs(anObj: TObject; aDirs: PDirectoriesRec);
begin
  FCanContinue := aDirs^.dirSucces;
  if not FCanContinue then begin
    DisableFuncions;
    FPresenter.SetStatusbarText('Onverwachte fout: ' + aDirs^.dirSuccesMsg, 0);
    messageDlg('Let op', 'Onverwachte fout bij het maken van een Directory.' + sLineBreak
    + sLineBreak + 'Fout: ' + aDirs^.dirSuccesMsg
    , mtError, [mbOK],0);
  end;
end;

procedure TfrmViewMain.DoReadSettings(anObj: TObject; Settings: PSettingsRec);
begin
  if Settings^.setSucces then begin
    if Settings^.setLanguage = lEN then begin
      mmiOptionsLanguageEN.Checked := True;
      mmiOptionsLanguageNL.Checked := False;
    end
    else if Settings^.setLanguage = lNL then begin
      mmiOptionsLanguageEN.Checked := False;
      mmiOptionsLanguageNL.Checked := True;
    end;
  end;
end;

procedure TfrmViewMain.DoReadFormState(anObj: TObject; Settings: PSettingsRec);
var
  LastWindowState : TWindowstate;
begin
  if (Settings^.setSucces)  and (Settings^.setFrmName = fnMain) then begin
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

procedure TfrmViewMain.DoCreateDbFile(anObj: TObject; DbFileRec: PCreDbFileRec);
begin
  if DbFileRec^.cdbfSucces then begin
    FPresenter.SetStatusbarText('', 0);  { #todo : If DebugMode then here can set some other text. }
  end
  else begin
    messageDlg('Error', DbFileRec^.cdbfMessage, mtError, [mbOK], 0);
    FPresenter.SetStatusbarText('Failed to create the database.', 0);
  end;
end;

procedure TfrmViewMain.DoOpenDbFilePrepare(anObj: TObject;
  DbFileRec: POpenDbFilePrepareViewRec);
begin
  screen.Cursor := crHourGlass;

  if DbFileRec^.odbfSucces then begin
    FCanContinue := True;
    PrepareGlobalComponentArrays;
    FNumberOfColumns := DbFileRec^.odbfColumnCount;

    FPresenter.SetStatusbartext('', 0);
    FPresenter.SetStatusbartext('Bestand: ' + DbFileRec^.odbfFileName, 2);
  end
  else begin
    FCanContinue := False;
    FPresenter.SetStatusbartext('Fout bij het opbouwen van het scherm.', 0);
    FPresenter.SetStatusbartext('Bestand: ', 2);
  end;

  screen.Cursor := crDefault;
end;

procedure TfrmViewMain.DoOpenDbFileGetData(anObj: TObject;
  DbFileRec: POpenDbFilegetDataRec);
begin
  screen.Cursor := crHourGlass;
  if DbFileRec^.gdSucces then begin
    FCanContinue := True;
     FPresenter.SetStatusbartext('', 0);
  end
  else begin
    FCanContinue := False;
    FPresenter.SetStatusbartext('Fout bij het het ophalen van de data.', 0);
  end;

  screen.Cursor := crDefault;
end;

procedure TfrmViewMain.DoClearMainView(anObj: TObject;
  ViewdataRec: PClearPtrData);
begin
  if ViewdataRec^.cpdSuccess = True Then begin
    FPresenter.SetStatusbartext('Bestand:', 2);
  end
  else begin
    FPresenter.SetStatusbartext('Verwijderen componenten is mislukt.', 0);
  end;
end;

procedure TfrmViewMain.DoCreateAppDbMaintainer(anObj: TObject;
  AppDbMaintainer: POpenDbFilegetDataRec);
begin
  if AppDbMaintainer^.gdSucces Then begin
    FCanContinue := True;
  end;
end;

procedure TfrmViewMain.DoSetStringGridHeaderFontStyle(anObj: TObject;
  StrinGridrecRec: PStringGridRec);
var
  i : Integer;
begin{ #todo : Make on/of optional and make bold and the color optional }
  with PStringGridRec(StrinGridrecRec)^ do begin
    for i := 0 to TStringGrid(anObj).VisibleColCount-1 do begin
      if sgHeaderFontStyle = 0 then begin
        if (RadioGroup1.ItemIndex = 0) or (RadioGroup1.ItemIndex = 1) then begin
          TStringGrid(anObj).Columns[i].Title.Font.Style := [fsBold];

          TStringGrid(anObj).Columns[0].Title.Font.Color := clteal;  // Parent
          TStringGrid(anObj).Columns[1].Title.Font.Color := clteal;  // Child
          TStringGrid(anObj).Columns[2].Title.Font.Color := clBlue;  // Itrem
          //TStringGrid(anObj).Columns[i].Title.Font.Color := TColor(sgParentFontColor);
        end;
      end
      else if sgHeaderFontStyle = -1 then begin
        TStringGrid(anObj).Columns[i].Title.Font.Style := [];
        TStringGrid(anObj).Columns[i].Title.Font.Color := clBlack;
      end;
    end;
  end;
end;

procedure TfrmViewMain.DoRemoveSgEmptyRows(anObj: TObject;
  StrinGridrecRec: PStringGridRec);
var
  aRow: Integer;
  i: Integer;
begin
//  if StrinGridrecRec <> nil then begin
  i:= TStringGrid(anObj).RowCount ;

    if TStringGrid(anObj).RowCount > 0 then begin
      for aRow := 1 to TStringGrid(anObj).RowCount-1 do begin
        if TStringGrid(anObj).Cells[3,aRow] = '' then begin
          TStringGrid(anObj).DeleteRow(aRow);
        end;
      end;
    end;
//  end;
end;

procedure TfrmViewMain.DoSgAddRow(anObj: TObject; StrinGridrecRec: PStringGridRec);
begin
  with anObj as TStringGrid do begin
    if PStringGridRec(StrinGridrecRec)^.sgAddExtraRow then begin
      RowCount := RowCount + 1;
    end;
  end;
end;

procedure TfrmViewMain.DoSgChange(anObj: TObject;
  StrinGridrecRec: PStringGridRec);
var
  i: Integer;
begin
  { #todo : Dat kan naar stringgrid fabric }
  with PStringGridRec(StrinGridrecRec)^ do begin
      for i:= 0 to length(AllStringGrids)-1 do begin

        if sgState = ssRead then begin
          AllStringGrids[i].ColWidths[0] := 20;
          AllStringGrids[i].AutoFillColumns := True;
          AllStringGrids[i].Options := AllStringGrids[i].Options - [goEditing, goAutoAddRows];
          AllStringGrids[i].FocusColor := clRed;
        end
        else if sgState = ssModify then begin
          AllStringGrids[i].ColWidths[0] := 20;
          AllStringGrids[i].AutoFillColumns := True;
          AllStringGrids[i].Options := AllStringGrids[i].Options + [goEditing, goAutoAddRows, goTabs];  //goTabs goRowSelect = blue color
          AllStringGrids[i].FocusColor := clRed;
        end
        else if sgState = ssModifyRelations then begin
          AllStringGrids[i].AutoFillColumns := False;
          self.Caption := IntToStr(AllStringGrids[i].ColCount);
          AllStringGrids[i].ColWidths[0] := 20;
          AllStringGrids[i].ColWidths[1] := 50;
          AllStringGrids[i].ColWidths[2] := 50;
          AllStringGrids[i].ColWidths[3] := 150;
          AllStringGrids[i].AutoSizeColumn(3); // Ensures that the last column shows all contents.

          AllStringGrids[i].Options := AllStringGrids[i].Options + [goEditing];
          AllStringGrids[i].FocusColor := clNone;
        end;

        AllStringGrids[i].Columns[0].Visible := sgShowParentCol;
        AllStringGrids[i].Columns[1].Visible := sgShowChildCol;
      end;
  end;
end;

procedure TfrmViewMain.DoShowBitBtn(anObj: TObject; BitBtnrec: PBitBtnRec);
begin
  with PBitBtnRec(BitBtnrec)^ do begin
    TBitBtn(anObj).Visible:= btnAddVisible;
    btnSave.Visible := btnSaveVisible;
  end;
end;

procedure TfrmViewMain.DoEnableSaveButton(anObj: TObject; Btnrec: PSaveBtn);
begin
  with PSaveBtn(Btnrec)^ do begin
    TButton(anObj).Enabled := btnEnable;
    if DupFound then begin
      FPresenter.SetStatusbartext('Alleen unieke waarden zijn toegestaan.', 0);
    end
    else if LengthToLongFound then begin
      FPresenter.SetStatusbartext('Maximaal 1000 tekens toegestaan.', 0);
    end
    else begin
      FPresenter.SetStatusbartext('Niet opgeslagen wijzigingen aanwezig.', 0);
    end;
  end;
end;

procedure TfrmViewMain.DoSetupPmiStatus(anObj: TObject; pmiVisibility: PPmiVisibility);
begin
  with PPmiVisibility(pmiVisibility)^ do begin
    pmiDeleteItem.Visible := pmivDeletItem;
    pmiAddItem.Visible := pmivAddItem;
    pmiImport.Visible := pmivImportItems;

    // enable / disable the seperatord
    pmiSeparator1.Visible := pmivAddItem;
    pmiSeparator2.Visible := pmivImportItems;
  end;
end;

procedure TfrmViewMain.DoAddNewItem(anObj: TObject; NewItem: PtrItemObject);
var
  pItem : PtrItemObject;
  _sg : TStringGrid;
begin
  with PtrItemObject(NewItem)^ do begin
    // Create a new object.
    new(pItem);
    pItem^.Guid := Guid;
    pItem^.Level := Level;
    pItem^.Name := Name;
    pItem^.Action := Action;

    // Assign the new object to the new stringgrid row.
    if GridObject <> nil then begin
      _sg := TStringGrid(GridObject);

//      Dit is vreemd !!!
      if _sg.Cells[3, _sg.RowCount-1] <> '' then begin // add button
        _sg.Objects[3, _sg.RowCount-1] := TObject(pItem);
      end
      else if _sg.Cells[3, _sg.RowCount-1] = '' then begin  // tab
        _sg.Objects[3, _sg.RowCount-2] := TObject(pItem);
      end;
    end;

    FMustSaveFirst := MustSave;
    FPresenter.SetStatusbartext('Niet opgeslagen wijzigingen aanwezig.', 0);
  end;
end;

procedure TfrmViewMain.DoUpdateItem(anObj: TObject; NewItem: PtrItemObject);
var
  ExistingItem : PtrItemObject;
  _sg : TStringGrid;
begin
  with PtrItemObject(NewItem)^ do begin
    if GridObject <> nil then begin
      _sg := TStringGrid(GridObject);
      ExistingItem := PtrItemObject(_sg.Objects[sgCol, sgRow]);

      if ExistingItem^.Guid = Guid Then begin
        ExistingItem^.Name := Name;
        ExistingItem^.Action := Action;

        // Change the StringGrid row object.
        _sg.Objects[sgCol, sgRow] := TObject(ExistingItem);
      end
      else begin
        FPresenter.SetStatusbartext('item is niet bijgewerkt, zie log bestand', 1 );
        FPresenter.WriteToLog(laDebug, 'guid stringgrid: ' + ExistingItem^.Guid + ' guid update aangeboden: ' +  Guid);
        FPresenter.WriteToLog(laDebug, 'rij stringgrid: ' + IntToStr(ExistingItem^.sgRow) + ' rij update aangeboden: ' +  IntToStr(sgRow));
        FPresenter.WriteToLog(laDebug, 'col stringgrid: ' + IntToStr(ExistingItem^.sgCol) + ' col update aangeboden: ' +  IntToStr(sgCol));
        FPresenter.WriteToLog(laDebug, '');
      end;
    end;
    FMustSaveFirst := MustSave;
    FPresenter.SetStatusbartext('Niet opgeslagen wijzigingen aanwezig.', 0);
  end;
end;

procedure TfrmViewMain.DoDeleteItem(anObj: TObject; DeleteItem: PtrItemObject);
var
  _sg : TStringGrid;
begin
  with PtrItemObject(DeleteItem)^ do begin
    if GridObject <> nil then begin
      _sg := TStringGrid(GridObject);

      // Remove the oject
      if PtrItemObject(_sg.Objects[sgCol,sgRow]) <> nil then begin
        Dispose(PtrItemObject(_sg.Objects[sgCol,sgRow]));
      end;

      // Delete the stringgrid row.
      //_sg.OnSelectCell := nil;

      _sg.DeleteRow(sgRow);  // hierna komt select cel en dat gat mis

      // det neits kan weg
{      for i:=0 to Length(AllStringGrids)-1 do begin
        //AllStringGrids[i].OnSelectCell := @StringGridOnSelectCell;
        AllStringGrids[i].Repaint;
      end;}

    end;
    FMustSaveFirst := MustSave;
    if MustSave then
      btnSave.Enabled := True
    else
      btnSave.Enabled := False;
    FPresenter.SetStatusbartext('Niet opgeslagen wijzigingen aanwezig.', 0);
  end;
end;

procedure TfrmViewMain.DoSaveChanges(anObj: TObject;
  SaveChanges: PSaveChangesRec);
var
  i : Integer;
  aCol, aRow: Integer;
  pItem : PtrItemObject;
begin
  with PSaveChangesRec(SaveChanges)^ do begin
    if scSuccess then begin

      // Update all SrtringGrid Row objects
      { #todo : Op deze manier gaat opslaan steeds langen duren. anders opzetten. En past op deze manier niet in mvp model}
      for i:=0 to Length(AllStringGrids)-1 do begin
        for aRow:=0 to AllStringGrids[i].RowCount-1 do begin
          for aCol:=0 to AllStringGrids[i].ColCount-1 do begin
            pItem := PtrItemObject(AllStringGrids[i].Objects[acol,aRow]);
            if pItem <> nil then begin
              if pItem^.Action <> iaRead then begin
                PtrItemObject(AllStringGrids[i].Objects[acol,aRow])^.Action := iaRead;
                break;
              end;
            end;
          end;
        end;
      end;

      FPresenter.SetStatusbartext('De wijzigingen zijn opgeslagen', 0);
      FMustSaveFirst := MustSave;
      btnSave.Enabled := MustSave;
    end
    else begin
      FPresenter.SetStatusbartext('Het opslaan van de wijzigingen is mislukt.', 0);
    end;
  end;
end;

procedure TfrmViewMain.DoSaveCheckBoxToggled(anObj: TObject;
  CheckBoxToggled: PCheckBoxCellPosition);
begin
  with PCheckBoxCellPosition(CheckBoxToggled)^ do begin
    FMustSaveFirst := MustSave;
    if CbParentMultipleCheck then begin
      if btnSave.Enabled then
        btnSave.Enabled := False;
    end
    else begin
      if CanSave then begin
        btnSave.Enabled := True;
      end
      else begin
        btnSave.Enabled := False;
      end;
    end;
  end;
end;

procedure TfrmViewMain.DoGetColumnnames(anObj: TObject;
  Collnames: PGetColumnNameRec);
var
  i : Integer;
begin
  if Collnames = nil then exit;
  with PGetColumnNameRec(Collnames)^ do begin
    if NameView = 'MainView' then begin
      for i:= 0 to Length(AllStringGrids)-1 do begin
        AllStringGrids[i].Columns.Items[2].Title.Caption := AllColNames[i].Value;
      end;
    end;
  end;
end;

procedure TfrmViewMain.mmiProgramQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmViewMain.pmiAddItemClick(Sender: TObject);
begin
  // TODO
  ShowMessage('Not yet implemented.');
end;

procedure TfrmViewMain.pmiAutoSizeStringGridAllClick(Sender: TObject);
begin
  // TODO
  ShowMessage('Not yet implemented.');
end;

procedure TfrmViewMain.pmiAutoSizeStringGridClick(Sender: TObject);
begin
  // TODO
  ShowMessage('Not yet implemented.');
end;

procedure TfrmViewMain.pmiDeleteItemClick(Sender: TObject);
var
  ExistingItem : PtrItemObject;
  lItemRec: TItemTransaction;
begin
  if FActiveStringgrid <> nil then begin
    if (RadioGroup1.ItemIndex = 1) or (RadioGroup1.ItemIndex = 2) then begin
      if MessageDlg('Wilt u het volgende item verwijderen: ' + sLineBreak + sLineBreak +
         FActiveStringgrid.Cells[FCol, FRow] ,
         mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
        begin
          try
            ExistingItem := PtrItemObject(FActiveStringgrid.Objects[FCol, FRow]);

            if ExistingItem <> nil then begin
              lItemRec := fPresenter.TrxMan.StartTransaction(msDeleteItem) as TItemTransaction;

              lItemRec.Action := iaDelete;
              lItemRec.Col := FCol;
              lItemRec.Row := FRow;
              lItemRec.GridObject := FActiveStringgrid;
              lItemRec.Guid := ExistingItem^.Guid;
              lItemRec.Name := ExistingItem^.Name;
              //lItemRec.AllSGrids := Pointer(AllStringGrids);

              FPresenter.TrxMan.CommitTransaction;
            end
            else begin // there is no object found (= inserted row and direct popup menu delete row)
              FActiveStringgrid.DeleteRow(FRow);
            end;
          except
            fPresenter.TrxMan.RollbackTransaction;
            FPresenter.SetStatusbartext('Fout bij voorbereiden gegevens: verwijder item.',0);
            screen.Cursor := crDefault;
          end;
        end;
    end;
  end;
end;

procedure TfrmViewMain.pmiImportClick(Sender: TObject);
begin
  // TODO
  ShowMessage('Not yet implemented.');
end;

procedure TfrmViewMain.RadioGroup1Click(Sender: TObject);
var
  lsgRec : TStringGridRec;
  lBtnRec : TBitBtnRec;
begin
//  if not FMustSaveFirst then begin
    if RadioGroup1.ItemIndex = 0 then begin
      if CanContinue then begin
        RemoveEmptyRowStringGrid;
        if AllStringGrids <> nil then begin
          lsgRec.sgShowParentCol := False;
          lsgRec.sgShowChildCol := False;
          FPresenter.SgSetState(@lsgRec, ssRead);

          lBtnRec.btnAddVisible := False;
          lBtnRec.btnSaveVisible := False;
        end;
        FLastRadioGroupIndex := RadioGroup1.ItemIndex;
        FPresenter.SetStatusbartext('', 0);
      end
      else begin
        RadioGroup1.ItemIndex := FLastRadioGroupIndex;
      end;
    end
    else if RadioGroup1.ItemIndex = 1 then begin
      //if not FMustSaveFirst then begin
        if AllStringGrids <> nil then begin
          lsgRec.sgShowParentCol := False;
          lsgRec.sgShowChildCol := False;
          FPresenter.SgSetState(@lsgRec, ssModify);

          lBtnRec.btnAddVisible := True;
          lBtnRec.btnSaveVisible := True;

        end;
        FLastRadioGroupIndex := RadioGroup1.ItemIndex;
      //end
{      else begin
        RadioGroup1.ItemIndex := FLastRadioGroupIndex;
      end; }
    end
    else if RadioGroup1.ItemIndex = 2 then begin
      if not FMustSaveFirst then begin
//      if CanContinue then begin
         RemoveEmptyRowStringGrid;

        if AllStringGrids <> nil then begin
          lsgRec.sgShowParentCol := True;
          lsgRec.sgShowChildCol := True;
          FPresenter.SgSetState(@lsgRec, ssModifyRelations);

          lBtnRec.btnAddVisible := False;
          lBtnRec.btnSaveVisible := True;
        end;
        FLastRadioGroupIndex := RadioGroup1.ItemIndex;
      end
      else begin
        if FLastRadioGroupIndex <> 0 then begin
          lBtnRec.btnAddVisible := True;
          lBtnRec.btnSaveVisible := True;
        end
        else begin
          lBtnRec.btnAddVisible := False;
          lBtnRec.btnSaveVisible := False;
        end;
        messageDlg('Waarschuwing', 'De wijzigingen moeten eerst worden opgeslagen.', mtWarning, [mbOK], 0);
        RadioGroup1.ItemIndex := FLastRadioGroupIndex;
      end;
{      else begin
        RadioGroup1.ItemIndex := FLastRadioGroupIndex;
      end; }
    end
    else begin
      lsgRec.sgShowParentCol := False;
      lsgRec.sgShowChildCol := False;
      FPresenter.SgSetState(@lsgRec, ssRead);

      lBtnRec.btnAddVisible := False;
      lBtnRec.btnSaveVisible := False;
    end;
    ShowNewRowButtons(lBtnRec);
//  end;
{  else begin
    //
    RadioGroup1.ItemIndex := FLastRadioGroupIndex;
  end;}
end;

procedure TfrmViewMain.sbxMainResize(Sender: TObject);
begin
  (sender as TScrollBox).Repaint; // Voorkomt "lijnen" bij aanpassen van splitter positie.
end;

procedure TfrmViewMain.HandleObsNotify(aReason: TProviderReason;
  aNotifyClass: TObject; UserData: pointer);
begin
  case aReason of
    prStaticTexts: DoSetStaticTexts(UserData);
    prStatusBarPanelText: DoSetStatusBarText(UserData);
    prCreateDirs: DoCreateDirs(aNotifyClass,UserData);
    prReadsettings: DoReadsettings(aNotifyClass,UserData);
    prReadFormState : DoReadFormState(aNotifyClass,UserData);
    prCreateDbFile: DoCreateDbFile(aNotifyClass,UserData);
    prOpenDbFile: DoOpenDbFilePrepare(aNotifyClass,UserData);
    prGetAllItems: DoOpenDbFileGetData(aNotifyClass,UserData);
    prClearMainView: DoClearmainView(aNotifyClass,UserData);
    prCreateAppDbMaintainer: DoCreateAppDbMaintainer(aNotifyClass,UserData);
    prSgHeaderFontStyle: DoSetStringGridHeaderFontStyle(aNotifyClass,UserData);
    prSgRemoveEmptyRows: DoRemoveSgEmptyRows(aNotifyClass,UserData);
    prSgAddRow: DoSgAddRow(aNotifyClass,UserData);
    prSgAdjust: DoSgChange(aNotifyClass,UserData);
    prBitBtnShow: DoShowBitBtn(aNotifyClass,UserData);
    prPmiStatus: DoSetupPmiStatus(aNotifyClass,UserData);

    prEnableSaveButton: DoEnableSaveButton(aNotifyClass,UserData);

    prAddNewItem: DoAddNewItem(aNotifyClass,UserData);
    prUpdateItem: DoUpdateItem(aNotifyClass,UserData);
    prDeleteItem: DoDeleteItem(aNotifyClass,UserData);
    prSaveChanges: DoSaveChanges(aNotifyClass,UserData);
    prCheckboxToggled: DoSaveCheckBoxToggled(aNotifyClass,UserData);

    prGetColumnNames : DoGetColumnnames(aNotifyClass,UserData);
  end;
end;

procedure TfrmViewMain.DoSetStatusBarText(aTextRec: PStatusbarPanelText);
begin
  with aTextRec^ do begin
    if sbpt_panel0 <> '' then
      StatusBar1.Panels[0].Text := sbpt_panel0;
    if sbpt_panel1 <> '' then
      StatusBar1.Panels[1].Text := sbpt_panel1;
    if sbpt_panel2 <> '' then
      StatusBar1.Panels[2].Text := sbpt_panel2;

    case sbpt_activePanel of
      0: begin
        if sbpt_panel0 = '' then
          StatusBar1.Panels[0].Text := '';
      end;
      1: begin
        if sbpt_panel1 = '' then
          StatusBar1.Panels[1].Text := '';
      end;
      2: begin
        if sbpt_panel2 = '' then
          StatusBar1.Panels[2].Text := '';
      end;
    end;
  end;
end;

procedure TfrmViewMain.PanelOnResize(Sender: TObject);
begin
  (sender as TPanel).Repaint;
end;

procedure TfrmViewMain.StringGridOnClick(Sender: TObject);
begin
  { #todo : make font color optional. Then this must executed with a trecord }
  if sender is TStringGrid then begin
    FPresenter.SetStringGridHeaderFontStyle(sender, 0);
  end;
end;

procedure TfrmViewMain.StringGridOnExit(Sender: TObject);
begin
  if sender is TStringGrid then begin
    FPresenter.SetStringGridHeaderFontStyle(sender, -1);
  end;
end;

procedure TfrmViewMain.StringGridOnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (RadioGroup1.ItemIndex = 1) or (RadioGroup1.ItemIndex = 2) then begin
    if (Key = VK_TAB) and (Shift = []) then begin
      FPresenter.ActiveStrgridCell(Sender, True)
    end;
  end;
end;

procedure TfrmViewMain.StringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (RadioGroup1.ItemIndex = 1) or (RadioGroup1.ItemIndex = 2) then begin
    if Key = 40 then begin  // Arrow down
      with sender as TStringgrid do begin
        if RowCount-1 = FRow Then  // If the current selected cel is the last row then create a new row. (Else go one row done).
          FPresenter.ActiveStrgridCell(Sender, True);
        end;
      end;

    case Key of
      $53: if ssCtrl in Shift then  begin // ctrl + S ($53 = VK_S ; https://gitlab.com/freepascal.org/lazarus/lazarus/-/blob/main/lcl/lcltype.pp?ref_type=heads#L397)
        if btnSave.Enabled then begin
          //TStringGrid(Sender).Perform(wm_keydown,vk_return,0);
          btnSave.SetFocus;  // remove the focus from the stringgrid. Tehn the cell which is in editmode will be saved too.
          btnSaveClick(Sender);
        end;
      end;
      $49: if ssCtrl in Shift then  begin // CTRL + i
        BitButtonAddOnClick(Sender);
      end;
      $54: if ssCtrl in Shift then  begin // CTRL + t
        BitButtonAddOnClick(Sender);
      end;
      $44 : if ssCtrl in Shift then  begin // CTRL + d
        pmiDeleteItemClick(Sender);
      end;
    end;
  end;
end;

procedure TfrmViewMain.StringGridOnValidateEntry(Sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
var
  lItemRec: TItemTransaction;
  _sg : TStringGrid;
  SelectedItemObject : PtrItemObject;
begin
  self.Caption := 'OldValue: ' +OldValue + '<> NewValue: ' + NewValue;
  _sg := TStringGrid(sender);
  SelectedItemObject := PtrItemObject(_sg.Objects[aCol,aRow]);

  if OldValue <> NewValue then begin
    if (OldValue = '') and (NewValue <> '') then begin  // New item
      try
        // Place the new item in the array with all items. (So it can be saved later).
        lItemRec := fPresenter.TrxMan.StartTransaction(msAddNewItem) as TItemTransaction;

        lItemRec.Name := NewValue;
        lItemRec.Level := StrToInt(FPresenter.ExtractNumberFromString(_sg.Name));
        lItemRec.Action := iaCreate;
        lItemRec.GridObject := _sg;
        lItemRec.MustSave := True;
        lItemRec.Col := aCol;
        lItemRec.Row := aRow;

        FPresenter.TrxMan.CommitTransaction;
      except
        fPresenter.TrxMan.RollbackTransaction;
        FPresenter.SetStatusbartext('Fout bij voorbereiden gegevens nieuw item.',0);
        screen.Cursor := crDefault;
      end;
    end
    else begin  // update
      try
        lItemRec := fPresenter.TrxMan.StartTransaction(msUpdateItem) as TItemTransaction;
        lItemRec.Name := NewValue;
        lItemRec.GridObject := _sg;
        lItemRec.Col := aCol;
        lItemRec.Row := aRow;
        lItemRec.Level := StrToInt(FPresenter.ExtractNumberFromString(_sg.Name));

        if SelectedItemObject <> nil then begin
          lItemRec.Guid := SelectedItemObject^.Guid;
          lItemRec.MustSave := True;

          if SelectedItemObject^.Action = iaRead then begin
            lItemRec.Action := iaUpdate;
          end
          else begin
            lItemRec.Action := SelectedItemObject^.Action;
          end;
        end
        else begin
          EditTmp.Text :=  EditTmp.Text + '==> Oeps, er ging iets fout in onvalidate...';
          fPresenter.TrxMan.RollbackTransaction;
        end;

        FPresenter.TrxMan.CommitTransaction;

      except
        fPresenter.TrxMan.RollbackTransaction;
        FPresenter.SetStatusbartext('Fout bij voorbereiden gegevens: aanpassen item.',0);
        screen.Cursor := crDefault;
      end;
    end;
  end
  else begin
    //
  end;

  // Check for duplicates and enable/disable the save button
  FPresenter.ValidateCellEntry(Sender,btnSave, NewValue, aRow);  // Werkt hier niet goed ?
end;

procedure TfrmViewMain.StringGridOnSelectCell(Sender: TObject; aCol,
  aRow: Integer; var CanSelect: Boolean);
var
  p: PtrItemObject;
  i: Integer;
  lRec : TStringGridSelect;
begin
  { #todo : moet een presenter functie worden }
  if sender is TStringGrid then begin
    FActiveStringGrid :=  TStringGrid(sender);

    FCol := aCol;  // only use(d) for deleting a row
    FRow := aRow;  // only use(d) for deleting a row

    if RadioGroup1.ItemIndex = 0 Then begin
      FAllowCellselectColor := True;
    end
    else begin
      FAllowCellselectColor := False;
    end;

    if PtrItemObject(FActiveStringGrid.Objects[acol,aRow]) <> nil then begin
      p := PtrItemObject(FActiveStringGrid.Objects[acol,aRow]);
      lRec.aRow := aRow;
      lRec.aCol := aCol;
      lRec.aLevel := p^.Level;
      lRec.sgarray := PtrSgArr;
      lRec.Parent_guid := p^.Parent_guid;
      lRec.AllowCellSelectColor :=  FAllowCellselectColor;
      FPresenter.StringGridOnSelectCell(Sender, @lRec);
    end;

    // Temp. Just for checking if the stringgrid cel has an object with data.
    try
      EditTmp.Text :='';
      if PtrItemObject(FActiveStringGrid.Objects[acol,aRow]) <> nil then begin

        p := PtrItemObject(FActiveStringGrid.Objects[acol,aRow]);
        //EditTmp.Text := p^.Name + ', - Level: ' + IntToStr(p^.Level) + ', - actie: ' + p^.Action + ' - rowcount: ' + IntToStr(FActiveStringGrid.RowCount) + '- ' + p^.Guid;

        if length(p^.Parent_guid)> 0 then begin
          for i:=0 to length(p^.Parent_guid)-1 do begin
            EditTmp.Text := EditTmp.Text + p^.Parent_guid[i] + ' -  ';

          end;
        end;
      end
      else begin
        EditTmp.Text := '';
      end;
    finally
      //
    end;
  end;
end;

procedure TfrmViewMain.StringGridMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  s: String;
  lRec : TPmiVisibility;
  aCol, aRow : Integer;
begin
  FActiveStringGrid :=  TStringGrid(sender);  // Also used in the popupmenu delete item option.
  aCol := FActiveStringGrid.Col;
  aRow := FActiveStringGrid.Row;

  if Button = mbLeft then // you have to click on the row before you can delete
    FCanDeletePmi := True;

  If Button = mbRight then begin
    FActiveStringGrid :=  TStringGrid(sender);  // Also used in the popupmenu delete item option.

    // Enable/disable popupmenu item(s).
    s:= FActiveStringGrid.Cells[aCol, aRow];

    if (RadioGroup1.ItemIndex = 1) and (s <> '') then begin
      if FCanDeletePmi then // you have to click on the row before you can delete
        lRec.pmivDeletItem := True
      else
        lRec.pmivDeletItem := False;

      lRec.pmivAddItem := True;
      lRec.pmivImportItems := True;
    end
    else if (RadioGroup1.ItemIndex = 1) and (s = '') then begin
      lRec.pmivDeletItem := False;
      lRec.pmivAddItem := True;
      lRec.pmivImportItems := True;
    end
    else begin
      lRec.pmivDeletItem := False;
      lRec.pmivAddItem := False;
      lRec.pmivImportItems := False;
    end;

    FPresenter.SetPmiState(lRec);
    FCanDeletePmi := False;
  end;
end;

procedure TfrmViewMain.StringGridOnPrepareCanvas(Sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
var
  b: Boolean;
begin
  if RadioGroup1.ItemIndex = 0 then begin
    b := True;
  end
  else if (RadioGroup1.ItemIndex = 1) or (RadioGroup1.ItemIndex = 2) then begin
    b := False;
  end;

  FPresenter.StringGridOnPrepareCanvas(Sender, aCol, aRow, b);
end;

procedure TfrmViewMain.StringGridOnCheckboxToggled(Sender: TObject; aCol,
  aRow: Integer; aState: TCheckboxState);
var
  lTrx : TCheckboxToggleTransaction;
  c, i : Integer;
begin
  // Bepaal de benodigde rij
  for c:=0 to TstringGrid(sender).ColCount-1 do begin
    if PtrItemObject(TstringGrid(sender).Objects[c,aRow]) <> nil then begin
      break; // cell with objectdata is found
    end;
  end;

  if PtrItemObject(TstringGrid(sender).Objects[3,aRow]) <> nil then begin
    try
      ltrx := FPresenter.TrxMan.StartTransaction(msCheckboxToggled) as TCheckboxToggleTransaction;
      ltrx.Col:= aCol;
      ltrx.Row:= aRow;
      ltrx.aGuid:= PtrItemObject(TstringGrid(sender).Objects[c,aRow])^.Guid;  // De reguliere guid wordt de parent voor de childs
      ltrx.AllSGrids := Pointer(AllStringGrids);
      ltrx.aGridPtr:= Sender;
      if aState = cbChecked then begin
        ltrx.CbIsChecked := True;
      end
      else begin
        ltrx.CbIsChecked := False;
      end;
      ltrx.RowObject := PtrItemObject(TstringGrid(sender).Objects[c,aRow]);

      FPresenter.TrxMan.CommitTransaction;
    except
      fPresenter.TrxMan.RollbackTransaction;
      FPresenter.SetStatusbartext('Fout bij het bepalen of er 1 parent is aangevinkt.',0);
      screen.Cursor := crDefault;
    end;
  end
  else begin
    FPresenter.WriteToLog(laError, 'Dit item heeft geen object data. Relaties kan niet worden opgeslagen.' );
    FPresenter.WriteToLog(laError, 'Item : '  + TstringGrid(sender).Name); { #todo : Verbeteren door level toe te voegen. }
    FPresenter.SetStatusbartext('Let op: Dit item heeft geen object data.', 0);
  end;

  // Repaint all stringgrids. This sets the parent checked color again.
  for I:= 0 to length(AllStringGrids)-1 do begin
    AllStringGrids[i].Repaint;
  end;
end;

procedure TfrmViewMain.StringGridOnDrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
var
  lRec : TStringGridSelect;
    p: PtrItemObject;
begin
  if FAllowCellselectColor then begin
    try
      if TStringGrid(sender) = FActiveStringGrid then begin
        if PtrItemObject(FActiveStringGrid.Objects[acol,aRow]) <> nil then begin
          p := PtrItemObject(FActiveStringGrid.Objects[acol,aRow]);

          lRec.aLevel := p^.Level;
          lRec.aRow := aRow;
          lRec.aCol := aCol;
          lRec.sgarray := PtrSgArr;
          lRec.AllowCellSelectColor := FAllowCellSelectColor;
          lRec.RectLeft := aRect.Left;
          lRec.RectTop := aRect.Top;
          lRec.RectRight := aRect.Right;
          lRec.RectBottom := aRect.Bottom;
          lRec.Guid := p^.Guid;
          lRec.sgName := TStringGrid(sender).Name;

          if RadioGroup1.ItemIndex = 0 then begin
            lRec.AllowCellSelectColor := True;
          end
          else begin
            lRec.AllowCellSelectColor := False;
          end;

          if (gdSelected in aState) or (gdFocused in aState) then begin
            FPresenter.StringGridOnDrawCell(Sender, @lRec);
          end;
        end;
      end;
    finally
    end;
  end;

end;

procedure TfrmViewMain.StringGridOnEditingDone(Sender: TObject);
//var
//  tmp:string;
begin
//  tmp:='';
end;

function TfrmViewMain.CanContinue: Boolean;
var
  MsgDlgbuttonSelected : Word;
begin
  // TODO functie van maken via de presenter
  if FMustSaveFirst then begin
    MsgDlgbuttonSelected := MessageDlg('De wijzigingen zijn niet opgeslagen.' + sLineBreak + 'Doorgaan zonder op te slaan?' ,mtConfirmation, [mbYes,mbCancel], 0);
    if MsgDlgbuttonSelected = mrYes then begin
      Result := True;
    end
    else begin
      Result := False;
    end;
  end
  else begin
    Result := True;
  end;
end;

procedure TfrmViewMain.SetColumnHeaderNames;
var
  lRec : TGetColumnNamesTransaction;
begin
  if (AllStringGrids <> nil) and (length(AllStringGrids)>0) then begin
    screen.Cursor := crHourGlass;
    try
      lRec := FPresenter.TrxMan.StartTransaction(msGetColumnnames) as TGetColumnNamesTransaction;
      lRec.NameView := 'MainView';
      FPresenter.TrxMan.CommitTransaction;
      screen.Cursor := crDefault;
    except
      fPresenter.TrxMan.RollbackTransaction;
      FPresenter.SetStatusbartext('Fout bij ophalen Kolomnamen.',0);
      screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfrmViewMain.FormCreate(Sender: TObject);
begin
  AlterSystemMenu(Application_name, Application_version, self.Handle);
  FSubscriber := CreateObsSubscriber(@HandleObsNotify); { we delegate messages }
  Presenter := TPresenter.Create; { we own the presenter }

  FPresenter.SetStatusbarText('Welkom', 0);
  mmiProgramCloseDbFile.Enabled := False;
  ToolButton2.Enabled := False;
  btnSave.Visible := False;
  CheckDirectories;

  if FCanContinue then begin
    FPresenter.ReadSettings(fnMain); // Read settings
    StartLogging;

    //KeyPreview := True;  // For capturing CTRL+S
    FAllowCellselectColor := False;
  end
  else begin
    // disable funtions
  end;
end;

procedure TfrmViewMain.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  StoreFormstate;
  FPresenter.ClearMainView(sbxLeft);
  FPresenter.ClearMainView(sbxmain);
end;

procedure TfrmViewMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if CanContinue then begin
    FAllowCellselectColor := False; // disable draw cells
     CanClose := True;

     // Optimize the app. database.

   end
   else begin
     CanClose := False;
   end;
end;

procedure TfrmViewMain.btnSaveClick(Sender: TObject);
var
  lTrx : TSaveChangesTransaction;
begin
  //RemoveEmptyRowStringGrid;  loopt vast? index out of range ???
  try
    ltrx := FPresenter.TrxMan.StartTransaction(msSaveChanges) as TSaveChangesTransaction;
    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
    FPresenter.SetStatusbartext('Fout bij het opslaan van de gegevens.',0);
    screen.Cursor := crDefault;
  end;
end;

procedure TfrmViewMain.FormDestroy(Sender: TObject);
begin
  if Assigned(FPresenter) then begin
    FPresenter.Provider.UnSubscribe(FSubscriber);
    FSubscriber.Free;
    FPresenter.Free;
  end;
end;

procedure TfrmViewMain.FormShow(Sender: TObject);
begin
  ReadFormState(fnMain);  // Get form position.
end;

procedure TfrmViewMain.mmiOptionsLanguageENClick(Sender: TObject);
begin
  if not mmiOptionsLanguageEN.Checked then begin
    mmiOptionsLanguageEN.Checked := True;
    mmiOptionsLanguageNL.Checked := False;
    FPresenter.WriteToLog(laInformation, 'English language option Enabled');
  end;
  WriteSettings;  // a test to store a seeting from the main view.
end;

procedure TfrmViewMain.mmiOptionsLanguageNLClick(Sender: TObject);
begin
  if not mmiOptionsLanguageNL.Checked then begin
    mmiOptionsLanguageNL.Checked := True;
    mmiOptionsLanguageEN.Checked := False;
    FPresenter.WriteToLog(laInformation, 'Dutch language option Enabled');
  end;
  WriteSettings;
end;

procedure TfrmViewMain.mmiOptionsOptionsClick(Sender: TObject);
var
  frm : TfrmViewConfigure;
begin
  frm := TfrmViewConfigure.Create(Self);
  try
    frm.Presenter := FPresenter;  // Use the same presenter as the MainView.
    frm.ShowModal;
  finally
    frm.Free;

  end;

//  SetColumnHeaderNames;  // Set the (new) header names.
end;

procedure TfrmViewMain.mmiProgramCloseDbFileClick(Sender: TObject);
begin
  if CanContinue then begin
    FPresenter.PrepareCloseDb;
    FPresenter.ClearMainView(sbxLeft);
    FPresenter.ClearMainView(sbxmain);
    FMustSaveFirst := False;
  end;
end;

procedure TfrmViewMain.mmiProgramNewDbFileClick(Sender: TObject);
var
  dbFile : String;
begin
  if CanContinue then begin
    FMustSaveFirst := False;
    dbFile := CreateNewDbFile;

    if dbFile <> '' then begin
      FPresenter.PrepareCloseDb;
      PrepareView(dbFile);
      screen.Cursor := crHourGlass;

      if FCanContinue then begin
        GetAllItemsForStringGrid; // Get the data.
        RadioGroup1.ItemIndex := 0;
        FAllowCellselectColor := False;
      end;
      screen.Cursor := crDefault;
    end;
  end;
end;

function TfrmViewMain.CreateNewDbFile: String;
var
  SaveDialog: TSaveDialog;
  lcdbt : TCreateDbFileTransaction;  // Local Create Database Transaction
  lrecDbFileInfo : TCreDbFileRec;
begin
  Screen.Cursor := crHourGlass;
  FPresenter.SetStatusbartext('Choose a directory', 0);  // Kies een directory
  SaveDialog := TSaveDialog.Create(nil);
  try
    with saveDialog do
      begin
        Title := 'Create new database file.';  // Maak nieuw database bestand.
        InitialDir := ExtractFilePath(Application.ExeName) + adDatabase;
        Filter := 'SQLite db file|*.db';
        DefaultExt := 'db';
        Options := saveDialog.Options + [ofOverwritePrompt, ofNoTestFileCreate];
        if Execute then begin

          lcdbt := fPresenter.TrxMan.StartTransaction(msCreateDbFile) as TCreateDbFileTransaction;

          if not IsFileInUse(saveDialog.FileName) then begin
            // Open form that requests/stores number of columns and the name of the dbfile.
            Screen.Cursor := crDefault;
            // create and open the help form.
            NewDbFileData(saveDialog.FileName, @lrecDbFileInfo);

            if lrecDbFileInfo.cdbfCreateTable then begin
              lcdbt.DirName := saveDialog.FileName;
              lcdbt.FileName := lrecDbFileInfo.cdbfFilename;
              lcdbt.ColumnCount := lrecDbFileInfo.cdbfColumnCount;
              lcdbt.ShortDescription:= lrecDbFileInfo.cdbfShortDescription;

              fPresenter.TrxMan.CommitTransaction;
              Result := saveDialog.FileName;
            end
            else begin
              Result := '';
              fPresenter.TrxMan.RollbackTransaction;
              FCanContinue := False;
            end;
          end
          else begin
            FPresenter.SetStatusbartext('The file is in use and cannot be overwritten.', 0);
            messageDlg('Warning', 'The file is in use and cannot be overwritten.', mtWarning, [mbOK], 0);
          end;
        end
        else begin
          result := '';
          FPresenter.SetStatusbartext('',0);
        end;
      end;
  finally
    SaveDialog.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfrmViewMain.mmiProgramOpenDbFileClick(Sender: TObject);
var
  openDialog : TOpenDialog;
  FileName : String;

  CanSelect : Boolean;
  i: Integer;
begin
  if not FMustSaveFirst then begin
    FPresenter.SetStatusbartext('Openen documentatie bestand...', 0);

    openDialog := TOpenDialog.Create(self);
    openDialog.Title := 'Open een documentatie bestand.';
    openDialog.InitialDir := ExtractFilePath(Application.ExeName) + adDatabase;
    openDialog.Options := [ofFileMustExist];
    openDialog.Filter := 'Documate files|*.db';
    try
      if openDialog.Execute then begin
        FileName := openDialog.FileName;
      end
      else begin
        FileName := '';
        FPresenter.SetStatusbartext('',0);
      end;
    finally
      openDialog.Free;
    end;

    if FileName <> '' then begin
      FPresenter.PrepareCloseDb;
      PrepareView(FileName); // Build the panels, stringgrids etc.
      GetAllItemsForStringGrid; // Get the data.
    end;

    { #todo : Dit zorgt ervoor dat de eerste cel is geselecerteerd na het openen van een db.  Verplaatsen en optioneel maken }
    CanSelect := True;
    for i := 0 to length(AllStringGrids)-1 do begin
      if AllStringGrids[i].RowCount > 1 then begin
        StringGridOnSelectCell(AllStringGrids[i], 3, 1, CanSelect);
        break;
      end;
    end;
    { --- }


    RadioGroup1.ItemIndex := 0;
    FAllowCellselectColor := False;
  end
  else begin
    MessageDlg('let op', 'Er zijn niet opgeslagen wijzigingen. Er kan géén nieuw data bestand worden geopend.', mtInformation, [mbOK],0);
  end;
end;

procedure TfrmViewMain.PrepareView(Filename: String);
var
  lodbt : TOpenDbFilePrepareViewTransaction;
  ParentSingleColumn : Pointer;
  ParentMultipleColumns : Pointer;
begin
  if Filename = '' then exit;

  screen.Cursor := crHourGlass;

  try
    screen.Cursor := crHourGlass;
    FPresenter.SetStatusbartext('Scherm wordt opgebouwd...',0);
    Application.ProcessMessages;

    // Maak eerst een instance van TAppDbMaintainItems worden aangemaakt
    CreateDbItemsMaintainer(Filename); { #todo : Is dit de beste plaats voor deze functie? }

    lodbt := FPresenter.TrxMan.StartTransaction(msOpenDbFilePrepareView) as TOpenDbFilePrepareViewTransaction;

    ParentSingleColumn := sbxLeft;
    ParentMultipleColumns := sbxMain;
    lodbt.PParentSingleColumn := ParentSingleColumn; // scrollbox in transaction zetten. dat is de parent voor de panels en splitters
    lodbt.PParentMultiColumns := ParentMultipleColumns;
    lodbt.Filename := FileName;

    SendMessage(Handle, WM_SETREDRAW, WPARAM(False), 0);  // Disable All redrawing. Form flickers while buildng the controls.
    FPresenter.TrxMan.CommitTransaction;                  // After this DoOpenDbFilePrepare is executed.
    RadioGroup1.ItemIndex := 1; // step 1
    SendMessage(Handle, WM_SETREDRAW, WPARAM(True), 0);   // Enable All redrawing.
    RadioGroup1.ItemIndex := 0; // step 2 to trigger the hiding of the checkbox columns
    self.Repaint;

    if FCanContinue then begin
      mmiProgramCloseDbFile.Enabled := True;
      ToolButton2.Enabled := true;
    end;

    screen.Cursor := crDefault;
  except
    fPresenter.TrxMan.RollbackTransaction;
    FPresenter.SetStatusbartext('',0);
    screen.Cursor := crDefault;
  end;
end;

end.

