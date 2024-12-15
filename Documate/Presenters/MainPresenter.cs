using Documate.Library;
using Documate.Models;
using Documate.Resources.Models;
using Documate.Views;
using Microsoft.Extensions.DependencyInjection;
using System.Data.Entity.Hierarchy;
using System.Windows.Forms;
using static Documate.Library.Common;
using static Documate.Library.StatusStripHelper;  // Allows you to call SetStatusbarStaticText directly.

namespace Documate.Presenters
{
    public class MainPresenter : IMainPresenter
    {
        private readonly IMainView _view;
        private readonly DirectoryModel _directoryModel;
        private readonly LoggingModel _loggingModel;
        private readonly FormPositionModel _formPosition;
        private readonly IServiceProvider _serviceProvider;
        private readonly IAppSettings _appSettings;
        private readonly ICreateControls _createControls;

        public MainPresenter(
            IMainView view,
            IAppSettings appSettings,
            DirectoryModel directoryModel, 
            LoggingModel loggingModel, 
            IServiceProvider serviceProvider,
            FormPositionModel formPosition,
            ICreateControls createControls
            )
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

            _appSettings = appSettings;
            _directoryModel = directoryModel;
            _loggingModel = loggingModel;
            _serviceProvider = serviceProvider; // Added for the configure form/view
            _formPosition = formPosition;
            _createControls = createControls;
        }

        public void Run()
        {
            Application.Run((Form)_view);  // Start/Show the MainForm.            
        }

        public void OnFormShown()
        {
            // Get the current language setting from Properties.Settings.
            string language = _appSettings.Language ?? "en-EN";

            _view.MenuItemNLChecked = language == "nl-NL";
            _view.MenuItemENChecked = language == "en-EN";

            // Update the UI strings.
            UpdateUIStrings();

            SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("Welcome", LocalizationPaths.General));
            SetStatusbarStaticText(TsStatusLblName.tsTwo, LocalizationHelper.GetString("MVPAtWork", LocalizationPaths.General));
        }
        public void OnFormClosing()
        {            
            StopLogging();
        }

        public void CreateDirectory(DirectoryModel.DirectoryOption directoryOption, string FolderName)
        {
            _directoryModel.CreateDirectory(directoryOption, FolderName);

            if (_directoryModel.Messages.Count > 0)
            {
                foreach (var message in _directoryModel.Messages)
                {
                    _loggingModel.WriteToLog((LogAction)message.MsgType, message.MsgText);
                }
            }
        }

        #region Logging
        public void StartLogging()
        {
            if (!DocumateUtils.LoggingIsStarded)
            {
                _loggingModel.StartLogging();
                DocumateUtils.LoggingIsStarded = true;
            }
        }

        public void StopLogging()
        {
            _loggingModel.StopLogging();
            DocumateUtils.LoggingIsStarded = false;
        }
        #endregion Logging

        public void LoadFormPosition()
        {
             _formPosition.SystemEvents_DisplaySettingsChanged((MainForm)_view, "MainFrm");
        }

        public void SaveFormPosition()
        {
            _formPosition.StoreWindowPosition((MainForm)_view, "MainFrm");
        }

        public void OpenConfigureForm()
        {
            var configurePresenter = _serviceProvider.GetService<ConfigurePresenter>();

            if (_serviceProvider.GetService<IConfigureView>() is ConfigureForm configureView && configurePresenter != null)
            {
                configureView.SetPresenter(configurePresenter);
                configureView.ShowDialog(); // Open ConfigureForm as dialog form.
            }

            if (_appSettings.ActivateLogging)
            {
                StartLogging(); 
            }
            else
            {
                StopLogging();
            }
        }

        #region View Menu Items
        private void OnMenuItemOpenFileClicked(object? sender, EventArgs e)
        {
            SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("OpenDocumateFile", LocalizationPaths.MainPresenter));
            OpenFileDialog openFileDialog = new()
            {
                InitialDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, _appSettings.DatabaseDirectory),
                RestoreDirectory = true,
                Title = LocalizationHelper.GetString("OpenFile", LocalizationPaths.MainPresenter),
                DefaultExt = "db",
                Filter = "Documate files (*.db)|*.db",
                CheckPathExists = true,
                CheckFileExists = true,
            };

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                //_view.OpenFile();  // TODO; remove method, does nothing.
                OpenDocumateFile(openFileDialog.FileName);
            }
            else
            {
                SetStatusbarStaticText(TsStatusLblName.tsOne, string.Empty);
            }
            //_view.OpenFile();
        }
        private void OnMenuItemNewFileClicked(object? sender, EventArgs e)
        {
            //_view.NewFile();
            OpenNewDbForm();
        }
        private void OnMenuItemCloseFileClicked(object? sender, EventArgs e)
        {
            _createControls.RemoveComponents(_view.ATabPage);
            DocumateUtils.FileLocationAndName = string.Empty;
            DocumateUtils.ColCount = -1;

            SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("FileIsClosed", LocalizationPaths.MainPresenter));
            //_view.CloseFile();
        }
        private void OnMenuItemExitClicked(object? sender, EventArgs e)
        {
            _view.CloseView();
        }
        private void OnMenuItemOptionsOptionsClicked(object? sender, EventArgs e)
        {
            this.OpenConfigureForm();
        }
        #endregion View Menu Items

        private void OpenDocumateFile(string FileName)
        {
            DocumateUtils.FileLocationAndName = FileName;
            _createControls.CreateComponents(FileName, _view.ATabPage);
            //laden van de data. Moet een nieuwe klasse worden ==> AppDbMaintainItemsModel
        }
        private void OpenNewDbForm()
        {
            SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("SelectFileLocation", LocalizationPaths.MainPresenter));

            // Open file dialog.
            SaveFileDialog saveFileDialog = new()
            {
                Title = LocalizationHelper.GetString("Save", LocalizationPaths.MainPresenter),
                DefaultExt = "db",
                Filter = "Documate files (*.db)|*.db",
                InitialDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, _appSettings.DatabaseDirectory),
                CheckPathExists = true,
                OverwritePrompt = true,
                CreatePrompt = false,
            };

            string NewFileName = string.Empty;
            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                NewFileName = saveFileDialog.FileName;
            }

            // new form...
            if (!string.IsNullOrEmpty(NewFileName))
            {
                SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("CreateNewDbFile", LocalizationPaths.MainPresenter));

                var newDbPresenter = _serviceProvider.GetService<NewDbPresenter>();

                if (_serviceProvider.GetService<INewDbView>() is NewDbForm newDbView && newDbPresenter != null)
                {
                    newDbView.NewFileName = NewFileName;
                    newDbView.SetPresenter(newDbPresenter);
                    newDbView.ATabPage = _view.ATabPage;
                    newDbView.ShowDialog(); // Open ConfigureForm as dialog form.

                    if (newDbPresenter.FileIsCreated)
                    {
                        OpenDocumateFile(NewFileName);
                        SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("FileIsCreated", LocalizationPaths.MainPresenter));
                    }
                    else
                    {
                        SetStatusbarStaticText(TsStatusLblName.tsOne, string.Empty);
                    }
                }
            }
        }

        private void OnMenuItemLanguageNLClicked(object? sender, EventArgs e)
        {
            LocalizationHelper.SetCulture("nl-NL");
            UpdateUIStrings();

            _view.MenuItemNLChecked = true;
            _view.MenuItemENChecked = false;

            _loggingModel.WriteToLog(LogAction.INFORMATION, $"{LocalizationHelper.GetString("NLIsActivated", LocalizationPaths.MainPresenter)}");
        }

        private void OnMenuItemLanguageENClicked(object? sender, EventArgs e)
        {
            LocalizationHelper.SetCulture("en-EN");
            UpdateUIStrings();

            _view.MenuItemENChecked = true;
            _view.MenuItemNLChecked = false;

            _loggingModel.WriteToLog(LogAction.INFORMATION, $"{LocalizationHelper.GetString("ENIsActivated", LocalizationPaths.MainPresenter)}");
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
    }
}
