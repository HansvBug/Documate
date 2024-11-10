using Documate.Models;
using Documate.Properties;
using Documate.Views;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Documate.Models.LocalizationManagerModel;
using static System.Windows.Forms.LinkLabel;

namespace Documate.Presenters
{
    public class MainPresenter : IMainPresenter
    {
        private readonly IMainView _view;
        private readonly LocalizationManagerModel _localizationManagerModel;

        public MainPresenter(IMainView view, LocalizationManagerModel localizationManager)
        {
            _view = view;

            // Link the view's event handlers to the methods in the presenter.
            _view.MenuItemOpenFileClicked += this.OnMenuItemOpenFileClicked;
            _view.MenuItemCloseFileClicked += this.OnMenuItemCloseFileClicked;
            _view.MenuItemNewFileClicked += this.OnMenuItemNewFileClicked;
            _view.MenuItemExitClicked += this.OnMenuItemExitClicked;
            _view.MenuItemLanguageENClicked += this.OnMenuItemLanguageENClicked;
            _view.MenuItemLanguageNLClicked += this.OnMenuItemLanguageNLClicked;

            _localizationManagerModel = localizationManager;
            _localizationManagerModel.OnIniDataLoaded += OnIniDataLoaded;
            _view.LoadRequested += async (s, e) => await LoadIniFileAsync();
            _view.FormShown += (s, e) => OnFormShown();
        }

        public void Run()
        {
            Application.Run((Form)_view);  // Start/Show the MainForm.
        }

        public void OnFormShown()
        {
            if (Properties.Settings.Default.Language == "EN")
            {
                _view.MenuItemENChecked = true;
                _view.MenuItemNLChecked = false;
            }
            else if (Properties.Settings.Default.Language == "NL")
            {
                _view.MenuItemNLChecked = true;
                _view.MenuItemENChecked = false;
            }
            else
            {
                _view.ShowMessage("Onbekende taalinstelling aangetroffen", MessageType.Warning, MessageBoxIcon.Warning);  // TODO: string in het taalbestand opnemen.
            }
        }


        #region View Menu Items
        private void OnMenuItemOpenFileClicked(object? sender, EventArgs e)
        {
            _view.OpenFile();
        }
        private void OnMenuItemNewFileClicked(object? sender, EventArgs e)
        {
            _view.NewFile();
        }
        private void OnMenuItemCloseFileClicked(object? sender, EventArgs e)
        {
            _view.CloseFile();
        }
        private void OnMenuItemExitClicked(object? sender, EventArgs e)
        {
            _view.CloseView();
        }
        #endregion View Menu Items

        private void OnMenuItemLanguageNLClicked(object? sender, EventArgs e)
        {
            _view.SetLanguage(LanguageOption.NL.ToString());
        }

        private void OnMenuItemLanguageENClicked(object? sender, EventArgs e)
        {
            _view.SetLanguage(LanguageOption.EN.ToString());
        }

        #region Languages Files
        // This method is called when the model has loaded the INI data. It Updates the view.
        private void OnIniDataLoaded(Dictionary<string, Dictionary<string, string>> iniData)
        {
            // Zet de menu item teksten.
            if (iniData.TryGetValue("MenuItems", out Dictionary<string, string>? miValue))
            {
                foreach (var entry in miValue)
                {
                    _view.UpdateMenuItem(entry.Key, entry.Value);
                }
            }

            if (iniData.TryGetValue("MainForm", out Dictionary<string, string>? tcValue))
            {
                foreach (var entry in tcValue)
                {
                    _view.UpdateTabControlPage(entry.Key, entry.Value);
                }
            }
        }

        public async Task LoadIniFileAsync()
        {
            string filePath = Directory.GetCurrentDirectory();  // The ini files with the component texts must be in the application directory.
            try
            {
                switch (Settings.Default.Language)
                {
                    case "EN":
                        await _localizationManagerModel.LoadIniFileAsync(filePath, LocalizationManagerModel.LanguageOption.EN);
                        break;
                    case "NL":
                        await _localizationManagerModel.LoadIniFileAsync(filePath, LocalizationManagerModel.LanguageOption.NL);
                        break;
                    default:
                        await _localizationManagerModel.LoadIniFileAsync(filePath, LocalizationManagerModel.LanguageOption.EN);
                        break;
                }

                // Zet de tekst van het form.
                _view.UpdateFormText(GetStaticText("MainForm", "MainForm"));
                _view.UpdateStatusbarText("ToolStripStatusLabel1", GetStaticText("StatusStripMain", "ToolStripStatusLabel1"));
                _view.UpdateStatusbarText("ToolStripStatusLabel2", GetStaticText("StatusStripMain", "ToolStripStatusLabel2"));
            }
            catch (Exception ex)
            {
                _view.ShowMessage($"Fout bij het laden van het INI-bestand: {ex.Message}", MessageType.Error, MessageBoxIcon.Error);
            }
        }
        #endregion Languages Files

        public string GetStaticText(string section, string textKey)
        {
            return _localizationManagerModel.GetStaticText(section, textKey);
        }
    }
}
