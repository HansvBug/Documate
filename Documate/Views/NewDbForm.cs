using Documate.Library;
using Documate.Presenters;

namespace Documate.Views
{
    public partial class NewDbForm : Form, INewDbView
    {
        private NewDbPresenter? _presenter;
        private string _newDbFile = string.Empty;
        private int _colCount;
        private string _shortDescription = string.Empty;
        private bool _CanContinue;
        private TabPage _tabPage;

        #region Properties Set Texts

        public string FormNewDbText
        {
            set => this.Text = value;
        }
        public string LbFileNameText
        {
            set => LbFileName.Text = value;
        }
        public string LbColCountText
        {
            set => LbColCount.Text = value;
        }
        public string LbShortDescriptionText
        {
            set => LbShortDescription.Text = value;
        }
        public string BtSaveText
        {
            set => BtSave.Text = value;
        }
        public string BtCancelText
        {
            set => BtCancel.Text = value;
        }
        #endregion Properties Set Texts
        #region Properties
        public string NewFileName
        {
            get => _newDbFile;
            set => _newDbFile = value;
        }
        public int ColCount
        {
            get => _colCount;
            set => _colCount = value;
        }
        public string ShortDescription
        {
            get => _shortDescription;
            set => _shortDescription = value;
        }

        public bool CanContinue
        {
            get => _CanContinue;
            set
            {
                _CanContinue = value;
                BtSave.Enabled = value;
            }
        }
        public TabPage ATabPage
        {
            get => _tabPage;
            set => _tabPage = value;
        }
        #endregion Properties

        #region Eventhandlers
        public event EventHandler? DoFormShown;
        public event KeyPressEventHandler? TbKeyPressed;
        public event EventHandler? TbTextColCountChanged;
        public event EventHandler? TbTextShortDescriptionChanged;
        public event EventHandler? BtSaveClicked;
        public event EventHandler? BtCancelClicked;
        #endregion Eventhandlers

        public NewDbForm()
        {
            InitializeComponent();
            TextBoxFileName.Text = string.Empty;
            TextBoxColCount.Text = string.Empty;
            TextBoxShortDescription.Text = string.Empty;
            LbWarning.Text = string.Empty;
            BtSave.Enabled = CanContinue;
            BackColor = SystemColors.Window;
        }
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e); // First: calls Form's native OnLoad method.

            this.Shown += NewDbForm_Shown!;
            _presenter?.OnFormShown();

            TextBoxColCount.KeyPress += (sender, args) => TbKeyPressed?.Invoke(sender, args);
            TextBoxColCount.TextChanged += (sender, args) => TbTextColCountChanged?.Invoke(sender, args);
            TextBoxShortDescription.TextChanged += (sender, args) => TbTextShortDescriptionChanged?.Invoke(sender, args);
            BtSave.Click += (sender, args) => BtSaveClicked?.Invoke(this, EventArgs.Empty);
            BtCancel.Click += (sender, args) => BtCancelClicked?.Invoke(this, EventArgs.Empty);

            this.TextBoxFileName.Text = Path.GetFileName(_newDbFile);
            TextBoxColCount.Text = string.Empty;            
            TextBoxColCount.Focus();  //Set focus to TextBoxColCount.
            TextBoxColCount.Select(); //Set focus to TextBoxColCount.
        }

        
        public void SetPresenter(NewDbPresenter presenter)
        {
            _presenter = presenter;
        }

        public void ShowWarning(string message)
        {
            LbWarning.Text = LocalizationHelper.GetString("Warning", LocalizationPaths.General) + ": " + message;            
        }

        public void ClearWarning()
        {
            LbWarning.Text = string.Empty;
        }

        public void CloseView()
        {

            this.Close();
        }

        private void NewDbForm_Shown(object sender, EventArgs e)
        {
            DoFormShown?.Invoke(this, EventArgs.Empty);
        }
    }
}
