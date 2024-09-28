unit View.NewDbFile;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  obs_prosu, istrlist, model.intf, model.decl{, presenter.main, presenter.trax}
  ;

type

  { TfrmViewCreDbFile }

  TfrmViewCreDbFile = class(TForm, IViewNewItem)
    btCancel: TButton;
    btCreate: TButton;
    edtDescriptionShort: TEdit;
    edNewFileName: TEdit;
    edtColumnCount: TEdit;
    lbFileName: TLabel;
    lbColCount: TLabel;
    lbDescriptionShort: TLabel;
    StatusBarFrmNewDb: TStatusBar;
    procedure btCancelClick(Sender: TObject);
    procedure btCreateClick(Sender: TObject);
    procedure edtDescriptionShortChange(Sender: TObject);
    procedure edtColumnCountChange(Sender: TObject);
  private
    fPresenter: IPresenterMain;
    fSubscriber: IobsSubscriber;
    FDbInfo: PCreDbFileRec;

    function Obj: TObject;
    procedure SetStatusbarText(aText : String);  // this is NOT mvp. { #todo : make it mvp }
  protected
    procedure HandleObsNotify(aReason: ptrint; aNotifyClass: TObject; UserData: pointer);
    procedure SetStaticTexts(Texts: IStrings);
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;


  end;

  function SetNewDbFileView(aPresenter: IPresenterMain; DbFileInfo: PCreDbFileRec): Boolean; // forward function
  procedure CloseDbForm;

var
  frmViewCreDbFile: TfrmViewCreDbFile;

implementation


function SetNewDbFileView(aPresenter: IPresenterMain; DbFileInfo: PCreDbFileRec
  ): Boolean;
begin
  frmViewCreDbFile:= TfrmViewCreDbFile.Create(nil);
  with frmViewCreDbFile do try  // Is Free-ed in CloseDbForm.
    edtColumnCount.NumbersOnly:= True;
    btCreate.Enabled := False;

    fPresenter:= aPresenter;
    fPresenter.Provider.Subscribe(fSubscriber);
    fPresenter.GetStaticTexts(UnitName);  // get the caption texts

    FDbInfo:= DbFileInfo;
    edNewFileName.Text:= ExtractFileName(PCreDbFileRec(FDbInfo)^.cdbfFilename);
    Result:= (ShowModal = mrOK);
  finally
    { #todo : Logging maken }
    //Free; // Is called from main.view.
  end;
end;

procedure CloseDbForm;
begin
  if assigned(frmViewCreDbFile) then
  frmViewCreDbFile.Free;
end;

{$R *.lfm}

{ TfrmViewCreDbFile }

procedure TfrmViewCreDbFile.edtColumnCountChange(Sender: TObject);
begin
  btCreate.Enabled := False;
  if (edtColumnCount.Text <> '') then Begin
    if (StrToInt(edtColumnCount.Text) >= 2) and (StrToInt(edtColumnCount.Text) <= 20) then begin
      btCreate.Enabled := True;
      SetStatusbarText('');
    end
    else if (StrToInt(edtColumnCount.Text) < 2) then begin
      SetStatusbarText('Minimaal 2 kolommen benodigd.');
    end
    else if (StrToInt(edtColumnCount.Text) > 20) then begin
      SetStatusbarText('Maximaal 20 kolommen toegestaan.');
    end;
    FDbInfo^.cdbfColumnCount := StrToInt(edtColumnCount.Text);
  end
  else begin
    FDbInfo^.cdbfColumnCount := 0;
  end;
end;

procedure TfrmViewCreDbFile.btCancelClick(Sender: TObject);
begin
  FDbInfo^.cdbfColumnCount:= 0;
  FDbInfo^.cdbfShortDescription:= '';
  FDbInfo^.cdbfCreateTable:= False;
end;

procedure TfrmViewCreDbFile.btCreateClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  FDbInfo^.cdbfCreateTable:= True;
end;

procedure TfrmViewCreDbFile.edtDescriptionShortChange(Sender: TObject);
begin
  FDbInfo^.cdbfShortDescription:= trim(edtDescriptionShort.Text);
end;

function TfrmViewCreDbFile.Obj: TObject;
begin
  Result:= Self;
end;

procedure TfrmViewCreDbFile.SetStatusbarText(aText: String);
begin
  if aText <> '' then begin
    StatusBarFrmNewDb.Panels.Items[0].Text := ' ' + aText;
  end
  else begin
    StatusBarFrmNewDb.Panels.Items[0].Text := '';
  end;

  Application.ProcessMessages;
end;



procedure TfrmViewCreDbFile.HandleObsNotify(aReason: ptrint;
  aNotifyClass: TObject; UserData: pointer);
begin
  case aReason of
    prNewItemStaticTexts: SetStaticTexts(IStringList(UserData));
  end;
end;

procedure TfrmViewCreDbFile.SetStaticTexts(Texts: IStrings);
var
  i: integer;
  lc: TComponent;
begin
  Caption:= Texts.Values[Name];

  for i:= 0 to ComponentCount-1 do begin
    lc:= Components[i];
    if (lc is TButton) then
      TButton(lc).Caption:= Texts.Values[TButton(lc).Name];
    if (lc is TGroupBox) then
      TGroupBox(lc).Caption:= Texts.Values[TGroupBox(lc).Name];
    if (lc is TLabel) then
      TLabel(lc).Caption:= Texts.Values[TLabel(lc).Name];
    if (lc is TEdit) then
      TEdit(lc).Caption:= Texts.Values[TEdit(lc).Name];
  end;
end;

procedure TfrmViewCreDbFile.AfterConstruction;
begin
  inherited AfterConstruction;
  self.Color:= clWindow;

  fSubscriber:= CreateObsSubscriber(@HandleObsNotify);
end;

procedure TfrmViewCreDbFile.BeforeDestruction;
begin
  fPresenter.Provider.UnSubscribe(fSubscriber);
  fSubscriber.Obj.Free;
  inherited BeforeDestruction;
end;

end.

