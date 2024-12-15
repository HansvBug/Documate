using Documate.Models;

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
        void LoadFormPosition();
        void SaveFormPosition();

        void OpenConfigureForm();
    }
}
