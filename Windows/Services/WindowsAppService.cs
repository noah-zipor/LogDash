using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using Microsoft.Win32;
using StartupDashboard.Core;

namespace StartupDashboard.Services
{
    public class WindowsAppService : IAppService
    {
        public IEnumerable<AppEntry> GetInstalledApps()
        {
            var apps = new Dictionary<string, AppEntry>();

            // Scan Registry for installed apps
            string[] registryPaths = {
                @"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
                @"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
            };

            foreach (var root in new[] { Registry.LocalMachine, Registry.CurrentUser })
            {
                foreach (var path in registryPaths)
                {
                    using (var key = root.OpenSubKey(path))
                    {
                        if (key == null) continue;
                        foreach (var subkeyName in key.GetSubKeyNames())
                        {
                            using (var subkey = key.OpenSubKey(subkeyName))
                            {
                                if (subkey == null) continue;

                                string? displayName = subkey.GetValue("DisplayName") as string;
                                string? installLocation = subkey.GetValue("InstallLocation") as string;
                                string? displayIcon = subkey.GetValue("DisplayIcon") as string;

                                if (!string.IsNullOrEmpty(displayName) && !apps.ContainsKey(displayName))
                                {
                                    string iconPath = ParseIconPath(displayIcon);
                                    apps[displayName] = new AppEntry
                                    {
                                        Name = displayName,
                                        ExecutablePath = installLocation,
                                        Icon = GetIconBytes(iconPath)
                                    };
                                }
                            }
                        }
                    }
                }
            }

            return apps.Values;
        }

        private string ParseIconPath(string displayIcon)
        {
            if (string.IsNullOrEmpty(displayIcon)) return null;
            var parts = displayIcon.Split(',');
            return parts[0].Trim('\"');
        }

        public void LaunchApp(AppEntry? app)
        {
            if (app != null && !string.IsNullOrEmpty(app.ExecutablePath))
            {
                Process.Start(new ProcessStartInfo(app.ExecutablePath) { UseShellExecute = true });
            }
        }

        private byte[] GetIconBytes(string path)
        {
            if (string.IsNullOrEmpty(path) || !File.Exists(path)) return null;
            try
            {
                using (Icon icon = Icon.ExtractAssociatedIcon(path))
                {
                    if (icon == null) return null;
                    using (MemoryStream ms = new MemoryStream())
                    {
                        icon.ToBitmap().Save(ms, ImageFormat.Png);
                        return ms.ToArray();
                    }
                }
            }
            catch { return null; }
        }
    }
}
