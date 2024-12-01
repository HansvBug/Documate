using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Globalization;

namespace Documate.Library
{
    public class AppSettings : IAppSettings
    {
        public string Language
        {
            get => Properties.Settings.Default.Language;
            set
            {
                Properties.Settings.Default.Language = value;
                Properties.Settings.Default.Save();
            }
        }
        public string DatabaseFolder
        {
            get => Properties.Settings.Default.DatabaseFolder;  // TODO; configure Database folder.
        }

        #region Logging
        public string LogFileName
        {
            get => Properties.Settings.Default.LogFileName;
        }

        public string LogFileLocation
        {
            get => Properties.Settings.Default.LogFileLocation;
            set
            {
                Properties.Settings.Default.LogFileLocation = value;
                Properties.Settings.Default.Save();
            }
        }
        public string ApplicationName
        {
            get => Properties.Settings.Default.ApplicationName;

        }

        public string ApplicationVersion
        {
            get => Properties.Settings.Default.ApplicationVersion;
        }

        public string ApplicationBuildDate
        {
            get
            {
                return DateTime.Now.ToString("dd-MM-yyyy", CultureInfo.InvariantCulture);
            }
        }

        #endregion Logging

        #region Configure
        public bool ActivateLogging
        {
            get => Properties.Settings.Default.ActivateLogging;
            set
            {
                Properties.Settings.Default.ActivateLogging = value;
                Properties.Settings.Default.Save();
            }
        }
        
        public bool AppendLogFile
        {
            get => Properties.Settings.Default.AppendLogFile;
            set
            {
                Properties.Settings.Default.AppendLogFile = value;
                Properties.Settings.Default.Save();
            }
        }
        #endregion Configure

        #region FormPosition
        public Point GetLocation(string keyPrefix)
        {
            {
                var key = $"{keyPrefix}Location";
                if (Properties.Settings.Default[key] is Point location)
                {
                    return location;
                }

                // Retourneer een standaardwaarde als de sleutel niet bestaat
                return Point.Empty;
            }
        }
        public void SetLocation(string keyPrefix, Point location)
        {
            var key = $"{keyPrefix}Location";
            Properties.Settings.Default[key] = location;
            Properties.Settings.Default.Save();
        }

        public Size GetSize(string keyPrefix)
        {
            var key = $"{keyPrefix}Size";
            if (Properties.Settings.Default[key] is Size size)
            {
                return size;
            }
            return Size.Empty; // Standaardwaarde als de sleutel niet bestaat
        }

        public void SetSize(string keyPrefix, Size size)
        {
            var key = $"{keyPrefix}Size";
            Properties.Settings.Default[key] = size;
            Properties.Settings.Default.Save();
        }

        public FormWindowState GetWindowState(string keyPrefix)
        {
            var key = $"{keyPrefix}WindowState";
            if (Properties.Settings.Default[key] is string stateString &&
                Enum.TryParse(stateString, out FormWindowState state))
            {
                return state;
            }

            // Standaardwaarde als de sleutel niet bestaat
            return FormWindowState.Normal;
        }

        public void SetWindowState(string keyPrefix, FormWindowState state)
        {
            var key = $"{keyPrefix}WindowState";
            Properties.Settings.Default[key] = state.ToString(); // Sla de state op als string
            Properties.Settings.Default.Save();
        }
        #endregion FormPosition
    }
}
