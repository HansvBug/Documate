using Documate.Presenters;
using Documate.Views;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Documate
{
    public partial class ConfigureForm : Form, IConfigureView
    {
        private ConfigurePresenter? _presenter;

        #region Properties
        public string FormConfigureText
        {
            set => this.Text = value;
        }
        public string ChkActivateLoggingText
        {
            set => ChkActivateLogging.Text = value;
        }
        public string ChkAppendLogFileText
        {
            set => ChkAppendLogFile.Text = value;
        }
        public string TabPageVariousText
        {
            set => TabPageVarious.Text = value;
        }
        public string TabPageDatabaseText
        {
            set => TabPageDatabase.Text = value;
        }
        public string BtnCloseText
        {
            set => BtnClose.Text = value;
        }
        #endregion Properties

        public event EventHandler? DoFormShown;
        public event EventHandler? BtnClosedClicked;
        public event FormClosingEventHandler? DoFormClosing;

        public ConfigureForm()
        {
            InitializeComponent();
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e); // First: calls Form's native OnLoad method.

            this.Shown += ConfigureForm_Shown!;
            _presenter?.OnFormShown();

            BtnClose.Click += (sender, args) => BtnClosedClicked?.Invoke(this, EventArgs.Empty);
            this.FormClosing += ConfigureForm_FormClosing!;

            this.BackColor = SystemColors.Window;
            LoadFormPosition();
        }
        private void ConfigureForm_Shown(object sender, EventArgs e)
        {
            DoFormShown?.Invoke(this, EventArgs.Empty);
        }
        // Connect the presenter after the form has been created.
        public void SetPresenter(ConfigurePresenter presenter)
        {
            _presenter = presenter;
        }

        public void CloseView()
        {
            this.Close();
        }

        private void LoadFormPosition()
        {
            _presenter?.LoadFormPosition(this);
        }

        private void ConfigureForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            _presenter?.SaveFormPosition(this);
            DoFormClosing?.Invoke(this, e);
        }
    }
}
