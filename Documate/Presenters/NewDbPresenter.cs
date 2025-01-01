using Documate.Library;
using Documate.Models;
using Documate.Resources.Models;
using Documate.Views;
using System.Data.SQLite;
using static Documate.Library.StatusStripHelper;

namespace Documate.Presenters
{
    public class NewDbPresenter : INewDbPresenter
    {
        private readonly INewDbView _view;
        private readonly LoggingModel _loggingModel;
        private readonly IAppDbCreateModel _appDbCreate;
        private readonly ICreateControls _createControls;

        public bool FileIsCreated
        {  get; private set; }
        
        public NewDbPresenter(
            INewDbView view,
            LoggingModel loggingModel,
            IAppDbCreateModel appDbCreateModel,
            ICreateControls createControls
            )
        {
            _view = view;
            _loggingModel = loggingModel;
            _appDbCreate = appDbCreateModel;
            _createControls = createControls;

            // Set eventhandlers.
            _view.DoFormShown += (s, e) => OnFormShown();
            _view.TbKeyPressed += this.DoTbKeyPress!;
            _view.TbTextColCountChanged += this.DoTbColCountTextChanged!;
            _view.TbTextShortDescriptionChanged += this.DoTbShortDescriptionTextChanged!;
            _view.BtSaveClicked += this.OnBtSaveClicked!;
            _view.BtCancelClicked += this.OnBtCancelClicked!;
        }

        public void OnFormShown()
        {
            // Update the UI strings.
            UpdateUIStrings();
        }

        private void UpdateUIStrings()
        {
            // Update UI text using resource strings
            _view.FormNewDbText = LocalizationHelper.GetString("FormNewDb", LocalizationPaths.NewDbForm);
            _view.LbFileNameText = LocalizationHelper.GetString("LbFileName", LocalizationPaths.NewDbForm);
            _view.LbColCountText = LocalizationHelper.GetString("LbColCount", LocalizationPaths.NewDbForm);
            _view.LbShortDescriptionText = LocalizationHelper.GetString("LbShortDescription", LocalizationPaths.NewDbForm);
            _view.BtSaveText = LocalizationHelper.GetString("BtSave", LocalizationPaths.NewDbForm);
            _view.BtCancelText = LocalizationHelper.GetString("BtCancel", LocalizationPaths.NewDbForm);
        }

        private void DoTbKeyPress(object sender, KeyPressEventArgs e)
        {
            if (!char.IsControl(e.KeyChar) && !char.IsDigit(e.KeyChar))
            {
                e.Handled = true;  // Block the input.
                _view.ShowWarning(LocalizationHelper.GetString("OnlyNumericalValues", LocalizationPaths.NewDbPresenter));
            }
            else
            {
                _view.ClearWarning();
            }
        }

        private void DoTbColCountTextChanged(object sender, EventArgs e)
        {
            if (sender is TextBox textBox)
            {
                if (!string.IsNullOrEmpty(textBox.Text) && int.Parse(textBox.Text) > 1 && int.Parse(textBox.Text) <= 20)
                {
                    _view.ClearWarning();
                    _view.ColCount = int.Parse(textBox.Text);
                    SetStatusbarStaticText(TsStatusLblName.tsOne, string.Empty);
                    _view.CanContinue = true;
                }
                else if (string.IsNullOrEmpty(textBox.Text))
                {
                    _view.ClearWarning();
                    SetStatusbarStaticText(TsStatusLblName.tsOne, string.Empty);
                    _view.CanContinue = false;
                }
                else
                {
                    _view.ShowWarning(LocalizationHelper.GetString("ColCountBetween2and21", LocalizationPaths.NewDbPresenter));
                    SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("ColCountBetween2and21", LocalizationPaths.NewDbPresenter));
                    _view.CanContinue = false;
                }
            }
            FileIsCreated = _view.CanContinue;
        }

        private void DoTbShortDescriptionTextChanged(object sender, EventArgs e)
        {
            if (sender is TextBox textBox)
            {
                if (textBox.Text.Length <= 255)
                {
                    _view.ClearWarning();
                    _view.ShortDescription = textBox.Text;
                    SetStatusbarStaticText(TsStatusLblName.tsOne, string.Empty);
                }
                else
                {
                    _view.ShowWarning(LocalizationHelper.GetString("MaxTextSize255", LocalizationPaths.NewDbPresenter));
                    SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("MaxTextSize255", LocalizationPaths.NewDbPresenter));
                }
            }
        }

        private void OnBtSaveClicked(object sender, EventArgs e)
        {
            if (_appDbCreate.CreateAppDbFile(_view.NewFileName))
            {
                Cursor.Current = Cursors.WaitCursor;
                DocumateUtils.FileLocationAndName = _view.NewFileName;  // Store the file name and location for later use.
                DocumateUtils.LevelCount = _view.ColCount;

                _createControls.RemoveComponents(_view.APanel);  // First Remove the components if needed.
                _appDbCreate.InsertMeta("Column count", _view.ColCount.ToString());

                // Prepare column header texts.
                for (int i = 0; i < _view.ColCount; i++)
                {
                    _appDbCreate.InsertMeta("COL_" + (i + 1).ToString(), string.Empty);
                }

                _loggingModel.WriteToLog(Common.LogAction.INFORMATION, string.Format(LocalizationHelper.GetString("FileIsCreated", LocalizationPaths.NewDbPresenter), _view.NewFileName));
                SetStatusbarStaticText(TsStatusLblName.tsOne, string.Format(LocalizationHelper.GetString("FileIsCreated", LocalizationPaths.NewDbPresenter), _view.NewFileName));

                _view.CanContinue = true;
                Cursor.Current = Cursors.Default;
            }
            else 
            {
                _view.CanContinue = false;
                DocumateUtils.FileLocationAndName = string.Empty;
            }

            _view.CloseView();
        }

        private void OnBtCancelClicked(object sender, EventArgs e)
        {
            DocumateUtils.FileLocationAndName = string.Empty;
            _view.CanContinue = false;
            FileIsCreated = false;
            _view.CloseView();
        }
    }
}
