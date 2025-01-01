using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static Documate.Library.Common;
using System.Windows.Forms;
using Documate.Views;

namespace Documate.Library
{
    public static class StatusStripHelper
    {
        private static IMainView? _view;
        public enum TsStatusLblName
        {
            tsOne,
            tsTwo,
            tsThree,
        }

        public static void Initialize(IMainView view)
        {
            _view = view;
        }

        public static void SetStatusbarStaticText(TsStatusLblName toolstripName, string text)
        {
            if (_view == null)
            {
                throw new InvalidOperationException(LocalizationHelper.GetString("ViewIsNotInitialized", LocalizationPaths.StatusStripHelper)); 
            }

            switch(toolstripName)
            {
                case TsStatusLblName.tsOne:
                    _view.ToolStripStatusLabel1Text = text;
                    break;
                case TsStatusLblName.tsTwo:
                    _view.ToolStripStatusLabel2Text = text;
                    break;
                case TsStatusLblName.tsThree:
                    _view.ToolStripStatusLabel3Text = text;
                    break;
            }
        }
    }
}
