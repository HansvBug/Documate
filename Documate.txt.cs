using Documate.Library;

namespace Documate
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            //ApplicationConfiguration.Initialize();
            //Application.Run(new MainForm());


            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Configure dependency injection
            _ = new Startup();
            var serviceProvider = Startup.ConfigureServices();

            // Run the application
            Startup.Run(serviceProvider);
        }
    }
}

using Documate.Models;
using Documate.Presenters;
using Documate.Views;
using Microsoft.Extensions.DependencyInjection;
using System.Globalization;


namespace Documate.Library
{
    public class Startup
    {
        /// <summary>
        /// The method ConfigureServices initializes a new ServiceCollection.
        /// Singleton   : Only a single instance of the service is created and shared across the entire application lifetime.
        /// Transient   : A new instance is created each time the service is requested.
        /// Scoped      : An instance is created once per request(typically used in web applications).
        /// </summary>
        /// <returns>ServiceProvider</returns>
        public static ServiceProvider ConfigureServices() // (D)ependency (I)njection
        {
            InitializeLocalization();  // Initializes the language settings.

            return new ServiceCollection()
            .AddSingleton<IMainView, MainForm>()           // Registers MainForm as the implementation for the IMainView interface. This means that whenever IMainView is requested, the application will provide a single, shared instance of MainForm
            .AddSingleton<MainPresenter>()                 // Registers MainPresenter so that a new instance is created every time it’s requested. No specific interface is associated, so it’s registered by its concrete type.
            .AddSingleton<DirectoryModel>()
            .AddSingleton<LoggingModel>()
            .AddTransient<IConfigureView, ConfigureForm>() // Register as Transient                
            .AddTransient<ConfigurePresenter>()            // Register as Transient
            .BuildServiceProvider();
        }

        public static void Run(ServiceProvider serviceProvider)
        {
            // Get the presenter from the service provider
            var presenter = serviceProvider.GetService<MainPresenter>();

            // Get the MainForm from the service provider and link the presenter with the view.
            if (serviceProvider.GetService<IMainView>() is MainForm form && presenter != null)
            {
                form.SetPresenter(presenter);

                // Start the application
                presenter?.Run();
            }
            else if (presenter == null)
            {
                throw new InvalidOperationException("MainPresenter not registered.");
            }
        }

        public static void InitializeLocalization()
        {
            // Laad de taal uit de instellingen of gebruik een standaardwaarde
            string language = Properties.Settings.Default.Language ?? "en-EN";
            CultureInfo culture = new CultureInfo(language);

            // Stel de cultuur in voor de huidige thread
            Thread.CurrentThread.CurrentCulture = culture;
            Thread.CurrentThread.CurrentUICulture = culture;

            // Optioneel: Log de gekozen cultuur voor debugging
            Console.WriteLine($"Taal ingesteld op: {culture.Name}");

            LocalizationHelper.SetCulture(language);
        }
    }
}

using System.Globalization;
using System.Resources;

namespace Documate.Library
{
    public static class LocalizationHelper
    {
        public static string GetString(string key, string resourcePath)
        {
            try
            {
                ResourceManager resourceManager = new ResourceManager(resourcePath, typeof(LocalizationHelper).Assembly);
                return resourceManager.GetString(key, CultureInfo.CurrentUICulture) ?? $"{key}"; // Fallback with debug-placeholder.
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error retrieving key '{key}' from '{resourcePath}': {ex.Message}");
                return $"{key}"; // Fallback to a recognizable placeholder.
            }
        }

        public static void SetCulture(string cultureCode)
        {
            CultureInfo newCulture = new CultureInfo(cultureCode);
            CultureInfo.CurrentCulture = newCulture;
            CultureInfo.CurrentUICulture = newCulture;

            // Save the language in settings.
            Properties.Settings.Default.Language = cultureCode;
            Properties.Settings.Default.Save();
        }
    }

    public static class LocalizationPaths
    {
        public const string General = "Documate.Resources.general.General";
        public const string MainForm = "Documate.Resources.Views.MainForm";
        public const string MainPresenter = "Documate.Resources.Presenters.MainPresenter";
        public const string DirectoryModel = "Documate.Resources.Models.DirectoryModel";
        public const string Logging = "Documate.Resources.Logging.Logging";
        public const string ConfigureForm = "Documate.Resources.Views.ConfigureForm";


    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Library
{
    public class Common
    {
        public enum LogAction
        {
            INFORMATION,
            WARNING,
            ERROR,
            DEBUG,
            UNKNOWN
        }

        public enum ToolstripstatusLabelName
        {
            ToolStripStatusLabel1,
            ToolStripStatusLabel2
        }
    }
}

using System.Globalization;

namespace Documate.Library
{
    public static class AppSettings
    {
        public static string ApplicationBuildDate { get { return DateTime.Now.ToString("dd-MM-yyyy", CultureInfo.InvariantCulture); } }

        public const string DatabaseFolder = "Database";
        public const string LoggingFolder = "Logging";
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Library
{
    public class AppMessage
    {
        // Different message types. This is used to determine the title of a message box.
        public enum MessageType
        {
            Information,
            Warning,
            Error,
            None
        }

        public List<AppMessage> Messages { get; private set; }
        public string MsgText { get; set; } = string.Empty;
        public MessageType MsgType { get; set; }

        public AppMessage()
        {
            Messages = [];  // Messages = new List<AppMessage>();
        }
        public void AddMessage(MessageType type, string text)
        {
            Messages.Add(new AppMessage
            {
                MsgType = type,
                MsgText = text
            });
        }
    }
}


using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Documate.Library;
using Documate.Models;

namespace Documate.Views
{
    public interface IMainView
    {        
        event EventHandler MenuItemOpenFileClicked;
        event EventHandler MenuItemCloseFileClicked;
        event EventHandler MenuItemNewFileClicked;
        event EventHandler MenuItemExitClicked;
        event EventHandler MenuItemLanguageNLClicked;
        event EventHandler MenuItemLanguageENClicked;
        event EventHandler MenuItemOptionsOptionsClicked;
        event EventHandler DoFormShown;
        event FormClosingEventHandler DoFormClosing;

        string FormMainText { set; }
        string MenuItemProgramText { set; }
        string MenuItemProgramOpenFileText { set; }
        string MenuItemProgramCloseFileText { set; }
        string MenuItemProgramNewFileText { set; }
        string MenuItemProgramExitText { set; }
        string MenuItemOptionsText { set; }
        string MenuItemOptionsOptionsText { set; }
        string MenuItemLanguageText { set; }
        string MenuItemLanguageENText { set; }
        string MenuItemLanguageNLText { set; }

        bool MenuItemENChecked { get; set; }
        bool MenuItemNLChecked { get; set; }

        string TabPageReadItemsText {  set; }
        string TabPageEditItemsText { set; }

        string ToolStripStatusLabel1Text { set; }
        string ToolStripStatusLabel2Text { set; }

        void OpenFile();
        void CloseFile();
        void NewFile();
        void CloseView();
        void ShowConfigureForm();
    }
}


using Documate.Library;
using Documate.Models;
using Documate.Presenters;
using Documate.Views;
using System.Windows.Forms;

namespace Documate
{
    public partial class MainForm : Form, IMainView
    {
        private MainPresenter? _presenter;
        public MainForm()
        {
            InitializeComponent();
        }

        public event EventHandler? MenuItemOpenFileClicked;
        public event EventHandler? MenuItemCloseFileClicked;
        public event EventHandler? MenuItemNewFileClicked;
        public event EventHandler? MenuItemExitClicked;
        public event EventHandler? MenuItemLanguageNLClicked;
        public event EventHandler? MenuItemLanguageENClicked;
        public event EventHandler? MenuItemOptionsOptionsClicked;
        public event EventHandler? DoFormShown;
        public event FormClosingEventHandler? DoFormClosing;


        #region Properties Set Texts

        public string FormMainText
        {
            set => this.Text = value;
        }
        public string MenuItemProgramText
        {
            set => MenuItemProgram.Text = value;
        }

        public string MenuItemProgramOpenFileText
        {
            set => MenuItemProgramOpenFile.Text = value;
        }
        public string MenuItemProgramCloseFileText
        {
            set => MenuItemProgramCloseFile.Text = value;
        }
        public string MenuItemProgramNewFileText
        {
            set => MenuItemProgramNewFile.Text = value;
        }
        public string MenuItemProgramExitText
        {
            set => MenuItemProgramExit.Text = value;
        }

        public string MenuItemOptionsText
        {
            set => MenuItemOptions.Text = value;
        }
        public string MenuItemOptionsOptionsText
        {
            set => MenuItemOptionsOptions.Text = value;
        }
        public string MenuItemLanguageText
        {
            set => MenuItemLanguage.Text = value;
        }
        public string MenuItemLanguageENText
        {
            set => MenuItemLanguageEN.Text = value;
        }
        public string MenuItemLanguageNLText
        {
            set => MenuItemLanguageNL.Text = value;
        }

        public string TabPageReadItemsText
        {
            set => TabPageReadItems.Text = value;
        }
        public string TabPageEditItemsText
        {
            set=> TabPageEditItems.Text = value;
        }

        public string ToolStripStatusLabel1Text
        {
            set => this.ToolStripStatusLabel1.Text = value;
        }

        public string ToolStripStatusLabel2Text
        {
            set => this.ToolStripStatusLabel2.Text = value;
        }

        #endregion Properties Set Texts

        #region Properties
        public bool MenuItemENChecked
        {
            get => MenuItemLanguageEN.Checked;
            set => MenuItemLanguageEN.Checked = value;
        }

        public bool MenuItemNLChecked
        {
            get => MenuItemLanguageNL.Checked;
            set => MenuItemLanguageNL.Checked = value;
        }

        #endregion Properties

        // Connect the presenter after the form has been created.
        public void SetPresenter(MainPresenter presenter)
        {
            _presenter = presenter;
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e); // First: calls Form's native OnLoad method.
            

            // Connect eventhandlers
            MenuItemProgramOpenFile.Click += (sender, args) => MenuItemOpenFileClicked?.Invoke(this, EventArgs.Empty);  // inline event handler to subscribe to the Click event of MenuItemProgramOpenFile
            MenuItemProgramCloseFile.Click += (sender, args) => MenuItemCloseFileClicked?.Invoke(this, EventArgs.Empty);
            MenuItemProgramNewFile.Click += (sender, args) => MenuItemNewFileClicked?.Invoke(this, EventArgs.Empty);
            MenuItemProgramExit.Click += (sender, args) => MenuItemExitClicked?.Invoke(this, EventArgs.Empty);  // Send the event to the presenter. The presenter takes care of the handling.
            MenuItemLanguageEN.Click += (sender, args) => MenuItemLanguageENClicked?.Invoke(this, EventArgs.Empty);
            MenuItemLanguageNL.Click += (sender, args) => MenuItemLanguageNLClicked?.Invoke(this, EventArgs.Empty);
            MenuItemOptionsOptions.Click += (sender, args) =>  MenuItemOptionsOptionsClicked?.Invoke(this, EventArgs.Empty);

            this.Shown += MainForm_Shown!;  // Bind the Shown event to the internal handler; suppress the warning by using the null-forgiving operator "!"
            
            this.FormClosing += MainForm_FormClosing!;

            //
            this.BackColor = SystemColors.Window;
            _presenter?.StartLogging();
            _presenter?.CreateDirectory(Models.DirectoryModel.DirectoryOption.ApplicatieDir, AppSettings.DatabaseFolder);

            LoadFormPosition();
        }


        #region Menu items
        public void OpenFile()
        {
            MessageBox.Show("Open");
        }
        public void CloseFile()
        {
            MessageBox.Show("Close");
        }
        public void NewFile()
        {
            MessageBox.Show("New");
        }
        public void CloseView()
        {
            this.Close();
        }

        public void ShowConfigureForm()
        {
            MessageBox.Show("Boe.....");  // Not used

        }
        #endregion Menu Items

        private void MainForm_Shown(object sender, EventArgs e)
        {
            DoFormShown?.Invoke(this, EventArgs.Empty);
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            _presenter?.SaveFormPosition(this);
            DoFormClosing?.Invoke(this, e);
        }


        private void LoadFormPosition()
        {
            _presenter?.LoadFormPosition(this);
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Views
{
    public interface IConfigureView
    {
        event EventHandler DoFormShown;

        string FormConfigureText { set; }
        string ChkActivateLoggingText { set; }
        string ChkAppendLogFileText { set; }
        string TabPageVariousText { set; }
        string TabPageDatabaseText { set; }
        string BtnCloseText { set; }

    }
}


using Documate.Presenters;
using Documate.Views;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Documate
{
    public partial class ConfigureForm : Form, IConfigureView
    {
        private ConfigurePresenter? _presenter;

        #region Properties
        public string FormConfigureText
        {
            set => this.Text = value;
        }
        public string ChkActivateLoggingText
        {
            set => ChkActivateLogging.Text = value;
        }
        public string ChkAppendLogFileText
        {
            set => ChkAppendLogFile.Text = value;
        }
        public string TabPageVariousText
        {
            set => TabPageVarious.Text = value;
        }
        public string TabPageDatabaseText
        {
            set => TabPageDatabase.Text = value;
        }
        public string BtnCloseText
        {
            set => BtnClose.Text = value;
        }
        #endregion Properties

        public event EventHandler? DoFormShown;

        public ConfigureForm()
        {
            InitializeComponent();
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e); // First: calls Form's native OnLoad method.

            this.Shown += ConfigureForm_Shown!;
            _presenter?.OnFormShown();
            this.Refresh();

            this.BackColor = SystemColors.Window;
        }
        private void ConfigureForm_Shown(object sender, EventArgs e)
        {
            DoFormShown?.Invoke(this, EventArgs.Empty);
        }
        // Connect the presenter after the form has been created.
        public void SetPresenter(ConfigurePresenter presenter)
        {
            _presenter = presenter;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            _presenter?.OnFormShown();
            this.Refresh();
        }
    }
}

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Documate.Models;
using static Documate.Library.Common;
using static Documate.Models.LoggingModel;
using static Documate.Presenters.MainPresenter;

namespace Documate.Presenters
{
    public interface IMainPresenter
    {
        /// <summary>
        /// Start the program.
        /// </summary>
        void Run();
        void OnFormShown();
        void OnFormClosing();

        void CreateDirectory(DirectoryModel.DirectoryOption directoryOption, string FolderName);
        void StartLogging();
        void StopLogging();
        void WriteToLog(LogAction logAction, string logText);
        void SetStatusbarStaticText(string toolStripStatusLabelName, string text);

        void LoadFormPosition(MainForm mainForm);
        void SaveFormPosition(MainForm mainForm);
    }
}

using Documate.Library;
using Documate.Models;
using Documate.Properties;
using Documate.Resources.Views;
using Documate.Views;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static Documate.Library.AppMessage;
using static Documate.Library.Common;
using static Documate.Models.LoggingModel;
using static System.Windows.Forms.LinkLabel;

namespace Documate.Presenters
{
    public class MainPresenter : IMainPresenter
    {
        private readonly IMainView _view;
        private readonly DirectoryModel _directoryModel;
        private readonly LoggingModel _loggingModel;
        private readonly FormPosition _formPosition;
        private readonly IServiceProvider _serviceProvider;

        public MainPresenter(IMainView view, DirectoryModel directoryModel, LoggingModel loggingModel, IServiceProvider serviceProvider)
        {
            _view = view;

            // Link the view's event handlers to the methods in the presenter.
            _view.MenuItemOpenFileClicked += this.OnMenuItemOpenFileClicked;
            _view.MenuItemCloseFileClicked += this.OnMenuItemCloseFileClicked;
            _view.MenuItemNewFileClicked += this.OnMenuItemNewFileClicked;
            _view.MenuItemExitClicked += this.OnMenuItemExitClicked;
            _view.MenuItemLanguageENClicked += this.OnMenuItemLanguageENClicked;
            _view.MenuItemLanguageNLClicked += this.OnMenuItemLanguageNLClicked;
            _view.MenuItemOptionsOptionsClicked += this.OnMenuItemOptionsOptionsClicked;

            _view.DoFormShown += (s, e) => OnFormShown();
            _view.DoFormClosing += (s, e) => OnFormClosing();            

            _directoryModel = directoryModel;
            _loggingModel = loggingModel;

            _serviceProvider = serviceProvider; // Added for the configure form/view
        }

        public MainPresenter(FormPosition formposition)
        {
            _formPosition = formposition;         
        }

        public void Run()
        {
            Application.Run((Form)_view);  // Start/Show the MainForm.            
        }

        public void OnFormShown()
        {
            // Get the current language setting from Properties.Settings.
            string language = Properties.Settings.Default.Language ?? "en-EN";

            _view.MenuItemNLChecked = language == "nl-NL";
            _view.MenuItemENChecked = language == "en-EN";

            // Update the UI strings.
            UpdateUIStrings();

            SetStatusbarStaticText(ToolstripstatusLabelName.ToolStripStatusLabel1.ToString(), $"{LocalizationHelper.GetString("Welcome", LocalizationPaths.General)}");
            SetStatusbarStaticText(ToolstripstatusLabelName.ToolStripStatusLabel2.ToString(), $"{LocalizationHelper.GetString("MVPAtWork", LocalizationPaths.General)}");
        }
        public void OnFormClosing()
        {            
            StopLogging();
        }

        public void SetStatusbarStaticText(string toolStripStatusLabelName, string text)
        {
            if (toolStripStatusLabelName == ToolstripstatusLabelName.ToolStripStatusLabel1.ToString())
            {
                _view.ToolStripStatusLabel1Text = text;
            }
            else if (toolStripStatusLabelName == ToolstripstatusLabelName.ToolStripStatusLabel2.ToString())
            {
                _view.ToolStripStatusLabel2Text = text;
            }
        }

        #region View Menu Items
        private void OnMenuItemOpenFileClicked(object? sender, EventArgs e)
        {
            _view.OpenFile();
        }
        private void OnMenuItemNewFileClicked(object? sender, EventArgs e)
        {
            _view.NewFile();
        }
        private void OnMenuItemCloseFileClicked(object? sender, EventArgs e)
        {
            _view.CloseFile();
        }
        private void OnMenuItemExitClicked(object? sender, EventArgs e)
        {
            _view.CloseView();
        }
        private void OnMenuItemOptionsOptionsClicked(object? sender, EventArgs e)
        {
            //_view.ShowConfigureForm();  Not used
            this.OpenConfigureForm();

        }
        #endregion View Menu Items

        private void OnMenuItemLanguageNLClicked(object? sender, EventArgs e)
        {
            LocalizationHelper.SetCulture("nl-NL");
            UpdateUIStrings();

            _view.MenuItemNLChecked = true;
            _view.MenuItemENChecked = false;

            WriteToLog(LogAction.INFORMATION, $"{LocalizationHelper.GetString("NLIsActivated", LocalizationPaths.MainPresenter)}");
        }

        private void OnMenuItemLanguageENClicked(object? sender, EventArgs e)
        {
            LocalizationHelper.SetCulture("en-EN");
            UpdateUIStrings();

            _view.MenuItemENChecked = true;
            _view.MenuItemNLChecked = false;

            WriteToLog(LogAction.INFORMATION, $"{LocalizationHelper.GetString("ENIsActivated", LocalizationPaths.MainPresenter)}");
        }

        public void CreateDirectory(DirectoryModel.DirectoryOption directoryOption, string FolderName)
        {
            _directoryModel.CreateDirectory(directoryOption, FolderName);

            if (_directoryModel.Messages.Count > 0)
            {
                foreach (var message in _directoryModel.Messages)
                {
                    WriteToLog((LogAction)message.MsgType, message.MsgText);
                }
            }
        }

        #region Helper Methods
        private void UpdateUIStrings()
        {
            // Update UI text using resource strings
            _view.FormMainText = LocalizationHelper.GetString("FormMain", LocalizationPaths.MainForm);
            _view.MenuItemProgramText = LocalizationHelper.GetString("MenuProgram", LocalizationPaths.MainForm);
            _view.MenuItemProgramOpenFileText = LocalizationHelper.GetString("MenuItemProgramOpenFile", LocalizationPaths.MainForm);
            _view.MenuItemProgramCloseFileText = LocalizationHelper.GetString("MenuItemProgramCloseFile", LocalizationPaths.MainForm);
            _view.MenuItemProgramNewFileText = LocalizationHelper.GetString("MenuItemProgramNewFile", LocalizationPaths.MainForm);
            _view.MenuItemProgramExitText = LocalizationHelper.GetString("MenuItemProgramExit", LocalizationPaths.MainForm);
            _view.MenuItemOptionsText = LocalizationHelper.GetString("MenuItemOptions", LocalizationPaths.MainForm);
            _view.MenuItemOptionsOptionsText = LocalizationHelper.GetString("MenuItemOptionsOptions", LocalizationPaths.MainForm);
            _view.MenuItemLanguageText = LocalizationHelper.GetString("MenuItemLanguage", LocalizationPaths.MainForm);
            _view.MenuItemLanguageENText = LocalizationHelper.GetString("MenuItemLanguageEN", LocalizationPaths.MainForm);
            _view.MenuItemLanguageNLText = LocalizationHelper.GetString("MenuItemLanguageNL", LocalizationPaths.MainForm);
            _view.TabPageReadItemsText = LocalizationHelper.GetString("TabPageReadItems", LocalizationPaths.MainForm);
            _view.TabPageEditItemsText = LocalizationHelper.GetString("TabPageEditItems", LocalizationPaths.MainForm);

            // Add updates for other UI components here as needed
        }
        #endregion Helper Methods

        #region Logging
        public void StartLogging()
        {
            _loggingModel.StartLogging();
        }

        public void StopLogging()
        {
            _loggingModel.StopLogging();
        }

        public void WriteToLog(LogAction logAction, string logText)
        {
            _loggingModel.WriteToLog(logAction, logText);
        }
        #endregion Logging

        public void LoadFormPosition(MainForm mainForm)
        {            
            using FormPosition frmPos = new(mainForm);
            Microsoft.Win32.SystemEvents.DisplaySettingsChanged += frmPos.SystemEvents_DisplaySettingsChanged!;
            frmPos.RestoreWindowPosition();
        }

        public void SaveFormPosition(MainForm mainForm)
        {
            using FormPosition frmPos = new(mainForm);
            frmPos.StoreWindowPosition();
        }

        public void OpenConfigureForm()
        {
            var configureView = _serviceProvider.GetService<IConfigureView>() as ConfigureForm;
            var configurePresenter = _serviceProvider.GetService<ConfigurePresenter>();

            if (configureView != null && configurePresenter != null)
            {
                configureView.SetPresenter(configurePresenter);
                configureView.ShowDialog(); // Open ConfigureForm as dialog form.
            }
        }
    }
}


using Documate.Library;
using Documate.Models;
using Documate.Views;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static Documate.Library.Common;

namespace Documate.Presenters
{
    public class ConfigurePresenter
    {
        private readonly IConfigureView _view;
        private readonly LoggingModel _loggingModel;

        public ConfigurePresenter(IConfigureView view, LoggingModel loggingModel)
        {
            _view = view;
            _loggingModel = loggingModel;

            // set eventhandlers

            _view.DoFormShown += (s, e) => OnFormShown();
        }

        public void OnFormShown()
        {
            // Get the current language setting from Properties.Settings.
            string language = Properties.Settings.Default.Language ?? "en-EN";

            //_view.MenuItemNLChecked = language == "nl-NL";
            //_view.MenuItemENChecked = language == "en-EN";

            // Update the UI strings.
            UpdateUIStrings();
        }

        private void UpdateUIStrings()
        {
            // Update UI text using resource strings
            _view.FormConfigureText = LocalizationHelper.GetString("FormConfigure", LocalizationPaths.ConfigureForm);
            _view.ChkActivateLoggingText = LocalizationHelper.GetString("ChkActivateLogging", LocalizationPaths.ConfigureForm);
            _view.ChkAppendLogFileText = LocalizationHelper.GetString("ChkAppendLogFile", LocalizationPaths.ConfigureForm);
            _view.TabPageVariousText = LocalizationHelper.GetString("TabPageVarious", LocalizationPaths.ConfigureForm);
            _view.TabPageDatabaseText = LocalizationHelper.GetString("TabPageDatabase", LocalizationPaths.ConfigureForm);
            _view.BtnCloseText = LocalizationHelper.GetString("BtnClose", LocalizationPaths.ConfigureForm);
        }
    }
}


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
                    logging.WriteToLogUnknown(logText);  // Write a log line for unknown actions, if necessary.
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
            public bool AppendLogFile { get; set; } = true;      // Append the logfile true is the default.
            public string LogFolder { get; set; } = string.Empty;
            public bool ActivateLogging { get; set; } = true;    // Activate logging.
            public bool WriteToFile { get; set; }                // If logging fails then this can be set to false and de application will work without logging.
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
                // When there is no path for the log file, the file will be placed in the application folder.
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
                        _message.Add($"{LocalizationHelper.GetString("LogFolderCreated", LocalizationPaths.Logging)} { LogFolder}");

                        return true; // Folder was created.
                    }

                    return true; // Folder already exists.
                }
                catch (UnauthorizedAccessException ue)
                {
                    ShowErrorMessage(LocalizationHelper.GetString("ErrGetDirectory", LocalizationPaths.Logging) + Environment.NewLine +
                                     LocalizationHelper.GetString("Error", LocalizationPaths.Logging) + ue.Message 
                                     + Environment.NewLine
                                     + LocalizationHelper.GetString("Location", LocalizationPaths.Logging) + LogFolder + Environment.NewLine + Environment.NewLine +

                                     LocalizationHelper.GetString("CheckFolderRights", LocalizationPaths.Logging), LocalizationHelper.GetString("Error", LocalizationPaths.General));
                    return false;
                }
                catch (PathTooLongException pe)
                {
                    ShowErrorMessage(LocalizationHelper.GetString("ErrGetDirectory", LocalizationPaths.Logging) + Environment.NewLine +
                                     LocalizationHelper.GetString("Error", LocalizationPaths.Logging) + pe.Message
                                     + Environment.NewLine
                                     + LocalizationHelper.GetString("Location", LocalizationPaths.Logging) + LogFolder + Environment.NewLine + Environment.NewLine +
                                     LocalizationHelper.GetString("ErrPathToLong", LocalizationPaths.Logging), LocalizationHelper.GetString("Error", LocalizationPaths.General));
                    return false;
                }
                catch (Exception ex)
                {
                    ShowErrorMessage(LocalizationHelper.GetString("ErrGetDirectory", LocalizationPaths.Logging) + Environment.NewLine +
                                     LocalizationHelper.GetString("Error", LocalizationPaths.Logging) + ex.Message
                                     + Environment.NewLine
                                     + LocalizationHelper.GetString("Location", LocalizationPaths.Logging) + LogFolder + Environment.NewLine + Environment.NewLine +
                                     LocalizationHelper.GetString("ErrUnknown", LocalizationPaths.Logging), LocalizationHelper.GetString("Error", LocalizationPaths.General));
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
                                     LocalizationHelper.GetString("Error", LocalizationPaths.Logging) + e.Message,
                                     LocalizationHelper.GetString("Error", LocalizationPaths.General));
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
                                         LocalizationHelper.GetString("Error", LocalizationPaths.Logging) + e.Message,
                                         LocalizationHelper.GetString("Error", LocalizationPaths.General));
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
                    ShowErrorMessage("Fout bij het starten van de logging" + Environment.NewLine + $"Fout: {ioex.Message}", LocalizationHelper.GetString("Error", LocalizationPaths.General));
                }
                catch (Exception ex)
                {
                    ShowErrorMessage("Onverwachte fout bij het starten van de logging" + Environment.NewLine + $"Fout: {ex.Message}", LocalizationHelper.GetString("Error", LocalizationPaths.General));
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
                    ShowErrorMessage("ArgumentException bij LogRegulier" + Environment.NewLine + $"Fout: {aex.Message}", LocalizationHelper.GetString("Error", LocalizationPaths.General));
                }
                catch (Exception ex)
                {
                    LoggingEfforts += 1;
                    StoppenLogging();
                    ShowErrorMessage("Onverwachte fout bij LogRegulier" + Environment.NewLine + $"Fout: {ex.Message}", LocalizationHelper.GetString("Error", LocalizationPaths.General));
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
                    ShowErrorMessage("Fout bij het stoppen van de logging" + Environment.NewLine + $"Fout: {ioex.Message}", LocalizationHelper.GetString("Error", LocalizationPaths.General));
                }
                catch (Exception ex)
                {
                    AbortLogging = true;
                    ShowErrorMessage("Onverwachte fout bij het stoppen van de logging" + Environment.NewLine + $"Fout: {ex.Message}", LocalizationHelper.GetString("Error", LocalizationPaths.General));
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

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Documate.Models.DirectoryModel;

namespace Documate.Models
{
    public interface IDirectoryModel
    {
        void CreateDirectory(DirectoryOption option, string dirName);
    }
}


using Microsoft.Win32.SafeHandles;
using System.Runtime.InteropServices;

namespace Documate.Models
{
    public class FormPosition : IDisposable
    {
        private readonly MainForm _mainForm;
        public FormPosition(MainForm mainForm)
        {
            _mainForm = mainForm ?? throw new ArgumentNullException(nameof(mainForm));
        }
        
        /// <summary>
        /// Restore the main form position parameters.
        /// </summary>
        public void RestoreWindowPosition()
        {
            // Check if there are valid saved settings.
            if (Properties.Settings.Default.MainFrmLocation != Point.Empty &&
                Properties.Settings.Default.MainFrmSize != Size.Empty)
            {
                var savedBounds = new Rectangle(
                    Properties.Settings.Default.MainFrmLocation,
                    Properties.Settings.Default.MainFrmSize
                );

                // Check if the saved position is on an existing monitor.
                if (Screen.AllScreens.Any(s => s.WorkingArea.IntersectsWith(savedBounds)))
                {
                    _mainForm.Location = Properties.Settings.Default.MainFrmLocation;
                    _mainForm.Size = Properties.Settings.Default.MainFrmSize;

                    // Restore window status (Maximized (2), Minimized (1), Normal (0))
                    if (Properties.Settings.Default.MainFrmWindowstate == 2)
                    {
                        _mainForm.WindowState = FormWindowState.Maximized;
                    }
                    else
                    {
                        _mainForm.WindowState = FormWindowState.Normal;
                    }
                }
                else
                {
                    // Default position if saved position is invalid
                    SetDefaultPosition();
                }
            }
            else
            {
                // Default position if no settings exist
                SetDefaultPosition();
            }
        }

        /// <summary>
        /// Store the main form position parameters.
        /// </summary>
        public void StoreWindowPosition()
        {
            // Save the window status and size only when the window is not maximized.
            if (_mainForm.WindowState == FormWindowState.Normal)
            {
                Properties.Settings.Default.MainFrmLocation = _mainForm.Location;
                Properties.Settings.Default.MainFrmSize = _mainForm.Size;
            }

            // Save window state (e.g. maximized).
            Properties.Settings.Default.MainFrmWindowstate = (int)_mainForm.WindowState;
            Properties.Settings.Default.Save();
        }

        /// <summary>
        /// Set the form to a default position.
        /// </summary>
        private void SetDefaultPosition()
        {
            _mainForm.StartPosition = FormStartPosition.CenterScreen;
        }

        /// <summary>
        /// Handle monitor configuration changes.
        /// </summary>
        public void SystemEvents_DisplaySettingsChanged(object sender, EventArgs e)
        {
            // Recheck the window position when the monitor configuration changes.
            RestoreWindowPosition();
        }


        #region Dispose

        // Flag: Has Dispose already been called?
        private bool _disposed;

        // Instantiate a SafeHandle instance.
        private SafeHandle _safeHandle = new SafeFileHandle(IntPtr.Zero, true);

        /// <summary>
        /// Public implementation of Dispose pattern.
        /// </summary>
        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Protected implementation of Dispose pattern.
        /// </summary>
        /// <param name="disposing">Has Dispose already been called.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    // Dispose managed resources
                    _safeHandle?.Dispose();
                }

                // Free unmanaged resources (if any) here

                _disposed = true;
            }
        }
        #endregion Dispose
    }
}

using Documate.Library;

namespace Documate.Models
{
    public class DirectoryModel: AppMessage, IDirectoryModel
    {

        public enum DirectoryOption
        {
            AppData,
            ApplicatieDir
        }

        public void CreateDirectory(DirectoryOption option, string dirName)
        {
            string appName = Properties.Settings.Default.ApplicationName;
            string basePath;

            switch (option)
            {
                case DirectoryOption.AppData:
                    basePath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
                    break;
                case DirectoryOption.ApplicatieDir:
                    basePath = Directory.GetCurrentDirectory();
                    appName = string.Empty;
                    break;
                default:
                    basePath = Directory.GetCurrentDirectory();
                    appName = string.Empty;
                    break;
            }

            DoCreateDirectory(basePath, appName, dirName);
        }

        private void DoCreateDirectory(string basePath, string appName, string dirName)
        {
            try
            {
                // Create the base directory.
                if (!Directory.Exists(basePath))
                {
                    Directory.CreateDirectory(basePath);

                    AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("DirectoryCreated", LocalizationPaths.DirectoryModel)} {basePath}"
                              );
                }

                // Add application directory if appName is provided.
                if (!string.IsNullOrEmpty(appName))
                {
                    basePath = Path.Combine(basePath, appName);

                    if (!Directory.Exists(basePath))
                    {
                        Directory.CreateDirectory(basePath);

                        AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("DirectoryCreated", LocalizationPaths.DirectoryModel)} {basePath}"
                              );
                    }
                }

                // Add sub-directory if dirName is provided.
                if (!string.IsNullOrEmpty(dirName))
                {
                    basePath = Path.Combine(basePath, dirName);
                    if (!Directory.Exists(basePath))
                    {
                        Directory.CreateDirectory(basePath);

                        AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("DirectoryCreated", LocalizationPaths.DirectoryModel)} {basePath}"
                              );
                    }
                }
            }
            catch (Exception ex)
            {
                AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("DirectoryCreateError", LocalizationPaths.DirectoryModel)} {basePath}"
                              );
                AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("ErrorDetails", LocalizationPaths.DirectoryModel)} {ex.Message}"
                              );
            }
        }
    }
}

