using Documate.Library;
using Documate.Presenters;
using Documate.Views;
using System.DirectoryServices.ActiveDirectory;
using System.Windows.Forms;
using static Documate.Library.Common;

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

        public event EventHandler? RbReadCheckedChanged;
        public event EventHandler? RbModifyCheckedChanged;
        public event EventHandler? RbSetRelationsCheckedChanged;

        public event EventHandler? SaveItemDataClicked;

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
            set => TabPageEditItems.Text = value;
        }

        public string ToolStripStatusLabel1Text
        {
            set
            {
                ToolStripStatusLabel1.Text = value;
                StatusStrip1.Refresh();
            }
        }

        public string ToolStripStatusLabel2Text
        {
            set
            {
                ToolStripStatusLabel2.Text = value;
                StatusStrip1.Refresh();
            }
        }

        public string ToolStripStatusLabel3Text
        {
            set
            {
                ToolStripStatusLabel3.Text = value;
                StatusStrip1.Refresh();
            }
        }

        public string RbReadText
        {
            set => RbRead.Text = value;
        }
        public  string RbModifyText
        {
            set => RbModify.Text = value;
        }
        public string RbSetRelationsText
        {
            set => RbSetRelations.Text = value;
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
        public Panel? APanel { get; set; }  // Holds the panel on which the splitcontainer is placed.

        public RadioButtonOption SelectedRadioButton
        {
            get
            {
                if (RbRead.Checked) return RadioButtonOption.RbRead;
                if (RbModify.Checked) return RadioButtonOption.RbModify;
                if (RbSetRelations.Checked) return RadioButtonOption.RbSetRelations;
                throw new InvalidOperationException(LocalizationHelper.GetString("NoOptionSelected", LocalizationPaths.MainForm));
            }
        }

        public bool ButtonSaveEnabled
        {
            set => ButtonSave.Enabled = value;
        }

        public bool RbReadChecked
        {
            set => RbRead.Checked = value;
        }

        public bool ViewKeyPreview
        {
            set => this.KeyPreview = value;  // TODO: wordt niet gebruikt.
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
            MenuItemOptionsOptions.Click += (sender, args) => MenuItemOptionsOptionsClicked?.Invoke(this, EventArgs.Empty);

            ButtonSave.Click += (sender, args) => SaveItemDataClicked?.Invoke(this, EventArgs.Empty);  // Save Item data.

            this.Shown += MainForm_Shown!;  // Bind the Shown event to the internal handler; suppress the warning by using the null-forgiving operator "!"

            this.FormClosing += MainForm_FormClosing!;
            RbRead.CheckedChanged += (s, e) => RbReadCheckedChanged?.Invoke(this, EventArgs.Empty);
            RbModify.CheckedChanged += (s, e) => RbModifyCheckedChanged?.Invoke(this, EventArgs.Empty);
            RbSetRelations.CheckedChanged += (s, e) => RbSetRelationsCheckedChanged?.Invoke(this, EventArgs.Empty);

            //
            this.BackColor = SystemColors.Window;
            _presenter?.StartLogging();
            _presenter?.CreateDirectory(Models.DirectoryModel.DirectoryOption.ApplicatieDir, _appSettings.DatabaseDirectory);
            _presenter?.CreateDirectory(Models.DirectoryModel.DirectoryOption.ApplicatieDir, _appSettings.DatabaseDirectory + "\\" + _appSettings.BackUpFolder);

            LoadFormPosition();
            APanel = this.PanelMain;
        }


        #region Menu items
        public void OpenFile()
        {
            MessageBox.Show("Open");  // TODO; functie kan volledig weg (denk aan de eventhandlers
        }
        public void CloseFile()
        {
            //MessageBox.Show("Close");// TODO; functie kan volledig weg (denk aan de eventhandlers
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

        private void ButtonSave_Click(object sender, EventArgs e)
        {
            /*foreach (Control c in this.TabPageEditItems.Controls)
            {
                if (c.GetType() == typeof(SplitContainer))
                {
                    SplitContainer spc = (SplitContainer)c;

                    foreach (Control splitpan in spc.Controls)
                    {
                        if (splitpan.GetType() == typeof(SplitterPanel))
                        {
                            SplitterPanel asplitpanel = (SplitterPanel)splitpan;

                            foreach (Control pnl in asplitpanel.Controls)
                            {
                                if (pnl.GetType() == typeof(Panel))
                                {
                                    Panel panelbody = (Panel)pnl;
                                    if (panelbody.Name.Contains("PanelBody"))
                                    {
                                        foreach (Control pnlMid in panelbody.Controls)
                                        {
                                            if (pnlMid.GetType() == typeof(Panel))
                                            {
                                                Panel panMid = (Panel)pnlMid;
                                                foreach (Control dgv in panMid.Controls)
                                                {
                                                    if (dgv.GetType() == typeof(DataGridView))
                                                    {
                                                        DataGridView adgv = (DataGridView)dgv;
                                                        int i = adgv.RowCount;
                                                        string tmp = "";
                                                        // WERKT
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                }
            }*/
        }

        public void ShowItemDataInTextBox(string data)
        {
            // Toon de data in een TextBox (bijvoorbeeld TextBox1)
            TextBoxCtrlObject.Text = data;
        }

        public void CanSaveChanged(bool canSave)
        {
           this.ButtonSaveEnabled = canSave;
        }
    }
}
