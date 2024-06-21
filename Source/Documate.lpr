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
  Forms, anchordockpkg,
  { you can add units after this }
  ViewMain, ViewConfigure, ViewNewDbFile, AppDbMaintainItems
  ;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TfrmViewMain, frmViewMain);
  Application.Run;
end.

