unit Logging;

{$mode objfpc}{$H+}

interface
{$M+}

uses Classes, Sysutils, FileUtil, Forms;

type
{$Interfaces CORBA}

  { ILogging }

  ILogging = interface['{00DEC400-7DDF-4748-9AFB-5AE4D74A610B}']
    procedure   StopLogging;
    procedure   StartLogging;
    procedure   WriteToLogInfo(const Commentaar : String);
    procedure   WriteToLogWarning(const Commentaar : String);
    procedure   WriteToLogError(const Commentaar : String);
    procedure   WriteToLogDebug(const Commentaar : String);
  end;

{$Interfaces COM}

type

  { TLog_File }

  TLog_File = class(TObject, ILogging)
  private
    strlist                                  : TStringList;
    FileStream1                              : TFileStream;
    FLogFolder, FLogFileName, FUserName      : String;
    FAppendCurrentLogfile, FActivateLogging  : Boolean;
    szCurrentTime                            : String;
    FApplicationName, FAppVersion            : String;

    function GetAppendCurrentLogfile: Boolean;
    procedure SetAppendCurrentLogfile(AValue: Boolean);

    function    CurrentDate: String;                            //Bepalen huidige datum
    procedure   Logging;                                        //De gegevens worden in het bestand gezet
    procedure   CurrentTime;

    procedure   WriteToLog(const Commentaar : String);          //Tekst naar logbestand schrijven
    procedure   WriteToLogAndFlush(const Commentaar : String);  //Tekst direct naar logbestand schrijven

  public
    constructor Create(const LogFile : String);
    destructor  Destroy; override;
    procedure   StartLogging;                                          //Aanmaken/openen log bestand
    procedure   StopLogging;                                           //Bestand opslaan en sluiten
    procedure   WriteToLogInfo(const Commentaar : String);             //Tekst naar logbestand schrijven
    procedure   WriteToLogWarning(const Commentaar : String);          //Tekst naar logbestand schrijven
    procedure   WriteToLogError(const Commentaar : String);            //Tekst naar logbestand schrijven
    procedure   WriteToLogDebug(const Commentaar : String);            //Tekst naar logbestand schrijven

    procedure   WriteToLogAndFlushInfo(const Commentaar : String);     //Tekst direct naar logbestand schrijven
    procedure   WriteToLogAndFlushWarning(const Commentaar : String);  //Tekst direct naar logbestand schrijven
    procedure   WriteToLogAndFlushError(const Commentaar : String);    //Tekst direct naar logbestand schrijven
    procedure   WriteToLogAndFlushDebug(const Commentaar : String);    //Tekst direct naar logbestand schrijven

    property AppendLogFile    : Boolean Read GetAppendCurrentLogfile Write SetAppendCurrentLogfile;
    property ActivateLogging  : Boolean Read FActivateLogging        Write FActivateLogging;
    property ApplicationName  : String Read FApplicationName         Write FApplicationName;
    property AppVersion       : String Read FAppVersion              Write FAppVersion;
end;

implementation

uses lazfileutils;

{ TLog_File }

{%region% properties}
function TLog_File.GetAppendCurrentLogfile: Boolean;
begin
  Result := FAppendCurrentLogfile;
end;

procedure TLog_File.SetAppendCurrentLogfile(AValue: Boolean);
begin
  FAppendCurrentLogfile := AValue;
end;
{%endregion% properties}


constructor TLog_File.Create(const LogFile : String);
begin
  FLogFolder := ExtractFilePath(LogFile);
  FLogFileName := ExtractFileName(LogFile);
  strlist := TStringList.Create;
  FUserName := StringReplace(GetEnvironmentVariable('USERNAME'), ' ', '_', [rfIgnoreCase, rfReplaceAll]);

{  if LogFolder = '' then
    begin
      ActivateLogging := False;
      AppendLogFile := False;
    end;}
end;

destructor TLog_File.Destroy;
begin
  FileStream1.Free;
  strlist.Free;
  inherited;
end;

procedure TLog_File.CurrentTime;  //Bepaal het huidige tijdstip
begin
  szCurrentTime := FormatDateTime('hh:mm:ss', Now) + ' --> | ';
end;

function TLog_File.CurrentDate: String;
var
  Present           : TDateTime;
  Year, Month, Day  : Word;
begin
  Present := Now;                         //de huidige datum en tijd opvragen
  DecodeDate(Present, Year, Month, Day);  //de datum bepalen die met present is opgehaald
  Result :=  IntToStr(Day) + '-' + IntToStr(Month) + '-' + IntToStr(Year);
end;

procedure TLog_File.Logging;
var
  retry      : Boolean;
  retries, i : Integer;
  MyString   : String;
const
  MAXRETRIES = 10;
  RETRYBACKOFFDELAYMS = 50;
begin
  if ActivateLogging then begin
    try
      // Retry mechanisme voor een SaveToFile()
      retry := True;
      retries := 0;
      while retry do
      try
        //wegschrijven
        for I := 0 to strlist.Count-1 do
          begin
            try
              FileStream1.seek(0,soFromEnd);  ////cursor aan het eind van het bestand zetten
              MyString := strlist[i] + sLineBreak;
              FileStream1.WriteBuffer(MyString[1], Length(MyString) * SizeOf(Char));
            finally
              //
            end;
          end;
        strlist.Clear;  //Stringlist leegmaken
        retry := False;
      except
        on EInOutError do
        begin
          Inc(retries);
          Sleep(RETRYBACKOFFDELAYMS * retries);
          if retries > MAXRETRIES then
          begin
            WriteToLog('INFORMATIE | Na 10 pogingen is het opslaan in het logbestand afgebroken.');
            Exit;
          end;
        end;
      end;
    finally
      //
    end;
  end;
end;

procedure TLog_File.StartLogging;

begin
  if ActivateLogging then begin
    if AppendLogFile = True then
      begin
        if FileExists(FLogFolder
                       + FUsername
                       + '_'
                       + FLogFileName) then
          begin
            FileStream1 := TFileStream.Create(FLogFolder
                                                 + FUsername
                                                 + '_'
                                                 + FLogFileName,
                           fmOpenReadWrite or fmShareDenyNone);  //fmShareDenyNone : Do not lock file
          end
        else  //wel append maar het bestand bestaat nog niet dan aanmaken
          begin
            FileStream1 := TFileStream.Create(FLogFolder
                                                 + FUsername
                                                 + '_'
                                                 + FLogFileName,
                           fmCreate or fmShareDenyNone);
          end;
      end
    else  //nieuw bestand aanmaken
      begin
        FileStream1 := TFileStream.Create(FLogFolder
                                                   + FUsername
                                                   + '_'
                                                   + FLogFileName,
                             fmCreate or fmShareDenyNone);

      end;

    try
      strlist.Add('##################################################################################################');
      strlist.Add(' Programma: ' + ApplicationName);
      strlist.Add(' Versie   : ' + AppVersion);
      strlist.Add(' Datum    : ' + CurrentDate);
      strlist.Add('##################################################################################################');
      Logging;  //Direct opslaan
      CurrentTime;
    except
      strlist.Add('FOUT      | Onverwachte fout opgetreden bij de opstart van de logging procedure.');
    end;
  end;
end;

procedure TLog_File.StopLogging;
begin
  strlist.Add('');
  strlist.Add('##################################################################################################');
  strlist.Add(' Programma ' + ApplicationName + ' is afgesloten');
  strlist.Add('##################################################################################################');
  strlist.Add('');
  strlist.Add('');
  strlist.Add('');
  Logging;  //Direct opslaan
end;

procedure TLog_File.WriteToLogInfo(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : INFORMATIE   | ' + Commentaar);
end;

procedure TLog_File.WriteToLogWarning(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : WAARSCHUWING | ' + Commentaar);
end;

procedure TLog_File.WriteToLogError(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : FOUT         | ' + Commentaar);
end;

procedure TLog_File.WriteToLogDebug(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : DEBUG        | ' + Commentaar);
end;


procedure TLog_File.WriteToLog(const Commentaar : String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' :              | ' + Commentaar);  //In de stringgrid gereed zetten
end;


procedure TLog_File.WriteToLogAndFlushInfo(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : INFORMATIE   | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;
end;

procedure TLog_File.WriteToLogAndFlushWarning(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : WAARSCHWING  | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;
end;

procedure TLog_File.WriteToLogAndFlushError(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : ERROR        | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;
end;

procedure TLog_File.WriteToLogAndFlushDebug(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' : DEBUG        | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;
end;

procedure TLog_File.WriteToLogAndFlush(const Commentaar: String);
begin
  CurrentTime;
  strlist.Add(szCurrentTime + ' :              | ' + Commentaar);  //In de stringgrid gereed zetten
  Logging;  // Direct opslaan
end;

end.


