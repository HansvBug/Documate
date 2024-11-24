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
        void LoadFormPosition(ConfigureForm configureForm);
        void SaveFormPosition(ConfigureForm configureForm);
    }
}
