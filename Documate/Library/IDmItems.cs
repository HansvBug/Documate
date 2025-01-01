using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Library
{
    public interface IDmItems
    {
        List<DmItem> Items { get; }
        void AddItem(DmItem item);
    }
}
