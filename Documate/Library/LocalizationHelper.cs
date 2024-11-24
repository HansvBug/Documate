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
                ResourceManager resourceManager = new ResourceManager(resourcePath, typeof(LocalizationHelper).Assembly);
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
            CultureInfo newCulture = new CultureInfo(cultureCode);
            CultureInfo.CurrentCulture = newCulture;
            CultureInfo.CurrentUICulture = newCulture;

            // Save the language in settings.
            Properties.Settings.Default.Language = cultureCode;
            Properties.Settings.Default.Save();
        }
    }

    public static class LocalizationPaths
    {
        public const string General = "Documate.Resources.general.General";
        public const string MainForm = "Documate.Resources.Views.MainForm";
        public const string MainPresenter = "Documate.Resources.Presenters.MainPresenter";
        public const string DirectoryModel = "Documate.Resources.Models.DirectoryModel";
        public const string Logging = "Documate.Resources.Logging.Logging";
        public const string ConfigureForm = "Documate.Resources.Views.ConfigureForm";


    }
}
