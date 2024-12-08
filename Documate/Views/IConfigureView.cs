using Documate.Presenters;
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
        event EventHandler ChkActivateLogging_CheckedChanged;
        event EventHandler ChkAppendLogFile_CheckedChanged;
        event EventHandler ChkAppendLogging_EnabledChanged;
        event EventHandler BtnCompressClicked;

        string FormConfigureText { set; }
        string GroupBoxLoggingText { set; }
        string ChkActivateLoggingText { set; }
        string ChkAppendLogFileText { set; }
        string TabPageVariousText { set; }
        string TabPageDatabaseText { set; }
        string BtnCloseText { set; }
        string BtnCompressDbText { set; }

        bool ActivateLoggingChecked { get; set; }
        bool AppendLogFileChecked { get; set; }
        bool AppendLogFileEnabled { get; set; }

        void CloseView();
        void SetPresenter(ConfigurePresenter presenter);



    }
}
