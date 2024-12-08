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
        private readonly IAppSettings _appSettings;
        public MainForm(IAppSettings appSettings)
        {
            InitializeComponent();
            _appSettings = appSettings;
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
            _presenter?.CreateDirectory(Models.DirectoryModel.DirectoryOption.ApplicatieDir, _appSettings.DatabaseDirectory);

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

        #endregion Menu Items

        private void MainForm_Shown(object sender, EventArgs e)
        {
            DoFormShown?.Invoke(this, EventArgs.Empty);
        }

        private void MainForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            _presenter?.SaveFormPosition();
            DoFormClosing?.Invoke(this, e);
        }

        private void LoadFormPosition()
        {
            _presenter?.LoadFormPosition();
        }
    }
}
