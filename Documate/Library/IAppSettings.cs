using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;



namespace Documate.Library
{
    public interface IAppSettings
    {
        string Language { get; set; }
        string DatabaseFolder { get; }

        #region Logging
        string LogFileName { get; }
        string LogFileLocation { get; set; }
        string ApplicationName { get; }
        string ApplicationVersion { get; }
        string ApplicationBuildDate { get; }
        #endregion Logging

        #region Configure
        bool ActivateLogging { get; set; }
        bool AppendLogFile { get; set; }
        #endregion Configure

        #region FormPosition
        Point GetLocation(string keyPrefix);
        void SetLocation(string keyPrefix, Point location);
        Size GetSize(string keyPrefix);        
        void SetSize(string keyPrefix, Size size);
        FormWindowState GetWindowState(string keyPrefix);
        void SetWindowState(string keyPrefix, FormWindowState state);

        #endregion FormPosition
    }
}
