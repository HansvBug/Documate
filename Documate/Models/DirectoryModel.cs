using Documate.Library;

namespace Documate.Models
{
    public class DirectoryModel(IAppSettings appSettings) : AppMessage, IDirectoryModel
    {
        private readonly IAppSettings _appSettings = appSettings;
        public enum DirectoryOption
        {
            AppData,
            ApplicatieDir
        }

        public void CreateDirectory(DirectoryOption option, string dirName)
        {
            string appName = _appSettings.ApplicationName;
            string basePath;

            switch (option)
            {
                case DirectoryOption.AppData:
                    basePath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
                    break;
                case DirectoryOption.ApplicatieDir:
                    basePath = Directory.GetCurrentDirectory();
                    appName = string.Empty;
                    break;
                default:
                    basePath = Directory.GetCurrentDirectory();
                    appName = string.Empty;
                    break;
            }

            DoCreateDirectory(basePath, appName, dirName);
        }

        private void DoCreateDirectory(string basePath, string appName, string dirName)
        {
            try
            {
                // Create the base directory.
                if (!Directory.Exists(basePath))
                {
                    Directory.CreateDirectory(basePath);

                    AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("DirectoryCreated", LocalizationPaths.DirectoryModel)} {basePath}"
                              );
                }

                // Add application directory if appName is provided.
                if (!string.IsNullOrEmpty(appName))
                {
                    basePath = Path.Combine(basePath, appName);

                    if (!Directory.Exists(basePath))
                    {
                        Directory.CreateDirectory(basePath);

                        AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("DirectoryCreated", LocalizationPaths.DirectoryModel)} {basePath}"
                              );
                    }
                }

                // Add sub-directory if dirName is provided.
                if (!string.IsNullOrEmpty(dirName))
                {
                    basePath = Path.Combine(basePath, dirName);
                    if (!Directory.Exists(basePath))
                    {
                        Directory.CreateDirectory(basePath);

                        AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("DirectoryCreated", LocalizationPaths.DirectoryModel)} {basePath}"
                              );
                    }
                }
            }
            catch (Exception ex)
            {
                AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("DirectoryCreateError", LocalizationPaths.DirectoryModel)} {basePath}"
                              );
                AddMessage(MessageType.Information,
                               $"{LocalizationHelper.GetString("ErrorDetails", LocalizationPaths.DirectoryModel)} {ex.Message}"
                              );
            }
        }
    }
}
