using Documate.Presenters;

namespace Documate.Views
{
    public interface INewDbView
    {
        event EventHandler DoFormShown;
        event KeyPressEventHandler TbKeyPressed;
        event EventHandler TbTextColCountChanged;
        event EventHandler TbTextShortDescriptionChanged;
        event EventHandler BtSaveClicked;
        event EventHandler BtCancelClicked;

        string FormNewDbText { set; }
        string LbFileNameText { set; }
        string LbColCountText { set; }
        string LbShortDescriptionText { set; }
        string BtSaveText { set; }
        string BtCancelText { set; }
        string NewFileName { get; set; }
        void ShowWarning(string message);
        void ClearWarning();
        int ColCount { get; set; }
        string ShortDescription {  get; set; }
        
        bool CanContinue { get; set; }

        void SetPresenter(NewDbPresenter presenter);
        void CloseView();
    }
}
