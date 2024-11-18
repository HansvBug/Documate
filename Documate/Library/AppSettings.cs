using System.Globalization;

namespace Documate.Library
{
    public static class AppSettings
    {
        public static string ApplicationBuildDate { get { return DateTime.Now.ToString("dd-MM-yyyy", CultureInfo.InvariantCulture); } }

        public const string DatabaseFolder = "Database";
        public const string LoggingFolder = "Logging";
    }
}