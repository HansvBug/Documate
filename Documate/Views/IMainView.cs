using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Documate.Library;
using Documate.Models;

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
        event EventHandler MenuItemOptionsOptionsClicked;
        event EventHandler DoFormShown;
        event FormClosingEventHandler DoFormClosing;

        string FormMainText { set; }
        string MenuItemProgramText { set; }
        string MenuItemProgramOpenFileText { set; }
        string MenuItemProgramCloseFileText { set; }
        string MenuItemProgramNewFileText { set; }
        string MenuItemProgramExitText { set; }
        string MenuItemOptionsText { set; }
        string MenuItemOptionsOptionsText { set; }
        string MenuItemLanguageText { set; }
        string MenuItemLanguageENText { set; }
        string MenuItemLanguageNLText { set; }

        bool MenuItemENChecked { get; set; }
        bool MenuItemNLChecked { get; set; }

        string TabPageReadItemsText {  set; }
        string TabPageEditItemsText { set; }

        string ToolStripStatusLabel1Text { set; }
        string ToolStripStatusLabel2Text { set; }

        TabPage ATabPage { get; set; }

        void OpenFile();
        void CloseFile();
        void NewFile();
        void CloseView();
    }
}
