using static Documate.Models.DirectoryModel;

namespace Documate.Models
{
    public interface IDirectoryModel
    {
        void CreateDirectory(DirectoryOption option, string dirName);
    }
}
