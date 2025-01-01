using Documate.Library;

namespace Documate.Models
{
    public interface IAppDbMaintainItemsModel
    {
        List<DmItem> ReadLevel(int level, DataGridView dgv, bool sorted);

        void SaveItems(int level, DataGridView dgv);
        void RemoveEmptyRows(DataGridView dgv);
    }
}
