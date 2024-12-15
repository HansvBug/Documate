using Documate.Library;
using Documate.Models;
using Documate.Views;
using static Documate.Models.AppDbMaintainModel;
using static Documate.Library.StatusStripHelper;
using Documate.Resources.Models;
using Documate.Resources.Logging;
using Microsoft.VisualBasic;

namespace Documate.Presenters
{
    public class ConfigurePresenter : IConfigurePresenter
    {
        private readonly IConfigureView _view;
        private readonly LoggingModel _loggingModel;
        private readonly FormPositionModel _formPosition;
        private readonly IAppSettings _appSettings;
        private readonly IAppDbMaintainModel _appDbMaintainModel;

        public ConfigurePresenter(
            IConfigureView view,
            LoggingModel loggingModel,
            FormPositionModel formPosition,
            IAppSettings appSettings,
            IAppDbMaintainModel appDbMaintainModel
            )
        {
            _view = view;
            _loggingModel = loggingModel;
            _formPosition = formPosition;
            _appSettings = appSettings;
            _appDbMaintainModel = appDbMaintainModel;

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
            Cursor.Current = Cursors.WaitCursor;

            SetStatusbarStaticText(TsStatusLblName.tsOne, $"{LocalizationHelper.GetString("FileBeingCompressed", LocalizationPaths.ConfigurePresenter)}, {DocumateUtils.FileName}");

            // Copy the database file before compress takes place.
            if (_appDbMaintainModel.CopyDatabaseFile(DocumateUtils.FileLocationAndName, CopyType.OTHER))
            {
                _appDbMaintainModel.CompressDatabase();
                _appDbMaintainModel.ResetAllAutoIncrementFields();

                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, $"{ LocalizationHelper.GetString("FileSuccessfullyCompressed", LocalizationPaths.ConfigurePresenter)}, {DocumateUtils.FileName}");

                MessageBox.Show(
                    LocalizationHelper.GetString("AppDatabaseCompressed", LocalizationPaths.ConfigurePresenter),
                    LocalizationHelper.GetString("Information", LocalizationPaths.General), 
                    MessageBoxButtons.OK, MessageBoxIcon.Information); 
            }
            else  // Do not overwrite
            {
                MessageBox.Show(
                    LocalizationHelper.GetString("CompressAppDbIsAborted", LocalizationPaths.ConfigurePresenter),
                    LocalizationHelper.GetString("Information", LocalizationPaths.General),
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
            }

            Cursor.Current = Cursors.Default;
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
