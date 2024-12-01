using Documate.Library;
using Documate.Models;
using Documate.Properties;
using Documate.Resources.Views;
using Documate.Views;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Diagnostics;
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
        private readonly IAppSettings _appSettings;

        public MainPresenter(
            IMainView view,
            IAppSettings appSettings,
            DirectoryModel directoryModel, 
            LoggingModel loggingModel, 
            IServiceProvider serviceProvider,
            FormPosition formPosition
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
        }

       /* public MainPresenter(FormPosition formposition)
        {
            _formPosition = formposition;         
        }*/

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
