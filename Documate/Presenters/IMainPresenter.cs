using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Documate.Models;
using static Documate.Library.Common;
using static Documate.Models.LoggingModel;
using static Documate.Presenters.MainPresenter;

namespace Documate.Presenters
{
    public interface IMainPresenter
    {
        /// <summary>
        /// Start the program.
        /// </summary>
        void Run();
        void OnFormShown();
        void OnFormClosing();

        void CreateDirectory(DirectoryModel.DirectoryOption directoryOption, string FolderName);
        void StartLogging();
        void StopLogging();
        void WriteToLog(LogAction logAction, string logText);
        void SetStatusbarStaticText(string toolStripStatusLabelName, string text);
    }
}
