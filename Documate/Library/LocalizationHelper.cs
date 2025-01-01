using System.Globalization;
using System.Resources;

namespace Documate.Library
{
    public static class LocalizationHelper
    {
        public static string GetString(string key, string resourcePath)
        {
            try
            {
                ResourceManager resourceManager = new(resourcePath, typeof(LocalizationHelper).Assembly);
                return resourceManager.GetString(key, CultureInfo.CurrentUICulture) ?? $"{key}"; // Fallback with debug-placeholder.
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error retrieving key '{key}' from '{resourcePath}': {ex.Message}");
                return $"{key}"; // Fallback to a recognizable placeholder.
            }
        }

        public static void SetCulture(string cultureCode)
        {
            CultureInfo newCulture = new(cultureCode);
            CultureInfo.CurrentCulture = newCulture;
            CultureInfo.CurrentUICulture = newCulture;

            // Save the language in settings.
            Properties.Settings.Default.Language = cultureCode;
            Properties.Settings.Default.Save();
        }
    }

    public static class LocalizationPaths
    {
        public const string General             = "Documate.Resources.general.General";
        public const string MainForm            = "Documate.Resources.Views.MainForm";
        public const string ConfigureForm       = "Documate.Resources.Views.ConfigureForm";
        public const string NewDbForm           = "Documate.Resources.Views.NewDatabaseForm";

        public const string MainPresenter       = "Documate.Resources.Presenters.MainPresenter";
        public const string NewDbPresenter      = "Documate.Resources.Presenters.NewDbPresenter";
        public const string ConfigurePresenter  = "Documate.Resources.Presenters.ConfigurePresenter";

        public const string DirectoryModel      = "Documate.Resources.Models.Directory";
        public const string AppDb               = "Documate.Resources.Models.AppDb";
        public const string AppDbCreate         = "Documate.Resources.Models.AppDbCreate";
        public const string AppDbMaintain       = "Documate.Resources.Models.AppDbMaintain";
        public const string AppDbMaintainItems  = "Documate.Resources.Models.AppDbMaintainItems";
        public const string CreateControls      = "Documate.Resources.Models.CreateControls";

        public const string Logging             = "Documate.Resources.Logging.Logging";
        
        public const string StatusStripHelper   = "Documate.Resources.Library.StatusStripHelper";
    }
}
