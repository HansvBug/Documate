unit ViewNewDbFile;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

  { TfrmViewCreDbFile }

  TfrmViewCreDbFile = class(TForm)
    ButtonCancel: TButton;
    ButtonNewFile: TButton;
    EditDescriptionShort: TEdit;
    EditNewFileName: TEdit;
    EditNumberOfColumns: TEdit;
    Label1: TLabel;
    LabelColumnNumber: TLabel;
    LabelDescriptionShort: TLabel;
    StatusBarFrmNewDb: TStatusBar;
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonNewFileClick(Sender: TObject);
    procedure EditDescriptionShortChange(Sender: TObject);
    procedure EditNumberOfColumnsChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FNewFileName : String;
    FNumberOfColumns : Integer;
    FDbDescriptionShort : String;
    FCreateTable : Boolean;

    procedure SetStatusbarText(aText : String);
  public
    property NewFileName        : String  read FNewFileName        write FNewFileName;
    property NumberOfColumns    : Integer    read FNumberOfColumns    write FNumberOfColumns;
    property DbDescriptionShort : String  read FDbDescriptionShort write FDbDescriptionShort;
    property CreateTable        : Boolean read FCreateTable        write FCreateTable;
  end;

var
  frmViewCreDbFile: TfrmViewCreDbFile;

implementation

{$R *.lfm}

{ TfrmViewCreDbFile }

procedure TfrmViewCreDbFile.EditNumberOfColumnsChange(Sender: TObject);
begin
  ButtonNewFile.Enabled := False;
  if (EditNumberOfColumns.Text <> '') then Begin
    if (StrToInt(EditNumberOfColumns.Text) >= 2) and (StrToInt(EditNumberOfColumns.Text) <= 20) then begin
      ButtonNewFile.Enabled := True;
      SetStatusbarText('');
    end
    else if (StrToInt(EditNumberOfColumns.Text) < 2) then begin
      SetStatusbarText('Minimaal 2 kolommen benodigd.');
    end
    else if (StrToInt(EditNumberOfColumns.Text) > 20) then begin
      SetStatusbarText('Maximaal 20 kolommen toegestaan.');
    end;
    NumberOfColumns := StrToInt(EditNumberOfColumns.Text);
  end
  else begin
    NumberOfColumns := 0;
  end;
end;

procedure TfrmViewCreDbFile.FormCreate(Sender: TObject);
begin
  Caption := 'Maak een nieuwe database bestand.';
  Color := clWindow;  { #todo : Should be a constant so that it applies to all views. }
  ButtonNewFile.Enabled := False;
end;

procedure TfrmViewCreDbFile.FormShow(Sender: TObject);
begin
  EditNewFileName.Text := NewFileName;
end;

procedure TfrmViewCreDbFile.EditDescriptionShortChange(Sender: TObject);
begin
  DbDescriptionShort:= EditDescriptionShort.Text;
end;

procedure TfrmViewCreDbFile.ButtonCancelClick(Sender: TObject);
begin
  FCreateTable:= False;
end;

procedure TfrmViewCreDbFile.ButtonNewFileClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  CreateTable:= True;
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

end.

