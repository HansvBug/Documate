program Documate;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, view.main, presenter.main, presenter.trax, model.base, model.decl,
  model.intf, model.main, istrlist, obs_prosu, view.configure, View.NewDbFile
  { you can add units after this }
  ;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:= True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.

