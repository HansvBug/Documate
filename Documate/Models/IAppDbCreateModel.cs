using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Models
{
    public interface IAppDbCreateModel
    {
        bool CreateAppDbFile(string databaseLocationName);
        int SelectMeta();
        void InsertMeta(string key, string value);
    }
}
