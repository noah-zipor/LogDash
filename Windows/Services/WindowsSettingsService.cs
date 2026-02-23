using Microsoft.Win32;
using StartupDashboard.Core;

namespace StartupDashboard.Services
{
    public class WindowsSettingsService : ISettingsService
    {
        private const string RootKey = @"Software\StartupDashboard\Settings";

        public void SetString(string key, string value)
        {
            using (var registryKey = Registry.CurrentUser.CreateSubKey(RootKey))
            {
                registryKey.SetValue(key, value);
            }
        }

        public string GetString(string key, string defaultValue = "")
        {
            using (var registryKey = Registry.CurrentUser.OpenSubKey(RootKey))
            {
                return registryKey?.GetValue(key) as string ?? defaultValue;
            }
        }

        public void SetBool(string key, bool value)
        {
            using (var registryKey = Registry.CurrentUser.CreateSubKey(RootKey))
            {
                registryKey.SetValue(key, value ? 1 : 0, RegistryValueKind.DWord);
            }
        }

        public bool GetBool(string key, bool defaultValue = false)
        {
            using (var registryKey = Registry.CurrentUser.OpenSubKey(RootKey))
            {
                var val = registryKey?.GetValue(key);
                if (val is int i) return i == 1;
                return defaultValue;
            }
        }
    }
}
