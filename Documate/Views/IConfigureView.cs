using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Views
{
    public interface IConfigureView
    {
        event EventHandler DoFormShown;
        event EventHandler BtnClosedClicked;
        event FormClosingEventHandler DoFormClosing;

        string FormConfigureText { set; }
        string ChkActivateLoggingText { set; }
        string ChkAppendLogFileText { set; }
        string TabPageVariousText { set; }
        string TabPageDatabaseText { set; }
        string BtnCloseText { set; }

        void CloseView();

    }
}
