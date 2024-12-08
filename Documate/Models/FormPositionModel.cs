using Documate.Library;
using Documate.Views;
using Microsoft.Win32.SafeHandles;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace Documate.Models
{
    public class FormPositionModel(IAppSettings appSettings) : IFormPositionModel, IDisposable
    {
        private readonly IAppSettings _appSettings = appSettings;

        /// <summary>
        /// Restore the form position parameters.
        /// </summary>
        //public void RestoreWindowPosition(Form form, string settingsKeyPrefix) //, Action setDefaultPosition)
        public void RestoreWindowPosition(Form form, string settingsKeyPrefix)  //, Action setDefaultPosition
        {
            Point location = _appSettings.GetLocation(settingsKeyPrefix);
            Size size = _appSettings.GetSize(settingsKeyPrefix);
           // FormWindowState windowState = _appSettings.GetWindowState(settingsKeyPrefix);

            // Check if there are valid saved settings.
            if (location != Point.Empty && size != Size.Empty)
            {
                var savedBounds = new Rectangle(location, size);

                // Check if the saved position is on an existing monitor.
                if (Screen.AllScreens.Any(s => s.WorkingArea.IntersectsWith(savedBounds)))
                {
                    form.Location = location;
                    form.Size = size;

                    // Restore window state (maximized (2), minimized (1), normal (0)).
                    if (_appSettings.GetWindowState(settingsKeyPrefix) == FormWindowState.Maximized)
                    {
                        form.WindowState = FormWindowState.Maximized;
                    }
                    else
                    {
                        form.WindowState = FormWindowState.Normal;
                    }

                    return; // Recovery completed.
                }
                else
                {
                    SetDefaultPosition(form);
                }
            }
            else
            {
                SetDefaultPosition(form);
            }

            // Use default position if settings are invalid.
            //    setDefaultPosition?.Invoke();
        }

        /// <summary>
        /// Store the form position parameters.
        /// </summary>
        public void StoreWindowPosition(Form form, string settingsKeyPrefix)
        {
            // Save the window status and size only when the window is not maximized.
            if (form.WindowState == FormWindowState.Normal)
            {
                _appSettings.SetLocation(settingsKeyPrefix, form.Location);
                _appSettings.SetSize(settingsKeyPrefix, form.Size);
            }

            // Save the window state (for example, maximized).
            _appSettings.SetWindowState(settingsKeyPrefix, (FormWindowState)form.WindowState);
        }

        /// <summary>
        /// Set the form to a default position.
        /// </summary>
        private static void SetDefaultPosition(Form form)
        {
            form.StartPosition = FormStartPosition.CenterScreen;
        }

        /// <summary>
        /// Handle monitor configuration changes.
        /// </summary>
        public void SystemEvents_DisplaySettingsChanged(Form form, string settingsKeyPrefix) // , Action setDefaultPosition
        {
            // Recheck the window position when making changes to the monitor configuration.
            RestoreWindowPosition(form, settingsKeyPrefix);  //, setDefaultPosition
        }


        #region Dispose

        // Flag: Has Dispose already been called?
        private bool _disposed;

        // Instantiate a SafeHandle instance.
        private readonly SafeHandle _safeHandle = new SafeFileHandle(IntPtr.Zero, true);

        /// <summary>
        /// Public implementation of Dispose pattern.
        /// </summary>
        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }

        /// <summary>
        /// Protected implementation of Dispose pattern.
        /// </summary>
        /// <param name="disposing">Has Dispose already been called.</param>
        protected virtual void Dispose(bool disposing)
        {
            if (!_disposed)
            {
                if (disposing)
                {
                    // Dispose managed resources
                    _safeHandle?.Dispose();
                }

                // Free unmanaged resources (if any) here

                _disposed = true;
            }
        }
        #endregion Dispose
    }
}
