using Microsoft.Win32;
using System.Diagnostics;
using StartupDashboard.Core;

namespace StartupDashboard.Services
{
    public class WindowsStartupService : IStartupService
    {
        private const string AppName = "StartupDashboard";
        private const string RegistryPath = @"Software\Microsoft\Windows\CurrentVersion\Run";

        public bool IsRegisteredForStartup()
        {
            using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RegistryPath))
            {
                return key?.GetValue(AppName) != null;
            }
        }

        public void RegisterForStartup()
        {
            try
            {
                string? exePath = Process.GetCurrentProcess().MainModule?.FileName;
                if (string.IsNullOrEmpty(exePath)) return;

                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RegistryPath, true))
                {
                    key?.SetValue(AppName, $"\"{exePath}\"");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Failed to register for startup: {ex.Message}");
            }
        }

        public void UnregisterFromStartup()
        {
            try
            {
                using (RegistryKey key = Registry.CurrentUser.OpenSubKey(RegistryPath, true))
                {
                    key?.DeleteValue(AppName, false);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Failed to unregister from startup: {ex.Message}");
            }
        }
    }
}
