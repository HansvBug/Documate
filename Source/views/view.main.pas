unit view.main;
{$mode objfpc}{$H+}
interface
uses Classes, SysUtils, Forms, StdCtrls, Controls, Graphics, Dialogs, ComCtrls,
  ExtCtrls, Menus, Grids, Buttons, Windows,
  istrlist, model.intf, model.decl, presenter.main, View.NewDbFile,
  presenter.trax;

type
  { TfrmMain }

  TfrmMain = class(TForm,IViewMain)
    btnSave: TButton;
    CoolBar1: TCoolBar;
    EditTmp: TEdit;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    mmiProgramSep1: TMenuItem;
    mmiProgramNewFile: TMenuItem;
    mmiProgramCloseFile: TMenuItem;
    mmiProgramOpenFile: TMenuItem;
    mmiOptions: TMenuItem;
    mmiOptionsLanguage: TMenuItem;
    mmiOptionsLanguageEN: TMenuItem;
    mmiOptionsLanguageNL: TMenuItem;
    mmiOptionsOptions: TMenuItem;
    mmiProgram: TMenuItem;
    mmiProgramQuit: TMenuItem;
    PanelItemsTop: TPanel;
    pgcMain: TPageControl;
    pmiAddItem: TMenuItem;
    pmiAutoSizeStringGrid: TMenuItem;
    pmiAutoSizeStringGridAll: TMenuItem;
    pmiDeleteItem: TMenuItem;
    pmiImport: TMenuItem;
    pmiSeparator1: TMenuItem;
    pmiSeparator2: TMenuItem;
    pmMain: TPopupMenu;
    pnlMain: TPanel;
    rgMainViewState: TRadioGroup;
    sbxLeft: TScrollBox;
    sbxMain: TScrollBox;
    splMain: TSplitter;
    stbInfo: TStatusBar;
    ToolBar1: TToolBar;
    tbOpenFile: TToolButton;
    tbCLoseFile: TToolButton;
    tbNewFile: TToolButton;
    ToolButton4: TToolButton;
    tbOptions: TToolButton;
    tsItems: TTabSheet;
    procedure btnSaveClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mmiOptionsLanguageENClick(Sender: TObject);
    procedure mmiOptionsLanguageNLClick(Sender: TObject);
    procedure mmiOptionsOptionsClick(Sender: TObject);
    procedure mmiProgramCloseFileClick(Sender: TObject);
    procedure mmiProgramNewFileClick(Sender: TObject);
    procedure mmiProgramOpenFileClick(Sender: TObject);
    procedure mmiProgramQuitClick(Sender: TObject);
    procedure pmiAddItemClick(Sender: TObject);
    procedure pmiAutoSizeStringGridAllClick(Sender: TObject);
    procedure pmiAutoSizeStringGridClick(Sender: TObject);
    procedure pmiDeleteItemClick(Sender: TObject);
    procedure pmiImportClick(Sender: TObject);
    procedure rgMainViewStateClick(Sender: TObject);
  private
    fPresenter: IPresenterMain;
    fSubscriber: IobsSubscriber;
    FCanContinue : Boolean;
    FMustSaveFirst : Boolean;
    FNumberOfColumns : Integer;
    AllStringGrids : array of TStringGrid;
    PtrSgArr : Array of TObject; // used for stringgridFabric
    AllBitButtonsAdd : array of TBitBtn;
    FActiveStringGrid :  TStringGrid;
    FCol, FRow : Integer; // only use(d) for delete a row
    FAllowCellselectColor : Boolean;
    FCanDeletePmi : Boolean;
    FLastRadioGroupIndex : Byte;

    function get_Observer: IobsSubscriber;
    function get_Presenter: IPresenterMain;
    function Obj: TObject;
    //procedure SetPanelWidth(aPanel: TPanel);
    procedure set_Observer(aValue: IobsSubscriber);
    procedure set_Presenter(aValue: IPresenterMain);

    function CheckLanguageFiles: Boolean;
    procedure SetAppLanguage;
   { Create the necessary directories. }
    procedure CreateDirectories;
    { Read application and user settings }
    procedure ReadSettings;
    procedure WriteSingleSetting(Setting, aValue: String);
    { Write application and user settings }
    procedure WriteSettings;
    procedure StoreFormstate;
    procedure ReadFormState;
    { Start logging. Creates or opens a log file. }
    procedure StartLogging;
    function GetSettingsFile: String;
    function CheckFormIsEntireVisible(Rect: TRect): TRect;
    procedure OpenDbFile(aFileName: String);
    procedure CleanUpDbFile;
    procedure PrepareView(Filename: String);
    procedure CreateDbItemsMaintainer(FileName: String);  // gebruikt FPresenter
    procedure PrepareGlobalComponentArrays;  // Moet beter kunnen
    function GetTheRightStringGid(identifier: Byte; aName : String) : TStringGrid; // gebruikt FPresenter = n.v.t.

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
//    procedure StringGridOnEditingDone(Sender: TObject);

    procedure RemoveEmptyRowStringGrid;  // gebruikt FPresenter
    function CanContinue: Boolean;
    procedure GetAllItemsForStringGrid;  // Transaction
    procedure SetColumnHeaderNames;
    procedure StringgridStateIsRead;
    function CloseDbFile: Boolean;
    function CreateNewDbFile: String;
    procedure ShowNewRowButtons(lBtnRec : TBitBtnRec);
    procedure AlterSystemMenu(AppName, AppVersion : String; hWnd:HWND);
    procedure SetStringGridWidth(anObj: TObject);


  protected
    procedure DoStaticTexts(Texts: IStrings);           
    procedure DoStatus({%H-}anObj: TObject; aData: pointer);
    procedure DoCreateDirs({%H-}anObj: TObject; aDirs: PDirectoriesRec);
    procedure DoAppSettings({%H-}anObj: TObject; Settings: PSettingsRec);
    procedure DoFormState({%H-}anObj: TObject; Settings: PSettingsRec);
    procedure DoStbPanelWidth(anObj: TObject; aData: pointer);
    procedure DoCreateDbFile({%H-}anObj: TObject; DbFileRec: PCreDbFileRec);
    procedure DoOpenDbFilePrepare({%H-}anObj: TObject; DbFileRec: POpenDbFilePrepareViewRec);
    procedure DoCloseDbFile({%H-}anObj: TObject; DbCloseFileRec: PDbFileRec);
    procedure DoGetColumnnames({%H-}anObj: TObject; Collnames: PGetColumnNameRec);
    procedure DoOpenDbFileGetData({%H-}anObj: TObject; aData: POpenDbFileGetDataRec);
    procedure DoRemoveSgEmptyRows({%H-}anObj: TObject; StrinGridrecRec: PStringGridRec);
    procedure DoSgChange({%H-}anObj: TObject; StrinGridrecRec: PStringGridRec);
    procedure DoSgAddRow({%H-}anObj: TObject; StrinGridrecRec: PStringGridRec);
    procedure DoShowBitBtn({%H-}anObj: TObject; BitBtnrec: PBitBtnRec);
    procedure DoSetupPmiStatus({%H-}anObj: TObject; pmiVisibility: PPmiVisibility);
    procedure DoEnableSaveButton({%H-}anObj: TObject; Btnrec: PSaveBtn);
    procedure DoAddNewItem({%H-}anObj: TObject; NewItem: PItemObjectData);
    procedure DoUpdateItem({%H-}anObj: TObject; NewItem: PItemObjectData);
    procedure DoDeleteItem({%H-}anObj: TObject; DeleteItem: PItemObjectData);
    procedure DoSaveChanges({%H-}anObj: TObject; SaveChanges: PSaveChangesRec);
    procedure DoSaveCheckBoxToggled({%H-}anObj: TObject; CheckBoxToggled: PCheckBoxCellPosition);


    procedure HandleObsNotify(aReason: ptrint; aNotifyClass: TObject; UserData: pointer);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    property Observer: IobsSubscriber read get_Observer write set_Observer;
    property Presenter: IPresenterMain read get_Presenter write set_Presenter;
  end;

var
  frmMain: TfrmMain;

implementation
uses obs_prosu, view.configure;
{$R *.lfm}

{ TfrmMain }
{$Region 'getter/setter'}

function TfrmMain.get_Observer: IobsSubscriber;
begin
  Result:= fSubscriber;
end;

function TfrmMain.get_Presenter: IPresenterMain;
begin
  Result:= fPresenter;
end;

function TfrmMain.Obj: TObject;
begin
  Result:= Self;
end;

procedure TfrmMain.set_Observer(aValue: IobsSubscriber);
begin
  if aValue <> nil then begin
    if fSubscriber <> nil then begin // trying to avoid dangling refs
      if Assigned(fPresenter) then fPresenter.Provider.UnSubscribe(fSubscriber);
      fSubscriber.Obj.Free;
    end;
    fSubscriber:= aValue;
    if Assigned(fSubscriber) then begin
      fSubscriber.SetUpdateSubscriberMethod(@HandleObsNotify);
      if Assigned(fPresenter) then fPresenter.Provider.Subscribe(fSubscriber);
    end;
  end; /// we don't care for nil 'cause we need the observer/subscriber to function at all!
end;

procedure TfrmMain.set_Presenter(aValue: IPresenterMain);
begin
  if aValue <> nil then begin
    if Assigned(fPresenter) then begin
      fPresenter.Provider.UnSubscribe(fSubscriber); { no dangling subscriptions }
      fPresenter.Obj.Free;
    end;
    fPresenter:= aValue;
    fPresenter.Provider.Subscribe(fSubscriber);
    fPresenter.GetStaticTexts(UnitName); { important startup-code }
    // etc...
  end else begin //aValue = nil
    if Assigned(fPresenter) then fPresenter.Obj.Free;
    fPresenter:= aValue; // ~ nil
  end;
end;

{$EndRegion 'getter/setter'}

{$Region 'subscriber-events'}
procedure TfrmMain.DoStaticTexts(Texts: IStrings);
var
  i: integer;
  lc: TComponent;
  sl: TStringList;
begin
  Caption:= Texts.Values[Name];
  for i:= 0 to ComponentCount-1 do begin
    lc:= Components[i];
    if (lc is TMenuItem) then
      TMenuItem(lc).Caption:= Texts.Values[TMenuItem(lc).Name];
    if (lc is TButton) then
      TButton(lc).Caption:= Texts.Values[TButton(lc).Name];
    if (lc is TTabSheet) Then
      TTabSheet(lc).Caption:= Texts.Values[TTabSheet(lc).Name];
    if (lc is TRadioGroup) then begin
      sl := TStringList.Create;
      sl.Add(Texts.Values['rgMainViewItem1']);
      sl.Add(Texts.Values['rgMainViewItem2']);
      sl.Add(Texts.Values['rgMainViewItem3']);
      TRadioGroup(lc).Items:= sl;
      sl.Free;
    end;
    if (lc is TToolButton) then
      TToolButton(lc).Hint:= Texts.Values[TToolButton(lc).Name];
    end;
end;

procedure TfrmMain.DoStatus(anObj: TObject; aData: pointer);
begin { in case of extended status object present }
  with PStatusbarPanelText(aData)^ do begin
    stbInfo.Panels[stbActivePanel].Text := stbPanelText;
    Application.ProcessMessages;
  end;
end;

procedure TfrmMain.DoCreateDirs(anObj: TObject; aDirs: PDirectoriesRec);
begin
  FCanContinue := aDirs^.dirSucces;
  if not FCanContinue then begin
    //DisableFuncions;
    FPresenter.SetStatusbarText(aDirs^.dirSuccesMsg, 0);
    messageDlg(fpresenter.GetstaticText(UnitName, 'MsgWarning'), fPresenter.GetstaticText(UnitName, 'MsgWarnCreateDir') + sLineBreak
    + sLineBreak + fPresenter.GetstaticText(UnitName, 'Error') + ': ' + aDirs^.dirSuccesMsg
    , mtError, [mbOK],0);
  end;
end;

procedure TfrmMain.DoAppSettings(anObj: TObject; Settings: PSettingsRec);
begin
  with Settings^ do begin

    if setReadSettings then begin
      if not setSucces then begin
        FPresenter.SetStatusbarText(fPresenter.GetstaticText('view.main.StatusbarTexts', 'ErrorReadSettings'), 0);
      end
      else begin
        if (setLanguage = 'en') or (setLanguage = '') then begin
          mmiOptionsLanguageEN.Checked:= True;
          mmiOptionsLanguageNL.Checked:= False;
        end
        else if setLanguage = 'nl' then begin
          mmiOptionsLanguageEN.Checked:= False;
          mmiOptionsLanguageNL.Checked:= True;
        end;
      end;
    end;

    if setWriteSettings then begin
      if not setSucces then begin
        FPresenter.SetStatusbarText(fPresenter.GetstaticText('view.main.StatusbarTexts', 'ErrorStoreSettings'), 0);
      end;
    end;

  end;
end;

procedure TfrmMain.DoFormState(anObj: TObject; Settings: PSettingsRec);
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

procedure TfrmMain.DoStbPanelWidth(anObj: TObject; aData: pointer);
begin
  with PStbPanelsSize(aData)^ do begin
    TStatusbar(anObj).Panels[1].Width:= mpWidth;
  end;
end;

procedure TfrmMain.DoCreateDbFile(anObj: TObject; DbFileRec: PCreDbFileRec);
begin
  if DbFileRec^.cdbfSucces then begin
    ShowMessage(DbFileRec^.cdbfMessage);
    fPresenter.Model.DbFullFilename:= DbFileRec^.cdbfFilename; // used when opening another dbfile.       { #todo : Nakijken, is dit nog nodig? }
    FNumberOfColumns:= DbFileRec^.cdbfColumnCount;  // used when after the creation the file is opened    { #todo : Nakijken, is dit nog nodig? }
  end
  else begin
    if not DbFileRec^.cdbfSQLiteFileFound then begin
      messageDlg('Error', DbFileRec^.cdbfMessage, mtError, [mbOK],0);
    end
    else
      messageDlg('Error', DbFileRec^.cdbfMessage, mtError, [mbOK],0);
  end;
end;

procedure TfrmMain.DoOpenDbFilePrepare(anObj: TObject;
  DbFileRec: POpenDbFilePrepareViewRec);
begin
  screen.Cursor:= crHourGlass;

  if DbFileRec^.odbfSucces then begin
    FCanContinue := True;
    PrepareGlobalComponentArrays;
    FNumberOfColumns := DbFileRec^.odbfColumnCount;

    FPresenter.SetStatusbartext('', 0);
    FPresenter.SetStatusbartext(fPresenter.GetstaticText('view.main.StatusbarTexts', 'File') + DbFileRec^.odbfFileName + '     ', 2);
  end
  else begin
    FCanContinue := False;
    FPresenter.SetStatusbartext(fPresenter.GetstaticText('view.main.StatusbarTexts', 'ErrorBuildingView'), 0);
    FPresenter.SetStatusbartext(fPresenter.GetstaticText('view.main.StatusbarTexts', 'File') + '-     ', 2);
  end;

  screen.Cursor := crDefault;
end;

procedure TfrmMain.DoCloseDbFile(anObj: TObject; DbCloseFileRec: PDbFileRec);
begin
  if DbCloseFileRec^.dbfIsClosed then begin
    FPresenter.SetStatusbarText('',2);
    fPresenter.Model.DbFullFilename:= '';
    mmiProgramCloseFile.Enabled:= False;
//    tbCloseFile.Enabled:= False;
//    btNewItem.Enabled:= False;
//    StringGrid1.OnSelectCell:= nil;
  end;
end;

procedure TfrmMain.DoGetColumnnames(anObj: TObject; Collnames: PGetColumnNameRec
  );
var
  i: Integer;
begin
  if Collnames = nil then exit;

  with PGetColumnNameRec(Collnames)^ do begin
    if (AllColNames <> Nil) and (length(AllColNames)>0) then begin
      for i:= 0 to Length(AllStringGrids)-1 do begin
        AllStringGrids[i].Columns.Items[2].Title.Caption:= AllColNames[i].Value;  { #todo : moet een const worden }
      end;
    end;
  end;
end;

procedure TfrmMain.DoOpenDbFileGetData(anObj: TObject;
  aData: POpenDbFileGetDataRec);
begin
  if aData^.gdSucces then begin
    RemoveEmptyRowStringGrid;
  end
  else begin
    FCanContinue:= False;
    fPresenter.SetStatusbarText(fPresenter.GetstaticText('view.main.StatusbarTexts', 'ErrorGettingdata'), 0);
  end;
end;

procedure TfrmMain.DoRemoveSgEmptyRows(anObj: TObject;
  StrinGridrecRec: PStringGridRec);
var
  aRow: Integer;
begin
  if TStringGrid(anObj).RowCount > 0 then begin
    for aRow := 1 to TStringGrid(anObj).RowCount-1 do begin
      if TStringGrid(anObj).Cells[3,aRow] = '' then begin
        TStringGrid(anObj).DeleteRow(aRow);
      end;
    end;
  end;
end;

procedure TfrmMain.DoSgChange(anObj: TObject; StrinGridrecRec: PStringGridRec);
var
  i: Integer;
begin
  { #todo : Dat kan naar stringgrid fabric }
  with PStringGridRec(StrinGridrecRec)^ do begin
      for i:= 0 to length(AllStringGrids)-1 do begin

        if sgState = ssRead then begin
          AllStringGrids[i].ColWidths[0] := 10;
          AllStringGrids[i].AutoFillColumns := True;
          AllStringGrids[i].Options := AllStringGrids[i].Options - [goEditing, goAutoAddRows];
          AllStringGrids[i].FocusColor := clRed;
        end
        else if sgState = ssModify then begin
          AllStringGrids[i].ColWidths[0] := 10;
          AllStringGrids[i].AutoFillColumns := True;
          AllStringGrids[i].Options := AllStringGrids[i].Options + [goEditing, goAutoAddRows, goTabs];  //goTabs goRowSelect = blue color
          AllStringGrids[i].FocusColor := clRed;
        end
        else if sgState = ssModifyRelations then begin
          AllStringGrids[i].AutoFillColumns := False;
          //self.Caption := 'Colcount: ' + IntToStr(AllStringGrids[i].ColCount);
          AllStringGrids[i].ColWidths[0] := 10;
          AllStringGrids[i].ColWidths[1] := 60;
          AllStringGrids[i].ColWidths[2] := 60;
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

procedure TfrmMain.DoSgAddRow(anObj: TObject; StrinGridrecRec: PStringGridRec);
begin
  with anObj as TStringGrid do begin
    if PStringGridRec(StrinGridrecRec)^.sgAddExtraRow then begin
      RowCount := RowCount + 1;
    end;
  end;
end;

procedure TfrmMain.DoShowBitBtn(anObj: TObject; BitBtnrec: PBitBtnRec);
begin
  with PBitBtnRec(BitBtnrec)^ do begin
    TBitBtn(anObj).Visible:= btnAddVisible;
    btnSave.Visible := btnSaveVisible;
  end;
end;

procedure TfrmMain.DoSetupPmiStatus(anObj: TObject;
  pmiVisibility: PPmiVisibility);
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

procedure TfrmMain.DoEnableSaveButton(anObj: TObject; Btnrec: PSaveBtn);
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

procedure TfrmMain.DoAddNewItem(anObj: TObject; NewItem: PItemObjectData);
var
  pItem : PItemObjectData;
  _sg : TStringGrid;
begin
  with PItemObjectData(NewItem)^ do begin
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

procedure TfrmMain.DoUpdateItem(anObj: TObject; NewItem: PItemObjectData);
var
  ExistingItem : PItemObjectData;
  _sg : TStringGrid;
begin
  with PItemObjectData(NewItem)^ do begin
    if GridObject <> nil then begin
      _sg := TStringGrid(GridObject);
      ExistingItem := PItemObjectData(_sg.Objects[sgCol, sgRow]);

      if ExistingItem^.Guid = Guid Then begin
        ExistingItem^.Name := Name;
        ExistingItem^.Action := Action;

        // Change the StringGrid row object.
        _sg.Objects[sgCol, sgRow] := TObject(ExistingItem);
      end
      else begin
        FPresenter.SetStatusbartext('item is niet bijgewerkt, zie log bestand', 1 );
        FPresenter.WriteToLog(UnitName, laDebug, 'guid stringgrid: ' + ExistingItem^.Guid + ' guid update aangeboden: ' +  Guid);
        FPresenter.WriteToLog(UnitName, laDebug, 'rij stringgrid: ' + IntToStr(ExistingItem^.sgRow) + ' rij update aangeboden: ' +  IntToStr(sgRow));
        FPresenter.WriteToLog(UnitName, laDebug, 'col stringgrid: ' + IntToStr(ExistingItem^.sgCol) + ' col update aangeboden: ' +  IntToStr(sgCol));
        FPresenter.WriteToLog(UnitName, laDebug, '');
      end;
    end;
    FMustSaveFirst := MustSave;
    FPresenter.SetStatusbartext('Niet opgeslagen wijzigingen aanwezig.', 0);
  end;
end;

procedure TfrmMain.DoDeleteItem(anObj: TObject; DeleteItem: PItemObjectData);
var
  _sg : TStringGrid;
begin
  with PItemObjectData(DeleteItem)^ do begin
    if GridObject <> nil then begin
      _sg := TStringGrid(GridObject);

      // Remove the oject
      if PItemObjectData(_sg.Objects[sgCol,sgRow]) <> nil then begin
        Dispose(PItemObjectData(_sg.Objects[sgCol,sgRow]));
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

procedure TfrmMain.DoSaveChanges(anObj: TObject; SaveChanges: PSaveChangesRec);
var
  i : Integer;
  aCol, aRow: Integer;
  pItem : PItemObjectData;
begin
  with PSaveChangesRec(SaveChanges)^ do begin
    if scSuccess then begin

      // Update all SrtringGrid Row objects
      { #todo : Op deze manier gaat opslaan steeds langen duren. anders opzetten. En past op deze manier niet in mvp model}
      for i:=0 to Length(AllStringGrids)-1 do begin
        for aRow:=0 to AllStringGrids[i].RowCount-1 do begin
          for aCol:=0 to AllStringGrids[i].ColCount-1 do begin
            pItem := PItemObjectData(AllStringGrids[i].Objects[acol,aRow]);
            if pItem <> nil then begin
              if pItem^.Action <> iaRead then begin
                PItemObjectData(AllStringGrids[i].Objects[acol,aRow])^.Action := iaRead;
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

procedure TfrmMain.DoSaveCheckBoxToggled(anObj: TObject;
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

procedure TfrmMain.HandleObsNotify(aReason: ptrint; aNotifyClass: TObject; UserData: pointer);
begin
  case aReason of
    prMainStaticTexts: DoStaticTexts(IStringList(UserData)); { important startup-code }
    prStatus: if aNotifyClass = nil then
                stbInfo.Panels[0].Text:= Pch2Str(UserData)
              else DoStatus(aNotifyClass,UserData);
    prStatusBarPanelText  : DoStatus(aNotifyClass,UserData);
    prCreateDir           : DoCreateDirs(aNotifyClass,UserData);
    prAppSettings         : DoAppSettings(aNotifyClass,UserData);
    prFormState           : DoFormState(aNotifyClass,UserData);
    prStatusBarPanelWidth : DoStbPanelWidth(aNotifyClass,UserData);
    prCreDatabaseFile     : DoCreateDbFile(aNotifyClass,UserData);
    prOpenDbFile          : DoOpenDbFilePrepare(aNotifyClass,UserData);
    prCloseDatabaseFile   : DoCloseDbFile(aNotifyClass,UserData);  // nodig?
    prGetColumnNames      : DoGetColumnnames(aNotifyClass,UserData);
    prGetAllItems         : DoOpenDbFileGetData(aNotifyClass,UserData);
    prSgRemoveEmptyRows   : DoRemoveSgEmptyRows(aNotifyClass,UserData);
    prSgAdjust            : DoSgChange(aNotifyClass,UserData);
    prSgAddRow            : DoSgAddRow(aNotifyClass,UserData);


    prBitBtnShow          : DoShowBitBtn(aNotifyClass,UserData);
    prPmiStatus           : DoSetupPmiStatus(aNotifyClass,UserData);   // not used

    prEnableSaveButton    : DoEnableSaveButton(aNotifyClass,UserData);

    prAddNewItem          : DoAddNewItem(aNotifyClass,UserData);
    prUpdateItem          : DoUpdateItem(aNotifyClass,UserData);
    prDeleteItem          : DoDeleteItem(aNotifyClass,UserData);
    prSaveChanges         : DoSaveChanges(aNotifyClass,UserData);
    prCheckboxToggled     : DoSaveCheckBoxToggled(aNotifyClass,UserData);
  end;
end;
{$EndRegion 'subscriber-events'}

procedure TfrmMain.AfterConstruction;
begin
  inherited AfterConstruction; { now, everything is said & done, we're ready to show }
  self.Color:= clWindow;
  mmiProgramCloseFile.Enabled:= False;
  tbCLoseFile.Enabled:= False;
  rgMainViewState.Enabled:= False;
  btnSave.Enabled:= False;
  FCanContinue:= CheckLanguageFiles;

  if FCanContinue then begin
    SetAppLanguage; // Read the language setting in the settings file. If no file was found, English is the default.

    fSubscriber:= CreateObsSubscriber(@HandleObsNotify); //bm: fPresenter.Provider
    Presenter:= CreatePresenterMain(''); // should take care of subscribing etc.
    CreateDirectories;  // sets FCanContinue to true if dirs exists or are created.
  end;

  if FCanContinue then begin
    ReadSettings;
    StartLogging;
  end;

  fPresenter.SetStatusbarPanelsWidth(stbInfo, stbInfo.Width, stbInfo.Panels[0].Width, stbInfo.Panels[2].Width);

  if not FCanContinue then begin
    // disable controles
  end;
end;

procedure TfrmMain.BeforeDestruction;
begin
  StoreFormstate;  // Store form position and size.

  if fSubscriber <> nil then begin
    if fPresenter <> nil then fPresenter.Provider.UnSubscribe(fSubscriber);
    fSubscriber.Obj.Free; fSubscriber:= nil;
  end;
  if fPresenter <> nil then fPresenter.Obj.Free; fPresenter:= nil;

  inherited BeforeDestruction;
end;

procedure TfrmMain.mmiProgramQuitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.pmiAddItemClick(Sender: TObject);
begin
  // TODO
  ShowMessage('Not yet implemented.');
end;

procedure TfrmMain.pmiAutoSizeStringGridAllClick(Sender: TObject);
begin
  SetStringGridWidth(nil);
end;

procedure TfrmMain.pmiAutoSizeStringGridClick(Sender: TObject);
begin
  SetStringGridWidth(FActiveStringGrid);
end;

procedure TfrmMain.pmiDeleteItemClick(Sender: TObject);
var
  ExistingItem : PItemObjectData;
  lItemRec: TDeleteItemTransaction;
begin
  if FActiveStringgrid <> nil then begin
    if (rgMainViewState.ItemIndex = 1) or (rgMainViewState.ItemIndex = 2) then begin
      if MessageDlg('Wilt u het volgende item verwijderen: ' + sLineBreak + sLineBreak +
         FActiveStringgrid.Cells[FCol, FRow] ,
         mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
        begin
          try
            ExistingItem := PItemObjectData(FActiveStringgrid.Objects[FCol, FRow]);

            if ExistingItem <> nil then begin
              lItemRec := fPresenter.TrxMan.StartTransaction(prDeleteItem) as TDeleteItemTransaction;

              lItemRec.Action := iaDelete;
              lItemRec.Col := FCol;
              lItemRec.Row := FRow;
              lItemRec.GridObject := FActiveStringgrid;
              lItemRec.Guid := ExistingItem^.Guid;
              lItemRec.Name := ExistingItem^.Name;

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

procedure TfrmMain.pmiImportClick(Sender: TObject);
begin
  // TODO
  ShowMessage('Not yet implemented.');
end;

procedure TfrmMain.rgMainViewStateClick(Sender: TObject);
var
  lsgRec : TStringGridRec;
  lBtnRec : TBitBtnRec;
begin
  FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   01');
  FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  01');
  FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  01');
  if Length(AllStringGrids)> 0 then begin
  //  if not FMustSaveFirst then begin
      if rgMainViewState.ItemIndex = 0 then begin
        FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   02');
        FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  02');
        if CanContinue then begin
          FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   03');
          FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  03');
          RemoveEmptyRowStringGrid;
          if AllStringGrids <> nil then begin
            lsgRec.sgShowParentCol := False;
            lsgRec.sgShowChildCol := False;
            FPresenter.SgSetState(@lsgRec, ssRead);

            lBtnRec.btnAddVisible := False;
            lBtnRec.btnSaveVisible := False;
          end;

          FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   04');
          FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  04');
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  04');

          FLastRadioGroupIndex := rgMainViewState.ItemIndex;
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  04a');
          FPresenter.SetStatusbartext('', 0);
        end
        else begin
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  05');
          rgMainViewState.ItemIndex := FLastRadioGroupIndex;
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  05a');

          FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   05');
          FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  05');

        end;
      end
      else if rgMainViewState.ItemIndex = 1 then begin
        FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   06');
        FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  06');
        //if not FMustSaveFirst then begin
          if AllStringGrids <> nil then begin
            lsgRec.sgShowParentCol := False;
            lsgRec.sgShowChildCol := False;
            FPresenter.SgSetState(@lsgRec, ssModify);

            lBtnRec.btnAddVisible := True;
            lBtnRec.btnSaveVisible := True;

          end;
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  06');
          FLastRadioGroupIndex := rgMainViewState.ItemIndex;
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  06a');

          FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   07');
          FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  07');

      end
      else if rgMainViewState.ItemIndex = 2 then begin
        FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   08');
        FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  08');

        if not FMustSaveFirst then begin
           RemoveEmptyRowStringGrid;

          if AllStringGrids <> nil then begin
            lsgRec.sgShowParentCol := True;
            lsgRec.sgShowChildCol := True;
            FPresenter.SgSetState(@lsgRec, ssModifyRelations);

            lBtnRec.btnAddVisible := True;
            lBtnRec.btnSaveVisible := True;
          end;
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  08');
          FLastRadioGroupIndex := rgMainViewState.ItemIndex;
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  08a');

          FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   09');
          FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  09');

        end
        else begin
          FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   10');
          FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  10');

          if FLastRadioGroupIndex <> 0 then begin
            FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   11');
            FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  11');
            FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  11');
            lBtnRec.btnAddVisible := True;
            lBtnRec.btnSaveVisible := True;
          end
          else begin
            FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   12');
            FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  12');
            FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  12');

            lBtnRec.btnAddVisible := False;
            lBtnRec.btnSaveVisible := False;
          end;
          FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   13');
          FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  13');
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  13');

          messageDlg(fPresenter.GetstaticText(UnitName, 'MsgWarning'), fPresenter.GetstaticText(UnitName, 'MsgSaveModifications'), mtWarning, [mbOK], 0);
          rgMainViewState.ItemIndex := FLastRadioGroupIndex;
          FPresenter.WriteToLog(UnitName, laDebug, 'FLastRadioGroupIndex: ' +  IntToStr(FLastRadioGroupIndex) + '  13a');
        end;
      end
      else begin
        FPresenter.WriteToLog(UnitName, laDebug, 'rgMainViewStateClick   14');
        FPresenter.WriteToLog(UnitName, laDebug, 'itemidex: ' +  IntToStr(rgMainViewState.ItemIndex) + '  14');

        lsgRec.sgShowParentCol := False;
        lsgRec.sgShowChildCol := False;
        FPresenter.SgSetState(@lsgRec, ssRead);

        lBtnRec.btnAddVisible := False;
        lBtnRec.btnSaveVisible := False;
      end;
      ShowNewRowButtons(lBtnRec);
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  if FCanContinue then ReadFormState;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  fPresenter.SetStatusbarPanelsWidth(stbInfo, stbInfo.Width, stbInfo.Panels[0].Width, stbInfo.Panels[2].Width);
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
var
  lTrx : TSaveChangesTransaction;
begin
  RemoveEmptyRowStringGrid;
  try
    ltrx := FPresenter.TrxMan.StartTransaction(prSaveChanges) as TSaveChangesTransaction;
    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
    FPresenter.SetStatusbartext('Fout bij het opslaan van de gegevens.',0);
    screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:= CloseDbFile;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  AlterSystemMenu(ApplicationName, Application_version, self.Handle);
end;

procedure TfrmMain.mmiOptionsLanguageENClick(Sender: TObject);
begin
  Lang:= 'en';
  fPresenter.SwitchLanguage(UnitName);

  if not mmiOptionsLanguageEN.Checked then begin
    mmiOptionsLanguageEN.Checked := True;
    mmiOptionsLanguageNL.Checked := False;
    FPresenter.WriteToLog(UnitName, laInformation, 'Switchlanguage'); //'English language option Enabled'
    WriteSingleSetting('Language', Lang);
  end;
end;

procedure TfrmMain.mmiOptionsLanguageNLClick(Sender: TObject);
begin
  Lang:= 'nl';
  fPresenter.SwitchLanguage(UnitName);

  if not mmiOptionsLanguageNL.Checked then begin
    mmiOptionsLanguageNL.Checked := True;
    mmiOptionsLanguageEN.Checked := False;
    FPresenter.WriteToLog(UnitName, laInformation, 'Switchlanguage' ); //'Dutch language option Enabled'
    WriteSingleSetting('Language', Lang);
  end;
end;

procedure TfrmMain.mmiOptionsOptionsClick(Sender: TObject);
begin
  SetUpConfigureView(fPresenter); // start the configure (options) form.
  ReadSettings;
  SetColumnHeaderNames;  // Set the (new) header names.
end;

procedure TfrmMain.mmiProgramCloseFileClick(Sender: TObject);
begin
  CloseDbFile;
end;

procedure TfrmMain.mmiProgramNewFileClick(Sender: TObject);
begin
  if CanContinue then begin
    FMustSaveFirst := False;

    if FPresenter.Model.DbFullFilename <> '' then begin
      CloseDbFile;
    end;

    FPresenter.Model.DbFullFilename := CreateNewDbFile;  // Create the new file

    if FPresenter.Model.DbFullFilename <> '' then begin
      screen.Cursor := crHourGlass;


      PrepareView(FPresenter.Model.DbFullFilename);

      if FCanContinue then begin
        GetAllItemsForStringGrid; // Get the data.
        rgMainViewState.Enabled:= True;
        rgMainViewState.ItemIndex := 1;  // Go direct into the add mode.
        FAllowCellselectColor := False;
      end;
      screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfrmMain.mmiProgramOpenFileClick(Sender: TObject);
var
  openDialog: TOpenDialog;
  FileName: String;
begin
  fPresenter.SetStatusbartext('OpenDbFile', 0);

  openDialog := TOpenDialog.Create(self);
  openDialog.Title := fPresenter.GetstaticText('view.main.StatusbarTexts', 'OpenDbFile');
  openDialog.InitialDir:= SysUtils.GetEnvironmentVariable('appdata') + PathDelim + ApplicationName + PathDelim + adDatabase;
  openDialog.Options := [ofFileMustExist];
  openDialog.Filter := 'Documate files|*.db';
  try
    if openDialog.Execute then begin
      FileName := openDialog.FileName;
      OpenDbFile(FileName);
    end
    else begin
      FileName := '';
      FPresenter.SetStatusbartext('',0);
    end;
  finally
    openDialog.Free;
  end;
end;

procedure TfrmMain.OpenDbFile(aFileName: String);
begin
  if aFileName <> '' then begin
    if fPresenter.Model.DbFullFilename <> '' then begin  // First close the previous opened database.

      CleanUpDbFile;  // Optimize the open dbase before closing.
      FPresenter.PrepareCloseDb;
      fPresenter.Model.DbFullFilename := '';
      AllStringGrids := Nil;
    end;

    fPresenter.Model.DbFullFilename := aFileName;
    PrepareView(aFileName); // Build the panels, stringgrids etc.
    GetAllItemsForStringGrid; // Get the data.

    rgMainViewState.Enabled:= True;
    rgMainViewState.ItemIndex := 0;
    if not FCanContinue then begin
      //disable functions
      { #todo : insert disableFunctions }
    end;
  end;
end;

procedure TfrmMain.CleanUpDbFile;
begin
  // Optimize the app. database.
  //FPresenter.SetStatusbartext(GetstaticText('view.main.StatusbarTexts', 'DbCleanUp'), 0);
  if fPresenter.Model.DbFullFilename <> '' then begin
    FPresenter.DbResetAutoIncrementAll(fPresenter.Model.DbFullFilename);
    FPresenter.DbOptimize(fPresenter.Model.DbFullFilename);
    FPresenter.DbCompress(fPresenter.Model.DbFullFilename);
    //FPresenter.SetStatusbartext('', 0);
  end;
end;

procedure TfrmMain.PrepareView(Filename: String);
var
  lodbt : TOpenDbFilePrepareViewTransaction;
  ParentSingleColumn : Pointer;
  ParentMultipleColumns : Pointer;
begin
  if Filename = '' then exit;

  screen.Cursor := crHourGlass;

  try
    screen.Cursor := crHourGlass;
    FPresenter.SetStatusbartext(fPresenter.GetstaticText('view.main.StatusbarTexts', 'BuildingTheView'), 0);

    // Maak eerst een instance van TAppDbMaintainItems worden aangemaakt
    CreateDbItemsMaintainer(Filename); { #todo : Is dit de beste plaats voor deze functie? }

    lodbt := FPresenter.TrxMan.StartTransaction(prOpenDbFilePrepareView) as TOpenDbFilePrepareViewTransaction;

    ParentSingleColumn := sbxLeft;
    ParentMultipleColumns := sbxMain;
    lodbt.PParentSingleColumn := ParentSingleColumn; // Scrollbox in transaction zetten. Dat is de parent voor de panels en splitters.
    lodbt.PParentMultiColumns := ParentMultipleColumns;
    lodbt.Filename := FileName;

    SendMessage(Handle, WM_SETREDRAW, WPARAM(False), 0);  // Disable All redrawing. Form flickers while buildng the controls.
    FPresenter.TrxMan.CommitTransaction;                  // After this DoOpenDbFilePrepare is executed.
    SendMessage(Handle, WM_SETREDRAW, WPARAM(True), 0);   // Enable All redrawing.
    screen.Cursor := crHourGlass;
    self.Repaint;

    if FCanContinue then begin
      mmiProgramCloseFile.Enabled := True;
      tbCLoseFile.Enabled := true;
    end;

    screen.Cursor := crDefault;
  except
    fPresenter.TrxMan.RollbackTransaction;
    FPresenter.SetStatusbartext('',0);
    screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.CreateDbItemsMaintainer(FileName: String);
var
  ltrx : TCreateAppDbMaintainerTransaction;
begin
  // Create a TAppDbMaintainItems reference. This will live until a new db file is openend or created.
  if FileName = '' then exit;

  try
    ltrx := FPresenter.TrxMan.StartTransaction(prCreateAppDbReference) as TCreateAppDbMaintainerTransaction;
    ltrx.FileName := FileName;
    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
    fPresenter.GetstaticText('view.main.StatusbarTexts', 'ErrorCreateApDbObject');
    screen.Cursor := crDefault;
  end;
end;

procedure TfrmMain.PrepareGlobalComponentArrays;
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

function TfrmMain.GetTheRightStringGid(identifier: Byte; aName: String
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

procedure TfrmMain.BitButtonAddOnClick(Sender: TObject);
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

procedure TfrmMain.PanelOnResize(Sender: TObject);
begin
  (sender as TPanel).Repaint;
end;

procedure TfrmMain.StringGridOnClick(Sender: TObject);
begin
  { #todo : make font color optional. Then this must executed with a trecord }
  if sender is TStringGrid then begin
    FPresenter.SetStringGridHeaderFontStyle(sender, 0);
  end;
end;

procedure TfrmMain.StringGridOnExit(Sender: TObject);
begin
  if sender is TStringGrid then begin
    FPresenter.SetStringGridHeaderFontStyle(sender, -1);
  end;
end;

procedure TfrmMain.StringGridOnKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (rgMainViewState.ItemIndex = 1) or (rgMainViewState.ItemIndex = 2) then begin
    if (Key = VK_TAB) and (Shift = []) then begin
      FPresenter.ActiveStrgridCell(Sender, True)
    end;
  end;
end;

procedure TfrmMain.StringGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (rgMainViewState.ItemIndex = 1) or (rgMainViewState.ItemIndex = 2) then begin
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

procedure TfrmMain.StringGridOnValidateEntry(Sender: TObject; aCol,
  aRow: Integer; const OldValue: string; var NewValue: String);
var
  lNewItemRec: TNewItemTransaction;
  lUpdateItemRec: TUpdateItemTransaction;
  _sg : TStringGrid;
  SelectedItemObject : PItemObjectData;
begin
  self.Caption := 'OldValue: ' +OldValue + '<> NewValue: ' + NewValue;
  _sg := TStringGrid(sender);
  SelectedItemObject := PItemObjectData(_sg.Objects[1,aRow]);

  if OldValue <> NewValue then begin
    if (OldValue = '') and (NewValue <> '') then begin  // New item
      try
        // Place the new item in the array with all items. (So it can be saved later).
        lNewItemRec := fPresenter.TrxMan.StartTransaction(prAddNewItem) as TNewItemTransaction;

        lNewItemRec.Name := NewValue;
        lNewItemRec.Level := StrToInt(FPresenter.ExtractNumberFromString(_sg.Name));
        lNewItemRec.Action := iaCreate;
        lNewItemRec.GridObject := _sg;
        lNewItemRec.MustSave := True;
        lNewItemRec.Col := aCol;
        lNewItemRec.Row := aRow;

        FPresenter.TrxMan.CommitTransaction;
      except
        fPresenter.TrxMan.RollbackTransaction;
        FPresenter.SetStatusbartext('Fout bij voorbereiden gegevens nieuw item.',0);
        screen.Cursor := crDefault;
      end;
    end
    else begin  // update
      try
        lUpdateItemRec := fPresenter.TrxMan.StartTransaction(prUpdateItem) as TUpdateItemTransaction;
        lUpdateItemRec.Name := NewValue;
        lUpdateItemRec.GridObject := _sg;
        lUpdateItemRec.Col := aCol;
        lUpdateItemRec.Row := aRow;
        lUpdateItemRec.Level := StrToInt(FPresenter.ExtractNumberFromString(_sg.Name));

        if SelectedItemObject <> nil then begin
          lUpdateItemRec.Guid := SelectedItemObject^.Guid;
          lUpdateItemRec.MustSave := True;

          if SelectedItemObject^.Action = iaRead then begin
            lUpdateItemRec.Action := iaUpdate;
          end
          else begin
            lUpdateItemRec.Action := SelectedItemObject^.Action;
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

procedure TfrmMain.StringGridOnSelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
var
  p: PItemObjectData;
  i: Integer;
  lRec : TStringGridSelect;
begin
  { #todo : moet een presenter functie worden }
  if sender is TStringGrid then begin
    FActiveStringGrid :=  TStringGrid(sender);

    FCol := aCol;  // only use(d) for deleting a row
    FRow := aRow;  // only use(d) for deleting a row

    i:= rgMainViewState.ItemIndex;

    case rgMainViewState.ItemIndex of
      0: begin
        FAllowCellselectColor := True;
      end;
      1: begin
        FAllowCellselectColor := False;
      end;
      2: begin
        FAllowCellselectColor := False;
      end
      else begin
        FAllowCellselectColor := True;
      end;
    end;

    if PItemObjectData(FActiveStringGrid.Objects[acol,aRow]) <> nil then begin
      p := PItemObjectData(FActiveStringGrid.Objects[acol,aRow]);
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
      if PItemObjectData(FActiveStringGrid.Objects[acol,aRow]) <> nil then begin

        p := PItemObjectData(FActiveStringGrid.Objects[acol,aRow]);
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

procedure TfrmMain.StringGridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
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

    if (rgMainViewState.ItemIndex = 1) and (s <> '') then begin
      if FCanDeletePmi then // you have to click on the row before you can delete
        lRec.pmivDeletItem := True
      else
        lRec.pmivDeletItem := False;

      lRec.pmivAddItem := True;
      lRec.pmivImportItems := True;
    end
    else if (rgMainViewState.ItemIndex = 1) and (s = '') then begin
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

procedure TfrmMain.StringGridOnPrepareCanvas(Sender: TObject; aCol,
  aRow: Integer; aState: TGridDrawState);
var
  b: Boolean;
begin
  if rgMainViewState.ItemIndex = 0 then begin
    b := True;
  end
  else if (rgMainViewState.ItemIndex = 1) or (rgMainViewState.ItemIndex = 2) then begin
    b := False;
  end;

  FPresenter.StringGridOnPrepareCanvas(Sender, aCol, aRow, b);
end;

procedure TfrmMain.StringGridOnCheckboxToggled(Sender: TObject; aCol,
  aRow: Integer; aState: TCheckboxState);
var
  lTrx : TCheckboxToggleTransaction;
  c, i : Integer;
begin
  // Bepaal de benodigde rij
  for c:=0 to TstringGrid(sender).ColCount-1 do begin
    if PItemObjectData(TstringGrid(sender).Objects[c,aRow]) <> nil then begin
      break; // cell with objectdata is found
    end;
  end;

  if PItemObjectData(TstringGrid(sender).Objects[3,aRow]) <> nil then begin
    try
      ltrx := FPresenter.TrxMan.StartTransaction(prCheckboxToggled) as TCheckboxToggleTransaction;
      ltrx.Col:= aCol;
      ltrx.Row:= aRow;
      ltrx.aGuid:= PItemObjectData(TstringGrid(sender).Objects[c,aRow])^.Guid;  // De reguliere guid wordt de parent voor de childs
      ltrx.AllSGrids := Pointer(AllStringGrids);
      ltrx.aGridPtr:= Sender;
      if aState = cbChecked then begin
        ltrx.CbIsChecked := True;
      end
      else begin
        ltrx.CbIsChecked := False;
      end;
      ltrx.RowObject := PItemObjectData(TstringGrid(sender).Objects[c,aRow]);

      FPresenter.TrxMan.CommitTransaction;
    except
      fPresenter.TrxMan.RollbackTransaction;
      FPresenter.SetStatusbartext('Fout bij het bepalen of er 1 parent is aangevinkt.',0);
      screen.Cursor := crDefault;
    end;
  end
  else begin
    FPresenter.WriteToLog(UnitName, laError, 'Dit item heeft geen object data. Relaties kan niet worden opgeslagen.' );
    FPresenter.WriteToLog(UnitName, laError, 'Item : '  + TstringGrid(sender).Name); { #todo : Verbeteren door level toe te voegen. }
    FPresenter.SetStatusbartext('Let op: Dit item heeft geen object data.', 0);
  end;

  // Repaint all stringgrids. This sets the parent checked color again.
  for I:= 0 to length(AllStringGrids)-1 do begin
    AllStringGrids[i].Repaint;
  end;
end;

procedure TfrmMain.StringGridOnDrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  lRec : TStringGridSelect;
    p: PItemObjectData;
begin
  if FAllowCellselectColor then begin
    try
      if TStringGrid(sender) = FActiveStringGrid then begin
        if PItemObjectData(FActiveStringGrid.Objects[acol,aRow]) <> nil then begin
          p := PItemObjectData(FActiveStringGrid.Objects[acol,aRow]);

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

          case rgMainViewState.ItemIndex of
            0: begin
              lRec.AllowCellSelectColor := True;
            end;
            1: begin
              lRec.AllowCellSelectColor := False;
            end;
            2: begin
              lRec.AllowCellSelectColor := False;
            end;
            else begin
              lRec.AllowCellSelectColor := True;
            end
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

procedure TfrmMain.RemoveEmptyRowStringGrid;
var
  i : Integer;
begin
  if Length(AllStringGrids) > 0 then begin
    for i := 0 to Length(AllStringGrids)-1 do begin
      if AllStringGrids[i].RowCount > 0 then begin
        FPresenter.SGRemoveEmptyRows(AllStringGrids[i]);
      end;
    end;
  end;
end;

function TfrmMain.CanContinue: Boolean;
var
  MsgDlgbuttonSelected : Word;
begin
  // TODO functie van maken via de presenter, model ?
  if FMustSaveFirst then begin
    MsgDlgbuttonSelected := MessageDlg(FPresenter.GetstaticText(UnitName, 'MsgTitelUnsavedData')  + sLineBreak + fPresenter.GetstaticText(UnitName, 'MsgUnsavedDataContinue') ,mtConfirmation, [mbYes,mbCancel], 0);
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

procedure TfrmMain.GetAllItemsForStringGrid;
var
  lodbt : TOpenDbFileGetDataTransaction;
  i : Integer;
  _stringGrid : TStringGrid;
  CanSelect: Boolean;
begin
  screen.Cursor := crHourGlass;

  for i:= 1 to FNumberOfColumns do begin
    try
      FPresenter.SetStatusbartext(FPresenter.GetstaticText('view.main.StatusbarTexts', 'RetreivingDataPerColumn') + IntToStr(i), 0);
      _stringGrid := GetTheRightStringGid(i, 'STRINGGRID_');
      _stringGrid.OnSelectCell := Nil;

      lodbt := FPresenter.TrxMan.StartTransaction(prGetAllItems) as TOpenDbFileGetDataTransaction;
      lodbt.StringgridPtr := _stringGrid;
      lodbt.Level := i;

      FPresenter.TrxMan.CommitTransaction;

      StringgridStateIsRead;  // romove parent and child column
      _stringGrid.OnSelectCell := @StringGridOnSelectCell;


    except
      fPresenter.TrxMan.RollbackTransaction;
      FPresenter.SetStatusbartext(FPresenter.GetstaticText('view.main.StatusbarTexts', 'ErrorGettingdata'), 0);
      screen.Cursor := crDefault;
    end;
  end;

  if FCanContinue then begin
    SetColumnHeaderNames;  // Set the (new) header names.

    { #todo : Dit zorgt ervoor dat de eerste cel is geselecteerd na het openen van een db.  Verplaatsen en optioneel maken }
    if length(AllStringGrids)> 0 then begin
      if AllStringGrids[0].RowCount> 1 then begin
        CanSelect := True;
        StringGridOnSelectCell(AllStringGrids[0], 3, 1, CanSelect);
        AllStringGrids[0].SetFocus;
      end;
    end;
    { --- }
  end;

  FPresenter.SetStatusbartext('', 0);
  screen.Cursor := crDefault;
end;

procedure TfrmMain.SetColumnHeaderNames; //(Sender: TObject);
var
  lRec : TGetColumnNamesTransaction;
begin
  if (AllStringGrids <> nil) and (length(AllStringGrids)>0) then begin
    screen.Cursor := crHourGlass;
    try
      lRec := FPresenter.TrxMan.StartTransaction(prGetColumnnames) as TGetColumnNamesTransaction;
      lRec.NameView := 'MainView'; // not used
      //lrec.aGrid:= Sender;
      FPresenter.TrxMan.CommitTransaction;
      screen.Cursor := crDefault;
    except
      fPresenter.TrxMan.RollbackTransaction;
      FPresenter.SetStatusbartext('Fout bij ophalen Kolomnamen.',0);
      screen.Cursor := crDefault;
    end;
  end;
end;

procedure TfrmMain.StringgridStateIsRead;
var
  i: Integer;
  lsgRec : TStringGridRec;
begin
  if Length(AllStringGrids) > 0 then begin
    for i := 0 to Length(AllStringGrids)-1 do begin
      lsgRec.sgShowParentCol := False;
      lsgRec.sgShowChildCol := False;
      FPresenter.SgSetState(@lsgRec, ssRead);
    end;
  end;
end;

function TfrmMain.CloseDbFile: Boolean;
begin
  if CanContinue then begin
    FPresenter.SetStatusbartext(FPresenter.GetstaticText('view.main.StatusbarTexts', 'BusyClosing'), 0);
    CleanUpDbFile;
    FPresenter.PrepareCloseDb; { #todo : add notify if an error occurs }
    FPresenter.ClearMainView(sbxLeft);
    FPresenter.ClearMainView(sbxmain);
    AllStringGrids := nil;
    FMustSaveFirst := False;

    FPresenter.Model.DbFullFilename := '';

    mmiProgramCloseFile.Enabled:= False;
    tbCLoseFile.Enabled:= False;
    rgMainViewState.Enabled:= False;
    rgMainViewState.ItemIndex:= 0;
    FPresenter.SetStatusbartext('', 0);
    FPresenter.SetStatusbartext('', 2);
    Result := True;
  end
  else begin
    Result := False;
  end;
end;

function TfrmMain.CreateNewDbFile: String;
var
  SaveDialog: TSaveDialog;
  lcdbt : TCreateDbFileTransaction;  // Local Create Database Transaction
  lrecDbFileInfo : TCreDbFileRec;
begin
  Screen.Cursor := crHourGlass;
  FPresenter.SetStatusbartext(FPresenter.GetstaticText('view.main.StatusbarTexts', 'ChooseADir') , 0);  // Kies een directory
  SaveDialog := TSaveDialog.Create(nil);
  try
    with saveDialog do
      begin
        Title := fPresenter.GetstaticText('view.main', 'dlgTitleCreDb');
        InitialDir := ExtractFilePath(Application.ExeName) + adDatabase;
        Filter := 'SQLite db file|*.db';
        DefaultExt := 'db';
        Options := saveDialog.Options + [ofOverwritePrompt, ofNoTestFileCreate];
        if Execute then begin

          lcdbt := fPresenter.TrxMan.StartTransaction(prCreDatabaseFile) as TCreateDbFileTransaction;

          if not fPresenter.IsFileInUse(saveDialog.FileName) then begin
            // Open view that requests/stores number of columns and the name of the dbfile.
            Screen.Cursor := crDefault;

            // create and open the create new dbfile form.
            lrecDbFileInfo.cdbfFilename:= saveDialog.FileName;
            SetNewDbFileView(fPresenter, @lrecDbFileInfo); // Opens the create new dbfile view.
            CloseDbForm;

            if lrecDbFileInfo.cdbfCreateTable then begin
              lcdbt.DirName := saveDialog.FileName;
              lcdbt.FileName := lrecDbFileInfo.cdbfFilename;  { #todo : Solve duplicate field } // = duplicate with DirName
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
            FPresenter.SetStatusbartext(fPresenter.GetstaticText('view.main.StatusbarTexts', 'CreNewDbFileInUse'), 0);
            messageDlg(fPresenter.GetstaticText('view.main.StatusbarTexts', 'MsgWarning'), fPresenter.GetstaticText('view.main.StatusbarTexts', 'CreNewDbFileInUse'), mtWarning, [mbOK], 0);
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

procedure TfrmMain.ShowNewRowButtons(lBtnRec: TBitBtnRec);
var
  i : Integer;
begin
  if Length(AllBitButtonsAdd) > 0 then begin
    for i := 0 to Length(AllBitButtonsAdd)-1 do begin
      FPresenter.ShowButtons(@lBtnRec, AllBitButtonsAdd[i]);
      AllBitButtonsAdd[i].Hint:=  fPresenter.GetstaticText('view.main.hints', 'btAddHint');
    end;
  end;
end;

procedure TfrmMain.AlterSystemMenu(AppName, AppVersion: String; hWnd: HWND);
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

procedure TfrmMain.SetStringGridWidth(anObj: TObject);
var
  i: Integer;
begin
  if anObj <> nil then begin  // 1 StringGrid
    fPresenter.SetStringGridWidth(anObj);
  end
  else begin  // Allstringgrids
    for i:= 0 to  Length(allStringGrids)-1 do begin
      fPresenter.SetStringGridWidth(allStringGrids[i]);
    end;
  end;
end;


function TfrmMain.CheckLanguageFiles: Boolean;
var
  aRoot: String;
begin
  // Let op, taal bestanden moeten aanwezig zijn anders loopt de tool vast met een access violation en geheugen lekken.
  aRoot:= ExtractFilePath(ParamStr(0));
  if FileExists(format(mvpTexts,[aRoot,Lang])) then begin
    Result:= True;
  end
  else begin
    Result:= False;
    MessageDlg(ApplicationName + ': Error', 'No language file was found.'
    , mtError, [mbOK],0);
  end;
end;

procedure TfrmMain.SetAppLanguage;
var
  SetFile: String;
begin
  SetFile:= GetSettingsFile;
  if FileExists(SetFile) then
    Lang:= CreStrListFromFile(SetFile).Values['Language'].Trim; ///<- i18n
  if Lang = '' then Lang := 'en';  // back to the default when the settingsfile is found but language is empty.
end;

procedure TfrmMain.CreateDirectories;
var
  lDirTrx: TCreDirTransaction;
  dirList : TStringList;
begin
  dirList := TStringList.Create;  // Create stringlist that contains the directory names.
  lDirTrx:= FPresenter.TrxMan.StartTransaction(prCreateDir) as TCreDirTransaction;
  try
    dirList.Add(adSettings);
    dirList.Add(adLogging);
    dirList.Add(adDatabase);  { #todo : Moet pas worden aangemaakt nadat settings is uitgelezen. Dan kan de locatie optioneel worden. }
    dirList.Add(adBackUpFld);
    lDirTrx.NewDirnames.AddStrings(dirList);
    lDirTrx.RootDir:= ApplicationName;  //GetEnvironmentVariable('appdata') + ApplicationName;  // C:\Users\<username>\AppData\Roaming\<Application Name>
    FPresenter.TrxMan.CommitTransaction;
    dirList.Free;
  except
    FPresenter.TrxMan.RollbackTransaction;  // does NOTHING and _frees_ transaction
  end;
end;

procedure TfrmMain.ReadSettings;
var
  lTrs: TSettingstransaction;
begin
  lTrs:= FPresenter.TrxMan.StartTransaction(prAppSettings) as TSettingstransaction;
  try
    lTrs.ReadSettings:= True;  // <<---
    lTrs.WriteSettings:= False;
    lTrs.AppName:= ApplicationName;
    lTrs.AppVersion:= Application_version;
    lTrs.AppBuildDate:= Application_buildDate;

    FPresenter.TrxMan.CommitTransaction;
  except
    FPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmMain.WriteSingleSetting(Setting, aValue: String);
var
  lTrs: TSingleSettingTransaction;
begin
  lTrs:= FPresenter.TrxMan.StartTransaction(prAppSingleSetting) as TSingleSettingTransaction;
  try
    lTrs.SettingName:= Setting;
    lTrs.SettingValue:= aValue;
    FPresenter.TrxMan.CommitTransaction;
  except
    FPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmMain.WriteSettings;
var
  lTrs: TSettingstransaction;
begin
  lTrs:= FPresenter.TrxMan.StartTransaction(prAppSettings) as TSettingstransaction;
  try
    lTrs.WriteSettings:= True;  // <<---
    lTrs.ReadSettings:= False;
    if mmiOptionsLanguageEN.Checked then
      lTrs.Language:= 'en'
    else if mmiOptionsLanguageNL.Checked then
      ltrs.Language:= 'nl';

    FPresenter.TrxMan.CommitTransaction;
  except
    FPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmMain.StoreFormstate;
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

procedure TfrmMain.ReadFormState;
var
  lTrs : TSettingstransaction;
begin
  lTrs := FPresenter.TrxMan.StartTransaction(prFormState) as TSettingstransaction;
  try
    lTrs.ReadSettings:= True;
    lTrs.ReadFormState:= True;
    lTrs.FormName := UnitName;

    FPresenter.TrxMan.CommitTransaction;
  except
    fPresenter.TrxMan.RollbackTransaction;
  end;
end;

procedure TfrmMain.StartLogging;
begin
  FPresenter.StartLogging;
end;

function TfrmMain.GetSettingsFile: String;
var
  UserName : String;
begin
  UserName:= StringReplace(SysUtils.GetEnvironmentVariable('USERNAME') , ' ', '_', [rfIgnoreCase, rfReplaceAll]) + '_';
  Result:= SysUtils.GetEnvironmentVariable('appdata') + PathDelim + ApplicationName+PathDelim+ 'Settings' +PathDelim+ UserName + ApplicationName+'.cfg';  // 'Settings' is wrong should be adSettings
end;

function TfrmMain.CheckFormIsEntireVisible(Rect: TRect): TRect;
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

end.

