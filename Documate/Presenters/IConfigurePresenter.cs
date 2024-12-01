using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Documate.Presenters
{
    public  interface IConfigurePresenter
    {
        void OnFormShown();
        void LoadSettings();
        void SaveSettings();
        void LoadFormPosition();
        void SaveFormPosition();

    }
}
