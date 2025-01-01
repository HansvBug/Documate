using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Library
{
    public class DmItems: IDmItems
    {
        private readonly List<DmItem> items = new List<DmItem>();

        public List<DmItem> Items => items;

        public void AddItem(DmItem item)
        {
            items.Add(item);
        }
    }
}
