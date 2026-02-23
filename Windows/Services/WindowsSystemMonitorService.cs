using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms; // For SystemInformation (battery)
using StartupDashboard.Core;

namespace StartupDashboard.Services
{
    public class WindowsSystemMonitorService : ISystemMonitorService
    {
        private readonly PerformanceCounter _cpuCounter;
        private readonly PerformanceCounter _ramCounter;

        public WindowsSystemMonitorService()
        {
            _cpuCounter = new PerformanceCounter("Processor", "% Processor Time", "_Total");
            _ramCounter = new PerformanceCounter("Memory", "% Committed Bytes In Use");
            // Warm-up read so first real call is accurate
            _ = _cpuCounter.NextValue();
        }

        public SystemStats GetStats()
        {
            return new SystemStats
            {
                CpuUsage     = Math.Round(_cpuCounter.NextValue(), 1),
                MemoryUsage  = Math.Round(_ramCounter.NextValue(), 1),
                DiskUsage    = GetDiskUsage(),
                BatteryLevel = GetBatteryLevel(),
                IsCharging   = GetIsCharging()
            };
        }

        private static double GetDiskUsage()
        {
            try
            {
                var drive = new DriveInfo(Path.GetPathRoot(Environment.GetFolderPath(Environment.SpecialFolder.System)) ?? "C:\\");
                if (!drive.IsReady) return -1;
                double used  = drive.TotalSize - drive.TotalFreeSpace;
                return Math.Round((used / drive.TotalSize) * 100.0, 1);
            }
            catch { return -1; }
        }

        private static double GetBatteryLevel()
        {
            var status = SystemInformation.PowerStatus;
            float charge = status.BatteryLifePercent;
            return charge >= 0 && charge <= 1 ? Math.Round(charge * 100.0, 0) : -1;
        }

        private static bool GetIsCharging()
        {
            var status = SystemInformation.PowerStatus;
            return status.PowerLineStatus == PowerLineStatus.Online;
        }
    }
}
