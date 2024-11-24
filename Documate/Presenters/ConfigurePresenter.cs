using Documate.Library;
using Documate.Models;
using Documate.Resources.Views;
using Documate.Views;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static Documate.Library.Common;

namespace Documate.Presenters
{
    public class ConfigurePresenter : IConfigurePresenter
    {
        private readonly IConfigureView _view;
        private readonly LoggingModel _loggingModel;

        public ConfigurePresenter(IConfigureView view, LoggingModel loggingModel)
        {
            _view = view;
            _loggingModel = loggingModel;

            // set eventhandlers

            _view.DoFormShown += (s, e) => OnFormShown();
            _view.BtnClosedClicked += this.OnBtnClosedClicked;
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

        private void OnBtnClosedClicked(object? sender, EventArgs e)
        {
            _view.CloseView();
        }

        public void LoadFormPosition(ConfigureForm configureForm)
        {
            using FormPosition frmPos = new(configureForm);
            Microsoft.Win32.SystemEvents.DisplaySettingsChanged += frmPos.SystemEvents_ConfigureFrm_DisplaySettingsChanged!;
            frmPos.RestoreConfigureFrmWindowPosition();
        }

        public void SaveFormPosition(ConfigureForm configureForm)
        {
            using FormPosition frmPos = new(configureForm);
            frmPos.StoreConfigureFrmWindowPosition();
        }
    }
}
