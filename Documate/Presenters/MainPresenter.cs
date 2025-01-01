using Documate.Library;
using Documate.Models;
using Documate.Views;
using Microsoft.Extensions.DependencyInjection;
using System.Data;
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
        private readonly IAppDbMaintainItemsModel _appDbMaintainItemsModel;
        private readonly IDataGridViewModel _dataGridViewModel;

        public MainPresenter(
            IMainView view,
            IAppSettings appSettings,
            DirectoryModel directoryModel, 
            LoggingModel loggingModel, 
            IServiceProvider serviceProvider,
            FormPositionModel formPosition,
            ICreateControls createControls,
            IAppDbMaintainItemsModel appDbMaintainItemsModel,
            IDataGridViewModel dataGridViewModel
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

            _view.SaveItemDataClicked += this.OnSaveItemDataClicked;

            _view.DoFormShown += (s, e) => OnFormShown();
            _view.DoFormClosing += (s, e) => OnFormClosing();

            _view.RbReadCheckedChanged += OnRbReadCheckedChanged!;
            _view.RbModifyCheckedChanged += OnModifyCheckedChanged!;
            _view.RbSetRelationsCheckedChanged += OnRbSetRelationsCheckedChanged!;


            _appSettings = appSettings;
            _directoryModel = directoryModel;
            _loggingModel = loggingModel;
            _serviceProvider = serviceProvider; // Added for the configure form/view
            _formPosition = formPosition;
            _createControls = createControls;
            _appDbMaintainItemsModel = appDbMaintainItemsModel;

            _dataGridViewModel = dataGridViewModel;
            _dataGridViewModel.CellClickedEvent += OnCellClicked;  // Koppel het CellClickedEvent aan een handler in de presenter
            _dataGridViewModel.CanSaveChangedEvent += OnCanSaveChangedEvent;
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
            SetStatusbarStaticText(TsStatusLblName.tsThree, string.Empty);

            _view.CanSaveChanged(false);
            _view.RbReadChecked = true;

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
            _createControls.RemoveComponents(_view.APanel!);
            DocumateUtils.FileLocationAndName = string.Empty;
            DocumateUtils.LevelCount = -1;
            _view.CanSaveChanged(false);  // Disable save button.
            _view.RbReadChecked = true;   // Enable radiobutton RbRead.

            SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("FileIsClosed", LocalizationPaths.MainPresenter));
            SetStatusbarStaticText(TsStatusLblName.tsThree, string.Empty);
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
            _createControls.CreateComponents(FileName, _view.APanel!);
            RetrieveData();

            SetStatusbarStaticText(TsStatusLblName.tsThree, Path.GetFileName(FileName));  // TODO; moeten controle voor. 

            // hier moet de bestandsnaam naar de statustrip label

        }
        
        private void RetrieveData()
        {
            for (int i = 1; i <=DocumateUtils.LevelCount; i++)
            {
                foreach (DataGridView dgv in DataGridViewHelper.AllDgvs.Cast<DataGridView>())
                {
                    if (DocumateUtils.ExtractDigets(dgv.Name) == i)
                    {
                        var itemList = new List<DmItem>();

                        itemList = _appDbMaintainItemsModel.ReadLevel(i, dgv, true);  // TODO; make sorted optional.

                        // Hide the parent and child column.
                        dgv.Columns[0].Visible = false;  // Parent.
                        dgv.Columns[1].Visible = false;  // Child.
                        dgv.Columns[3].Visible = false;  // Item object.

                        // disable editing. Open file and show the data as readonly.
                        dgv.ReadOnly = true;
                    }
                }
            }
        }

        private void OnSaveItemDataClicked(object? sender, EventArgs e)
        {
            for (int i = 1; i <= DocumateUtils.LevelCount; i++)
            {
                foreach (DataGridView dgv in DataGridViewHelper.AllDgvs.Cast<DataGridView>())
                {
                    if (DocumateUtils.ExtractDigets(dgv.Name) == i)
                    {                        
                        _appDbMaintainItemsModel.RemoveEmptyRows(dgv);  // First remove empty rows. No need to save them.
                        _appDbMaintainItemsModel.SaveItems(i, dgv);     // Save changes.
                    }
                }
            }
        }

        private void OpenNewDbForm()
        {
            string CurrentFileName = DocumateUtils.FileLocationAndName;

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
                    SetStatusbarStaticText(TsStatusLblName.tsThree, string.Empty);
                    newDbView.NewFileName = NewFileName;
                    newDbView.SetPresenter(newDbPresenter);
                    newDbView.APanel = _view.APanel!;
                    newDbView.ShowDialog(); // Open ConfigureForm as dialog form.

                    if (newDbPresenter.FileIsCreated)
                    {
                        OpenDocumateFile(NewFileName);
                        SetStatusbarStaticText(TsStatusLblName.tsOne, LocalizationHelper.GetString("FileIsCreated", LocalizationPaths.MainPresenter));
                        SetStatusbarStaticText(TsStatusLblName.tsThree, Path.GetFileName(NewFileName));
                    }
                    else
                    {
                        SetStatusbarStaticText(TsStatusLblName.tsOne, string.Empty);
                        SetStatusbarStaticText(TsStatusLblName.tsThree, Path.GetFileName(CurrentFileName));
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

        private void OnCellClicked(string message)
        {
            _view.ShowItemDataInTextBox(message); // Roep de view aan om de data weer te geven
        }

        private void OnCanSaveChangedEvent(bool canSave)
        {
            _view.CanSaveChanged(canSave);
        }

        #region Radio buttons
        private void OnRbReadCheckedChanged(object sender, EventArgs e)
        {
            if (DocumateUtils.LevelCount > 0)
            {
                foreach (DataGridView dgv in DataGridViewHelper.AllDgvs.Cast<DataGridView>())
                {
                    dgv.AllowUserToAddRows = false;  // TODO moet pas na een enter/tab aan het eind.
                    dgv.AllowUserToDeleteRows = false;

                    dgv.ReadOnly = true;
                    dgv.Columns[0].Visible = false;
                    dgv.Columns[1].Visible = false;
                }
            }

            _dataGridViewModel.CanProcessKey = false;
            _view.CanSaveChanged(false); // TODO eerst controleren of er nog opgeslagen moet worden.
            //_view.ViewKeyPreview = false;
        }
        private void OnModifyCheckedChanged(object sender, EventArgs e)
        {
            if (DocumateUtils.LevelCount > 0)
            {
                foreach (DataGridView dgv in DataGridViewHelper.AllDgvs.Cast<DataGridView>())
                {
                    dgv.ReadOnly = false;
                    //dgv.AllowUserToAddRows = true;  // TODO moet pas na een enter/tab aan het eind.
                    dgv.AllowUserToDeleteRows = true;                    
                    dgv.Columns[0].Visible = false;
                    dgv.Columns[1].Visible = false;

                    if (dgv.DataSource is BindingSource bindingSource)
                    {
                        bindingSource.AllowNew = true;
                    }
                }
            }

            _dataGridViewModel.CanProcessKey = true;
            _view.CanSaveChanged(false);  // TODO eerst controleren of er nog opgeslagen moet worden.
            //_view.ViewKeyPreview = true;  // Nodig voor de TAB af te vangen in de datagridview en het standaard gedrag te overrulen.
        }
        private void OnRbSetRelationsCheckedChanged(object sender, EventArgs e)
        {
            if (DocumateUtils.LevelCount > 0)
            {
                foreach (DataGridView dgv in DataGridViewHelper.AllDgvs.Cast<DataGridView>())
                {
                    dgv.ReadOnly = false;
                    dgv.Columns[0].Visible = true;
                    dgv.Columns[1].Visible = true;
                }
            }

            _dataGridViewModel.CanProcessKey = false;
            _view.CanSaveChanged(false); // TODO eerst controleren of er nog opgeslagen moet worden.
            //_view.ViewKeyPreview = false;
        }
        #endregion Radio buttons


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
            _view.RbReadText = LocalizationHelper.GetString("RbRead", LocalizationPaths.MainForm);
            _view.RbModifyText = LocalizationHelper.GetString("RbModify", LocalizationPaths.MainForm);
            _view.RbSetRelationsText = LocalizationHelper.GetString("RbSetRelations", LocalizationPaths.MainForm);

            // Add updates for other UI components here as needed
        }
        #endregion Helper Methods
    }
}
