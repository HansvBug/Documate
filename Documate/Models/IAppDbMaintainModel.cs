using static Documate.Models.AppDbMaintainModel;

namespace Documate.Models
{
    public interface IAppDbMaintainModel
    {
        bool CopyDatabaseFile(string databaseName, CopyType type);
        void CompressDatabase();
        void ResetAllAutoIncrementFields();
        int GetColCount();
    }
}
