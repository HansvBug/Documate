using static Documate.Library.Common;

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

        event EventHandler RbReadCheckedChanged;
        event EventHandler RbModifyCheckedChanged;
        event EventHandler RbSetRelationsCheckedChanged;

        event EventHandler SaveItemDataClicked;  // TODO; ook in het menu zetten.

        

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
        string ToolStripStatusLabel3Text { set; }

        Panel? APanel {  set; get; }
        RadioButtonOption SelectedRadioButton { get; }  // Property to determine the selected radio button.
        string RbReadText { set; }
        string RbModifyText { set; }
        string RbSetRelationsText { set; }

        bool RbReadChecked { set; }

        bool ButtonSaveEnabled { set; }  // Set the Button state.

        void ShowItemDataInTextBox(string data); // show itemdata in a textbox.
        void CanSaveChanged(bool canSave);

        void OpenFile();
        void CloseFile();
        void NewFile();
        void CloseView();

        bool ViewKeyPreview { set; }
    }
}
