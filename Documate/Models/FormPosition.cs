using Microsoft.Win32.SafeHandles;
using System.Runtime.InteropServices;

namespace Documate.Models
{
    public class FormPosition : IDisposable
    {
        private readonly MainForm _mainForm;
        private readonly ConfigureForm _configureForm;
        public FormPosition(MainForm mainForm)
        {
            _mainForm = mainForm ?? throw new ArgumentNullException(nameof(mainForm));
        }

        public FormPosition(ConfigureForm configureForm)
        {
            _configureForm = configureForm ?? throw new ArgumentNullException( nameof(configureForm));
        }

        /// <summary>
        /// Restore the main form position parameters.
        /// </summary>
        public void RestoreMainFrmWindowPosition()
        {
            // Check if there are valid saved settings.
            if (Properties.Settings.Default.MainFrmLocation != Point.Empty &&
                Properties.Settings.Default.MainFrmSize != Size.Empty)
            {
                var savedBounds = new Rectangle(
                    Properties.Settings.Default.MainFrmLocation,
                    Properties.Settings.Default.MainFrmSize
                );

                // Check if the saved position is on an existing monitor.
                if (Screen.AllScreens.Any(s => s.WorkingArea.IntersectsWith(savedBounds)))
                {
                    _mainForm.Location = Properties.Settings.Default.MainFrmLocation;
                    _mainForm.Size = Properties.Settings.Default.MainFrmSize;

                    // Restore window status (Maximized (2), Minimized (1), Normal (0))
                    if (Properties.Settings.Default.MainFrmWindowstate == 2)
                    {
                        _mainForm.WindowState = FormWindowState.Maximized;
                    }
                    else
                    {
                        _mainForm.WindowState = FormWindowState.Normal;
                    }
                }
                else
                {
                    // Default position if saved position is invalid
                    SetMainFrmDefaultPosition();
                }
            }
            else
            {
                // Default position if no settings exist
                SetMainFrmDefaultPosition();
            }
        }

        /// <summary>
        /// Store the main form position parameters.
        /// </summary>
        public void StoreMainFrmWindowPosition()
        {
            // Save the window status and size only when the window is not maximized.
            if (_mainForm.WindowState == FormWindowState.Normal)
            {
                Properties.Settings.Default.MainFrmLocation = _mainForm.Location;
                Properties.Settings.Default.MainFrmSize = _mainForm.Size;
            }

            // Save window state (e.g. maximized).
            Properties.Settings.Default.MainFrmWindowstate = (int)_mainForm.WindowState;
            Properties.Settings.Default.Save();
        }

        /// <summary>
        /// Set the form to a default position.
        /// </summary>
        private void SetMainFrmDefaultPosition()
        {
            _mainForm.StartPosition = FormStartPosition.CenterScreen;
        }

        /// <summary>
        /// Handle monitor configuration changes.
        /// </summary>
        public void SystemEvents_MainFrm_DisplaySettingsChanged(object sender, EventArgs e)
        {
            // Recheck the window position when the monitor configuration changes.
            RestoreMainFrmWindowPosition();
        }

        public void SystemEvents_ConfigureFrm_DisplaySettingsChanged(object sender, EventArgs e)
        {
            // Recheck the window position when the monitor configuration changes.
            RestoreConfigureFrmWindowPosition();
        }

        #region ConfigureForm
        public void RestoreConfigureFrmWindowPosition()
        {
            // Check if there are valid saved settings.
            if (Properties.Settings.Default.ConfigureFrmLocation != Point.Empty &&
                Properties.Settings.Default.ConfigureFrmSize != Size.Empty)
            {
                var savedBounds = new Rectangle(
                    Properties.Settings.Default.ConfigureFrmLocation,
                    Properties.Settings.Default.ConfigureFrmSize
                );

                // Check if the saved position is on an existing monitor.
                if (Screen.AllScreens.Any(s => s.WorkingArea.IntersectsWith(savedBounds)))
                {
                    _configureForm.Location = Properties.Settings.Default.ConfigureFrmLocation;
                    _configureForm.Size = Properties.Settings.Default.ConfigureFrmSize;

                    // Restore window status (Maximized (2), Minimized (1), Normal (0))
                    if (Properties.Settings.Default.ConfigureFrmWindowstate == 2)
                    {
                        _configureForm.WindowState = FormWindowState.Maximized;
                    }
                    else
                    {
                        _configureForm.WindowState = FormWindowState.Normal;
                    }
                }
                else
                {
                    // Default position if saved position is invalid
                    SetConfigureFrmDefaultPosition();
                }
            }
            else
            {
                // Default position if no settings exist
                SetConfigureFrmDefaultPosition();
            }
        }

        public void StoreConfigureFrmWindowPosition()
        {
            // Save the window status and size only when the window is not maximized.
            if (_configureForm.WindowState == FormWindowState.Normal)
            {
                Properties.Settings.Default.ConfigureFrmLocation = _configureForm.Location;
                Properties.Settings.Default.ConfigureFrmSize = _configureForm.Size;
            }

            // Save window state (e.g. maximized).
            Properties.Settings.Default.ConfigureFrmWindowstate = (int)_configureForm.WindowState;
            Properties.Settings.Default.Save();
        }

        private void SetConfigureFrmDefaultPosition()
        {
            _configureForm.StartPosition = FormStartPosition.CenterScreen;
        }
        #endregion ConfigureFrom

        #region Dispose

        // Flag: Has Dispose already been called?
        private bool _disposed;

        // Instantiate a SafeHandle instance.
        private SafeHandle _safeHandle = new SafeFileHandle(IntPtr.Zero, true);

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
