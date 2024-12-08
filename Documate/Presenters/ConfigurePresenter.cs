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
        private readonly FormPositionModel _formPosition;
        private readonly IAppSettings _appSettings;

        public ConfigurePresenter(
            IConfigureView view,
            LoggingModel loggingModel,
            FormPositionModel formPosition,
            IAppSettings appSettings
            )
        {
            _view = view;
            _loggingModel = loggingModel;
            _formPosition = formPosition;
            _appSettings = appSettings;

            // Set eventhandlers.
            _view.DoFormShown += (s, e) => OnFormShown();
            _view.BtnClosedClicked += this.OnBtnClosedClicked;
            _view.ChkActivateLogging_CheckedChanged += OnChkActivateLoggingCheckedChanged;
            _view.ChkAppendLogFile_CheckedChanged += OnChkAppendLogFileCheckedChanged;
            _view.BtnCompressClicked += this.OnBtnCompressClicked;
        }

        public void OnFormShown()
        {
            // Update the UI strings.
            UpdateUIStrings();            
        }

        public void LoadSettings()
        {
            _view.ActivateLoggingChecked = _appSettings.ActivateLogging;
            _view.AppendLogFileChecked = _appSettings.AppendLogFile;
        }

        public void LoadFormPosition()
        {
            _formPosition.SystemEvents_DisplaySettingsChanged((ConfigureForm)_view, "ConfigureFrm");
        }
        public void SaveFormPosition()
        {
            _formPosition.StoreWindowPosition((ConfigureForm)_view, "ConfigureFrm");
        }

        private void UpdateUIStrings()
        {
            // Update UI text using resource strings
            _view.FormConfigureText = LocalizationHelper.GetString("FormConfigure", LocalizationPaths.ConfigureForm);
            _view.GroupBoxLoggingText = LocalizationHelper.GetString("GroupBoxLogging", LocalizationPaths.ConfigureForm);
            _view.ChkActivateLoggingText = LocalizationHelper.GetString("ChkActivateLogging", LocalizationPaths.ConfigureForm);
            _view.ChkAppendLogFileText = LocalizationHelper.GetString("ChkAppendLogFile", LocalizationPaths.ConfigureForm);
            _view.TabPageVariousText = LocalizationHelper.GetString("TabPageVarious", LocalizationPaths.ConfigureForm);
            _view.TabPageDatabaseText = LocalizationHelper.GetString("TabPageDatabase", LocalizationPaths.ConfigureForm);
            _view.BtnCloseText = LocalizationHelper.GetString("BtnClose", LocalizationPaths.ConfigureForm);
            _view.BtnCompressDbText = LocalizationHelper.GetString("BtnCompressDb", LocalizationPaths.ConfigureForm);
        }
        private void OnBtnClosedClicked(object? sender, EventArgs e)
        {
            _view.CloseView();
        }
        private void OnBtnCompressClicked(object? sender, EventArgs e)
        {

        }

        private void OnChkActivateLoggingCheckedChanged(object? sender, EventArgs e)
        {
            if (_view.ActivateLoggingChecked)
            {
                _view.AppendLogFileEnabled = true;
                _appSettings.ActivateLogging = true;
            }
            else
            {
                _view.AppendLogFileChecked = false;
                _view.AppendLogFileEnabled = false;
                _appSettings.ActivateLogging = false;
                _appSettings.AppendLogFile = false;
            }
        }

        private void OnChkAppendLogFileCheckedChanged(object? sender, EventArgs e)
        {
            _appSettings.AppendLogFile = _view.AppendLogFileChecked;
        }
    }
}
