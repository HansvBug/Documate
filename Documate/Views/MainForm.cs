using Documate.Presenters;
using Documate.Views;
using static Documate.Models.LocalizationManagerModel;

namespace Documate
{
    public partial class MainForm : Form, IMainView
    {
        private MainPresenter? _presenter;
        public MainForm()
        {
            InitializeComponent();
        }

        public event EventHandler? MenuItemOpenFileClicked;
        public event EventHandler? MenuItemCloseFileClicked;
        public event EventHandler? MenuItemNewFileClicked;
        public event EventHandler? MenuItemExitClicked;
        public event EventHandler? MenuItemLanguageNLClicked;
        public event EventHandler? MenuItemLanguageENClicked;
        public event EventHandler? LoadRequested;
        public event EventHandler? FormShown;

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

            LoadRequested?.Invoke(this, EventArgs.Empty);  // Trigger/Raise the LoadRequested event.
            this.Shown += MainForm_Shown!;  // Bind the Shown event to the internal handler; suppress the warning by using the null-forgiving operator "!"
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

        public void SetLanguage(string language)
        {
            if (language == "NL")
            {
                MenuItemLanguageEN.Checked = false;
                MenuItemLanguageNL.Checked = true;
            }
            else
            {
                MenuItemLanguageEN.Checked = true;
                MenuItemLanguageNL.Checked = false;
            }

            try
            {
                Properties.Settings.Default["Language"] = language;
                Properties.Settings.Default.Save();

                _ = _presenter?.LoadIniFileAsync(); // _ = disgard await. Set the Texts new language according to the loaded ini file.
            }
            catch (Exception ex)
            {
                ShowMessage($"Fout bij het laden van het INI-bestand: {ex.Message}", MessageType.Error, MessageBoxIcon.Error);
            }

        }
        #endregion Menu Items

        #region Update view (language)
        public void ShowMessage(string message, MessageType messageType, MessageBoxIcon mbIcon)
        {
            MessageBox.Show(message, _presenter?.GetStaticText("MessageTitle", messageType.ToString()), MessageBoxButtons.OK, mbIcon);
        }
        public void UpdateMenuItem(string menuItemName, string menuItemText)
        {
            var menuItem = FindMenuItem(menuItemName);
            if (menuItem != null)
            {
                menuItem.Text = menuItemText;
            }
            else
            {
                ShowMessage($"Menu-item '{menuItemName}' niet gevonden.", MessageType.Error, MessageBoxIcon.Error);  // TODO: string in het taalbestand opnemen.
            }
        }
        private ToolStripMenuItem? FindMenuItem(string menuItemName)
        {
            foreach (var control in this.Controls.OfType<MenuStrip>())
            {
                var menuItem = FindMenuItem(control.Items, menuItemName);
                if (menuItem != null)
                {
                    return menuItem;
                }
            }

            return null;
        }
        private static ToolStripMenuItem? FindMenuItem(ToolStripItemCollection items, string name)
        {
            foreach (ToolStripItem item in items)
            {
                if (item is ToolStripMenuItem menuItem)
                {
                    if (menuItem.Name == name)
                    {
                        return menuItem;
                    }

                    var foundItem = FindMenuItem(menuItem.DropDownItems, name);
                    if (foundItem != null)
                    {
                        return foundItem;
                    }
                }
            }

            return null;
        }

        public void UpdateTabControlPage(string pageName, string pageText)
        {
            var tabPage = FindTabPage(pageName);
            if (tabPage != null)
            {
                tabPage.Text = pageText;
            }
        }
        private TabPage? FindTabPage(string tabpageName)
        {
            foreach (var control in this.Controls.OfType<TabControl>())
            {
                var tabPage = FindTabPage(control, tabpageName);
                if (tabPage != null)
                {
                    return tabPage;
                }
            }

            return null;
        }
        private static TabPage? FindTabPage(TabControl tabControl, string name)
        {
            foreach (TabPage tabPage in tabControl.TabPages)
            {
                if (tabPage.Name == name)
                {
                    return tabPage;
                }
            }

            return null;
        }

        public void UpdateStatusbarText(string statusbarToolstripName, string toolstripNameText)
        {
            var statusLabel = FindStatusLabel(statusbarToolstripName);
            if (statusLabel != null)
            {
                statusLabel.Text = toolstripNameText;
            }
            else
            {
                ShowMessage($"Statuslabel '{statusbarToolstripName}' niet gevonden.", MessageType.Error, MessageBoxIcon.Error);
            }
        }

        private ToolStripStatusLabel? FindStatusLabel(string statusLabelName)
        {
            foreach (var control in this.Controls.OfType<StatusStrip>())
            {
                var statusLabel = FindStatusLabel(control.Items, statusLabelName);
                if (statusLabel != null)
                {
                    return statusLabel;
                }
            }

            return null;
        }

        private static ToolStripStatusLabel? FindStatusLabel(ToolStripItemCollection items, string name)
        {
            foreach (ToolStripItem item in items)
            {
                if (item is ToolStripStatusLabel statusLabel)
                {
                    if (statusLabel.Name == name)
                    {
                        return statusLabel;
                    }
                }
            }

            return null;
        }
        #endregion Update view (language)

        public void UpdateFormText(string text)
        {
            this.Text = text;
        }

        private void MainForm_Shown(object sender, EventArgs e)
        {
            FormShown?.Invoke(this, EventArgs.Empty);
        }
    }
}
