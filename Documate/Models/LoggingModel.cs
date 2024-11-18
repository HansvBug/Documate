using Microsoft.Win32;
using System.Globalization;
using System.Management;
using System.Text;
using Documate.Library;
using static Documate.Library.Common;

namespace Documate.Models
{
    public class LoggingModel
    {
        private readonly Logging logging;

        public LoggingModel()
        {
            logging = new Logging();
        }

        public void WriteToLog(LogAction logAction, string logText)
        {
            switch (logAction)
            {
                case LogAction.INFORMATION:
                    logging.WriteToLogInformation(logText);
                    break;

                case LogAction.WARNING:
                    logging.WriteToLogWarning(logText);
                    break;

                case LogAction.ERROR:
                    logging.WriteToLogError(logText);
                    break;

                case LogAction.DEBUG:
                    logging.WriteToLogDebug(logText);
                    break;

                case LogAction.UNKNOWN:
                default:
                    logging.WriteToLogUnknown(logText);  // Schrijf een logregel voor onbekende acties, als dat nodig is
                    break;
            }
        }
        public void StartLogging()
        {
            PrepareLogging();
        }

        public void StopLogging()
        {
            logging.StopLogging();
        }

        private void PrepareLogging()
        {
            // Application settings
            logging.NameLogFile = Properties.Settings.Default.LogFileName;
            logging.ApplicationName = Properties.Settings.Default.ApplicationName;
            logging.ApplicationVersion = Properties.Settings.Default.ApplicationVersion;
            logging.ApplicationBuildDate = AppSettings.ApplicationBuildDate;

            // User settings
            logging.DebugMode = false;  // TODO Debug mode
            if (!string.IsNullOrEmpty(Properties.Settings.Default.LogFileLocation))
            {
                logging.LogFolder = Properties.Settings.Default.LogFileLocation;
            }
            else
            {
                logging.LogFolder = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), Properties.Settings.Default.ApplicationName, AppSettings.LoggingFolder) + "\\";
            }

            logging.ActivateLogging = Properties.Settings.Default.ActivateLogging;
            logging.AppendLogFile = Properties.Settings.Default.AppendLogFile;

            if (!logging.StartLogging())
            {
                logging.WriteToFile = false;
                logging.ActivateLogging = false;
            }
        }

        #region private class Logging
        private class Logging
        {
            private readonly List<string> _message = [];
            private enum LogAction
            {
                INFORMATION,
                WARNING,
                ERROR,
                DEBUG,
                UNKNOWN
            }

            #region Properties

            public string NameLogFile { get; set; } = string.Empty;
            public bool AppendLogFile { get; set; } = true;      //append the logfile true is the default
            public string LogFolder { get; set; } = string.Empty;
            public bool ActivateLogging { get; set; } = true;    //activate logging
            public bool WriteToFile { get; set; }                //If logging fails then this can be set to false and de application will work without logging
            public string Customer { get; set; } = string.Empty;
            public string ApplicationName { get; set; } = string.Empty;
            public string ApplicationVersion { get; set; } = string.Empty;
            public string ApplicationBuildDate { get; set; } = string.Empty;
            public bool DebugMode { get; set; }

            private string UserName { get; set; } = string.Empty;
            private string MachineName { get; set; } = string.Empty;
            private string TotalRam { get; set; } = string.Empty;
            private string WindowsVersion { get; set; } = string.Empty;
            private string ProcessorCount { get; set; } = string.Empty;

            private short LoggingEfforts { get; set; } = 0;
            private string CurrentCultureInfo { get; set; } = string.Empty;
            private bool AbortLogging { get; set; }
            #endregion Properties

            #region Settings
            private void GetAppEnvironmentSettings()
            {
                using AppEnvironment AppEnv = new();
                UserName = AppEnv.UserName;
                MachineName = AppEnv.MachineName;
                WindowsVersion = AppEnv.WindowsVersion;
                ProcessorCount = AppEnv.ProcessorCount;
                TotalRam = AppEnv.TotalRam;
            }

            private void SetDefaultSettings()
            {
                CurrentCultureInfo = GetCultureInfo();

                LoggingEfforts = 0;
                WriteToFile = true;

                SetDefaultLogFileName();
                SetDefaultLogFileFolder();
            }

            private void SetDefaultLogFileName()
            {
                if (string.IsNullOrWhiteSpace(NameLogFile))
                {
                    NameLogFile = "LogFile.log";
                }
            }

            private void SetDefaultLogFileFolder()
            {
                //When there is no path for the log file, the file will be placed in the application folder
                if (string.IsNullOrWhiteSpace(LogFolder))
                {
                    using AppEnvironment Folder = new();
                    LogFolder = Folder.ApplicationPath;
                }
            }

            private static string GetCultureInfo()
            {
                return System.Globalization.CultureInfo.CurrentCulture.ToString();
            }
            #endregion Settings

            #region Check if there is a settings folder

            private bool CheckExistsSettingsFolder() // Check if the Settings folder exists, if not create it.
            {
                try
                {
                    if (!Directory.Exists(LogFolder))
                    {
                        Directory.CreateDirectory(LogFolder); // Create the settings folder.
                        _message.Add($"{LocalizationHelper.GetString("LogFolderCreated", LocalizationPaths.Logging)} { LogFolder}");  // TODO; doorvoeren in de hele klasse.

                        return true; // Folder was created.
                    }

                    return true; // Folder already exists.
                }
                catch (UnauthorizedAccessException ue)
                {
                    ShowErrorMessage("Fout opgetreden bij het bepalen van de 'logging directory'." + Environment.NewLine +
                                     $"Fout: {ue.Message}\n\nLocatie: {LogFolder}" + Environment.NewLine + Environment.NewLine +
                                     "Controleer of u rechten heeft om een map aan te maken op de locatie", "Fout.");
                    return false;
                }
                catch (PathTooLongException pe)
                {
                    ShowErrorMessage("Fout opgetreden bij het bepalen van de 'logging directory'." + Environment.NewLine +
                                     $"Fout: {pe.Message}\n\nPad: {LogFolder}" + Environment.NewLine + Environment.NewLine +
                                     "Het opgegeven pad bevat meer tekens dan is toegestaan", "Fout");
                    return false;
                }
                catch (Exception ex)
                {
                    ShowErrorMessage("Fout opgetreden bij het bepalen van de 'logging directory'." + Environment.NewLine +
                                     $"Fout: {ex.Message}\n\nPad: {LogFolder}" + Environment.NewLine + Environment.NewLine +
                                     "Onbekende fout", "Fout");
                    return false;
                    throw; // Rethrow exception to allow further handling.
                }
            }

            private void ShowErrorMessage(string title, string message)
            {
                MessageBox.Show(message, title, MessageBoxButtons.OK, MessageBoxIcon.Information);
                AbortLogging = true;
                WriteToFile = false; // Stop the logging.
            }

            #endregion Check if there is a settings folder

            #region methods
            private bool EnsureLogFileExists()
            {
                // Check if the log file exists; create it if necessary.
                try
                {
                    string logFileName = string.IsNullOrEmpty(UserName) || string.IsNullOrWhiteSpace(UserName)
                        ? NameLogFile
                        : $"{UserName}_{NameLogFile}";

                    string fullPath = Path.Combine(LogFolder, logFileName);

                    if (!File.Exists(fullPath))
                    {
                        File.Create(fullPath).Close(); // Create the log file if it does not exist.
                    }
                    return true;
                }
                catch (IOException e)
                {
                    ShowErrorMessage("Fout bij het controleren of het logbestand al bestaat." + Environment.NewLine +
                                     $"Fout: {e.Message}",
                                     "Fout.");
                    return false;
                }
            }
            private void ClearLogFile()
            {
                if (!AppendLogFile)
                {
                    try
                    {
                        string logFileName = string.IsNullOrWhiteSpace(UserName)
                            ? NameLogFile
                            : $"{UserName}_{NameLogFile}";

                        string fullPath = Path.Combine(LogFolder, logFileName);

                        if (File.Exists(fullPath))
                        {
                            File.Delete(fullPath); // Delete the log file if it exists.
                        }
                    }
                    catch (Exception e)
                    {
                        ShowErrorMessage("Fout bij het verwijderen van het logbestand." + Environment.NewLine +
                                         $"Fout: {e.Message}",
                                         "Fout.");
                        throw; // Rethrow the exception for further handling.
                    }
                }
            }
            #endregion methods

            #region Handle the log file
            public void WriteToLogInformation(string logMessage)
            {
                if (ActivateLogging)
                {
                    WriteToLog(LogAction.INFORMATION.ToString(), logMessage);
                }
            }

            public void WriteToLogError(string logMessage)
            {
                if (ActivateLogging)
                {
                    WriteToLog(LogAction.ERROR.ToString(), logMessage);
                }
            }

            public void WriteToLogWarning(string logMessage)
            {
                if (ActivateLogging)
                {
                    WriteToLog(LogAction.WARNING.ToString(), logMessage);
                }
            }

            public void WriteToLogDebug(string logMessage)  //Nog niet in gebruik
            {
                if (ActivateLogging)
                {
                    WriteToLog(LogAction.DEBUG.ToString(), logMessage);
                }
            }

            public void WriteToLogUnknown(string logMessage)  //Nog niet in gebruik
            {
                if (ActivateLogging)
                {
                    WriteToLog(LogAction.DEBUG.ToString(), logMessage);
                }
            }

            #endregion Handle the log file


            public bool StartLogging()
            {
                if (AbortLogging || !ActivateLogging)
                {
                    return false; // Abort als logging is afgebroken of niet geactiveerd.
                }

                SetDefaultSettings();
                GetAppEnvironmentSettings();

                if (CheckExistsSettingsFolder() && EnsureLogFileExists())
                {
                    ClearLogFile(); // Wis het logbestand als AppendLogFile niet is ingesteld.

                    string logFilePath = Path.Combine(LogFolder,
                        string.IsNullOrWhiteSpace(UserName) ? NameLogFile : $"{UserName}_{NameLogFile}");

                    using (StreamWriter writer = File.AppendText(logFilePath))
                    {
                        LogStart(writer);
                    }

                    CheckIfLogFolderIsCreated();

                    return !AbortLogging; // Return true if AbortLogging is false.
                }

                return false; // Return false if the settings or log file could not be configured.
            }

            private void CheckIfLogFolderIsCreated()
            {
                foreach (string msg in _message)
                {
                    WriteToLogInformation(msg);
                }
            }

            public void StopLogging()
            {
                if (!ActivateLogging) return; // Stop immediately if logging is not activated/started.

                string logFilePath = Path.Combine(LogFolder,
                    string.IsNullOrWhiteSpace(UserName) ? NameLogFile : $"{UserName}_{NameLogFile}");

                using StreamWriter writer = File.AppendText(logFilePath);
                LogStop(writer);
            }

            private void WriteToLog(string errorType, string logMessage)
            {
                if (!WriteToFile)
                {
                    // An event log can be placed here.
                    return;
                }

                string logFilePath = Path.Combine(LogFolder,
                    string.IsNullOrWhiteSpace(UserName) ? NameLogFile : $"{UserName}_{NameLogFile}");

                using StreamWriter writer = File.AppendText(logFilePath);

                if (!IsLogFileTooLarge())
                {
                    LogRegulier(errorType, logMessage, writer);
                }
                else
                {
                    LogRegulier("INFORMATIE", string.Empty, writer);
                    LogRegulier("INFORMATIE", "Logbestand wordt groter dan 10 MB.", writer);
                    LogRegulier("INFORMATIE", "Een nieuw logbestand wordt aangemaakt.", writer);
                    LogRegulier("INFORMATIE", string.Empty, writer);
                    LogStop(writer);

                    CopyLogFile();  // Make a copy of the log file.
                    EmptyLogFile(); // Clear the current log file.
                }
            }

            private bool IsLogFileTooLarge() // Naam aangepast voor duidelijkheid
            {
                try
                {
                    string logFilePath = Path.Combine(LogFolder,
                        string.IsNullOrWhiteSpace(UserName) ? NameLogFile : $"{UserName}_{NameLogFile}");

                    long fileLength = new FileInfo(logFilePath).Length;

                    // Maximum file size set to 10 MB (10 * 1024 * 1024 bytes)
                    const long maxFileSize = 10 * 1024 * 1024;
                    return fileLength > maxFileSize;
                }
                catch (Exception ex)
                {
                    AbortLogging = true;

                    MessageBox.Show(
                        "Bepalen grootte logbestand is mislukt." + Environment.NewLine +
                        Environment.NewLine +
                        "Fout: " + ex.Message + Environment.NewLine +
                        "Logging wordt uitgeschakeld.",
                        "Informatie",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Exclamation);

                    throw; // Dit zou moeten worden opgevangen door de aanroeper
                }
            }

            private void CopyLogFile()
            {
                try
                {
                    string timestamp = DateTime.Now.ToString("dd-MM-yyyy_HH_mm_ss", CultureInfo.InvariantCulture);
                    string sourceFile = Path.Combine(LogFolder, GetLogFileName());
                    string destFile = Path.Combine(LogFolder, $"{timestamp}_{GetLogFileName()}");

                    File.Copy(sourceFile, destFile);
                }
                catch (IOException ioex)
                {
                    // Error handling when copying the file.
                    WriteToLogError("Fout bij het kopiëren van het logbestand: " + ioex.Message);
                }
                catch (Exception ex)
                {
                    // General error handling.
                    WriteToLogError("Onverwachte fout bij het kopiëren van het logbestand: " + ex.Message);
                }
            }

            private string GetLogFileName()
            {
                if (string.IsNullOrWhiteSpace(UserName))
                {
                    return NameLogFile;
                }
                return $"{UserName}_{NameLogFile}";
            }

            private void EmptyLogFile()
            {
                string logFilePath = Path.Combine(LogFolder, GetLogFileName());

                if (File.Exists(logFilePath))
                {
                    File.Delete(logFilePath); // Delete the file.
                    StartLogging();           // Create new log file.
                }
                else
                {
                    WriteToLogError("Het logbestand bestaat niet en kan niet worden geleegd.");
                }
            }

            private void LogStart(TextWriter w)
            {
                try
                {
                    string date = DateTime.Today.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture);
                    StringBuilder sb = new();

                    sb.AppendLine("===================================================================================================");
                    sb.AppendLine("Applicatie        : " + ApplicationName);
                    sb.AppendLine("Versie            : " + ApplicationVersion);
                    sb.AppendLine("Datum Applicatie  : " + ApplicationBuildDate);
                    sb.AppendLine("Organisatie       : " + Customer);
                    sb.AppendLine();
                    sb.AppendLine("Datum             : " + date);
                    sb.AppendLine("Naam gebruiker    : " + UserName);
                    sb.AppendLine("Naam machine      : " + MachineName);

                    if (DebugMode)
                    {
                        sb.AppendLine("Windows versie    : " + WindowsVersion);
                        sb.AppendLine("Aantal processors : " + ProcessorCount);
                        sb.AppendLine("Fysiek geheugen   : " + Convert.ToString(TotalRam, CultureInfo.InvariantCulture));
                        sb.AppendLine("CultuurInfo       : " + CurrentCultureInfo);
                    }

                    sb.AppendLine("===================================================================================================");
                    sb.AppendLine();

                    w.Write(sb.ToString());
                }
                catch (IOException ioex)
                {
                    ShowErrorMessage("Fout bij het starten van de logging" + Environment.NewLine + $"Fout: {ioex.Message}", "Fout.");
                }
                catch (Exception ex)
                {
                    ShowErrorMessage("Onverwachte fout bij het starten van de logging" + Environment.NewLine + $"Fout: {ex.Message}", "Fout.");
                }
            }

            private void LogRegulier(string errorType, string logMessage, TextWriter w)
            {
                try
                {
                    /*
                    var logTypes = new Dictionary<string, string>()
                    {
                        { "INFORMATIE", "INFORMATIE" },
                        { "WAARSCHUWING", "WAARSCHUWING" },
                        { "FOUT", "FOUT" },
                        { "DEBUG", "DEBUG" }
                    };*/

                    /*if (!logTypes.ContainsKey(errorType))
                    {
                        errorType = LogAction.UNKNOWN.ToString();
                    }*/

                    //w.WriteLine($"{DateTime.Now} | {logTypes[errorType],-12} | {logMessage}");  // -12 is PadRight[12]
                    w.WriteLine($"{DateTime.Now} | {errorType} | {logMessage}");  // -12 is PadRight[12]


                    if (errorType == "FOUT")
                    {
                        // Event logging can be added here.
                        // AddMessageToEventLog(logMessage, errorType, 1000);
                    }
                }
                catch (ArgumentException aex)
                {
                    LoggingEfforts += 1;
                    StoppenLogging();
                    ShowErrorMessage("ArgumentException bij LogRegulier" + Environment.NewLine + $"Fout: {aex.Message}", "Fout.");
                }
                catch (Exception ex)
                {
                    LoggingEfforts += 1;
                    StoppenLogging();
                    ShowErrorMessage("Onverwachte fout bij LogRegulier" + Environment.NewLine + $"Fout: {ex.Message}", "Fout.");
                    throw;
                }
            }

            private void StoppenLogging()
            {
                if (LoggingEfforts >= 5)
                {
                    WriteToFile = false; // Stop het schrijven naar het logbestand
                    WriteToLogError($"De logging van '{ApplicationName}' is gestopt omdat er reeds 5 pogingen zijn mislukt.");

                    MessageBox.Show("Schrijven naar het logbestand is mislukt. Logging wordt uitgeschakeld.", "Informatie",
                        MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                }
            }

            private void LogStop(TextWriter w)
            {
                string closeLogString = string.IsNullOrWhiteSpace(ApplicationName) ? "De applicatie is afgesloten." : $"{ApplicationName} is afgesloten.";

                try
                {
                    w.WriteLine("===================================================================================================");
                    w.WriteLine(closeLogString);
                    w.WriteLine("===================================================================================================");
                    w.WriteLine();
                    w.Flush();
                    w.Close();
                }
                catch (IOException ioex)
                {
                    AbortLogging = true;
                    ShowErrorMessage("Fout bij het stoppen van de logging" + Environment.NewLine + $"Fout: {ioex.Message}", "Fout.");
                }
                catch (Exception ex)
                {
                    AbortLogging = true;
                    ShowErrorMessage("Onverwachte fout bij het stoppen van de logging" + Environment.NewLine + $"Fout: {ex.Message}", "Fout.");
                }
            }

            #region Writing to Windows event log in Windows NOT USED
            //Writing to Windows event log in Windows NOT USED
            /*
            private static void AddMessageToEventLog(string mess, string ErrorType, int Id)
            {
                EventLog elog = new EventLog("");

                if (!EventLog.SourceExists(Settings.ApplicationName))
                {
                    EventLog.CreateEventSource(Settings.ApplicationName, "Application");
                }

                elog.Source = Settings.ApplicationName;
                elog.EnableRaisingEvents = true;

                EventLogEntryType entryType = EventLogEntryType.Error;

                switch (ErrorType)
                {
                    case "FOUT":
                        {
                            entryType = EventLogEntryType.Error;
                            break;
                        }
                    case "INFORMATIE":
                        {
                            entryType = EventLogEntryType.Information;
                            break;
                        }
                    case "WAARSCHUWING":
                        {
                            entryType = EventLogEntryType.Warning;
                            break;
                        }
                }

                elog.WriteEntry(mess, entryType, Id);

                /*    catch (System.Security.SecurityException secError)
                    {

                    }
                    catch (Exception eventError)
                    {

                    }*/
            /* }*/
            #endregion Writing to Windows event log in Windows NOT USED



            private class AppEnvironment : IDisposable
            {
                #region Properties
                public string ApplicationPath { get; set; } = string.Empty;
                public string UserName { get; set; } = string.Empty;
                public string MachineName { get; set; } = string.Empty;
                public string WindowsVersion { get; set; } = string.Empty;
                public string ProcessorCount { get; set; } = string.Empty;
                public string TotalRam { get; set; } = string.Empty;
                #endregion Properties

                #region Constructor
                public AppEnvironment()
                {
                    this.SetProperties();
                }
                #endregion Constructor

                private void SetProperties()
                {
                    this.ApplicationPath = GetApplicationPath();
                    this.UserName = GetUserName();
                    this.MachineName = GetMachineName();
                    this.WindowsVersion = GetWindowsVersion();
                    this.ProcessorCount = GetProcessorCount();
                    this.TotalRam = GetTotalRam();
                }

                private static string GetApplicationPath() // Get the application path.
                {
                    try
                    {
                        string appPath;
                        appPath = Directory.GetCurrentDirectory();
                        appPath += "\\";                                  // Add \to the path.
                        return appPath.Replace("file:\\", string.Empty);  // Remove the text "file:\\" from the path.
                    }
                    catch (ArgumentException aex)
                    {
                        throw new InvalidOperationException(aex.Message);
                    }
                    catch (Exception)
                    {
                        throw new InvalidOperationException("Ophalen locatie applicatie is mislukt.");
                    }
                }

                private static string GetUserName()
                {
                    try
                    {
                        return Environment.UserName;
                    }
                    catch (Exception)
                    {
                        throw new InvalidOperationException("Ophalen naam gebruiker is mislukt.");
                    }
                }
                private static string GetMachineName()
                {
                    try
                    {
                        return Environment.MachineName;
                    }
                    catch (Exception)
                    {
                        throw new InvalidOperationException("Ophalen naam machine is mislukt.");
                    }
                }

                private static string GetWindowsVersion()
                {
                    string registryKey = @"SOFTWARE\Microsoft\Windows NT\CurrentVersion";
                    using (RegistryKey? key = Registry.LocalMachine.OpenSubKey(registryKey))
                    {
                        if (key != null)
                        {
                            // Using null-coalescing operators (??) to provide fallback values if registry values are null.
                            var productName = key.GetValue("ProductName") as string ?? "Unknown Product";
                            var releaseId = key.GetValue("ReleaseId") as string ?? "Unknown Release ID";
                            var currentBuild = key.GetValue("CurrentBuild") as string ?? "Unknown Build";

                            return $"Product Name: {productName}, Release ID: {releaseId}, Current Build: {currentBuild}";
                        }
                    }

                    // Fallback to OS version if registry values are not accessible.
                    return Environment.OSVersion.Version.ToString();
                }

                private static string GetProcessorCount()
                {
                    try
                    {
                        return Convert.ToString(Environment.ProcessorCount, CultureInfo.InvariantCulture);
                    }
                    catch (Exception)
                    {
                        throw new InvalidOperationException("Ophalen aantal processors is mislukt.");
                    }
                }

                private static string GetTotalRam()
                {
                    try
                    {
                        using ManagementClass mc = new("Win32_ComputerSystem");
                        ManagementObjectCollection moc = mc.GetInstances();

                        ObjectQuery wql = new("SELECT * FROM Win32_OperatingSystem");
                        ManagementObjectSearcher searcher = new(wql);
                        ManagementObjectCollection results = searcher.Get();

                        string TotalVisibleMemorySize = "Geen Totaal telling Ram gevonden.";

                        // string FreePhysicalMemory;
                        // string TotalVirtualMemorySize;
                        // string FreeVirtualMemory;
                        foreach (ManagementObject result in results.Cast<ManagementObject>())
                        {
                            TotalVisibleMemorySize = Convert.ToString(Math.Round(Convert.ToDouble(result["TotalVisibleMemorySize"], CultureInfo.InvariantCulture) / 1000000, 2), CultureInfo.InvariantCulture) + " GB";

                            // FreePhysicalMemory = result["FreePhysicalMemory"].ToString();
                            // TotalVirtualMemorySize = result["TotalVirtualMemorySize"].ToString();
                            // FreeVirtualMemory = result["FreeVirtualMemory"].ToString();
                        }

                        return TotalVisibleMemorySize;
                    }
                    catch (Exception)
                    {
                        // throw new InvalidOperationException(ResourceEx.Get_TotalRam);
                        return "Geen Totaal telling Ram gevonden.";
                    }

                    /*try
                    {
                        using (ManagementClass mc = new ManagementClass("Win32_ComputerSystem"))
                        {
                            ManagementObjectCollection moc = mc.GetInstances();

                            foreach (ManagementObject item in moc)
                            {
                                return Convert.ToString(Math.Round(Convert.ToDouble(item.Properties["TotalPhysicalMemory"].Value, CultureInfo.InvariantCulture) / 1073741824, 2), CultureInfo.InvariantCulture) + " GB";
                            }

                            return "Geen Totaal telling Ram gevonden.";
                        }
                    }
                    catch (Exception)
                    {
                        //throw new InvalidOperationException(ResourceEx.Get_TotalRam);
                        return "Geen Totaal telling Ram gevonden.";
                    }*/
                }

                #region IDisposable

                private bool disposed = false;

                //Implement IDisposable.
                public void Dispose()
                {
                    this.Dispose(true);
                    GC.SuppressFinalize(this);
                }

                protected virtual void Dispose(bool disposing)
                {
                    if (!this.disposed)
                    {
                        if (disposing)
                        {
                            // Free other state (managed objects).
                            this.ApplicationPath = string.Empty;
                            this.UserName = string.Empty;
                            this.MachineName = string.Empty;
                            this.WindowsVersion = string.Empty;
                            this.ProcessorCount = string.Empty;
                            this.TotalRam = string.Empty;
                        }

                        // Free your own state (unmanaged objects).
                        // Set large fields to null.
                        this.disposed = true;
                    }
                }
                #endregion IDisposable
            }

        }
        #endregion private class Logging
    }
}