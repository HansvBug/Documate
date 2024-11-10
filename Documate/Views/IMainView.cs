using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Documate.Models;
using static Documate.Models.LocalizationManagerModel;

namespace Documate.Views
{
    public interface IMainView
    {        
        event EventHandler MenuItemOpenFileClicked;
        event EventHandler MenuItemCloseFileClicked;
        event EventHandler MenuItemNewFileClicked;
        event EventHandler MenuItemExitClicked;
        event EventHandler MenuItemLanguageNLClicked;
        event EventHandler MenuItemLanguageENClicked;
        event EventHandler LoadRequested;
        event EventHandler FormShown;

        bool MenuItemENChecked { get; set; }
        bool MenuItemNLChecked { get; set; }

        void OpenFile();
        void CloseFile();
        void NewFile();
        void CloseView();

        #region Update language
        void SetLanguage(string language);
        void ShowMessage(string message, MessageType messageType, MessageBoxIcon mbIcon);
        void UpdateMenuItem(string menuItemName, string menuItemText);
        void UpdateTabControlPage(string pageName, string pageText);
        void UpdateStatusbarText(string statusbarToolstripName, string toolstripNameText);
        #endregion Update language

        void UpdateFormText(string text);        
    }
}
